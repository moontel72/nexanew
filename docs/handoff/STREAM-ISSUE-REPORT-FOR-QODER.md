# HANDOFF — Live Video Not Reaching the Public Page

**For:** QODER EXPERT AGENT
**Date:** 2026-09-18
**Severity:** Critical — public stream has never played at `https://cricket.traceodd.com/`
**Duration:** ~7 days of failed attempts
**Requested action:** **INVESTIGATE AND REPORT ONLY. DO NOT WRITE CODE.**

---

## 0. What I am asking you to do

1. Scan **all cricket-related files** across frontend, backend, database, and media engine.
2. Find the **actual fault** that prevents video reaching the public page.
3. Produce a **solution** (described, not implemented).

The last 7 days of attempts all followed the same failed pattern: fix something that
looked wrong, deploy, ask the operator to test, and the symptom returned unchanged.
The report below is honest about that, including the fixes I made that did **not** work.

**Do not code.** I want an independent read of the evidence before any further change.

---

## 1. The symptom (current, reproducible)

Operator opens **Cricket Manager → Live Video**:

```
OFF AIR — no video reaching viewers
bridge: missing
```

Operator presses **"Reconnect live video"**:

```
LIVE VIDEO RECONNECTED        <- top banner
BROKEN - the bridge failed    <- status card
bridge: failed                <- below
```

Public page `https://cricket.traceodd.com/` — no video, HLS 404.
Todd **Studio** shows the camera fine.

### The two facts that matter most

| Fact | Evidence |
|---|---|
| Video **works** in Todd Studio | Studio plays the camera over WHEP directly from the SFU |
| Video **never** reaches SRS | `/var/www/traceodd/cricket-hls/live/` is empty; SRS `/api/v1/streams/` returns `{"streams":[]}` |

So the camera publishes, the SFU receives it, and the **break is on the
engine → SRS hop** (the "forwarder").

---

## 2. System architecture (as built)

```
Todd Broadcaster (Android, WHIP)
        |
        v
  Todd Studio (Rust, todd-signaling + todd-sfu)   <- camera lives here
        |  on-air camera (PGM)
        v
  GStreamer forwarder  (todd-transcode)           <- THE FAILING HOP
        |  RTMP
        v
  SRS (port 1935)
        |  HLS segments
        v
  /var/www/traceodd/cricket-hls/live/*.m3u8
        |
        v
  nginx -> https://cricket.traceodd.com/hls/live/{key}.m3u8
        |
        v
  Public Flutter page (HLS player)
```

### Key files

| Layer | Path |
|---|---|
| Forwarder (GStreamer pipeline) | `media-engine/crates/todd-transcode/src/forwarder.rs` |
| Forwarder orchestration | `media-engine/crates/todd-sfu/src/engine.rs` (`add_forwarder`, `rearm_stale_forwarders`) |
| Track router / subscription | `media-engine/crates/todd-sfu/src/router.rs` |
| WHIP publisher | `media-engine/crates/todd-sfu/src/whip_peer.rs` |
| Engine HTTP routes | `media-engine/crates/todd-signaling/src/routes/rooms.rs` |
| Engine bootstrap | `media-engine/crates/todd-signaling/src/state.rs` |
| Laravel video bridge | `backend/app/Services/Cricket/CricketStreamSyncService.php` |
| Laravel video API | `backend/app/Http/Controllers/Cricket/LiveVideoController.php` |
| Laravel watchdog | `backend/app/Console/Commands/CricketStreamWatchdog.php` |
| Public stream URL | `backend/app/Http/Controllers/Cricket/PublicMatchController.php::streamUrl` |
| Public page player | `lib/features/cricket/presentation/pages/public/live_match_page.dart` |
| Public page bloc | `lib/features/cricket/presentation/blocs/stream_player/stream_player_bloc.dart` |
| Manager live-video UI | `lib/features/cricket/presentation/pages/manager/live_video_page.dart` |
| Repository | `lib/features/cricket/data/repositories/cricket_repository.dart` |
| SRS config | `/usr/local/srs/conf/cricket.conf` (on server) |

