// ============================================================================
// STEP Application - Production Environment Parameters
// ============================================================================
using '../main.bicep'

// Application Configuration
param applicationName = 'step'
param environment = 'prod'
param location = 'eastus'
param regionCode = 'eus'

// VM Configuration
param vmSize = 'Standard_D8s_v3' // Production-grade size
param osType = 'Linux'
param osDiskType = 'Premium_LRS'
param osDiskSizeGB = 512
param imageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}
param adminUsername = 'azureadmin'
param adminPasswordOrKey = loadTextContent('./ssh-key.pub')
param authenticationType = 'sshPublicKey'
param vmCount = 3 // Multiple VMs for high availability

// Data disks - Production storage
param dataDisks = [
  {
    sizeGB: 512
    storageAccountType: 'Premium_LRS'
    caching: 'ReadWrite'
  }
  {
    sizeGB: 1024
    storageAccountType: 'Premium_LRS'
    caching: 'ReadOnly'
  }
]

// Network Configuration
param vnetAddressPrefix = '10.3.0.0/16'
param subnetAddressPrefix = '10.3.1.0/24'
param enablePublicIP = false // No public IPs in production

// NSG Rules - Highly restricted
param nsgSecurityRules = [
  {
    name: 'allow-ssh-from-jumpbox'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '10.3.0.0/28' // Only from jump box subnet
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
    description: 'Allow SSH from jump box only'
  }
  {
    name: 'allow-app-from-lb'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRanges: ['80', '443']
    sourceAddressPrefix: 'AzureLoadBalancer'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 110
    direction: 'Inbound'
    description: 'Allow traffic from Azure Load Balancer'
  }
  {
    name: 'allow-app-internal'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 120
    direction: 'Inbound'
    description: 'Allow internal application traffic'
  }
  {
    name: 'deny-all-inbound'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Deny'
    priority: 4096
    direction: 'Inbound'
    description: 'Deny all other inbound traffic'
  }
]

// Monitoring & Backup - Production settings
param enableMonitoring = true
param logRetentionDays = 180 // 6 months retention
param enableBackup = true

// Security - Maximum protection
param enableKeyVault = true
param networkAclsDefaultAction = 'Deny'

// Tags - Production governance
param costCenter = 'IT-Prod'
param ownerEmail = 'prodops@example.com'
param department = 'Operations'
param additionalTags = {
  Project: 'STEP'
  Criticality: 'Critical'
  ComplianceScope: 'SOC2,HIPAA'
  DataClassification: 'Confidential'
  DisasterRecovery: 'Tier1'
}
