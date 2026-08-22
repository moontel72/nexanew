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

### Unified realtime sync (Phase 1)

Scoreboard data is **push-first**: the Rust media engine subscribes to the
manager's Laravel Reverb feed (`cricket.match.{id}` channels) and forwards
`score_updated` events to this GUI over the control-plane WebSocket — no
browser-side polling of the manager. REST polling survives only as a
watchdog fallback (and as a GUI fallback when the control feed is
offline).

Cross-panel deep links are supported out of the box:
- `?sso=<media-engine JWT>` — adopted as the session token (minted by the
  Cricket Manager via `POST /api/v1/studio/exchange`); one-click sign-in.
- `?match=<id>` — initial scoreboard match until the engine's pushed
  `active_match_id` (mirrored from the manager's match selection) arrives.

Both query parameters are stripped from the URL after use.

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

`npm run build:web` is an explicit alias for the same web production
bundle — the two scripts coexist so CI and local workflows never break.

## Desktop build (Windows .exe installer)

```bash
npm run build:desktop            # NSIS + MSI installers (bundle.targets: "all")
npm run build:desktop:nsis       # NSIS .exe setup only
npm run build:desktop:msi        # MSI only
npm run build:desktop:dry-run    # print the resolved build environment
```

The desktop launcher (`scripts/build-desktop.mjs`) bakes the committed
`.env.desktop` template into the package: its `VITE_*` values are injected
into the process environment before `tauri build`, so the inner Vite
production build freezes them into `import.meta.env`. Override any value
per build by pre-setting the same variable in the shell (process env wins):

```powershell
# PowerShell
$env:VITE_API_BASE_URL="http://10.0.0.5:8080"; npm run build:desktop
```

```bash
# bash
VITE_API_BASE_URL=http://10.0.0.5:8080 npm run build:desktop
```

Output installers land in `src-tauri/target/release/bundle/`
(`nsis/*-setup.exe`, `msi/*.msi`). The packaged app defaults to a **local**
media engine (`http://127.0.0.1:8080`) — point it at a remote engine by
overriding `VITE_API_BASE_URL` at build time.

### Desktop-specific requirements

- **CORS:** the packaged app origin is `tauri://localhost`. The media
  engine must include it in `CORS_ALLOWED_ORIGINS` (the WHEP
  `POST application/sdp` triggers a preflight), and the SSO login URL
  must be absolute (`VITE_STUDIO_LOGIN_URL` in `.env.desktop`).
- **GPU:** WebView2 (Chromium) enables hardware-accelerated video decode
  by default — keep GPU acceleration on for multi-camera WHEP playback.
- **Installer:** NSIS installs per-user (no admin prompt;
  `bundle.windows.nsis.installMode: "currentUser"`). Unsigned builds show
  the standard SmartScreen warning until code-signing is configured.

## Backend contracts used

| Contract | Method | Notes |
| --- | --- | --- |
| `/api/v1/room/list` | `GET` | Admin; superseded by the control-plane WS for live updates |
| `/api/v1/room/{id}/camera` | `POST` | Admin; add a camera to a live room |
| `/api/v1/room/{id}/camera/{camera}` | `PUT` / `DELETE` | Admin; update metadata / remove a camera |
| `/api/v1/control/ws` | `WS` | Admin; rooms + cameras + PGM + cricket config + pushed scores |
| `/api/v1/cricket/config` | `GET` / `PUT` | Admin; runtime match ids, API token, poll interval (poll = fallback only) |
| `/api/v1/whep/watch/{room}/{camera}` | `POST` | Viewer; WHEP egress per camera |
| `/api/v1/program/transition` | `POST` | Admin; Cut/Fade/LumaWipe/Stinger + optional `duration_ms`, scene `layout`, `stinger` asset |
| `/api/v1/program/{room}` | `GET` | Admin; current program state (reconcile after a lost control feed) |
| `/api/v1/whep/program/{room}` | `POST` | Viewer; WHEP egress for the composite PGM (gst builds) |
| `/api/v1/replay/trigger` | `POST` | Admin; instant replay / slow-motion |
| `/api/v1/audio/mix/{room}` | `GET` / `PUT` | Admin; audio console config + metering |
| `/api/v1/cricket/live/{match_id}` | `GET` | Admin; cached scoreboard lower-third |
| `/api/v1/cricket/ws` | `WS` | Push feed of cached matches |
| `/api/v1/telemetry/ws` | `WS` | Stream diagnostics feed |
