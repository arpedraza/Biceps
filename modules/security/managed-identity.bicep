// ============================================================================
// User Assigned Managed Identity Module
// ============================================================================
// This module creates a User Assigned Managed Identity
// ============================================================================

@description('Name of the Managed Identity')
param identityName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: User Assigned Managed Identity
// ============================================================================
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: tags
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Managed Identity')
output identityId string = managedIdentity.id

@description('Name of the Managed Identity')
output identityName string = managedIdentity.name

@description('Principal ID of the Managed Identity')
output principalId string = managedIdentity.properties.principalId

@description('Client ID of the Managed Identity')
output clientId string = managedIdentity.properties.clientId
