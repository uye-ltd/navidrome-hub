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

**5. Patch default Navidrome static with custom assets**
Use the reverse proxy to intercept requests for favicons and static images,
serving them from `static/favicons/` and `static/images_/` on the host instead of
from the Navidrome container.

e.g.:
```caddy
navidrome.uye.rocks {
    @appstatic {                                                                      
      path /app/*                                                                   
      file {                                                                        
          root /home/rwrotson/navidrome-hub/static
          try_files {path}                                                          
      }                   
    }    
    handle @appstatic {
        root * /home/rwrotson/navidrome-hub/static
        file_server                               
    }                                                                                 
                                                                                      
    @staticimages path /static/images_/*                                              
    handle @staticimages {                                                            
        root * /home/rwrotson/navidrome-hub
        file_server                        
    }              
     
    reverse_proxy localhost:4533
}
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
5. In a browser, verify favicons and the custom login background appear correctly on `navidrome.uye.rocks`