### Infrastructure facts

- Server: `root@135.181.46.27`, Docker, host networking.
- Containers: `todd-studio` (port 8082), `todd-broadcaster` (port 8081), `todd-redis`.
- SRS: RTMP `1935`, API `1985`, HLS HTTP `8088`, HLS dir `/var/www/traceodd/cricket-hls`.
- SRS config HLS path uses `[app]/[stream].m3u8` → real path `/.../live/{stream}.m3u8`.
- Deploy: GitHub Actions on branch **`mainnew`** (`Deploy to Hetzner`,
  `Media Engine — Build & Push Docker Image`, then `Media Engine — Deploy to VPS`).
- The build runs on **Ubuntu 24.04 with GStreamer 1.24** (`media-engine/deploy/docker/Dockerfile`).
  **The local dev machine has no GStreamer**, so `cargo check` without
  `--features gst` compiles the forwarder code as an empty stub — this is a real
  trap and it hid at least three compile errors for days (see §5).

---

## 3. Commands run and their results

### 3.1 Proving the delivery chain works (rules it OUT as the cause)

I published a synthetic stream from inside the engine container straight to SRS:

```sh
docker exec todd-studio gst-launch-1.0 -q \
  flvmux streamable=true name=mux ! \
  rtmpsink location="rtmp://135.181.46.27:1935/live/DIAGTEST" \
  videotestsrc is-live=true ! videoconvert ! \
  x264enc tune=zerolatency ! mux.
```

**Result — the whole chain works:**

```
SRS log:  client identified, type=fmle-publish, stream=DIAGTEST
SRS log:  new live source, stream_url=/live/DIAGTEST
```

```sh
ls -la /var/www/traceodd/cricket-hls/live/
# DIAGTEST-0.ts
# DIAGTEST.m3u8        <- segments + playlist produced

curl -s -o /dev/null -w "%{http_code}" \
  https://cricket.traceodd.com/hls/live/DIAGTEST.m3u8
# 200

curl -s https://cricket.traceodd.com/hls/live/DIAGTEST.m3u8
# #EXTM3U
# #EXT-X-VERSION:3
# #EXT-X-TARGETDURATION:5
# #EXTINF:1.967, no desc
# DIAGTEST-0.ts
```

**Conclusion:** SRS, RTMP egress, HLS segmentation, nginx routing, and the public
HLS URL all work. The 404 is **not** a delivery problem. **The forwarder never
feeds SRS.**

### 3.2 Proving the broadcaster reaches the engine

```sh
docker logs --since 30m todd-studio | grep -a "publisher h264 keyframes"
```

```
INFO whip_peer: publisher h264 keyframes received
     room="68f38fd5-..." camera="CAM-04" ssrc=3870740826 keyframes=300
```

**Conclusion:** the publisher works and the SFU receives video. The break is
strictly between the SFU and SRS.

### 3.3 The forwarder reported "running" while doing nothing

```sh
# engine internal API (bearer token minted by MediaEngineTokenService)
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/forward/list
```

```json
[{"key":".../CAM-04/rtmp://135.181.46.27:1935/live/cricket_match_..._cam1_...",
  "state":"running","error":null}]
```

```sh
curl -s http://127.0.0.1:1985/api/v1/streams/   # {"streams":[]}
ls /var/www/traceodd/cricket-hls/live/          # empty
```

**Conclusion:** `state: "running"` was a **lie**. This is the root of the 7-day
confusion: every dashboard check said healthy while nothing was being produced.

### 3.4 SRS log — last successful publish

```sh
grep -aE 'publish|start publish' /var/log/srs-cricket.log | tail -20
```

```
[2026-09-14 16:25:28] connected stream, stream=zed-rtmpsink
[2026-09-14 16:25:28] start publish mr=0/350
```

