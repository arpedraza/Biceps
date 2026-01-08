targetScope = 'subscription'

param location string

param agwResourceGroupName string
param certResourceGroupName string
param vnetResourceGroupName string
param vnetName string
param subnetName string
param appGatewayName string
param keyVaultName string
param managedIdentityName string
param publicIP object
param appGatewaySku string
param appGatewayZones array
param frontendPorts array
param frontendIPConfigurations object
param redirectConfigurations array
param authenticationCertificates array
param autoscaleMaxCapacity int
param autoscaleMinCapacity int
param capacity int
param enableHttp2 bool
param backendAddressPools array
param backendHttpSettingsCollection array
param probes array
param httpListeners array
param requestRoutingRules array
param sslCertificates array
param urlPathMaps array
param diagnosticsSettings array
param apps array
param rewriteRuleSets array

var snetId = vnet::subnet.id
var appGatewayId = resourceId(subscription().subscriptionId,agwResourceGroupName,'Microsoft.Network/applicationGateways', appGatewayName)

var var_frontendIPConfigurations = [
  frontendIPConfigurations.publicIPAddress ? {
    name: frontendIPConfigurations.publicConfigName
    properties: {
      publicIPAddress: {
        id: pip.outputs.resourceId
      }
    }
  } : null
  !empty(frontendIPConfigurations.privateIPAddress) ? {
    name: frontendIPConfigurations.privateConfigName
    properties: {
      privateIPAddress: frontendIPConfigurations.privateIPAddress
      privateIPAllocationMethod: 'Static'
      subnet: {
        id: snetId
      }
    }
  } : null
]

var var_backendHttpSettingsCollection = [
  for setting in backendHttpSettingsCollection: {
    name: setting.name
    properties: !empty(setting.probeName) ? union(setting.properties, {
      probe: {
        id: '${appGatewayId}/probes/${setting.probeName}'
      }
    }) : setting.properties
  }
]

var var_httpListeners = [
  for listener in httpListeners: {
    name: listener.name
    properties: {
      firewallPolicy: !empty(listener.firewallPolicy) ? {
        id: listener.firewallPolicy
      } : null
      frontendIPConfiguration: {
        id: listener.frontendIPConfiguration == 'public' ? '${appGatewayId}/frontendIPConfigurations/${frontendIPConfigurations.publicConfigName}' : '${appGatewayId}/frontendIPConfigurations/${frontendIPConfigurations.privateConfigName}'
      }
      frontendPort: {
        id: listener.frontendPort == 443 ? '${appGatewayId}/frontendPorts/Port_443' : '${appGatewayId}/frontendPorts/Port_80'
      }
      protocol: listener.frontendPort == 443 ? 'https' : 'http'
      hostName: listener.hostName
      requireServerNameIndication: listener.frontendPort == 443 ? true : false
      sslCertificate: listener.frontendPort == 443 ? {
        id: '${appGatewayId}/sslCertificates/${listener.sslCertificateName}'
      } : null
    }
  }
]

var var_requestRoutingRules = [
  for rule in requestRoutingRules: {
    name: rule.name
    properties: {
      backendAddressPool: !empty(rule.backendAddressPool) ? {
        id: '${appGatewayId}/backendAddressPools/${rule.backendAddressPool}'
      } : null
      backendHttpSettings: !empty(rule.backendHttpSettings) ? {
        id: '${appGatewayId}/backendHttpSettingsCollection/${rule.backendHttpSettings}'
      } : null
      rewriteRuleSet: !empty(rule.rewriteRuleSet) ? {
        id: '${appGatewayId}/rewriteRuleSets/${rule.rewriteRuleSet}'
      } : null
      httpListener: {
        id: '${appGatewayId}/httpListeners/${rule.httpListener}'
      }
      redirectConfiguration: !empty(rule.redirectConfiguration) ? {
        id: '${appGatewayId}/redirectConfigurations/${rule.httpListener}'
      } : null
      urlPathMap: !empty(rule.urlPathMap) ? {
        id: '${appGatewayId}/urlPathMaps/${rule.urlPathMap}'
      } : null
      priority: rule.priority
      ruleType: rule.ruleType
    }
  }
]

