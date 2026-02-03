#!/usr/bin/env bash
set -euo pipefail

SCRIPT_URL="https://raw.githubusercontent.com/sabinm677/codegen/refs/heads/develop/setup_env.sh"

curl -fsSL "${SCRIPT_URL}" -o setup.sh
bash setup.sh
rm -f setup.sh
rm -f "$0"
