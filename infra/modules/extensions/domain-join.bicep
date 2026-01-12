targetScope = 'resourceGroup'

@description('Virtual machine name (existing).')
param vmName string

@description('Whether to join the domain. If false, this module deploys nothing.')
param enabled bool = true

@description('AD domain name, e.g., corp.example.com')
param domainName string

@description('Optional OU path for the computer account, e.g., OU=Servers,OU=...')
param ouPath string = ''

@description('Domain join user, in UPN or DOMAIN\\user format.')
param username string

@secure()
@description('Domain join password.')
param password string

@description('Restart after join.')
param restart bool = true

@description('Join options (bitmask). 3 = join with reset account and set default password; adjust as needed.')
param options int = 3

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' existing = {
  name: vmName
}

resource domainJoin 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if (enabled) {
  name: '${vm.name}/joindomain'
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainName
      OUPath: empty(ouPath) ? null : ouPath
      User: username
      Restart: restart
      Options: options
    }
    protectedSettings: {
      Password: password
    }
  }
}

output extensionName string = enabled ? domainJoin.name : ''
