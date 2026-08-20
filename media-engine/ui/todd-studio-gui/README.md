# Todd Studio GUI

Tauri 2.x + React + TypeScript + TailwindCSS director control room for the
T-Odd media engine. It renders live WHEP previews, the PGM/PVW vision
switcher, replay triggers, the scoreboard lower-third, and the 3D overlay
layer.

## Prerequisites

- Node.js **20+** (the project is verified on Node 26)
- Rust toolchain (for the Tauri desktop shell)
- Optional: Tauri platform prerequisites for Windows, macOS or Linux

## One-time setup

```bash
cd media-engine/ui/todd-studio-gui
npm install
```

## Environment

Copy the example env file and adjust the values:

```bash
cp .env.example .env.local
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `VITE_API_BASE_URL` | *(empty → same-origin)* | Signaling control plane base URL |
| `VITE_STUDIO_LOGIN_URL` | `/api/v1/studio/login` | Phase-1 SSO identity provider (Laravel) login endpoint |
| `VITE_CRICKET_MANAGER_URL` | *(empty)* | External manager origin (shown in the settings panel; the backend sync is configured at runtime via `PUT /api/v1/cricket/config`) |
| `VITE_STUN_URL` | *(empty)* | STUN server for local WHEP viewers (ICE is host-only when unset) |
| `VITE_TURN_URL` | *(empty)* | Optional TURN server |
| `VITE_GFX_ASSET_URL` | *(empty)* | Optional transparent GLTF/WebM overlay asset |

### Studio login (Phase 1 SSO)

The director UI is gated behind a login screen. Credentials are posted to
the Laravel identity provider (`POST {VITE_STUDIO_LOGIN_URL}` with
`{email, password}`), which returns a JWT (`token`) carrying
`role: "admin"` and `perms: ["studio_director"]`. The JWT is stored in
`localStorage` (`todd_studio_jwt`) and attached as `Authorization: Bearer`
on every engine request; a `401` from the engine clears the token and
returns to the login screen. The endpoint is configurable via
`VITE_STUDIO_LOGIN_URL` above — by default it is the relative
`/api/v1/studio/login`, which the studio nginx proxies to the Laravel
backend on the same server (`/api/v1/studio/*`), so no separate
`admin.traceodd.com` DNS or CORS is needed.

## Develop

```bash
npm run dev
```

This serves the Vite dev server on `http://localhost:5173`.

To run the full desktop shell:

```bash
npm run tauri dev
```

## Production build

```bash
npm run build
```

Output goes to `dist/`. The build runs `tsc` (type-check) followed by
`vite build` (bundling). Vite code-splitting separates React and Three.js
into `react-vendor` and `three-vendor` chunks to keep the main entry small.

## Backend contracts used

| Contract | Method | Notes |
| --- | --- | --- |
| `/api/v1/room/list` | `GET` | Admin; superseded by the control-plane WS for live updates |
| `/api/v1/room/{id}/camera` | `POST` | Admin; add a camera to a live room |
| `/api/v1/room/{id}/camera/{camera}` | `PUT` / `DELETE` | Admin; update metadata / remove a camera |
| `/api/v1/control/ws` | `WS` | Admin; rooms + cameras + PGM + cricket config (push) |
| `/api/v1/cricket/config` | `GET` / `PUT` | Admin; runtime match ids, API token, poll interval |
| `/api/v1/whep/watch/{room}/{camera}` | `POST` | Viewer; WHEP egress per camera |
| `/api/v1/program/transition` | `POST` | Admin; Cut/Fade/LumaWipe/Stinger + optional `duration_ms`, scene `layout`, `stinger` asset |
| `/api/v1/program/{room}` | `GET` | Admin; current program state (reconcile after a lost control feed) |
| `/api/v1/whep/program/{room}` | `POST` | Viewer; WHEP egress for the composite PGM (gst builds) |
| `/api/v1/replay/trigger` | `POST` | Admin; instant replay / slow-motion |
| `/api/v1/audio/mix/{room}` | `GET` / `PUT` | Admin; audio console config + metering |
| `/api/v1/cricket/live/{match_id}` | `GET` | Admin; cached scoreboard lower-third |
| `/api/v1/cricket/ws` | `WS` | Push feed of cached matches |
| `/api/v1/telemetry/ws` | `WS` | Stream diagnostics feed |
