# Cricket Streaming — History, Root Causes and Fix

**Status: WORKING.** The engine → SRS → HLS → public-page chain publishes again
(verified 2026-09-22: SRS reported an active publish for
`cricket_match_a2c0880f-…_cam1` with fresh HLS segments). Three fixes were needed
on the one broken hop, plus two recovery fixes — see §2, §4 and §6.

This file consolidates four handoff documents that have been deleted —
`STREAM-ISSUE-REPORT-FOR-QODER.md`, `FAULT-REMEDIATION-HISTORY.md`,
`CRICKET-DEEP-SCAN-FOR-QODER.md` and `STREAMING-FAULTS-AND-SOLUTIONS-LATEST.md`.
They remain readable in git history (`git log --oneline -- docs/handoff/`).

---

## 1. The pipeline

```
Todd Broadcaster (Android, WHIP)
      |  RTMP/WHIP
Todd Studio engine (todd-signaling + todd-sfu)   <- camera + SFU; Studio itself plays via WHEP
      |  on-air camera (PGM)
GStreamer forwarder (todd-transcode)             <- the hop that was broken
      |  RTMP
SRS (1935)  ->  HLS segments
/var/www/traceodd/cricket-hls/live/*.m3u8
      |  nginx  location /hls/ { alias /var/www/traceodd/cricket-hls/; }
https://cricket.traceodd.com/hls/live/{key}.m3u8
      |
Public Flutter web page (HLS player)
```

- HLS stream key is **derived from the match id**: `cricket_match_{matchId}_cam1`.
- The public page consumes **HLS**; Todd Studio consumes **WHEP** straight from the
  SFU. That is why Studio always looked fine while the public page was dark.
- Infra: server `root@135.181.46.27`, Docker host networking. Containers
  `todd-studio` (:8082), `todd-broadcaster` (:8081), `todd-redis`. SRS: RTMP 1935,
  API 1985, HLS HTTP 8088, HLS dir `/var/www/traceodd/cricket-hls`. Images built on
  Ubuntu 24.04 + **GStreamer 1.24** (`media-engine/deploy/docker/Dockerfile`).

---

## 2. Timeline (commits)

| Commit | What |
|---|---|
| `6fab701e` | DOCS: first handoff report for the expert agent |
| `4b4f1127` | 11 reported faults "fixed" (8 files) — **CI red: 5 compile errors** (written without GStreamer, never compiled) |
| `b9b5db9d` | Fixes for those 5 errors |
| `f6fc23b5` | FIX(engine): silent audio bus no longer blocks video egress (`AUDIO_PRIME_TIMEOUT` = 1500 ms priming). One-sided: no matching `build_description` change |
| `f0fc72e5` | FIX: declare/feed **count** mismatch on audio branches. Deployed — error text changed, outage continued |
| `e951903b` | FIX: **codec** filter (`VIDEO_CODECS`/`AUDIO_CODECS`). Deployed and firing — console errors gone, bridge still failed |
| `04fa702c` | DIAG: print the built pipeline in the forwarder failure text (this is what finally made the bug readable) |
| `e1e181b2` | `tests.yml` triggers moved to `main`/`mainnew` (were `master`/`*.x`, which do not exist → tests never ran on deploy branches) |
| `535ba3c1` `17e4393d` | `composer.lock` synced; `deploy.yml` now runs `composer install` |
| `11dbaf8f` | `consumer.php` routes registered (0 → 4 routes) |
| `bdb3001d` | Deleted plaintext Postgres credentials in `lib/core/config/database_config.dart` |
| **`ead72810`** | **THE FIX**: declare `rtpopusdepay`'s required RTP payload type on audio branches (§3) |
| `5bebdf76` | Public player: stage sized from the viewport; HLS starts at the live edge (§6) |
| **`01f5905e`** | **Recovery fix**: verify forwarder health at the *far end* (SRS) so a stale `running` state cannot block every recovery path (§6) |

---

## 3. Root causes (three, all on the forwarder hop)

