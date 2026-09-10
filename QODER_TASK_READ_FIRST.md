# READ FIRST — QODER AGENT TASK PACK (Todd Studio "no video" investigation)

**Environment constraint that shapes this whole document:** the Qoder IDE stalls/freezes on
heavy commands (compilers, bundlers, large log searches). Therefore:

- **Qoder runs only LIGHT, read-only commands** (see §5).
- **Every heavy command is emitted as a copy-paste block for the human operator**, who runs it
  in Windows CMD / server SSH and pastes the output back to Qoder.
- Qoder produces a **written diagnosis + plan**, not code changes.

---

## 1. Mission

Explain why video never appears in Todd Studio (browser and desktop), and specify the fix plan
and a reliable fallback path — in English, grounded in the evidence already collected.

Two deliverables:

- **Part A — Root cause of the WHIP → engine → WHEP failure.** Use the collected evidence
  (section §3) plus the two brief files. State the primary cause, the runner-up, and the exact
  evidence that discriminates them. Do not stop at "network problem".
- **Part B — The OBS/RTMP route.** The operator has a PROVEN-WORKING RTMP pipeline
  (Larix + OBS + cricket-manager + `https://cricket.traceodd.com/` public viewer) on the same
  phone, laptop and network. Specify the concrete bridge to get that picture into Todd Studio
  (Stage 1: HLS tile; Stage 2: RTMP → SRS → engine GStreamer ingest → existing WHEP tiles).
  Include latency, security (stream keys), and rollback.

**Do not write code. Do not commit. Do not run heavy commands.**

---

## 2. Files to read (in this order)

Repository (root: `C:\Ecosystem\NexaTrace_System`):

1. `QODER_AGENT_INSTRUCTIONS_BLACK_VIDEO.md` — the main instruction file. Read **all** of it,
   especially:
   - §1.1 the operator-confirmed topology (what works vs what fails),
   - §4 current deployment state,
   - §5 failure signatures,
   - §6 diagnostic tree,
   - §8 Part B (the OBS/RTMP bridge specification),
   - §10 evidence runbook,
   - **§11 pre-digested findings from the 2026-09-10 field run — start your Part A answer from
     §11.1 (facts) and §11.2 (derived diagnosis).**
2. `QODER_FOLLOWUP_BRIEF_2.md` — accumulated briefs:
   - BRIEF #3 (native Kotlin APK: encoder stall, VP8 vs H264, sender-BWE starvation),
   - BRIEF #4 (webrtc-rs lifecycle: `ErrClosedPipe` displayed as "DataChannel is not opened",
     `on_track` fires only after the first RTP per SSRC, PLI nudge schedule, watchdog race),
   - BRIEF #5 (2026-09-09 field run: audio-only session, watchdog null-stats blind spot,
     viewer-side relay defaults).

