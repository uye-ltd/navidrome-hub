# navidrome-hub

Docker Compose configuration for the Navidrome UYE media server.

## Setup

1. Copy `.env.example` to `.env` and fill in your values
2. Start the stack:
   ```bash
   docker compose up -d
   ```

## Reverse Proxy (SSL Termination)

Navidrome runs plain HTTP inside the container. SSL should be terminated at the reverse proxy.

Set `BaseUrl` in `data/config.toml` to your public HTTPS URL:

```toml
BaseUrl = "https://music.yourdomain.com"
```

Configure your reverse proxy to forward to `http://<host>:4533` and pass these headers:

```
X-Forwarded-For
X-Forwarded-Proto: https
X-Real-IP
Host
```

To prevent direct access to Navidrome (bypassing the proxy), restrict the host binding in `docker-compose.yaml`:

```yaml
ports:
  - "127.0.0.1:4533:4533"
```

`TLSCert`/`TLSKey` should remain unset — those are only for running Navidrome with direct TLS.

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

**3. Install the systemd unit from the repo**
```bash
sudo cp /home/rwrotson/navidrome-hub/webhook.service /etc/systemd/system/webhook.service
sudo systemctl daemon-reload
```

`webhook.service` loads `.env` via `EnvironmentFile=`, so `WEBHOOK_SECRET` (and other
variables) are available to the webhook binary without hardcoding them in the unit.

**4. Enable and start**
```bash
sudo systemctl enable --now webhook
```

### GitHub webhook setup

Repo → Settings → Webhooks → Add webhook:
- **Payload URL**: `http://<server-ip>:9000/hooks/deploy`
- **Content type**: `application/json`
- **Secret**: same value as `WEBHOOK_SECRET` in `.env`
- **Events**: Just the push event

### Verification

1. Push a commit to `main`
2. GitHub → Settings → Webhooks → Recent Deliveries — should show `200`
3. On server: `journalctl -u webhook -f`
4. `docker compose ps` should show the updated container

## Custom Favicons

Navidrome serves all icon assets from `/app/` (e.g. `/app/favicon-32x32.png`). Custom favicons are injected at the Caddy layer — Caddy intercepts those paths and serves files from `static/favicons/` in this repo instead, so the Navidrome container is never modified.

### How it works

Add this block to the `navidrome.uye.rocks` site in your Caddyfile (lives in the Caddy config repo):

```caddyfile
@appicons path /app/favicon* /app/android-chrome* /app/apple-touch-icon* /app/mstile* /app/safari-pinned-tab.svg /app/browserconfig.xml
handle @appicons {
    uri strip_prefix /app
    root * /home/rwrotson/navidrome-hub/static/favicons
    file_server
}
```

`uri strip_prefix /app` rewrites `/app/favicon-32x32.png` → `/favicon-32x32.png` before `file_server` resolves it under `root`.

### Updating favicon files

1. Replace files in `static/favicons/` (all 18 files must keep their exact names)
2. Commit and push — `deploy.sh` syncs the repo on the server via `git pull`
3. No Caddy reload needed; `file_server` reads from disk on each request

To regenerate all sizes from a single 512×512 source PNG:

```bash
# Requires Pillow: pip install Pillow
python3 - << 'EOF'
from PIL import Image
import os

src = "media/favicons/favicon_512x512.png"
out = "static/favicons"
img = Image.open(src).convert("RGBA")

sizes = {
    "favicon-16x16.png": (16, 16), "favicon-32x32.png": (32, 32),
    "android-chrome-192x192.png": (192, 192), "android-chrome-512x512.png": (512, 512),
    "apple-touch-icon.png": (180, 180), "apple-touch-icon-60x60.png": (60, 60),
    "apple-touch-icon-76x76.png": (76, 76), "apple-touch-icon-120x120.png": (120, 120),
    "apple-touch-icon-152x152.png": (152, 152), "apple-touch-icon-180x180.png": (180, 180),
    "mstile-70x70.png": (70, 70), "mstile-144x144.png": (144, 144),
    "mstile-150x150.png": (150, 150), "mstile-310x310.png": (310, 310),
}
for name, (w, h) in sizes.items():
    img.resize((w, h), Image.LANCZOS).save(os.path.join(out, name), "PNG")

# mstile-310x150: center 150×150 icon on wide canvas
canvas = Image.new("RGBA", (310, 150), (0, 0, 0, 0))
icon = img.resize((150, 150), Image.LANCZOS)
canvas.paste(icon, (80, 0), icon)
canvas.save(os.path.join(out, "mstile-310x150.png"), "PNG")
EOF
```

`favicon.ico` and `safari-pinned-tab.svg` must be provided or generated separately.

### Verification

```bash
# Each should return HTTP/2 200
curl -sI https://navidrome.uye.rocks/app/favicon-32x32.png
curl -sI https://navidrome.uye.rocks/app/android-chrome-192x192.png
curl -sI https://navidrome.uye.rocks/app/apple-touch-icon.png
curl -sI https://navidrome.uye.rocks/app/mstile-150x150.png
curl -sI https://navidrome.uye.rocks/app/safari-pinned-tab.svg
```