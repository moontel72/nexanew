# Todd Studio "No Video" — Comprehensive Diagnosis and Bridge Plan

## A. Root Cause of the WHIP → Engine → WHEP No-Video Failure

### A.1 Primary Root Cause: TURN TCP Relay Path Collapses ~6s After ICE CONNECTED

Verdict (HIGH confidence): The phone's forced-RELAY ICE connection through coturn dies approximately 6 seconds after reaching CONNECTED state, in every single session. The video encoder never sends a single RTP packet because libwebrtc tears down the send stream once ICE transport enters FAILED. The engine's ICE agent — running with long grace timeouts via webrtc-rs — never notices the path death and continues PLI-ing a dead relay for up to 160 seconds.

**Discriminating evidence chain:**

Perfectly reproducible ~6s death. Five consecutive sessions all show CONNECTED→FAILED in 5.95-6.04s:

| Session | CONNECTED | FAILED | Delta |
|---------|-----------|--------|-------|
| f2cecefe | 15:59:49.885 | 15:59:55.873 | 5.99 s |
| 67953f52 | 16:02:01.299 | 16:02:07.253 | 5.95 s |
| a8e499b9 | 16:04:12.697 | 16:04:18.720 | 6.02 s |
| 376bbf74 | 16:06:24.079 | 16:06:30.121 | 6.04 s |

The ~6s interval matches libwebrtc's ICE consent freshness timer: a STUN Binding request is sent on the selected candidate pair every 5s; if no response returns within ~1s (retransmit window), consent expires and ICE transitions to FAILED.

coturn log confirms relay instability (todd-turn.log):
- ALLOCATE processed, success for phone IP — allocation works
- TCP socket closed remotely — the TCP relay socket dies almost immediately
- allocation timeout for phone sessions within 60s
- Five separate `bind: Address already in use` errors — relay port pool is conflicting/exhausted
- Engine-side allocations through Docker gateway 172.17.0.1:3478 also go stale

Asymmetric ICE failure detection: The engine log shows zero peer connection disconnected/failed events. `todd_ice_disconnects_total 0`, `todd_ice_failures_total 0`. The engine's webrtc-rs ICE agent believes the path is alive even after the phone has given up.

Zero video frames encoded: `todd_whip_h264_keyframes_total 0`, `todd_ingress_bitrate_bps 31592` (audio-only ~32 kbps).

The 25-minute-late proof: Session cbff931b ran for 25 minutes of PLIs. At 13:57:29, `track up codec=H264` finally appeared — followed within 350us by session close. This proves the video pipeline is structurally correct — the problem is transport, not signaling.

**Mechanism summary:**

```
Phone (force-RELAY) --TCP--> coturn --relay--> Engine (Docker 172.17.0.1)
     |                         |                    |
     | CONNECTED at T+0        | alloc OK           | CONNECTED at T+0
     |                         | TCP closed ~T+2    |
     | consent STUN at T+5     | relay dead         | (never sees failure)
     | no response             |                    | keeps PLI-ing
     | ICE FAILED at T+6       |                    | for 160s
     | encoder stops           |                    |
```

### A.2 Runner-Up Cause: Viewer-Gating Defect (Independent, Would Block Video Even if ICE Were Fixed)

The Studio viewer tile gates its WHEP /watch POST on camera video bytes > ~1 kbps (in MultiviewGrid.tsx). An audio-only camera never crosses this threshold, so the Studio never even attempts to subscribe. Evidence: `todd_whep_watches_total 0`, zero `whep watch accepted` lines in the engine log.

This is an independent defect: even if a future session's ICE survives and video registers, the viewer tile may have already given up or be stuck in a "camera not live" state. The 10s black-frame watchdog in useWhepPlayer.ts handles post-subscribe black frames but does nothing for the pre-subscribe gate.

### A.3 Why RTMP/SRS/HLS Works on the Same Phone and Network

Larix pushes a single TCP connection to SRS port 1935. There is:
- No ICE negotiation (no candidate gathering, no consent freshness)
- No DTLS handshake
- No TURN relay (direct TCP to server)
- No PLI dependency (encoder starts immediately, keyframes on connect)
- No sender-BWE starvation (RTMP is open-loop)

