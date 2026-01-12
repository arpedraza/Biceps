using '../../../infra/rg-deploy.bicep'

param targetSubscriptionId = 'c2ae3152-6777-45b2-8c04-f4492ad08be4'
param targetResourceGroupName = 'rg-ep-step-stone-01'
param targetLocation = 'westeurope'

param centralKeyVaultResourceId = '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-shared-01/providers/Microsoft.KeyVault/vaults/kv-mrg-shared-infra'
param logAnalyticsWorkspaceResourceId = '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-monitoring-prod-01/providers/Microsoft.OperationalInsights/workspaces/law-compute-monitoring-shr'
param bootDiagStorageAccountResourceId = '/subscriptions/c2ae3152-6777-45b2-8c04-f4492ad08be4/resourceGroups/rg-ep-monitoring-test-01/providers/Microsoft.Storage/storageAccounts/stbootdiagtst'
param defaultSubnetResourceId = '/subscriptions/c2ae3152-6777-45b2-8c04-f4492ad08be4/resourceGroups/rg-ep-network-test-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-epb-test-westeu-01/subnets/snet-ep-epb-applications-test-westeu-01'

// Shared Image Gallery (latest version resource IDs). Replace later.
param defaultWindowsSourceImageId = '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-shared-01/providers/Microsoft.Compute/galleries/gal.mrg.shared.infra/images/W2k25-DC-AZ-Gen2'
param defaultLinuxSourceImageId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sig/providers/Microsoft.Compute/galleries/gallery/images/linux/versions/1.0.0'

param baseTags = {
  Environment: 'test'
  Owner: 'Andy Group IT'
  Responsible: 'Andy Infrastructure Team'
  AppStack: 'Stone'
  Role: ''
  Backup: 'DailyKeepDay'
  PatchSchedule: 'TestUnattended01'
}

// Inventory passed by pipeline as array param; pipeline should load inventory.json and pass as --parameters inventory=@file
// This file intentionally does not set 'inventory' param.
