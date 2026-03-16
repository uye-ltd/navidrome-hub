# navidrome-hub

Docker Compose configuration for the Navidrome UYE media server.

## Setup

1. Copy `.env.example` to `.env` and fill in your values
2. Start the stack:
   ```bash
   docker compose up -d
   ```

## Auto-Deploy via Webhook

On every push to `main`, GitHub sends a signed POST request to the server, which pulls the latest code and restarts the stack.

```
GitHub push → POST /hooks/deploy → deploy.sh → git pull + docker compose up -d
```

### Server-side setup (one-time)

**1. Clone the repo**
```bash
git clone https://github.com/<org>/navidrome-hub /home/rwrotson/navidrome-hub
```

**2. Install the webhook daemon**
```bash
sudo apt install webhook
```

**3. Create `/etc/systemd/system/webhook.service`**
```ini
[Unit]
Description=GitHub Webhook Listener
After=network.target

[Service]
ExecStart=/usr/bin/webhook -hooks ${NAVIDROME_DEPLOY_DIR}/hooks.json -port 9000 -verbose
Restart=always
User=${NAVIDROME_DEPLOY_USER}
Environment=WEBHOOK_SECRET=<your-secret>
Environment=NAVIDROME_DEPLOY_DIR=/home/rwrotson/navidrome-hub
Environment=NAVIDROME_DEPLOY_USER=rwrotson

[Install]
WantedBy=multi-user.target
```

**4. Enable and start**
```bash
sudo systemctl enable --now webhook
```

### GitHub webhook setup

Repo → Settings → Webhooks → Add webhook:
- **Payload URL**: `http://<server-ip>:9000/hooks/deploy`
- **Content type**: `application/json`
- **Secret**: same value as `WEBHOOK_SECRET` in the systemd unit
- **Events**: Just the push event

### Verification

1. Push a commit to `main`
2. GitHub → Settings → Webhooks → Recent Deliveries — should show `200`
3. On server: `journalctl -u webhook -f`
4. `docker compose ps` should show the updated container
