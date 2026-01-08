using './main.bicep'

param location = 'westeurope'
param agwResourceGroupName = 'rg-mrg-waf-prod-01'
param certResourceGroupName = 'rg-mrg-waf-certs-prod-01'
param vnetResourceGroupName = 'rg-mrg-network-prod-01'
param vnetName = 'vnet-mrg-shared-prod-westeu-01'
param subnetName = 'snet-mrg-shared-waf-prod-westeu-01'
param appGatewayName = 'agw-edge-waf-prod-01'
param keyVaultName = 'kv-edge-waf-prod-01'
param managedIdentityName = 'umi-edge-waf-prod-01'
param publicIP = {
  name: 'pip-agw-edge-waf-prod-01'
  publicIPAllocationMethod: 'Static'
  skuName: 'Standard'
  skuTier: 'Regional'
  zones: [
    1
    2
    3
  ]
  domainNameLabel: 'agwedgewafprod'
}
param appGatewaySku = 'WAF_v2'
param appGatewayZones = [
  1
  2
  3
]
param frontendPorts = [
  {
    name: 'Port_443'
    properties: {
      port: 443
    }
  }
  {
    name: 'Port_80'
    properties: {
      port: 80
    }
  }
]
param frontendIPConfigurations = {
  publicConfigName: 'FrontEndIPConfiguration'
  publicIPAddress: true
  privateConfigName: 'PrivateFrontEndIPConfiguration'
  privateIPAddress: '10.11.123.4'
  }
