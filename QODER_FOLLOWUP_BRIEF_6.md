# QODER FOLLOW-UP BRIEF #6 — Todd Studio video verification + full-system audit

> **Audience:** the Qoder coding agent starting in a fresh chat.
> **Owner:** the operator (reads/acts on your audit report).
> **Date of state snapshot:** 2026-09-11 ~15:10 UTC.

---

## 0. Read these first (mandatory, before any action)

1. `TODD_STUDIO_NO_VIDEO_DIAGNOSIS.md` — read the **whole** file, especially
   **Section E** (root cause, fix, production verification, remaining work, the
   latest Broadcaster-APK behaviour, and an ops cheat-sheet).
2. `media-engine/crates/todd-sfu/src/whip_peer.rs` — the `pc.on_track(...)`
   handler (the site of the fix in commit `375eb6de`).
3. Historical evidence (predates the fix — treat as history, not current state):
   `C:\Ecosystem\qoder-evidence\` (`phone-logcat.txt`, `todd-engine.log`,
   `todd-metrics.txt`, `todd-turn.log`, `webrtc_internals_dump.json`).

Related recent commits on `mainnew`: `754212d5` (coturn range + Studio `/hls/`),
`b74e438d` + `14e9af4b` (Stage-1 HLS bridge), `375eb6de` (**the video fix**),
`8673aee2` (handoff doc).

---

## 1. What is already known and verified

| Path | Status |
|---|---|
| **Stage-1 HLS bridge** (RTMP → SRS → HLS → Studio tile, via hls.js) | ✅ **Operator visually confirmed working in Studio** — a 720p colour-bar test stream rendered inside the Todd Studio multiview tile with the `HLS` badge. |
| **WHIP path** (Todd Broadcaster APK → engine → WHEP → Studio tile) | ⚠️ **Server-side signals say it works; operator visual confirmation is still pending.** After commit `375eb6de` was deployed, a live broadcast produced: `track up … codec=H264` (logged), `todd_whip_h264_keyframes_total 3`, `todd_ingress_bitrate_bps 831507` (~832 kbps), `todd_whep_watches_total 1`, `todd_viewers_active 1`, `todd_whep_h264_keyframes_total 2`, `todd_egress_bitrate_bps 1663015`. |

**Important:** the operator states that Broadcaster video has *not yet* been seen
working inside Studio. Do **not** assume the WHIP path is broken, and do **not**
re-open the TURN/ICE investigation — the packet capture proved the transport is
fine and the real bug (a webrtc-rs `on_track` mutex deadlock) is already fixed.
**Your first job is to confirm or refute** the visual result, with evidence.

### The one-line root cause (for context)

webrtc-rs 0.17 `peer_connection::do_track` runs the `on_track` callback while
holding a mutex across the *entire* callback future. The engine awaited its
long-lived `pump_track()` inline, so the **audio** track's pump held the lock
forever and the **video** track's handler blocked on `handler.lock().await` and
never ran → no video registration, 0 H.264 keyframes, and viewers stuck on a
retryable **409** forever. The fix spawns the pump and returns immediately
(`whip_peer.rs`, commit `375eb6de`).

---

## 2. Your tasks, in order

### Task 1 — Confirm or refute WHIP video end-to-end (highest priority)

With a live broadcast from the APK:

1. Ask the operator to take a **fresh** WHIP URL from the Studio Input Panel
   (new camera, or *Regenerate token* on an existing one). Ingest tokens live
   **6 h**; rooms live **1 h** — an expired token returns **401**
   (`ExpiredSignature`) and a vanished room returns **404**.
2. Ask them to paste the URL into the Broadcaster app and press **Stop → Start**
   (the app does **not** re-POST WHIP by itself after an engine restart; without
   this it stays connected but `todd_whip_ingests_total` stays `0`).
3. While they broadcast (keep it running ≥ 60 s), collect evidence:

```bash
# engine counters — the decisive signals
curl -s http://127.0.0.1:8082/metrics | grep -E \
 '^todd_(sessions_active|whip_ingests_total|whip_h264_keyframes_total|ingress_bitrate_bps|whep_watches_total|viewers_active|whep_h264_keyframes_total|egress_bitrate_bps|whip_no_media_total|rtp_starvation_closures_total|ice_disconnects_total|ice_failures_total)'

