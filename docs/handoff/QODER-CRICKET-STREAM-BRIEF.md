# QODER BRIEF — Cricket live video: remaining fault + sub-second (WHEP) public screen

**Read-only investigation requested.** Please produce a report (and, where you are
confident, the patch). Do not push code without the owner's go-ahead.

**Scope of this brief**

1. The engine→SRS→HLS→public-page hop now works, but a session can still **stall**;
   §4 names the suspected root cause with `file:line` evidence and asks you to
   confirm or refute it.
2. **How to show the public stream in under a second** instead of via HLS (§6).
   The engine already serves WHEP and Todd Studio already plays it, so this is a
   re-wire, not new infrastructure.

Platform facts, the three fixes already landed, and the evidence are in §1–§5.

---

## 1. The chain

```
Todd Broadcaster (Android, WHIP)
      │  WHIP (SDP offer → answer)
Todd Studio engine — todd-signaling (Axum control plane) + todd-sfu (media plane)
      │  WHEP egress  ← Todd Studio's own previews use this (sub-second)
      │  on-air camera (PGM)
GStreamer forwarder — todd-transcode (crate `todd-transcode`, bin in todd-studio)
      │  RTMP (flvmux → rtmpsink)
SRS  (RTMP 1935, API 1985, HLS HTTP 8088, HLS dir /var/www/traceodd/cricket-hls)
      │  HLS segments: /var/www/traceodd/cricket-hls/live/{stream}.m3u8
nginx  location /hls/ { alias /var/www/traceodd/cricket-hls/; }
      │
https://cricket.traceodd.com/hls/live/{stream}.m3u8
      │
Public Flutter web page — HLS player (lib/shared/widgets/hls_video_player_web.dart)
```

- Stream key is **derived**: `cricket_match_{matchId}_cam1` (`CricketStreamSyncService::streamNameFor`).
- The public page consumes **HLS**; Studio consumes **WHEP** directly from the SFU.
  That asymmetry is why Studio always looked fine while the public page was dark.

Infra: `root@135.181.46.27`, Docker host networking, containers `todd-studio` (:8082),
`todd-broadcaster` (:8081), `todd-redis`. Deploys run from branch `mainnew` via
GitHub Actions (`Deploy to Hetzner`, `Media Engine — Build & Push Docker Image` →
`Media Engine — Deploy to VPS`). Engine image: Ubuntu 24.04 + GStreamer 1.24.

---

## 2. The original outage — FIXED (`ead72810`)

Three faults sat on the forwarder hop; the first two were found earlier and did
**not** end the outage:

| # | Fault | Fix |
|---|---|---|
| 1 | `build_description` declared an audio branch per **enabled** bus while only **primed** buses were fed → `flvmux` waited forever, video never left | `f0fc72e5` |
| 2 | priming accepted any codec, so an H.264 chunk reached an `appsrc` whose caps say OPUS | `e951903b` (codec filter, deployed and firing) |
| 3 | **the blocker** | `ead72810` |

**Fault 3, exactly:** the audio feeder's `appsrc` caps were
`application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000` — **no
`payload`**. `rtpopusdepay`'s sink pad template *fixes* `payload` to `[96, 127]`
and a caps event must carry **fixed** caps, so `set_caps` failed, the depayloader
never negotiated, and the first pushed buffer returned `GST_FLOW_NOT_NEGOTIATED`,
which the `appsrc` (a `GstBaseSrc`) reports as:

```
/GstPipeline:pipelineNNN/GstAppSrc:audio_commentary: Internal data stream error
  (../libs/gst/base/gstbasesrc.c(3177): gst_base_src_loop ():
   streaming stopped, reason not-negotiated (-4))
```

`rtph264depay`'s template has **no** `payload` field, which is why only the audio
branch died and the error always named `audio_commentary`.

Reproduce it locally (no server, GStreamer ≥1.24 — Windows setup is in
`docs/handoff/STREAMING-HISTORY-AND-FIX.md` §7):

```sh
gst-inspect-1.0 rtpopusdepay | grep -A6 "SINK template"   # payload: [ 96, 127 ]
```
Push one Opus RTP packet into the *as-shipped* branch and the error appears; add
`,payload=111` to the caps and it negotiates (`rtpopusdepay` sink caps become
`Some(... payload: 111)`). Verified both ways on 1.24.13 before the fix shipped.

