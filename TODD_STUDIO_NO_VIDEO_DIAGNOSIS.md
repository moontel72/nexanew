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
