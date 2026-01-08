# Introduction
This repository is created to manage the Azure platform.  
It is divided into several sections:
- *.azuredevops*
  - **pipelineTemplates:** Template pipeline(s)
  - **pipelineVariables:** Global variables, should be edited for each customer.
- *config*
  - **settings.json:** contains the tokens that will be replaced in the json files deployed.
- *deployment:*
  - **Foundation:** used to deploy management group structure
  - **Networking:** used to deploy network infrastructure
  - **Policy:** used to deploy Azure policy definitions/initiatives and assignments
  - **RBAC:** used to deploy Azure RBAC
- *modules:* contains all template components that can be used to deploy infrastructure.
- *pipelines:*  contains the deployment pipelines
- *utilities:* contains several PowerShell scripts used in the deployments

To be able to deploy Azure resources in Azure DevOps, Service connections need to be setup.
The following Service connections are configured:
- AzureDevops-Foundation-Pipeline
- AzureDevops-LandingZone-Pipeline
- AzureDevops-Networking-Pipeline
- AzureDevops-Platform-Pipeline
- AzureDevops-Policies-Pipeline
- AzureDevops-Rbac-Pipeline

In Azure Active Directory the corresponding application registrations are created:
- AzureDevops-Foundation-Pipeline (Management Group Contributor)
- AzureDevops-Landingzone-Pipeline (Owner)
- AzureDevops-Networking-Pipeline (Network Contributor Reader)
- AzureDevops-Platform-Pipeline (Contributor)
- AzureDevops-Policies-Pipeline (Resource Policy Contributor)
- AzureDevops-Rbac-Pipeline (User Access Administrator)

# Getting Started
To get an understanding how this repository works, follow the instructions below:  
1. Only change/update BICEP files in the **deployment** folder
1. When these files are getting updated, the corresponding pipeline (located in the **pipelines** folder) will be triggered to start.  
The pipeline consists of:
   1. The **global.variables.yml** file that contains allnex related parameters
   1. A variable group containing deployment related parameters
   1. A reference to the pipeline template file **main.yml**, located in *.azuredevops/pipelineTemplates* folder  
   This pipeline contains 4 deployment stages: 
      - **Lint:** analyzing BICEP code and provides suggestions for improving its quality and adherence to best practices and evaluating the Azure resources against a set of customizable rules to identify potential security and compliance isingsues
      - **Validate:** check the deployment status of Azure resources by validating that the expected resources are provisioned and that the properties of those resources meet the specified criteria
      - **Preview:** simulating the deployment process and displays the expected changes without actually executing them, allowing the user to preview the changes that would be made before executing the deployment.
      - **Deploy:** creating a new deployment of Azure resources from a BICEP template

The pipelines are devided in different folders:
- Foundation: deploying the Azure governance structure (management groups)
- Networking: deploying network infrastructure (Azure firewall, VNets, subnets, NSGs, Route tables,...)
- Platform: deploying Azure resources in the HUB
- Policies: deploying Azure policies (definitions, initiatives and assignments)
- Project onboarding: deploying solution landing zones for development teams (resource groups, key vault, subnets,...)
- RBAC: Deploying Role-Based Access Control in Azure

# Deploy Azure resources
Follow the procedure below to deploy new or update existing resources in the Azure platform:  
1. Create an offline clone of the repository
   ```
   git clone GIT_SSH_URL
   ```
1. Create a new branch
   ```
   git checkout -b /users/fullname/branchname
   ```
1. Add code
1. Commit change
   ```
   git commit -m "description of the commit"
   ```
1. Push code to online branch
   ```
   git push
   ```
1. Create Pull request
1. Pull request will initiate code scan
1. If all is succesfull, the PR will be approved and the deployment will be triggered