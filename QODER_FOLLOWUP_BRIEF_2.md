# QODER FOLLOW-UP BRIEF #3 — NATIVE Kotlin APK: video registers but encoder stalls (VP8 software)

> **TEMPORARY HANDOFF FILE** — updated 2026-09-07 (23:35 UTC) with the live command
> results from the native Kotlin broadcaster run (room `d4683c95-0d0f-4f92-b0eb-c9635c3b7899`,
> camera `Cam-04`, Samsung J-series phone, 23:22–23:31 UTC).
> Brief #2 (Flutter-era) is superseded: with the native APK the engine DOES see a
> `track up codec=Vp8` every session — the old "publisher sends audio only / no video
> track at all" conclusion no longer applies. **Delete this file before your final commit.**

---

## 1. Live evidence — 2026-09-07 23:22–23:31 UTC (native Kotlin APK)

Every ~41 s a brand-new WHIP session appears (the app watchdog restarts the
broadcast — 15 s stall checks + restart):

```
23:22:31 whip answer media sections   answer_media=["m=video ... 96 39 98 127 104 108", "m=audio ..."]
23:22:31 PLI watchdog state room=... offer_video_ssrc=1747593322 offer_has_video_ssrc_lines=true offer_has_video=true
23:22:32 track up ... codec=Vp8        ← video track registers 0.2–0.3 s after the answer
23:23:01 track up ... codec=Opus       ← audio track up ~30 s LATER
23:23:12 (next offer — new session)
```

Metrics (two samples 30 s apart):
| Metric | Sample 1 | Sample 2 |
|---|---|---|
| `todd_rtp_packets_in_total` | 276,635 | 277,238 |
| `todd_rtp_bytes_in_total` | 28,250,925 | 28,537,755 |
| `todd_ingress_bitrate_bps` | 0 | 34,163 |

≈ 287 KB / 30 s ≈ 76 kbps averaged, gauge ~34 kbps → **audio-only level. Video RTP
after the initial frame(s) is effectively zero.** Two sessions also logged
`track ended ... error=DataChannel is not opened` when the superseding session closed them.

## 2. What this proves

1. **Engine + Studio + network are ruled out**: ICE disconnects/failures = 0; WHIP 201s
   every time; the PLI watchdog arms every session (`offer_has_video_ssrc_lines=true`).
2. **The publisher's video encoder emits a few frames at session start** (enough for
   `track up codec=Vp8`) **and then stalls** — nothing after that, forever.
3. No `"no video RTP yet — sending PLI"` nudge lines ever appear: the engine sees the
   initial video packets and considers video healthy, so its 4/8/12/…/60 s PLI nudge
   never fires. The app watchdog then restarts the whole session every ~41 s.
4. Audio is also delayed ~30 s in some sessions (Opus track up late, order varies) —
   consistent with one starving CPU: software video encoding hogging everything.

## 3. Root cause (HIGH confidence) — implemented fix below

