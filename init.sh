#!/usr/bin/env bash
set -euo pipefail

SCRIPT_URL="<SCRIPT_URL>"

curl -fsSL "${SCRIPT_URL}" -o setup.sh
bash setup.sh
rm -f setup.sh
rm -f "$0"
