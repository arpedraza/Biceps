// ============================================================================
// Recovery Services Vault Module
// ============================================================================
// This module creates a Recovery Services Vault for Azure Backup
// ============================================================================

@description('Name of the Recovery Services Vault')
param vaultName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('SKU name')
@allowed([
  'RS0'
  'Standard'
])
param skuName string = 'RS0'

@description('SKU tier')
@allowed([
  'Standard'
])
param skuTier string = 'Standard'

@description('Tags to apply to resources')
param tags object = {}

// ============================================================================
// Resource: Recovery Services Vault
// ============================================================================
resource recoveryVault 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  name: vaultName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {}
}

// ============================================================================
// Resource: Backup Policy for VMs
// ============================================================================
resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-01-01' = {
  parent: recoveryVault
  name: 'DefaultVMPolicy'
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '2023-01-01T02:00:00Z'
      ]
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '2023-01-01T02:00:00Z'
        ]
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: [
          'Sunday'
        ]
        retentionTimes: [
          '2023-01-01T02:00:00Z'
        ]
        retentionDuration: {
          count: 12
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        retentionScheduleWeekly: {
          daysOfTheWeek: [
            'Sunday'
          ]
          weeksOfTheMonth: [
            'First'
          ]
        }
        retentionTimes: [
          '2023-01-01T02:00:00Z'
        ]
        retentionDuration: {
          count: 12
          durationType: 'Months'
        }
      }
    }
    timeZone: 'UTC'
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Recovery Services Vault')
output vaultId string = recoveryVault.id

@description('Name of the Recovery Services Vault')
output vaultName string = recoveryVault.name

@description('Resource ID of the backup policy')
output backupPolicyId string = backupPolicy.id

@description('Name of the backup policy')
output backupPolicyName string = backupPolicy.name
