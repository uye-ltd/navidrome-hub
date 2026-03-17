#!/usr/bin/env bash
set -euo pipefail

cd "${NAVIDROME_DEPLOY_DIR}"

if [[ "${1:-}" != "--post-pull" ]]; then
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] deploy started"
  git pull origin main
  exec "$0" --post-pull
fi

docker compose pull
docker compose up -d
docker compose restart navidrome

ln -sfn "${NAVIDROME_DEPLOY_DIR}/static/favicons" "${NAVIDROME_DEPLOY_DIR}/static/app"

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] deploy finished"
