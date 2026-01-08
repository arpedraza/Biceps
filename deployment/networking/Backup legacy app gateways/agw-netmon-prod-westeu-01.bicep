param applicationGateways_agw_netmon_prod_westeu_01_name string = 'agw-netmon-prod-westeu-01'
param virtualNetworks_vnet_ep_shared_westeu_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-network-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-ep-shared-westeu-01'
param publicIPAddresses_pip_ep_agw_netmon_01_externalid string = '/subscriptions/c71cfef2-700e-47e5-b810-e34898fd2249/resourceGroups/rg-ep-monitoring-prod-01/providers/Microsoft.Network/publicIPAddresses/pip-ep-agw-netmon-01'

resource applicationGateways_agw_netmon_prod_westeu_01_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_agw_netmon_prod_westeu_01_name
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
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_vnet_ep_shared_westeu_01_externalid}/subnets/snet-ep-shared-applicationgateway-westeu-01'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'WildcartCertificate'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/sslCertificates/WildcartCertificate'
        properties: {}
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
        properties: {}
      }
    ]
    authenticationCertificates: [
      {
        name: 'Wildcard_Euroports2024'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/authenticationCertificates/Wildcard_Euroports2024'
        properties: {
          data: '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'
        }
      }
      {
        name: 'EuroportsWildcard20242025'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/authenticationCertificates/EuroportsWildcard20242025'
        properties: {
          data: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlIMVRDQ0JyMmdBd0lCQWdJUUJDNDhnS2RpYWRaa3ZPT1JNaUM1VmpBTkJna3Foa2lHOXcwQkFRc0ZBREJaDQpNUXN3Q1FZRFZRUUdFd0pWVXpFVk1CTUdBMVVFQ2hNTVJHbG5hVU5sY25RZ1NXNWpNVE13TVFZRFZRUURFeXBFDQphV2RwUTJWeWRDQkhiRzlpWVd3Z1J6SWdWRXhUSUZKVFFTQlRTRUV5TlRZZ01qQXlNQ0JEUVRFd0hoY05NalF4DQpNREF6TURBd01EQXdXaGNOTWpVeE1ESXhNak0xT1RVNVdqQldNUXN3Q1FZRFZRUUdFd0pDUlRFUU1BNEdBMVVFDQpCeE1IUW1WMlpYSmxiakViTUJrR0ExVUVDaE1TUlhWeWIzQnZjblJ6SUVkeWIzVndJRUpXTVJnd0ZnWURWUVFEDQpEQThxTG1WMWNtOXdiM0owY3k1amIyMHdnZ0lpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDDQpBUURtWjd4R284L0lnQ1l3RUY3dCtyKzc2MGJ4UUY0RUIvQXNjVWJpSTAxWmU5YXF0RFRxUmRnTGhiL2tXZS9zDQpITXYwY1BKd3hNZXVna2dDbU9oSm9JZnJlRDBKMmNsTnN2MStkeWVrSDFraEo0YWx2dHBOcHo0Q1M0L3Frak5xDQpSa0YzKytYTFVNZTJFbVFHRWtQTE9tOUd2WTI2czB6cUpLaUNXL05mdi8xWGwzZUNWVjJaTCtDc3FXNlVTbFM1DQplUk4rdW4xUUFCdHJHL0ZoT0V4QzI4c09UQk92Y1k2czNkTkpNcHZyMGRIaHE0YzNGaFdWcS80cmdkTEpvSnJLDQpabjNqV0huZFFBOGFMdEpxcXZGbkVoelZZVDlLZ3BMQ1JlWld5YStvSk1EWkZqNUhBZktoKy80bnBBRUNXZW43DQpZMXFubHJ0U1ZTQ2RiZzBDdGhGOHU2VjJWZkpibStrTUUya2JPSXdZY25SYXZpWVY5QXEwcXdNVmZJNUYrNmdGDQp2dko4UTVEWWpiZnRHTzUxQmVRQ01yOUkyQk51eGJyaUttcTZVNTE4WGtxOFlZV3o5VEFJR3EwNXlmRVdWVVpzDQo2TG1XWlFYeVpFckwwa3R6UjdCeDRiMzVrWWp1MXJSUThMY24zQzFFKzUyNzhLbUQwYUwxdFhSVWIyZXdNTjB0DQpWdHJyMG5GdVI0amlGbmo1MzQxaUZlTlh1SEFmdSsvNmV4SjA3dTVOV2I5TEVKY2hHcUtoT3pCMHZ6SDVLS0ZxDQppaTZBd0FKYVcwbmwyaDBXOWFvT3Q3S0pqWXJVZndHbGRadlY3MDV6NzhHbHlGMlhLcHpnREw5TlNGRTJHQmY4DQpML1d5amQ5bGtkLzA0SjZMRFVXMm1EcTNPM2tZTVE4ZU9YS3NCcVc3L0t2SWl3SURBUUFCbzRJRG1qQ0NBNVl3DQpId1lEVlIwakJCZ3dGb0FVZElXQXdHYkgzemZlejcwcE42b0RIYjd0elJjd0hRWURWUjBPQkJZRUZEOUpFRmIxDQo1czR2bnh3d2c5TWE3YUVDMlYxdk1Da0dBMVVkRVFRaU1DQ0NEeW91WlhWeWIzQnZjblJ6TG1OdmJZSU5aWFZ5DQpiM0J2Y25SekxtTnZiVEErQmdOVkhTQUVOekExTURNR0JtZUJEQUVDQWpBcE1DY0dDQ3NHQVFVRkJ3SUJGaHRvDQpkSFJ3T2k4dmQzZDNMbVJwWjJsalpYSjBMbU52YlM5RFVGTXdEZ1lEVlIwUEFRSC9CQVFEQWdXZ01CMEdBMVVkDQpKUVFXTUJRR0NDc0dBUVVGQndNQkJnZ3JCZ0VGQlFjREFqQ0Jud1lEVlIwZkJJR1hNSUdVTUVpZ1JxQkVoa0pvDQpkSFJ3T2k4dlkzSnNNeTVrYVdkcFkyVnlkQzVqYjIwdlJHbG5hVU5sY25SSGJHOWlZV3hITWxSTVUxSlRRVk5JDQpRVEkxTmpJd01qQkRRVEV0TVM1amNtd3dTS0JHb0VTR1FtaDBkSEE2THk5amNtdzBMbVJwWjJsalpYSjBMbU52DQpiUzlFYVdkcFEyVnlkRWRzYjJKaGJFY3lWRXhUVWxOQlUwaEJNalUyTWpBeU1FTkJNUzB4TG1OeWJEQ0Jod1lJDQpLd1lCQlFVSEFRRUVlekI1TUNRR0NDc0dBUVVGQnpBQmhoaG9kSFJ3T2k4dmIyTnpjQzVrYVdkcFkyVnlkQzVqDQpiMjB3VVFZSUt3WUJCUVVITUFLR1JXaDBkSEE2THk5allXTmxjblJ6TG1ScFoybGpaWEowTG1OdmJTOUVhV2RwDQpRMlZ5ZEVkc2IySmhiRWN5VkV4VFVsTkJVMGhCTWpVMk1qQXlNRU5CTVMweExtTnlkREFNQmdOVkhSTUJBZjhFDQpBakFBTUlJQmZnWUtLd1lCQkFIV2VRSUVBZ1NDQVc0RWdnRnFBV2dBZFFBUzhVNDB2Vk55VElRR0djT1BQM29UDQorT2UxWW9lSW5HMHdCWVRyNVlZbU9nQUFBWkpTTFRnbkFBQUVBd0JHTUVRQ0lHcUxzWG1jbjFWakVic1l1S2ZaDQphSHV2dDJOUk1qZVFCNXFJdDF2V0I5NjdBaUFLaFhpVXdwVmhYU2dyRHhxaU0zb3FuY1RkS3V4MDB3S0lYRXVhDQpEMjFpeWdCMkFPYlNNV05BZDR6QkVFRUcxM0c1enNIU1FQYVdoSWI3dW9jeUhmMGVONDVRQUFBQmtsSXRPSElBDQpBQVFEQUVjd1JRSWhBS1BveFRvVlNEQy94Z0hyR2RUYTVLWVNtblBNTUcweUg4VlNtODdxSXQ1MUFpQmFBbzFHDQoxNkFuUTJSTE5veGl5OTRRRDFHTmtmRG5XZ1ExYWVkSmNsRWxIQUIzQU16N0QycUZjUWxsL3BXYlU4N3BzbndpDQo2WVZjRFplTnRxbCtWTUQrVEEyd0FBQUJrbEl0T0dNQUFBUURBRWd3UmdJaEFPMFJScUc3YTVQalEwVDBOQ3FpDQpabG1HREx6M0xudFhKODJyWHd3QTVmRmdBaUVBbEdhbzVaeHQyNWcrMUxhc3RlQ01PL3JaY1VFTzVCTzNYT3ZFDQozQzIrOVZJd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFMYjFkeEphK0VQK29SZHdqUElHL3FjUy9aZWFua0ZpDQpINGZ1YVU2ZDNiVkVGUHUvb3FkdGJPcXBZTTF2ZEZZWmdOWVgxeGJweFMwL3g5WjdESUR4dFJBcmE5UzRrbXJVDQpnZmpWSE1MajhzaTlsbm1wRXVDNTZDZ0xVMWdSOGJGNTZsVDVNV0lpejRnSjBjM2pMaXd6bE1nTlVYSE5YOXZTDQovZXZYT1l1OU1VaWtNWFI4UTN4T0d2ZHFiL2xjeExJekpUQ3ZRRlZlTTRaWlJ3TTZvdUxySHlYM3lVQXZMcmxKDQo2ZHBBZDZISElKWFdkYUFQMUNMMFpjcWNOOGdYbnZVelRQaEtCUUZwVkJOd2VQTWx3S2tjcFZiaW1DeG0xZDh2DQp3Rlg3OXp0SVMrZUdNL2Z1U1pnZHZBdHl5U0lkbHhOOXVsTFBvTWpxVGtDOFJTVHRnMFFGUFVBPQ0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ0K'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_pip_ep_agw_netmon_01_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'shrpwe-mon01.corp.euroports.com'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/backendAddressPools/shrpwe-mon01.corp.euroports.com'
        properties: {
          backendAddresses: [
            {
              fqdn: 'shrpwe-mon01.corp.euroports.com'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'StandardHttpSettings'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          authenticationCertificates: [
            {
              id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/authenticationCertificates/EuroportsWildcard20242025'
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'Public-ListenerHttpRedirect'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHttpRedirect'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'Public-ListenerStandard'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/sslCertificates/EuroportsWildcard20242025'
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
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerStandard'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
          }
          backendAddressPool: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/backendAddressPools/shrpwe-mon01.corp.euroports.com'
          }
          backendHttpSettings: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/backendHttpSettingsCollection/StandardHttpSettings'
          }
        }
      }
      {
        name: 'Public-ListenerHttpRedirect'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerHttpRedirect'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerHttpRedirect'
          }
          redirectConfiguration: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-ListenerHttpRedirect'
          }
        }
      }
    ]
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: [
      {
        name: 'Public-ListenerHttpRedirect'
        id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/redirectConfigurations/Public-ListenerHttpRedirect'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/httpListeners/Public-ListenerStandard'
          }
          includePath: true
          includeQueryString: true
          requestRoutingRules: [
            {
              id: '${applicationGateways_agw_netmon_prod_westeu_01_name_resource.id}/requestRoutingRules/Public-ListenerHttpRedirect'
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
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA'
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
