# Quick Start Guide

Get your first VM deployed in Azure using this Bicep solution in under 10 minutes!

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] Azure CLI installed (version 2.50.0+)
- [ ] Bicep CLI installed (comes with Azure CLI)
- [ ] An active Azure subscription
- [ ] Contributor or Owner permissions on the subscription
- [ ] SSH key pair generated (for Linux VMs)

## Step-by-Step Deployment

### Step 1: Verify Your Tools

```bash
# Check Azure CLI version
az --version
# Should show version 2.50.0 or higher

# Check Bicep version
az bicep version
# Should show version 0.20.0 or higher

# Update if needed
az bicep upgrade
```

### Step 2: Login to Azure

```bash
# Login to your Azure account
az login

# List your subscriptions
az account list --output table

# Set the subscription you want to use
az account set --subscription "<subscription-id-or-name>"

# Verify current subscription
az account show --output table
```

### Step 3: Generate SSH Key (Linux VMs)

```bash
# Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm_key -C "azure-vm-key"

# This creates:
# - Private key: ~/.ssh/azure_vm_key
# - Public key: ~/.ssh/azure_vm_key.pub
```

### Step 4: Configure the STEP Application

```bash
# Navigate to the biceps_improved directory
cd /home/ubuntu/biceps_improved

# Copy your SSH public key to the dev environment
cp ~/.ssh/azure_vm_key.pub applications/step/dev/ssh-key.pub

# Optional: View the dev parameter file
cat applications/step/dev/dev.bicepparam
```

### Step 5: Customize Parameters (Optional)

Edit `applications/step/dev/dev.bicepparam` to customize:

```bicep
// Change VM size
param vmSize = 'Standard_B2s'  // Small, cost-effective

// Change number of VMs
param vmCount = 1  // Start with one VM

// Update tags
param ownerEmail = 'your-email@example.com'
```

### Step 6: Validate the Template

```bash
# Navigate to the application directory
cd applications/step

# Validate the Bicep template
az deployment sub what-if \
  --location eastus \
  --template-file main.bicep \
  --parameters dev/dev.bicepparam

# This shows what resources will be created without actually deploying
```

### Step 7: Deploy to Azure

```bash
# Deploy the infrastructure
az deployment sub create \
  --name "step-dev-$(date +%Y%m%d-%H%M%S)" \
  --location eastus \
  --template-file main.bicep \
  --parameters dev/dev.bicepparam

# This will take 5-10 minutes to complete
```

### Step 8: Monitor the Deployment

While deployment is in progress:

```bash
# In another terminal, watch the deployment
az deployment sub list --output table

# Or view in Azure Portal:
# Portal > Subscriptions > Your Subscription > Deployments
```

### Step 9: Verify Resources

Once deployment completes:

```bash
# List resource groups
az group list --query "[?contains(name, 'step-dev')].name" -o table

# List VMs in the resource group
az vm list --resource-group rg-step-dev-eus --output table

# Get VM details
az vm show \
  --resource-group rg-step-dev-eus \
  --name vm-step-dev-eus-001-001 \
  --output table
```

### Step 10: Connect to Your VM

For VMs with public IPs (dev environment):

```bash
# Get the public IP address
PUBLIC_IP=$(az vm show \
  --resource-group rg-step-dev-eus \
  --name vm-step-dev-eus-001-001 \
  --show-details \
  --query publicIps -o tsv)

echo "Public IP: $PUBLIC_IP"

# Connect via SSH (Linux)
ssh -i ~/.ssh/azure_vm_key azureadmin@$PUBLIC_IP

# For Windows (if you deployed Windows VMs)
az vm show \
  --resource-group rg-step-dev-eus \
  --name vm-step-dev-eus-001-001 \
  --show-details
# Use RDP client to connect
```

## What Was Deployed?

Your deployment created:

✅ **Resource Group**: `rg-step-dev-eus`
- Isolated container for all resources

✅ **Virtual Network**: `vnet-step-dev-eus`
- Address space: 10.0.0.0/16
- Subnet: 10.0.1.0/24

