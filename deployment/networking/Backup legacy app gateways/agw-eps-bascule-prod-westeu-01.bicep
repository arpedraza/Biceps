param applicationGateways_agw_eps_bascule_prod_westeu_01_name string = 'agw-eps-bascule-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-01'
param publicIPAddresses_pip_ep_agw_bascule_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-eps-bascule-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-agw-bascule-01'

resource applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_eps_bascule_prod_westeu_01_name
  location: 'westeurope'
  properties: {
    sku: {
      name: 'Standard_Medium'
      tier: 'Standard'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'WildcardCertificate'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/sslCertificates/WildcardCertificate'
        properties: {}
      }
      {
        name: 'WildcartEuroports'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/sslCertificates/WildcartEuroports'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    authenticationCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_agw_bascule_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'epspwe-wbr01.corp.euroports.com'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/backendAddressPools/epspwe-wbr01.corp.euroports.com'
        properties: {
          backendAddresses: [
            {
              fqdn: 'epspwe-wbr01.corp.euroports.com'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'StandardHttpSettings'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
        properties: {
          port: 8081
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'Public-ListenerHttpRedirect'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHttpRedirect'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
          }
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerStandard'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/backendAddressPools/epspwe-wbr01.corp.euroports.com'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
          }
        }
      }
      {
        name: 'Public-RedirectHttp'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-RedirectHttp'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHttpRedirect'
          }
          redirectConfiguration: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-RedirectHttp'
          }
        }
      }
    ]
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: [
      {
        name: 'Public-RedirectHttp'
        id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-RedirectHttp'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
          }
          includePath: true
          includeQueryString: true
          requestRoutingRules: [
            {
              id: '${applicationGateways_agw_eps_bascule_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-RedirectHttp'
            }
          ]
        }
      }
    ]
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_RSA_WITH_AES_256_CBC_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
        'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_RSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA'
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA'
        'TLS_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_RSA_WITH_AES_256_CBC_SHA'
        'TLS_RSA_WITH_AES_128_CBC_SHA'
      ]
    }
    enableHttp2: false
  }
}