var var_redirectConfigurations = [
  for configuration in redirectConfigurations: {
    name: configuration.name
    properties: {
      redirectType: configuration.redirectType
      targetListener: !empty(configuration.targetListener) ? {
        id: '${appGatewayId}/httpListeners/${configuration.targetListener}'
      } : null
      targetUrl: !empty(configuration.targetUrl) ? configuration.targetUrl : null
      includePath: configuration.includePath
      includeQueryString: configuration.includeQueryString
      requestRoutingRules: !empty (configuration.requestRoutingRule) ? [
        {
          id: '${appGatewayId}/requestRoutingRules/${configuration.requestRoutingRule}'
        } 
      ] : null
      pathRules: !empty(configuration.pathRules) ? configuration.pathRules : null
    }
  }
]

var var_sslCertificates = [
  for cert in sslCertificates: {
    name: cert.name
    properties: {
      keyVaultSecretId: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/secrets/${cert.name}'
    }
  }
]

var var_urlPathMaps = [
  for map in urlPathMaps: {
    name: map.name
    properties: {
      defaultBackendAddressPool: {
            id: '${appGatewayId}/backendAddressPools/${map.backendAddressPool}'
          }
      defaultBackendHttpSettings: {
        id: '${appGatewayId}/backendHttpSettingsCollection/${map.backendHttpSettings}'
      }
      pathRules : map.pathRules
    }
  }
]

var var_rewriteRuleSets = [
  for ruleSet in rewriteRuleSets: {
    name: ruleSet.name
    properties: ruleSet.properties
  }
]

resource rgAppGateway'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: agwResourceGroupName
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
  resource subnet 'subnets@2023-04-01' existing = {
    name: subnetName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup(certResourceGroupName)
}

resource umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = {
  scope: resourceGroup(certResourceGroupName)
  name: managedIdentityName
}

module pip 'br/public:avm/res/network/public-ip-address:0.8.0' = {
  scope: rgAppGateway
  name: 'module-avm-pip-${publicIP.name}'
  params: {
    name: publicIP.name
    publicIPAllocationMethod: publicIP.publicIPAllocationMethod
    skuName: publicIP.skuName
    skuTier: publicIP.skuTier
    location: location
    zones: publicIP.zones
    dnsSettings: {
      domainNameLabel: publicIP.domainNameLabel
    }
  }
}

module agw 'br/public:avm/res/network/application-gateway:0.7.0' = {
  scope: rgAppGateway
  name: 'module-avm-agw-${appGatewayName}'
  params: {
    name: appGatewayName
    location: location
    availabilityZones: appGatewayZones
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: var_backendHttpSettingsCollection
    authenticationCertificates: authenticationCertificates
    autoscaleMinCapacity: autoscaleMinCapacity
    autoscaleMaxCapacity: autoscaleMaxCapacity
    capacity: capacity
    enableHttp2: enableHttp2
    firewallPolicyResourceId: wafGlobalPolicy.outputs.resourceId
    frontendIPConfigurations: var_frontendIPConfigurations
    frontendPorts: frontendPorts
    gatewayIPConfigurations: [
      {
        name: 'agw-ip-configuration'
        properties: {
          subnet: {
            id: snetId
          }
        }
      }
    ]
    httpListeners: var_httpListeners
    probes: probes
    redirectConfigurations: var_redirectConfigurations
    requestRoutingRules: var_requestRoutingRules
    rewriteRuleSets: var_rewriteRuleSets
    sku: appGatewaySku
    urlPathMaps: var_urlPathMaps
    sslCertificates: var_sslCertificates
    managedIdentities: {
      userAssignedResourceIds: [
        umi.id
      ]
    }
    diagnosticSettings: diagnosticsSettings
  }
  dependsOn: [
    keyVault
  ]
}

module wafGlobalPolicy 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.2.0' = {
  scope: rgAppGateway
  name: 'waf-policy-global-nonprod-deployment'
  params: {
    name: 'waf-policy-global-nonprod'
    location: location
    policySettings: {
      mode: 'Detection'
      state: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleGroupOverrides: []
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
        {
          ruleGroupOverrides: []
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.1'
        }
      ]
    }
  }
}

module wafPolicies 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.2.0' = [for app in apps: {
  scope: rgAppGateway
  name: 'waf-policy-${app.name}-deployment'
  params: {
    name: 'waf-policy-${app.name}'
    location: location
    policySettings: {
      mode: '${app.mode}'
      state: 'Enabled'
    }
    managedRules: {
      managedRuleSets: app.managedRuleSets
    }
  }
}]
