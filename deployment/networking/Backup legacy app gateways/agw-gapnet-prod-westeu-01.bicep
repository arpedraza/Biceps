param applicationGateways_agw_gapnet_prod_westeu_01_name string = 'agw-gapnet-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-01'
param publicIPAddresses_pip_ep_agw_gapnet_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-gapnet-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-agw-gapnet-01'

resource applicationGateways_agw_gapnet_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_gapnet_prod_westeu_01_name
  location: 'westeurope'
  properties: {
    sku: {
      name: 'Standard_Small'
      tier: 'Standard'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'WildcardEuroports'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/sslCertificates/WildcardEuroports'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    authenticationCertificates: [
      {
        name: 'WildcardEuroports'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/authenticationCertificates/WildcardEuroports'
        properties: {
          data: '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'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_agw_gapnet_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_8443'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/frontendPorts/port_8443'
        properties: {
          port: 8443
        }
      }
      {
        name: 'port_443'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'epbpwe-bgt01.corp.euroports.com'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/backendAddressPools/epbpwe-bgt01.corp.euroports.com'
        properties: {
          backendAddresses: [
            {
              fqdn: 'epbpwe-bgt01.corp.euroports.com'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'StandardHttpSettings'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
        properties: {
          port: 8083
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
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
        id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerStandard'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/backendAddressPools/epbpwe-bgt01.corp.euroports.com'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_gapnet_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
          }
        }
      }
    ]
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
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
