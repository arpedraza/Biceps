using '../..//..//infra/rg-deploy.bicep'

// TODO: update values for prod
// Target deployment settings (used by pipelines)
param targetSubscriptionId = 'c71cfef2-700e-47e5-b810-e34898fd2249'
param targetResourceGroupName = 'rg-prod-placeholder'
param targetLocation = 'westeurope'

param centralKeyVaultResourceId = '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-shared-01/providers/Microsoft.KeyVault/vaults/kv-mrg-shared-infra'
param logAnalyticsWorkspaceResourceId = '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-monitoring-prod-01/providers/Microsoft.OperationalInsights/workspaces/law-compute-monitoring-shr'
param bootDiagStorageAccountResourceId = '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-monitoring-prod-01/providers/Microsoft.Storage/storageAccounts/stbootdiagshr'
param defaultSubnetResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-net/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet1'

// Shared Image Gallery (latest version resource IDs). Replace later.
param defaultWindowsSourceImageId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sig/providers/Microsoft.Compute/galleries/gallery/images/win/versions/1.0.0'
param defaultLinuxSourceImageId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sig/providers/Microsoft.Compute/galleries/gallery/images/linux/versions/1.0.0'

param baseTags = {
  Environment: 'prod'
  Owner: 'TBD'
  Responsible: 'TBD'
  AppStack: 'TBD'
  Role: 'TBD'
  Backup: 'TBD'
  PatchSchedule: 'TBD'
}

// Inventory passed by pipeline as array param; pipeline should load inventory.json and pass as --parameters inventory=@file
// This file intentionally does not set 'inventory' param.