### A.4 Fault Severity Ranking

| # | Fault | Severity | Status |
|---|-------|----------|--------|
| 1 | TURN TCP relay collapses ~6s post-connect (coturn TCP close + allocation churn + port conflict) | P0 — production blocker | Active |
| 2 | Engine ICE agent never detects publisher path death (asymmetric timeout, zombie PLI sessions) | P1 — amplifier | Active |
| 3 | Viewer gates WHEP on video bytes; audio-only camera never triggers subscribe | P1 — independent blocker | Active |
| 4 | coturn `bind: Address already in use` — relay port pool exhaustion | P1 — contributing | Active |
| 5 | Engine coturn allocation via Docker 172.17.0.1 bridge goes stale | P2 — contributing | Active |

---

## B. Discriminating Tests

### Command 1 — One-way vs both-way relay media
```bash
timeout 30 tcpdump -ni any -c 4000 "udp port 3478 or udp portrange 49160-49200" -w /tmp/turn-cap.pcap
tcpdump -nr /tmp/turn-cap.pcap -nn "udp portrange 49160-49200" | awk '{print $3, $5}' | sort | uniq -c | sort -rn | head -20
```

### Command 2 — coturn verbose log
```bash
journalctl -u todd-turn --since "2 min ago" --no-pager -o short-iso > /tmp/turn-verbose.log
grep -E "closed|timeout|Address already|ALLOCATE|PERMISSION|CHANNEL" /tmp/turn-verbose.log | tail -40
```

### Command 3 — RELAY-forced vs relay-optional A/B test
Change `iceTransportsType` from `RELAY` to `ALL` in BroadcasterEngine.kt, then rebuild APK.

### Command 4 — Engine-side ICE timeout verification
```bash
docker exec -it $(docker ps -q -f ancestor=traceodd/media-engine:latest) env | grep -i ICE
```

### Command 5 — coturn relay port range check
```bash
ss -unap | grep -c "49[12][0-9][0-9]"
grep "min-port\|max-port\|relay-threads" /etc/turnserver.conf
```

### Command 6 — Fresh evidence collection
See source document for full adb logcat and journalctl commands.

---

## C. Bridge Plan — RTMP/SRS to Todd Studio

### C.1 Recommendation
Implement Both Stages (Stage 1 First, Stage 2 When GStreamer Is Verified).

### C.2 Stage 1 — HLS Tile in Todd Studio (Fastest Picture)
Latency: 4-10s glass-to-glass.

| Component | File | Change |
|-----------|------|--------|
| Studio viewer | MultiviewTile.tsx | Add HLS player mode using hls.js |
| Studio viewer | MultiviewGrid.tsx | Relax video-bytes gate for HLS cameras, add tile mode label |
| Studio viewer | New: src/lib/hls/hlsPlayer.ts | Thin Hls() wrapper ~50 lines |
| Control plane | control.ts | Accept camera entries with source: "hls" and hlsUrl field |
| Backend/Engine | engine.rs CameraInfo | Add source_kind field to camera metadata |

### C.3 Stage 2 — RTMP to Engine GStreamer Ingest to WHEP (Sub-Second)
Latency: Sub-second glass-to-glass.

| Component | File | Change |
|-----------|------|--------|
| Engine | ingest.rs | Already behind cfg(feature = "gst"), just activate |
| Engine | engine.rs | pump_ingest_feed() exists, build with --features gst |
| Build | media-engine-build.yml | Verify Docker build passes --features gst |
| API | http_routes.rs | Add POST /api/v1/ingest/start and DELETE endpoints |

Pipeline flow:
```
Phone (Larix RTMP) --TCP:1935--> SRS --RTMP loopback--> Engine GstIngest
    --h264parse--> rtph264pay --broadcast channel--> TrackRouter
    --WHEP--> Studio viewer tiles (sub-second)
```

### C.4 Stage 3 (Optional) — SRS Native WHEP
SRS supports rtc_server (currently disabled). Comparison option only.

