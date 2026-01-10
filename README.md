# Azure Bicep Infrastructure as Code - VM Deployment Solution

## 📋 Overview

This is a production-ready, modular Bicep infrastructure-as-code solution for deploying Virtual Machines in Azure. The solution follows Azure best practices and provides comprehensive support for:

- ✅ Modular, reusable Bicep templates
- ✅ Environment-specific configurations (dev, test, UAT, prod)
- ✅ Application-centric organization
- ✅ Comprehensive security (Key Vault, NSGs, ASGs, Managed Identity)
- ✅ Monitoring and diagnostics (Log Analytics, Azure Monitor)
- ✅ Backup and disaster recovery
- ✅ Token-based configuration management
- ✅ Consistent naming conventions and tagging
- ✅ Multi-subscription ready

## 🏗️ Solution Architecture

```
biceps_improved/
├── modules/                      # Reusable Bicep modules
│   ├── compute/                  # VM and compute resources
│   ├── network/                  # VNet, NSG, ASG
│   ├── storage/                  # Storage accounts
│   ├── monitoring/               # Log Analytics, diagnostics
│   ├── backup/                   # Recovery Services Vault
│   ├── security/                 # Managed Identity
│   └── keyvault/                 # Key Vault
├── applications/                 # Application-specific deployments
│   └── step/                     # Example: STEP application
│       ├── main.bicep            # Main orchestration template
│       ├── dev/                  # Dev environment params
│       ├── test/                 # Test environment params
│       ├── uat/                  # UAT environment params
│       └── prod/                 # Prod environment params
├── config/                       # Configuration management
│   ├── naming/                   # Naming convention templates
│   ├── tags/                     # Tagging templates
│   ├── tokens/                   # Environment-specific tokens
│   └── common.json               # Common configuration
├── scripts/                      # Deployment and helper scripts
│   ├── deployment/               # Deployment automation
│   └── validation/               # Validation scripts
├── docs/                         # Additional documentation
└── .github/workflows/            # CI/CD pipeline templates
```

## 🚀 Quick Start

See [QUICKSTART.md](./docs/QUICKSTART.md) for detailed getting started instructions.

## 🔄 CI/CD with Azure DevOps

This solution includes production-ready Azure DevOps pipelines for automated deployment:

### Pipeline Features
- ✅ **Multi-stage deployments** (Lint → Validate → Preview → Deploy)
- ✅ **Environment-specific deployments** with approval gates
- ✅ **What-if analysis** to preview changes before deployment
- ✅ **Reusable templates** for consistent deployments
- ✅ **Hotfix pipelines** for emergency deployments
- ✅ **PR validation** to ensure code quality

### Available Pipelines

| Pipeline | Purpose | Trigger |
|----------|---------|---------|
| **Multi-Environment** | Deploy across dev → test → UAT → prod | Auto (main branch) |
| **Single Environment** | Rapid dev deployment | Auto (develop branch) |
| **Hotfix** | Emergency production fixes | Manual only |
| **Multi-Application** | Deploy multiple apps | Auto (main branch) |
| **PR Validation** | Validate pull requests | Auto (PRs) |

### Quick Setup

1. **Complete Azure DevOps Setup**
   - Follow the comprehensive guide: [Azure DevOps Setup](./docs/AZURE_DEVOPS_SETUP.md)
   - Setup includes: Service connections, variable groups, environments, approvals

2. **Create Your First Pipeline**
   ```
   1. Navigate to Pipelines in Azure DevOps
   2. Click "New pipeline"
   3. Select "Azure Repos Git"
   4. Choose "Existing YAML file"
   5. Select: /azure-pipelines-enhanced.yml
   6. Save and run
   ```

3. **Documentation**
   - 📖 [Azure DevOps Setup Guide](./docs/AZURE_DEVOPS_SETUP.md) - Complete setup instructions
   - 📖 [Pipeline Usage Guide](./docs/PIPELINE_USAGE.md) - How to use the pipelines
   - 📖 [Quick Reference](./docs/PIPELINE_QUICK_REFERENCE.md) - Commands and tips
   - 📖 [Pipelines README](./pipelines/README.md) - Template documentation

### Prerequisites

1. **Azure CLI** (version 2.50.0 or later)
   ```bash
   az --version
   ```

2. **Bicep CLI** (version 0.20.0 or later)
   ```bash
   az bicep version
   ```

3. **Azure Subscription** with appropriate permissions (Contributor or Owner)