param redirectConfigurations = [
  {
    name: 'tos.euroports.com_80'
    redirectType: 'Permanent'
    targetListener: 'tos.euroports.com_443'
    targetUrl: ''
    includePath: true
    includeQueryString: true
    requestRoutingRule: 'tos.euroports.com_80'
    pathRules: ''
  }
]
param authenticationCertificates = []
param autoscaleMaxCapacity = 16
param autoscaleMinCapacity = 2
param capacity = 1
param enableHttp2 = true
param diagnosticsSettings = [
  {
    name: 'all-logs-metrics'
    workspaceResourceId: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-logs-prod-01/providers/Microsoft.OperationalInsights/workspaces/law-edge-waf-prod-01'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    logCategoriesAndGroups: [
      {
        categoryGroup: 'allLogs'
      }
    ]
    logAnalyticsDestinationType: 'Dedicated'
  }
]
param backendAddressPools = [
  {
    name: 'netmon-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'shrpwe-mon01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'apex-internal-prod-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.127.30'
        }
        {
          ipAddress: '10.11.127.31'
        }
      ]
    }
  }
  {
    name: 'bzt-integration-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'shrpwe-bzt01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'camco-gate-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epbpwe-cam04.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'arxivar-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epi0007.epi.int'
        }
      ]
    }
  }
  {
    name: 'basculas-operativa-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epspwe-wbr01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'basculas-operativa-clientes-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epspwe-wbr01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'basculas-transito-carga-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epspwe-wbr01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'basculas-operativa-carga-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epspwe-wbr01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'gapnet-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'epbpwe-bgt01.corp.euroports.com'
        }
      ]
    }
  }
  {
    name: 'lgs-portal-prod-backend'
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
  {
    name: 'step-eterminal-api-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'ec524-api.euroports.com'
        }
      ]
    }
  }
  {
    name: 'step-eterminal-auth-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'ec524-auth.euroports.com'
        }
      ]
    }
  }
  {
    name: 'step-eterminal-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'ec524.euroports.com'
        }
      ]
    }
  }
  {
    name: 'ipos-doc-prod-backend'
    properties: {
      backendAddresses: [
        {
          fqdn: 'app-ep-ipos-doc-prod-westeu-02.azurewebsites.net'
        }
        {
          fqdn: 'app-ep-ipos-doc-prod-westeu-03.azurewebsites.net'
        }
        {
          fqdn: 'app-ep-ipos-doc-prod-westeu-04.azurewebsites.net'
        }
      ]
    }
  }
  {
    name: 'crl-eu-prod-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.124.38'
        }
      ]
    }
  }
]
param backendHttpSettingsCollection = [
  {
    name: 'netmon-prod-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'netmon-prod-probe'
  }
  {
    name: 'apex-internal-prod-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'apex-internal-prod-probe'
  }
  {
    name: 'bzt-integration-prod-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'bzt-integration-prod-probe'
  }
  {
    name: 'camco-gate-prod-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'camco-gate-prod-probe'
  }
  {
    name: 'arxivar-prod-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'arxivar-prod-probe'
  }
  {
    name: 'basculas-operativa-prod-backend-settings'
    properties: {
      port: 8081
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'basculas-operativa-prod-probe'
  }
  {
    name: 'basculas-operativa-clientes-prod-backend-settings'
    properties: {
      port: 8082
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'basculas-operativa-clientes-prod-probe'
  }
  {
    name: 'basculas-transito-carga-prod-backend-settings'
    properties: {
      port: 8084
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'basculas-transito-carga-prod-probe'
  }
  {
    name: 'basculas-operativa-carga-prod-backend-settings'
    properties: {
      port: 8083
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'basculas-operativa-carga-prod-probe'
  }
  {
    name: 'gapnet-prod-backend-settings'
    properties: {
      port: 8083
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'gapnet-prod-probe'
  }
  {
    name: 'lgs-portal-prod-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'lgs-portal-prod-probe'
  }
  {
    name: 'step-eterminal-api-prod-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'step-eterminal-api-prod-probe'
  }
  {
    name: 'step-eterminal-auth-prod-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: true
      requestTimeout: 120
    }
    probeName: 'step-eterminal-auth-prod-probe'
  }
  {
    name: 'step-eterminal-prod-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'step-eterminal-prod-probe'
  }
  {
    name: 'ipos-doc-prod-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Enabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: true
      requestTimeout: 120
    }
    probeName: 'ipos-doc-prod-probe'
  }
  {
    name: 'crl-eu-prod-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Disabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'crl-eu-prod-probe'
  }
]
param probes = [
  {
    name: 'netmon-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/Orion/Login.aspx'
      protocol: 'Https'
      host: 'netmon.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'apex-internal-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/ords'
      protocol: 'Http'
      host: 'apex.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'bzt-integration-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Https'
      host: 'integration-prd.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'camco-gate-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'camcogate.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'arxivar-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'arxivar.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'basculas-operativa-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'axbasculasoperativa.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'basculas-operativa-clientes-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'axbasculasoperativaclientes.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'basculas-transito-carga-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'axbasculastransitocarga.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'basculas-operativa-carga-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'axbasculasoperativacarga.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'gapnet-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'gapnet.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'lgs-portal-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Https'
      host: 'portal.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'step-eterminal-api-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Https'
      host: 'ec524-api.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'step-eterminal-auth-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: true
      path: '/auth'
      protocol: 'Https'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'step-eterminal-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Https'
      host: 'ec524.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'ipos-doc-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: true
      path: '/ipos/'
      protocol: 'Http'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
  {
    name: 'crl-eu-prod-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Http'
      host: 'crl-eu.euroports.com'
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '200-399'
        ]
      }
    }
  }
]
param httpListeners = [
  {
    name: 'apex-internal.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'apex.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-apex-internal-prod'
  }
  {
    name: 'integration-prd.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'integration-prd.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-bzt-integration-prod'
  }
  {
    name: 'camcogate.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'camcogate.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-camco-gate-prod'
  }
  {
    name: 'arxivar.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'arxivar.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-arxivar-prod'
  }
  {
    name: 'axbasculasoperativa.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'axbasculasoperativa.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-basculas-operativa-prod'
  }
  {
    name: 'axbasculasoperativaclientes.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'axbasculasoperativaclientes.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-basculas-operativa-clientes-prod'
  }
  {
    name: 'axbasculastransitocarga.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'axbasculastransitocarga.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-basculas-transito-carga-prod'
  }
  {
    name: 'axbasculasoperativacarga.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'axbasculasoperativacarga.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-basculas-operativa-carga-prod'
  }
  {
    name: 'gapnet.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'gapnet.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-gapnet-prod'
  }
  {
    name: 'portal.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'portal.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-lgs-portal-prod'
  }
  {
    name: 'ec524-api.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'ec524-api.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-step-eterminal-api-prod'
  }
  {
    name: 'ec524-auth.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'ec524-auth.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-step-eterminal-auth-prod'
  }
  {
    name: 'ec524.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'ec524.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-step-eterminal-prod'
  }
  {
    name: 'tos.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'tos.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-ipos-doc-prod'
  }
  {
    name: 'tos.euroports.com_80'
    frontendIPConfiguration: 'private'
    frontendPort: 80
    hostName: 'tos.euroports.com'
    requireServerNameIndication: false
    firewallPolicy: ''
  }
  {
    name: 'crl-eu.euroports.com_80'
    frontendIPConfiguration: 'public'
    frontendPort: 80
    hostName: 'crl-eu.euroports.com'
    requireServerNameIndication: false
    firewallPolicy: ''
  }
  {
    name: 'netmon.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'netmon.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-prod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-netmon-prod'
  }
]
param requestRoutingRules = [
  {
    name: 'netmon.euroports.com_443'
    backendAddressPool: 'netmon-prod-backend'
    backendHttpSettings: 'netmon-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'netmon.euroports.com_443'
    urlPathMap: ''
    priority: 1
    ruleType: 'Basic'
  }
  {
    name: 'apex-internal.euroports.com_443'
    backendAddressPool: 'apex-internal-prod-backend'
    backendHttpSettings: 'apex-internal-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'apex-internal.euroports.com_443'
    urlPathMap: ''
    priority: 4
    ruleType: 'Basic'
  }
  {
    name: 'integration-prd.euroports.com_443'
    backendAddressPool: 'bzt-integration-prod-backend'
    backendHttpSettings: 'bzt-integration-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'integration-prd.euroports.com_443'
    urlPathMap: ''
    priority: 5
    ruleType: 'Basic'
  }
  {
    name: 'camcogate.euroports.com_443'
    backendAddressPool: 'camco-gate-prod-backend'
    backendHttpSettings: 'camco-gate-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'camcogate.euroports.com_443'
    urlPathMap: ''
    priority: 6
    ruleType: 'Basic'
  }
  {
    name: 'arxivar.euroports.com_443'
    backendAddressPool: 'arxivar-prod-backend'
    backendHttpSettings: 'arxivar-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'arxivar.euroports.com_443'
    urlPathMap: ''
    priority: 7
    ruleType: 'Basic'
  }
  {
    name: 'axbasculasoperativa.euroports.com_443'
    backendAddressPool: 'basculas-operativa-prod-backend'
    backendHttpSettings: 'basculas-operativa-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'axbasculasoperativa.euroports.com_443'
    urlPathMap: ''
    priority: 8
    ruleType: 'Basic'
  }
  {
    name: 'axbasculasoperativaclientes.euroports.com_443'
    backendAddressPool: 'basculas-operativa-clientes-prod-backend'
    backendHttpSettings: 'basculas-operativa-clientes-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'axbasculasoperativaclientes.euroports.com_443'
    urlPathMap: ''
    priority: 9
    ruleType: 'Basic'
  }
  {
    name: 'axbasculastransitocarga.euroports.com_443'
    backendAddressPool: 'basculas-transito-carga-prod-backend'
    backendHttpSettings: 'basculas-transito-carga-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'axbasculastransitocarga.euroports.com_443'
    urlPathMap: ''
    priority: 10
    ruleType: 'Basic'
  }
  {
    name: 'axbasculasoperativacarga.euroports.com_443'
    backendAddressPool: 'basculas-operativa-carga-prod-backend'
    backendHttpSettings: 'basculas-operativa-carga-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'axbasculasoperativacarga.euroports.com_443'
    urlPathMap: ''
    priority: 11
    ruleType: 'Basic'
  }
  {
    name: 'gapnet.euroports.com_443'
    backendAddressPool: 'gapnet-prod-backend'
    backendHttpSettings: 'gapnet-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'gapnet.euroports.com_443'
    urlPathMap: ''
    priority: 12
    ruleType: 'Basic'
  }
  {
    name: 'portal.euroports.com_443'
    backendAddressPool: 'lgs-portal-prod-backend'
    backendHttpSettings: 'lgs-portal-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'portal.euroports.com_443'
    urlPathMap: ''
    priority: 13
    ruleType: 'Basic'
  }
  {
    name: 'ec524-api.euroports.com_443'
    backendAddressPool: 'step-eterminal-api-prod-backend'
    backendHttpSettings: 'step-eterminal-api-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'ec524-api.euroports.com_443'
    urlPathMap: ''
    priority: 14
    ruleType: 'Basic'
  }
  {
    name: 'ec524-auth.euroports.com_443'
    backendAddressPool: 'step-eterminal-auth-prod-backend'
    backendHttpSettings: 'step-eterminal-auth-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'ec524-auth.euroports.com_443'
    urlPathMap: ''
    priority: 15
    ruleType: 'Basic'
  }
  {
    name: 'ec524.euroports.com_443'
    backendAddressPool: 'step-eterminal-prod-backend'
    backendHttpSettings: 'step-eterminal-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'ec524.euroports.com_443'
    urlPathMap: ''
    priority: 16
    ruleType: 'Basic'
  }
  {
    name: 'tos.euroports.com_443'
    backendAddressPool: 'ipos-doc-prod-backend'
    backendHttpSettings: 'ipos-doc-prod-backend-settings'
    rewriteRuleSet: 'ipos-doc-prod-rewrite'
    redirectConfiguration: ''
    httpListener: 'tos.euroports.com_443'
    urlPathMap: ''
    priority: 17
    ruleType: 'Basic'
  }
  {
    name: 'crl-eu.euroports.com_80'
    backendAddressPool: 'crl-eu-prod-backend'
    backendHttpSettings: 'crl-eu-prod-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'crl-eu.euroports.com_80'
    urlPathMap: ''
    priority: 19
    ruleType: 'Basic'
  }
  {
    name: 'tos.euroports.com_80'
    backendAddressPool: ''
    backendHttpSettings: ''
    rewriteRuleSet: ''
    redirectConfiguration: 'tos.euroports.com_80'
    httpListener: 'tos.euroports.com_80'
    urlPathMap: ''
    priority: 37
    ruleType: 'Basic'
  }
]
param sslCertificates = [
  {
    name: 'euroports-wildcard'
  }
]
param urlPathMaps = []

param apps = [
  {
    name: 'netmon-prod'
    mode: 'Prevention'
    managedRuleSets: [
      {
        ruleGroupOverrides: [
          {
            ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
            rules: [
              {
                ruleId: '942100'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942110'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942120'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942130'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942140'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942150'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942160'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942170'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942180'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942190'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942200'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942210'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942220'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942230'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942240'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942250'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942251'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942260'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942270'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942280'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942290'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942300'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942310'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942320'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942330'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942340'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942350'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942360'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942361'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942370'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942380'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942390'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942400'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942410'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942420'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942421'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942430'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942431'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942432'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942440'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942450'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942460'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942470'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942480'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942490'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '942500'
                state: 'Enabled'
                action: 'Log'
              }
            ]
          }
          {
            ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
            rules: [
              {
                ruleId: '941100'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941101'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941110'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941120'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941130'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941140'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941150'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941160'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941170'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941180'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941190'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941200'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941210'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941220'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941230'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941240'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941250'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941260'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941270'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941280'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941290'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941300'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941310'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941320'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941330'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '941340'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '941350'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
              {
                ruleId: '941360'
                state: 'Enabled'
                action: 'AnomalyScoring'
              }
            ]
          }
          {
            ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
            rules: [
              {
                ruleId: '932115'
                state: 'Enabled'
                action: 'Log'
              }
            ]
          }
          {
            ruleGroupName: 'General'
            rules: [
              {
                ruleId: '200002'
                state: 'Enabled'
                action: 'Log'
              }
              {
                ruleId: '200003'
                state: 'Enabled'
                action: 'Log'
              }
            ]
          }
        ]
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'apex-internal-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'bzt-integration-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'camco-gate-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'arxivar-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'basculas-operativa-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'basculas-operativa-clientes-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'basculas-transito-carga-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'basculas-operativa-carga-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'gapnet-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'lgs-portal-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'step-eterminal-api-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'step-eterminal-auth-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'step-eterminal-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
  {
    name: 'ipos-doc-prod'
    mode: 'Detection'
    managedRuleSets: [
      {
        ruleGroupOverrides: []
        ruleSetType: 'OWASP'
        ruleSetVersion: '3.2'
      }
      {
        ruleGroupOverrides: []
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.1'
      }
    ]
  }
]

param rewriteRuleSets = [
  {
    name: 'ipos-doc-prod-rewrite'
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
