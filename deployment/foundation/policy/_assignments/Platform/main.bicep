targetScope = 'managementGroup'

param location string = deployment().location
param platformManagementId string

param policyEnforcementEnabled bool

var builtInPolicyDefinitionsArray = [
  {
    name: 'LAW-Automation-Account'
    id: '/providers/Microsoft.Authorization/policyDefinitions/8e3e61b3-0b32-22d5-4edf-55f87fdb5955'
    parameters: json('{"workspaceRegion": {"value": "westeurope"},"automationRegion": {"value": "westeurope"}}')
  }
  {
    name: 'VM-backup-NoTag'
    id: '/providers/Microsoft.Authorization/policyDefinitions/98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86'
  }
  {
    name: 'Nic-no-public-IPs'
    id: '/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114'

  }
]

var customPolicyDefinitionsArray = [
  {
    name: 'Deny-Subnet-Without-Nsg'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-Subnet-Without-Nsg.json'))
  }
  {
    name: 'Deny-MgmtPorts-Internet'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-MgmtPorts-From-Internet.json'))
  }
]

var customPolicySetDefinitionsArray = []

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

module builtinPolicyAssignments '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in builtInPolicyDefinitionsArray :{
  name: 'polbuiltinassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(platformManagementId)
  params: {
    name: policy.name
    policyDefinitionId: policy.id
    location: location
    parameters: contains(policy, 'parameters') ? policy.parameters : {}
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]

module customPolicyAssignments '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in customPolicyDefinitionsArray: {
  name: 'polassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(platformManagementId)
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    location: location
    policyDefinitionId: customPolicyDefinitions[i].outputs.resourceId
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]

module customPolicySetAssignments '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in customPolicySetDefinitionsArray: {
  name: 'polsetassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(platformManagementId)
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    location: location
    policyDefinitionId: customPolicySetDefinitions[i].outputs.resourceId
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]
