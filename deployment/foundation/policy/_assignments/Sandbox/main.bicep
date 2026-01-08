targetScope = 'managementGroup'

param location string = deployment().location
param sandboxManagementId string

param policyEnforcementEnabled bool

var customPolicyDefinitionsArray = [
  {
    name: 'Deny-VNet-Peer-Cross-Sub'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-VNet-Peer-Cross-Sub.json'))
  }
  {
    name: 'Deny-RG-Missing-Tags'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-RG-Missing-Tags.json'))
  }
]

var customPolicySetDefinitionsArray = [
  {
    name: 'Enforce-ALZ-Sandbox'
    definition: json(loadTextContent('../../_policySetDefinitions/Enforce-ALZ-Sandbox.json'))
    requiredParameters: {
      listOfResourceTypesNotAllowed: {
        value: [
          'microsoft.network/virtualnetworkgateways'
          'microsoft.network/virtualwans'
          'microsoft.network/vpngateways'
          'microsoft.network/expressroutegateways'
        ]
      }
      effectNotAllowedResources: {
        value: 'Audit'
      }
      effectDenyVnetPeering: {
        value: 'Audit'
      }
      effectDenyRgMissingTags: {
        value: 'Audit'
      }
    }
  }
]

module customPolicyDefinitions '../../../../../modules/Microsoft.Authorization/policyDefinitions/deploy.bicep' = [for (policy, i) in customPolicyDefinitionsArray: {
  name: 'poldef${i}-${uniqueString(deployment().name)}'
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    metadata: policy.definition.properties.metadata
    mode: policy.definition.properties.mode
    parameters: policy.definition.properties.parameters
    policyRule: policy.definition.properties.policyRule
    location: location
  }
}]

module customPolicySetDefinitions '../../../../../modules/Microsoft.Authorization/policySetDefinitions/deploy.bicep' = [for (policy, i) in customPolicySetDefinitionsArray: {
  name: 'polsetdef${i}-${uniqueString(deployment().name)}'
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    metadata: policy.definition.properties.metadata
    parameters: policy.definition.properties.parameters
    policyDefinitions: policy.definition.properties.policyDefinitions
    location: location
  }
  dependsOn: [
    customPolicyDefinitions
  ]
}]

module customPolicySetAssignments '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in customPolicySetDefinitionsArray: {
  name: 'polsetassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(sandboxManagementId)
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    location: location
    policyDefinitionId: customPolicySetDefinitions[i].outputs.resourceId
    roleDefinitionIds: contains(customPolicySetDefinitions[i], 'roleDefinitionIds') ? customPolicyDefinitions[i].outputs.roleDefinitionIds : []
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]
