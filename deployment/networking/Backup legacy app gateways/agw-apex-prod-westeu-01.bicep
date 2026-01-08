param applicationGateways_agw_apex_prod_westeu_01_name string = 'agw-apex-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-01'
param publicIPAddresses_pip_apex_prod_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-apex-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-apex-prod-westeu-01'

resource applicationGateways_agw_apex_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_apex_prod_westeu_01_name
  location: 'westeurope'
  properties: {
    sku: {
      name: 'WAF_Medium'
      tier: 'WAF'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'Wildcard'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/sslCertificates/Wildcard'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    authenticationCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_apex_prod_westeu_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool01'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'Settings01'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 300
          probe: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/probes/Probe01'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'Listener02'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/httpListeners/Listener02'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'Listener01'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
          }
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: [
      {
        name: 'Rule02'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02'
        properties: {
          defaultBackendAddressPool: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
          }
          defaultBackendHttpSettings: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
          }
          pathRules: [
            {
              name: 'Stylesheets'
              id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/Stylesheets'
              properties: {
                paths: [
                  '/i/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
                }
              }
            }
            {
              name: 'BerthPlanning'
              id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BerthPlanning'
              properties: {
                paths: [
                  '/ords/r/berth_planning*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
                }
              }
            }
            {
              name: 'BerthPlanning2'
              id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BerthPlanning2'
              properties: {
                paths: [
                  '/ords/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/Settings01'
                }
              }
            }
            {
              name: 'BlockApex'
              id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BlockApex'
              properties: {
                paths: [
                  '/ords/r/apex*'
                ]
                redirectConfiguration: {
                  id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_BlockApex'
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'Rule01'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule01'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/httpListeners/Listener02'
          }
          redirectConfiguration: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule01'
          }
        }
      }
      {
        name: 'Rule02'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule02'
        properties: {
          ruleType: 'PathBasedRouting'
          httpListener: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          urlPathMap: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02'
          }
        }
      }
    ]
    probes: [
      {
        name: 'Probe01'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/probes/Probe01'
        properties: {
          protocol: 'Http'
          host: 'apex.euroports.com'
          path: '/ords'
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
        name: 'Rule01'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule01'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          includePath: true
          includeQueryString: true
          requestRoutingRules: [
            {
              id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule01'
            }
          ]
        }
      }
      {
        name: 'Rule02_redir'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_redir'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://www.google.com'
          includePath: false
          includeQueryString: false
        }
      }
      {
        name: 'Rule02_Redirect'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_Redirect'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://www.google.com'
          includePath: false
          includeQueryString: false
        }
      }
      {
        name: 'Rule02_BlockTinyTiger'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_BlockTinyTiger'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://e-bp.euroports.com/ords/r/berth_planning/berth-booking/'
          includePath: true
          includeQueryString: true
        }
      }
      {
        name: 'Rule02_BlockApex'
        id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_BlockApex'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://e-bp.euroports.com/ords/r/berth_planning/berth-booking/'
          includePath: false
          includeQueryString: false
          pathRules: [
            {
              id: '${applicationGateways_agw_apex_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BlockApex'
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
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      exclusions: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: false
  }
}
