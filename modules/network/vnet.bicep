// ============================================================================
// Virtual Network Module
// ============================================================================
// This module creates a Virtual Network with configurable subnets and NSGs
// Supports service endpoints, delegation, and network security
// ============================================================================

@description('Name of the Virtual Network')
param vnetName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Address space for the VNet')
param addressPrefix string = '10.0.0.0/16'

@description('Array of subnets to create')
param subnets array = []

@description('Tags to apply to resources')
param tags object = {}

@description('Enable DDoS protection')
param enableDdosProtection bool = false

@description('Enable VM protection')
param enableVmProtection bool = false

@description('DNS servers for the VNet')
param dnsServers array = []

// ============================================================================
// Resource: Virtual Network
// ============================================================================
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    dhcpOptions: empty(dnsServers) ? null : {
      dnsServers: dnsServers
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: contains(subnet, 'nsgId') ? {
          id: subnet.nsgId
        } : null
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : 'Disabled'
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : 'Enabled'
      }
    }]
    enableDdosProtection: enableDdosProtection
    enableVmProtection: enableVmProtection
  }
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Virtual Network')
output vnetId string = vnet.id

@description('Name of the Virtual Network')
output vnetName string = vnet.name

@description('Array of subnet IDs')
output subnetIds array = [for (subnet, i) in subnets: vnet.properties.subnets[i].id]

@description('Map of subnet names to IDs')
output subnetMap object = {
  subnets: [for (subnet, i) in subnets: {
    name: subnet.name
    id: vnet.properties.subnets[i].id
  }]
}
