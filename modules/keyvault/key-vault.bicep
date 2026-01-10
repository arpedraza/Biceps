// ============================================================================
// Key Vault Module
// ============================================================================
// This module creates an Azure Key Vault for storing secrets,
// keys, and certificates
// ============================================================================

@description('Name of the Key Vault')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('SKU name')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Azure AD tenant ID')
param tenantId string = tenant().tenantId

@description('Enable RBAC authorization')
param enableRbacAuthorization bool = true

@description('Enable soft delete')
param enableSoftDelete bool = true

@description('Soft delete retention in days')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Enable purge protection')
param enablePurgeProtection bool = true

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

@description('Enable public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Access policies (only if RBAC is disabled)')
param accessPolicies array = []

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: Key Vault
// ============================================================================
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? true : null
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: networkAclsDefaultAction
      bypass: 'AzureServices'
      virtualNetworkRules: virtualNetworkRules
      ipRules: ipRules
    }
    accessPolicies: !enableRbacAuthorization ? accessPolicies : []
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Key Vault')
output keyVaultId string = keyVault.id

@description('Name of the Key Vault')
output keyVaultName string = keyVault.name

@description('URI of the Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri
