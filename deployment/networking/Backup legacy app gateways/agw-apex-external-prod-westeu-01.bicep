param applicationGateways_agw_apex_external_prod_westeu_01_name string = 'agw-apex-external-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_02_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-02'
param publicIPAddresses_pip_apex2_prod_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-apex-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-apex2-prod-westeu-01'

resource applicationGateways_agw_apex_external_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_apex_external_prod_westeu_01_name
  location: 'westeurope'
  zones: [
    '1'
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_02_externalid}/subnets/snet-ep-appgateway-v2-prod-westeu01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'Wildcard'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/sslCertificates/Wildcard'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_apex2_prod_westeu_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.11.127.30'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'BackendSettings01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/BackendSettings01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 300
          probe: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/probes/Probe01'
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'Listener02'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/httpListeners/Listener02'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
      {
        name: 'Listener01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
          }
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: [
      {
        name: 'Rule02'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02'
        properties: {
          defaultBackendAddressPool: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
          }
          defaultBackendHttpSettings: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/BackendSettings01'
          }
          pathRules: [
            {
              name: 'Stylesheets'
              id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/Stylesheets'
              properties: {
                paths: [
                  '/i/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/BackendSettings01'
                }
              }
            }
            {
              name: 'Berthplanning'
              id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/Berthplanning'
              properties: {
                paths: [
                  '/ords/r/berth_planning*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/BackendSettings01'
                }
              }
            }
            {
              name: 'BerthPlanning2'
              id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BerthPlanning2'
              properties: {
                paths: [
                  '/ords/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendAddressPools/BackendPool01'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/BackendSettings01'
                }
              }
            }
            {
              name: 'BlockApex'
              id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BlockApex'
              properties: {
                paths: [
                  '/ords/r/apex*'
                ]
                redirectConfiguration: {
                  id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_BlockApex'
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'Rule02'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule02'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 98
          httpListener: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          urlPathMap: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02'
          }
        }
      }
      {
        name: 'Rule01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule01'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/httpListeners/Listener02'
          }
          redirectConfiguration: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule01'
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'Probe01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/probes/Probe01'
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
    rewriteRuleSets: [
      {
        name: 'Rewrite01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/rewriteRuleSets/Rewrite01'
        properties: {
          rewriteRules: []
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'Rule02_RedirectApex'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_RedirectApex'
        properties: {
          redirectType: 'Temporary'
          targetUrl: 'https://e-bp2.euroports.com/ords/r/berth_planning/berth-booking/'
          includePath: false
          includeQueryString: false
        }
      }
      {
        name: 'Rule02_ApexAuthentication'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_ApexAuthentication'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://e-bp2.euroports.com/apex_authentication.callback'
          includePath: false
          includeQueryString: true
        }
      }
      {
        name: 'Rule01'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule01'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/httpListeners/Listener01'
          }
          includePath: true
          includeQueryString: true
          requestRoutingRules: [
            {
              id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/requestRoutingRules/Rule01'
            }
          ]
        }
      }
      {
        name: 'Rule02_BlockTinyTiger'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_BlockTinyTiger'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://e-bp.euroports.com/ords/r/berth_planning/berth-booking/'
          includePath: false
          includeQueryString: false
        }
      }
      {
        name: 'Rule02_BlockApex'
        id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/redirectConfigurations/Rule02_BlockApex'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://e-bp.euroports.com/ords/r/berth_planning/berth-booking/'
          includePath: false
          includeQueryString: false
          pathRules: [
            {
              id: '${applicationGateways_agw_apex_external_prod_westeu_01_name_resource.id}/urlPathMaps/Rule02/pathRules/BlockApex'
            }
          ]
        }
      }
    ]
    privateLinkConfigurations: []
    webApplicationFirewallConfiguration: {
      enabled: false
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: true
  }
}
