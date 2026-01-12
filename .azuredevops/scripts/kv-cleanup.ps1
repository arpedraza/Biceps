[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$KeyVaultName,

  [Parameter(Mandatory = $true)]
  [string]$RemovedVmsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$removedMap = $RemovedVmsJson | ConvertFrom-Json

$vmNames = New-Object System.Collections.Generic.HashSet[string]
foreach ($p in $removedMap.PSObject.Properties) {
  foreach ($n in @($p.Value)) {
    if (-not [string]::IsNullOrWhiteSpace([string]$n)) {
      $null = $vmNames.Add([string]$n)
    }
  }
}

if ($vmNames.Count -eq 0) {
  Write-Host "No removed VMs detected for KV cleanup. Nothing to do."
  exit 0
}

Write-Host "Key Vault cleanup starting..."
Write-Host "  Vault: $KeyVaultName"
Write-Host "  VM count: $($vmNames.Count)"

foreach ($vmName in $vmNames) {
  $secretName = "${vmName}-local-admin"
  $keyName = "key-${vmName}"

  # Secret delete (soft-delete retention handled by Key Vault settings)
  try {
    Write-Host "Deleting secret (soft-delete): $secretName"
    $null = Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $secretName -Force -ErrorAction Stop
  } catch {
    Write-Warning "Secret delete failed or not found: $secretName. $($_.Exception.Message)"
  }

  # Key delete (soft-delete retention handled by Key Vault settings)
  try {
    Write-Host "Deleting key (soft-delete): $keyName"
    $null = Remove-AzKeyVaultKey -VaultName $KeyVaultName -Name $keyName -Force -ErrorAction Stop
  } catch {
    Write-Warning "Key delete failed or not found: $keyName. $($_.Exception.Message)"
  }
}

Write-Host "Key Vault cleanup completed. (Items should remain recoverable for your vault's retention period, e.g. 90 days.)"
