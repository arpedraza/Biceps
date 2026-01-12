targetScope = 'resourceGroup'

param environmentKey string
param subscriptionKey string
param baseTags object
param domainJoin object

@secure()
param localAdminPasswords object

@secure()
param vmKeyUrls object

param inventory array

var shared = loadJsonContent('../config/shared.json')
var envs = loadJsonContent('../config/environments.json')
var images = loadJsonContent('../config/images.json')

var centralKeyVaultResourceId = shared.centralKeyVaultResourceId
var bootDiagStorageAccountResourceId = envs[environmentKey].bootDiagStorageAccountResourceId

var isWindows = [for vm in inventory: toLower(vm.osType) == 'windows']

module vm 'modules/compute/vm.bicep' = [for (vmItem, i) in inventory: {
  name: 'vm-${vmItem.vmName}'
  params: {
    vmName: vmItem.vmName
    osType: isWindows[i] ? 'windows' : 'linux'
    location: resourceGroup().location
    vmSize: vmItem.vmSize
    adminUsername: 'epadmin'
    adminPassword: localAdminPasswords[vmItem.vmName]
    sourceImageId: isWindows[i] ? images.windows.server2022 : images.linux.rhel9
    bootDiagStorageAccountResourceId: bootDiagStorageAccountResourceId
    tags: union(baseTags, vmItem.tags)
  }
}]
