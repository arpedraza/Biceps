// ============================================================================
// STEP Application - Development Environment Parameters
// ============================================================================
using '../main.bicep'

// Application Configuration
param applicationName = 'step'
param environment = 'dev'
param location = 'eastus'
param regionCode = 'eus'

// VM Configuration
param vmSize = 'Standard_B2s' // Small size for development
param osType = 'Linux'
param osDiskType = 'StandardSSD_LRS' // Cost-effective for dev
param osDiskSizeGB = 128
param imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}
param adminUsername = 'azureadmin'
param adminPasswordOrKey = loadTextContent('./ssh-key.pub') // Load SSH public key from file
param authenticationType = 'sshPublicKey'
param vmCount = 1 // Single VM for dev

// Data disks (optional for dev)
param dataDisks = [
  {
    sizeGB: 64
    storageAccountType: 'StandardSSD_LRS'
    caching: 'ReadWrite'
  }
]

// Network Configuration
param vnetAddressPrefix = '10.0.0.0/16'
param subnetAddressPrefix = '10.0.1.0/24'
param enablePublicIP = true // Enable public access for development

// NSG Rules - Open SSH for dev (restrict source IPs in production!)
param nsgSecurityRules = [
  {
    name: 'allow-ssh'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '*' // ⚠️ WARNING: Restrict this to your IP range!
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
    description: 'Allow SSH access'
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
param logRetentionDays = 30
param enableBackup = false // Disable backup for dev to save costs

// Security
param enableKeyVault = true
param networkAclsDefaultAction = 'Allow' // Less restrictive for dev

// Tags
param costCenter = 'IT-Dev'
param ownerEmail = 'devteam@example.com'
param department = 'Engineering'
param additionalTags = {
  Project: 'STEP'
  Criticality: 'Low'
}
