param applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name string = 'apw-ep-ipos-doc-uat-westeu-01'
param virtualNetworks_vnet_ep_shared_test_westeu_01_externalid string = '/subscriptions/c2ae3152-6777-45b2-8c04-f4492ad08be4/resourceGroups/rg-ep-network-test-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-test-westeu-01'
param publicIPAddresses_pip_ep_ipos_doc_uat_westeu_01_externalid string = '/subscriptions/c2ae3152-6777-45b2-8c04-f4492ad08be4/resourceGroups/rg-ep-ipos-test-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-ipos-doc-uat-westeu-01'

resource applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name
  location: 'westeurope'
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_test_westeu_01_externalid}/subnets/snet-ep-applicationgateway-v2-test-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'Wildcard'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/sslCertificates/Wildcard'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_ipos_doc_uat_westeu_01_externalid
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIp'
        properties: {
          privateIPAddress: '10.11.141.20'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_test_westeu_01_externalid}/subnets/snet-ep-applicationgateway-v2-test-westeu-01'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'Backend'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/backendAddressPools/Backend'
        properties: {
          backendAddresses: [
            {
              fqdn: 'app-ep-ipos-doc-uat-westeu-01.azurewebsites.net'
            }
            {
              fqdn: 'app-ep-ipos-doc-uat-westeu-02.azurewebsites.net'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'HTTPSettings'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/backendHttpSettingsCollection/HTTPSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Enabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 600
          probe: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/probes/HTTPSettings027f0a63-f9ea-4286-88ad-ef7f78e34214'
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'ListenerHTTP'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/httpListeners/ListenerHTTP'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'ListenerHTTPS'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/httpListeners/ListenerHTTPS'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
          }
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
        name: 'RoutingHTTP'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/requestRoutingRules/RoutingHTTP'
        properties: {
          ruleType: 'Basic'
          priority: 10010
          httpListener: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/httpListeners/ListenerHTTP'
          }
          backendAddressPool: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/backendAddressPools/Backend'
          }
          backendHttpSettings: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/backendHttpSettingsCollection/HTTPSettings'
          }
          rewriteRuleSet: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/rewriteRuleSets/RedirectRewrite'
          }
        }
      }
      {
        name: 'RoutingHTTPS'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/requestRoutingRules/RoutingHTTPS'
        properties: {
          ruleType: 'Basic'
          priority: 10020
          httpListener: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/httpListeners/ListenerHTTPS'
          }
          backendAddressPool: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/backendAddressPools/Backend'
          }
          backendHttpSettings: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/backendHttpSettingsCollection/HTTPSettings'
          }
          rewriteRuleSet: {
            id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/rewriteRuleSets/RedirectRewrite'
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'HTTPSettings027f0a63-f9ea-4286-88ad-ef7f78e34214'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/probes/HTTPSettings027f0a63-f9ea-4286-88ad-ef7f78e34214'
        properties: {
          protocol: 'Http'
          path: '/ipos/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'RedirectRewrite'
        id: '${applicationGateways_apw_ep_ipos_doc_uat_westeu_01_name_resource.id}/rewriteRuleSets/RedirectRewrite'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              conditions: [
                {
                  variable: 'http_resp_Location'
                  pattern: '(https?):\\/\\/.*azurewebsites\\.net(.*)$'
                  ignoreCase: true
                  negate: false
                }
              ]
              name: 'RedirectRewrite'
              actionSet: {
                requestHeaderConfigurations: []
                responseHeaderConfigurations: [
                  {
                    headerName: 'Location'
                    headerValue: '{http_resp_Location_1}://tos-uat.euroports.com{http_resp_Location_2}'
                  }
                ]
              }
            }
            {
              ruleSequence: 101
              conditions: [
                {
                  variable: 'var_request_uri'
                  pattern: '^/$'
                  ignoreCase: true
                  negate: false
                }
              ]
              name: 'RedirectIPOSPath '
              actionSet: {
                requestHeaderConfigurations: []
                responseHeaderConfigurations: []
                urlConfiguration: {
                  modifiedPath: '/ipos'
                  reroute: false
                }
              }
            }
          ]
        }
      }
    ]
    redirectConfigurations: []
    privateLinkConfigurations: []
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
