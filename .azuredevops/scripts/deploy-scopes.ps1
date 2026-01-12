param(
  [Parameter(Mandatory=$true)][string]$ScopesJson,
  [Parameter(Mandatory=$true)][string]$LocalAdminPasswordsJson,
  [Parameter(Mandatory=$true)][string]$VmKeyUrlsJson
)

$ErrorActionPreference = 'Stop'

$scopes = $ScopesJson | ConvertFrom-Json

if ($null -eq $scopes -or $scopes.Count -eq 0) {
  Write-Host "No scopes to deploy."
  exit 0
}

foreach ($s in $scopes) {
  Write-Host "---"
  Write-Host "Deploying $($s.app)/$($s.env) in subscription $($s.subscriptionId) RG $($s.resourceGroupName)"

  az account set --subscription $s.subscriptionId | Out-Null

  # Ensure RG exists
  az deployment sub create `
    --location $s.location `
    --template-file infra/subscription-deploy.bicep `
    --parameters resourceGroupName=$($s.resourceGroupName) location=$($s.location) `
    --only-show-errors --output none

  # Deploy/update stack
  az stack group create `
    --name $($s.stackName) `
    --resource-group $($s.resourceGroupName) `
    --template-file infra/rg-deploy.bicep `
    --parameters @$($s.envParamFile) inventory=@$($s.inventoryFile) `
    --parameters localAdminPasswords=$LocalAdminPasswordsJson vmKeyUrls=$VmKeyUrlsJson `
    --action-on-unmanage deleteResources `
    --deny-settings-mode none `
    --only-show-errors --output none
}