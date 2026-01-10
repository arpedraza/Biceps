# STEP Application

This is an example application deployment showcasing the complete Bicep solution with all four environments.

## Overview

The STEP application demonstrates:
- Multi-environment deployment (dev, test, UAT, prod)
- Progressive hardening (dev → test → UAT → prod)
- Environment-specific configurations
- Proper resource isolation
- Security best practices

## Architecture

### Components Deployed

1. **Networking**
   - Virtual Network with isolated address space per environment
   - Subnet with NSG attached
   - Application Security Group
   - Public IPs (dev/test only)

2. **Compute**
   - Virtual Machines (Ubuntu 22.04 LTS)
   - Managed Identities
   - Data disks for application data

3. **Storage**
   - Storage account for boot diagnostics

4. **Monitoring**
   - Log Analytics Workspace
   - Azure Monitor Agent on VMs

5. **Security**
   - Key Vault for secrets
   - NSG rules for network security
   - ASG for logical grouping

6. **Backup** (test, UAT, prod)
   - Recovery Services Vault
   - Daily backup policy

## Environment Configurations

### Development (`dev/`)

**Purpose**: Developer testing and experimentation

**Configuration**:
- VM Size: Standard_B2s (2 vCPU, 4 GB RAM)
- VM Count: 1
- OS Disk: StandardSSD_LRS, 128 GB
- Data Disk: 64 GB StandardSSD_LRS
- Network: 10.0.0.0/16, Public IP enabled
- Backup: Disabled (cost savings)
- Security: More permissive (allow SSH from anywhere ⚠️)

**Cost**: ~$50-70/month

### Test (`test/`)

**Purpose**: Integration testing and QA

**Configuration**:
- VM Size: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- VM Count: 2 (load testing capability)
- OS Disk: Premium_LRS, 128 GB
- Data Disk: 128 GB Premium_LRS
- Network: 10.1.0.0/16, Public IP enabled
- Backup: Enabled (30 days retention)
- Security: Restricted SSH (corporate network only)

**Cost**: ~$200-250/month

### UAT (`uat/`)

**Purpose**: User acceptance testing, pre-production validation

**Configuration**:
- VM Size: Standard_D4s_v3 (4 vCPU, 16 GB RAM)
- VM Count: 2 (high availability)
- OS Disk: Premium_LRS, 256 GB
- Data Disks: 256 GB + 512 GB Premium_LRS
- Network: 10.2.0.0/16, No public IPs
- Backup: Enabled (60 days retention)
- Security: Highly restricted (VNet and corporate only)

**Cost**: ~$500-600/month

### Production (`prod/`)

**Purpose**: Live production workloads

**Configuration**:
- VM Size: Standard_D8s_v3 (8 vCPU, 32 GB RAM)
- VM Count: 3 (high availability, fault tolerance)
- OS Disk: Premium_LRS, 512 GB
- Data Disks: 512 GB + 1024 GB Premium_LRS
- Network: 10.3.0.0/16, No public IPs
- Backup: Enabled (180 days retention)
- Security: Maximum restrictions (jump box only)
- Monitoring: Extended retention (180 days)

**Cost**: ~$1,200-1,500/month

## Deployment Instructions

### Prerequisites

1. Azure CLI installed
2. Bicep CLI installed
3. SSH key pair generated
4. Azure subscription with appropriate permissions

### Quick Deploy

```bash
# Navigate to the application directory
cd applications/step

# Deploy to development
cp ~/.ssh/id_rsa.pub dev/ssh-key.pub
az deployment sub create \
  --name step-dev-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters dev/dev.bicepparam

# Deploy to test
cp ~/.ssh/id_rsa.pub test/ssh-key.pub
az deployment sub create \
  --name step-test-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters test/test.bicepparam

# Deploy to UAT
cp ~/.ssh/id_rsa.pub uat/ssh-key.pub
az deployment sub create \
  --name step-uat-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters uat/uat.bicepparam

# Deploy to production
cp ~/.ssh/id_rsa.pub prod/ssh-key.pub
az deployment sub create \
  --name step-prod-deployment \
  --location eastus \
  --template-file main.bicep \
  --parameters prod/prod.bicepparam
```

### Validation Before Deploy

```bash
# Validate the template
az deployment sub validate \
  --location eastus \
  --template-file main.bicep \
  --parameters dev/dev.bicepparam

# Preview changes (what-if)
az deployment sub what-if \
  --location eastus \
  --template-file main.bicep \
  --parameters dev/dev.bicepparam
```

## Customization

### Changing VM Sizes

Edit the `.bicepparam` file for the environment:

```bicep
// In dev/dev.bicepparam
param vmSize = 'Standard_D2s_v3'  // Upgrade from B2s
```

### Adding Data Disks

