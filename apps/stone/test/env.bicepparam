using '../../../infra/rg-deploy.bicep'

param environmentKey = 'test'
param subscriptionKey = 'euroports-test-01'

param baseTags = {
  Environment: 'test'
  Owner: 'Andy Group IT'
  Responsible: 'Andy Infrastructure Team'
  AppStack: 'STONE'
}

param domainJoin = {
  enabled: false
  domainName: ''
  ouPath: ''
  username: ''
  password: ''
}