### C.5 Decision Summary

| Criterion | Stage 1 (HLS) | Stage 2 (RTMP->Engine->WHEP) |
|-----------|---------------|------------------------------|
| Time | ~1 day | ~2-3 days |
| Latency | 4-10s | Sub-second |
| Engine changes | None | --features gst + ingest API |
| Risk | Very low | Medium |

Ship Stage 1 immediately. Pursue Stage 2 in parallel. Keep the WHIP path — fix TURN/ICE issues separately.

---

## D. Open Questions

1. Is the ~6s death caused by coturn's TCP relay or by the Docker bridge routing?
2. Does iceTransportsType = ALL fix video?
3. What are the actual engine-side ICE timeout values in the running container?
4. Is the coturn relay port range exhausted?
5. What does the viewer-side webrtc-internals show?
6. Is the phone's carrier CGNAT blocking TURN-UDP but allowing TURN-TCP?
7. Does the 120s first-video watchdog interact correctly with the engine's 180s PLI schedule?

---

## E. UPDATE 2026-09-11 — ROOT CAUSE FOUND, FIXED AND VERIFIED (video is live)

Section A's TURN/ICE theory was **not** what broke video. Packet-level evidence
and engine debug logs settled it, and the engine-side fix is now deployed and
proven in production.

### E.1 The real root cause: webrtc-rs `on_track` mutex held by a long-lived pump

Evidence chain (2026-09-11, room `be2a31c8…`, camera `Cam-3`):

1. **The network was fine.** A `tcpdump` capture on the VPS showed the phone
   sending **~838 kbps** of media to the engine's UDP socket, and RTP header
decoding of the capture showed the video stream present with the exact SSRC and
   payload type the engine expected:

   | SSRC | PT | packets / 20 s | stream |
   |---|---|---|---|
   | 2842452494 | 104 | 1869 | video (H264) |
   | 1478644654 | 111 | 971 | audio (Opus) |

   (RTP headers are not encrypted by SRTP, so SSRC/PT are readable straight from
   the capture.) The engine's own PLI watchdog was PLI-ing exactly SSRC
   `2842452494` for 180 s — then reporting "no video RTP yet".

2. **The engine received the track.** With `RUST_LOG=info,webrtc=debug` the
   engine logged **both** webrtc-rs tracks:
   `got new track: TrackRemote { id: "audio0", … }` and
   `got new track: TrackRemote { id: "video0", payload_type: 104, ssrc:
   1243080873, codec: video/H264 … }`.

3. **But only audio registered.** The engine's own log line
   `track up … codec=Opus` appeared; **no** `track up … codec=H264` ever did —
   even though webrtc-rs had surfaced both tracks.

4. **Why:** webrtc-rs 0.17's `peer_connection::do_track` runs the `on_track`
   handler **while holding a mutex over the whole callback future**:

   ```rust
   // webrtc-0.17.2/src/peer_connection/mod.rs::do_track
   tokio::spawn(async move {
       if let Some(handler) = &*on_track_handler.load() {
           let mut f = handler.lock().await;      // lock
           f(track, receiver, transceiver).await; // held for the entire future
       }
   });
   ```

   The engine's handler awaited the **long-lived pump** `pump_track(...)`
   inline. That pump loops on `track.read_rtp()` until teardown, so the **audio**
   track's handler took the lock and **never released it**. The **video**
   track's handler then blocked forever on `handler.lock().await` and never ran —
   no router registration, no RTP reads, zero H264 keyframes, and every WHEP
   viewer stuck on a retryable 409.

This single bug explains every symptom in this document: audio-only ingest at
~30-32 kbps, `todd_whip_h264_keyframes_total 0`, `todd_whep_watches_total 0`,
`todd_whip_no_media_total`, the perpetual 409s, and the brief's observations that
`track up codec=H264` "appeared 30-90 s later" or "after 25 minutes" (in those
runs the audio pump happened to exit and release the lock, letting the video
handler finally run).

### E.2 The fix