**False lead, do not re-chase:** the "mixer declaration ordering" hypothesis (mixer
declared before its sink pads exist) is **wrong**. The full pipeline with real
Opus RTP reaches EOS locally, and `audiomixer` renegotiates/resamples happily
(observed negotiating 44100 Hz output with a 48000 Hz sink pad). The old
`gst-launch` A/B bisect could not decide anything because a non-live `appsrc` that
is never pushed **never negotiates at all** — the pipeline just sits at PLAYING and
looks healthy.

---

## 3. Production evidence (after `ead72810`)

```
$ curl -s http://127.0.0.1:1985/api/v1/streams/
{"streams":[{"name":"cricket_match_a2c0880f-cc5b-40d9-8d5c-6ffa3916e021_cam1",
  "publish":{"active":true},"video":{"codec":"H264","width":480,"height":800},
  "audio":{"codec":"AAC","sample_rate":44100,"channel":2}}]}
$ ls -la /var/www/traceodd/cricket-hls/live/      # fresh .m3u8 + .ts
$ docker logs --since 10m todd-studio | grep -ac "not-negotiated"   # 0
```
The public page played. The AAC/44100 audio in SRS also proves the audio branch
negotiates now.

---

## 4. REMAINING FAULT — the forwarder goes idle and keeps reporting `running`

**Symptom.** The feed publishes, then a session ends with the pipeline *alive and
idle*: the publisher goes away, nothing reaches `flvmux`, SRS drops the feed and
deletes the HLS files, the public page 404s — and the engine still reports
`state: "running"`. Because **every** recovery path skips a forwarder that claims
to be running, that stale state was **self-locking**:

- the backend watchdog prints `ok <match> — forwarder running` and re-arms nothing,
- `resyncMatch()` returns `true` immediately (so the manager panel's
  "Reconnect live video" button is a **no-op**),
- the engine's own `rearm_stale_forwarders()` skips "already running".

Observed: 40+ minutes with the publisher live, `streams:[]`, empty HLS dir, and
**nothing at all** in the engine logs (no new pipeline was ever built).

**Suspected root cause (please confirm or refute).**
`media-engine/crates/todd-sfu/src/router.rs` — `subscribe()` documents the intent:

> *"channel closes when the camera is torn down, which signals forwarders to end
> their pipelines cleanly."*

`remove_camera()` really does drop those senders (`subscribers.retain(...)`), so the
forwarder's router receiver closes. **But** the forwarder's pump takes that close
and just returns, leaving the consumer channels open:

```rust
// media-engine/crates/todd-transcode/src/forwarder.rs, spawn_input_pump
loop {
    let Some(chunk) = receiver.recv().await else {
        // The router receiver closed; there is nothing left to pump.
        return;                      // <-- consumers keep their senders
    };
    let senders = { /* consumers_for(track_index) */ };
    fan_out(&senders, chunk);
}
```

The pipeline's push tasks (`spawn_push_task`) hold the other end of those consumer
channels and only end when the channel closes — so they block forever, the appsrcs
never reach `end_of_stream()`, `flvmux` never sees EOS, the pipeline never
finalises, `watch_bus()` never reports anything, and the state stays `running`.
The router's intent ("end their pipelines cleanly") is defeated in the forwarder.

**Complicating factor for any fix.** `register_inputs()` is idempotent per track
name — it **skips** a name that is already in `track_order`. So if a track's pump
dies when the publisher disconnects, a later re-arm cannot restart it: the new
router receiver is dropped on the floor. Any fix that makes the pipeline end
cleanly must also make a dead track **revivable** (or the reconnect path gets
worse, not better). Note the consumers' channel vectors are **index-aligned** with
`track_order`, and running pumps look their senders up by index on every chunk —
so a fix must not shift indices while other pumps are alive (a HashMap keyed by a
stable track id, or a per-track generation, is the likely shape).

Also worth checking while you are in there: does a WHIP reconnect with the same
rid re-register a **new** router receiver, and does `remove_camera` actually run
when a publisher merely drops (versus the camera being torn down)? The "ghost
camera" class of bug (a `whip` camera that is registered but carries no media —
the 409 loop in Studio) is the same territory.

---

## 5. Recovery fixes already shipped (context for §4)