**Conclusion:** the last successful RTMP publish was **2026-09-14**, matching the
operator's "broken for about 4 days" report. After that, zero successful publishes.

### 3.5 CRITICAL — pipeline shape experiment (this is the key evidence)

Run **inside** the `todd-studio` container, against real SRS:

```sh
# A) video only, no audio branch
timeout 14 gst-launch-1.0 -q \
  flvmux streamable=true name=mux ! rtmpsink location="rtmp://127.0.0.1:1935/live/DIAG_NOAUDIO" sync=false \
  videotestsrc is-live=true num-buffers=200 ! videoconvert ! \
  x264enc tune=zerolatency speed-preset=ultrafast key-int-max=30 ! \
  h264parse ! queue name=vq ! mux.
```
```
exit=0            <- completed
SRS received DIAG_NOAUDIO
```

```sh
# B) video + a SILENT audio branch (the real forwarder shape)
timeout 14 gst-launch-1.0 -q \
  flvmux streamable=true name=mux ! rtmpsink location="rtmp://127.0.0.1:1935/live/DIAG_WITHAUDIO" sync=false \
  videotestsrc is-live=true num-buffers=200 ! videoconvert ! \
  x264enc tune=zerolatency speed-preset=ultrafast key-int-max=30 ! \
  h264parse ! queue name=vq ! mux. \
  audiomixer name=mix ! audioconvert ! audioresample ! voaacenc bitrate=128000 ! \
  aacparse ! queue name=aq ! mux. \
  appsrc name=audio_commentary format=time do-timestamp=true is-live=false \
    caps="application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000" ! \
    queue max-size-time=200000000 leaky=downstream ! \
    rtpopusdepay ! opusdec ! audioconvert ! audioresample ! \
    volume name=vol_commentary volume=1.0 ! mix.
```
```
exit=124          <- TIMED OUT / HUNG
SRS received NOTHING
```

**Additionally tested, both still hang:**

| Variant | Result |
|---|---|
| `audiomixer ignore-inactive-pads=true` | `exit=124` (hung) |
| `audiomixer start-time-selection=first` | `exit=124` (hung) |
| audio branch removed entirely | `exit=0` (published) |

**Interpretation:** a branch built for an audio input that never delivers a
buffer stalls `flvmux`. `flvmux` waits for the stream that never arrives, so the
**video never leaves either**. A silent bus does not raise an error — it simply
hangs, which is why no log ever explained it.

**Note the asymmetry:** "empty appsrc → depay → fakesink" completed fine in
isolation. The hang only appears once the branch is **muxed alongside video**.

### 3.6 THE BUS ERROR — what the forwarder actually reports

After adding GStreamer bus handling (§4.1), the real error finally became visible:

```
ERROR todd_transcode::forwarder: forwarder pipeline error label=camera/CAM-01
    error=Internal data stream error.
    debug="../libs/gst/base/gstbasesrc.c(3177): gst_base_src_loop () :
           /GstPipeline:pipeline179/GstAppSrc:audio_commentary:
           streaming stopped, reason not-negotiated (-4)"

ERROR todd_sfu::engine: forwarder failed; clearing it so a watchdog can rebuild
    key=7900b2a8-.../CAM-01/rtmp://135.181.46.27:1935/live/cricket_match_..._cam1
```

**The failing element is always `GstAppSrc:audio_commentary`** — an audio branch
that never received data.

### 3.7 Watchdog re-arm loop observed live

```sh
docker logs --since 20m todd-studio | grep -a "forwarder failed"
```

```
23:37:51 forwarder failed ... audio_commentary ... not-negotiated (-4)
23:37:56 forwarder failed ... audio_commentary ... not-negotiated (-4)
23:38:01 forwarder failed ... audio_commentary ... not-negotiated (-4)
23:38:06 forwarder failed ... audio_commentary ... not-negotiated (-4)
... every ~5 seconds
```

