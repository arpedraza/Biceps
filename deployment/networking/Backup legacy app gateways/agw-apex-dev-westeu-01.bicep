param applicationGateways_agw_apex_dev_westeu_01_name string = 'agw-apex-dev-westeu-01'
param virtualNetworks_vnet_ep_shared_test_westeu_01_externalid string = '/subscriptions/c2ae3152-6777-45b2-8c04-f4492ad08be4/resourceGroups/rg-ep-network-test-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-test-westeu-01'

resource applicationGateways_agw_apex_dev_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_apex_dev_westeu_01_name
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
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_test_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'Wildcard'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/sslCertificates/Wildcard'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    authenticationCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPrivateFrontendIpIPv4'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIpIPv4'
        properties: {
          privateIPAddress: '10.11.142.145'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_test_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool01'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.11.131.5'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'Settings01'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Enabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 300
          probe: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/probes/Probe'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'Listener01'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/httpListeners/Listener01'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
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
        name: 'Rule01'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/requestRoutingRules/Rule01'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
          }
        }
      }
    ]
    probes: [
      {
        name: 'Probe'
        id: '${applicationGateways_agw_apex_dev_westeu_01_name_resource.id}/probes/Probe'
        properties: {
          protocol: 'Http'
          host: 'apex-dev.euroports.com'
          path: '/ords-dev'
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
