param(
  [Parameter(Mandatory=$true)][string]$ScopesJson,
  [Parameter(Mandatory=$true)][string]$LocalAdminPasswordsJson,
  [Parameter(Mandatory=$true)][string]$VmKeyUrlsJson
)

$ErrorActionPreference = 'Stop'

$scopes = $ScopesJson | ConvertFrom-Json

if ($null -eq $scopes -or $scopes.Count -eq 0) {
  Write-Host "No scopes to what-if."
  Write-Host "##vso[task.setvariable variable=deletionsDetected]false"
  exit 0
}

$localAdmin = $LocalAdminPasswordsJson | ConvertFrom-Json
$keyUrls = $VmKeyUrlsJson | ConvertFrom-Json

$deletionsDetected = $false

$summary = New-Object System.Collections.Generic.List[string]
$summary.Add('# Azure What-If Summary')
$summary.Add('')
$summary.Add('This summary is produced from Azure what-if and deployment-stack what-if outputs.')
$summary.Add('')

foreach ($s in $scopes) {
  Write-Host "---"
  Write-Host "What-if for $($s.app)/$($s.env) in subscription $($s.subscriptionId) RG $($s.resourceGroupName)"

  az account set --subscription $s.subscriptionId | Out-Null

  # 1) Subscription-scope what-if for RG create/update
  $subWhatIf = az deployment sub what-if `
    --location $s.location `
    --template-file infra/subscription-deploy.bicep `
    --parameters resourceGroupName=$($s.resourceGroupName) location=$($s.location) `
    --only-show-errors --output json

  $summary.Add("## $($s.app) / $($s.env)")
  $summary.Add('')
  $summary.Add("- Subscription: `$($s.subscriptionId)`")
  $summary.Add("- Resource Group: `$($s.resourceGroupName)`")
  $summary.Add("- Stack: `$($s.stackName)`")
  $summary.Add('')

  # 2) Deployment Stack what-if (shows deletes when resources removed from template)
  $stackWhatIf = az stack group create `
    --name $($s.stackName) `
    --resource-group $($s.resourceGroupName) `
    --template-file infra/rg-deploy.bicep `
    --parameters @$($s.envParamFile) inventory=@$($s.inventoryFile) `
    --parameters localAdminPasswords=$LocalAdminPasswordsJson vmKeyUrls=$VmKeyUrlsJson `
    --action-on-unmanage deleteResources `
    --deny-settings-mode none `
    --what-if `
    --only-show-errors --output json

  # Detect deletions in stack what-if output
  if ($stackWhatIf -match '"changeType"\s*:\s*"Delete"' -or $stackWhatIf -match '"Delete"') {
    $deletionsDetected = $true
  }

  # Write a short per-scope summary line
  $summary.Add("### Stack what-if")
  $summary.Add('')
  if ($deletionsDetected) {
    $summary.Add('- ⚠️ Deletions detected (manual approval will be required).')
  } else {
    $summary.Add('- No deletions detected.')
  }
  $summary.Add('')
}

$outFile = Join-Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY 'azure-whatif-summary.md'
New-Item -ItemType Directory -Force -Path $env:BUILD_ARTIFACTSTAGINGDIRECTORY | Out-Null
Set-Content -LiteralPath $outFile -Value ($summary -join "`n") -Encoding utf8

Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Azure What-If;]$outFile"
Write-Host "##vso[task.setvariable variable=deletionsDetected]$($deletionsDetected.ToString().ToLowerInvariant())"