| Commit | What |
|---|---|
| `01f5905e` | `healthForMatch()` no longer trusts the engine's `state` alone: it asks **SRS** (`/api/v1/streams/` → `publish.active`) and reports **`stale`** when the engine says running but SRS has no active publish. A `stale` state is not `running`, so `resyncMatch()` proceeds to stop the zombie and build a fresh forwarder, and the panel shows the truth. Config: `cricket.streaming.srs_api_url`. |
| `269478ef` | A publish can be **stalled** (connection up, no media) while `publish.active` still reads `true` — SRS stops segmenting and deletes the playlist, so the public page 404s while SRS looks healthy. Health now also checks the **HLS playlist is advancing** (`cricket.streaming.hls_dir`, 30 s threshold). |
| `6c57fdc0` | `docs/handoff/` consolidated into `STREAMING-HISTORY-AND-FIX.md`; **and the Laravel scheduler is now installed by the deploy** (see below). |

**Operational gap that was found:** `cricket:stream-watchdog` is scheduled
`everyMinute()` in `backend/routes/console.php`, but **nothing installed
`schedule:run`** — `/etc/cron.d` had no entry and the root crontab held only
unrelated rsync jobs, so the watchdog **never ran automatically**. `deploy.yml` now
writes `/etc/cron.d/nexatrace-scheduler` idempotently. Worth confirming this is the
only missing supervisor/cron in the stack.

---

## 6. The requested goal: **sub-second** public screen via WHEP (WebRTC)

HLS is segmented by construction. Even perfectly tuned (3 s fragments, player one
segment off the live edge) it is ~6–10 s behind, and with a long publisher GOP it
is far worse. **The engine already speaks WHEP, and Todd Studio already plays it
in a browser at sub-second latency** — so the public page can do the same.

### 6.1 Server side — already implemented

`media-engine/crates/todd-signaling/src/routes/whep.rs` documents it:

> *"The browser-side counterpart of WHIP: viewers watch a camera live in a `<video>`
> element with sub-second latency — no OBS, no RTMP, no transcoding (pure RTP
> fan-out from the track router). The optional `?rid=` query parameter selects a
> simulcast layer (empty = lowest)."*

| Method | Path | Auth | Notes |
|---|---|---|---|
| `POST` | `/api/v1/whep/watch/{room_id}/{camera_id}` | **Viewer**, room-scoped (`claims.require_room`) | body = recvonly SDP offer → `201` + answer, `Location: /api/v1/whep/session/{id}` |
| `DELETE` | `/api/v1/whep/session/{session_id}` | Viewer | close the session |
| `POST` | `/api/v1/whep/program/{room_id}` | Viewer | WHEP egress of the **composite PGM** (gst builds) |

`GET /api/v1/room/list` + `GET /api/v1/program/{room_id}` give the live room and the
on-air camera; the backend already resolves both in
`CricketStreamSyncService::broadcasterCamera()` (PGM camera preferred, first live
WHIP camera as fallback, ghost cameras excluded via `active`).

### 6.2 Browser client — a working reference exists in this repo

Todd Studio's GUI is the reference implementation (TypeScript):

- `media-engine/ui/todd-studio-gui/src/lib/webrtc/whep.ts` —
  `startWhepWatch({ watchUrl, videoEl })` → `WhepSession`, `WhepWatchError`,
  `isRetryableWatchError`.
- `src/hooks/useWhepPlayer.ts` — full lifecycle: retry on retryable failures (409
  *not-live-yet*, 5xx, network), surface 401/403/404 permanently, a **10 s
  black-frame watchdog** that force-restarts the watch (fresh POST → fresh keyframe
  PLI) to heal "LIVE badge but black tile", and a real render signal
  (`videoWidth > 0 && !stalled`) rather than `connected` alone.
- `src/components/MultiviewTile.tsx` — the **direct-render** pattern: mount a bare
  `<video>` DOM node and bind `srcObject`/`src` imperatively so no framework
  re-render can detach the `MediaStream` and leave a black tile while bytes flow.
- ICE: `VITE_STUN_URL` / `VITE_TURN_URL`; the SFU resolves ICE interfaces and the
  deploy installs **coturn** (`media-engine-deploy.yml`), and a past fix made the
  engine prefer the **relay** by default.

### 6.3 What has to be built (the actual work)

