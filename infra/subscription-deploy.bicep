targetScope = 'subscription'

@description('Target resource group name')
param resourceGroupName string

@description('Location for the resource group (if created)')
param location string

@description('Tags to apply to the resource group')
param tags object = {}

//
// TODO: implement RG create-if-missing (Bicep will do create-or-update)
//
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

output resourceGroupId string = rg.id
