#!/bin/bash
# ============================================================================
# Validate All Templates Script
# ============================================================================
# This script validates all Bicep templates and parameter files
# ============================================================================

set -e

ROOT_DIR="$(dirname "$(dirname "$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )")"))"

echo "Validating all Bicep templates..."
echo ""

ERROR_COUNT=0

# Find all .bicep files
while IFS= read -r -d '' file; do
    echo "Validating: $file"
    if az bicep build --file "$file" --stdout > /dev/null 2>&1; then
        echo "✓ Valid"
    else
        echo "✗ Invalid"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
    echo ""
done < <(find "$ROOT_DIR" -name "*.bicep" -print0)

if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "All templates are valid!"
    exit 0
else
    echo "Found $ERROR_COUNT invalid templates"
    exit 1
fi
