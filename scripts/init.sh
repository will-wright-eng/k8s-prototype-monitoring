#!/bin/bash

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/common.sh"

check_do_token

init_terraform() {
    cd "$TERRAFORM"

    if [ -d ".terraform" ]; then
        rm -rf .terraform
    fi

    echo "Initializing tofu..."
    $TERRAFORM init
}

init_terraform
