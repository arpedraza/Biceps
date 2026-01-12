param(
  [string]$App = "stone",
  [string]$Env = "test",
  [string]$ResourceGroup = "rg-ep-step-stone-01",
  [string]$KeyVaultName = "kv-mrg-shared-infra"
)

$inventoryPath = ".\apps\$App\$Env\inventory.json"
$inventory = Get-Content $inventoryPath | ConvertFrom-Json

$localAdminPasswords = @{}
$vmKeyUrls = @{}

foreach ($vm in $inventory) {
    $vmName = $vm.vmName
    $pwd = [System.Web.Security.Membership]::GeneratePassword(32,6)
    $localAdminPasswords[$vmName] = $pwd

    $keyUrl = az keyvault key show `
      --vault-name $KeyVaultName `
      --name "key-$vmName" `
      --query "key.kid" -o tsv

    $vmKeyUrls[$vmName] = $keyUrl
}

$domainJoin = @{
  enabled = $true
  domainName = "corp.euroports.local"
  ouPath = "OU=Servers,DC=corp,DC=euroports,DC=local"
  username = az keyvault secret show --vault-name $KeyVaultName --name "svc-domainjoin-usr" --query value -o tsv
  password = az keyvault secret show --vault-name $KeyVaultName --name "svc-domainjoin-pwd" --query value -o tsv
}

az deployment group create `
  --resource-group $ResourceGroup `
  --template-file .\infra\rg-deploy.bicep `
  --parameters .\apps\$App\$Env\env.bicepparam `
  --parameters inventory=$inventory `
  --parameters localAdminPasswords=$localAdminPasswords `
  --parameters vmKeyUrls=$vmKeyUrls `
  --parameters domainJoin=$domainJoin
