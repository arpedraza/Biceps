# Azure DevOps Pipelines

## 📚 Overview

This directory contains Azure DevOps pipeline configurations and templates for deploying Bicep infrastructure.

## 📁 Directory Structure

```
pipelines/
├── templates/              # Reusable pipeline templates
│   ├── lint-template.yml        # Bicep linting
│   ├── validate-template.yml    # Template validation
│   ├── whatif-template.yml      # What-if analysis
│   ├── deploy-template.yml      # Deployment
│   └── environment-deploy-template.yml  # Full environment orchestration
├── examples/              # Example pipelines
│   ├── single-environment-pipeline.yml   # Dev-only deployment
│   ├── hotfix-pipeline.yml               # Emergency deployments
│   ├── multi-application-pipeline.yml    # Multiple apps
│   └── pr-validation-pipeline.yml        # PR validation
└── README.md              # This file
```

## 🎯 Pipeline Templates

### Lint Template

**Purpose:** Validate Bicep syntax and run linting checks

**Usage:**
```yaml
- template: pipelines/templates/lint-template.yml
  parameters:
    applicationPath: 'applications/step'
    modulesPath: 'modules'
    azureServiceConnection: $(azureServiceConnection)
    workingDirectory: '$(System.DefaultWorkingDirectory)'
```

**What it does:**
- ✅ Upgrades Bicep CLI to latest version
- ✅ Lints all module Bicep files
- ✅ Lints application Bicep files
- ✅ Runs custom linting rules (if bicepconfig.json exists)
- ✅ Publishes lint results as artifact

---

### Validate Template

**Purpose:** Run `az deployment validate` against templates

**Usage:**
```yaml
- template: pipelines/templates/validate-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection)
    deploymentScope: 'subscription'
```

**Parameters:**
- `applicationName`: Name of application to deploy
- `environment`: Target environment (dev/test/uat/prod)
- `azureLocation`: Azure region
- `azureServiceConnection`: Service connection name
- `deploymentScope`: subscription | resourceGroup | managementGroup | tenant
- `templateFile`: (Optional) Override template path
- `parameterFile`: (Optional) Override parameter file path
- `resourceGroupName`: (Required for resourceGroup scope)

**What it does:**
- ✅ Checks Azure connectivity
- ✅ Validates template and parameter files exist
- ✅ Runs validation based on deployment scope
- ✅ Publishes validation results

---

### What-If Template

**Purpose:** Preview changes before deployment

**Usage:**
```yaml
- template: pipelines/templates/whatif-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection)
    deploymentScope: 'subscription'
    resultFormat: 'ResourceIdOnly'
```

**Result Formats:**
- `ResourceIdOnly`: Show only resource IDs (concise)
- `FullResourcePayloads`: Show full resource definitions (detailed)

**What it does:**
- ✅ Runs what-if analysis
- ✅ Shows resources to be:
  - ➕ Created
  - ⟺ Modified
  - ➖ Deleted
  - ♾ Ignored
  - ⬚ No Change
- ✅ Parses and summarizes changes
- ✅ Warns about deletions
- ✅ Publishes what-if results

---

### Deploy Template

**Purpose:** Deploy Bicep templates to Azure

**Usage:**
```yaml
- template: pipelines/templates/deploy-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection)
    deploymentScope: 'subscription'
    runWhatIf: true
    verifyDeployment: true
```

**Parameters:**
- `runWhatIf`: Run what-if before deployment (default: true)
- `verifyDeployment`: Verify resources after deployment (default: true)
- `deploymentName`: Custom deployment name (optional)

**What it does:**
- ✅ Pre-deployment checks (providers, permissions)
- ✅ Optional what-if analysis
- ✅ Deploys to Azure
- ✅ Tracks deployment duration
- ✅ Retrieves deployment outputs
- ✅ Verifies resources created
- ✅ Publishes deployment logs

---

### Environment Deploy Template

**Purpose:** Complete environment deployment orchestration

**Usage:**
```yaml
- template: pipelines/templates/environment-deploy-template.yml
  parameters:
    applicationName: 'step'
    environment: 'dev'
    azureLocation: 'eastus'
    azureServiceConnection: $(azureServiceConnection)
    variableGroupName: 'bicep-dev'
    requiresApproval: false
    runValidation: true
    runWhatIf: true
    verifyAfterDeployment: true
```

**What it does:**
- ✅ Pre-deployment validation
- ✅ What-if analysis
- ✅ Manual approval gate (if required)
- ✅ Deployment
- ✅ Post-deployment verification

---

## 📚 Example Pipelines

### 1. Single Environment Pipeline

**File:** `examples/single-environment-pipeline.yml`

**Use Case:** Rapid development, deploy to dev only

**Trigger:** Automatic on `develop` and `feature/*` branches

**Stages:**
1. Lint
2. Validate
3. Deploy to Dev

**Best For:**
- Development iterations
- Testing template changes
- Feature branch deployments

---

### 2. Hotfix Pipeline

**File:** `examples/hotfix-pipeline.yml`

**Use Case:** Emergency production fixes

**Trigger:** Manual only

**Key Features:**
- ⚠️ Requires justification and change ticket
- 🔒 Double approval required
- 🔍 Quick validation only
- 🏷️ Tags resources as hotfix
- ✅ Post-hotfix verification

**When to Use:**
- Critical production issues
- Security patches
- Incidents requiring immediate resolution

⚠️ **Use with caution!**

