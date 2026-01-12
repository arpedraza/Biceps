targetScope = 'resourceGroup'

@description('Virtual machine name.')
param vmName string

@description('Location for the VM.')
param location string

@description('VM size/SKU, e.g. Standard_D4s_v5.')
param vmSize string

@description('NIC resource ID to attach as primary.')
param nicId string

@description('Source image resource ID (e.g., Shared Image Gallery image version resource ID).')
param sourceImageId string

@description('Local admin username (fixed across org, e.g., epadmin).')
param adminUsername string = 'epadmin'

@secure()
@description('Local admin password (retrieved from Key Vault by pipeline).')
param adminPassword string

@description('Boot diagnostics storage account resource ID (existing).')
param bootDiagStorageAccountResourceId string

@description('Disk Encryption Set resource ID for OS disk CMK encryption.')
param diskEncryptionSetId string

@description('OS disk storage SKU name, e.g., Premium_LRS, StandardSSD_LRS.')
param osDiskSku string = 'Premium_LRS'

@description('OS disk caching mode: ReadOnly or ReadWrite.')
param osDiskCaching string = 'ReadWrite'

@description('OS disk size in GB. If 0, uses image default.')
param osDiskSizeGb int = 0

@description('Data disk attachment objects for storageProfile.dataDisks (from vm-disks module).')
param dataDisks array = []

@description('Whether to enable System Assigned Managed Identity.')
param enableSystemAssignedIdentity bool = true

@description('Tags to apply.')
param tags object = {}

var storageAccountName = last(split(bootDiagStorageAccountResourceId, '/'))
resource bootDiagSa 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  identity: enableSystemAssignedIdentity ? {
    type: 'SystemAssigned'
  } : null
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        id: sourceImageId
      }
      osDisk: {
        name: 'disk-${vmName}-os'
        caching: osDiskCaching
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskSku
          diskEncryptionSet: {
            id: diskEncryptionSetId
          }
        }
        diskSizeGB: osDiskSizeGb == 0 ? null : osDiskSizeGb
      }
      dataDisks: dataDisks
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicId
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: bootDiagSa.properties.primaryEndpoints.blob
      }
    }
  }
}

output id string = vm.id
output name string = vm.name
output principalId string = enableSystemAssignedIdentity ? vm.identity.principalId : ''