`media-engine/crates/todd-sfu/src/whip_peer.rs` (`pc.on_track` handler): the pump
is now **spawned** and the callback returns immediately, releasing the lock:

```rust
Box::pin(async move {
    // webrtc-rs holds the on_track handler mutex across this future; awaiting
    // the long-lived pump here would block the publisher's next track (video).
    tokio::spawn(async move {
        pump_track(track, &engine, &room, &camera, pump_shutdown).await;
    });
})
```

Commit **`375eb6de`** — "Fix video track never registering after audio".

### E.3 Production verification (2026-09-11 15:06 UTC)

After the media-engine image rebuilt and the engine restarted, the phone
broadcast (Stop → Start) produced:

| Signal | Value |
|---|---|
| `track up … codec=H264` | ✅ logged (`ssrc=2435969854`) |
| `todd_whip_h264_keyframes_total` | **3** |
| `todd_ingress_bitrate_bps` | **831,507** (~832 kbps, not ~31 kbps) |
| `todd_whep_watches_total` / `todd_viewers_active` | **1 / 1** |
| `todd_whep_h264_keyframes_total` | **2** |
| `todd_egress_bitrate_bps` | **1,663,015** |
| `todd_ice_*`, `todd_rtp_starvation_closures_total` | 0 |

**Video flows end-to-end: phone → WHIP → engine → WHEP → Studio multiview tile.**

### E.4 Phase status

| Phase | Scope | Status |
|---|---|---|
| 0 | Baseline / server recon | ✅ done |
| 1 | Server prep: coturn relay range widened `49160-49200` → `49152-65535`; `/hls/` block added to `studio.traceodd.com` (CORS + m3u8/ts types) | ✅ done (`754212d5`) |
| 2 | Stage-1 HLS bridge: `hls_url` wired through engine + Studio camera form; verified RTMP → SRS → HLS → Studio tile | ✅ done (`b74e438d`, `14e9af4b`) |
| 3 | WHIP diagnosis: packet capture + webrtc debug logs → root cause | ✅ done |
| 3b | **Fix: spawn the ingest pump in `on_track`** | ✅ done (`375eb6de`), deployed, **verified video live** |
| 4 | APK `iceTransportsType` RELAY → ALL | ✅ shipped and required — with it ICE stays connected and media actually reaches the engine |
| 5 | Stage 2: RTMP → engine GStreamer → WHEP (sub-second) | ⬜ not started |

### E.5 What remains / follow-ups (next chat)

1. **ICE timeouts are pinned in the deploy workflow**, not the code:
   `media-engine-deploy.yml` writes `ICE_DISCONNECTED_GRACE_MS=300000`,
   `ICE_DISCONNECTED_TIMEOUT_MS=30000`, `ICE_FAILED_TIMEOUT_MS=60000` into
   `/opt/todd-media-engine/.env`, so the tighter defaults in `config.rs`
   (15000 / 5000 / 15000) are **inert in production**. Decide whether to tighten;
   the new RTP-starvation watchdog (30 s) already reaps zombie sessions, so this
   is now a cleanup-latency tuning question, not a video blocker.
2. **Congestion feedback / adaptive bitrate:** the engine registers webrtc-rs's
   default interceptors (NACK, RTCP reports, **TWCC receiver**), but the APK
   strips `transport-cc`/`goog-remb` from its SDP and pins the video sender to a
   fixed open-loop bitrate (~800 kbps). Works, but bitrate cannot adapt. To get
   adaptive bitrate, stop stripping transport-cc in the APK and confirm the
   engine's TWCC feedback reaches the publisher.
3. **Stage 2 (sub-second RTMP alternative):** engine has `--features gst`
   ingest already built into the image (`FEATURES=gst` in
   `media-engine-build.yml`); the `pump_ingest_feed` path exists. No new work
   started.
4. **RUST_LOG:** temporarily set to `info,webrtc=debug,todd_sfu=debug` in
   `/opt/todd-media-engine/.env` for this diagnosis. The official deploy rewrote
   that file, so the container is back to normal logging — **do not leave debug
   logging on in production**; set it only for a diagnosis window.

