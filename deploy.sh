#!/usr/bin/env bash
set -euo pipefail

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] deploy started"

cd "${NAVIDROME_DEPLOY_DIR}"
git pull origin main
docker compose pull
docker compose up -d

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] deploy finished"