# track registration + viewer acceptance
journalctl -u todd-studio --since '15 min ago' --no-pager | grep -E \
 'track up|whep watch accepted|whep viewer started|h264 keyframes received|not live'

# what the browser is doing
tail -n 300 /var/log/nginx/access.log | grep -E 'whep/watch'
```

4. **Classify the result:**

| Observation | Meaning |
|---|---|
| `track up … codec=H264` + `ingress_bitrate_bps` ≈ 500k–2M + `viewers_active 1` | ✅ WHIP video path healthy at the engine — if the tile is still blank, the problem is **viewer-side** (browser/WHEP rendering), go to Task 1b |
| Only `track up … codec=Opus`, `ingress_bitrate_bps` ≈ 30k, `whip_h264_keyframes_total 0` | ❌ video still not registering at the engine — re-open the engine RTP/track path (regression of `375eb6de`?) |
| `whip_ingests_total 0` and no recent `POST /api/v1/whip/ingest` in nginx | ⚠️ the phone never reached the server — token/room/app-start problem, not an engine problem |
| `whep watch rejected: camera not live (409)` repeating | viewer is retrying correctly; the camera is not registered yet (see row 2) |

### Task 1b — If the engine is healthy but the tile is blank

Check, in this order:
1. Browser console (F12) on `studio.traceodd.com` for WHEP/hls errors.
2. `useWhepPlayer` retry/black-frame watchdog behaviour in
   `media-engine/ui/todd-studio-gui/src/hooks/useWhepPlayer.ts` and the tile in
   `components/MultiviewTile.tsx`.
3. Whether the deployed GUI bundle is the current one
   (`/var/www/todd-studio/assets/index-*.js` vs the repo build) — note that
   Cloudflare's Browser-Integrity check returns **403 error 1010** for
   non-browser user agents; always test with a browser-like User-Agent.

### Task 2 — Validate the fix itself (code audit)

- Confirm the `on_track` handler in `whip_peer.rs` cannot block again (the pump
  must be spawned, and the callback must return immediately).
- Check for **any other** long-lived `await` inside a webrtc-rs callback
  (`on_track`, `on_ice_candidate`, `on_peer_connection_state_change`,
  `on_ice_connection_state_change`) — the same mutex pattern applies to all of
  them. `grep -rn "\.on_track(\|\.on_ice_candidate(\|on_peer_connection_state_change(\|on_ice_connection_state_change(" media-engine/crates`.
- Verify no per-track state is still only reachable through the blocked path
  (e.g. the PLI watchdog's SSRC resolution, `router.lowest_video_rid`).

### Task 3 — Fresh issue scan (audit)

Scan the whole video path for **new** issues, and report them even if unrelated
to the current symptom. Suggested areas:

- **Engine/ingest:** track registration, PLI/TWCC feedback, RTP starvation
  watchdog, session takeover/teardown, `has_video_stream`/`lowest_video_rid`.
- **Viewer:** WHEP subscribe/retry, hls.js tile mode selection, black-frame
  watchdog, `409` back-off.
- **Studio UI:** `MultiviewGrid` liveness gate, `MultiviewTile` mode switching,
  `InputPanel` camera create/edit for `hls`/`whip` kinds.
- **Config/deploy drift:** `media-engine-deploy.yml` pins
  `ICE_DISCONNECTED_GRACE_MS=300000`, `ICE_DISCONNECTED_TIMEOUT_MS=30000`,
  `ICE_FAILED_TIMEOUT_MS=60000` into `/opt/todd-media-engine/.env`, so the
  tighter `config.rs` defaults (15000/5000/15000) are **inert in production**.
- **Adaptive bitrate:** the APK strips `transport-cc`/`goog-remb` from its SDP
  and pins a fixed open-loop bitrate; the engine registers webrtc-rs's default
  TWCC receiver interceptor. Assess whether adaptive bitrate can be safely
  re-enabled.
- **TURN/coturn:** relay range is now `49152-65535`; check the verbose log for
  `bind: Address already in use` and stale allocations.
- **Stage 2 (not started):** `--features gst` ingest path
  (`pump_ingest_feed`) for RTMP → engine → WHEP sub-second latency.

For each issue: severity (P0–P3), concrete evidence (quote log lines/metrics with
timestamps), root cause, proposed fix, and estimated effort.

### Task 4 — Produce the audit report

Use **exactly** this structure (English; add a short Roman-Urdu summary at the
end for the operator). The operator will carry this report back to the planning
agent, so be specific and self-contained.

```
## 1. Executive summary            (≤ 10 lines: is WHIP video working? what did you change?)
## 2. Method & environment          (what you ran, when, on which host/commit/image digest)
## 3. Evidence                      (metrics/log excerpts WITH timestamps; before/after)
## 4. Phase verification            (Phase 0–5 table: PASS / FAIL / UNVERIFIED + evidence)
## 5. New issues found              (P0–P3; each: evidence, root cause, proposed fix, effort)
## 6. Recommended next actions      (priority-ordered, smallest-change-first)
## 7. Risks / open questions        (anything needing the operator's decision or a live test)
## 8. Files changed by you          (paths + commit hashes, or "none")
## 9. Roman Urdu khulasa            (8–12 lines for the operator)
```

---

## 3. Environment & access

- **Server:** `ssh root@135.181.46.27` (key-based; reachable from the dev box).
- **Engine env (rewritten by every media-engine deploy):**
  `/opt/todd-media-engine/.env` (diagnosis backup:
  `/opt/todd-media-engine/.env.bak-debug`).
- **Systemd units:** `todd-studio` (engine + control plane, host network, UDP
  media on `127.0.0.1:8082`), `todd-broadcaster` (`:8081`), `todd-redis`
  (`:6380`), `todd-turn` (coturn, `/etc/turnserver.conf`), `cricket-srs`
  (RTMP `:1935`, HLS HTTP `:8088`).
- **HLS output dir** (served at `https://studio.traceodd.com/hls/`):
  `/var/www/traceodd/cricket-hls/` — playlist pattern `live/<key>.m3u8`.
