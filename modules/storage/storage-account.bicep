// ============================================================================
// Storage Account Module
// ============================================================================
// This module creates a Storage Account for boot diagnostics,
// file shares, or general storage needs
// ============================================================================

@description('Name of the Storage Account')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Storage Account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Storage Account kind')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@description('Access tier for the storage account')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Enable HTTPS traffic only')
param supportsHttpsTrafficOnly bool = true

@description('Minimum TLS version')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Allow blob public access')
param allowBlobPublicAccess bool = false

@description('Enable hierarchical namespace (Data Lake Gen2)')
param isHnsEnabled bool = false

@description('Network ACL default action')
@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Deny'

@description('Virtual network rules')
param virtualNetworkRules array = []

@description('IP rules')
param ipRules array = []

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: Storage Account
// ============================================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    isHnsEnabled: isHnsEnabled
    networkAcls: {
      defaultAction: networkAclsDefaultAction
      virtualNetworkRules: virtualNetworkRules
      ipRules: ipRules
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Storage Account')
output storageAccountId string = storageAccount.id

@description('Name of the Storage Account')
output storageAccountName string = storageAccount.name

@description('Primary endpoints')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('Primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