`DefaultVideoEncoderFactory(enableH264HighProfile=true)` **drops Baseline-only
hardware H.264 encoders** (Samsung J-series encoders are Baseline-only). With H.264
excluded and no hardware VP8 on these chipsets, negotiation lands on **software VP8**
(`OMX.google.vp8.encoder`-class libvpx), which cannot sustain 480p@30 on an ancient
chipset → a few frames, then stall. The engine answers VP8 first because the offer
lists VP8 first (publisher's codec order is preserved).

**Client-side fix (commit `FIX: Prefer hardware H264 encoding`, BroadcasterEngine.kt):**
- `enableH264HighProfile=false` → Baseline hardware H.264 stays in the factory list.
- New `H264PreferredEncoderFactory` wrapper: when any H.264 encoder exists the offer
  advertises **only H.264**, so negotiation can never land on VP8. Falls back to the
  delegate's full list when a device has no H.264 at all.
- `initialize()` logs the effective encoder list ("Available video encoders: ...") so
  the next run proves the codec choice from logcat without server archaeology.

## 4. Verify after the next APK deploy

1. Logcat: `Available video encoders: H264 {...}` present.
2. Engine logs: `track up ... codec=H264` (not Vp8).
3. `todd_ingress_bitrate_bps` ≥ ~300–400 kbps sustained at 480p.
4. WHEP 201 + video renders in the Todd Studio tile (brief #2 DoD, unchanged).
5. Re-check the ~30 s audio delay anomaly once video is healthy (open item).

## 5. Isolation tests worth running in parallel

- Web broadcaster (PC Chrome) on a fresh room/camera → proves engine video ingest.
- Second Android phone with the new APK → rules out this specific handset.
- Phone dropdown at 360p/15 fps → capability floor check.

## 7. UPDATE 2026-09-08 — A22 5G + engine PLIs prove it: sender BWE starvation

New live evidence (session 14:25:46 UTC, room b7f13e87, Cam-05):

```
14:25:47 peer connection connected + track up Opus (instant)
14:25:50/58, 14:26:10  engine: no video RTP yet — sending PLI (4/8/12s)  ← engine IS asking
14:26:17 track up H264  ← first video RTP ~30 s AFTER connect
14:26:28 next offer      ← app watchdog killed it 11 s after video finally started
```

Facts established this round:
- Test phone is a **Galaxy A22 5G (SM-A226B, Dimensity 700, Android 11+)** — fully capable;
  the J-series assumption was wrong. Larix/Ninja previously pushed video from this phone.
- Camera preview runs from app open (capture path OK). Codec = H264 hw (42e01f) OK.
- ICE/network now OK on multiple networks (candidates 4-6; one `candidates=0` stretch was a
  transient network state; TCP to studio.traceodd.com fine from phone).
- Engine sends PLIs on schedule yet video RTP stays ~0 for ~30 s, then trickles at ~25-30 kbps
  (`Video bitrate too low` watchdog restarts every ~41 s kill it right as it starts).
- The engine sends **no congestion feedback** (no TWCC/REMB to publishers — only the PLI
  pump writes RTCP). libwebrtc's estimator then starves video to ~30 kbps; audio (fixed
  rate) flows instantly. Larix/OBS work because they send open-loop fixed bitrate.

Fix (commit `FIX: Open-loop video bitrate and no-progress watchdog`):
- Strip transport-cc/goog-remb (rtcp-fb + extmap) from the local offer → no BWE negotiation.
- Pin the video sender min=max bitrate to the UI profile (EncoderConfig bitrate) via
  `RtpSender.setParameters` → Larix-style fixed CBR.
- Watchdog now restarts only after 3 consecutive no-progress checks (~45 s) instead of any
  single sub-50-kbps reading → gives the encoder its warmup window.
- `Logging.enableLogToDebugOutput(LS_INFO)` → native WebRTC logs in logcat for the next run.

Verify: engine shows `track up codec=H264` quickly, ingress ≥ profile kbps (480p→~800), no
41 s restart cadence, video renders in Studio. If video still stalls: read logcat for the
native `webrtc` encoder/BWE lines this build enables.

## 8. Constraints (unchanged)

- Do NOT weaken engine F1–F19 (PLI scope, SDP SSRC parsing, 409-not-live gate, etc.).
- Client-side codec preference is explicitly allowed by brief #2 suspect 2.
- Validate: Gradle `compileDebugKotlin` green; commit on `mainnew`; push (CI rebuilds
  and uploads the APK); then re-run section 4. Delete this file before the final commit.

---

# QODER FOLLOW-UP BRIEF #4 — late-video WHIP lifecycle: "track ended error=DataChannel is not opened" + session removal (2026-09-09)

> Appended verbatim-essentials from the moontel72/nexanew black-video task brief. Findings +
> fixes implemented in this round are recorded in section 9 (added by the agent).

## Brief: production diagnostics (room b560881c-04ec-42be-bba0-96690ac4150d, camera cam-08)

Server: Ubuntu 24.04, public 135.181.46.27. Services: todd-studio (Docker
traceodd/media-engine:latest), todd-broadcaster, todd-redis. Disk 93.9% full of 149.92 GB;
148 Docker images = 134.5 GB (130.6 GB reclaimable); journald ~4.0 GB. UDP counters:
UdpInDatagrams 8,114,290 / UdpInErrors 11,128 / UdpRcvbufErrors 10,710 /
UdpOutDatagrams 2,228,400. tcpdump 2000 packets, 0 dropped. TURN traffic active; media
relayed between broadcaster and server.

Signaling/ICE: WHIP 201 OK; ICE Connected; offer m=video H264/90000 + m=audio Opus/48000/2,
4 remote candidates; answer 12 candidates (4 host, 6 srflx, 2 relay). TURN allocations,
permissions, channel bindings OK. → HTTP signaling + basic ICE are NOT the primary failure.

Production log sequence (single session):
1. WHIP session accepted, ICE connected.
2. Audio track registers immediately: track up … ssrc=2349172553 rid=None codec=Opus
3. SFU sends PLIs at 4, 8, 12, 20, 30, 40, 50, 60 s: "no video RTP yet — sending PLI to publisher"
4. Video finally registers much later: track up … ssrc=3035725903 rid=None codec=H264
5. Immediately afterward the video track ends: track ended … error=DataChannel is not opened
6. PeerConnection closed; WHIP session removed.

(Previous session showed the same pattern; the brief records it in repo files:
media-engine/crates/todd-sfu/src/{engine,whip_peer,whep_peer,router,pli,http_routes}.rs,
media-engine/deploy/systemd/*.service, deploy/docker/docker-compose.yml,
deploy/coturn/{turnserver.conf, coturn.conf}.)

Brief's questions to verify in the webrtc-rs lifecycle:
- Can TrackRemote legally return "DataChannel is not opened" for a media track, and should
  that error terminate only that track pump or the whole WHIP session?
- Is the session closed because one track ends, because the PC enters Failed/Closed, or
  because cleanup removes router state?
- Is a late video track registered after the viewer already negotiated a fallback/rejected video?
- Are TrackRemote::read_rtp() errors transient during media startup (retry vs unregister)?
- Is PLI sent to the correct publisher SSRC through the correct PeerConnection?
- Is audio-first/video-later ordering handled safely?
- Can a WHEP viewer attach to a video layer that did not exist when the viewer was created?
- Does H264 fmtp/profile-level-id negotiation match the Android/Larix publisher profile?
- Are router subscriber queues too small / wrongly treated as permanent failure?
- Is "DataChannel is not opened" an incorrect PC/DataChannel assumption, premature close, or
  a separate app lifecycle bug?

Implementation requirements (from the brief):
1. Reproduce/unit-test relevant behavior with existing mocks where possible.
2. Smallest reliable code change fixing the root cause.
3. Do not hide real errors with a broad catch, silent fallback, or unconditional retry loop.
4. Preserve correct cleanup for genuinely failed/closed PeerConnections.
5. Ensure: late video track does not kill a healthy WHIP session; transient RTP read failure
   during startup does not immediately destroy camera state; router registers/unregisters
   audio and video independently; existing WHEP viewers receive late video or retry/rebind
   controllably; PLIs go only to the correct publisher video SSRC; H264 forwarding stays
   browser-decodable.
6. Add structured logs/metrics distinguishing transient track-read errors, permanent track
   termination, PC failure, RTP ingress, router forwarding, WHEP egress.
7. No destructive production changes (no image/journal/media/db deletion); document ops
   cleanup separately.
8. Check Docker/systemd runs the intended current binary/image; runtime config may explain
   behavior; primary change stays in the repository.

## Section 9 — agent findings & fixes (2026-09-09, engine round on commit dfbda904+)

Verified against webrtc-rs 0.17.2 vendored source:
- error.rs: `#[error("DataChannel is not opened")] ErrClosedPipe` — the message is a
  webrtc-rs MISLABEL for a generic closed pipe. RTPReceiver returns ErrClosedPipe whenever
  the receiver is Stopped (rtp_transceiver/rtp_receiver/mod.rs wait_for/error_on_close), and
  rtp_sender/srtp_writer paths return it when stop_called fires. Media reads never touch
  data channels → the log line means "receiver stopped / PC closed", never an app
  DataChannel bug.
- peer_connection_internal.rs start_receiver: on_track fires ONLY after the FIRST RTP
  packet per SSRC (track.peek() blocks until data; failure → no on_track). So a silent
  video encoder = no video track in the router at all; "track up codec=H264" 30-90 s after
  connect is the encoder waking up (engine PLI wake-up), not a late negotiation. Late
  on_track cannot race a viewer: viewers are 409-gated on lowest_video_rid and pumps
  subscribe by (room, camera, rid) key, so a video layer registering later resumes
  seamlessly on the same subscription.
- read_rtp errors in 0.17 are ALL terminal (ErrClosedPipe / ErrRTPReceiverNil /
  ErrCodecNotFound per-packet); none are transient/retryable → no retry loop added
  (requirement 3). Session removal after a track end comes from the PC state machine
  (Failed/Closed → prune_dead_sessions → stop_session), takeover replacement, or the
  disconnected-grace watchdog (preserve-subscribers path). A single track pump exiting only
  unregisters its own (rid, ssrc) entry; audio/video register/unregister independently.
- Root cause of the cam-08 cycle: the CLIENT watchdog restarts the session when video has
  not started/progressed within its window — racing the engine PLIs that finally wake the
  encoder ("track up H264" + instant ErrClosedPipe = the app closed the PC at that moment).
  Engine-side lifecycle semantics were sound; the kill decision is app-side.

Fixes implemented this round:
1. engine.rs — video-start PLI nudge extended 60 s → 180 s (10 s cadence after 60 s) with a
   comment documenting the on_track-after-first-RTP quirk.
2. whip_peer.rs pump_track — read-error classification & logs: benign race (session close
   signalled), expected receiver-stopped (ErrClosedPipe/ErrRTPReceiverNil), and unexpected
   error kinds (loud warn); "track ended" log lines now read
   "track ended — receiver stopped (peer connection closed)" so ops stops chasing the
   DataChannel red herring.
3. apps/broadcaster-android MainActivity.kt — watchdog first-video grace: no-progress
   checks before the session's first video byte no longer count toward the 45 s restart;
   a 120 s FIRST_VIDEO_DEADLINE still restarts a truly dead encoder. Post-first-video
   freeze detection (3 checks / ~45 s) unchanged.
4. Earlier same-branch commit dfbda904: H264 IDR counters on ingest + per-viewer egress,
   "whep answer negotiated video m-line" log, h264.rs NAL detector + 6 unit tests.
