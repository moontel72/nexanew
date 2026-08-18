# T-Odd Media Engine

High-performance, ultra-low latency broadcasting suite in Rust.

| Crate | Role |
|---|---|
| `todd-signaling` | Axum control plane — rooms, Bearer-token auth, multi-camera routing, forwarding control (binary `todd-studio`) |
| `todd-sfu` | WebRTC media plane — WHIP ingest, WHEP egress, simulcast routing, PLI forwarding (binary `todd-broadcaster`) |
| `todd-transcode` | GStreamer pipelines — hardware-acceleration matrix, multichannel audio mixer |
| `todd-common` | Shared JWT auth, config, DTOs, error type |
| `todd-telemetry` | Prometheus metrics + WebSocket diagnostics |
| `todd-replay` | Cricket instant replay: ring buffer, slow motion, clip export |
| `todd-cricket` | Cricket scoring recompute |

The engine is fully decoupled from the Laravel app (`../backend`): Laravel
talks to it exclusively through `MEDIA_ENGINE_URL` + shared-secret JWTs, so
moving it to a dedicated media server later is an env-var change.

## Quick start (dev)

```bash
# Windows (PowerShell): .\scripts\dev.ps1 check|build|run|test
# Linux/WSL:            ./scripts/dev.sh check|build|run|test

cp .env.example .env
# edit .env — at minimum set a real JWT_SECRET

# Studio (with the SFU engine embedded — Phase 1 mode):
cargo run -p todd-signaling

# Standalone SFU (Phase 2 mode, second terminal):
cargo run -p todd-sfu
```

### Studio GUI (director control room)

The production Studio UI lives in `ui/todd-studio-gui`. Build and serve it
with nginx (see `ui/todd-studio-gui/README.md`). It drives the same
WHIP/WHEP/replay/scoreboard APIs documented below.

Mint a dev admin token to call the API:

```bash
JWT_SECRET=<same secret> cargo run -p todd-common --example mint_token -- admin
```

Create a room and ingest:

```bash
TOKEN=<admin token>
curl -sS -X POST http://127.0.0.1:8080/api/v1/room/create \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"match-1","camera_ids":["cam-1"],"ttl_secs":3600}'
# → returns per-camera ingest_tokens + whip_base_url

curl -sS -X POST "http://127.0.0.1:8080/api/v1/whip/ingest/<room_id>/cam-1?token=<ingest_token>" \
  -H "Content-Type: application/sdp" --data-binary @offer.sdp
# → 201 with SDP answer; DELETE the returned Location header to close
```

## Building with GStreamer forwarding

`cargo run --features gst` requires system libraries on the build host:

```bash
# Ubuntu 24.04
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
  gstreamer1.0-libav
```

Without the feature, WHIP ingestion and routing work fully; only
`POST /api/v1/room/{id}/forward` returns 501.

## Endpoints

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/v1/room/create` | admin | Create room + mint ingest/viewer tokens |
| GET | `/api/v1/room/list` | admin | List rooms |
| GET | `/api/v1/room/{id}` | room-scoped | Room status (active cameras) |
| DELETE | `/api/v1/room/{id}` | admin | Tear down room + sessions |
| POST | `/api/v1/room/{id}/forward` | admin | Attach RTMP/SRT/file forwarder to a camera |
| POST | `/api/v1/whip/ingest/{room}/{camera}` | publisher | WHIP ingest (SDP offer → answer) |
| DELETE | `/api/v1/whip/session/{id}` | publisher/admin | Close a WHIP session |
| POST | `/api/v1/whep/watch/{room}/{camera}` | viewer | WHEP watch (SDP offer → answer) |
| DELETE | `/api/v1/whep/session/{id}` | viewer | Close a WHEP viewer session |
| POST | `/api/v1/replay/trigger` | admin | Trigger an instant replay from the ring buffer |
| GET | `/api/v1/replay/list` | admin | List live replay sessions |
| DELETE | `/api/v1/replay/{id}` | admin | Close a replay session |
| POST | `/api/v1/replay/{id}/export` | admin | Start an async clip export |
| POST | `/api/v1/replay/watch/{id}/{camera}` | viewer | WHEP slow-motion preview egress |
| GET | `/metrics` | none* | Prometheus metrics (see `docs/06-ice-and-telemetry.md`) |
| GET | `/api/v1/telemetry/ws` | none* | WebSocket diagnostics feed (JSON snapshots) |
| GET | `/healthz`, `/readyz` | none | Liveness / readiness |

*Metrics/telemetry endpoints carry aggregate diagnostics only (no
media, no tokens). Protect them at the nginx layer if exposed publicly.

## Documentation

- `docs/01-architecture.md` — full architecture, auth model, data flow
- `docs/02-phase1-single-server.md` — shared-VPS runbook (nginx/systemd/firewall)
- `docs/03-phase2-migration.md` — dedicated media server + Docker migration
- `docs/04-laravel-integration.md` — Laravel-side config, client, token minting
- `docs/05-local-dev-windows.md` — Windows toolchain & IDE setup guide
- `docs/06-ice-and-telemetry.md` — ICE resilience policy, telemetry endpoints
  and metric reference
- `docs/07-sfu-architecture.md` — SFU crate decomposition, webrtc-rs 0.17
  upgrade, simulcast/PLI/NACK, hardware-acceleration matrix, audio buses
- `docs/08-replay-engine.md` — cricket instant replay: ring buffer,
  slow-motion retiming, replay WHEP egress, clip exporter

## Storage backends

Room/session state lives behind a `RoomStore` trait with two backends
(`crates/todd-studio/src/store.rs`):

- `ROOM_STORE=memory` (default) — in-process DashMaps, single instance
- `ROOM_STORE=redis` + `REDIS_URL=redis://127.0.0.1:6379/0` — shared state
  across Studio replicas/hosts, with per-key TTLs

## Layout

```
media-engine/
├── crates/{todd-common,todd-cricket,todd-telemetry,todd-transcode,
│           todd-sfu,todd-signaling}/
├── deploy/nginx/            reverse-proxy configs (subdomain + path mode)
├── deploy/systemd/          hardened service units (bare-metal Phase 1)
├── deploy/docker/           Dockerfile, docker-compose, coturn.conf
└── docs/
```
