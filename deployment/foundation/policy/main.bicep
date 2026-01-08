targetScope = 'managementGroup'

param location string = deployment().location
param customerManagementId string= '<<managementGroupId-Customer>>'
param platformManagementId string = '<<managementGroupId-platform>>'
param landingZoneManagementId string = '<<managementGroupId-landingzone>>'
param corpManagementId string = '<<managementGroupId-corp>>'
param decommManagementId string = '<<managementGroupId-decommissioned>>'
param sandboxManagementId string = '<<managementGroupId-sandbox>>'

param policyEnforcementEnabled bool = false

module policiesIntermediateRoot '_assignments/IntermediateRoot/main.bicep' = {
  name: 'mod-IntemediateRoot'
  params: {
    location: location
    customerManagementId: customerManagementId
    policyEnforcementEnabled: policyEnforcementEnabled
  }
}

module platform '_assignments/Platform/main.bicep' = {
  name: 'mod-Connecitvity'
  params: {
    location: location
    platformManagementId: platformManagementId
    policyEnforcementEnabled: policyEnforcementEnabled
  }
}

module landingZones '_assignments/Landingzones/main.bicep' = {
  name: 'mod-LandingZones'
  params: {
    location: location
    landingZoneManagementId: landingZoneManagementId
    policyEnforcementEnabled: policyEnforcementEnabled
  }
}

module corpLandingZones '_assignments/Landingzones/Corp/main.bicep' = {
  name: 'mod-Corp'
  params: {
    location: location
    corpManagementId: corpManagementId
    policyEnforcementEnabled: policyEnforcementEnabled
  }
}

module decommissioned '_assignments/Decommissioned/main.bicep' = {
  name: 'mod-Decomm'
  params: {
    location: location
    decommManagementId: decommManagementId
    policyEnforcementEnabled: policyEnforcementEnabled
  }
}

module sandBox '_assignments/Sandbox/main.bicep' = {
  name: 'mod-Sandbox'
  params: {
    location: location
    sandboxManagementId: sandboxManagementId
    policyEnforcementEnabled: policyEnforcementEnabled
  }
}
