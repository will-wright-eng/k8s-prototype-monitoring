#!/bin/bash

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
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

echo "Plan saved to tfplan file"
echo "You can apply this plan with 'make tofu-apply'"
