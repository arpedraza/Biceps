// ============================================================================
// Main Orchestration Template - STEP Application
// ============================================================================
// This template orchestrates the deployment of all resources for the
// STEP application including networking, VMs, monitoring, backup, and security
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// Parameters - Application Configuration
// ============================================================================
@description('Application name')
param applicationName string = 'step'

@description('Environment')
@allowed([
  'dev'
  'test'
  'uat'
  'prod'
])
param environment string

@description('Azure region for resources')
param location string = 'eastus'

@description('Region short code for naming')
param regionCode string = 'eus'

@description('Subscription ID for deployment')
param subscriptionId string = subscription().subscriptionId

// ============================================================================
// Parameters - VM Configuration
// ============================================================================
@description('Virtual machine size')
param vmSize string

@description('Operating system type')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Linux'

@description('OS disk type')
param osDiskType string

@description('OS disk size in GB')
param osDiskSizeGB int = 128

@description('Image reference')
param imageReference object

@description('Admin username')
param adminUsername string

@description('Admin password or SSH key')
@secure()
param adminPasswordOrKey string

@description('Authentication type')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'sshPublicKey'

@description('Number of VMs to deploy')
@minValue(1)
@maxValue(10)
param vmCount int = 1

@description('Data disks configuration')
param dataDisks array = []

// ============================================================================
// Parameters - Network Configuration
// ============================================================================
@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet address prefix')
param subnetAddressPrefix string = '10.0.1.0/24'

@description('Enable public IP for VMs')
param enablePublicIP bool = false

@description('NSG security rules')
param nsgSecurityRules array = []

// ============================================================================
// Parameters - Monitoring & Backup
// ============================================================================
@description('Enable monitoring')
param enableMonitoring bool = true

@description('Log retention in days')
param logRetentionDays int = 30

@description('Enable backup')
param enableBackup bool = true

// ============================================================================
// Parameters - Security
// ============================================================================
@description('Enable Key Vault')
param enableKeyVault bool = true

@description('Network ACLs default action')
param networkAclsDefaultAction string = 'Deny'

// ============================================================================
// Parameters - Tags
// ============================================================================
@description('Cost center')
param costCenter string = ''

@description('Owner email')
param ownerEmail string = ''

@description('Department')
param department string = ''

@description('Additional tags')
param additionalTags object = {}

// ============================================================================
// Module: Naming Convention
// ============================================================================
module naming '../../config/naming/naming-convention.bicep' = {
  name: 'naming-${applicationName}-${environment}'
  scope: subscription(subscriptionId)
  params: {
    applicationName: applicationName
    environment: environment
    regionCode: regionCode
    instance: '001'
  }
}

// ============================================================================
// Module: Tags
// ============================================================================
module tags '../../config/tags/tags.bicep' = {
  name: 'tags-${applicationName}-${environment}'
  scope: subscription(subscriptionId)
  params: {
    applicationName: applicationName
    environment: environment
    costCenter: costCenter
    ownerEmail: ownerEmail
    department: department
    customTags: additionalTags
  }
}

// ============================================================================
// Resource Group
// ============================================================================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: naming.outputs.resourceGroupName
  location: location
  tags: tags.outputs.standardTags
}

