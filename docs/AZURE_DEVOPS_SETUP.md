# Azure DevOps Setup Guide

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step 1: Azure Service Connections](#step-1-azure-service-connections)
- [Step 2: Variable Groups](#step-2-variable-groups)
- [Step 3: Environments and Approvals](#step-3-environments-and-approvals)
- [Step 4: Pipeline Setup](#step-4-pipeline-setup)
- [Step 5: First Deployment](#step-5-first-deployment)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Overview

This guide provides step-by-step instructions for setting up Azure DevOps pipelines to deploy the Bicep infrastructure solution. The setup supports:

- ✅ Multi-stage deployments across dev, test, UAT, and production
- ✅ Automated validation and what-if analysis
- ✅ Manual approval gates for sensitive environments
- ✅ Multi-subscription deployments
- ✅ Reusable pipeline templates

**Estimated Setup Time:** 30-45 minutes

---

## Prerequisites

Before starting, ensure you have:

### Azure Requirements
- [ ] Azure subscription(s) with Owner or Contributor access
- [ ] Azure AD permissions to create service principals
- [ ] Resource providers registered (Microsoft.Compute, Microsoft.Network, Microsoft.Storage)

### Azure DevOps Requirements
- [ ] Azure DevOps organization
- [ ] Azure DevOps project created
- [ ] Project Administrator or Build Administrator permissions
- [ ] Azure Repos Git repository containing this Bicep solution

### Local Requirements (Optional)
- [ ] Azure CLI installed
- [ ] Git installed
- [ ] Access to Azure Portal

---

## Step 1: Azure Service Connections

Service connections allow Azure DevOps to authenticate with Azure subscriptions. You'll need one service connection per subscription/environment.

### 1.1 Understanding Service Connection Strategy

Choose one of these strategies:

#### Strategy A: Single Subscription (Simple)
Use one service connection for all environments. Resources are separated by resource groups.

```
Azure Subscription
├── Dev Resource Groups
├── Test Resource Groups
├── UAT Resource Groups
└── Prod Resource Groups
```

**Best for:** Small teams, development/testing, single subscription scenarios

#### Strategy B: Multi-Subscription (Recommended for Production)
Use separate subscriptions and service connections for each environment.

```
Dev Subscription ──> azureServiceConnection-dev
Test Subscription ──> azureServiceConnection-test
UAT Subscription ──> azureServiceConnection-uat
Prod Subscription ──> azureServiceConnection-prod
```

**Best for:** Enterprise deployments, production workloads, compliance requirements

### 1.2 Create Service Connection via Azure Portal

Follow these steps for each environment:

#### Option 1: Automatic (Recommended)

1. **Navigate to Azure DevOps Project Settings**
   - Go to: `https://dev.azure.com/{YourOrg}/{YourProject}`
   - Click **Project Settings** (bottom left)
   - Select **Service connections** under Pipelines

2. **Create New Service Connection**
   - Click **New service connection**
   - Select **Azure Resource Manager**
   - Click **Next**

3. **Choose Authentication Method**
   - Select **Service principal (automatic)**
   - Click **Next**

4. **Configure Connection**
   ```
   Subscription: [Select your Azure subscription]
   Resource group: [Leave empty for subscription-level access]
   Service connection name: azureServiceConnection-dev
   Description: Service connection for Dev environment
   Grant access permission to all pipelines: ✓ (Check this for now)
   ```
   
5. **Click Save**

6. **Repeat for each environment:**
   - `azureServiceConnection-dev`
   - `azureServiceConnection-test`
   - `azureServiceConnection-uat`
   - `azureServiceConnection-prod`

#### Option 2: Manual Service Principal (Advanced)

If automatic creation fails or you need more control:

1. **Create Service Principal in Azure**

   ```bash
   # Login to Azure
   az login
   
   # Set subscription
   az account set --subscription "<subscription-id>"
   
   # Create service principal
   az ad sp create-for-rbac \
     --name "sp-azdo-bicep-dev" \
     --role "Contributor" \
     --scopes "/subscriptions/<subscription-id>"
   ```
   
   **Save the output:**
   ```json
   {
     "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "displayName": "sp-azdo-bicep-dev",
     "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```

2. **Create Service Connection in Azure DevOps**
   - Choose **Service principal (manual)**
   - Fill in details:
     ```
     Environment: Azure Cloud
     Scope Level: Subscription
     Subscription Id: <your-subscription-id>
     Subscription Name: <your-subscription-name>
     Service Principal Id: <appId from above>
     Service Principal key: <password from above>
     Tenant ID: <tenant from above>
     Service connection name: azureServiceConnection-dev
     ```

3. **Click Verify** to test connection
4. **Click Save**

### 1.3 Assign Permissions to Service Principal

The service principal needs appropriate permissions:

```bash
# For subscription-level deployments (recommended)
az role assignment create \
  --assignee "<appId>" \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"

# Additional role for managing user-assigned identities
az role assignment create \
  --assignee "<appId>" \
  --role "Managed Identity Operator" \
  --scope "/subscriptions/<subscription-id>"
```

### 1.4 Verify Service Connections

Test each service connection:

1. Go to **Service connections**
2. Click on each connection
3. Click **Verify** button
4. Ensure status shows **Ready**

---

## Step 2: Variable Groups

Variable groups store configuration values used across pipelines. They support:
- Environment-specific settings
- Secrets (masked variables)
- Subscription IDs, resource names, locations

### 2.1 Create Variable Groups

You'll create 5 variable groups:

1. **bicep-common** - Shared across all environments
2. **bicep-dev** - Dev-specific variables
3. **bicep-test** - Test-specific variables
4. **bicep-uat** - UAT-specific variables
5. **bicep-prod** - Production-specific variables

### 2.2 Step-by-Step Creation

1. **Navigate to Library**
   - Go to **Pipelines** > **Library**
   - Click **+ Variable group**

2. **Create "bicep-common" Group**

   ```
   Variable group name: bicep-common
   Description: Common variables for all environments
   
   Variables:
   ┌────────────────────────────────────┬──────────────────────────────┐
   │ Name                               │ Value                        │
   ├────────────────────────────────────┼──────────────────────────────┤
   │ azureLocation                      │ eastus                       │
   │ deploymentScope                    │ subscription                 │
   │ vmImageName                        │ ubuntu-latest                │
   │ bicepVersion                       │ latest                       │
   │ defaultTags                        │ {"ManagedBy": "AzureDevOps"} │
   └────────────────────────────────────┴──────────────────────────────┘
   ```

   - Click **Save**

3. **Create "bicep-dev" Group**

   ```
   Variable group name: bicep-dev
   Description: Development environment variables
   
   Variables:
   ┌────────────────────────────────────┬────────────────────────────────────┐
   │ Name                               │ Value                              │
   ├────────────────────────────────────┼────────────────────────────────────┤
   │ azureServiceConnection             │ azureServiceConnection-dev         │
   │ azureSubscriptionId                │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx │
   │ azureSubscriptionName              │ Dev Subscription                   │
   │ environment                        │ dev                                │
   │ resourceGroupLocation              │ eastus                             │
   │ vmSize                             │ Standard_B2s                       │
   │ enableBackup                       │ false                              │
   │ enableMonitoring                   │ true                               │
   │ logRetentionDays                   │ 30                                 │
   │ adminUsername                      │ azureuser                          │
   │ adminPassword                      │ *** (secret - see below)           │
   └────────────────────────────────────┴────────────────────────────────────┘
   ```

   **For secrets (adminPassword):**
   - Click **Add** > Select variable
   - Name: `adminPassword`
   - Value: `<your-secure-password>`
   - Check **🔒 Keep this value secret**
   - Click **OK**

   - Click **Save**

4. **Create "bicep-test" Group**

   ```
   Variable group name: bicep-test
   Description: Test environment variables
   
   Variables:
   ┌────────────────────────────────────┬────────────────────────────────────┐
   │ Name                               │ Value                              │
   ├────────────────────────────────────┼────────────────────────────────────┤
   │ azureServiceConnection             │ azureServiceConnection-test        │
   │ azureSubscriptionId                │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx │
   │ azureSubscriptionName              │ Test Subscription                  │
   │ environment                        │ test                               │
   │ resourceGroupLocation              │ eastus                             │
   │ vmSize                             │ Standard_B2ms                      │
   │ enableBackup                       │ false                              │
   │ enableMonitoring                   │ true                               │
   │ logRetentionDays                   │ 30                                 │
   │ adminUsername                      │ azureuser                          │
   │ adminPassword                      │ *** (secret)                       │
   └────────────────────────────────────┴────────────────────────────────────┘
   ```

5. **Create "bicep-uat" Group**

   ```
   Variable group name: bicep-uat
   Description: UAT environment variables
   
   Variables:
   ┌────────────────────────────────────┬────────────────────────────────────┐
   │ Name                               │ Value                              │
   ├────────────────────────────────────┼────────────────────────────────────┤
   │ azureServiceConnection             │ azureServiceConnection-uat         │
   │ azureSubscriptionId                │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx │
   │ azureSubscriptionName              │ UAT Subscription                   │
   │ environment                        │ uat                                │
   │ resourceGroupLocation              │ eastus                             │
   │ vmSize                             │ Standard_D2s_v3                    │
   │ enableBackup                       │ true                               │
   │ enableMonitoring                   │ true                               │
   │ logRetentionDays                   │ 60                                 │
   │ adminUsername                      │ azureuser                          │
   │ adminPassword                      │ *** (secret)                       │
   └────────────────────────────────────┴────────────────────────────────────┘
   ```

6. **Create "bicep-prod" Group**

   ```
   Variable group name: bicep-prod
   Description: Production environment variables
   
   Variables:
   ┌────────────────────────────────────┬────────────────────────────────────┐
   │ Name                               │ Value                              │
   ├────────────────────────────────────┼────────────────────────────────────┤
   │ azureServiceConnection             │ azureServiceConnection-prod        │
   │ azureSubscriptionId                │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx │
   │ azureSubscriptionName              │ Production Subscription            │
   │ environment                        │ prod                               │
   │ resourceGroupLocation              │ eastus                             │
   │ vmSize                             │ Standard_D4s_v3                    │
   │ enableBackup                       │ true                               │
   │ enableMonitoring                   │ true                               │
   │ logRetentionDays                   │ 90                                 │
   │ adminUsername                      │ azureuser                          │
   │ adminPassword                      │ *** (secret)                       │
   │ backupRetentionDays                │ 30                                 │
   │ alertEmailAddress                  │ ops-team@company.com               │
   └────────────────────────────────────┴────────────────────────────────────┘
   ```

### 2.3 Variable Group Security

**Important Security Settings:**

1. **Control Access to Variable Groups**
   - Open each variable group
   - Click **Pipeline permissions**
   - Restrict which pipelines can use the group
   - For prod: Only allow production pipelines

2. **Use Azure Key Vault for Secrets (Recommended)**
   
   Instead of storing secrets directly:
   
   ```bash
   # Create Key Vault
   az keyvault create \
     --name kv-bicep-secrets \
     --resource-group rg-shared-services \
     --location eastus
   
   # Add secrets
   az keyvault secret set \
     --vault-name kv-bicep-secrets \
     --name "dev-admin-password" \
     --value "<secure-password>"
   ```
   
   Then in Azure DevOps:
   - Create variable group
   - Choose **Link secrets from an Azure key vault as variables**
   - Select your Key Vault
   - Authorize the service connection
   - Select secrets to import

---

## Step 3: Environments and Approvals

Environments provide:
- Deployment history
- Manual approval gates
- Security restrictions
- Environment-specific variables

### 3.1 Create Environments

1. **Navigate to Environments**
   - Go to **Pipelines** > **Environments**
   - Click **Create environment**

2. **Create Development Environment**
   ```
   Name: Development
   Description: Development environment (auto-deploy)
   Resource: None (select this)
   ```
   - Click **Create**

3. **Create Test Environment**
   ```
   Name: Test
   Description: Test environment (auto-deploy)
   Resource: None
   ```
   - Click **Create**

4. **Create UAT Environment**
   ```
   Name: UAT
   Description: UAT environment (requires approval)
   Resource: None
   ```
   - Click **Create**

5. **Create Production Environment**
   ```
   Name: Production
   Description: Production environment (requires approval)
   Resource: None
   ```
   - Click **Create**

### 3.2 Configure Approval Gates

For UAT and Production environments:

1. **Open Environment** (e.g., Production)
2. Click the **⋮** menu > **Approvals and checks**
3. Click **+** to add a check
4. Select **Approvals**

   **Configure Approvals:**
   ```
   Approvers: [Add users/groups who can approve]
   Instructions: 
     Please review:
     1. What-if analysis results
     2. Test environment validation
     3. Change management ticket
   
   Advanced:
   ☑ Approvers can approve their own runs
   ☐ Reassign to requestor when no approvers found
   Timeout: 24 hours
   ```

5. **Add Business Hours Check** (Optional)
   - Click **+** again
   - Select **Business hours**
   - Configure allowed deployment windows

6. **Add Branch Control** (Optional)
   - Click **+**
   - Select **Branch control**
   - Allowed branches: `refs/heads/main`

### 3.3 Additional Environment Security

1. **Restrict Pipeline Access**
   - In environment, go to **⋮** > **Security**
   - Add users/groups with appropriate roles:
     - **Administrator**: Full control
     - **User**: Can deploy
     - **Reader**: View only

2. **Add Deployment Policies**
   - Set maximum number of parallel deployments
   - Configure deployment order

---

## Step 4: Pipeline Setup

### 4.1 Choose Your Pipeline

Select the appropriate pipeline for your needs:

| Pipeline File | Use Case |
|--------------|----------|
| `azure-pipelines-enhanced.yml` | Full multi-environment deployment with all stages |
| `pipelines/examples/single-environment-pipeline.yml` | Deploy to dev only |
| `pipelines/examples/hotfix-pipeline.yml` | Emergency production fixes |
| `pipelines/examples/multi-application-pipeline.yml` | Deploy multiple applications |
| `pipelines/examples/pr-validation-pipeline.yml` | Validate pull requests |

### 4.2 Create Pipeline

1. **Navigate to Pipelines**
   - Go to **Pipelines** > **Pipelines**
   - Click **New pipeline**

2. **Select Repository**
   - Choose **Azure Repos Git**
   - Select your repository

3. **Configure Pipeline**
   - Select **Existing Azure Pipelines YAML file**
   - Branch: `main`
   - Path: `/azure-pipelines-enhanced.yml` (or your chosen pipeline)
   - Click **Continue**

4. **Review and Customize**
   
   Update these sections if needed:
   
   ```yaml
   # Update application name if different
   parameters:
     - name: applicationName
       default: 'step'  # Change to your application name
   
   # Update variable groups if named differently
   variables:
     - group: 'bicep-common'
     - group: 'bicep-dev'
     # ...
   ```

5. **Save Pipeline**
   - Click **Save and run** dropdown
   - Select **Save**
   - Commit directly to main branch

6. **Rename Pipeline** (Optional)
   - Click **⋮** menu next to Run
   - Select **Rename/move**
   - New name: `Bicep Infrastructure - Multi-Environment`

### 4.3 Pipeline Variables

You can override pipeline variables:

1. **Edit Pipeline**
2. Click **Variables** button
3. Add pipeline-specific variables:
   ```
   Name: pipelineVariable
   Value: value
   Let users override this value when running this pipeline: ☑
   Keep this value secret: ☐
   ```

### 4.4 Create Additional Pipelines

Create separate pipelines for different scenarios:

#### Hotfix Pipeline
```
Name: Hotfix Deployment
Path: /pipelines/examples/hotfix-pipeline.yml
Trigger: Manual only
```

#### PR Validation Pipeline
```
Name: PR Validation
Path: /pipelines/examples/pr-validation-pipeline.yml
Trigger: Pull request to main/develop
```

---

## Step 5: First Deployment

### 5.1 Pre-Deployment Checklist

Before running your first deployment:

- [ ] All service connections created and verified
- [ ] All variable groups created with correct values
- [ ] All environments created
- [ ] Approval gates configured for UAT and Production
- [ ] Parameter files reviewed (applications/step/*/bicepparam)
- [ ] Azure subscriptions have required permissions
- [ ] Resource providers registered

### 5.2 Test Deployment to Dev

1. **Navigate to your pipeline**
2. Click **Run pipeline**
3. **Configure run:**
   ```
   Branch: main
   Parameters:
     - applicationName: step
     - environmentsToDeploy: dev (only)
     - skipValidation: false
     - skipWhatIf: false
     - deploymentMode: Standard
   ```
4. Click **Run**

### 5.3 Monitor Deployment

1. **Watch Pipeline Stages**
   - Build & Lint
   - Validate
   - Preview (What-If)
   - Deploy Dev

2. **Review What-If Results**
   - Click on **Preview** stage
   - Review changes to be deployed
   - Ensure only expected resources

3. **Check Deployment**
   - After completion, go to Azure Portal
   - Find resource group: `rg-step-dev-eas`
   - Verify resources created

### 5.4 Deploy to Additional Environments

Once dev deployment succeeds:

1. **Run pipeline again**
2. **Select more environments:**
   ```
   environmentsToDeploy: dev, test
   ```
3. **Deploy progressively:**
   - First: dev + test
   - Then: add uat
   - Finally: add prod

### 5.5 Production Deployment

For production:

1. **Ensure prerequisites met:**
   - [ ] Successfully deployed to dev, test, UAT
   - [ ] What-if analysis reviewed
   - [ ] Change management ticket created
   - [ ] Approvers notified

2. **Run pipeline with prod**
3. **Review approval:**
   - Pipeline will pause at UAT environment
   - Approver receives notification
   - Review deployment details
   - Approve or reject

4. **Monitor production deployment**
   - Watch for any errors
   - Review post-deployment verification
   - Check resource health in Azure Portal

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Service Connection Fails

**Error:** `The subscription could not be found`

**Solutions:**
- Verify subscription ID is correct
- Ensure service principal has access to subscription
- Check service principal hasn't expired
- Re-create service connection

```bash
# Check service principal
az ad sp show --id <appId>

# Check role assignments
az role assignment list --assignee <appId> --output table
```

#### Issue 2: Variable Group Not Found

**Error:** `Variable group 'bicep-dev' could not be found`

**Solutions:**
- Verify variable group name matches exactly (case-sensitive)
- Check variable group permissions
- Ensure pipeline has access to variable group

#### Issue 3: Template Validation Fails

**Error:** `Template validation failed`

**Solutions:**
- Check Bicep syntax: `az bicep build --file main.bicep`
- Verify parameter file matches template parameters
- Ensure all required parameters provided
- Check parameter values are valid (e.g., VM sizes available in region)

#### Issue 4: Deployment Fails - Insufficient Permissions

**Error:** `The client does not have authorization to perform action`

**Solutions:**
```bash
# Grant Contributor role
az role assignment create \
  --assignee <service-principal-id> \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"

# Grant User Access Administrator if managing identities
az role assignment create \
  --assignee <service-principal-id> \
  --role "User Access Administrator" \
  --scope "/subscriptions/<subscription-id>"
```

#### Issue 5: Resource Already Exists

**Error:** `Resource already exists`

**Solutions:**
- Use `existing` keyword in Bicep for existing resources
- Delete existing resources if intentional
- Ensure deployment name is unique
- Check for stuck deployments: `az deployment sub list`

#### Issue 6: Agent Timeout

**Error:** `Job execution exceeded timeout`

**Solutions:**
- Increase job timeout in YAML:
  ```yaml
  jobs:
    - job: Deploy
      timeoutInMinutes: 120  # Default is 60
  ```
- Deploy fewer resources at once
- Check for hung resources in Azure

#### Issue 7: Approval Not Received

**Problem:** No email notification for approval

**Solutions:**
- Check email settings in Azure DevOps
- Add approvers to environment settings
- Manually check Pipelines > Environments > [Environment] > View history
- Use Azure DevOps notifications settings

---

## Best Practices

### 1. Pipeline Organization

```
Repository Structure:
/azure-pipelines-enhanced.yml          # Main multi-env pipeline
/pipelines/
  /templates/                           # Reusable templates
    lint-template.yml
    validate-template.yml
    whatif-template.yml
    deploy-template.yml
  /examples/                            # Example pipelines
    single-environment-pipeline.yml
    hotfix-pipeline.yml
```

### 2. Variable Management

✅ **Do:**
- Use variable groups for environment-specific values
- Store secrets in Azure Key Vault
- Use descriptive variable names
- Document variables in README

❌ **Don't:**
- Hardcode values in YAML
- Store secrets in plain text
- Use ambiguous variable names
- Share production credentials

### 3. Approval Process

**Development/Test:**
- Auto-deploy on successful build
- No manual approval required

**UAT:**
- Require approval from QA team
- Auto-deploy if tests pass

**Production:**
- Require approval from:
  - Operations team
  - Application owner
  - Security team (if required)
- Include change management ticket reference

### 4. Pipeline Triggers

```yaml
# Main pipeline - auto trigger
trigger:
  branches:
    include: [main]
  paths:
    include: [applications/**, modules/**]
    exclude: [docs/**, README.md]

# Feature branches - PR validation only
pr:
  branches:
    include: [main, develop]

# Hotfix pipeline - manual only
trigger: none
pr: none
```

### 5. Deployment Strategy

**Progressive Deployment:**
```
Dev → Test → UAT → Production
 ↓      ↓      ↓       ↓
Auto  Auto  Manual  Manual
```

**Blue-Green Deployment:**
- Deploy to new resources
- Test new environment
- Switch traffic
- Keep old resources for rollback

**Canary Deployment:**
- Deploy to subset of resources
- Monitor for issues
- Gradually increase deployment
- Roll back if problems detected

### 6. Monitoring and Alerts

Set up monitoring for:
- Pipeline failures
- Deployment duration
- Resource health
- Cost anomalies

```yaml
# Add monitoring task
- task: AzureCLI@2
  displayName: 'Configure Monitoring'
  inputs:
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Set up alerts
      az monitor metrics alert create \
        --name "High CPU Alert" \
        --resource-group $RG_NAME \
        --scopes $VM_ID \
        --condition "avg Percentage CPU > 80" \
        --window-size 5m \
        --evaluation-frequency 1m
```

### 7. Rollback Strategy

Always have a rollback plan:

```yaml
# Save deployment state
- task: AzureCLI@2
  displayName: 'Backup Current State'
  inputs:
    inlineScript: |
      # Export current resources
      az resource list \
        --resource-group $RG_NAME \
        --output json > backup-state.json

# Rollback task (if needed)
- task: AzureCLI@2
  displayName: 'Rollback Deployment'
  condition: failed()
  inputs:
    inlineScript: |
      # Delete new resources
      # Restore from backup
```

### 8. Documentation

Maintain documentation for:
- [ ] Service connection setup
- [ ] Variable group definitions
- [ ] Approval process
- [ ] Deployment procedures
- [ ] Rollback procedures
- [ ] Troubleshooting guides

### 9. Security

**Principle of Least Privilege:**
- Grant minimum permissions needed
- Use separate service principals per environment
- Regularly rotate secrets
- Audit access logs

**Secret Management:**
```yaml
# Use Key Vault
- task: AzureKeyVault@2
  inputs:
    azureSubscription: $(azureServiceConnection)
    KeyVaultName: 'kv-bicep-secrets'
    SecretsFilter: '*'
    RunAsPreJob: true
```

### 10. Cost Management

Monitor and control costs:
- Tag all resources with cost center
- Set up budget alerts
- Auto-shutdown dev/test resources
- Use appropriate VM sizes per environment

```yaml
# Add cost tags
tags:
  CostCenter: "IT-Infrastructure"
  Environment: "$(environment)"
  ManagedBy: "AzureDevOps"
  Project: "$(applicationName)"
  Owner: "$(Build.RequestedFor)"
```

---

## Next Steps

After completing setup:

1. ✅ Run first deployment to dev
2. ✅ Verify resources in Azure Portal
3. ✅ Test VM connectivity
4. ✅ Review costs in Azure Cost Management
5. ✅ Document any custom changes
6. ✅ Train team on deployment process
7. ✅ Set up monitoring and alerts
8. ✅ Plan production deployment

---

## Additional Resources

- [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops/)
- [Azure Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Service Connection Setup](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Variable Groups](https://docs.microsoft.com/azure/devops/pipelines/library/variable-groups)
- [Environments and Approvals](https://docs.microsoft.com/azure/devops/pipelines/process/environments)

---

## Support

For issues or questions:
- Check [Troubleshooting](#troubleshooting) section
- Review pipeline logs in Azure DevOps
- Check Azure deployment logs in Portal
- Contact your Azure administrator

---

**Document Version:** 1.0  
**Last Updated:** January 2025  
**Maintained By:** DevOps Team
