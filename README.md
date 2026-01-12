# VM Factory (Bicep) — Inventory-driven deployments (test-ready)

This repository deploys **Azure Virtual Machines** from an **inventory.json** using **Bicep** and **Azure DevOps**.

## What it does
- Deploys **VMs + NICs + managed disks + VM extensions** (AMA, optional domain join)
- Uses **existing** networking (you provide `subnetResourceId`)
- Uses **Shared Image Gallery** images (Windows + Linux)
- Uses a **single Log Analytics Workspace** (LAW) for AMA
- Uses existing **Boot Diagnostics** storage account (per subscription)
- Uses **Customer-Managed Keys (CMK)** for managed disks via **Disk Encryption Set (DES)**
- Stores per-VM secrets/keys in a **central Key Vault (RBAC)**
- Deleting a VM from inventory results in deletion of VM resources (gated by what-if + approval)

## Repo layout
- `/apps/<app>/<env>/`
  - `env.bicepparam` — shared config for that app+env
  - `inventory.json` — list of VMs (add/remove to create/delete)
- `/infra/` — reusable Bicep modules + orchestrators
- `/.azuredevops/` — Azure DevOps pipelines + PowerShell scripts

## Key Vault conventions
- Local admin username is always: `epadmin`
- Local admin password secret (per VM): **`<vmName>-local-admin`**
  - Secret metadata: tags include `username=epadmin`, `purpose=local-admin`
- Per-VM CMK key name: **`key-<vmName>`**
- Key Vault soft-delete retention (e.g., 90 days) is enforced by the **vault settings**.

## CI/CD behavior
- **PR pipeline** (`pr-validate.yml`)
  - Validates repo + inventories
  - Produces an inventory change plan summary
- **Main pipeline** (`deploy-main.yml`)
  - Detects changed app/env scopes
  - Syncs Key Vault (creates missing secrets/keys)
  - Runs Azure what-if
  - **If deletions are detected:** requires manual approval
  - Deploys using **Azure Deployment Stacks**
  - Deletes KV secret/key for removed VMs (soft-delete)

## Minimum configuration required to test
For each environment you want to deploy, update:
- `apps/<app>/<env>/env.bicepparam`
- `apps/<app>/<env>/inventory.json`

### Required values in `env.bicepparam`
- `targetSubscriptionId`
- `targetResourceGroupName`
- `targetLocation`
- `centralKeyVaultResourceId`
- `logAnalyticsWorkspaceResourceId`
- `bootDiagStorageAccountResourceId`
- `defaultSubnetResourceId`
- `defaultWindowsSourceImageId`
- `defaultLinuxSourceImageId` (can be placeholder until you deploy Linux)

> Domain join is disabled by default (`domainJoin.enabled = false`). Enable later when you have service account credentials.

## Azure DevOps prerequisites
- Create an Azure DevOps **Service Connection** (service principal)
- Ensure it has permissions:
  - On target subscriptions: create/update resources in target RGs
  - On central Key Vault: `get/list/set` secrets and `get/list/create` keys (RBAC roles)
  - Ability to deploy Deployment Stacks

