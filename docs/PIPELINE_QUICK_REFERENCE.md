# Pipeline Quick Reference

## 🚀 Quick Commands

### Deploy to Development Only
```yaml
Pipeline: Single Environment Pipeline
Branch: develop
Auto-triggered: Yes
```

### Deploy All Environments
```yaml
Pipeline: Multi-Environment Pipeline
Branch: main
Parameters:
  applicationName: step
  environmentsToDeploy: [dev, test, uat, prod]
```

### Emergency Hotfix
```yaml
Pipeline: Hotfix Pipeline
Trigger: Manual
Parameters:
  targetEnvironment: prod
  justification: "Critical fix for [issue]"
  changeTicketNumber: CHG-XXXXX
```

---

## 📊 Pipeline Overview

| Pipeline | File | Trigger | Environments | Approvals |
|----------|------|---------|--------------|------------|
| Multi-Environment | `azure-pipelines-enhanced.yml` | Auto (main) | All | UAT, Prod |
| Single Environment | `pipelines/examples/single-environment-pipeline.yml` | Auto (develop) | Dev | None |
| Hotfix | `pipelines/examples/hotfix-pipeline.yml` | Manual | Any | Required |
| Multi-Application | `pipelines/examples/multi-application-pipeline.yml` | Auto (main) | Configurable | Based on env |
| PR Validation | `pipelines/examples/pr-validation-pipeline.yml` | PR | None (validate only) | None |

---

## 🔧 Variable Groups

### Common Variables (bicep-common)
```yaml
azureLocation: eastus
deploymentScope: subscription
vmImageName: ubuntu-latest
```

### Environment-Specific Variables

#### bicep-dev
```yaml
azureServiceConnection: azureServiceConnection-dev
environment: dev
vmSize: Standard_B2s
enableBackup: false
```

#### bicep-test
```yaml
azureServiceConnection: azureServiceConnection-test
environment: test
vmSize: Standard_B2ms
enableBackup: false
```

#### bicep-uat
```yaml
azureServiceConnection: azureServiceConnection-uat
environment: uat
vmSize: Standard_D2s_v3
enableBackup: true
```

#### bicep-prod
```yaml
azureServiceConnection: azureServiceConnection-prod
environment: prod
vmSize: Standard_D4s_v3
enableBackup: true
alertEmailAddress: ops@company.com
```

---

## 🎯 Stage Execution Times

| Stage | Duration | Notes |
|-------|----------|-------|
| Build & Lint | 2-3 min | Fast |
| Validate | 1-2 min per env | Parallel |
| Preview (What-If) | 2-3 min per env | Parallel |
| Deploy Dev | 10-15 min | VM deployment |
| Deploy Test | 10-15 min | VM deployment |
| Deploy UAT | 10-15 min + approval | Manual gate |
| Deploy Prod | 15-20 min + approval | Enhanced verification |

**Total Time (All Environments):** ~45-60 minutes + approval time

---

## 🔐 Service Connections

### Required Connections
```
azureServiceConnection-dev   → Dev Subscription
azureServiceConnection-test  → Test Subscription
azureServiceConnection-uat   → UAT Subscription  
azureServiceConnection-prod  → Prod Subscription
```

### Permissions Needed
```
Role: Contributor (subscription level)
Additional: Managed Identity Operator
```

---

## 🌍 Environments

| Environment | Approval | Timeout | Approvers |
|-------------|----------|---------|------------|
| Development | No | - | - |
| Test | No | - | - |
| UAT | Yes | 24 hours | QA Team |
| Production | Yes | 24 hours | Ops Team, App Owner |

---

## 📝 Common Pipeline Parameters

### Multi-Environment Pipeline
```yaml
applicationName: step
environmentsToDeploy:
  - dev      # Deploy to dev
  - test     # Deploy to test
  - uat      # Deploy to UAT (requires approval)
  - prod     # Deploy to prod (requires approval)
skipValidation: false
skipWhatIf: false
deploymentMode: Standard  # or HotFix, Rollback
```

### Hotfix Pipeline
```yaml
targetEnvironment: prod
applicationName: step
justification: "Emergency fix for [issue]"
changeTicketNumber: CHG-XXXXX
```

### Multi-Application Pipeline
```yaml
applications:
  - step
  - webapp
  - api
deploymentStrategy: Sequential  # or Parallel
targetEnvironment: dev
```

---

## 🎬 Template Usage

