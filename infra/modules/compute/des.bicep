targetScope = 'resourceGroup'

@description('Disk Encryption Set name (recommended: des-<vmName>).')
param name string

@description('Location for the Disk Encryption Set.')
param location string

@description('Resource ID of the Key Vault that contains the key.')
param keyVaultResourceId string

@description('Full Key Vault key URL including version (for example: https://<vault>.vault.azure.net/keys/<keyName>/<keyVersion>).')
param keyVaultKeyUrl string

@description('Tags to apply.')
param tags object = {}

resource des 'Microsoft.Compute/diskEncryptionSets@2023-07-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVaultResourceId
      }
      keyUrl: keyVaultKeyUrl
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}

@description('Disk Encryption Set resource ID.')
output id string = des.id

@description('Disk Encryption Set principalId (system-assigned identity). Use this to grant Key Vault Crypto User permissions.')
output principalId string = des.identity.principalId