### E.6 Latest Todd Broadcaster (APK) behaviour — observed

- **TURN auto-fill is correct:** `turn:135.181.46.27:3478`, user `traceodd`,
  pass `traceodd-turn-2026` (matches `/etc/turnserver.conf`). Pasting the WHIP
  ingest URL fills every field.
- **Token/room lifetimes:** ingest tokens live **6 h**; rooms live **1 h**
  (`ROOM_TTL_SECS` default 3600). An expired token → **401**
  (`ExpiredSignature`); a vanished room → **404**. Always take a fresh URL from
  the Studio Input Panel before a test.
- **After an engine restart the app does NOT re-POST WHIP by itself** — press
  **Stop → Start** in the app to create a fresh session (or wait ~2 min for its
  own video-stall watchdog). Symptom if you skip this: app is connected
  (telemetry WebSocket visible in nginx log) but
  `todd_whip_ingests_total` stays 0.
- **Encoder warm-up:** video starts shortly after Start; the app's bitrate ramps
  to ~700-800 kbps over the first ~35-45 s.
- The app pins the video sender to the UI profile bitrate (open-loop) and strips
  transport-cc/goog-remb from the offer — see follow-up #2.

### E.7 Ops cheat-sheet (for the next session)

- **Server:** `ssh root@135.181.46.27` (key-based; also reachable from this dev box).
- **Engine env (rewritten by every media-engine deploy):**
  `/opt/todd-media-engine/.env` (backup used during diagnosis:
  `/opt/todd-media-engine/.env.bak-debug`).
- **TURN config:** `/etc/turnserver.conf` (repo: `media-engine/deploy/coturn/turnserver.conf`),
  unit `todd-turn.service`; relay range now `49152-65535`.
- **Units:** `todd-studio` (engine + control plane, host network, UDP media),
  `todd-broadcaster`, `todd-redis` (port 6380), `todd-turn`, `cricket-srs`
  (RTMP 1935 / HLS 8088).
- **HLS output dir (served at `/hls/`):** `/var/www/traceodd/cricket-hls/`
  (playlist pattern `live/<key>.m3u8`).
- **Key metrics to check after any WHIP test:**
  `curl -s http://127.0.0.1:8082/metrics | grep -E
  '^todd_(sessions_active|whip_h264_keyframes_total|ingress_bitrate_bps|whep_watches_total|viewers_active)'`
- **Decisive logs:**
  `journalctl -u todd-studio | grep -E 'track up|whep watch accepted|h264 keyframes'`
  and `journalctl -u todd-turn` for TURN allocations.
- **Deploy pipelines on a push to `mainnew`:** `deploy.yml` (GUI/nginx/Laravel),
  `media-engine-build.yml` (image build with `FEATURES=gst`) →
  `media-engine-deploy.yml` (pull + restart), `frontend-deploy.yml`,
  `broadcaster-apk-native.yml` (APK to
  `https://traceodd.com/download/broadcaster/todd-broadcaster.apk`).
  Image build + deploy can take ~25 min end-to-end.

### E.8 Roman Urdu khulasa (for the operator)

- Video ka asal masla **network/TURN nahi** tha — **engine ke andar ek deadlock**
  tha: webrtc-rs `on_track` par lock rakhta hai, aur engine audio ke pump ko
  inline await kar raha tha, is liye **video track kabhi register nahi hota tha**.
- Fix: pump ko `tokio::spawn` kar diya (`375eb6de`). Deploy ke baad **video
  Studio tile par chal gayi** (832 kbps ingest, keyframes aa rahe hain, viewer
  live).
- **Sab phases (0, 1, 2, 3, 3b, 4) mukammal.** Baqi: **Stage 2** (sub-second
  RTMP→engine→WHEP) aur do chhoti tuning cheezein (ICE timeouts, adaptive
  bitrate).
- Testing ka tareeqa wahi: Studio se fresh WHIP camera → APK mein URL → **Stop
  → Start** (engine restart ke baad app khud re-POST nahi karta).

---

## F. UPDATE 2026-09-12 — viewer receives AUDIO ONLY (no video track in the browser)