**Conclusion:** the watchdog re-creates the forwarder every 5s, it dies
immediately, forever. The status alternates between `failed` and `missing`, which
is exactly what the UI shows as `BROKEN` after pressing Reconnect.

### 3.8 Room / camera / PGM state

```sh
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/room/list
```

```json
[{"id":"7900b2a8-5de3-46bd-9af6-9cba99353483","name":"ROOM-01",
  "cameras":[{"id":"CAM-01","kind":"whip","active":false}]}]
```

```sh
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/program/7900b2a8-...
# {"camera_id":"CAM-01"}
```

**Conclusion:** room, camera, and PGM routing are all correct. `active:false`
simply means the broadcaster was not publishing at that moment.

### 3.9 Public page console 403s

```
/api/v1/cricket/manager/sponsors?per_page=100   -> 403
/api/v1/cricket/manager/matches/{id}            -> 403
/hls/live/cricket_match_..._cam1.m3u8           -> 404
```

**Diagnosis:** the public Flutter app and the manager console share
`CricketRepository`. `SponsorBloc._fetchAll()` and `LiveScoreBloc` call
**manager-only** endpoints. The public host blocks `/api/v1/cricket/manager/*`
by design (`nginx: .nginx/cricket-public.conf`). These 403s are noise generated
by the public page itself — they do **not** block video, but they pollute the
console and delayed diagnosis.

**Already fixed** (§4.6) — but note this was a *symptom*, never the cause.

### 3.10 Checking the engine image actually deployed

```sh
docker inspect todd-studio --format '{{.Image}} created={{.Created}}'
# created=2026-09-17T22:58:30Z

docker images | grep media-engine
# traceodd/media-engine  2026-09-17 22:43:27
```

**Conclusion:** deploys did land. The failures are not stale images.

---

## 4. Changes I made (chronological, with outcomes)

Honest accounting. Several of these were **wrong or insufficient** — that is the
main reason this handoff exists.

### 4.1 `forwarder.rs` — added GStreamer bus handling
**File:** `media-engine/crates/todd-transcode/src/forwarder.rs`
Added `watch_bus()`: subscribes to the pipeline bus, maps
`Message::Error` / `Eos` / `StateChanged` to a log plus a failure callback.
`GstForwarder` gained a `_bus_task` field.

**Outcome:** ✅ **This worked and was essential.** It converted a silent failure
into the explicit `audio_commentary ... not-negotiated (-4)` error in §3.6.
Without it, the root cause was invisible.

### 4.2 `engine.rs` — non-blocking forwarder creation
**File:** `media-engine/crates/todd-sfu/src/engine.rs::add_forwarder`
`GstForwarder::build` waits for the first video chunk. It was awaited inside the
HTTP handler, so activating a camera before its publisher connected hung the
request. Now the target is validated, status published as `Starting`, and the
pipeline built on a background task that sets `Running` or `Failed`.

Also switched layer selection from `lowest_rid` to `lowest_video_rid`.

**Outcome:** ✅ Correct improvement. Does **not** fix the hang.

### 4.3 `engine.rs` — `rearm_stale_forwarders()` + 5s watchdog
**Files:** `engine.rs`, `todd-signaling/src/state.rs`
Rebuilds camera forwarders whose pipeline died or never started.
Spawned via `spawn_forwarder_watchdog()`.

**Outcome:** ✅ Working as designed, but it **re-creates the failing pipeline every
5 seconds** (§3.7). It faithfully reproduces the bug in a loop. It also masks the
`missing` → `failed` transition from the operator.

### 4.4 `forwarder.rs` — audio appsrc made non-live + leaky queue
Changed each audio appsrc from `is-live=true` to
`is-live=false`, and inserted
`queue max-size-time=200000000 leaky=downstream` before the depayloader.

**Outcome:** ❌ **INSUFFICIENT.** The hang persisted unchanged.

