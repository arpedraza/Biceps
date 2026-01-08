targetScope = 'managementGroup'

param location string = deployment().location
param customerManagementId string

param policyEnforcementEnabled bool

param builtInPolicySetDefinitionsArray array = [
  {
    name: 'Cloud_Security_Benchmark'
    id: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
  }
  {
    name: 'AZ_Activity_logs_LAW'
    id: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
    parameters: json('{"logAnalytics": {"value": "/subscriptions/572372b1-d391-476f-a2fb-bc9254fa6c0a/resourceGroups/Sentinel/providers/Microsoft.OperationalInsights/workspaces/lawsentinel001"}}')
  }
  {
    name: 'Audit_VM_Manag_Disks'
    id: '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'
  }
]

var customPolicyDefinitionsArray = [
  {
    name: 'Audit-Disks-UnusedResourcesCostOptimization'
    definition: json(loadTextContent('../../_policyDefinitions/Audit-Disks-UnusedResourcesCostOptimization.json'))
  }
  {
    name: 'Audit-PublicIpAddresses-UnusedResourcesCostOptimization'
    definition: json(loadTextContent('../../_policyDefinitions/Audit-PublicIpAddresses-UnusedResourcesCostOptimization.json'))
  }
  {
    name: 'Audit-ServerFarms-UnusedResourcesCostOptimization'
    definition: json(loadTextContent('../../_policyDefinitions/Audit-ServerFarms-UnusedResourcesCostOptimization.json'))
  }
]

var customPolicySetDefinitionsArray = [
  {
    name: 'Enforce-ACSB'
    definition: json(loadTextContent('../../_policySetDefinitions/Enforce-ACSB.json'))
  }
  {
    name: 'Audit-UnusedResources'
    definition: json(loadTextContent('../../_policySetDefinitions/Audit-UnusedResourcesCostOptimization.json'))
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

module mg_Customer_assign_builtin_policies '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in builtInPolicySetDefinitionsArray :{
  name: 'polassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(customerManagementId)
  params: {
    name: policy.name
    policyDefinitionId: policy.id
    roleDefinitionIds: contains(policy, 'roleDefinitionId') ? policy.roleDefinitionId : []
    location: location
    parameters: contains(policy, 'parameters') ? policy.parameters : {}
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]

module customPolicySetAssignments '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in customPolicySetDefinitionsArray: {
  name: 'polsetassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(customerManagementId)
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    location: location
    policyDefinitionId: customPolicySetDefinitions[i].outputs.resourceId
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]
