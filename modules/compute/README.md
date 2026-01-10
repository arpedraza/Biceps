# Compute Module

This module provides templates for creating Azure Virtual Machines with comprehensive configuration options.

## Modules

### vm.bicep

Creates a complete Virtual Machine deployment including:
- Virtual Machine
- Network Interface
- Optional Public IP Address
- OS and Data Disks
- Boot Diagnostics
- Managed Identity
- Application Security Group association

## Parameters

### Required Parameters

- `vmName`: Name of the Virtual Machine
- `adminUsername`: Administrator username
- `adminPasswordOrKey`: Administrator password or SSH public key
- `subnetId`: Resource ID of the subnet for the VM

### Optional Parameters

- `vmSize`: VM size/SKU (default: Standard_D2s_v3)
- `osType`: Operating system type - Windows or Linux (default: Linux)
- `osDiskType`: OS disk storage type (default: Premium_LRS)
- `osDiskSizeGB`: OS disk size in GB (default: 128)
- `imageReference`: Image reference object for the VM
- `authenticationType`: Authentication method - password or sshPublicKey
- `enablePublicIP`: Enable public IP address (default: false)
- `dataDisks`: Array of data disks to attach
- `enableBootDiagnostics`: Enable boot diagnostics (default: true)
- `enableManagedIdentity`: Enable managed identity (default: true)
- `applicationSecurityGroupIds`: Array of ASG resource IDs
- `enableAcceleratedNetworking`: Enable accelerated networking
- `availabilityZone`: Availability zone for the VM
- `tags`: Resource tags

## Usage Example

```bicep
module vm 'modules/compute/vm.bicep' = {
  name: 'deploy-vm'
  params: {
    vmName: 'myvm-dev-001'
    location: 'eastus'
    vmSize: 'Standard_D2s_v3'
    osType: 'Linux'
    adminUsername: 'azureuser'
    adminPasswordOrKey: 'ssh-rsa AAAA...'
    authenticationType: 'sshPublicKey'
    subnetId: '/subscriptions/.../subnets/default'
    enablePublicIP: true
    dataDisks: [
      {
        sizeGB: 128
        storageAccountType: 'Premium_LRS'
      }
    ]
    tags: {
      Environment: 'dev'
      Application: 'myapp'
    }
  }
}
```

## Outputs

- `vmId`: Resource ID of the Virtual Machine
- `vmName`: Name of the Virtual Machine
- `nicId`: Resource ID of the Network Interface
- `privateIPAddress`: Private IP address
- `publicIPAddress`: Public IP address (if enabled)
- `fqdn`: Fully qualified domain name (if public IP enabled)
- `managedIdentityPrincipalId`: System assigned managed identity principal ID
