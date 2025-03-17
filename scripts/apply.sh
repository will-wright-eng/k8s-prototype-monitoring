#!/bin/bash

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/common.sh"

check_do_token

# Create tofu directory if it doesn't exist
if [ ! -d "$TERRAFORM" ]; then
    echo "Error: $TERRAFORM directory not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Navigate to tofu directory
cd $TERRAFORM

# Initialize tofu if not already initialized
if [ ! -d ".terraform" ]; then
    echo "Initializing tofu..."
    $TERRAFORM init
fi

# Run tofu plan
echo "Running tofu plan..."
$TERRAFORM plan -out=tfplan

# Prompt for confirmation
read -p "Do you want to apply this plan? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Apply tofu configuration
    echo "Applying tofu configuration..."
    $TERRAFORM apply tfplan
else
    echo "Apply cancelled"
    rm tfplan
    exit 0
fi

# Clean up plan file
rm tfplan
