#!/bin/bash

# Set color variables
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

export TERRAFORM="tofu"

check_do_token() {
    echo "Checking DO_TOKEN environment variable..."
    if [ -z "$DO_TOKEN" ]; then
        echo "Error: DO_TOKEN environment variable is not set"
        echo "Usage: DO_TOKEN=your_token ./script.sh"
        exit 1
    fi
    # Export DO_TOKEN as a tofu variable
    export TF_VAR_do_token="$DO_TOKEN"
}
