targetScope = 'managementGroup'

param location string = deployment().location
param landingZoneManagementId string

param policyEnforcementEnabled bool

param builtInPolicyDefinitionsArray array = [
  {
    name: 'VM-backup-NoTag'
    id: '/providers/Microsoft.Authorization/policyDefinitions/98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86'
  }
  {
    name: 'Secure-Transfer-SA'
    id: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
  }
  {
    name: 'Nic-Disable-IPforw'
    id: '/providers/Microsoft.Authorization/policyDefinitions/88c0b9da-ce96-4b03-9635-f29a937e2900'
  }
]

var customPolicyDefinitionsArray = [
  {
    name: 'Deny-Subnet-Without-Nsg'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-Subnet-Without-Nsg.json'))
  }
  {
    name: 'Deny-MgmtPorts-From-Internet'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-MgmtPorts-From-Internet.json'))
  }
  {
    name: 'Append-AppService-httpsonly'
    definition: json(loadTextContent('../../_policyDefinitions/Append-AppService-httpsonly.json'))
  }
  {
    name: 'Append-AppService-latestTLS'
    definition: json(loadTextContent('../../_policyDefinitions/Append-AppService-latestTLS.json'))
  }
  {
    name: 'Deny-AppServiceApiApp-http'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-AppServiceApiApp-http.json'))
  }
  {
    name: 'Deny-AppServiceFunctionApp-http'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-AppServiceFunctionApp-http.json'))
  }
  {
    name: 'Deny-AppServiceWebApp-http'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-AppServiceWebApp-http.json'))
  }
  {
    name: 'Deploy-MySQL-sslEnforcement'
    definition: json(loadTextContent('../../_policyDefinitions/Deploy-MySQL-sslEnforcement.json'))
  }
  {
    name: 'Deny-MySql-http'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-MySql-http.json'))
  }
  {
    name: 'Deploy-PostgreSQL-sslEnforcement'
    definition: json(loadTextContent('../../_policyDefinitions/Deploy-PostgreSQL-sslEnforcement.json'))
  }
  {
    name: 'Deny-PostgreSql-http'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-PostgreSql-http.json'))
  }
  {
    name: 'Append-Redis-sslEnforcement'
    definition: json(loadTextContent('../../_policyDefinitions/Append-Redis-sslEnforcement.json'))
  }
  {
    name: 'Append-Redis-disableNonSslPort'
    definition: json(loadTextContent('../../_policyDefinitions/Append-Redis-disableNonSslPort.json'))
  }
  {
    name: 'Deny-Redis-http'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-Redis-http.json'))
  }
  {
    name: 'Deploy-SQL-minTLS'
    definition: json(loadTextContent('../../_policyDefinitions/Deploy-SQL-minTLS.json'))
  }
  {
    name: 'Deny-SqlMi-minTLS'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-SqlMi-minTLS.json'))
  }
  {
    name: 'Deploy-SqlMi-minTLS'
    definition: json(loadTextContent('../../_policyDefinitions/Deploy-SqlMi-minTLS.json'))
  }
  {
    name: 'Deny-Sql-minTLS'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-Sql-minTLS.json'))
  }
  {
    name: 'Deny-Storage-minTLS'
    definition: json(loadTextContent('../../_policyDefinitions/Deny-Storage-minTLS.json'))
  }
  {
    name: 'Deploy-Storage-sslEnforcement'
    definition: json(loadTextContent('../../_policyDefinitions/Deploy-Storage-sslEnforcement.json'))
  }
]

var customPolicySetDefinitionsArray = [
  {
    name: 'Enforce-EncryptTransit'
    definition: json(loadTextContent('../../_policySetDefinitions/Enforce-EncryptTransit.json'))
  }
  {
    name: 'Enforce-Guardrails-KV'
    definition: json(loadTextContent('../../_policySetDefinitions/Enforce-Guardrails-KeyVault.json'))
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

module mg_Customer_assign_builtin_policies '../../../../../modules/Microsoft.Authorization/policyAssignments/deploy.bicep' = [for (policy, i) in builtInPolicyDefinitionsArray :{
  name: 'polassig${i}-${uniqueString(deployment().name)}'
  scope: managementGroup(landingZoneManagementId)
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
  scope: managementGroup(landingZoneManagementId)
  params: {
    name: policy.name
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    location: location
    policyDefinitionId: customPolicySetDefinitions[i].outputs.resourceId
    enforcementMode: policyEnforcementEnabled ? 'Default' : 'DoNotEnforce'
  }
}]
