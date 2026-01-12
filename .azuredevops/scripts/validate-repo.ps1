param(
  [Parameter(Mandatory=$false)]
  [string]$AppsRoot = 'apps'
)

$ErrorActionPreference = 'Stop'

function Assert($Condition, $Message) {
  if (-not $Condition) { throw $Message }
}

Write-Host "Validating Bicep files..."

# Ensure Bicep tooling is available
try {
  az bicep version | Out-Host
} catch {
  throw "Azure CLI + bicep is required on agent. Error: $($_.Exception.Message)"
}

$bicepFiles = @(
  'infra/subscription-deploy.bicep',
  'infra/rg-deploy.bicep'
)

foreach ($f in $bicepFiles) {
  Assert (Test-Path -LiteralPath $f) "Missing required bicep file: $f"
  Write-Host "- az bicep build $f"
  az bicep build --file $f --only-show-errors | Out-Null
}

Write-Host "Validating inventory.json files under $AppsRoot..."

$inventoryFiles = Get-ChildItem -Path $AppsRoot -Filter 'inventory.json' -Recurse -File |
  Where-Object { $_.FullName -notmatch "\\_template\\" }

foreach ($inv in $inventoryFiles) {
  Write-Host "- $($inv.FullName)"
  $raw = Get-Content -LiteralPath $inv.FullName -Raw
  Assert (-not [string]::IsNullOrWhiteSpace($raw)) "Empty inventory file: $($inv.FullName)"

  $data = $raw | ConvertFrom-Json
  if ($data -isnot [System.Array]) { $data = @($data) }

  $names = @()
  foreach ($vm in $data) {
    Assert ($null -ne $vm.vmName -and -not [string]::IsNullOrWhiteSpace([string]$vm.vmName)) "inventory item missing vmName in $($inv.FullName)"
    Assert ($null -ne $vm.osType -and -not [string]::IsNullOrWhiteSpace([string]$vm.osType)) "inventory item '$($vm.vmName)' missing osType in $($inv.FullName)"

    $os = ([string]$vm.osType).ToLowerInvariant()
    Assert (@('windows','linux') -contains $os) "inventory item '$($vm.vmName)' has invalid osType '$($vm.osType)' in $($inv.FullName)"

    $names += [string]$vm.vmName

    if ($vm.PSObject.Properties.Name -contains 'domainJoined') {
      Assert ($vm.domainJoined -is [bool]) "inventory item '$($vm.vmName)' domainJoined must be boolean in $($inv.FullName)"
    }

    if ($vm.PSObject.Properties.Name -contains 'tags') {
      Assert ($vm.tags -is [pscustomobject] -or $vm.tags -is [hashtable]) "inventory item '$($vm.vmName)' tags must be object in $($inv.FullName)"
    }

    if ($vm.PSObject.Properties.Name -contains 'dataDisks') {
      Assert ($vm.dataDisks -is [System.Array]) "inventory item '$($vm.vmName)' dataDisks must be array in $($inv.FullName)"
    }
  }

  $dupes = $names | Group-Object | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
  Assert ($dupes.Count -eq 0) "Duplicate vmName(s) in $($inv.FullName): $($dupes -join ', ')"
}

Write-Host "Validation complete."
