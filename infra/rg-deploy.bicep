targetScope = 'resourceGroup'

@description('Central Key Vault resource ID (RBAC). Used for metadata and future role assignments; secrets/keys are handled by pipeline.')
param centralKeyVaultResourceId string

@description('Log Analytics Workspace resource ID (existing).')
param logAnalyticsWorkspaceResourceId string

@description('Optional Data Collection Rule resource ID (existing). If provided, AMA will be associated so it sends data.')
param dataCollectionRuleResourceId string = ''

@description('Boot diagnostics storage account resource ID (existing).')
param bootDiagStorageAccountResourceId string

@description('Default subnet resource ID (existing). Can be overridden per VM in inventory.')
param defaultSubnetResourceId string

@description('Default Windows image version resource ID (Shared Image Gallery image version). Can be overridden per VM in inventory.')
param defaultWindowsSourceImageId string

@description('Default Linux image version resource ID (Shared Image Gallery image version). Can be overridden per VM in inventory.')
param defaultLinuxSourceImageId string

@description('Environment/app base tags (owner, responsible, patch schedule, backup tier, etc.).')
param baseTags object = {}

@secure()
@description('Map of VM name -> local admin password. Pipeline retrieves from Key Vault secret <vmName>-local-admin and passes here securely.')
param localAdminPasswords object

@description('Map of VM name -> Key Vault key URL (including version), e.g., https://<vault>.vault.azure.net/keys/key-<vmName>/<version>. Pipeline creates/reads keys and passes here.')
param vmKeyUrls object

@description('Domain join configuration. Only used for Windows VMs where domainJoined is true (default).')
param domainJoin object = {
  enabled: false
  domainName: ''
  ouPath: ''
  username: ''
  password: ''
}

@description('Default VM size if not specified per VM in inventory.')
param defaultVmSize string = 'Standard_D2s_v5'

@description('Default OS disk SKU name.')
param defaultOsDiskSku string = 'Premium_LRS'

@description('Default OS disk caching.')
param defaultOsDiskCaching string = 'ReadWrite'

@description('Default data disks array applied when VM does not specify dataDisks. Empty = none.')
param defaultDataDisks array = []

@description('Inventory of VMs (parsed JSON passed by pipeline).')
param inventory array

module desMod 'modules/compute/des.bicep' = [for vm in inventory: {
  name: 'des-${vm.vmName}'
  params: {
    name: 'des-${vm.vmName}'
    location: resourceGroup().location
    keyVaultResourceId: centralKeyVaultResourceId
    keyVaultKeyUrl: string(vmKeyUrls[vm.vmName])
    tags: union(baseTags, contains(vm, 'tags') ? vm.tags : {})
  }
}]

module nicMod 'modules/compute/nic.bicep' = [for vm in inventory: {
  name: 'nic-${vm.vmName}'
  params: {
    name: 'nic-${vm.vmName}'
    location: resourceGroup().location
    subnetResourceId: contains(vm, 'subnetResourceId') && !empty(vm.subnetResourceId) ? vm.subnetResourceId : defaultSubnetResourceId
    enableAcceleratedNetworking: contains(vm, 'enableAcceleratedNetworking') ? bool(vm.enableAcceleratedNetworking) : false
    privateIpAddress: contains(vm, 'privateIpAddress') ? string(vm.privateIpAddress) : ''
    tags: union(baseTags, contains(vm, 'tags') ? vm.tags : {})
  }
}]

module dataDisksMod 'modules/compute/vm-disks.bicep' = [for (vm, i) in inventory: {
  name: 'disks-${vm.vmName}'
  params: {
    vmName: vm.vmName
    location: resourceGroup().location
    diskEncryptionSetId: desMod[i].outputs.id
    dataDisks: contains(vm, 'dataDisks') ? vm.dataDisks : defaultDataDisks
    tags: union(baseTags, contains(vm, 'tags') ? vm.tags : {})
  }
}]

var isWindows = [for vm in inventory: toLower(string(vm.osType)) == 'windows']

module vm 'modules/compute/vm.bicep' = [for (vmItem, i) in inventory: {
  name: 'vm-${vmItem.vmName}'
  params: {
    vmName: vmItem.vmName
    osType: isWindows[i] ? 'windows' : 'linux'
    location: resourceGroup().location
    vmSize: contains(vmItem, 'vmSize') && !empty(vmItem.vmSize) ? vmItem.vmSize : defaultVmSize
    nicId: nicMod[i].outputs.id
    sourceImageId: contains(vmItem, 'sourceImageId') && !empty(vmItem.sourceImageId)
      ? vmItem.sourceImageId
      : (isWindows[i] ? defaultWindowsSourceImageId : defaultLinuxSourceImageId)
    adminUsername: 'epadmin'
    adminPassword: string(localAdminPasswords[vmItem.vmName])
    bootDiagStorageAccountResourceId: bootDiagStorageAccountResourceId
    diskEncryptionSetId: desMod[i].outputs.id
    osDiskSku: contains(vmItem, 'osDiskSku') ? string(vmItem.osDiskSku) : defaultOsDiskSku
    osDiskCaching: contains(vmItem, 'osDiskCaching') ? string(vmItem.osDiskCaching) : defaultOsDiskCaching
    osDiskSizeGb: contains(vmItem, 'osDiskSizeGb') ? int(vmItem.osDiskSizeGb) : 0
    dataDisks: dataDisksMod[i].outputs.vmDataDisks
    enableSystemAssignedIdentity: contains(vmItem, 'enableSystemAssignedIdentity') ? bool(vmItem.enableSystemAssignedIdentity) : true
    tags: union(baseTags, contains(vmItem, 'tags') ? vmItem.tags : {})
  }
}]

// AMA extension for all VMs
module ama 'modules/extensions/ama.bicep' = [for (vm, i) in inventory: {
  name: 'ama-${vm.vmName}'
  params: {
    vmName: vm.vmName
    osType: isWindows[i] ? 'windows' : 'linux'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    dataCollectionRuleResourceId: dataCollectionRuleResourceId
    createDcrAssociation: !empty(dataCollectionRuleResourceId)
    tags: union(baseTags, contains(vm, 'tags') ? vm.tags : {})
  }
  dependsOn: [
    vm[i]
  ]
}]

// Domain join extension for Windows VMs by default, unless overridden in inventory with domainJoined: false
module domainJoinExt 'modules/extensions/domain-join.bicep' = [for (vm, i) in inventory: if (isWindows[i]) {
  name: 'dj-${vm.vmName}'
  params: {
    vmName: vm.vmName
    enabled: (contains(vm, 'domainJoined') ? bool(vm.domainJoined) : true) && bool(domainJoin.enabled)
    domainName: string(domainJoin.domainName)
    ouPath: string(domainJoin.ouPath)
    username: string(domainJoin.username)
    password: string(domainJoin.password)
  }
  dependsOn: [
    vm[i]
  ]
}]

@description('Outputs a simplified list of VMs deployed from the inventory.')
output deployedVms array = [for (vm, i) in inventory: {
  vmName: vm.vmName
  osType: toLower(string(vm.osType))
  nicName: 'nic-${vm.vmName}'
  desName: 'des-${vm.vmName}'
}]
