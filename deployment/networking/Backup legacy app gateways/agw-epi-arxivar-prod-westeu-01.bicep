param applicationGateways_agw_epi_arxivar_prod_westeu_01_name string = 'agw-epi-arxivar-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_02_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-02'
param publicIPAddresses_pip_ep_agw_arxivar_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-epi-backoffice-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-agw-arxivar-01'
param ApplicationGatewayWebApplicationFirewallPolicies_waf01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-epi-backoffice-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf01'

resource applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_epi_arxivar_prod_westeu_01_name
  location: 'westeurope'
  zones: [
    '1'
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      family: 'Generation_1'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
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
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/sslCertificates/Wildcard'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_agw_arxivar_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'epi0007.epi.int'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/backendAddressPools/epi0007.epi.int'
        properties: {
          backendAddresses: [
            {
              fqdn: 'epi0007.epi.int'
            }
            {
              ipAddress: '10.11.160.6'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'StandardHttpSettings'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
          probe: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/probes/Probe01'
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
      {
        name: 'Public-ListenerHTTPS'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHTTPS'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
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
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerStandard'
        properties: {
          ruleType: 'Basic'
          priority: 10
          httpListener: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
          }
          redirectConfiguration: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-ListenerStandard'
          }
        }
      }
      {
        name: 'Public-ListenerHTTPS'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerHTTPS'
        properties: {
          ruleType: 'Basic'
          priority: 11
          httpListener: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHTTPS'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/backendAddressPools/epi0007.epi.int'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'Probe01'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/probes/Probe01'
        properties: {
          protocol: 'Http'
          host: 'epi0007.epi.int'
          path: '/ARXivarNextAuthentication'
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
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-ListenerStandard'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHTTPS'
          }
          includePath: true
          includeQueryString: true
          requestRoutingRules: [
            {
              id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerStandard'
            }
          ]
        }
      }
      {
        name: 'Public-PathBased_Arxivar'
        id: '${applicationGateways_agw_epi_arxivar_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-PathBased_Arxivar'
        properties: {
          redirectType: 'Permanent'
          targetUrl: 'https://arxivar.euroports.com/ARXivarNextAuthentication'
          includePath: false
          includeQueryString: false
        }
      }
    ]
    privateLinkConfigurations: []
    enableHttp2: true
    forceFirewallPolicyAssociation: true
    firewallPolicy: {
      id: ApplicationGatewayWebApplicationFirewallPolicies_waf01_externalid
    }
  }
}