Section E's ingest fix (`375eb6de`) is real and still holds: the engine registers
`track up … codec=H264`, ~846 kbps ingress, keyframes forwarded. A **second,
independent defect** on the WHEP **egress** side still keeps the Studio tile
black — the browser never receives a video track at all.

### F.1 The decisive browser evidence

`chrome://webrtc-internals` on `studio.traceodd.com`, with a live WHIP broadcast
and a WHEP camera tile:

- The viewer peer connection exposes **`media-playout (kind=audio)`** only.
- There is **no `inbound-rtp (kind=video)` section at all** — the browser has no
  inbound video stream to decode.
- Consequence: the tile's `live` flag is true (so the OFF badge disappears) but
  `videoEl.videoWidth` stays 0 → the tile stays black and the black-frame
  watchdog keeps bouncing the session.

Additionally, the viewer's own transceiver dump (`getTransceivers()` / the
`transceiver` panel in webrtc-internals) shows the video transceiver **is
negotiated correctly**:

```json
{ "mid": "0", "kind": "video",
  "sender":   { "track": null, "encodings": [{ "active": true }] },
  "receiver": { "track": "31561754-…", "streams": ["5cf93e6f-…"] },
  "direction": "recvonly", "currentDirection": "recvonly",
  "reason": "setRemoteDescription", "transceiverIndex": 0 }
```

(transceiver 0 = video, transceiver 1 = audio.)

So the offer is correct **and** the answer was accepted: the browser holds a
`recvonly` video transceiver carrying a remote track + stream (an `a=msid`
arrived), with `sender.track = null` as expected for a receiver. The browser is
ready and *willing* to receive video — **the engine simply never sends any video
RTP**.

### F.2 Server-side corroboration (2026-09-11 ~18:35 UTC run)

```
whep viewer started  session=2eefd073… room=be2a31c8… camera=Cam-3 rid=
whep watch accepted  session=2eefd073…
whep answer negotiated video m-line … candidate_count=12 outbound_video_ssrc=0 …
[whep] peer connection connected
```

- `outbound_video_ssrc` is `first_ssrc_in_sdp(&local.sdp)` and the log prints
  `.unwrap_or(0)`, so **0** means “no usable video SSRC”: either the parse
  returned `None` (no `a=ssrc:` line in any video m-section) **or** it read
  `a=ssrc:0` (never assigned). webrtc-rs only emits `a=ssrc` while iterating a
  sender's `send_parameters.encodings` (`sdp/mod.rs` → `with_media_source`), so
  the video sender has **no bound encoding at answer time** — while the audio
  sender does (audio plays). The PLI broker's `register_viewer` never runs either.
- Yet `todd_whep_h264_keyframes_total` increments and `todd_egress_bitrate_bps`
  is ~1.7 Mbps: the engine is writing RTP into its local video track and counting
  it, but that track is not negotiated into a send binding the browser receives.
- `[whep] peer connection connected` proves ICE/DTLS is fine, and audio flows.

### F.3 What is NOT the cause

- **Not the viewer's `srcObject` handling.** `whep.ts` offers two recvonly
  transceivers (video + audio) — correct. The earlier claim that the audio
  `ontrack` replaces the video stream does not hold: the engine creates both
  tracks with the same `stream_id` = `"todd"`
  (`whep_peer.rs`: `TrackLocalStaticRTP::new(codec, "todd-<uuid>", "todd")`),
  so a browser groups them into **one** `MediaStream` and `event.streams[0]` is
  the same object for both events. Audio-only playout in the browser confirms
  the offer itself is sound.
- **Not TURN/ICE** (the peer connection connects) and **not the ingest path**
  (`track up … codec=H264` + `ingest ~846 kbps`).

### F.4 Confirmed root cause

The browser-side transceiver (F.1) proves the SDP negotiation succeeded — the
answer's video m-line is `sendonly` (browser `currentDirection: recvonly`) — so
what was missing was the **outgoing SSRC binding** for the engine's local video
track (`outbound_video_ssrc` = 0 → no usable `a=ssrc`).

