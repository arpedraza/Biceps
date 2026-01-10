// ============================================================================
// VM Diagnostics Extension Module
// ============================================================================
// This module configures diagnostic settings for a Virtual Machine
// ============================================================================

@description('Name of the Virtual Machine')
param vmName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Log Analytics Workspace ID')
param workspaceId string

@description('OS Type')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Linux'

// ============================================================================
// Resource: VM Extension - Azure Monitor Agent
// ============================================================================
resource azureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: '${vmName}/AzureMonitorAgent'
  location: location
  properties: {
    publisher: osType == 'Linux' ? 'Microsoft.Azure.Monitor' : 'Microsoft.Azure.Monitor'
    type: osType == 'Linux' ? 'AzureMonitorLinuxAgent' : 'AzureMonitorWindowsAgent'
    typeHandlerVersion: osType == 'Linux' ? '1.0' : '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      workspaceId: workspaceId
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the extension')
output extensionId string = azureMonitorAgent.id
