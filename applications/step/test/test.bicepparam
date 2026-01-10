// ============================================================================
// STEP Application - Test Environment Parameters
// ============================================================================
using '../main.bicep'

// Application Configuration
param applicationName = 'step'
param environment = 'test'
param location = 'eastus'
param regionCode = 'eus'

// VM Configuration
param vmSize = 'Standard_D2s_v3' // Medium size for testing
param osType = 'Linux'
param osDiskType = 'Premium_LRS' // Premium for better performance
param osDiskSizeGB = 128
param imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}
param adminUsername = 'azureadmin'
param adminPasswordOrKey = loadTextContent('./ssh-key.pub')
param authenticationType = 'sshPublicKey'
param vmCount = 2 // Multiple VMs for load testing

// Data disks
param dataDisks = [
  {
    sizeGB: 128
    storageAccountType: 'Premium_LRS'
    caching: 'ReadWrite'
  }
]

// Network Configuration
param vnetAddressPrefix = '10.1.0.0/16'
param subnetAddressPrefix = '10.1.1.0/24'
param enablePublicIP = true // Public access for testing

// NSG Rules - More restrictive than dev
param nsgSecurityRules = [
  {
    name: 'allow-ssh-from-corpnet'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '203.0.113.0/24' // Example corporate network
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
    description: 'Allow SSH from corporate network'
  }
  {
    name: 'allow-http'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 110
    direction: 'Inbound'
    description: 'Allow HTTP access'
  }
  {
    name: 'allow-https'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 120
    direction: 'Inbound'
    description: 'Allow HTTPS access'
  }
]

// Monitoring & Backup
param enableMonitoring = true
param logRetentionDays = 60
param enableBackup = true // Enable backup for test

// Security
param enableKeyVault = true
param networkAclsDefaultAction = 'Deny' // More restrictive

// Tags
param costCenter = 'IT-Test'
param ownerEmail = 'testteam@example.com'
param department = 'Engineering'
param additionalTags = {
  Project: 'STEP'
  Criticality: 'Medium'
}
