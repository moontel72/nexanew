# 08 — Cricket Instant Replay Engine (Phase 3)

The `todd-replay` crate: circular RAM ring buffer, slow-motion processor
and clip exporter.

## 1. Ring buffer (`ring.rs`)

Every RTP packet of every camera is captured on the WHIP hot path into a
per-`(room, camera)` ring:

- **Zero-copy retention**: frames hold `Bytes` references to the RTP
  payloads the router already owns — a reference-count bump, no payload
  copy.
- **Lock-free hot path**: the pump does a bounded-channel `try_send`
  (16 384 deep); ring mutation happens in one dedicated task per camera.
  When saturated, packets are dropped — the replay buffer never stalls
  ingest.
- **Bounded memory**: age-based pruning within the retention window
  (`REPLAY_BUFFER_MS`, default 15 s, range 3–30 s) plus a hard cap of
  100 k frames per camera.
- Snapshots (triggers, exports) are answered by the camera task via a
  request channel — readers never contend with the writer.

## 2. Slow motion (`retime.rs`)

Time-scale RTP retiming operates at the **frame level**: packets sharing
an RTP timestamp form one access unit (fragmented H.264/VP8 frames stay
intact), and each unit is repeated or dropped by the speed factor:

- `0.5x` → every frame emitted twice; the output timeline advances by
  the frame's original duration per copy → half-speed playback via
  frame repetition (decoder-safe).
- `2.0x` → every other frame dropped.
- `0.25x`/`0.75x`/`1.0x` via the same accumulation logic (supported
  range 0.1x–4.0x).
- Output timestamps and sequence numbers are rewritten; SSRC and
  payloads are untouched. `spacing` on each packet drives real-time
  pacing (zero within a frame, one frame duration after each copy).

## 3. Replay sessions (`session.rs`)

`POST /api/v1/replay/trigger` with a [`ReplayTrigger`] (event: run_out /
wicket / boundary / catch / custom, cameras, lookback, speed,
loop_playback) snapshots the ring and starts one paced broadcast per
camera. Playback loops on demand for continuous director review; the
session finishes when every camera stream completed.

**WHEP replay egress**: `POST /api/v1/replay/watch/{replay_id}/{camera_id}`
creates a viewer PeerConnection fed from the replay session's paced
stream (video + audio demuxed by kind) — the Studio director reviews the
slomo feed on a preview monitor before pushing it to program. Replay
viewers reuse the standard WHEP session lifecycle (grace watchdogs,
telemetry).

## 4. Clip exporter (`export.rs`)

`POST /api/v1/replay/{replay_id}/export` starts an async export job:

- The snapshot is retimed at the session speed (or a per-export override)
  and fed **unpaced** into the Phase 2 transcode forwarder (depay →
  decode → re-encode → mux).
- The URL extension selects the container: `.mp4` → `mp4mux`,
  `.webm` → `webmmux`, otherwise Matroska.
- Audio is routed per bus via the RID convention and muxed as AAC.
- Status (`pending` → `running` → `done`/`failed`) is tracked in the
  manager's export registry; job completion is also broadcast on the
  replay notification channel (WebSocket surface lands with the Studio
  UI) and POSTed to `REPLAY_EXPORT_CALLBACK_URL` (the TraceOdd cloud
  webhook replacing the legacy `POST /replay/chunk`).

This absorbs the legacy chunker deleted in Phase 0: the ring replaces
HLS directory polling, retimed replay replaces ffmpeg
concat/trim/`setpts` speed filters, and the async task + status registry
replaces the hand-rolled HTTP server and ad-hoc Laravel callback.

## 5. API surface (both signaling and standalone SFU)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/v1/replay/trigger` | admin | Trigger a replay from the ring |
| GET | `/api/v1/replay/list` | admin | List live replay sessions |
| DELETE | `/api/v1/replay/{id}` | admin | Close a replay session |
| POST | `/api/v1/replay/{id}/export` | admin | Start an async clip export |
| POST | `/api/v1/replay/watch/{id}/{camera}` | viewer | WHEP slomo preview egress |

## 6. Configuration

| Env | Default | Meaning |
|---|---|---|
| `REPLAY_BUFFER_MS` | 15000 | Ring retention window (clamped 5–30 s) |
| `REPLAY_EXPORT_CALLBACK_URL` | — | Webhook POSTed the final export status on completion |

## 7. Known v1 limits

- Clip export requires the `gst` feature (CI-verified on ubuntu-24.04).
- Export completion is detected by feed exhaustion + a fixed flush
  window; a true EOS handshake from the forwarder is Phase 4 work.
- Replay playback audio runs at the slowed rate (pitch drop); atempo
  pitch correction is a Phase 4 refinement.
- Replay watch authorizes any viewer token; per-room scoping of replays
  is enforced at trigger time by the caller.
