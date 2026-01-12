param(
  [Parameter(Mandatory=$true)]
  [string]$BaseRef,

  [Parameter(Mandatory=$true)]
  [string]$HeadRef,

  [Parameter(Mandatory=$false)]
  [string]$AppsRoot = "apps"
)

$ErrorActionPreference = 'Stop'

function Set-VsoVariable {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][string]$Value,
    [switch]$IsOutput,
    [switch]$IsSecret
  )

  $flags = @()
  if ($IsOutput) { $flags += 'isOutput=true' }
  if ($IsSecret) { $flags += 'issecret=true' }
  $flagStr = ($flags -join ';')
  if ([string]::IsNullOrWhiteSpace($flagStr)) {
    Write-Host "##vso[task.setvariable variable=$Name]$Value"
  } else {
    Write-Host "##vso[task.setvariable variable=$Name;$flagStr]$Value"
  }
}

function Get-EnvParamValue {
  param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [Parameter(Mandatory=$true)][string]$ParamName
  )

  if (-not (Test-Path -LiteralPath $FilePath)) {
    throw "env parameter file not found: $FilePath"
  }

  $text = Get-Content -LiteralPath $FilePath -Raw
  # Match: param <name> = 'value'  OR  param <name> = "value"
  $re = [regex]"(?m)^\s*param\s+$([regex]::Escape($ParamName))\s*=\s*(['\"])(?<val>[^'\"\r\n]+)\1\s*$"
  $m = $re.Match($text)
  if (-not $m.Success) {
    throw "Missing required param '$ParamName' in $FilePath"
  }
  return $m.Groups['val'].Value
}

function Get-InventoryFromGit {
  param(
    [Parameter(Mandatory=$true)][string]$Ref,
    [Parameter(Mandatory=$true)][string]$Path
  )

  $content = $null
  try {
    $content = git show "${Ref}:${Path}" 2>$null
  } catch {
    return @() # file did not exist
  }
  if ([string]::IsNullOrWhiteSpace($content)) { return @() }
  $json = $content | ConvertFrom-Json
  if ($null -eq $json) { return @() }
  if ($json -is [System.Array]) { return $json }
  # allow single object
  return @($json)
}

function Get-ChangedScopes {
  param(
    [Parameter(Mandatory=$true)][string]$Base,
    [Parameter(Mandatory=$true)][string]$Head
  )

  $diff = git diff --name-only $Base $Head
  $scopes = @{}

  foreach ($p in $diff) {
    if ([string]::IsNullOrWhiteSpace($p)) { continue }
    if (-not $p.StartsWith("$AppsRoot/")) { continue }
    if ($p -match "^$([regex]::Escape($AppsRoot))/([^/]+)/([^/]+)/") {
      $app = $Matches[1]
      $env = $Matches[2]
      if ($app -eq '_template') { continue }
      $key = "$app|$env"
      $scopes[$key] = @{ app=$app; env=$env }
    }
  }

  return $scopes.Values
}

Write-Host "Detecting changed scopes between '$BaseRef' and '$HeadRef'..."

$changedScopes = Get-ChangedScopes -Base $BaseRef -Head $HeadRef

if ($changedScopes.Count -eq 0) {
  Write-Host "No app/env changes detected under $AppsRoot."
  Set-VsoVariable -Name 'scopesJson' -Value '[]'
  Set-VsoVariable -Name 'removedVmsJson' -Value '{}'
  exit 0
}

$scopeObjects = @()
$removed = @{}

foreach ($s in $changedScopes) {
  $app = $s.app
  $env = $s.env
  $scopePath = "$AppsRoot/$app/$env"
  $envParamFile = "$scopePath/env.bicepparam"
  $inventoryFile = "$scopePath/inventory.json"

  $subscriptionId = Get-EnvParamValue -FilePath $envParamFile -ParamName 'targetSubscriptionId'
  $resourceGroupName = Get-EnvParamValue -FilePath $envParamFile -ParamName 'targetResourceGroupName'
  $location = Get-EnvParamValue -FilePath $envParamFile -ParamName 'targetLocation'

  $stackName = "$app-$env"

  # Compute removed VMs by comparing inventories in git
  $baseInv = Get-InventoryFromGit -Ref $BaseRef -Path $inventoryFile
  $headInv = Get-InventoryFromGit -Ref $HeadRef -Path $inventoryFile
  $baseNames = @($baseInv | ForEach-Object { $_.vmName } | Where-Object { $_ })
  $headNames = @($headInv | ForEach-Object { $_.vmName } | Where-Object { $_ })
  $removedNames = @($baseNames | Where-Object { $_ -notin $headNames })
  $removed[$stackName] = $removedNames

  $scopeObjects += [pscustomobject]@{
    app = $app
    env = $env
    stackName = $stackName
    subscriptionId = $subscriptionId
    resourceGroupName = $resourceGroupName
    location = $location
    envParamFile = $envParamFile
    inventoryFile = $inventoryFile
  }
}

$scopesJson = ($scopeObjects | ConvertTo-Json -Depth 10 -Compress)
$removedJson = ($removed | ConvertTo-Json -Depth 10 -Compress)

Write-Host "Detected scopes: $scopesJson"
Write-Host "Removed VMs map: $removedJson"

Set-VsoVariable -Name 'scopesJson' -Value $scopesJson
Set-VsoVariable -Name 'removedVmsJson' -Value $removedJson
