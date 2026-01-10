#!/bin/bash
# ============================================================================
# Deploy All Environments Script
# ============================================================================
# This script deploys an application to all environments sequentially
# Use with caution - typically you'd deploy to environments progressively
# ============================================================================

set -e

APPLICATION=${1:-step}

echo "Deploying $APPLICATION to all environments..."
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Deploy to dev
echo "=== Deploying to DEV ==="
"$SCRIPT_DIR/deploy.sh" -a "$APPLICATION" -e dev
echo ""

# Deploy to test
echo "=== Deploying to TEST ==="
"$SCRIPT_DIR/deploy.sh" -a "$APPLICATION" -e test
echo ""

# Deploy to UAT (with confirmation)
read -p "Deploy to UAT? (yes/no): " CONFIRM_UAT
if [[ "$CONFIRM_UAT" == "yes" ]]; then
    echo "=== Deploying to UAT ==="
    "$SCRIPT_DIR/deploy.sh" -a "$APPLICATION" -e uat
    echo ""
fi

# Deploy to prod (with confirmation)
read -p "Deploy to PRODUCTION? (yes/no): " CONFIRM_PROD
if [[ "$CONFIRM_PROD" == "yes" ]]; then
    echo "=== Deploying to PRODUCTION ==="
    "$SCRIPT_DIR/deploy.sh" -a "$APPLICATION" -e prod
    echo ""
fi

echo "All deployments completed!"
