// ============================================================================
// Naming Convention Module
// ============================================================================
// This module generates consistent resource names based on Azure best practices
// Pattern: {resourceType}-{applicationName}-{environment}-{region}-{instance}
// ============================================================================

@description('Application name')
param applicationName string

@description('Environment')
@allowed([
  'dev'
  'test'
  'uat'
  'prod'
])
param environment string

@description('Azure region short code')
param regionCode string

@description('Instance number')
param instance string = '001'

@description('Additional suffix (optional)')
param suffix string = ''

// ============================================================================
// Variables: Resource Name Patterns
// ============================================================================
var baseNameWithoutInstance = '${applicationName}-${environment}-${regionCode}'
var baseNameWithInstance = '${baseNameWithoutInstance}-${instance}'
var baseNameWithSuffix = empty(suffix) ? baseNameWithInstance : '${baseNameWithInstance}-${suffix}'

// Storage account names (no dashes, lowercase, max 24 chars)
var storageBaseName = toLower(replace('${applicationName}${environment}${regionCode}', '-', ''))

// ============================================================================
// Outputs: Resource Names
// ============================================================================

// Resource Groups
@description('Resource group name')
output resourceGroupName string = 'rg-${baseNameWithoutInstance}'

// Virtual Machines
@description('Virtual machine name')
output vmName string = 'vm-${baseNameWithSuffix}'

// Networking
@description('Virtual network name')
output vnetName string = 'vnet-${baseNameWithoutInstance}'

@description('Subnet name')
output subnetName string = 'snet-${baseNameWithSuffix}'

@description('Network security group name')
output nsgName string = 'nsg-${baseNameWithSuffix}'

@description('Application security group name')
output asgName string = 'asg-${baseNameWithSuffix}'

@description('Network interface name')
output nicName string = 'nic-${baseNameWithSuffix}'

@description('Public IP name')
output pipName string = 'pip-${baseNameWithSuffix}'

// Storage
@description('Storage account name')
output storageAccountName string = take('${storageBaseName}${instance}', 24)

@description('Storage account name for diagnostics')
output diagStorageAccountName string = take('${storageBaseName}diag', 24)

// Monitoring
@description('Log Analytics workspace name')
output logAnalyticsWorkspaceName string = 'log-${baseNameWithoutInstance}'

// Backup
@description('Recovery Services vault name')
output recoveryVaultName string = 'rsv-${baseNameWithoutInstance}'

// Security
@description('Managed identity name')
output managedIdentityName string = 'id-${baseNameWithSuffix}'

@description('Key vault name (max 24 chars)')
output keyVaultName string = take('kv-${toLower(replace(baseNameWithoutInstance, '-', ''))}', 24)