```bicep
// In test/test.bicepparam
param dataDisks = [
  {
    sizeGB: 128
    storageAccountType: 'Premium_LRS'
    caching: 'ReadWrite'
  }
  {
    sizeGB: 256
    storageAccountType: 'Premium_LRS'
    caching: 'ReadOnly'
  }
  // Add more disks as needed
]
```

### Modifying NSG Rules

```bicep
// In uat/uat.bicepparam
param nsgSecurityRules = [
  {
    name: 'allow-custom-app'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 200
    direction: 'Inbound'
    description: 'Allow custom application port'
  }
]
```

### Scaling VM Count

```bicep
// In prod/prod.bicepparam
param vmCount = 5  // Scale from 3 to 5 VMs
```

## Security Configuration

### SSH Key Management

**Best Practices**:
1. Use different SSH keys per environment
2. Rotate keys regularly
3. Store keys securely (not in version control)
4. Consider using Azure Key Vault for key storage

```bash
# Generate environment-specific keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_step_dev
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_step_prod

# Use appropriate key for each environment
cp ~/.ssh/azure_step_dev.pub dev/ssh-key.pub
cp ~/.ssh/azure_step_prod.pub prod/ssh-key.pub
```

### Network Security

**Progressive Hardening**:

1. **Dev**: Open for development (but should still restrict SSH source IPs)
2. **Test**: Corporate network access only
3. **UAT**: VNet and corporate network only
4. **Prod**: Jump box or Azure Bastion only

### Key Vault Integration

```bash
# Store secrets in Key Vault
az keyvault secret set \
  --vault-name kv-stepdeveus \
  --name vm-admin-password \
  --value 'YourSecurePassword123!'

# Reference in application code using Managed Identity
# No credentials needed!
```

## Monitoring

### Log Analytics Queries

```kusto
// VM performance overview
Perf
| where Computer startswith "vm-step"
| where CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)

// Security events
SecurityEvent
| where Computer startswith "vm-step"
| where EventID == 4625  // Failed logins
| summarize count() by Computer, Account
```

### Setting Up Alerts

```bash
# Create alert for high CPU
az monitor metrics alert create \
  --name step-vm-high-cpu \
  --resource-group rg-step-prod-eus \
  --scopes /subscriptions/.../virtualMachines/vm-step-prod-eus-001-001 \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m
```

## Backup and Recovery

### Backup Configuration

Backup is configured automatically in test, UAT, and prod environments.

**Policy**:
- Daily backups at 2:00 AM UTC
- 30 days daily retention
- 12 weeks weekly retention
- 12 months monthly retention

### Manual Backup

```bash
# Trigger on-demand backup
az backup protection backup-now \
  --resource-group rg-step-prod-eus \
  --vault-name rsv-step-prod-eus \
  --container-name vm-step-prod-eus-001-001 \
  --item-name vm-step-prod-eus-001-001
```

### Restore VM

```bash
# List recovery points
az backup recoverypoint list \
  --resource-group rg-step-prod-eus \
  --vault-name rsv-step-prod-eus \
  --container-name vm-step-prod-eus-001-001 \
  --item-name vm-step-prod-eus-001-001

# Restore VM
az backup restore restore-disks \
  --resource-group rg-step-prod-eus \
  --vault-name rsv-step-prod-eus \
  --container-name vm-step-prod-eus-001-001 \
  --item-name vm-step-prod-eus-001-001 \
  --rp-name <recovery-point-name> \
  --storage-account stepproddusdiag
```

## Troubleshooting

### Common Issues

**1. Deployment fails with "ResourceGroupNotFound"**
- Ensure template has `targetScope = 'subscription'`
- Resource group is created by the template

**2. Cannot connect to VM**
- Check NSG rules
- Verify VM is running
- Confirm SSH key is correct
- Check public IP (if applicable)

**3. Key Vault access denied**
- Verify Managed Identity is enabled
- Check RBAC role assignments
- Ensure Key Vault network rules allow access

### Debug Commands

```bash
# Check deployment status
az deployment sub show --name step-dev-deployment

# View deployment errors
az deployment operation sub list \
  --name step-dev-deployment \
  --query "[?properties.provisioningState=='Failed']"

# Check VM status
az vm get-instance-view \
  --resource-group rg-step-dev-eus \
  --name vm-step-dev-eus-001-001
```

## Next Steps

1. **Configure Application**: Install and configure your application on the VMs
2. **Set Up CI/CD**: Integrate with Azure DevOps or GitHub Actions
3. **Enable Advanced Monitoring**: Configure Application Insights
4. **Implement Autoscaling**: Add VM Scale Sets for dynamic scaling
5. **Add Load Balancer**: Distribute traffic across VM instances

---

**For more information**, see the main [README.md](../../README.md)
