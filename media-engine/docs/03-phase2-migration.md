# 03 — Phase 2: Dedicated Media Server Migration Blueprint

Goal: move the Rust media engine to its own server by changing **only
environment variables** — no Laravel code changes, no client changes,
no downtime.

## 1. The seam: `MEDIA_ENGINE_URL`

Laravel's only knowledge of the engine is one config value:

```php
// config/services.php
'media_engine' => [
    'url'    => env('MEDIA_ENGINE_URL', 'http://127.0.0.1:8080'),
    'secret' => env('MEDIA_ENGINE_JWT_SECRET'),
    'issuer' => env('MEDIA_ENGINE_JWT_ISSUER', 'traceodd'),
    'timeout' => 5,
],
```

Phase 1: `MEDIA_ENGINE_URL=http://127.0.0.1:8080`
Phase 2: `MEDIA_ENGINE_URL=https://media.traceodd.com`

The JWT secret is identical on both servers, so tokens minted by the app
server verify on the media server without any shared database or session
store. **That is the entire cross-server trust model** — no Laravel API
calls from the media server, no shared filesystem.

## 2. What changes, what doesn't

| Concern | Phase 1 | Phase 2 | Change required |
|---|---|---|---|
| Laravel → engine URL | loopback | public DNS | `.env` value |
| JWT secret | shared | shared | none |
| Clients (cameras) | same URL | same URL | **none** (URL stays media.traceodd.com) |
| Studio → Broadcaster | embedded | remote | `MEDIA_PLANE=remote`, `BROADCASTER_URL` |
| CORS | disabled | `CORS_ALLOWED_ORIGINS=https://cricket.traceodd.com` | env only |
| Docker images | optional | required | none (images built since Phase 1) |
| Room state | in-memory | in-memory (+ Redis later) | none initially |

Keeping the public WHIP URL constant is deliberate: clients embed
`whip_base_url` from the room-create response, so as long as the DNS name
doesn't change, a server move is invisible to them.

## 3. Docker strategy

One Dockerfile, two services (see `deploy/docker/Dockerfile`):

- `traceodd/todd-studio` — control plane
- `traceodd/todd-broadcaster` — media plane (with GStreamer + plugins baked
  into the Ubuntu 24.04 runtime layer)

The compose file (`deploy/docker/docker-compose.yml`) defines studio,
broadcaster, redis (reserved for HA), and an opt-in coturn profile with
host networking (required for the UDP relay range).

Phase 1 already uses these images if you prefer containers to systemd —
the artifacts are identical either way, which is the portability win:
`docker save` / a private registry / `docker compose` on the new host, and
the engine runs exactly as it did on the old one.

## 4. Migration runbook

```bash
# ---- on the NEW media server (Ubuntu 24.04) ----
# 1. Firewall
sudo ufw allow 443/tcp
sudo ufw allow 3478/tcp && sudo ufw allow 3478/udp && sudo ufw allow 5349/tcp
sudo ufw allow 49160:49200/udp

# 2. Deploy (Docker Compose)
mkdir -p /opt/todd-media-engine && cd /opt/todd-media-engine
# copy: media-engine/ (deploy/docker, .env)
docker compose -f deploy/docker/docker-compose.yml up -d
docker compose --profile turn -f deploy/docker/docker-compose.yml up -d

# 3. .env on the media server
# STUDIO_HOST=0.0.0.0, BROADCASTER_HOST=0.0.0.0 (inside containers)
# TURN_SERVERS=turnuser:turnpass@media.traceodd.com:3478
# PUBLIC_BASE_URL=https://media.traceodd.com

# 4. nginx on the media server (same conf as Phase 1)
#    + certbot --nginx -d media.traceodd.com

# ---- DNS cutover ----
# 5. media.traceodd.com  A/AAAA → new server IP (lower TTL 300s beforehand)

# ---- on the OLD shared server ----
# 6. Laravel .env: MEDIA_ENGINE_URL=https://media.traceodd.com
#    php artisan config:cache

# 7. Smoke test (doc 02 §7) against the new server.

# 8. Tear down: systemctl disable --now todd-studio (or compose down),
#    remove the nginx media vhost, optionally keep coturn for dev.
```

Rollback = reverse steps 5–6 (point DNS back, reset the env var). Room
state is ephemeral by design, so a rollback mid-broadcast only affects
sessions created in the window.

## 5. CORS (only matters in Phase 2)

Phase 1: browsers talk same-origin (cricket.traceodd.com → nginx →
Rust) — CORS is unnecessary and disabled by default.

Phase 2: if a browser on cricket.traceodd.com calls the media origin
directly (e.g. WebRTC viewer pages), set:

```env
CORS_ALLOWED_ORIGINS=https://cricket.traceodd.com
```

The Studio then sends permissive method/header rules for those origins.
Server-to-server calls (Laravel → Studio) are unaffected — CORS is a
browser mechanism only.

## 6. Sizing reference (media server)

| Load | Spec |
|---|---|
| 1–4 cameras, pass-through routing, no re-encode | 2 vCPU / 4 GB |
| 4–8 cameras, RTMP re-encode (ultrafast) | 4 vCPU / 8 GB |
| 8+ cameras or 1080p60 re-encode | 8 vCPU / 16 GB, NVMe for recordings |

Bandwidth: outbound = Σ(forward target bitrates) + TURN relay for
NAT-ed cameras. Inbound = ingest bitrates (typically 2–8 Mbps per
camera at 1080p).

## 7. Phase 2.5 (future): HA & scale-out

- Room/session state: flip `ROOM_STORE=redis` (the backend ships with the
  engine) and run multiple Studio replicas behind the nginx upstream —
  rooms and sessions are already shared via Redis.
- Broadcaster becomes a pool: Studio assigns cameras round-robin via the
  existing `MediaPlane` seam; add a `MEDIA_PLANE` selector registry.
- TURN credentials move to coturn REST API, minted per room token.