- **Deployed Studio GUI:** `/var/www/todd-studio/` (nginx site
  `todd-studio`, repo file `.nginx/todd-studio.conf`).
- **Deploy pipelines on a push to `mainnew`:** `deploy.yml` (GUI/nginx/Laravel),
  `media-engine-build.yml` (Docker image with `FEATURES=gst`) →
  `media-engine-deploy.yml` (pull + restart; ~25 min end-to-end),
  `frontend-deploy.yml`, `broadcaster-apk-native.yml` (APK →
  `https://traceodd.com/download/broadcaster/todd-broadcaster.apk`).

---

## 4. Guardrails

- **Do not** re-open the TURN/ICE theory without new packet-level evidence — it
  was disproven by a `tcpdump` capture (video RTP arrives at the engine socket).
- **Do not** leave `RUST_LOG` debug logging on in production; enable it only for
  a bounded diagnosis window (set it in `/opt/todd-media-engine/.env`, restart
  `todd-studio`, then let the next official deploy rewrite the file).
- **Do not** change ICE timeouts, the APK's SDP stripping, or the coturn port
  range without a live A/B test and explicit operator approval — each of these
  has previously caused a confusing regression.
- **Always** test the public URLs with a **browser-like User-Agent** (Cloudflare
  returns `403 error 1010` otherwise).
- Prefer read-only diagnosis first; propose changes before applying them, and
  list every file you touch in your report.

---

## 5. Roman Urdu khulasa (operator ke liye)

- **HLS rasta:** ✅ kaam kar raha hai (Studio tile par test pattern chala).
- **Broadcaster (WHIP) rasta:** server ke metrics ke mutabiq **video ka poora
  rasta chal raha hai** (15:06 UTC: `track up codec=H264`, 832 kbps ingress,
  1 viewer live, keyframes forward ho rahe hain) — lekin aap ne **aankhon se
  tile par confirm nahi kiya**. Qoder agent ka **pehla kaam** yehi confirm
  karna hai (evidence ke saath).
- **Asal bug pehle hi fix ho chuka hai** (commit `375eb6de`) — network/TURN ka
  masla **nahi** tha; engine ke andar webrtc-rs ka `on_track` mutex deadlock tha.
- **Baqi kaam:** ICE timeouts ki tuning, adaptive bitrate (TWCC), aur Stage 2
  (RTMP → engine → WHEP, sub-second). Tafseel: `TODD_STUDIO_NO_VIDEO_DIAGNOSIS.md`
  **Section E**.
- Agent se audit report is format par maangni hai: Executive summary → Evidence
  → Phase PASS/FAIL → New issues (P0–P3) → Next actions → Risks → Files changed.