---

### 3. Multi-Application Pipeline

**File:** `examples/multi-application-pipeline.yml`

**Use Case:** Deploy multiple applications

**Deployment Strategies:**
- **Sequential:** One after another (safer)
- **Parallel:** All at once (faster)

**Best For:**
- Coordinated releases
- Infrastructure-wide updates
- Multiple independent applications

---

### 4. PR Validation Pipeline

**File:** `examples/pr-validation-pipeline.yml`

**Use Case:** Validate templates in pull requests

**Trigger:** Automatic on PRs to main/develop

**What it validates:**
- ✅ Lints changed Bicep files
- ✅ Validates for all environments
- ✅ Runs what-if analysis
- ✅ Comments results on PR

**Best For:**
- Code review process
- Pre-merge validation
- Team collaboration

---

## 🚀 Getting Started

### 1. Setup Azure DevOps

Follow the comprehensive setup guide:
```
docs/AZURE_DEVOPS_SETUP.md
```

**Setup includes:**
- Service connections
- Variable groups
- Environments and approvals
- Pipeline creation

### 2. Choose Your Pipeline

| Scenario | Pipeline |
|----------|----------|
| Regular multi-env deployment | `azure-pipelines-enhanced.yml` |
| Dev-only deployment | `examples/single-environment-pipeline.yml` |
| Emergency fix | `examples/hotfix-pipeline.yml` |
| Multiple apps | `examples/multi-application-pipeline.yml` |
| PR validation | `examples/pr-validation-pipeline.yml` |

### 3. Create Pipeline in Azure DevOps

1. Go to **Pipelines** > **New pipeline**
2. Select **Azure Repos Git**
3. Choose **Existing YAML file**
4. Select your pipeline file
5. Save and run

### 4. Run Your First Deployment

```yaml
Pipeline: Single Environment Pipeline
Branch: develop
Environment: dev
Run: Automatic on commit
```

---

## 🛠️ Customization

### Creating Custom Templates

1. **Create new template:**
   ```yaml
   # pipelines/templates/custom-template.yml
   parameters:
     - name: customParam
       type: string
   
   steps:
     - task: AzureCLI@2
       displayName: 'Custom Task'
       inputs:
         azureSubscription: $(azureServiceConnection)
         scriptType: 'bash'
         scriptLocation: 'inlineScript'
         inlineScript: |
           echo "Custom logic here"
           echo "Parameter: ${{ parameters.customParam }}"
   ```

2. **Use in pipeline:**
   ```yaml
   steps:
     - template: pipelines/templates/custom-template.yml
       parameters:
         customParam: 'value'
   ```

### Extending Existing Templates

**Option 1: Wrap existing template**
```yaml
steps:
  - template: pipelines/templates/deploy-template.yml
    parameters:
      # Standard parameters
      applicationName: 'step'
      environment: 'dev'
  
  # Add custom steps after
  - task: AzureCLI@2
    displayName: 'Custom Post-Deployment'
    inputs:
      # Custom logic
```

**Option 2: Create wrapper template**
```yaml
# pipelines/templates/custom-deploy-template.yml
parameters:
  - name: applicationName
    type: string

steps:
  # Pre-deployment custom logic
  - bash: echo "Pre-deployment"
  
  # Use existing template
  - template: deploy-template.yml
    parameters:
      applicationName: ${{ parameters.applicationName }}
  
  # Post-deployment custom logic
  - bash: echo "Post-deployment"
```

---

## 📊 Pipeline Best Practices

### 1. Use Templates
✅ **Do:** Use reusable templates
```yaml
- template: pipelines/templates/deploy-template.yml
```

❌ **Don't:** Duplicate code
```yaml
- task: AzureCLI@2  # Repeated in every pipeline
```

### 2. Parameterize
✅ **Do:** Use parameters
```yaml
parameters:
  - name: environment
    type: string
```

❌ **Don't:** Hardcode values
```yaml
environment: 'dev'  # Hardcoded
```

### 3. Validate Early
✅ **Do:** Validate in PR
```yaml
pr:
  branches:
    include: [main]
```

❌ **Don't:** Skip validation
```yaml
skipValidation: true
```

### 4. Use Approval Gates
✅ **Do:** Require approvals for production
```yaml
environment: 'Production'  # Has approval gate
```

❌ **Don't:** Auto-deploy to production
```yaml
# No environment specified = no approval
```

### 5. Monitor Deployments
✅ **Do:** Add verification steps
```yaml
verifyDeployment: true
```

❌ **Don't:** Deploy and forget
```yaml
verifyDeployment: false
```

---

## 📝 Documentation

| Document | Description |
|----------|-------------|
| [Azure DevOps Setup](../docs/AZURE_DEVOPS_SETUP.md) | Complete setup guide |
| [Pipeline Usage](../docs/PIPELINE_USAGE.md) | How to use pipelines |
| [Quick Reference](../docs/PIPELINE_QUICK_REFERENCE.md) | Quick commands and tips |
| [Main README](../README.md) | Solution overview |

---

## ❓ Troubleshooting

See [Azure DevOps Setup - Troubleshooting](../docs/AZURE_DEVOPS_SETUP.md#troubleshooting) for common issues and solutions.

---

## 📞 Support

For help:
1. Check documentation in `/docs`
2. Review pipeline logs in Azure DevOps
3. Check Azure deployment logs in Portal
4. Contact DevOps team

---

**Last Updated:** January 2025
