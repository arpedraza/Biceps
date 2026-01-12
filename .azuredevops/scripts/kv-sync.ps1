[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$KeyVaultName,

  [Parameter(Mandatory = $false)]
  [string]$AppsRoot = "apps",

  [Parameter(Mandatory = $false)]
  [switch]$IncludeTemplate,

  [Parameter(Mandatory = $false)]
  [ValidateRange(16, 128)]
  [int]$PasswordLength = 28
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-RandomPassword {
  param([int]$Length)

  $lower = 'abcdefghijkmnopqrstuvwxyz'  # omit l
  $upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'  # omit I,O
  $digits = '23456789'                 # omit 0,1
  $special = '!@#$%^&*()-_=+[]{}:,.?'
  $all = ($lower + $upper + $digits + $special).ToCharArray()

  # ensure at least one from each class
  $chars = @(
    $lower[(Get-Random -Minimum 0 -Maximum $lower.Length)]
    $upper[(Get-Random -Minimum 0 -Maximum $upper.Length)]
    $digits[(Get-Random -Minimum 0 -Maximum $digits.Length)]
    $special[(Get-Random -Minimum 0 -Maximum $special.Length)]
  )

  $remaining = $Length - $chars.Count
  if ($remaining -lt 0) { throw "PasswordLength must be >= 4." }

  for ($i = 0; $i -lt $remaining; $i++) {
    $chars += $all[(Get-Random -Minimum 0 -Maximum $all.Length)]
  }

  # shuffle
  return (-join ($chars | Sort-Object { Get-Random }))
}

function Get-InventoryFiles {
  param([string]$Root, [switch]$IncludeTemplate)

  if (-not (Test-Path -LiteralPath $Root)) {
    throw "AppsRoot path not found: $Root"
  }

  $files = Get-ChildItem -Path $Root -Recurse -File -Filter 'inventory.json' |
    Where-Object {
      if (-not $IncludeTemplate -and $_.FullName -match "[\\/]_template[\\/]") { return $false }
      return $true
    }

  return $files
}

Write-Host "Key Vault sync starting..."
Write-Host "  Vault: $KeyVaultName"
Write-Host "  AppsRoot: $AppsRoot"
Write-Host "  IncludeTemplate: $IncludeTemplate"
Write-Host ""

$inventoryFiles = Get-InventoryFiles -Root $AppsRoot -IncludeTemplate:$IncludeTemplate

if ($inventoryFiles.Count -eq 0) {
  Write-Warning "No inventory.json files found under '$AppsRoot'. Nothing to do."
  Write-Host "##vso[task.setvariable variable=localAdminPasswordsJson;issecret=true]{}"
  Write-Host "##vso[task.setvariable variable=vmKeyUrlsJson;issecret=true]{}"
  exit 0
}

$vmNames = New-Object 'System.Collections.Generic.HashSet[string]'
$vmList = @()

foreach ($file in $inventoryFiles) {
  $raw = Get-Content -LiteralPath $file.FullName -Raw
  if ([string]::IsNullOrWhiteSpace($raw)) { continue }

  $items = $raw | ConvertFrom-Json
  if ($items -isnot [System.Collections.IEnumerable]) {
    throw "Inventory file must be a JSON array: $($file.FullName)"
  }

  foreach ($vm in $items) {
    if (-not $vm.vmName) { throw "Missing vmName in inventory: $($file.FullName)" }
    $name = [string]$vm.vmName
    if (-not $vmNames.Add($name)) { throw "Duplicate vmName detected across inventories: $name" }
    $vmList += [pscustomobject]@{ VmName = $name; InventoryPath = $file.FullName }
  }
}

Write-Host ("Found {0} VM(s) across {1} inventory file(s)." -f $vmList.Count, $inventoryFiles.Count)

$localAdminPasswords = @{}
$vmKeyUrls = @{}

foreach ($entry in $vmList) {
  $vmName = $entry.VmName
  $secretName = "${vmName}-local-admin"
  $keyName = "key-${vmName}"

  # Ensure secret exists
  $secret = $null
  try { $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $secretName -ErrorAction Stop } catch { $secret = $null }

  if (-not $secret) {
    $pwd = New-RandomPassword -Length $PasswordLength
    $secure = ConvertTo-SecureString -String $pwd -AsPlainText -Force
    $tags = @{ username = 'epadmin'; vmName = $vmName; purpose = 'local-admin' }
    Write-Host "Creating secret: $secretName"
    $null = Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $secretName -SecretValue $secure -ContentType 'local-admin-password' -Tag $tags
  } else {
    Write-Host "Secret exists: $secretName"
  }

  $localAdminPasswords[$vmName] = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $secretName -AsPlainText)

  # Ensure key exists (RSA software)
  $key = $null
  try { $key = Get-AzKeyVaultKey -VaultName $KeyVaultName -Name $keyName -ErrorAction Stop } catch { $key = $null }

  if (-not $key) {
    Write-Host "Creating key: $keyName (RSA software-backed)"
    $null = Add-AzKeyVaultKey -VaultName $KeyVaultName -Name $keyName -Destination 'Software' -KeyOps @('wrapKey','unwrapKey','get')
    $key = Get-AzKeyVaultKey -VaultName $KeyVaultName -Name $keyName
  } else {
    Write-Host "Key exists: $keyName"
  }

  # Versioned URL is in Key.Kid
  $vmKeyUrls[$vmName] = $key.Key.Kid
}

$localAdminPasswordsJson = ($localAdminPasswords | ConvertTo-Json -Depth 5 -Compress)
$vmKeyUrlsJson = ($vmKeyUrls | ConvertTo-Json -Depth 5 -Compress)

Write-Host ""
Write-Host "Setting pipeline variables localAdminPasswordsJson and vmKeyUrlsJson (secret)..."
Write-Host "##vso[task.setvariable variable=localAdminPasswordsJson;issecret=true]$localAdminPasswordsJson"
Write-Host "##vso[task.setvariable variable=vmKeyUrlsJson;issecret=true]$vmKeyUrlsJson"

Write-Host "Key Vault sync completed."