✅ **Network Security Group**: `nsg-step-dev-eus-001`
- SSH access (port 22)
- HTTP/HTTPS access (ports 80, 443)

✅ **Application Security Group**: `asg-step-dev-eus-001`
- Logical grouping for security policies

✅ **Virtual Machine**: `vm-step-dev-eus-001-001`
- Size: Standard_B2s
- OS: Ubuntu 22.04 LTS
- Managed Identity enabled

✅ **Storage Account**: `stepdevdediag`
- For boot diagnostics

✅ **Log Analytics Workspace**: `log-step-dev-eus`
- For monitoring and diagnostics

✅ **Key Vault**: `kv-stepdeveus`
- For secrets management

✅ **Public IP Address** (dev only): `pip-step-dev-eus-001-001`
- For external access

## Next Steps

### 1. Deploy to Test Environment

```bash
# Copy SSH key
cp ~/.ssh/azure_vm_key.pub applications/step/test/ssh-key.pub

# Deploy to test
az deployment sub create \
  --name "step-test-$(date +%Y%m%d-%H%M%S)" \
  --location eastus \
  --template-file main.bicep \
  --parameters test/test.bicepparam
```

### 2. Explore Other Environments

- **UAT**: Higher-spec VMs, no public IPs, stricter security
- **Production**: Production-grade VMs, backup enabled, comprehensive monitoring

### 3. Customize Your Deployment

Edit the `.bicepparam` files to:
- Change VM sizes
- Add more data disks
- Modify network configurations
- Adjust security rules
- Enable/disable features

### 4. Add Your Application

```bash
# Create a new application
mkdir -p applications/myapp/{dev,test,uat,prod}
cp applications/step/main.bicep applications/myapp/
cp -r applications/step/dev/* applications/myapp/dev/

# Customize for your application
# Edit applications/myapp/main.bicep and parameter files
```

## Clean Up Resources

When you're done testing:

```bash
# Delete the resource group (deletes all resources)
az group delete --name rg-step-dev-eus --yes --no-wait

# Verify deletion
az group list --query "[?contains(name, 'step-dev')].name" -o table
```

## Cost Estimation

### Development Environment (as deployed)

- **VM (Standard_B2s)**: ~$30-40/month (pay-as-you-go)
- **Storage (StandardSSD_LRS)**: ~$5-10/month
- **Log Analytics**: First 5GB/day free
- **Public IP**: ~$3-5/month
- **Network**: Minimal (usually < $5/month)

**Estimated Total**: ~$50-70/month

💡 **Cost Savings Tips**:
- Stop VMs when not in use: `az vm deallocate --resource-group rg-step-dev-eus --name vm-step-dev-eus-001-001`
- Use auto-shutdown schedules
- Delete resources when done testing

## Troubleshooting

### Deployment Fails

```bash
# Check deployment errors
az deployment sub show \
  --name <deployment-name> \
  --query properties.error

# Validate template
az deployment sub validate \
  --location eastus \
  --template-file main.bicep \
  --parameters dev/dev.bicepparam
```

### Can't Connect to VM

```bash
# Verify NSG rules
az network nsg rule list \
  --resource-group rg-step-dev-eus \
  --nsg-name nsg-step-dev-eus-001 \
  --output table

# Check VM status
az vm get-instance-view \
  --resource-group rg-step-dev-eus \
  --name vm-step-dev-eus-001-001 \
  --query instanceView.statuses
```

### Permission Errors

```bash
# Check your role assignment
az role assignment list \
  --assignee $(az account show --query user.name -o tsv) \
  --output table

# You need Contributor or Owner role
```

## Getting Help

- 📖 See [README.md](../README.md) for overview
- 🏗️ See [ARCHITECTURE.md](./ARCHITECTURE.md) for design details
- 🔐 See [SECURITY.md](./SECURITY.md) for security best practices
- 📚 Review module documentation in `/modules/`

---

**Congratulations!** 🎉 You've successfully deployed your first VM using this Bicep solution!