### 4.5 `forwarder.rs` — audio "priming" with a 1.5s budget
**Current state of the code.** Each audio bus is given
`AUDIO_PRIME_TIMEOUT` (1500 ms) to deliver its first chunk. A bus that stays
silent is **dropped before the pipeline is built**. `has_audio` now reflects
*proven* audio rather than configured/enabled buses.

```rust
const AUDIO_PRIME_TIMEOUT: Duration = Duration::from_millis(1500);
// ...
let mut live_audio: Vec<(AudioBus, mpsc::Receiver<RtpChunk>, RtpChunk)> = Vec::new();
for (bus, mut rx) in audio_rx {
    let deadline = tokio::time::Instant::now() + AUDIO_PRIME_TIMEOUT;
    let primed = loop {
        match tokio::time::timeout_at(deadline, rx.recv()).await {
            Ok(Some(chunk)) => break Some(chunk),
            Ok(None) => break None,
            Err(_elapsed) => break None,
        }
    };
    match primed {
        Some(chunk) => live_audio.push((bus, rx, chunk)),
        None => tracing::info!(bus = %bus.as_str(),
            "audio bus produced no frames within the prime window; forwarding without it"),
    }
}
let has_audio = !live_audio.is_empty();
```

**Outcome:** ❓ **NOT CONFIRMED.** Deployed, but the operator's reported state
afterwards (`bridge: failed`) matches §3.7 exactly, suggesting the audio branch is
**still being built**. This needs verification — see §6.

**Hypothesis if it still fails:** `audio_tracks()` returns a track because the
publisher *negotiated* Opus, and the router may deliver at least one chunk during
prime (e.g. a header-only packet), so `has_audio` becomes `true` for a bus that
then goes silent. The prime window may be too long, or the test may be the wrong
one (a chunk ≠ a continuous stream).

### 4.6 `cricket_repository.dart` — suppressed manager calls from the public app
Added `hasManagerToken()`; `getMatch()` and `getSponsors()` now return empty when
no manager token exists.

**Outcome:** ✅ Fixes the console 403 noise (§3.9). Unrelated to the video fault.

### 4.7 Removed the entire manager-side camera registry
**Files deleted:** `StreamController.php`, `StreamEndpoint.php`,
`CricketStreamUpdated.php`, migration dropping `cricket_streams`,
`CameraSwitcherBloc`, `CameraSwitcherPage`; added `LiveVideoController.php`
(`video-health`, `video-resync`, `video-stop`) and `LiveVideoPage`.

Rationale: cameras belong to the broadcaster; the manager's duplicate camera
registration split the Studio player and gated the public page on a DB row.

**Outcome:** ✅ Correct architecturally. The SRS stream name is now **derived**
from the match id (`cricket_match_{matchId}_cam1`), never stored.

### 4.8 Fixed three compile errors hidden by the missing `gst` feature
Found only by building in an `ubuntu:24.04` + GStreamer 1.24 container:
- `&mut Receiver` vs owned `Receiver` mismatch
- `Arc` moved into a closure then borrowed again
- `ForwardTarget` literal missing six fields (in 4 existing tests)

Also repaired two **pre-existing broken tests** that had never run because they
are `gst`-gated:
- the 4 `ForwardTarget` literals above
- `description_links_branches_into_mux` asserted the description contains no
  `"enc"` substring — but `voaacenc` in the audio chain contains `enc`

**Outcome:** ✅ 31 tests pass with `--features gst`.

### 4.9 Other fixes made during this period
- `MatchController::show()` referenced the deleted `streams` relation → **HTTP 500**
  on every match load. Fixed.
- `MatchController::updateStatus()` rejected `innings_break → in_progress` and
  repeated same-status calls → **HTTP 422**, making the BREAK button appear dead.
  Transition table widened; UI now shows RESUME while on break.
- `LiveScoreService` now explains that scoring is paused during a break.
- `MultiviewTile.tsx` badge showed `LIVE`/`HLS` instead of `PGM`/`PVW`; now a
  filled badge.
