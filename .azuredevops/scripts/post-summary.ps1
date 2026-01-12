param(
  [Parameter(Mandatory=$true)][string]$ScopesJson,
  [Parameter(Mandatory=$true)][string]$RemovedVmsJson,
  [Parameter(Mandatory=$true)][string]$DeletionsDetected
)

$ErrorActionPreference = 'Stop'

$scopes = $ScopesJson | ConvertFrom-Json
$removedMap = $RemovedVmsJson | ConvertFrom-Json

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Deploy Summary')
$lines.Add('')
$lines.Add("Deletions detected: **$DeletionsDetected**")
$lines.Add('')

if ($null -eq $scopes -or $scopes.Count -eq 0) {
  $lines.Add('No scopes were deployed.')
} else {
  foreach ($s in $scopes) {
    $lines.Add("## $($s.app) / $($s.env)")
    $lines.Add('')
    $lines.Add("- Subscription: `$($s.subscriptionId)`")
    $lines.Add("- Resource Group: `$($s.resourceGroupName)`")
    $lines.Add("- Stack: `$($s.stackName)`")
    $lines.Add('')

    $removedNames = @()
    if ($removedMap.PSObject.Properties.Name -contains $s.stackName) {
      $removedNames = @($removedMap.$($s.stackName))
    }
    if ($removedNames.Count -gt 0) {
      $lines.Add('### Removed VMs')
      foreach ($n in ($removedNames | Sort-Object)) { $lines.Add("- ❌ $n") }
      $lines.Add('')
    }
  }
}

$out = Join-Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY 'deploy-summary.md'
New-Item -ItemType Directory -Force -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY | Out-Null
Set-Content -LiteralPath $out -Value ($lines -join "`n") -Encoding utf8
Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Deploy Summary;]$out"
