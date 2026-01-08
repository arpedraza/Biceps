using './main.bicep'

param roles = [
  {
    name: 'Euroports - Azure Data Factory Operator'
    description: 'Euroports Custom Role - Can view, start and stop ADF pipelines.'
    actions: [
      'Microsoft.DataFactory/factories/pipelines/read'
      'Microsoft.DataFactory/factories/pipelines/createrun/*'
      'Microsoft.DataFactory/factories/pipelines/pipelineruns/*'
    ]
    notActions: []
    scope: [
      '/providers/Microsoft.Management/managementGroups/4f604bd1-00fb-4aae-b3a1-79091a246031'
    ]
    managementGroupId: '/providers/Microsoft.Management/managementGroups/4f604bd1-00fb-4aae-b3a1-79091a246031'
  }
]