// ============================================================================
// Module: Network Security Group
// ============================================================================
module nsg '../../modules/network/nsg.bicep' = {
  name: 'deploy-nsg-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    nsgName: naming.outputs.nsgName
    location: location
    securityRules: nsgSecurityRules
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Application Security Group
// ============================================================================
module asg '../../modules/network/asg.bicep' = {
  name: 'deploy-asg-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    asgName: naming.outputs.asgName
    location: location
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Virtual Network
// ============================================================================
module vnet '../../modules/network/vnet.bicep' = {
  name: 'deploy-vnet-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    vnetName: naming.outputs.vnetName
    location: location
    addressPrefix: vnetAddressPrefix
    subnets: [
      {
        name: naming.outputs.subnetName
        addressPrefix: subnetAddressPrefix
        nsgId: nsg.outputs.nsgId
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.KeyVault'
          }
        ]
      }
    ]
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Storage Account (for boot diagnostics)
// ============================================================================
module storage '../../modules/storage/storage-account.bicep' = {
  name: 'deploy-storage-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    storageAccountName: naming.outputs.diagStorageAccountName
    location: location
    skuName: 'Standard_LRS'
    networkAclsDefaultAction: networkAclsDefaultAction
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Log Analytics Workspace (conditional)
// ============================================================================
module logAnalytics '../../modules/monitoring/log-analytics.bicep' = if (enableMonitoring) {
  name: 'deploy-log-analytics-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    workspaceName: naming.outputs.logAnalyticsWorkspaceName
    location: location
    retentionInDays: logRetentionDays
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Recovery Services Vault (conditional)
// ============================================================================
module recoveryVault '../../modules/backup/recovery-vault.bicep' = if (enableBackup) {
  name: 'deploy-recovery-vault-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    vaultName: naming.outputs.recoveryVaultName
    location: location
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Key Vault (conditional)
// ============================================================================
module keyVault '../../modules/keyvault/key-vault.bicep' = if (enableKeyVault) {
  name: 'deploy-keyvault-${applicationName}-${environment}'
  scope: resourceGroup
  params: {
    keyVaultName: naming.outputs.keyVaultName
    location: location
    networkAclsDefaultAction: networkAclsDefaultAction
    tags: tags.outputs.standardTags
  }
}

// ============================================================================
// Module: Virtual Machines
// ============================================================================
module vms '../../modules/compute/vm.bicep' = [for i in range(0, vmCount): {
  name: 'deploy-vm-${applicationName}-${environment}-${padLeft(i + 1, 3, '0')}'
  scope: resourceGroup
  params: {
    vmName: '${naming.outputs.vmName}-${padLeft(i + 1, 3, '0')}'
    location: location
    vmSize: vmSize
    osType: osType
    osDiskType: osDiskType
    osDiskSizeGB: osDiskSizeGB
    imageReference: imageReference
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    authenticationType: authenticationType
    subnetId: vnet.outputs.subnetIds[0]
    enablePublicIP: enablePublicIP
    dataDisks: dataDisks
    enableBootDiagnostics: true
    bootDiagnosticsStorageUri: storage.outputs.primaryBlobEndpoint
    enableManagedIdentity: true
    applicationSecurityGroupIds: [asg.outputs.asgId]
    tags: tags.outputs.standardTags
  }
}]

// ============================================================================
// Module: VM Diagnostics (conditional)
// ============================================================================
module vmDiagnostics '../../modules/monitoring/vm-diagnostics.bicep' = [for i in range(0, vmCount): if (enableMonitoring) {
  name: 'deploy-vm-diagnostics-${applicationName}-${environment}-${padLeft(i + 1, 3, '0')}'
  scope: resourceGroup
  params: {
    vmName: vms[i].outputs.vmName
    location: location
    workspaceId: enableMonitoring ? logAnalytics.outputs.workspaceId : ''
    osType: osType
  }
  dependsOn: [
    vms
  ]
}]

// ============================================================================
// Outputs
// ============================================================================
@description('Resource group name')
output resourceGroupName string = resourceGroup.name

@description('Virtual network ID')
output vnetId string = vnet.outputs.vnetId

@description('Subnet IDs')
output subnetIds array = vnet.outputs.subnetIds

@description('VM names')
output vmNames array = [for i in range(0, vmCount): vms[i].outputs.vmName]

@description('VM private IP addresses')
output vmPrivateIPs array = [for i in range(0, vmCount): vms[i].outputs.privateIPAddress]

@description('VM public IP addresses (if enabled)')
output vmPublicIPs array = enablePublicIP ? [for i in range(0, vmCount): vms[i].outputs.publicIPAddress] : []

@description('Storage account name')
output storageAccountName string = storage.outputs.storageAccountName

@description('Log Analytics workspace ID')
output logAnalyticsWorkspaceId string = enableMonitoring ? logAnalytics.outputs.workspaceId : ''

@description('Recovery vault name')
output recoveryVaultName string = enableBackup ? recoveryVault.outputs.vaultName : ''

@description('Key Vault name')
output keyVaultName string = enableKeyVault ? keyVault.outputs.keyVaultName : ''
