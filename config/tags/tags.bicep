// ============================================================================
// Tags Configuration Module
// ============================================================================
// This module generates consistent tags for resource governance
// ============================================================================

@description('Application name')
param applicationName string

@description('Environment')
param environment string

@description('Cost center')
param costCenter string = ''

@description('Owner email')
param ownerEmail string = ''

@description('Department')
param department string = ''

@description('Project name')
param projectName string = ''

@description('Additional custom tags')
param customTags object = {}

// ============================================================================
// Outputs: Standard Tags
// ============================================================================
@description('Standard tags for all resources')
output standardTags object = union({
  Application: applicationName
  Environment: environment
  ManagedBy: 'Bicep'
  DeploymentDate: utcNow('yyyy-MM-dd')
}, !empty(costCenter) ? { CostCenter: costCenter } : {}, !empty(ownerEmail) ? { Owner: ownerEmail } : {}, !empty(department) ? { Department: department } : {}, !empty(projectName) ? { Project: projectName } : {}, customTags)