1. **Declared vs fed branch count** (`f0fc72e5`). `build_description` emitted a
   branch for every *enabled* bus while a push task was attached only to *primed*
   buses. Unfed `audiomixer` pads never preroll, `flvmux` waits forever and the
   **video never leaves either**. Fixed by deriving both from the same `live_buses`.
2. **Wrong codec pushed to an audio branch** (`e951903b`). Priming accepted the
   first chunk regardless of codec, so an H.264 chunk reached an `appsrc` whose caps
   say OPUS; `rtpopusdepay` answered `not-negotiated (-4)`. Fixed with an enforced
   codec filter (`WARN dropping chunk whose codec this branch cannot carry`).
3. **The actual blocker** (`ead72810`). The audio `appsrc` caps were
   `application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000` — **missing
   `payload`**. `rtpopusdepay`'s sink template *fixes* `payload` to `[96, 127]` and a
   caps event must carry **fixed** caps, so `set_caps` failed: the depayloader never
   negotiated and the first pushed buffer came back as `GST_FLOW_NOT_NEGOTIATED`,
   which the appsrc (a `GstBaseSrc`) reports as
   `streaming stopped, reason not-negotiated (-4)` on `GstAppSrc:audio_commentary`.
   `rtph264depay`'s template lists no `payload`, which is exactly why **only the
   audio branch died** and the error always named `audio_commentary`.

### False leads (do not re-chase)

- **The "mixer declaration ordering" hypothesis was WRONG.** Declaring
  `audiomixer name=mix` in an earlier statement than the branch that links into it
  is harmless: the full pipeline with real Opus RTP reaches EOS, and the mixer
  happily renegotiates/resamples (observed negotiating 44100 Hz output with a
  48000 Hz sink pad). Never spend time on this.
- **The old gst-launch "ordering bisect" (4A vs 4B) cannot decide anything.** With
  no buffer pushed, a non-live `appsrc` never negotiates, so the pipeline just sits
  at PLAYING and *looks healthy*. That false positive is what produced the ordering
  theory. A branch must be **fed a real buffer** to be tested.
- Wrong caps string and missing elements were both ruled out.
- `state:"running"` was a lie: nothing watched the bus, so a dead forwarder reported
  itself healthy. Fixed by `watch_bus()` (`04fa702c` area).

---

## 4. The fix, in code

| File | Change |
|---|---|
| `media-engine/crates/todd-transcode/src/media.rs` | `RtpChunk::rtp_payload_type()` (low 7 bits of RTP byte 1) and `FALLBACK_OPUS_PAYLOAD_TYPE = 96` |
| `.../todd-transcode/src/forwarder.rs` | `build_description(live_buses: &[(AudioBus, u8)])` now emits `...,payload={pt}` in each audio branch. The camera path takes the **real** payload type from the primed chunk; the program path uses `mixer_gst::PROGRAM_OPUS_PAYLOAD_TYPE` |
| `.../todd-transcode/src/mixer_gst.rs` | Bus `appsrc` caps get `payload={FALLBACK_OPUS_PAYLOAD_TYPE}`; `rtpopuspay pt=` now uses the shared `PROGRAM_OPUS_PAYLOAD_TYPE` const |
| `lib/features/cricket/presentation/pages/public/live_match_page.dart` | Player stage height from the viewport (was a fixed 220 px) — see §6 |
| `lib/shared/widgets/hls_video_player_web.dart` | hls.js live config — see §6 |

Regression tests added (gst-gated): a string-level caps assertion, and a push-level
test that builds the real description, pushes one Opus RTP packet and asserts no bus
error. The push-level test **skips** (with a reason) when the elements it needs are
not installed — CI's `check-gst` job installs only GStreamer's *base* plugins, and a
false failure there would block the image build.

Verification of the schema fact (the whole bug in one line):
```
$ gst-inspect-1.0 rtpopusdepay | grep -A6 "SINK template"
      application/x-rtp
                  media: audio
                payload: [ 96, 127 ]      <-- required, and it must be FIXED
             clock-rate: 48000
```

---

## 5. Proof it works

