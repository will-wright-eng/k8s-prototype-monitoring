#!/bin/bash

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/common.sh"

check_do_token

echo "Logging into DO container registry..."
doctl auth init -t "${DO_TOKEN}"
doctl registry login

echo "Successfully logged into registry"
