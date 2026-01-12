targetScope = 'subscription'

@description('Name of the resource group to create or update.')
param resourceGroupName string

@description('Azure location for the resource group.')
param location string

@description('Tags to apply to the resource group.')
param tags object = {}

// Creating a resource group at subscription scope is an idempotent create-or-update operation.
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

output resourceGroupId string = rg.id
