// ============================================================================
// Application Security Group Module
// ============================================================================
// This module creates an Application Security Group for grouping VMs
// with similar security requirements
// ============================================================================

@description('Name of the Application Security Group')
param asgName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: Application Security Group
// ============================================================================
resource asg 'Microsoft.Network/applicationSecurityGroups@2023-05-01' = {
  name: asgName
  location: location
  tags: tags
  properties: {}
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Application Security Group')
output asgId string = asg.id

@description('Name of the Application Security Group')
output asgName string = asg.name