Evidence collected by the operator — **inside this repository at `NexaTrace_System\qoder-evidence\`**
(gitignored, so workspace-restricted agents can read it directly):

| File | What it contains |
|---|---|
| `apk-version.txt` | `dumpsys package com.todd.broadcaster` — proves which APK build ran |
| `phone-logcat.txt` | App + native WebRTC logs from the failing test (ICE state transitions, watchdog) |
| `todd-engine.log` | `journalctl -u todd-studio` for the test window (WHIP/WHEP ingest, PLI, sessions) |
| `todd-turn.log` | `journalctl -u todd-turn` (coturn allocations, permissions, teardowns) |
| `todd-metrics.txt` | `/metrics` snapshot (keyframe counters, ingress/egress, viewer counts) |
| `todd-services.txt` | `systemctl is-active` for the three services |
| `todd-df.txt` | `df -h /` |
| `todd-docker.txt` | `docker ps` image names + start times |
| `studio-deploy.txt` | Deployed `/var/www/todd-studio` listing + TURN-default grep result |
| `webrtc_internals_dump.json` | **UNUSABLE** (375 bytes of binary noise — capture failed; see §6 for the corrected recipe) |

Optional architecture context:

- `media-engine/docs/06-ice-and-telemetry.md`, `media-engine/docs/07-sfu-architecture.md`
- `apps/broadcaster-android/README.md`
- `media-engine/ui/todd-studio-gui/README.md`

Source files worth reading (light, just reading):

- Engine: `media-engine/crates/todd-sfu/src/{engine,whip_peer,whep_peer,router,pli,h264}.rs`
- App: `apps/broadcaster-android/app/src/main/java/com/todd/broadcaster/MainActivity.kt`,
  `.../media/BroadcasterEngine.kt`, `.../media/EncoderConfig.kt`
- Viewer: `media-engine/ui/todd-studio-gui/src/lib/webrtc/whep.ts`,
  `src/lib/utils.ts`, `src/components/MultiviewGrid.tsx`, `src/hooks/useWhepPlayer.ts`
- Part B assets: `.nginx/srs-cricket.conf`, `.nginx/cricket-srs.service`,
  `assets/cricket/HARDWARE_SETUP.md`, `backend/config/cricket.php`

---

## 3. Current facts (do not re-derive; verify if you wish)

Deployment (2026-09-10, all verified from the evidence):

- Services `todd-studio`, `todd-broadcaster`, `todd-turn`: **active**. Disk `/` back to **10 %**.
- Engine image `traceodd/media-engine:latest` (re-tagged from GHCR by the deploy workflow),
  running the extended-PLI build (`delay_secs` up to 160 in the logs).
- Browser Studio bundle at `/var/www/todd-studio` (Sep 9 22:49) **contains the TURN relay
  defaults** — "stale Studio" is refuted for the browser build.
- Android APK freshly installed 2026-09-10 15:31 (the fixed watchdog is present: it logs
  `Video stall detected: No video started after 120s` every ~131 s).

The failing run (operator local 15:32–16:21, UTC 13:32–14:21; **server logs are UTC, operator
local = UTC+2**):

- Phone: `PeerConnection state: CONNECTED` → **`ICE connection state: FAILED` ~6 seconds
  later**, in *every* session. Encoder encoded **zero frames**; no `Video sender stats
  unavailable` lines (so stats exist but are 0/0).
- Engine: sessions accepted, `[whip] peer connection connected`, `track up ... codec=Opus`;
  then `no video RTP yet — sending PLI to publisher` for minutes. **Zero** engine-side
  `disconnected`/`failed` events. **Zero H264 track registrations** except one that arrived
  25 minutes late (`13:57:29 ... codec=H264`) right before that session died.
- `todd_whep_watches_total 0` — **no viewer ever subscribed**; the Studio tile gates its watch
  on "camera video bytes > ~1 kbps", so an audio-only camera never even attempts a watch.
- coturn: allocations succeed but the log shows heavy churn — `allocation timeout`,
  `allocation watchdog determined stale session state`, `TCP socket closed remotely`, one
  `bind: Address already in use`.

Reference point that still works: **Larix + OBS + cricket-manager + cricket.traceodd.com
(RTMP → SRS → HLS)** on the same phone/network, video included.

---

## 4. What to produce

1. **Part A answer** — primary root cause with the discriminating evidence, runner-up cause,
   and the list of tests (§11.3 of the main instruction file) that would confirm each.
   Explicitly address: why the phone's ICE fails in ~6 s; why the engine does not notice;
   whether forced `iceTransportsType = RELAY` + this coturn instance is the trigger; and the
   independent viewer-gating defect.
2. **Part B decision memo** — recommend Stage 1 (HLS tile) and/or Stage 2 (RTMP → SRS →
   engine GStreamer ingest → WHEP), with latency expectations, exactly which files/functions
   change, stream-key security, and rollback.
3. **A command request list (§5)** — every heavy command you need run, as a fenced
   copy-paste block, with a one-line description of what its output will prove.
4. **Open questions** that cannot be answered without a new live capture.

---

## 5. Command policy (IMPORTANT for this environment)

### 5.1 Light — Qoder runs these directly (read-only)

- Reading/opening files; `rg`/`grep` over the repository; `git --no-pager log/show/diff`.
- Reading any file under `NexaTrace_System\qoder-evidence\` (plain text, inside the project).
- `ls`, `stat`, size checks; `find` over the repo.

### 5.2 Heavy — NEVER run these (they hang the IDE)

- `cargo build`, `cargo check`, `cargo test`, `cargo fmt --check`, any Rust compilation.
- `gradlew` / `gradle` (any task), Android builds.
- `npm install`, `npm run build`, `vite`, `tsc` over the GUI.
- `docker build/pull/prune/compose`, `systemctl`, `journalctl -f`, `tcpdump`, `ffprobe` on
  large inputs, `scp`/`ssh` bulk transfers, anything that starts a server or a watcher.
- Anything with `-f`/`--follow` or an unbounded loop.

### 5.3 When you need a heavy command

Emit it like this and stop; the operator will run it and paste the result:

````markdown
### Command request N — <what it proves>
Run on: <Windows CMD | VPS SSH>
```bat
<exact copy-paste command(s), one per line, no shell substitutions>
```
Expected: <what a healthy vs failing output looks like, with the exact strings to grep for>
````

Rules for the commands you request:

- Windows CMD or a plain bash prompt on the VPS only; **no PowerShell**, no shell
  substitutions like `$VAR`, `$(...)`, backticks, or process substitution.
- No destructive operations: never `rm -rf`, `docker prune`, `journalctl --vacuum`,
  `systemctl restart`, `DROP`, `DELETE`, or anything touching data/images/volumes.
- Keep each block small (≤ ~8 lines) and independently copy-pasteable.
- Prefer writing server output to a file under `/tmp` and `scp`-ing it down, exactly like the
  already-collected evidence set.
- State the time zone: server logs are UTC; the operator's clock is UTC+2.

### 5.4 Already-collected evidence cannot be extended by Qoder

The operator re-runs evidence collection manually. If you need a new capture, request it in the
format above — do not attempt to gather it yourself.

---

## 6. Pre-approved command library (operator-run; reuse these when they suffice)

**A. Fresh evidence set (run after a 3–4 minute live test):**

Windows CMD (phone on USB):
```bat
mkdir C:\Ecosystem\NexaTrace_System\qoder-evidence2
adb logcat -c
:: GO LIVE on the phone, open Todd Studio + chrome://webrtc-internals, wait 3-4 minutes
adb shell dumpsys package com.todd.broadcaster > C:\Ecosystem\NexaTrace_System\qoder-evidence2\apk-version.txt
adb logcat -d -v time MainActivity:V BroadcasterEngine:V WhipClient:V libjingle:V WebRTC:V "*:S" > C:\Ecosystem\NexaTrace_System\qoder-evidence2\phone-logcat.txt
```

VPS (SSH, no `ssh` prefix when already logged in):
```bash
journalctl -u todd-studio --since '30 min ago' --no-pager > /tmp/todd-engine.log
journalctl -u todd-turn   --since '30 min ago' --no-pager > /tmp/todd-turn.log
curl -s http://127.0.0.1:8082/metrics > /tmp/todd-metrics.txt
df -h / > /tmp/todd-df.txt
docker ps --format '{{.Image}} {{.Status}} {{.CreatedAt}}' > /tmp/todd-docker.txt
systemctl is-active todd-studio todd-broadcaster todd-turn > /tmp/todd-services.txt
ls -lah /var/www/todd-studio/ > /tmp/studio-deploy.txt
grep -o 'turn:135.181.46.27' /var/www/todd-studio/assets/*.js >> /tmp/studio-deploy.txt
exit
```

Windows CMD (copy down):
```bat
scp root@135.181.46.27:/tmp/todd-engine.log C:\Ecosystem\NexaTrace_System\qoder-evidence2\
scp root@135.181.46.27:/tmp/todd-turn.log C:\Ecosystem\NexaTrace_System\qoder-evidence2\
scp root@135.181.46.27:/tmp/todd-metrics.txt C:\Ecosystem\NexaTrace_System\qoder-evidence2\
scp root@135.181.46.27:/tmp/todd-df.txt C:\Ecosystem\NexaTrace_System\qoder-evidence2\
scp root@135.181.46.27:/tmp/todd-docker.txt C:\Ecosystem\NexaTrace_System\qoder-evidence2\
scp root@135.181.46.27:/tmp/todd-services.txt C:\Ecosystem\NexaTrace_System\qoder-evidence2\
scp root@135.181.46.27:/tmp/studio-deploy.txt C:\Ecosystem\NexaTrace_System\qoder-evidence2\
```

**B. Corrected viewer dump (the earlier file was unusable):**

In the same browser session that runs Todd Studio, open `chrome://webrtc-internals`
(second tab) *before* pressing GO LIVE, then after the test click
**"Download the PeerConnection updates and stats data"** and save the downloaded
`.txt`/`.json` into the evidence folder. Report the file size — anything under ~10 KB means the
capture failed.

**C. One-way vs both-way media check (during a live session):**

VPS SSH:
```bash
timeout 30 tcpdump -ni any -c 4000 'udp port 3478 or udp portrange 49160-49200' -w /tmp/turn-cap.pcap
tcpdump -nr /tmp/turn-cap.pcap -nn 'udp portrange 49160-49200' | awk '{print $3, $5}' | sort | uniq -c | sort -rn | head -20
exit
```
(Interpretation: which peers appear as sources of relayed packets, and whether the phone's
public IP appears in both directions.)

**D. Build/verify tasks (only if you decide a build is needed):**

Windows CMD:
```bat
cd C:\Ecosystem\NexaTrace_System\media-engine && cargo check -p todd-sfu
cd C:\Ecosystem\NexaTrace_System\apps\broadcaster-android && gradlew.bat :app:assembleDebug
cd C:\Ecosystem\NexaTrace_System\media-engine\ui\todd-studio-gui && npm run build
```

---

## 7. Output format

Write your answer as a single markdown report with: **A. Root cause**, **B. Discriminating
tests you need run** (in the §5.3 format), **C. Part B decision memo + bridge steps**,
**D. Open questions**. Keep it in English, specific, and free of generic networking advice.
