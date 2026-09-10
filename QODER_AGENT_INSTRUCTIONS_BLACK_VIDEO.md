# INSTRUCTIONS FOR THE QODER AGENT — "Studio video display still fails" root-cause explanation

**Do NOT write or edit code.** Work read-only: read the brief files, read the source,
check git history, and produce a written English diagnosis + prioritized fix/test plan.
The operator will act on it manually.

---

## 1. Your objective

The live video pipeline — Android broadcaster (WHIP) → Rust SFU engine → Todd Studio
viewer (browser GUI + Tauri desktop) — still does **not display video** in Todd Studio,
after several rounds of fixes. The operator has repeatedly said "video display failed",
"tile stays black", or "video never arrives".

Your job has TWO parts:

- **Part A — Diagnose the WebRTC path** (sections 2–7): read every brief file and the
  relevant code, then explain — in plain English, tied to the production log sequences —
  what the most probable remaining root cause is, and give an ordered verification +
  fix plan.
- **Part B — Specify the OBS-style path** (section 8): the operator asks why, when
  OBS/Larix work reliably on the same phone/laptop/network, Todd cannot simply adopt that
  route. The repository ALREADY contains most of the pieces (SRS RTMP→HLS for cricket,
  GStreamer RTMP/SRT support in the engine, per-camera stream keys, field runbooks).
  Part B asks you to turn that into a concrete, operational plan.

Assume the operator is non-technical and the test phone is a Samsung Galaxy A22 5G.

### 1.1 CRITICAL problem definition (operator-confirmed topology, 2026-09-10)

The operator has isolated the failure precisely — read this before anything else:

| Path | State |
|---|---|
| **Larix + OBS + cricket-manager panel + `https://cricket.traceodd.com/` public viewer** (RTMP → SRS → HLS, four-component combo) | **Works perfectly, video included** |
| **Larix → Todd Studio** (WHIP) | No video |
| **Todd Broadcaster APK → Todd Studio** (WHIP) | No video |
| Larix → RTMP ingest `rtmp://135.181.46.27:1935/live/{key}` → HLS playback | **Already proven working** (the "zero-code test" has effectively passed) |

Consequences you must carry into your analysis:

- **Phone, carrier/network, TURN server, VPS and the RTMP/HLS stack are all validated.**
  The failure is confined to the **WHIP ingest → engine → WHEP viewer** chain (and/or the
  Studio viewer's bridge to it).
- **Two independent WHIP publishers both fail into Todd Studio** (Larix and the Todd APK).
  That makes a single-client encoder bug less likely and shifts suspicion toward the engine
  ingest/negotiation or the WHEP viewer/egress path. Your Part A diagnosis must establish
  which of the two legs fails, per leg, with the keyframe-counter evidence.
- Since a **working RTMP/SRS/HLS pipeline already exists in the same deployment**, the
  operator's request in Part B ("use the OBS route") is not theoretical: it is the shortest
  path to a working picture in Todd Studio.

## 2. Brief files to read FIRST (in order)

File: `QODER_FOLLOWUP_BRIEF_2.md` (the single accumulated brief file at repo root).
It contains three top-level sections — read ALL of them:

1. `# QODER FOLLOW-UP BRIEF #3 — NATIVE Kotlin APK: video registers but encoder stalls`
   (Flutter-era history, VP8/software-encoder root cause, later 2026-09-08 update
   proving sender-BWE starvation on the A22, open-loop bitrate fix).
2. `# QODER FOLLOW-UP BRIEF #4 — late-video WHIP lifecycle: ... "DataChannel is not opened"`
   (webrtc-rs lifecycle verification: `ErrClosedPipe` mislabel, `on_track` fires only
   after first RTP per SSRC, PLI nudges extended to 180 s, watchdog-kill race).
3. `# QODER FOLLOW-UP BRIEF #5 — viewer-side relay + watchdog blind spot (2026-09-09 field run)`
   (2026-09-09 19:33–19:41 evidence: audio-only session for 8+ min, engine PLIs at
   70/80/90 s prove the new engine is live, coturn ~96 kbps phone→relay = audio only,
   the `getVideoStats() ?: return` watchdog blind spot, and the four re-implemented
   relay-default changes).

Also skim for architecture context:
- `media-engine/docs/06-ice-and-telemetry.md`, `media-engine/docs/07-sfu-architecture.md`
- `apps/broadcaster-android/README.md`
- `media-engine/ui/todd-studio-gui/README.md`

## 3. Source files that matter (read these)

Engine (Rust, `media-engine/crates/todd-sfu/src/`):
- `engine.rs` — WHIP session lifecycle, PLI video-start watchdog (now to 180 s),
  disconnected-grace, takeover, prune.
- `whip_peer.rs` — `pump_track()` (ingest pump, H264 IDR counter, read-error
  classification), offer parsing, ICE/trickle handling.
- `whep_peer.rs` — `create_viewer()`, `pump_live_track()`, `write_chunk()` (H264 IDR
  counter, header-extension strip, answer negotiated-video-mline log).
- `router.rs` — `(room, camera, rid, ssrc)` stream table, per-layer subscriber queues,
  backpressure drops.
- `pli.rs` — PLI forwarding broker (viewer SSRC → publisher SSRC map).
- `h264.rs` — NAL/IDR payload detection.

App (Kotlin, `apps/broadcaster-android/app/src/main/java/com/todd/broadcaster/`):
- `MainActivity.kt` — config dialog, GO LIVE, watchdog (`checkEncoderHealth`), TURN
  defaults on blank config, 120 s first-video deadline.
- `media/BroadcasterEngine.kt` — camera/encoder init, codec preference
  (`H264PreferredEncoderFactory`), `createOffer` (RELAY policy when TURN set,
  congestion-control stripping), `applyFixedVideoBitrate` (open-loop min=max),
  `getVideoStats()`.
- `media/EncoderConfig.kt` — H264 Baseline L3.1, profiles/bitrates.

Viewer (React GUI, `media-engine/ui/todd-studio-gui/`):
- `src/lib/webrtc/whep.ts` — WHEP client; now offers TURN udp+tcp with credentials.
- `src/lib/utils.ts` — env defaults (VITE_TURN_URL/USERNAME/PASSWORD → VPS coturn).
- `src/hooks/useWhepPlayer.ts`, `src/components/MultiviewTile.tsx`,
  `src/components/MultiviewGrid.tsx` — liveness gating (video bytes >1 kbps) and the
  10 s black-frame watchdog restart.
- `src/components/UpdateManager.tsx` — desktop auto-update.
- `src-tauri/tauri.conf.json` — updater endpoint `https://traceodd.com/api/desktop-update.json`.

Deploy/ops:
- `.github/workflows/media-engine-build.yml`, `media-engine-deploy.yml` (VPS deploy,
  pulls GHCR → re-tags `traceodd/...`), `broadcaster-apk-native.yml` (APK →
  `https://traceodd.com/download/broadcaster/todd-broadcaster.apk`),
  `desktop-build.yml` (tag `v*` → signed installer + `desktop-update.json`).
- `.nginx/todd-studio.conf` (studio root `/var/www/todd-studio`),
  `.nginx/traceodd.conf` (`/download/` portal, `/api/desktop-update.json`).
- `media-engine/deploy/coturn/turnserver.conf`.

## 4. Current state snapshot (as of 2026-09-09/10) — facts you must assume

Engine (on the VPS `135.181.46.27`, docker `traceodd/media-engine:latest`): **live and
current** — deploy logs showed the extended PLI schedule (`delay_secs` 70/80/90), so the
commit `af1c4115` engine is running. Code on `mainnew` HEAD is `ff92ffcf` (desktop version
bump 0.3.1); later engine/telemetry commits: `dfbda904` (H264 IDR counters, WHEP
answer-mline log), `adad671f` (relay defaults app+viewer, watchdog null-stats fix — engine
unchanged there).

App (Android):
- Fixes shipped in code on `mainnew`: relay-on-blank-config defaults, watchdog treats null
  video stats as zero progress (120 s restart deadline actually fires), fixed open-loop
  bitrate. **These only matter if the installed APK contains them** — the operator must
  install the newest APK from
  `https://traceodd.com/download/broadcaster/todd-broadcaster.apk` (CI build
  `broadcaster-apk-native`) or the locally built
  `apps/broadcaster-android/app/build/outputs/apk/debug/app-debug.apk`.
- Local `assembleDebug` compiled OK on the operator's PC.

Viewer:
- Desktop: version bumped to **0.3.1**, tag `v0.3.1` pushed → `desktop-build` CI builds a
  signed installer + uploads `desktop-update.json`. Installed apps show an auto-update
  prompt once that build is live (endpoint `https://traceodd.com/api/desktop-update.json`).
- Browser (studio.traceodd.com): the new WHEP-TURN `dist/` was built locally but
  **NOT uploaded** to `/var/www/todd-studio` yet — the served browser Studio may still be
  an OLD build with no relay support. This is a prime "stale artifact" suspect.

Ops:
- VPS disk hit ~95 % full → Redis RDB write failures (`MISCONF ... stop-writes-on-bgsave-
  error`) → Laravel `deploy.yml` GitHub Action went red. Disk must be cleaned
  (`docker image prune -a -f`, `journalctl --vacuum-size=300M`, `docker restart
  todd-redis`) and the failed workflow re-run.

## 5. The failure signatures you must reconcile (accumulated evidence)

A. **Late or absent video ingest.** Engine PLIs for up to 180 s; Opus `track up` is
   instant; `track up codec=H264` either never appears, or appears 30–90 s late and then
   the session dies (client watchdog restart racing the encoder wake-up). On 2026-09-09
   the phone sent audio only (~96 kbps through coturn) for 8+ minutes, with NO app-side
   restart (watchdog blind spot — fixed in code but maybe the tested APK predates the
   fix).
B. **Black Studio tile while bytes flow.** Engine `egress` telemetry ticking, viewer
   jitter/RTT ticking, but `videoWidth` never > 0 in the GUI (10 s black-frame watchdog
   keeps re-subscribing). Historically also seen as "OFF badge disappears but no picture".
C. **One working moment.** 2026-09-08 ~22:53–23:04, with the force-RELAY APK: engine
   ingress ~808 kbps (real H264 video). So ingest CAN work end-to-end when the encoder
   starts and media rides the relay.

## 6. The diagnostic tree you must apply (and explain)

Because code fixes exist for every known failure point but the operator still sees
failure, **first verify what build/version actually ran in the failing test**. A stale
APK, stale browser GUI, or old desktop GUI fully explains "nothing changed". Produce a
checklist like:

1. **APK**: engine logs during the failing run — did a session show PLI delays ≥ 70 s
   (new engine) AND did the operator install an APK built AFTER `adad671f`? If the phone
   shows `Video sender stats unavailable` in logcat, the new watchdog code is running;
   if no such log and no restart at 120 s, the old APK is still installed. Get logcat:
   `adb logcat -v time -s MainActivity:V BroadcasterEngine:V libjingle:V`.
2. **Viewer version**: browser Studio — has `dist/` been uploaded to `/var/www/todd-
   studio`? Desktop — is it 0.3.1 (check update dialog / manifest)? Old viewers have NO
   TURN relay → behind carrier CGNAT the tile can stay black even with healthy ingest.
3. **Where does this session fail?** In one fresh session capture simultaneously:
   - Phone logcat (encoder start? `Video sender pinned`? errors?).
   - Engine: `journalctl -u todd-studio -f | grep -E "track up|publisher h264 keyframes
     received|whep viewer h264 keyframes forwarded|whep answer negotiated video m-line|
     \[whep\] peer connection connected|no video RTP yet"` and
     `curl -s http://127.0.0.1:8082/metrics | grep -E "keyframes|ingress"`.
   - Browser console (WHEP): `ICE connection state`, ontrack fired, `getStats`
     inbound-rtp: `framesDecoded`, `keyFramesDecoded`, `decoderImplementation`, `codecId`.
   Then classify into the tree:
   - No `track up H264` + no `todd_whip_h264_keyframes_total` growth → encoder/ingest
     side (app). Distinguish "encoder never starts" (logcat: no encoder init / `Video
     sender stats unavailable`) vs "encoder starts but media dies in transit".
   - `track up H264` + whip keyframes rising, `todd_whep_h264_keyframes_total` flat →
     SFU subscriber/forward path.
   - Both keyframe counters rising but tile black → viewer negotiation/decode: compare
     the `whep answer negotiated video m-line` log (expected H264 `packetization-mode=1`,
     `profile-level-id=42e01f`) with the publisher's actual stream, then browser
     `getStats` for `framesDecoded` vs `bytesReceived`.
   - No `[whep] peer connection connected` → viewer ICE/relay never established.

## 7. What your written deliverable must contain

1. A concise **root-cause explanation** that reconciles signatures A/B/C and the
   "still fails after all fixes" report — explicitly stating which hypotheses the stale-
   artifact check confirms or refutes, and naming the single most probable remaining cause
   (and the runner-up).
2. The **exact one-session verification procedure** (commands + expected logs per step)
   that a non-technical operator can run, ending in an unambiguous pass/fail per stage.
3. A **prioritized fix list** (first = highest leverage), each item stating the code file
   + what to change — but DO NOT make the changes yourself.
4. Explicitly warn if the problem cannot be diagnosed further without fresh logs from a
   properly-versioned run (all three artifacts current), and what logs to collect.

## 8. PART B — Bridge the PROVEN RTMP/SRS path into Todd Studio

### 8.1 The operator's argument (evaluate it honestly)

> "OBS downloads fine and Todd Studio downloads fine; if OBS has its own server, we have
> Hetzner and a separate domain too. Why can't we just use the OBS route? I never use an
> old broadcaster or Studio — after every change and deployment I download and install
> BOTH fresh, every single time."

The comparison is valid and important:

| What makes OBS/Larix reliable | Todd's WHIP/WHEP path |
|---|---|
| Encoder warms before signaling; keyframe immediately | Cold HW H.264 encoder can take 30–90 s to emit its first RTP |
| Fixed/open-loop bitrate, no dependence on sender BWE | Earlier builds starved to ~30 kbps when no congestion feedback arrived |
| RTMP/SRT ride one TCP connection (or SRT's ARQ) — no ICE/DTLS/UDP NAT traversal | WHIP/WHEP depends on ICE + DTLS + RTP/RTCP + PLI + TURN; carrier CGNAT drops large UDP packets |
| Mature reconnect logic | App/engine watchdogs historically fought each other |

RTMP bypasses ICE/TURN entirely; SRT is UDP but with retransmission, no ICE.

### 8.2 What already exists in THIS repository (verify before proposing anything)

1. **SRS (Simple Realtime Server) for cricket — already deployed and documented**
   - Config: `.nginx/srs-cricket.conf` → RTMP ingest on **port 1935**, HLS output to
     `/var/www/traceodd/cricket-hls/`, HTTP API on 1985, `rtc_server` (WebRTC) currently
     **disabled**.
   - Service unit: `.nginx/cricket-srs.service` (separate process from the web server).
   - Published HLS: `https://cricket.traceodd.com/hls/live/{stream_key}.m3u8`.
   - Stream keys per camera live in `cricket_streams.rtmp_stream_key`; RTMP ingest URL is
     configured in `backend/config/cricket.php` (`CRICKET_RTMP_INGEST_URL`, defaults to
     `rtmp://135.181.46.27:1935/live`).
2. **Field runbook already prescribes the exact phone config**
   - `assets/cricket/HARDWARE_SETUP.md` → "Mode B — Pure Smartphone Network (Zero Hardware
     Cost)": Larix on each phone pushing directly to `rtmp://135.181.46.27:1935/live/{key}`,
     HLS pulled back for viewing. This is precisely the operator's field scenario.
   - Same doc documents OBS pushing to `rtmp://cricket.traceodd.com/live` with a stream key.
3. **Engine already understands RTMP/RTSP ingest and RTMP/SRT egress**
   - `media-engine/crates/todd-sfu/src/engine.rs` → `pump_ingest_feed()` (gst builds) fans an
     RTSP/RTMP feed into the SAME `TrackRouter`, so downstream viewers/forwarders behave
     identically.
   - `media-engine/crates/todd-common/src/types.rs` → `ForwardKind::{Rtmp, Srt, File}`.
   - `media-engine/docs/07-sfu-architecture.md` and `02-phase1-single-server.md` describe the
     GStreamer forwarding/ingest matrix.
4. **Viewer-side alternatives that need NO WebRTC at all**
   - HLS playback (`cricket.traceodd.com/hls/...`) — plain HTTPS/TCP.
   - SRS can also emit HTTP-FLV (low latency over TCP) and, with `rtc_server enabled on`,
     WHEP/WebRTC from SRS itself (a battle-tested WHEP implementation rather than the
     custom webrtc-rs SFU).

### 8.3 The options you must lay out, with trade-offs

For each option state: latency, what exists already vs what must be built, failure modes,
and whether it removes ICE/TURN/PLI from the critical path.

- **Option 1 — Phone (Larix or Todd Broadcaster RTMP mode) → SRS RTMP → HLS → Studio
  viewer.** Zero new server software; the fastest way to get a guaranteed picture in the
  operator's hands. Latency ~4–10 s (3 s HLS segments). Removes ICE/TURN/PLI entirely.
- **Option 2 — Phone → SRS RTMP → engine GStreamer ingest → existing WHEP Studio tiles.**
  Keeps sub-second latency and the current Studio UI; needs (a) a way to register an
  RTMP/RTSP URL as a room camera in the engine's ingest API, and (b) SRS feeding the engine
  (e.g. engine pulls `rtmp://127.0.0.1:1935/live/{key}`). Reuses `pump_ingest_feed`.
- **Option 3 — Phone → SRS (or engine) SRT ingest.** SRT gives retransmission + low
  latency on bad networks, no ICE; Larix supports SRT. Requires SRT listener/ingest work.
- **Option 4 — SRS WHEP out** (`rtc_server enabled on`): phone → RTMP → SRS → WHEP/WebRTC
  to the browser at low latency, using SRS's WebRTC stack instead of the custom SFU.

### 8.4 Required deliverable for Part B

**Note:** the zero-code RTMP/SRS/HLS validation has ALREADY passed — cricket-manager shows
Larix/OBS video on the same phone, laptop and network. Do not re-propose it as a test; use
it as the proven baseline and specify the bridge.

Deliver, in priority order:

1. **Stage 1 — fastest picture in Todd Studio (smallest change):** specify exactly how a
   Todd Studio tile can play the already-working HLS URL
   (`https://cricket.traceodd.com/hls/live/{key}.m3u8`). State the component/file to add
   or extend in `media-engine/ui/todd-studio-gui/src/`, the player library choices (hls.js
   for Chromium/WebView2), the latency the director should expect (3–10 s), and how tiles
   should be labelled so the operator knows which mode they are in.
2. **Stage 2 — low-latency bridge (recommended end state):** phone → RTMP → SRS →
   **engine GStreamer ingest** → existing WHEP tiles. Specify:
   - how an RTMP/RTSP feed is registered as a room camera in the engine (API shape, where
     `pump_ingest_feed` in `media-engine/crates/todd-sfu/src/engine.rs` is invoked today and
     what is missing to call it for `rtmp://127.0.0.1:1935/live/{key}`);
   - how SRS exposes that stream to the engine (SRS HTTP-FLV remux or plain RTMP pull),
     including whether `gst` is compiled into the deployed image
     (`media-engine-build.yml` uses `FEATURES=gst` — confirm);
   - verification commands: `ffprobe rtmp://127.0.0.1:1935/live/{key}`,
     `curl -s http://127.0.0.1:1985/api/v1/streams`, engine `track up ... codec=H264`,
     `whep answer negotiated video m-line`, and a browser `getStats` check;
   - what happens to the existing WHIP ingest path (keep it, or retire it for field use).
3. **Stage 3 — optional:** enable SRS `rtc_server` (WHEP out of SRS) and compare with the
   custom SFU WHEP for reliability/latency; state clearly which one you would ship.
4. **Decision memo (one page):** which stage to implement first, expected latency, operator
   workflow impact (live vision switching needs sub-second; HLS cannot provide that), and
   the rollback ("keep WHIP working, add RTMP") so no existing capability is removed.
5. **Security:** RTMP is unauthenticated beyond the stream key. Show how cricket validates
   keys (`cricket_streams.rtmp_stream_key`, `backend/config/cricket.php`) and mirror it for
   Todd rooms/cameras so Todd ingest is not an open relay.

### 8.5 Also answer this directly (operator's core question)

"Why does OBS work and Todd does not?" — Explain in one paragraph, in plain language:
OBS/Larix push a fully-formed H.264 stream over a single TCP connection (RTMP) or an
ARQ-reliable UDP flow (SRT); there is no ICE negotiation, no DTLS handshake, no SIP-like
signaling, no TURN relay, no PLI/keyframe dance, and their encoders are already warm and
send a keyframe immediately. Todd's WHIP/WHEP path adds all of those, and every one of them
has been a failure point on carrier CGNAT networks. That is why the OBS-style route is not
a workaround for a coding bug — it is a fundamentally simpler transport choice that the
repository already supports.

---

## 9. Hard constraints

- No code edits, no commits, no pushes.
- No destructive production commands (no deleting Docker images/journals/databases).
  Operational cleanup (disk/Redis) may be *recommended*, not executed.
- Be specific: quote actual code lines, actual log fields, and commit hashes where
  relevant. Do not hand-wave "probably a network issue".
- English output, structured markdown, written to be read by the operator.

---

## 10. Evidence collection runbook (what the operator will hand you)

The operator runs the following on his Windows PC (CMD), with the test phone on USB and
SSH access to the VPS. All artifacts land in `C:\Ecosystem\qoder-evidence\`. Treat the
file names below as guaranteed inputs when writing your Part A/B answers.

### 10.1 Before the run (one-time)

```bat
mkdir C:\Ecosystem\qoder-evidence
adb logcat -c
```

Then, on the phone: launch Todd Broadcaster, open Todd Studio in the browser with
`chrome://webrtc-internals` open in a second tab, and press GO LIVE. Let it run
**3–4 minutes** (long enough for the 120 s first-video deadline and the 180 s PLI
schedule to elapse).

### 10.2 After the run — phone artifacts

```bat
adb shell dumpsys package com.todd.broadcaster > C:\Ecosystem\qoder-evidence\apk-version.txt
adb shell getprop ro.product.model >> C:\Ecosystem\qoder-evidence\apk-version.txt
adb logcat -d -v time MainActivity:V BroadcasterEngine:V WhipClient:V libjingle:V "*:S" > C:\Ecosystem\qoder-evidence\phone-logcat.txt
```

`apk-version.txt` proves WHICH build ran (`versionName`, `versionCode`,
`lastUpdateTime`). `phone-logcat.txt` shows encoder warm-up, `Available video encoders`,
`Video sender pinned`, `Video sender stats unavailable`, `PeerConnection state`.

### 10.3 After the run — engine + VPS artifacts

```bat
ssh root@135.181.46.27 "journalctl -u todd-studio --since '15 min ago' --no-pager > /tmp/todd-engine.log; journalctl -u todd-turn --since '15 min ago' --no-pager > /tmp/todd-turn.log; curl -s http://127.0.0.1:8082/metrics > /tmp/todd-metrics.txt; df -h / > /tmp/todd-df.txt; docker ps --format '{{.Image}} {{.Status}} {{.CreatedAt}}' > /tmp/todd-docker.txt; systemctl is-active todd-studio todd-broadcaster todd-turn > /tmp/todd-services.txt; ls -lah /var/www/todd-studio/ > /tmp/studio-deploy.txt; grep -o 'turn:135.181.46.27' /var/www/todd-studio/assets/*.js >> /tmp/studio-deploy.txt"
scp root@135.181.46.27:/tmp/todd-engine.log C:\Ecosystem\qoder-evidence\
scp root@135.181.46.27:/tmp/todd-turn.log C:\Ecosystem\qoder-evidence\
scp root@135.181.46.27:/tmp/todd-metrics.txt C:\Ecosystem\qoder-evidence\
scp root@135.181.46.27:/tmp/todd-df.txt C:\Ecosystem\qoder-evidence\
scp root@135.181.46.27:/tmp/todd-docker.txt C:\Ecosystem\qoder-evidence\
scp root@135.181.46.27:/tmp/todd-services.txt C:\Ecosystem\qoder-evidence\
scp root@135.181.46.27:/tmp/studio-deploy.txt C:\Ecosystem\qoder-evidence\
```

Key fields you must mine from these files:

- `todd-metrics.txt`: `todd_whip_h264_keyframes_total` vs `todd_whep_h264_keyframes_total`,
  `todd_ingress_bitrate_bps`, `todd_rtp_packets_in_total` / `..._forwarded_total` /
  `..._dropped_total`, `todd_viewers_active`.
- `todd-engine.log`: `track up ... codec=`, `track ended —`, `no video RTP yet — sending PLI`,
  `whep watch accepted`, `whep viewer started`, `whep answer negotiated video m-line`,
  `[whip]/[whep] peer connection connected`, `whep viewer h264 keyframes forwarded`.
- `studio-deploy.txt`: whether the deployed Studio bundle contains `turn:135.181.46.27` —
  i.e. whether the browser build has the relay defaults. **No match = stale Studio build.**
- `todd-df.txt` / `todd-docker.txt`: disk pressure and the actual running image
  (should be `traceodd/media-engine:latest`, re-tagged by the deploy workflow from GHCR).

### 10.4 Viewer-side artifact (browser)

In the browser running Todd Studio, open `chrome://webrtc-internals` in the same session as
the test, expand the WHEP peer connection, and use its
**"Download the PeerConnection updates and stats data"** button. Hand the downloaded dump
to you as `webrtc-internals-<timestamp>.txt`. It answers definitively: did the viewer ICE
connect, which candidate pair (relay vs host), and `inbound-rtp` → `framesDecoded`,
`keyFramesDecoded`, `bytesReceived`, `decoderImplementation`.

### 10.5 Optional second capture — Larix WHIP into Todd Studio

Repeat 10.1–10.4 with **Larix** configured to push WHIP into the Studio room/camera
(the operator already has Larix working for cricket's RTMP path). Two captures — one per
publisher — let you separate "engine ingest is broken" from "viewer egress is broken",
because both publishers fail but only one may reach the engine.

---

## 11. Evidence findings — 2026-09-10 run (agent pre-digested; start Part A from HERE)

Artifacts: `C:\Ecosystem\qoder-evidence\` (collected 2026-09-10, test window ~13:32–14:21 UTC,
i.e. ~15:32–16:21 operator local time = UTC+2). Server logs are UTC.

### 11.1 What the evidence proves (facts, with the exact lines)

**Phone (`phone-logcat.txt`, `apk-version.txt`) — fresh APK, and the app watchdog works now:**

```
versionName=1.0.0  versionCode=1  firstInstallTime=2026-09-10 15:31:20  lastUpdateTime=2026-09-10 15:31:20
15:59:38.298 W/MainActivity: Video stall detected: No video started after 120s
15:59:38.301 I/MainActivity: Auto-restart attempt 1/3
... repeated every ~131 s (16:01:49, 16:04:01, 16:06:12, 16:08:23)
15:59:49.885 PeerConnection state: CONNECTED        (WHIP POST accepted 15:59:49.643)
15:59:55.873 ICE connection state: FAILED           ← 6 SECONDS after CONNECTED
```
- The instance installed at 15:31 today is the new build (the 120 s deadline log only exists in
  the fixed watchdog). So "old APK" is no longer a valid explanation.
- `Video sender pinned to 800 kbps (open-loop)` and `Video transceiver configured` appear every
  session — the sender exists.
- **No `Video sender stats unavailable` lines anywhere** → `getVideoStats()` returns a real
  `(0, 0)` pair: the encoder/sender exists but **encoded zero frames in every session**.
- **`ICE CONNECTED → FAILED in ~6 s` — every single session** (15:59, 16:02, 16:04, 16:06, 16:08).

**Engine (`todd-engine.log`, `todd-metrics.txt`):**

- Sessions accepted, `[whip] peer connection connected`, `track up ... codec=Opus` — and then
  `no video RTP yet — sending PLI to publisher` at delays 4…160 s (one session PLI'd for 23 min).
- **Only one H264 registration in the whole window**, and it was 25 minutes late:
  `13:57:29 INFO todd_sfu::whip_peer: track up ... codec=H264` — immediately followed by
  `[controlled]: Failed to close candidate udp4 relay ... the agent is closed` ×4 and
  `whip session closed` (the phone's watchdog restarted right then).
- **Zero** `peer connection disconnected` / `peer connection failed` lines: the engine's ICE
  agent never noticed the path death that the phone reported 6 s in.
- **Zero** `whep watch accepted` lines, and `todd_whep_watches_total 0`,
  `todd_viewers_active 0`, `todd_rtp_packets_forwarded_total 0`,
  `todd_whip_h264_keyframes_total 0`, `todd_ingress_bitrate_bps 31592` (audio-only level).
  → **No viewer ever subscribed.** The Studio tile gates its WHEP watch on "camera video bytes
  > ~1 kbps" (`MultiviewGrid.tsx`), so with audio-only ingress the tile stays OFF/black and
  never even attempts the watch. This is the direct cause of "the OFF button did not move".

**Deployment state (all healthy now):**

- `todd-services.txt`: todd-studio / todd-broadcaster / todd-turn all `active`.
- `todd-df.txt`: `/` at **10 %** (14G/150G) — the disk/Redis blocker is resolved.
- `todd-docker.txt`: `traceodd/media-engine:latest` + `...-broadcaster:latest` up 16 h —
  and the engine log shows PLI `delay_secs` up to 160, i.e. the extended-schedule build
  (`af1c4115`) is running.
- `studio-deploy.txt`: `/var/www/todd-studio` assets dated Sep 9 22:49 and
  `grep -o 'turn:135.181.46.27'` **found a match** → the deployed browser Studio DOES contain
  the TURN relay defaults. "Stale Studio bundle" is refuted for the browser build.

**TURN (`todd-turn.log`):**

- Allocations and permissions succeed (`ALLOCATE processed, success` after the normal 401
  nonce challenge); relay traffic did flow earlier in the day.
- But the log is dominated by teardown churn:
  `reason: allocation timeout`, `reason: allocation watchdog determined stale session state`
  (many, for both `94.34.193.186` clients and the engine's own `local 172.17.0.1` sessions),
  `TCP socket closed remotely`, and `bind: Address already in use` on one relay allocation.

### 11.2 The derived diagnosis (Part A starting point)

1. **Primary blocker: the WHIP ICE path dies ~6 s after connecting, on the publisher side,
   while the engine's agent still believes it is connected.** Nothing downstream can work:
   no media, no frames encoded (`framesEncoded` stays 0 — libwebrtc stops the send stream once
   the transport is unusable), no keyframes, no fan-out. The 25-minute-late H264 registration
   in the first session shows the video pipeline itself is capable; it is the transport that
   dies.
2. **Contributing: asymmetric ICE failure detection.** The phone fails in ~6 s while the engine
   (long `ICE_*` timeouts set by the deploy) reports nothing — the engine keeps a zombie session
   and keeps PLI-ing into a dead relay path for minutes.
3. **Second, independent defect: the viewer never subscribes when a camera is audio-only.**
   Tiles gate on video bytes, so during this whole test the Studio never POSTed a single WHEP
   watch. Even with a healthy publisher this gate would hide video for the first N seconds; with
   this failure it hides everything and makes the UI look "dead".
4. Candidate root causes for (1) that the evidence points at, to be discriminated by the tests
   in 11.3: (a) TURN relay-path failures (allocation churn / refresh / TCP-relay-vs-UDP relay —
   the app forces `iceTransportsType = RELAY` with both `?transport=udp` and `?transport=tcp`
   variants); (b) engine→phone direction blocked (STUN responses/consent not reaching the
   phone) while phone→engine works; (c) the engine's relay candidates (`relay=2` in the answer,
   allocated through the Docker gateway `172.17.0.1`) going stale, poisoning the selected pair.

### 11.3 The tests that discriminate (specify these; do not run destructive commands)

1. **One-way vs both-way check:** during a live session on the VPS, `tcpdump` on
   `udp port 3478 or (udp portrange 49160-49200)` and count packets inbound (from the phone's
   public IP) vs outbound to it. If outbound to the phone stops while inbound continues, the
   phone's relay data path or its allocation is the failure.
2. **Allocation refresh:** `turnutils_uclient` (or coturn's verbose log) to check whether the
   phone's allocation is refreshed; grep `todd-turn.log` for the phone's public IP around the
   6-second failure moment.
3. **RELAY-forced vs relay-optional A/B:** build a test APK variant with TURN configured but
   `iceTransportsType` left at `ALL` (so libwebrtc can also try host/srflx). If video then
   flows, the forced-RELAY policy plus this coturn instance is the culprit — not CGNAT.
4. **Engine-side asymmetry:** confirm the engine's ICE timeouts (deploy `.env` `ICE_*`) and
   whether the engine should proactively fail a session whose `todd_ingress_bitrate_bps` drops
   to zero after being non-zero (currently it PLIs for 180 s into a dead path).
5. **Viewer gating:** confirm the `MultiviewGrid` gate and specify either (a) allowing a watch
   attempt when a camera is audio-live but not yet video-live, or (b) an operator-visible
   "waiting for video" state that distinguishes "no ingest" from "ingest without video".

### 11.4 Note for Part B (OBS/RTMP route)

This run strengthens Part B: the RTMP/SRS/HLS path has no ICE, no DTLS, no TURN, no PLI and is
already proven working on this exact phone/network. The fastest reliable path to a picture in
Todd Studio remains the bridge specified in section 8.
