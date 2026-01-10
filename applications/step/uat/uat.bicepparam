// ============================================================================
// STEP Application - UAT Environment Parameters
// ============================================================================
using '../main.bicep'

// Application Configuration
param applicationName = 'step'
param environment = 'uat'
param location = 'eastus'
param regionCode = 'eus'

// VM Configuration
param vmSize = 'Standard_D4s_v3' // Larger size for UAT
param osType = 'Linux'
param osDiskType = 'Premium_LRS'
param osDiskSizeGB = 256
param imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}
param adminUsername = 'azureadmin'
param adminPasswordOrKey = loadTextContent('./ssh-key.pub')
param authenticationType = 'sshPublicKey'
param vmCount = 2 // Multiple VMs for HA

// Data disks
param dataDisks = [
  {
    sizeGB: 256
    storageAccountType: 'Premium_LRS'
    caching: 'ReadWrite'
  }
  {
    sizeGB: 512
    storageAccountType: 'Premium_LRS'
    caching: 'ReadOnly'
  }
]

// Network Configuration
param vnetAddressPrefix = '10.2.0.0/16'
param subnetAddressPrefix = '10.2.1.0/24'
param enablePublicIP = false // No public IPs for UAT (use VPN/ExpressRoute)

// NSG Rules - Restricted to internal networks
param nsgSecurityRules = [
  {
    name: 'allow-ssh-from-corpnet'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '203.0.113.0/24'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
    description: 'Allow SSH from corporate network'
  }
  {
    name: 'allow-app-from-vnet'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRanges: ['80', '443', '8080']
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 110
    direction: 'Inbound'
    description: 'Allow application traffic from VNet'
  }
]

// Monitoring & Backup
param enableMonitoring = true
param logRetentionDays = 90
param enableBackup = true

// Security
param enableKeyVault = true
param networkAclsDefaultAction = 'Deny'

// Tags
param costCenter = 'IT-UAT'
param ownerEmail = 'uatteam@example.com'
param department = 'Engineering'
param additionalTags = {
  Project: 'STEP'
  Criticality: 'High'
  ComplianceScope: 'Internal'
}
