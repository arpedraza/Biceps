param(
  [Parameter(Mandatory=$true)][string]$ScopesJson,
  [Parameter(Mandatory=$true)][string]$RemovedVmsJson
)

$ErrorActionPreference = 'Stop'

$scopes = $ScopesJson | ConvertFrom-Json
$removedMap = $RemovedVmsJson | ConvertFrom-Json

if ($null -eq $scopes -or $scopes.Count -eq 0) {
  $md = "# Inventory Plan\n\nNo app/environment changes detected."
  $out = Join-Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY 'inventory-plan.md'
  New-Item -ItemType Directory -Force -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY | Out-Null
  Set-Content -LiteralPath $out -Value $md -Encoding utf8
  Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Inventory Plan;]$out"
  exit 0
}

function Get-Inventory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return @() }
  $raw = Get-Content -LiteralPath $Path -Raw
  if ([string]::IsNullOrWhiteSpace($raw)) { return @() }
  $obj = $raw | ConvertFrom-Json
  if ($obj -is [System.Array]) { return $obj }
  return @($obj)
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Inventory Plan')
$lines.Add('')
$lines.Add('This plan is derived from inventory.json differences (not an Azure what-if).')
$lines.Add('')

foreach ($s in $scopes) {
  $stack = $s.stackName
  $inv = Get-Inventory -Path $s.inventoryFile
  $currentNames = @($inv | ForEach-Object { $_.vmName } | Where-Object { $_ })
  $removedNames = @()
  if ($removedMap.PSObject.Properties.Name -contains $stack) {
    $removedNames = @($removedMap.$stack)
  }

  $lines.Add("## $($s.app) / $($s.env)")
  $lines.Add('')
  $lines.Add("- Subscription: `$($s.subscriptionId)`")
  $lines.Add("- Resource Group: `$($s.resourceGroupName)`")
  $lines.Add("- Stack: `$stack`")
  $lines.Add('')
  $lines.Add("### Current inventory VMs ($($currentNames.Count))")
  if ($currentNames.Count -eq 0) {
    $lines.Add('- (none)')
  } else {
    foreach ($n in ($currentNames | Sort-Object)) { $lines.Add("- $n") }
  }
  $lines.Add('')

  $lines.Add("### Removed since base ($($removedNames.Count))")
  if ($removedNames.Count -eq 0) {
    $lines.Add('- (none)')
  } else {
    foreach ($n in ($removedNames | Sort-Object)) { $lines.Add("- ❌ $n") }
  }
  $lines.Add('')
}

$outFile = Join-Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY 'inventory-plan.md'
New-Item -ItemType Directory -Force -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY | Out-Null
Set-Content -LiteralPath $outFile -Value ($lines -join "`n") -Encoding utf8

Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Inventory Plan;]$outFile"