### Lint Template
```yaml
- template: pipelines/templates/lint-template.yml
  parameters:
    applicationPath: 'applications/step'
    modulesPath: 'modules'
    azureServiceConnection: $(azureServiceConnection)
```

### Validate Template
```yaml
- template: pipelines/templates/validate-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection-dev)
    deploymentScope: 'subscription'
```

### What-If Template
```yaml
- template: pipelines/templates/whatif-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection-dev)
    deploymentScope: 'subscription'
    resultFormat: 'ResourceIdOnly'
```

### Deploy Template
```yaml
- template: pipelines/templates/deploy-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection-dev)
    deploymentScope: 'subscription'
    runWhatIf: true
    verifyDeployment: true
```

---

## 🔍 Useful Azure CLI Commands

### Check Deployments
```bash
# List recent deployments
az deployment sub list \
  --query "[].{Name:name, State:properties.provisioningState, Timestamp:properties.timestamp}" \
  --output table

# Get deployment details
az deployment sub show \
  --name "step-dev-20250108-123456" \
  --query "properties.{State:provisioningState, Duration:duration, Outputs:outputs}"

# Get deployment errors
az deployment sub show \
  --name "step-dev-20250108-123456" \
  --query "properties.error"
```

### Check Resources
```bash
# List resources in resource group
az resource list \
  --resource-group "rg-step-dev-eas" \
  --output table

# Check VM status
az vm list \
  --resource-group "rg-step-dev-eas" \
  --show-details \
  --query "[].{Name:name, PowerState:powerState, ProvisioningState:provisioningState}" \
  --output table
```

### Manual Deployment
```bash
# Validate template
az deployment sub validate \
  --location eastus \
  --template-file applications/step/main.bicep \
  --parameters applications/step/dev/dev.bicepparam

# What-if analysis
az deployment sub what-if \
  --location eastus \
  --template-file applications/step/main.bicep \
  --parameters applications/step/dev/dev.bicepparam

# Deploy
az deployment sub create \
  --name "manual-deploy-$(date +%s)" \
  --location eastus \
  --template-file applications/step/main.bicep \
  --parameters applications/step/dev/dev.bicepparam
```

---

## 🚨 Troubleshooting Quick Fixes

### Pipeline Fails at Validation
```bash
# Check Bicep syntax
az bicep build --file applications/step/main.bicep

# Check parameter file
cat applications/step/dev/dev.bicepparam
```

### Service Connection Error
```bash
# Verify service principal
az ad sp show --id <app-id>

# Check role assignment
az role assignment list \
  --assignee <app-id> \
  --subscription <subscription-id> \
  --output table
```

### Resource Already Exists
```bash
# List existing resources
az resource list \
  --resource-group "rg-step-dev-eas" \
  --output table

# Delete if needed
az group delete \
  --name "rg-step-dev-eas" \
  --yes \
  --no-wait
```

### Deployment Timeout
```yaml
# Increase timeout in pipeline
jobs:
  - deployment: Deploy
    timeoutInMinutes: 180  # Default is 60
```

---

## 📞 Quick Links

- **Azure Portal:** https://portal.azure.com
- **Azure DevOps:** https://dev.azure.com/{YourOrg}
- **Project:** https://dev.azure.com/{YourOrg}/{YourProject}
- **Pipelines:** https://dev.azure.com/{YourOrg}/{YourProject}/_build
- **Environments:** https://dev.azure.com/{YourOrg}/{YourProject}/_environments
- **Library:** https://dev.azure.com/{YourOrg}/{YourProject}/_library

---

## 🎓 Learning Resources

- [Azure Bicep Docs](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure DevOps Pipelines](https://docs.microsoft.com/azure/devops/pipelines/)
- [YAML Pipeline Schema](https://docs.microsoft.com/azure/devops/pipelines/yaml-schema)

---

## 📋 Checklists

### Pre-Deployment Checklist
- [ ] Code reviewed and approved
- [ ] Parameter files updated
- [ ] Variable groups configured
- [ ] Service connections verified
- [ ] Approvers notified (for UAT/Prod)
- [ ] Change ticket created (for Prod)

### Post-Deployment Checklist
- [ ] Deployment succeeded
- [ ] Resources created in Azure Portal
- [ ] VMs running and accessible
- [ ] Monitoring configured
- [ ] Tags applied correctly
- [ ] Documentation updated
- [ ] Team notified

---

**Document Version:** 1.0  
**Last Updated:** January 2025
