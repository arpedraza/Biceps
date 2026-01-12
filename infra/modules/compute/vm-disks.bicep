targetScope = 'resourceGroup'

@description('VM name used as prefix for disk resources.')
param vmName string

@description('Location for disks.')
param location string

@description('Disk Encryption Set resource ID to use for encryption-at-rest with CMK.')
param diskEncryptionSetId string

@description('Array of data disk definitions.')
param dataDisks array = []

@description('Tags to apply.')
param tags object = {}

/*
Expected dataDisks schema (per element):
{
  "lun": 0,
  "sizeGb": 128,
  "sku": "Premium_LRS" | "StandardSSD_LRS" | "Standard_LRS",
  "caching": "None" | "ReadOnly" | "ReadWrite"
}
*/

resource disks 'Microsoft.Compute/disks@2023-07-01' = [for d in dataDisks: {
  name: 'disk-${vmName}-data-${string(d.lun)}'
  location: location
  tags: tags
  sku: {
    name: string(d.sku)
  }
  properties: {
    diskSizeGB: int(d.sizeGb)
    creationData: {
      createOption: 'Empty'
    }
    encryption: {
      type: 'EncryptionAtRestWithCustomerKey'
      diskEncryptionSetId: diskEncryptionSetId
    }
  }
}]

@description('Data disk attachment objects for VM.storageProfile.dataDisks')
output vmDataDisks array = [for (d, i) in dataDisks: {
  lun: int(d.lun)
  name: disks[i].name
  createOption: 'Attach'
  caching: contains(d, 'caching') ? string(d.caching) : 'ReadWrite'
  managedDisk: {
    id: disks[i].id
  }
}]