1. **Backend — expose the watch URL.** `PublicMatchController::streamUrl()` already
   returns `hls_url`; add `whep_url` (room + on-air camera) and, if the engine needs
   a bearer token, a short-lived **viewer** token minted the way
   `StudioAuthController`/`MediaEngineTokenService` already do it. Keep the two
   transports advertised side by side (`hls_url` **and** `whep_url`) so the page can
   fall back.
2. **nginx on the public host.** `.nginx/cricket-public.conf` currently proxies only
   `/api/v1/cricket/public/` to PHP-FPM. WHEP signaling must be reachable from
   `cricket.traceodd.com`; copy Studio's pattern
   (`.nginx/todd-studio.conf`: `location /api/ { proxy_pass http://127.0.0.1:8082; }`)
   so the SDP POST stays **same-origin** and no CORS preflight is involved. (If you
   prefer cross-origin instead, the engine's `CORS_ALLOWED_ORIGINS` must include the
   public host — the Studio desktop build needed exactly this for `tauri://localhost`.)
3. **Flutter web player.** Mirror the existing vendored-JS pattern in
   `lib/shared/widgets/hls_video_player_web.dart` (an `HtmlElementView` hosting a
   bare `<video>`, plus a vendored script) — but bind `srcObject` to an
   `RTCPeerConnection` instead of hls.js. Port the three pieces of `useWhepPlayer`
   that matter in practice: retryable-vs-permanent errors, the black-frame
   watchdog restart, and the `videoWidth > 0` render check. Keep the player
   **direct-rendered** (never let Flutter re-mount the element mid-playback).
4. **Selection + fallback.** Prefer WHEP, fall back to HLS on permanent failure or
   when the viewer count/CPU is the constraint (see risks). The page already has the
   HLS path, so the fallback is free.
5. **Camera choice.** Only ever watch the **on-air** camera
   (`broadcasterCamera`), never a ghost entry — an inactive `whip` camera produces
   the 409 loop and eventually "no video stream on camera … layer ''".

### 6.4 Honest constraints and risks

- **Scale.** Each WHEP viewer is a WebRTC peer on the SFU: CPU + egress bandwidth
  per viewer, and **no CDN** (unlike HLS, which the SRS config already anticipates
  serving through a BunnyCDN pull zone). For a large public audience, plan for
  *hybrid*: WHEP for the low-latency case / a capped number of viewers, HLS for
  scale. Measure before switching the public page wholesale.
- **Media path.** Cloudflare terminates TLS for the site but cannot proxy WebRTC
  media; ICE candidates must reach a publicly routable SFU/TURN address. The engine
  runs on the origin host with host networking and coturn is deployed — but confirm
  the advertised candidate/relay address is the **public** IP, not a private one,
  and that the UDP range is open in the firewall.
- **Keyframes still matter.** Sub-second latency depends on frequent keyframes
  (a PLI can request one, which `useWhepPlayer` relies on); the publisher's GOP
  currently looks irregular (the engine logs `publisher h264 keyframes received …
  keyframes=N` only every 25 keyframes, with intervals of roughly 60–250 s between
  log lines — i.e. anywhere from ~2 s to ~10 s per keyframe).
- **Not the same as `ForwardKind::WebRtcViewer`.** The forwarder's WebRTC *viewer
  fan-out* is deliberately unimplemented and is **not** needed here: public viewers
  attach to the SFU's own WHEP egress, exactly as Studio does.

### 6.5 Verification (must not depend on the operator)

- Reproduce the §4 stall and prove the fix without a phone: a synthetic publisher
  through the real forwarder path (or a scripted WHIP publish) plus a scripted WHEP
  client asserting a decoded frame (`videoWidth > 0`), then kill the publisher and
  assert the pipeline ends (EOS on the bus) and the state flips out of `running`.
- For §6, assert a first decoded frame within ~1 s of a WHEP watch, and that the
  watcher reconnects after the publisher restarts.

### 6.6 Ambiguities I could not settle from the code alone (please resolve)

- Whether the engine's `authenticate()` accepts a token in the query string or
  header only (the WHEP route passes the `Uri` in), which decides how the public
  page carries its viewer token.
- Whether `remove_camera` runs on a plain publisher drop, or only on explicit
  teardown — the "ghost camera" lingering suggests the latter.
- Whether `register_inputs`' "already registered" skip is what makes some re-arms
  produce a forwarder that publishes nothing.