- `LiveVideoPage` threw `Provider<CricketRepository> not found` because
  `MaterialPageRoute` builds above the page's providers.

**Outcome:** ✅ All verified. **None of these affect video delivery.**

---

## 5. Why 7 days were lost — process failures worth correcting

These matter as much as the code bug, because they are what allowed a hang to
survive a week of "fixes".

1. **Silent failure.** Nothing watched the GStreamer bus, so an output failure
   produced no log, no error, no state change. The dashboard said `running`.
   *Fixed in 4.1 — this was the single highest-value change of the week.*

2. **Status was inferred from intent, not outcome.** `Running` was published when
   the pipeline *object* was constructed. It should reflect observed output
   (bytes reaching SRS), not the absence of an exception.

3. **A healthy-looking dashboard hid the truth.** `stream-health` reported
   `healthy: true` while SRS had received nothing for days. Health must be
   measured at the **far end** of the hop (SRS / HLS playlist), not at the near end.

4. **`gst`-gated code silently compiles as a stub.** The local machine has no
   GStreamer, so the exact code under investigation was never compiled or tested
   locally. Three real errors and two dead tests were hidden. **Any change to
   the forwarder must be compiled in the Ubuntu 24.04 + GStreamer container.**

5. **Verification was delegated to the operator.** Deploying and asking "does it
   work now?" produced 7 days of inconclusive rounds. A synthetic RTMP publisher
   (§3.1) could have proven or disproven every hypothesis in minutes.

6. **An audit trail replaced root-cause work.** Many small, individually-correct
   fixes were made (4.2, 4.3, 4.9) that never touched the failing hop. Activity
   is not progress.

---

## 6. Current state, open questions, and where I would look

### Current state (last observed)

| Item | Value |
|---|---|
| Room / camera / PGM | `ROOM-01` / `CAM-01` (whip) / PGM = `CAM-01` — all correct |
| Forwarder | alternates `missing` ↔ `failed` every ~5s |
| Error (when present) | `GstAppSrc:audio_commentary … not-negotiated (-4)` |
| SRS streams | none |
| HLS dir | empty |
| Public HLS URL | 404 |
| Studio playback | works (WHEP direct) |

### The one question that must be answered first

**Is the audio branch still being built for a silent bus?**

```
docker logs --since 10m todd-studio | grep -aE \
  "audio bus produced no frames|forwarding without it|no live audio|forwarder started|forwarder failed"
```

- If **"audio bus produced no frames … forwarding without it"** appears →
  priming works, the audio branch is gone, and the fault is **elsewhere**.
  Then look at the muxer/sink path and the *video* stage.
- If it does **not** appear, and `forwarder failed … audio_commentary` recurs →
  priming is ineffective. `has_audio` is still true for a bus that stops
  delivering. The likely culprit is that a *single* early chunk (a header or a
  keep-alive) satisfies the prime while the bus is effectively silent.

### Secondary suspects to examine

- **`audiomixer` with a single input.** A muxer/mixer configured for N inputs but
  receiving 1 may wait. Test `flvmux` with audio **dropped entirely** vs
  **one live branch** — the first works (§3.5), the second has never been proven
  to work.
- **`flvmux` stream count.** `flvmux` may buffer waiting for a declared-but-absent
  audio stream. Consider whether the mux should be selected by the *number of live
  branches* rather than fixed.
- **`router.rs::audio_tracks()`** returns **registered** tracks, not tracks that
  have delivered data. `register_track` is called from the WHIP offer, before any
  packet arrives. Confirm whether a publisher that offers Opus but never sends it
  registers a track. **This is the most likely source of the wrong `has_audio`.**
- **Camera-side audio.** Is the broadcaster actually configured to publish audio?
  If the intent is "video only", the cleanest fix may be for the **publisher** to
  not negotiate Opus at all — removing the branch at the source rather than
  teaching the engine to tolerate it.
