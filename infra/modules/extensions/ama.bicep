targetScope = 'resourceGroup'

@description('Virtual machine name (existing).')
param vmName string

@description('OS type: windows or linux')
@allowed([
  'windows'
  'linux'
])
param osType string

@description('Log Analytics Workspace resource ID (existing). Used for DCR association naming/metadata; AMA itself is installed regardless.')
param logAnalyticsWorkspaceResourceId string

@description('Optional Data Collection Rule resource ID. If provided, a DCR association is created so AMA sends data.')
param dataCollectionRuleResourceId string = ''

@description('Whether to create the DCR association (requires dataCollectionRuleResourceId).')
param createDcrAssociation bool = true

@description('Tags to apply to association resources (extensions do not support tags).')
param tags object = {}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' existing = {
  name: vmName
}

var isWindows = osType == 'windows'
var extName = isWindows ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
var extType = isWindows ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
var extPublisher = 'Microsoft.Azure.Monitor'

resource ama 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  parent: vm
  name: 'AzureMonitorWindowsAgent' // or your extension name
  properties: {
    publisher: extPublisher
    type: extType
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
  }
}

// AMA routes data using DCR + association. The LAW is typically referenced by the DCR itself.
resource dcrAssoc 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = if (!empty(dataCollectionRuleResourceId) && createDcrAssociation) {
  name: '${vm.name}/dcr-assoc'
  properties: {
    description: 'AMA DCR association for ${vm.name}'
    dataCollectionRuleId: dataCollectionRuleResourceId
  }
  tags: tags
}

output extensionName string = ama.name
output dcrAssociationName string = (!empty(dataCollectionRuleResourceId) && createDcrAssociation) ? dcrAssoc.name : ''
