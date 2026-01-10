#!/bin/bash
# ============================================================================
# Deployment Script for Bicep Infrastructure
# ============================================================================
# This script automates the deployment of infrastructure using Bicep templates
# Supports multiple environments and validation options
# ============================================================================

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

show_usage() {
    echo "Usage: $0 -a <application> -e <environment> [options]"
    echo ""
    echo "Required arguments:"
    echo "  -a, --application    Application name (e.g., step)"
    echo "  -e, --environment    Environment (dev, test, uat, prod)"
    echo ""
    echo "Optional arguments:"
    echo "  -l, --location       Azure region (default: eastus)"
    echo "  -s, --subscription   Subscription ID (uses current if not specified)"
    echo "  -v, --validate       Validate only (don't deploy)"
    echo "  -w, --what-if        Run what-if analysis"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -a step -e dev"
    echo "  $0 -a step -e prod -s xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -v"
}

# ============================================================================
# Parse Command Line Arguments
# ============================================================================

APPLICATION=""
ENVIRONMENT=""
LOCATION="eastus"
SUBSCRIPTION=""
VALIDATE_ONLY=false
WHAT_IF=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--application)
            APPLICATION="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -s|--subscription)
            SUBSCRIPTION="$2"
            shift 2
            ;;
        -v|--validate)
            VALIDATE_ONLY=true
            shift
            ;;
        -w|--what-if)
            WHAT_IF=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# ============================================================================
# Validation
# ============================================================================

if [[ -z "$APPLICATION" ]]; then
    print_error "Application name is required"
    show_usage
    exit 1
fi

if [[ -z "$ENVIRONMENT" ]]; then
    print_error "Environment is required"
    show_usage
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|uat|prod)$ ]]; then
    print_error "Invalid environment. Must be: dev, test, uat, or prod"
    exit 1
fi

# ============================================================================
# Setup
# ============================================================================

print_header "Bicep Infrastructure Deployment"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
APP_DIR="$ROOT_DIR/applications/$APPLICATION"
PARAM_FILE="$APP_DIR/$ENVIRONMENT/$ENVIRONMENT.bicepparam"
TEMPLATE_FILE="$APP_DIR/main.bicep"

print_info "Application: $APPLICATION"
print_info "Environment: $ENVIRONMENT"
print_info "Location: $LOCATION"
print_info "Root Directory: $ROOT_DIR"

# Check if application directory exists
if [[ ! -d "$APP_DIR" ]]; then
    print_error "Application directory not found: $APP_DIR"
    exit 1
fi

# Check if parameter file exists
if [[ ! -f "$PARAM_FILE" ]]; then
    print_error "Parameter file not found: $PARAM_FILE"
    exit 1
fi

# Check if template file exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    print_error "Template file not found: $TEMPLATE_FILE"
    exit 1
fi

print_success "All required files found"

# ============================================================================
# Azure CLI Check
# ============================================================================

print_header "Checking Prerequisites"

if ! command -v az &> /dev/null; then
    print_error "Azure CLI not found. Please install it first."
    exit 1
fi
print_success "Azure CLI installed"

# Check Azure CLI version
AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
print_info "Azure CLI version: $AZ_VERSION"

# Check if logged in
if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Run 'az login' first."
    exit 1
fi
print_success "Logged in to Azure"

# Set subscription if provided
if [[ -n "$SUBSCRIPTION" ]]; then
    print_info "Setting subscription to: $SUBSCRIPTION"
    az account set --subscription "$SUBSCRIPTION"
fi

# Display current subscription
CURRENT_SUB=$(az account show --query name -o tsv)
CURRENT_SUB_ID=$(az account show --query id -o tsv)
print_info "Current subscription: $CURRENT_SUB ($CURRENT_SUB_ID)"

# ============================================================================
# Bicep Build
# ============================================================================

print_header "Building Bicep Template"

az bicep build --file "$TEMPLATE_FILE"
if [[ $? -eq 0 ]]; then
    print_success "Bicep template built successfully"
else
    print_error "Bicep build failed"
    exit 1
fi

# ============================================================================
# Validation
# ============================================================================

if [[ "$VALIDATE_ONLY" == true ]] || [[ "$WHAT_IF" == true ]]; then
    print_header "Validating Template"
    
    az deployment sub validate \
        --location "$LOCATION" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "$PARAM_FILE"
    
    if [[ $? -eq 0 ]]; then
        print_success "Template validation passed"
    else
        print_error "Template validation failed"
        exit 1
    fi
fi

# ============================================================================
# What-If Analysis
# ============================================================================

if [[ "$WHAT_IF" == true ]]; then
    print_header "Running What-If Analysis"
    
    az deployment sub what-if \
        --location "$LOCATION" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "$PARAM_FILE"
    
    if [[ "$VALIDATE_ONLY" == true ]]; then
        print_info "Validation and what-if complete. Exiting (no deployment)."
        exit 0
    fi
    
    # Ask for confirmation
    read -p "Do you want to proceed with deployment? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi
fi

if [[ "$VALIDATE_ONLY" == true ]]; then
    print_info "Validation complete. Exiting (no deployment)."
    exit 0
fi

# ============================================================================
# Deployment
# ============================================================================

print_header "Deploying Infrastructure"

DEPLOYMENT_NAME="$APPLICATION-$ENVIRONMENT-$(date +%Y%m%d-%H%M%S)"

print_info "Deployment name: $DEPLOYMENT_NAME"
print_warning "Starting deployment (this may take 5-15 minutes)..."

az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "$PARAM_FILE"

if [[ $? -eq 0 ]]; then
    print_success "Deployment completed successfully!"
else
    print_error "Deployment failed"
    exit 1
fi

# ============================================================================
# Display Outputs
# ============================================================================

print_header "Deployment Outputs"

az deployment sub show \
    --name "$DEPLOYMENT_NAME" \
    --query properties.outputs

print_success "Deployment script completed"

# ============================================================================
# Next Steps
# ============================================================================

print_header "Next Steps"

echo "1. Verify resources in Azure Portal"
echo "2. Connect to VMs using SSH or RDP"
echo "3. Configure applications on the VMs"
echo "4. Set up monitoring alerts"
echo "5. Test backup and recovery procedures"

print_info "To delete resources: az group delete --name rg-$APPLICATION-$ENVIRONMENT-<region> --yes"
