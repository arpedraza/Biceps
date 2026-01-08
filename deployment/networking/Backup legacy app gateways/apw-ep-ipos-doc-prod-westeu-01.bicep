param applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name string = 'apw-ep-ipos-doc-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_02_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-02'
param publicIPAddresses_pip_ep_ipos_doc_prod_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-ipos-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-ipos-doc-prod-westeu-01'

resource applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name
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
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_02_externalid}/subnets/snet-ep-appgateway-v2-prod-westeu01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'wildcard'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/sslCertificates/wildcard'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_ipos_doc_prod_westeu_01_externalid
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIp'
        properties: {
          privateIPAddress: '10.11.166.132'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_02_externalid}/subnets/snet-ep-appgateway-v2-prod-westeu01'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'Backend'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/backendAddressPools/Backend'
        properties: {
          backendAddresses: [
            {
              fqdn: 'app-ep-ipos-doc-prod-westeu-04.azurewebsites.net'
            }
            {
              fqdn: 'app-ep-ipos-doc-prod-westeu-02.azurewebsites.net'
            }
            {
              fqdn: 'app-ep-ipos-doc-prod-westeu-03.azurewebsites.net'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'HTTP-Settings'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/HTTP-Settings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Enabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 600
          probe: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/probes/HTTP-Settingsc7a6eb02-d809-4de7-8ff3-366990b421ed'
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'ListernetHTTP'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/httpListeners/ListernetHTTP'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'ListenerHTTPS'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/httpListeners/ListenerHTTPS'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPrivateFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
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
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/requestRoutingRules/RoutingHTTP'
        properties: {
          ruleType: 'Basic'
          priority: 10010
          httpListener: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/httpListeners/ListernetHTTP'
          }
          backendAddressPool: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/backendAddressPools/Backend'
          }
          backendHttpSettings: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/HTTP-Settings'
          }
          rewriteRuleSet: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/rewriteRuleSets/RedirectRewrite'
          }
        }
      }
      {
        name: 'RoutingHTTPS'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/requestRoutingRules/RoutingHTTPS'
        properties: {
          ruleType: 'Basic'
          priority: 10020
          httpListener: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/httpListeners/ListenerHTTPS'
          }
          backendAddressPool: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/backendAddressPools/Backend'
          }
          backendHttpSettings: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/HTTP-Settings'
          }
          rewriteRuleSet: {
            id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/rewriteRuleSets/RedirectRewrite'
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'HTTP-Settingsc7a6eb02-d809-4de7-8ff3-366990b421ed'
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/probes/HTTP-Settingsc7a6eb02-d809-4de7-8ff3-366990b421ed'
        properties: {
          protocol: 'Http'
          path: '/ipos/'
          interval: 30
          timeout: 10
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
        id: '${applicationGateways_apw_ep_ipos_doc_prod_westeu_01_name_resource.id}/rewriteRuleSets/RedirectRewrite'
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
                    headerValue: '{http_resp_Location_1}://tos.euroports.com{http_resp_Location_2}'
                  }
                ]
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
      ]
    }
    enableHttp2: false
  }
}
