targetScope = 'subscription'

param location string
param environment string

param applicationName string
param agwOriginalPIPName string
param agwOriginalSubscriptionId string
param agwOriginalResourceGroupName string
param agwOriginalPriority int
param agwNewPIPName string
param agwNewResourceGroupName string
param agwNewPriority int
param healthProbePath string
param healthProbeHostValue string
param diagnosticsSettings array

var tier = environment == 'PROD' ? 'prod' : 'nonprod'

var tmResourceGroupName = toLower('rg-traffic-manager-${tier}-01')

resource OriginalAppGWPIP 'Microsoft.Network/publicIPAddresses@2024-07-01' existing = {
  name: agwOriginalPIPName
  scope: az.resourceGroup(agwOriginalSubscriptionId, agwOriginalResourceGroupName)
}

resource NewAppGWPIP 'Microsoft.Network/publicIPAddresses@2024-07-01' existing = {
  name: agwNewPIPName
  scope: az.resourceGroup(agwNewResourceGroupName)
}

module ResourceGroup 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: toLower('rg-traffic-manager-${environment}-deployment')
  params: {
    name: tmResourceGroupName
    location: location
    tags: {
      'Cost Allocation': 'GEN-EP'
      'Environment': environment
    }
  }
}

module trafficManager 'br/public:avm/res/network/trafficmanagerprofile:0.3.0' = {
  name: toLower('tm-${applicationName}-${environment}-deployment')
  scope: resourceGroup(tmResourceGroupName)
  dependsOn: [
    ResourceGroup
  ]
  params: {
    name: toLower('tm-${applicationName}-${environment}-${location}-01')
    relativeName: toLower('ep-${applicationName}-${environment}')
    trafficRoutingMethod: 'Priority'

    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: healthProbePath
      customHeaders: [
        {
          name: 'host'
          value: healthProbeHostValue
        }
      ]
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 399
        }
      ]
    }

    endpoints: [
      {
        name: 'Original App Gateway'
        properties: {
          targetResourceId: OriginalAppGWPIP.id
          endpointStatus: 'Enabled'
          priority: agwOriginalPriority
        }
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
      }
      {
        name: 'New App Gateway'
        properties: {
          targetResourceId: NewAppGWPIP.id
          endpointStatus: 'Enabled'
          priority: agwNewPriority
        }
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
      }
    ]
    diagnosticSettings: diagnosticsSettings
  }
}