**Reproduced locally first** (GStreamer 1.24.13, macOS-free Windows box): pushing one
Opus RTP packet into the as-shipped branch produced the container's exact error —
`src=.../GstAppSrc:audio_commentary ... streaming stopped, reason not-negotiated (-4)`
with `rtpopusdepay sink caps => None`. Adding `payload=111` made the caps negotiate
(`Some(... payload: 111)`) and the error disappeared. The full pipeline with real
H264 + Opus RTP reaches EOS.

**Then in production** (2026-09-22, operator output):

| Check | Before | After |
|---|---|---|
| `docker logs todd-studio \| grep -c not-negotiated` | every ~5 s | **0** |
| SRS `api/v1/streams/` | `"streams":[]` | publish **active**: `cricket_match_a2c0880f-..._cam1`, 20461 frames, H264 480x800, **audio AAC 44100 stereo** |
| `/var/www/traceodd/cricket-hls/live/` | empty | `.m3u8` + `.ts` segments |
| Public screen | dark | plays |

The AAC/44100 audio in SRS also proves the audio branch now negotiates properly.

---

## 6. Open items

### The failure mode that still bites: the publish stalls, the engine keeps saying `running`

**OPEN — engine side.** After the payload fix the feed publishes (SRS
`publish.active: true`, fresh `.ts`/`.m3u8`), but a session can still end with the
pipeline alive and idle: the publisher goes away, no buffers reach `flvmux`, SRS
drops the feed and deletes the HLS files, and the engine still reports
`state: running`.

That stale state used to be **self-locking**: every recovery path skips a
forwarder that claims to be running, so the operator saw a 404, a panel that said
healthy, and *nothing* in the engine logs. The two recovery fixes below make the
state survivable; the real engine-side fix — make the state honest, so a
forwarder whose publisher is gone is stopped or marked stale instead of idling
forever — is still to be written. Leading suspect: the shared-subscription pump in
`forwarder.rs` returns when its router receiver closes but leaves the consumer
channels open, so the pipeline's push tasks block forever and the appsrcs never
reach EOS.

### Recovery fixes (done, 2026-09-22)

- **Health is verified at the far end** (`01f5905e`). `healthForMatch()` now asks
  SRS (`GET /api/v1/streams/` → `publish.active`) instead of trusting the engine's
  `state`, and reports `stale` when the engine claims `running` while SRS has no
  active publish. `resyncMatch()` therefore proceeds to stop the zombie and build
  a fresh forwarder, and the manager panel shows the truth instead of `BROKEN`
  with no reason. Config: `cricket.streaming.srs_api_url`
  (`CRICKET_SRS_API_URL`, default `http://127.0.0.1:1985`).
- **The Laravel scheduler is installed by the deploy.** `cricket:stream-watchdog`
  is scheduled `everyMinute()` in `backend/routes/console.php`, but nothing ever
  installed `schedule:run`: the server's `/etc/cron.d` had no entry and the root
  crontab held only unrelated rsync jobs, so the watchdog **never ran
automatically** — a dead feed could only be recovered by a manual run or the
  panel button. `deploy.yml` now writes `/etc/cron.d/nexatrace-scheduler`
  idempotently, so fresh servers get it too.

### Everything else

