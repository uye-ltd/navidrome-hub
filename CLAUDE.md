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

## Architecture

The setup follows a standard Docker Compose pattern:
- Environment variables in `.env` are substituted into `docker-compose.yaml`
- `data/navidrome.toml` is bind-mounted into the Navidrome container for persistent configuration
- `backups/` and `logs/` are bind-mounted volumes for persistent data outside the container

When editing `docker-compose.yaml`, keep secrets (passwords, API keys) in `.env`, not inline. Mirror any new `.env` variables into `.env.example` with placeholder values.
