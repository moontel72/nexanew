# QODER FOLLOW-UP BRIEF #2 — Publisher sends AUDIO ONLY; Studio + engine confirmed correct

> **TEMPORARY HANDOFF FILE** — created 2026-09-06 (evening UTC) for the Qoder agent.
> Brief #1 (`QODER_TAKEOVER_BRIEF.md`) was deleted after your previous work. This file is now the
> single authoritative handoff: it is **self-contained**. Read it fully, read the referenced repo
> files, verify on the live server, fix the root cause yourself.
> **Delete this file before your final commit.**

---

## 1. Current status (what is already done and deployed)

- All prior audit fixes **F1–F19** and the follow-up commit `c15689ea` are committed on branch `mainnew` and **deployed**:
  - Engine: media PLI drain scoping, section-aware SDP SSRC parsing, `lowest_video_rid` watchdog, marshal-error tolerance (50x), 60s PLI nudge cadence (`4/8/12/20/30/40/50/60s` + `delay_secs` log), session `DELETE`, closed-subscriber pruning in `router::forward`, plus **diagnostic logging** of WHIP offer/answer media sections.
  - Broadcaster APK/web: 300s ICE recovery, reconnect/backoff fixes, WHIP `Location` + `DELETE`, **mobile resume-restart** (`_onAppResumed` restarts capture on Android/iOS even when PC is Connected), **audio-only offer guard** (`_sdpHasMediaSection` in `whip_client.dart` fails fast if the SDP lacks an active `m=video`).
  - Studio GUI (Tauri + browser build): liveness-gated WHEP start (F8), black-frame watchdog 10s (F16), backoff cap 8s (F18), `Location` + `DELETE` on close (F9), encoded watch URLs (F19).
- Evidence that the **new engine build is live** on the server: the log lines `"whip offer media sections"` / `"whip answer media sections"` (code in `media-engine/crates/todd-sfu/src/whip_peer.rs` L46–64 and L233–237) appear in the running container's output. A previous container (old image) did not log these.

## 2. NEW live evidence — 2026-09-06 20:39 UTC (room `fc1d63bd-d42b-4720-9b85-f052d7368b69`, camera `Mob-02`)

WHIP session on the fresh deploy, with the operator's **newly downloaded broadcaster APK**:

```
whip offer received candidates=12
whip offer media sections
  offer_media = [ "m=audio 41162 ... 111 63 9 102 0 8 13 110 126",
                  "m=video 35112 ... 96 97 104 105 106 107 39 40 98 99 108 109 125" ]
  offer_rtpmap = [ ... 111 opus/48000/2, 96 VP8/90000, 104 H264/90000, 106 H265/90000,
                    39 AV1/90000, 98 VP9/90000, ... rtx/red/ulpfec ]
whip answer media sections
  answer_media = [ "m=audio 9 ... 111 9 0 8",
                   "m=video 9 ... 96 104 106 39 98 125" ]
  answer_rtpmap = [ ... 111 opus/48000/2, 96 VP8/90000, 104 H264/90000, 106 H265/90000,
                     39 AV1/90000, 98 VP9/90000, 125 ulpfec/90000 ]
track up room="fc1d63bd-..." camera="Mob-02" ssrc=1970751204 rid=None codec=Opus
```

Metrics at the same time:
| Metric | Value |
|---|---|
| `todd_sessions_active` | 1 |
| `todd_viewers_active` | 0 |
| `todd_rtp_packets_in_total` | 180,381 |
| `todd_rtp_bytes_in_total` | 15,219,467 → **≈84 bytes/packet = audio only** |
| `todd_rtp_packets_forwarded_total` | 0 |
| `todd_ice_disconnects/failures/closures` | 0 |

Also: **no WHEP POSTs** in nginx access log (last 300 lines), and **no** `track up` / `whep viewer started` / `no video RTP` lines in the last 30 minutes.

## 3. Operator observations (verbatim intent)

- The tile above the player used to show an **OFF button that disappeared a few seconds after the broadcaster started**. Now the **OFF button stays** the whole time.
- The operator **downloaded a brand-new Todd Broadcaster APK** (they were not 100% sure the new code was inside it — verify the APK build/version).
- Todd Studio was tested in **Google Chrome incognito** (Ctrl+Shift+N).
- **Video still does not display.**
- This time **no red errors appeared in the Studio console** (previous runs showed 409 spam).

