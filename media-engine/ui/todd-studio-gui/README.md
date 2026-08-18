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
| `VITE_API_BASE_URL` | `http://127.0.0.1:8080` | Signaling control plane base URL |
| `VITE_ADMIN_TOKEN` | *(empty)* | Admin JWT for director control calls |
| `VITE_VIEWER_TOKEN` | *(empty)* | Viewer JWT for WHEP playback |
| `VITE_CRICKET_MANAGER_URL` | `https://cricket-manager.traceodd.com` | External manager (used by the backend sync) |
| `VITE_STUN_URL` | `stun:stun.l.google.com:19302` | STUN server for local WHEP viewers |
| `VITE_TURN_URL` | *(empty)* | Optional TURN server |
| `VITE_GFX_ASSET_URL` | *(empty)* | Optional transparent GLTF/WebM overlay asset |

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
| `/api/v1/room/list` | `GET` | Admin; populates the multiview grid |
| `/api/v1/whep/watch/{room}/{camera}` | `POST` | Viewer; WHEP egress per camera |
| `/api/v1/program/transition` | `POST` | Admin; Cut/Fade/Stinger source switch |
| `/api/v1/whep/program/{room}` | `POST` | Viewer; WHEP egress for current PGM |
| `/api/v1/replay/trigger` | `POST` | Admin; instant replay / slow-motion |
| `/api/v1/cricket/live/{match_id}` | `GET` | Admin; cached scoreboard lower-third |
| `/api/v1/cricket/ws` | `WS` | Push feed of cached matches |
| `/api/v1/telemetry/ws` | `WS` | Stream diagnostics feed |