1. **HLS latency and startup stutter** (top priority). Player-side is fixed: the web
   player used `new Hls()` with **no config**, i.e. hls.js's default of starting
   *three segments behind* the live edge; it now uses `liveSyncDurationCount: 1`,
   `liveMaxLatencyDurationCount: 3`, `maxLiveSyncPlaybackRate: 1.5` and plays on
   `MANIFEST_PARSED`. **But** the operator's HLS directory showed segments closing
   ~1 minute apart, not every 3 s (a 31 MB `.ts.tmp` still open after 5 minutes).
   SRS runs **pure remux** (`hls_fragment 3` is only a target), and remux can only
   cut a segment **on a keyframe** — so the publisher's GOP governs segment length,
   and long segments explain both the lag and the "1–2 minutes of stuttering before
   it plays". Diagnose with:
   ```sh
   cat /var/www/traceodd/cricket-hls/live/cricket_match_<ID>_cam1.m3u8   # look at #EXTINF
   docker logs -f --since 2m todd-studio 2>&1 | grep -a "keyframes received"
   ```
   If `#EXTINF` is ~3 → player fix was the answer. If ~30–60 → shorten the
   **Broadcaster's keyframe interval to 1–2 s** (server-side; no re-encode needed).
   Expectation: classic HLS cannot match Studio's WHEP (<1 s). Best case with short
   segments is ~6–10 s; near-instant needs **LL-HLS** (~2–4 s) or **WHEP**. The owner
   has decided: **stay on HLS now, migrate to WHEP later, carefully** (the public
   player's earlier WHEP code still exists, so this is a re-wire, not a rewrite).
2. **SFU router cross-delivers media types on its rid-scoped fan-out.** Log proof:
   `appsrc=video_src codec=Opus expected=[H264, Vp8, Vp9]`. The forwarder's codec
   filter contains the damage, but the real fix belongs in
   `todd-sfu/src/router.rs` (scope fan-out by media type). Judge separately from this
   outage.
3. **Cricket Manager `Null check operator used on a null value`** — fires only when
   navigating **back to the dashboard**, reproduced at the same point in two
   browsers. `lib/features/cricket/presentation/pages/manager/live_video_page.dart`
   mixes null styles: ~L171 `_health?['rtmp_url']` vs ~L174 `_health!['rtmp_url']`.
   The mixed style is a smell, not a proven cause — find the throw site.
4. **Dead realtime path `stream.updated`** — Flutter still subscribes
   (`cricket_repository.dart` L542–L553, `stream_player_bloc.dart` L110) but the
   Laravel event `CricketStreamUpdated` was deleted in the camera-registry removal,
   so "manager switches camera → viewers follow" is **inert** (initial playback is
   unaffected).
5. **Non-streaming items that were recorded in the deleted docs** (do not lose
   these): `super_admin.php` has 19 routes behind `auth:sanctum` only, with no admin
   middleware (security; a shadow admin gate was specified in
   `PANEL-SEPARATION-PLAN.md`); 37 composer advisories across 11 packages, untriaged;
   stale references to the deleted camera registry in `.nginx/srs-cricket.conf`
   L135–141, `.scripts/CDN-CONFIG.md`, `assets/cricket/*.md`; Todd Studio repeats a
   409 for a ghost camera with no publisher; `forwarder_error` is fetched but not
   always rendered in the manager panel; `stream_player_bloc.dart` shows a generic
   "offline" for any 404; the stinger `uridecodebin` caps fix was never functionally
   verified; `ForwardKind::WebRtcViewer` is deliberately not implemented.

---

## 7. Commands worth keeping

**Deploy chain (push to `mainnew`):** a `media-engine/**` change runs
`Media Engine — Build & Push Docker Image` (`check-gst` → `build-and-push`, where
`build-and-push` has `needs: check-gst`), and its success triggers
`Media Engine — Deploy to VPS` (`workflow_run`). A `lib/**` change runs
`Deploy Flutter Web Frontend` **and** `Deploy to Hetzner` (both list `lib/**`).

**CI parity (must be run before pushing engine changes):**
```sh
cargo check -p todd-signaling -p todd-sfu --features gst
cargo test  -p todd-transcode --features gst
```
A green `cargo check --workspace` proves **nothing** about `forwarder.rs`,
`mixer_gst.rs`, `audio.rs` — they are behind `#[cfg(feature = "gst")]`.

**Deploy verify / baselines:**
```sh
docker ps --format "{{.Names}} | {{.Status}} | {{.Image}}"
docker logs --since 10m todd-studio 2>&1 | grep -ac "not-negotiated"   # expect 0
curl -s http://127.0.0.1:1985/api/v1/streams/; echo
ls -la /var/www/traceodd/cricket-hls/live/
```

**Live diagnostics (during a broadcast):**
```sh
docker logs -f --since 2m todd-studio 2>&1 | grep -a --line-buffered -E "forwarder started|forwarder running|not-negotiated|dropping chunk|pipeline error|keyframe"
docker logs --since 5m todd-studio 2>&1 | grep -a -A 12 "pipeline error" | tail -60   # includes the built pipeline
```

**Acceptance:**
```sh
curl -s -o /dev/null -w "%{http_code}\n" "https://cricket.traceodd.com/hls/live/cricket_match_<MATCH_ID>_cam1.m3u8"   # expect 200
curl -s http://127.0.0.1:1985/api/v1/streams/ | grep -a "cricket_match_"                                              # stream listed
```
(Use the real key from SRS — a literal `<MATCH_ID>` placeholder naturally 404s.)

**Recovery — the public page 404s while SRS is empty:**

```sh
# What the engine/backend believe, vs. what the far end shows
docker logs --since 5m todd-studio 2>&1 | grep -aE "forwarder started|forwarder running|forwarder failed|pipeline error"
curl -s http://127.0.0.1:1985/api/v1/streams/ | head -c 300; echo
ls -la /var/www/traceodd/cricket-hls/live/
# the watchdog's real reason (its skips are log-only, not stdout)
tail -20 /var/www/traceodd/admin-panel/storage/logs/laravel.log

# Clear a stale in-memory forwarder state, then let the backend re-arm it
docker restart todd-studio
cd /var/www/traceodd/admin-panel && php artisan cricket:stream-watchdog

# Is the scheduler installed? Without it the watchdog never runs on its own
ls -la /etc/cron.d/; grep -rn "schedule:run" /etc/cron.d/ /etc/crontab 2>/dev/null
```

The engine's forwarder state is **in memory only**, so a container restart clears
it; afterwards `cricket:stream-watchdog` (or the panel's "Reconnect live video",
which now works) can create a fresh forwarder. A publisher must be **on air** for
that to do anything — `resyncMatch()` returns silently when the engine reports no
live broadcaster camera, which makes "nothing happened" look like a bug when it
is really "nobody is broadcasting".

**Windows: building the `gst` feature** (needed by the two commands above; the
devel MSI alone is not enough):

1. Download `gstreamer-1.0-devel-msvc-x86_64-1.24.13.msi` (~712 MB) from
   `gstreamer.freedesktop.org/data/pkg/windows/1.24.13/msvc/`. Use `curl -sL`
   **without** `-C -`, else the MSI is truncated (error 1620).
2. Extract without admin rights:
   `msiexec /a gs-devel.msi /qn TARGETDIR=C:\gs-dev\extract`
3. Build with:
   ```sh
   env PKG_CONFIG_PATH="C:/gs-dev/extract/gstreamer/1.0/msvc_x86_64/lib/pkgconfig;C:/gs-dev/extract/gstreamer/1.0/msvc_x86_64/lib/gstreamer-1.0/pkgconfig" \
       PATH="/c/Users/<you>/.cargo/bin:/c/gs-dev/extract/gstreamer/1.0/msvc_x86_64/bin:/c/msys64/mingw64/bin:/usr/bin" \
       cargo check -p todd-signaling -p todd-sfu --features gst
   ```
4. **The devel MSI ships zero DLLs** (`bin/` holds only `.pdb` symbols). To *run*
   anything (tests, `gst-launch`), also install/extract the separate **runtime**
   MSI and put its `bin` on `PATH`.

---

## 8. Lessons (why this took so long)

- Compile before pushing. `4b4f1127` was written with no GStreamer installed and
  broke CI with 5 errors a compiler finds instantly.
- A green `cargo check --workspace` says nothing about `#[cfg(feature = "gst")]`
  code, and gst-gated tests had **never executed anywhere** until
  `media-engine-build.yml` added `cargo test -p todd-transcode --features gst`.
- A deployed fix is not a finished fix: `f0fc72e5` was correct, tested and deployed,
  and the outage continued because a second fault sat on the same path.
- **Do not trust a string-level test for a negotiation bug.** The old description was
  well-formed; GStreamer only rejected it at negotiation time, and the "isolated test
  negotiated fine" result was a false positive caused by never pushing a buffer.
- Watch the bus, and report status from the **far end** (bytes reaching SRS), not
  from "the pipeline object was constructed".
- Ask for the fact instead of inferring: three inferences in this cycle were wrong
  (the CI-blocked theory, the ordering theory, and the "before any push" reading of
  a 0.4 ms timestamp — the primed chunk *is* pushed immediately).
