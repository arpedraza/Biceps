using './main.bicep'

param location = 'westeurope'
param agwResourceGroupName = 'rg-mrg-waf-nonprod-01'
param certResourceGroupName = 'rg-mrg-waf-certs-nonprod-01'
param vnetResourceGroupName = 'rg-mrg-network-prod-01'
param vnetName = 'vnet-mrg-shared-prod-westeu-01'
param subnetName = 'snet-mrg-shared-waf-non-prod-westeu-01'
param appGatewayName = 'agw-edge-waf-nonprod-01'
param keyVaultName = 'kv-edge-waf-nonprod-01'
param managedIdentityName = 'umi-edge-waf-nonprod-01'
param publicIP = {
  name: 'pip-agw-edge-waf-nonprod-01'
  publicIPAllocationMethod: 'Static'
  skuName: 'Standard'
  skuTier: 'Regional'
  zones: [
    1
    2
    3
  ]
  domainNameLabel: 'agwedgewafnonprod'
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
  privateIPAddress: '10.11.123.69'
  }
param redirectConfigurations = []
param authenticationCertificates = []
param autoscaleMaxCapacity = 16
param autoscaleMinCapacity = 2
param capacity = 1
param enableHttp2 = true
param diagnosticsSettings = [
  {
    name: 'all-logs-metrics'
    workspaceResourceId: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-logs-nonprod-01/providers/Microsoft.OperationalInsights/workspaces/law-edge-waf-nonprod-01'
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
    name: 'integration-acc-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.131.10'
        }
      ]
    }
  }
  {
    name: 'integration-tst-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.131.9'
        }
      ]
    }
  }
  {
    name: 'apex-dev-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.131.5'
        }
      ]
    }
  }
  {
    name: 'apex-test-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.131.5'
        }
      ]
    }
  }
  {
    name: 'ipos-doc-uat-backend'
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
  {
    name: 'step1207-test-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.54.7'
        }
      ]
    }
  }
  {
    name: 'step524-test-backend'
    properties: {
      backendAddresses: [
        {
          ipAddress: '10.11.54.6'
        }
      ]
    }
  }
]
param backendHttpSettingsCollection = [
  {
    name: 'integration-acc-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'integration-acc-probe'
  }
  {
    name: 'integration-tst-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'integration-tst-probe'
  }
  {
    name: 'apex-dev-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Enabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'apex-dev-probe'
  }
  {
    name: 'apex-test-backend-settings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: 'Enabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'apex-test-probe'
  }
  {
    name: 'ipos-doc-uat-backend-settings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: 'Enabled'
      affinityCookieName: 'ApplicationGatewayAffinity'
      pickHostNameFromBackendAddress: true
      requestTimeout: 120
    }
    probeName: 'ipos-doc-uat-probe'
  }
  {
    name: 'step1207-test-backend-settings'
    properties: {
      port: 8080
      protocol: 'http'
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'step1207-test-probe'
  }
  {
    name: 'step524-test-backend-settings'
    properties: {
      port: 8080
      protocol: 'http'
      cookieBasedAffinity: 'Disabled'
      pickHostNameFromBackendAddress: false
      requestTimeout: 120
    }
    probeName: 'step524-test-probe'
  }
]
param probes = [
  {
    name: 'integration-acc-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Https'
      host: 'integration-acc.euroports.com'
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
    name: 'integration-tst-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'Https'
      host: 'integration-tst.euroports.com'
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
    name: 'apex-dev-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/ords-dev'
      protocol: 'Http'
      host: 'apex-dev.euroports.com'
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
    name: 'apex-test-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/ords-test'
      protocol: 'Http'
      host: 'apex-tst.euroports.com'
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
    name: 'ipos-doc-uat-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: true
      path: '/ipos'
      protocol: 'Https'
      host: ''
      unhealthyThreshold: 3
      interval: 30
      timeout: 120
      match: {
        statusCodes: [
          '301-302'
        ]
      }
    }
  }
  {
    name: 'step1207-test-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'http'
      host: 'step1207-test.euroports.com'
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
    name: 'step524-test-probe'
    properties: {
      pickHostNameFromBackendHttpSettings: false
      path: '/'
      protocol: 'http'
      host: 'step524-test.euroports.com'
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
    name: 'integration-acc.euroports.com_443'
    frontendIPConfiguration: 'public'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'integration-acc.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-integration-acc'
  }
  {
    name: 'integration-tst.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'integration-tst.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-integration-tst'
  }
  {
    name: 'apex-dev.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'apex-dev.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-apex-dev'
  }
  {
    name: 'apex-test.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'apex-tst.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-apex-test'
  }
  {
    name: 'tos-uat.euroports.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'tos-uat.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-ipos-doc-uat'
  }
  {
    name: 'step1207-test.europort.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'step1207-test.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-test-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-step1207-test'
  }
  {
    name: 'step524-test.europort.com_443'
    frontendIPConfiguration: 'private'
    frontendPort: 443
    sslCertificateName: 'euroports-wildcard'
    hostName: 'step524-test.euroports.com'
    requireServerNameIndication: true
    firewallPolicy: '/subscriptions/9c9c8305-0566-47cb-9b82-5dcf99bed903/resourceGroups/rg-mrg-waf-nonprod-test-01/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/waf-policy-step524-test'
  }

]
param requestRoutingRules = [
  {
    name: 'integration-acc.euroports.com_443'
    backendAddressPool: 'integration-acc-backend'
    backendHttpSettings: 'integration-acc-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'integration-acc.euroports.com_443'
    urlPathMap: ''
    priority: 1
    ruleType: 'Basic'
  }
  {
    name: 'integration-tst.euroports.com_443'
    backendAddressPool: 'integration-tst-backend'
    backendHttpSettings: 'integration-tst-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'integration-tst.euroports.com_443'
    urlPathMap: ''
    priority: 2
    ruleType: 'Basic'
  }
  {
    name: 'apex-dev.euroports.com_443'
    backendAddressPool: 'apex-dev-backend'
    backendHttpSettings: 'apex-dev-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'apex-dev.euroports.com_443'
    urlPathMap: ''
    priority: 3
    ruleType: 'Basic'
  }
  {
    name: 'apex-test.euroports.com_443'
    backendAddressPool: 'apex-test-backend'
    backendHttpSettings: 'apex-test-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'apex-test.euroports.com_443'
    urlPathMap: ''
    priority: 4
    ruleType: 'Basic'
  }
  {
    name: 'tos-uat.euroports.com_443'
    backendAddressPool: 'ipos-doc-uat-backend'
    backendHttpSettings: 'ipos-doc-uat-backend-settings'
    rewriteRuleSet: 'ipos-doc-uat-rewrite'
    redirectConfiguration: ''
    httpListener: 'tos-uat.euroports.com_443'
    urlPathMap: ''
    priority: 5
    ruleType: 'Basic'
  }
  {
    name: 'step1207-test.europort.com_443'
    backendAddressPool: 'step1207-test-backend'
    backendHttpSettings: 'step1207-test-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'step1207-test.europort.com_443'
    urlPathMap: ''
    priority: 6
    ruleType: 'Basic'
  }
  {
    name: 'step524-test.europort.com_443'
    backendAddressPool: 'step524-test-backend'
    backendHttpSettings: 'step524-test-backend-settings'
    rewriteRuleSet: ''
    redirectConfiguration: ''
    httpListener: 'step524-test.europort.com_443'
    urlPathMap: ''
    priority: 7
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
    name: 'integration-acc'
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
    name: 'integration-tst'
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
    name: 'apex-dev'
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
    name: 'apex-test'
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
    name: 'ipos-doc-uat'
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
    name: 'step1207-test'
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
    name: 'step524-test'
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
    name: 'ipos-doc-uat-rewrite'
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
          name: 'RedirectIPOSPath'
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