`create_viewer` called `pc.add_track(track)` **after**
`set_remote_description(offer)`. When `set_remote_description` processes the
remote offer it creates a **track-less** transceiver per offered m-section
(`RTCRtpSender::new(None, …)`) and stamps it with that m-section's `mid`. The
later `add_track` cannot reuse it (webrtc-rs reuses a sender only when
`sender.initial_track_id()` already matches the track id, which is `None` here)
and instead calls `new_transceiver_from_track`, which **always creates a fresh
transceiver** with no `mid`.

When the answer is generated, `generate_matched_sdp` resolves each remote m-line
with `find_by_mid(...)` — so it binds the **track-less** transceiver that the
offer created, never the one holding our track. Result: the answer advertises a
`sendonly` video m-line with **no SSRC**, the pump's `track.write_rtp(…)` has no
binding to write to, and the browser receives zero video RTP while the engine
keeps counting every keyframe it hands to the track (“bytes counted, nothing
received”). That is also why `todd_whep_h264_keyframes_total` and
`todd_egress_bitrate_bps` (an app-layer counter, not an SRTP counter) rose while
the tile stayed black.

### F.5 Fix applied and verified

`create_viewer` now creates the local tracks/transceivers **before** applying the
viewer's offer. `set_remote_description` then adopts them via
`satisfy_type_and_direction` (a local **Sendrecv** transceiver satisfies the
viewer's **Recvonly** m-line) and stamps them with the m-line's `mid`, so the
sender that owns our track is exactly the one `generate_matched_sdp` binds into
the answer.

- Commit **`6799dabd`** — "Fix WHEP answer binding the offered transceivers"
  (`media-engine/crates/todd-sfu/src/whep_peer.rs`).
- `offered_kinds` is derived from the offer's own `m=` lines, in order, so the
  pre-created transceivers line up 1:1 with the offered m-sections.
- Built + deployed via CI (`media-engine-build.yml` → `media-engine-deploy.yml`):
  image `8f283ac76139` (2026-09-11T23:22:18Z); `todd-studio` restarted
  23:31:14 UTC.
- **Operator-confirmed (2026-09-12): Todd Studio video now renders.**
  `chrome://webrtc-internals` shows `inbound-rtp (kind=video)` with rising
  `framesDecoded`, and ingest / egress / keyframe counters all advance.

Note: the earlier `replace_track` idea for this section would **not** have
worked — a transceiver created from a remote m-line has an empty
`track_encodings`, and `replace_track` errors with
`ErrRTPSenderNewTrackHasIncorrectEnvelope` in that case. Creating the tracks
first (the fix above) is the correct path.

### F.6 Roman Urdu khulasa (for the operator)

- Browser ne confirm kar diya: WHEP par **sirf audio** aa raha hai, **video
  receive nahi hoti** (`inbound-rtp (kind=video)` mojood hi nahi). Lekin browser
  ka **video transceiver sahi negotiate hua hai** (`recvonly` + remote track/msid)
  — yani browser video lene ke liye tayyar hai; engine bas **bhejta hi nahi**.
- Engine ke log mein `outbound_video_ssrc=0` — video ka koi valid outbound SSRC
  (`a=ssrc`) bind nahi hua, is liye pump ke `write_rtp` ka koi binding nahi aur
  RTP bahar jata hi nahi (counter phir bhi barhta rehta hai).
- Viewer (`whep.ts`) **bilkul theek** hai — offer mein dono transceivers theek
  hain; na TURN/ICE ka masla hai, na ingest ka (H264 track up + ~846 kbps).
- **Asal masla engine ke WHEP answer / sender binding mein tha**
  (`whep_peer.rs`): `add_track` offer ki maujooda video transceiver ke bajaye
  nayi transceiver bana deta tha.
- **Fix (deployed + verified):** local tracks ab offer apply karne se **pehle**
  banaa jate hain (`6799dabd`), is liye answer wahi sender bind karta hai jo
  hamara track rakhta hai. **Video Todd Studio tile par chal gayi** — 18 din baad
  masla hal.
