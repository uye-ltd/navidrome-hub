#!/usr/bin/env bash
# Fixed entrypoint called by webhook. Pulls latest code, then runs deploy.sh.
# This file should rarely change — keep it minimal.
set -euo pipefail

cd "${NAVIDROME_DEPLOY_DIR}"
git pull origin main
exec "${NAVIDROME_DEPLOY_DIR}/deploy.sh"
