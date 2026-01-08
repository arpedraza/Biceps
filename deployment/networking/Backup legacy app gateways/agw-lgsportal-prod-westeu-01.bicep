param applicationGateways_agw_lgsportal_prod_westeu_01_name string = 'agw-lgsportal-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_02_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-02'
param publicIPAddresses_pip_lgsportal_prod_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-lgs-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-lgsportal-prod-westeu-01'

resource applicationGateways_agw_lgsportal_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_lgsportal_prod_westeu_01_name
  location: 'westeurope'
  zones: [
    '1'
  ]
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_02_externalid}/subnets/snet-ep-appgateway-v2-prod-westeu01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'EuroportsWildcard'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard'
        properties: {}
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_lgsportal_prod_westeu_01_externalid
          }
        }
      }
      {
        name: 'pip-lgsportal-prod-westeu-01'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendIPConfigurations/pip-lgsportal-prod-westeu-01'
        properties: {
          privateIPAddress: '10.11.166.140'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_02_externalid}/subnets/snet-ep-appgateway-v2-prod-westeu01'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'Backend01'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/backendAddressPools/Backend01'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.11.7.14'
            }
            {
              ipAddress: '10.11.7.15'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'Settings01'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Enabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
          probe: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/probes/Probe02'
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'Listener01'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendIPConfigurations/pip-lgsportal-prod-westeu-01'
          }
          frontendPort: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard'
          }
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
      {
        name: 'Listener02'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/httpListeners/Listener02'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendIPConfigurations/pip-lgsportal-prod-westeu-01'
          }
          frontendPort: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'Rule01'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule01'
        properties: {
          ruleType: 'Basic'
          priority: 20
          httpListener: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/backendAddressPools/Backend01'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
          }
        }
      }
      {
        name: 'Rule02'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule02'
        properties: {
          ruleType: 'Basic'
          priority: 21
          httpListener: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/httpListeners/Listener02'
          }
          redirectConfiguration: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02'
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'Probe01'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/probes/Probe01'
        properties: {
          protocol: 'Http'
          host: 'portal.euroports.com'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'Probe02'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/probes/Probe02'
        properties: {
          protocol: 'Https'
          host: 'portal.euroports.com'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: [
      {
        name: 'Rule02'
        id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          includePath: true
          includeQueryString: true
          requestRoutingRules: [
            {
              id: '${applicationGateways_agw_lgsportal_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule02'
            }
          ]
        }
      }
    ]
    privateLinkConfigurations: []
    enableHttp2: true
  }
}
