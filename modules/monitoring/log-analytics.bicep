// ============================================================================
// Log Analytics Workspace Module
// ============================================================================
// This module creates a Log Analytics Workspace for centralized logging
// and monitoring
// ============================================================================

@description('Name of the Log Analytics Workspace')
param workspaceName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Pricing tier')
@allowed([
  'Free'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerGB2018'

@description('Retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Enable public network access')
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Enable public network access for query')
param publicNetworkAccessForQuery string = 'Enabled'

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: Log Analytics Workspace
// ============================================================================
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Log Analytics Workspace')
output workspaceId string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics Workspace')
output workspaceName string = logAnalyticsWorkspace.name

@description('Workspace ID for agents')
output customerId string = logAnalyticsWorkspace.properties.customerId
