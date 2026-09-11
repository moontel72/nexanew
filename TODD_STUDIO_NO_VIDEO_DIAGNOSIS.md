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