4. **SSH Key Pair** for Linux VMs
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key
   ```

### Deploy Your First VM

1. **Clone or copy this repository**

2. **Configure your SSH public key**
   ```bash
   # Copy your SSH public key to the dev environment
   cp ~/.ssh/azure_vm_key.pub applications/step/dev/ssh-key.pub
   ```

3. **Login to Azure**
   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

4. **Deploy to Development Environment**
   ```bash
   cd applications/step
   az deployment sub create \
     --location eastus \
     --template-file main.bicep \
     --parameters dev/dev.bicepparam
   ```

5. **Monitor the deployment**
   ```bash
   # The deployment typically takes 5-10 minutes
   # You can view progress in Azure Portal under Deployments
   ```

## 📚 Documentation

### Core Documentation

- [Quick Start Guide](./docs/QUICKSTART.md) - Get up and running quickly
- [Architecture Guide](./docs/ARCHITECTURE.md) - Detailed architecture overview
- [Deployment Guide](./docs/DEPLOYMENT.md) - Comprehensive deployment instructions
- [Configuration Guide](./docs/CONFIGURATION.md) - Configuration management details
- [Security Guide](./docs/SECURITY.md) - Security best practices
- [Operations Guide](./docs/OPERATIONS.md) - Day-2 operations

### Module Documentation

- [Compute Module](./modules/compute/README.md)
- [Network Module](./modules/network/README.md)
- [Storage Module](./modules/storage/README.md)
- [Monitoring Module](./modules/monitoring/README.md)
- [Backup Module](./modules/backup/README.md)
- [Security Module](./modules/security/README.md)
- [Key Vault Module](./modules/keyvault/README.md)

## 🎯 Key Features

### 1. Environment Separation

Each environment (dev, test, UAT, prod) has:
- Separate resource groups
- Different VM sizes and configurations
- Environment-specific security policies
- Isolated networks
- Appropriate backup and monitoring settings

### 2. Modular Design

Reusable modules for:
- Virtual Machines with full configuration
- Virtual Networks with subnets and NSGs
- Application Security Groups
- Storage Accounts
- Log Analytics Workspaces
- Recovery Services Vaults
- Key Vaults
- Managed Identities

### 3. Configuration Management

- **Token-based configs**: Environment-specific settings in `/config/tokens/`
- **Common configs**: Shared settings in `/config/common.json`
- **Naming conventions**: Consistent resource naming with `/config/naming/`
- **Tagging strategy**: Automated tagging with `/config/tags/`

### 4. Security Features

- Network Security Groups with customizable rules
- Application Security Groups for logical grouping
- Azure Key Vault for secrets management
- Managed Identities (system and user-assigned)
- Private endpoints support
- Encrypted storage accounts
- Secure network access with service endpoints

### 5. Monitoring & Observability

- Log Analytics Workspace integration
- Azure Monitor Agent deployment
- Boot diagnostics
- Diagnostic settings
- Customizable log retention

### 6. Backup & Recovery

- Azure Backup integration
- Recovery Services Vault
- Configurable backup policies
- Per-environment backup settings

## 🔧 Customization

### Adding a New Application

1. Create a new application folder:
   ```bash
   mkdir -p applications/myapp/{dev,test,uat,prod}
   ```

2. Copy and customize the main template:
   ```bash
   cp applications/step/main.bicep applications/myapp/
   ```

3. Create environment-specific parameter files:
   ```bash
   cp applications/step/dev/dev.bicepparam applications/myapp/dev/
   # Edit and customize for your application
   ```

### Modifying VM Configurations

Edit the `.bicepparam` files to change:
- VM sizes: `param vmSize = 'Standard_D4s_v3'`
- Number of VMs: `param vmCount = 2`
- OS images: Modify `param imageReference`
- Data disks: Edit `param dataDisks` array
- Network settings: Adjust VNet and subnet configurations
- Security rules: Customize NSG rules

### Adding Custom Modules

Create new modules in `/modules/` directory:
```bash
mkdir modules/mymodule
# Create your module.bicep and README.md
```

## 🌍 Multi-Subscription Deployment

The solution supports multi-subscription deployments:

1. Set the subscription ID in parameter files:
   ```bicep
   param subscriptionId = '<target-subscription-id>'
   ```

2. Ensure you have appropriate permissions in the target subscription

3. Deploy as usual - the template will deploy to the specified subscription

## 🔐 Security Best Practices

1. **Never commit secrets** to version control
   - Use Key Vault for secrets
   - Use `.gitignore` for sensitive files
   - Load secrets at deployment time

2. **Restrict network access**
   - Use NSG rules to limit access
   - Disable public IPs in production
   - Use Azure Bastion or Jump Boxes

3. **Enable monitoring**
   - Deploy Log Analytics in all environments
   - Configure alerts for critical events
   - Review logs regularly

4. **Regular backups**
   - Enable Azure Backup in non-dev environments
   - Test restore procedures
   - Document recovery processes

## 📊 Cost Optimization

### Development Environment
- Use B-series VMs (burstable)
- StandardSSD_LRS storage
- Disable backup
- Shorter log retention
- Auto-shutdown policies

### Production Environment
- Appropriate VM sizing (avoid over-provisioning)
- Premium_LRS only where needed
- Reserved instances for long-term workloads
- Azure Hybrid Benefit for Windows
- Proper tagging for cost allocation

## 🤝 Contributing

Contributions are welcome! Please:

1. Follow the existing module structure
2. Include comprehensive documentation
3. Add inline comments to Bicep templates
4. Test thoroughly before submitting
5. Update relevant README files

## 📝 License

This solution is provided as-is for use in your Azure environment.

## 🆘 Troubleshooting

### Common Issues

1. **Deployment fails with "InvalidTemplate" error**
   - Check Bicep syntax: `az bicep build --file main.bicep`
   - Validate parameters match parameter file schema

2. **Resource name conflicts**
   - Resource names must be globally unique (storage accounts, key vaults)
   - Modify naming convention or add suffixes

3. **Permission errors**
   - Ensure you have Contributor or Owner role
   - Check subscription quotas

4. **Network connectivity issues**
   - Review NSG rules
   - Check route tables
   - Verify service endpoints

### Getting Help

- Review module-specific README files
- Check Azure Bicep documentation: https://learn.microsoft.com/azure/azure-resource-manager/bicep/
- Azure CLI reference: https://learn.microsoft.com/cli/azure/

## 📞 Support

For issues and questions:
- Review the documentation in `/docs/`
- Check module README files
- Consult Azure documentation

---

**Last Updated**: January 2026
**Bicep Version**: 0.20+
**Azure CLI Version**: 2.50+
