targetScope = 'managementGroup'

param location string = deployment().location
param corpManagementId string

param policyEnforcementEnabled bool

param builtInPolicyDefinitionsArray array = [
  {
    name: 'Nic-no-public-IPs'
    id: '/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114'

  }
  {
    name: 'Notallowedresources'
    id: '/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749'
    parameters: json('{"listOfResourceTypesNotAllowed": {"value": ["microsoft.network/virtualnetworkgateways","microsoft.network/virtualwans","microsoft.network/vpngateways","microsoft.network/expressroutegateways"]}}')
  }
]

var customPolicyDefinitionsArray = [
  {
    name: 'Audit-PrivateLinkDnsZones'
    definition: json(loadTextContent('../../../_policyDefinitions/Audit-PrivateLinkDnsZones.json'))
  }
]

var customPolicySetDefinitionsArray = [
  {
    name: 'Deny-PublicPaaSEndpoints'
    definition: json(loadTextContent('../../../_policySetDefinitions/Deny-PublicPaaSEndpoints.json'))
  }
  {
    name: 'Deploy-Private-DNS-Zones'
    definition: json(loadTextContent('../../../_policySetDefinitions/Deploy-Private-DNS-Zones.json'))
  }
]

module customPolicyDefinitions '../../../../../../modules/Microsoft.Authorization/policyDefinitions/deploy.bicep' = [for (policy, i) in customPolicyDefinitionsArray: {
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

module customPolicySetDefinitions '../../../../../../modules/Microsoft.Authorization/policySetDefinitions/deploy.bicep' = [for (policy, i) in customPolicySetDefinitionsArray: {
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

module mg_Customer_assign_builtin_policies '../../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in builtInPolicyDefinitionsArray :{
  name: 'polassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(corpManagementId)
  params: {
    name: policy.name
    policyDefinitionId: policy.id
    roleDefinitionIds: contains(policy, 'roleDefinitionId') ? policy.roleDefinitionId : []
    location: location
    parameters: contains(policy, 'parameters') ? policy.parameters : {}
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]

module customPolicySetAssignments '../../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in customPolicySetDefinitionsArray: {
  name: 'polsetassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(corpManagementId)
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    location: location
    policyDefinitionId: customPolicySetDefinitions[i].outputs.resourceId
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]