## 4. Verified analysis — conclusions you MUST start from

1. **Negotiation is healthy.** Both `m=audio` and `m=video` were offered and answered with matched codecs (VP8/H264/H265/AV1/VP9). The publisher's own offer lists **VP8 first** (`96 VP8/90000` before `104 H264/90000`), and the answer echoes that order — the publisher's stack prefers VP8.
2. **The publisher sends NO video RTP.** Only `track up codec=Opus` ever appears; no video `track up`; bytes/packet ≈ 84 (Opus); `forwarded = 0` is explained by there being no video track and no viewers.
3. **The OFF button staying, zero WHEP POSTs, and zero console errors are all CORRECT new-client behavior (F8 gate), NOT a bug.** The Studio tile will not start a WHEP watch until the engine has a real video track (`lowest_video_rid() != None`). It is waiting, honestly, for video that never arrives. Do not "fix" the Studio to start WHEP anyway — that recreates the black tile.
4. **Therefore the entire remaining problem is on the publisher → engine video ingest hop.** The engine never sees video RTP, so the phone's video encoder is producing zero frames (or the video track never starts), despite a negotiated video m-line.
5. The mobile **resume-restart fix** only fires on a background→foreground transition. If the encoder **never starts at all** (or the app was backgrounded/locked before/while connecting), that fix never triggers. A fresh APK failing the same way points at a deeper, non-resume cause.

## 5. Primary suspects (verify each, then fix)

