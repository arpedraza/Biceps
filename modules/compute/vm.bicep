// ============================================================================
// Virtual Machine Module
// ============================================================================
// This module creates a complete Virtual Machine with:
// - Network Interface
// - Optional Public IP
// - OS Disk configuration
// - Data Disks
// - Boot diagnostics
// - Managed Identity
// ============================================================================

@description('Name of the Virtual Machine')
param vmName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Virtual Machine size/SKU')
param vmSize string = 'Standard_D2s_v3'

@description('Operating System type')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Linux'

@description('OS disk type')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param osDiskType string = 'Premium_LRS'

@description('OS disk size in GB')
param osDiskSizeGB int = 128

@description('Image reference for the VM')
param imageReference object = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

@description('Admin username')
param adminUsername string

@description('Admin password or SSH key')
@secure()
param adminPasswordOrKey string

@description('Authentication type (password or sshPublicKey)')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Subnet ID for the VM')
param subnetId string

@description('Enable public IP address')
param enablePublicIP bool = false

@description('Public IP allocation method')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('Public IP SKU')
@allowed([
  'Basic'
  'Standard'
])
param publicIPSku string = 'Standard'

@description('Array of data disks to attach')
param dataDisks array = []

@description('Enable boot diagnostics')
param enableBootDiagnostics bool = true

@description('Storage account URI for boot diagnostics')
param bootDiagnosticsStorageUri string = ''

@description('Enable managed identity')
param enableManagedIdentity bool = true

@description('Type of managed identity')
@allowed([
  'SystemAssigned'
  'UserAssigned'
  'SystemAssigned,UserAssigned'
])
param managedIdentityType string = 'SystemAssigned'

@description('User assigned identity resource IDs')
param userAssignedIdentities object = {}

@description('Application Security Group IDs')
param applicationSecurityGroupIds array = []

@description('Enable accelerated networking')
param enableAcceleratedNetworking bool = false

@description('Private IP allocation method')
@allowed([
  'Dynamic'
  'Static'
])
param privateIPAllocationMethod string = 'Dynamic'

@description('Static private IP address (if allocation method is Static)')
param staticPrivateIPAddress string = ''

@description('Availability Zone')
param availabilityZone string = ''

@description('Tags to apply to resources')
param tags object = {}

@description('Custom data script (base64 encoded)')
param customData string = ''

// ============================================================================
// Resource: Public IP Address (conditional)
// ============================================================================
resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = if (enablePublicIP) {
  name: '${vmName}-pip'
  location: location
  tags: tags
  sku: {
    name: publicIPSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: toLower('${vmName}-${uniqueString(resourceGroup().id)}')
    }
  }
  zones: !empty(availabilityZone) ? [availabilityZone] : []
}

// ============================================================================
// Resource: Network Interface
// ============================================================================
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: privateIPAllocationMethod
          privateIPAddress: privateIPAllocationMethod == 'Static' ? staticPrivateIPAddress : null
          publicIPAddress: enablePublicIP ? {
            id: publicIP.id
          } : null
          applicationSecurityGroups: [for asgId in applicationSecurityGroupIds: {
            id: asgId
          }]
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
}

// ============================================================================
// Resource: Virtual Machine
// ============================================================================
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  tags: tags
  identity: enableManagedIdentity ? {
    type: managedIdentityType
    userAssignedIdentities: managedIdentityType != 'SystemAssigned' ? userAssignedIdentities : null
  } : null
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: authenticationType == 'password' ? adminPasswordOrKey : null
      customData: !empty(customData) ? customData : null
      linuxConfiguration: osType == 'Linux' ? {
        disablePasswordAuthentication: authenticationType == 'sshPublicKey'
        ssh: authenticationType == 'sshPublicKey' ? {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPasswordOrKey
            }
          ]
        } : null
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      } : null
      windowsConfiguration: osType == 'Windows' ? {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      } : null
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        diskSizeGB: osDiskSizeGB
      }
      dataDisks: [for (disk, i) in dataDisks: {
        lun: i
        name: '${vmName}-datadisk-${i}'
        createOption: 'Empty'
        diskSizeGB: disk.sizeGB
        managedDisk: {
          storageAccountType: disk.storageAccountType
        }
        caching: contains(disk, 'caching') ? disk.caching : 'ReadWrite'
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: enableBootDiagnostics
        storageUri: enableBootDiagnostics && !empty(bootDiagnosticsStorageUri) ? bootDiagnosticsStorageUri : null
      }
    }
  }
  zones: !empty(availabilityZone) ? [availabilityZone] : []
}

// ============================================================================
// Outputs
// ============================================================================
@description('Resource ID of the Virtual Machine')
output vmId string = vm.id

@description('Name of the Virtual Machine')
output vmName string = vm.name

@description('Resource ID of the Network Interface')
output nicId string = nic.id

@description('Private IP address of the VM')
output privateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress

@description('Public IP address of the VM (if enabled)')
output publicIPAddress string = enablePublicIP ? publicIP.properties.ipAddress : ''

@description('FQDN of the VM (if public IP enabled)')
output fqdn string = enablePublicIP ? publicIP.properties.dnsSettings.fqdn : ''

@description('System assigned managed identity principal ID')
output managedIdentityPrincipalId string = enableManagedIdentity && (managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned,UserAssigned') ? vm.identity.principalId : ''
