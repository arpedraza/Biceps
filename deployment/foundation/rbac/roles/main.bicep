targetScope = 'managementGroup'

param roles array

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' = [ for role in roles : {
  name: guid(role.name)
  properties: {
    roleName: role.name
    description: role.description
    type: 'customRole'
    permissions: [
      {
        actions: role.actions
        notActions: role.notActions
      }
    ]
    assignableScopes: role.scope
  }
}]
