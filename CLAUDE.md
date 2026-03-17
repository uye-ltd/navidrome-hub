# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Docker Compose configuration repository for a [Navidrome](https://www.navidrome.org/) self-hosted music streaming server, managed for the UYE media server setup.

## Common Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart a specific service
docker compose restart navidrome

# Pull latest images
docker compose pull
```

## Repository Structure

- `docker-compose.yaml` — service definitions (Navidrome and any supporting services)
- `data/navidrome.toml` — Navidrome configuration file (mounted into the container)
- `.env` / `.env.example` — environment variables referenced in `docker-compose.yaml` (e.g. ports, paths, credentials)
- `backups/` — backup storage directory
- `logs/` — log output directory
- `static/favicons/` — custom favicon files served by Caddy (intercepted before reaching Navidrome)
- `Caddyfile` — Caddy reverse proxy configuration; must be applied manually on the server at `/etc/caddy/Caddyfile`
- `entrypoint.sh` — fixed script called by the webhook daemon; does `git pull` then `exec`s into `deploy.sh`
- `deploy.sh` — main deploy script (runs docker compose, creates symlinks, etc.); always executed at its latest version because `entrypoint.sh` pulls first

## Architecture

The setup follows a standard Docker Compose pattern:
- Environment variables in `.env` are substituted into `docker-compose.yaml`
- `data/navidrome.toml` is bind-mounted into the Navidrome container for persistent configuration
- `backups/` and `logs/` are bind-mounted volumes for persistent data outside the container

Caddy sits in front of Navidrome at `navidrome.uye.rocks`. Requests to `/app/favicon*`, `/app/android-chrome*`, `/app/apple-touch-icon*`, `/app/mstile*`, `/app/safari-pinned-tab.svg`, and `/app/browserconfig.xml` are intercepted by Caddy and served from `static/favicons/` on the host, bypassing the Navidrome container entirely. After updating `Caddyfile` or `static/favicons/`, reload Caddy on the server:

```bash
sudo systemctl reload caddy
```

When editing `docker-compose.yaml`, keep secrets (passwords, API keys) in `.env`, not inline. Mirror any new `.env` variables into `.env.example` with placeholder values.

`hooks.json` is pre-processed via `envsubst` at webhook service startup and written to `/tmp/hooks.json`. After changing `hooks.json`, restart the webhook service on the server for changes to take effect:

```bash
sudo systemctl restart webhook
```
