targetScope = 'resourceGroup'

@description('NIC name (recommended: nic-<vmName>).')
param name string

@description('Location for the NIC.')
param location string

@description('Subnet resource ID (existing).')
param subnetResourceId string

@description('Whether to enable accelerated networking (if supported by the size).')
param enableAcceleratedNetworking bool = false

@description('Optional static private IP address. If empty, dynamic allocation is used.')
param privateIpAddress string = ''

@description('Tags to apply.')
param tags object = {}

var ipAllocationMethod = empty(privateIpAddress) ? 'Dynamic' : 'Static'

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enableAcceleratedNetworking: enableAcceleratedNetworking
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: ipAllocationMethod
          privateIPAddress: empty(privateIpAddress) ? null : privateIpAddress
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
  }
}

output id string = nic.id