### Suspect 1 (HIGH — engine gap): the video-start PLI watchdog never arms because the offer has no `a=ssrc`
- Engine arms the nudge watchdog only when `whip_peer::first_video_ssrc(offer_sdp)` returns `Some(...)` (`engine.rs`, around L283–285 and the watchdog task L375+ that logs `"no video RTP yet — sending PLI to publisher"`).
- Native/browser WHIP offers (Flutter APK on libwebrtc, Chrome) often **do NOT include `a=ssrc` lines in a sendonly offer**. If so, `offer_video_ssrc = None` and **no PLI is ever sent**, even though a video m-line was negotiated. An encoder that needs a keyframe kick then never starts.
- **Verify:** grep the full session logs for `"no video RTP yet — sending PLI to publisher"`. If it never appears while the session sat audio-only for >60s, the watchdog was not armed → confirm whether the offer contained `a=ssrc` (the current logging only prints media sections + rtpmap; add a temporary log of `first_video_ssrc` result / any `a=ssrc:`/`a=ssrc-group:` lines in the offer).
- **Candidate fix:** arm the watchdog from the negotiated **video m-line** (or from the publisher's first video SSRC once any RTP/RTCP is seen), not only from a declared offer SSRC; keep PLIing every few seconds while the session is audio-only with a video m-line.

### Suspect 2 (MEDIUM — codec): VP8-first negotiation stalls Android hardware encoders
- The offer (created by the phone) lists VP8 first, and the engine answer keeps that order, so negotiation lands on **VP8**. Many Android phones only have a **hardware H.264** encoder; VP8 then runs in software and can fail to start or produce frames at 1080p/30.
- Note the SAME symptom occurred earlier (12:19 UTC run) when the engine build era was H.264-oriented — so codec is probably **not** the sole cause, but it must be ruled out.
- **Verify:** run the isolation matrix (Section 6). If a different publisher/device works, test forcing **H264 preference** on the Android client (restrict the offer's video codecs to H264 with `packetization-mode=1;profile-level-id=42e01f`) and/or making the engine's WHIP answer prefer H264 over VP8. Inspect how `flutter_webrtc` on Android supports codec preference before implementing.

### Suspect 3 (MEDIUM — client): the APK's encoder never starts (frames never flow)
Possible causes to rule out:
- Another broadcaster instance (the OLD APK) still installed/running and holding the camera.
- The app was backgrounded or the screen locked right after Start (encoder stops; audio continues). The resume-restart fix only helps on the NEXT resume.
- The preview `RTCVideoView` is not actually rendering (many stacks gate the encoder on first frame rendered).
- 1080p@30 exceeds the device encoder capability.
- **Add a client-side watchdog:** after WHIP connects, sample `RTCPeerConnection.getStats()` `outbound-rtp[kind=video]` — if `framesPerSecond` stays 0 (or no video bytes) for N seconds, log loudly, surface a "video not sending" state in the broadcaster UI, and auto-restart capture once or twice before giving up. The existing device telemetry already samples `fps` — reuse it.

## 6. Diagnose protocol (run before/while coding)

### On the server — full timeline of the 20:39 session
```bash
journalctl -u todd-studio --since "2026-09-06 20:39:00" --no-pager \
  | grep -E "whip|track up|track ended|no video RTP|rtp marshal|PLI|keyframe"
```
Questions to answer: Did a video `track up` EVER happen? Did a video `track ended` follow it? Did `"no video RTP yet"` appear at 4/8/12/20/30/40/50/60s after start?

### Metrics growth over 60s (is audio still flowing?)
```bash
curl -s http://127.0.0.1:8082/metrics | grep -E "todd_rtp_packets_in_total|todd_rtp_bytes_in_total"
# wait 60s, repeat
```

### Publisher side
- Check the broadcaster UI/health overlay (or its telemetry payload, `kind: device_telemetry` with `fps`, `uplink_kbps`) — is `fps` 0 or >0? If the APK samples `getStats()` outbound video and reports `fps=0` while live, the encoder is not producing.
- Confirm the installed APK build contains the new code (version/build string in the app).

### Isolation matrix (critical — run these)
1. **Same new APK on a second Android phone** → new room/camera. Video OK? (phone-specific?)
2. **Todd Broadcaster WEB build in desktop Chrome** (no phone involved) → new room/camera. Video OK? (APK-specific?)
3. If (2) works but (1) fails → phone/APK encoder issue → Suspect 2/3. If (2) ALSO fails → engine/watchdog/codec path → Suspect 1/2.
4. Optional: an independent WHIP client (OBS/larix/etc.) against the engine to prove engine video ingest works at all with a known-good sender.

## 7. Definition of done (unchanged)

1. Engine log shows `track up` with a **video** codec (`H264` or `VP8`) for the camera.
2. Ingress bytes/packet ratio rises above ~400 B/pkt while video runs.
3. WHEP POST flips 409 → 201; engine logs `whep viewer started`; `todd_viewers_active ≥ 1`; `todd_rtp_packets_forwarded_total` grows.
4. **Video renders in the Todd Studio tile** (browser and Tauri builds).

## 8. Also re-verify Problem B (cricket scoreboard) on the new deploy

`.env` on the server should now contain `CRICKET_MANAGER_URL=https://cricket-manager.traceodd.com` (the previous fix added it; only `.env.example` was committed). Confirm:
```bash
curl -s http://127.0.0.1:8082/api/v1/cricket/config
```
Check `push_connected`/`base_url`/`active_match_id`. Then update a score in cricket-manager.traceodd.com and confirm the Studio lower-third updates within ~1–2s (`ScoreUpdated` event on the control-plane WS). If config is empty, the deploy's `.env` was not updated — that is the root cause for Problem B, fix the deployment, not the code.

## 9. Constraints

- Do NOT regress or weaken F1–F19 (scoped PLI drain, SDP SSRC parsing, marshal tolerance, 300s ICE grace, session `DELETE`, F8 liveness gate, 409-not-live rejection, subscriber pruning, etc.).
- Keep the engine's "no video → 409" gate intact. Never fake liveness or start WHEP without video.
- Minimal, surgical, style-consistent changes. Validate: `cargo check --workspace` + `cargo test -p todd-sfu` (expect 14/14) from `media-engine/`; `flutter analyze` for Dart; TypeScript build for the GUI.
- Commit with a clear imperative subject on branch `mainnew`, push, redeploy, and re-run Section 7.

## 10. Final instruction

Report back concisely: per-suspect findings with the log evidence, the root cause you confirmed, files changed, validation results, and the Section 7 evidence. **Delete this temporary file before your final commit.**