- **Priority**: the operator's requirement is *"video must reach the public page"*.
  Audio is incidental. **The pipeline must be able to publish with zero audio
  branches, always.**

---

## 7. What QODER should deliver

**No code changes.** A written report containing:

1. **The root fault**, with `file:line` evidence for why the audio branch is built
   for a silent bus, and why it hangs the mux.
2. **The full chain audit** — frontend → backend → engine → SRS → HLS → public
   player — listing every place a failure can become silent again.
3. **A concrete solution**, including whether to:
   a. drop audio branches when unproven (engine-side), or
   b. stop the publisher negotiating Opus (source-side), or
   c. build the mux dynamically from live branches only.
   State the tradeoffs.
4. **A verification procedure** that proves the fix **without** asking the operator
   to test — e.g. a synthetic publisher through the real forwarder path asserting
   that `https://cricket.traceodd.com/hls/live/{key}.m3u8` returns `200`.
5. **Anything I have missed.** The evidence in §3 is complete and reproducible;
   treat it as ground truth, but challenge my interpretation if it is wrong.

---

## 8. Reproduce everything in this report

```sh
# 1. Rule out the delivery chain (expect 200 + a valid playlist)
docker exec todd-studio gst-launch-1.0 -q \
  flvmux streamable=true name=mux ! \
  rtmpsink location="rtmp://135.181.46.27:1935/live/DIAGTEST" \
  videotestsrc is-live=true ! videoconvert ! x264enc tune=zerolatency ! mux.
curl -s -o /dev/null -w "%{http_code}\n" \
  https://cricket.traceodd.com/hls/live/DIAGTEST.m3u8

# 2. Confirm SRS has nothing for the real match
curl -s http://127.0.0.1:1985/api/v1/streams/
ls -la /var/www/traceodd/cricket-hls/live/

# 3. See the real forwarder error (requires the bus handling from §4.1)
docker logs --since 10m todd-studio | grep -aE "forwarder|not-negotiated|audio bus"

# 4. See the re-arm loop
docker logs --since 10m todd-studio | grep -a "forwarder failed"

# 5. Engine state (token via MediaEngineTokenService, role=admin,
#    perms=[studio_director])
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/room/list
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/forward/list

# 6. Reproduce the hang (the pivotal experiment, §3.5)
#    Run shape A (video only) then shape B (video + silent audio) inside the
#    container and compare exit codes: 0 vs 124.

# 7. Compile the gst feature (local builds CANNOT)
tar czf /tmp/src.tgz --exclude=target Cargo.toml Cargo.lock crates
# ... docker build on ubuntu:24.04 + libgstreamer1.0-dev ...
#   cargo test -p todd-transcode --features gst   # expect 31 passed
```

---

## 9. Timeline of the operator's reports

| Date | Report | Root cause found |
|---|---|---|
| Sep 11 | Public page 404, split screen in Studio | Ghost HLS camera registered by the manager |
| Sep 14 | Last successful SRS publish (16:25) | — |
| Sep 16 | "Video not playing, split into 2" | Ghost camera removed; forwarder still silent |
| Sep 17 | Scoreboard fixed; video still 404 | Over-count bug fixed (unrelated to video) |
| Sep 17 | "BREAK stuck", "no PGM badge" | Both fixed (unrelated to video) |
| Sep 18 | `OFF AIR` → Reconnect → `BROKEN` | Audio branch hang identified (§3.5); fix deployed but **unconfirmed** |

---

## 10. Closing note

The single most important artefact here is §3.5: **a video-only pipeline publishes
to SRS, and the same pipeline plus a silent audio branch hangs and publishes
nothing.** Everything else in the video path has been independently verified as
working (§3.1, §3.2, §3.8).

If that experiment's conclusion is correct, the fault is confined to how the
forwarder decides whether to build an audio branch — and the fix is to make
"no audio" a first-class, always-working case rather than something the engine
must tolerate.

Please treat my interpretations as fallible and the raw evidence as sound.
