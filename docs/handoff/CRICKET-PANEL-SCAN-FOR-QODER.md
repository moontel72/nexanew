# CRICKET PANELS — live-video errors + history, and the scan brief for a Qoder expert

**Created:** 2026-10-01 (during the live incident on `cricket-manager.traceodd.com`).
**Status:** the original red error is **fixed and deployed**; two more states surfaced after a
hard restart and are catalogued below.
**Purpose of this file:** give a fresh **Qoder (VS Code) expert** (a) every error text the
Cricket Manager / broadcaster actually produced, (b) the full history of this issue so nothing
is re-learned, and (c) a concrete **scan task across every cricket panel**.

> Owner's brief (2026-10-01): *"AAP LATEST TAMMAM ERROR AND IS ISSUE KI HISTORY Qoder expert ke
> lye ek file mein update karain, mein Qoder se kehta hoon woh cricket ke sare panels scan kare."*

---

## 0. UPDATE — the hybrid WHEP+HLS work, 2026-10-01 (read before planning)

Four fixes for the cricket panels landed on `mainnew` in this session. **A fresh Qoder session must
not re-plan these:**

| Commit | What |
|---|---|
| `e18a58ff` | `healthForMatch()` prefers the running/newest forwarder row (a stale row used to shadow a live one); `live_video_page.dart` errors go through `StickyErrorBanner` |
| `ef4d97ec` | `FAR_END_GRACE_MS` settle window — SRS reports flow over a **30 s** window, so a freshly rebuilt forwarder read `recv_30s = 0` and the every-minute watchdog rebuilt it in a loop, reporting a *working* bridge as `stale` forever |
| `3a75399a` | this file |
| `a5da50fb` | WHEP latency: `jitterBufferTarget`/`playoutDelayHint = 0` on the receivers in **both** clients (`web/vendor/whep.js` + `media-engine/ui/todd-studio-gui/src/lib/webrtc/whep.ts`) — no client had asked for a small playout buffer, so the browser's 1-3 s default was the latency |
| `7146fd7f` | **hybrid WHEP+HLS** (below) |

`7146fd7f` in detail:
- **Phase 1 (the real WHEP blocker):** `media-engine-deploy.yml` now writes `ICE_PUBLIC_IPS`
  (`config.rs` → `net.rs` `nat_1to1_ips` → `engine.rs` `set_nat_1to1_ips`) so the engine advertises a
  routable 1:1 NAT host candidate; without it ICE ends with `no candidate pairs` and WHEP silently
  falls back to HLS. Its `TURN_SERVERS` default changed from the docker-bridge `172.17.0.1:3478` to
  `127.0.0.1:3478` because `todd-studio.service` runs the container **`--network host`** — the bridge
  address is what produced `Failed to allocate on turn.Client 172.17.0.1:3478 attribute not found`.
- **Phase 3:** `live_match_page.dart` polls `getWhepTarget` for the whole session (was one-shot) and
  `WhepVideoPlayer` is keyed by the target URL, so a program-camera switch re-POSTs while an unchanged
  target never tears the live session down.
- **Design (owner):** the stream fills the screen; everything that used to sit below the player is
  behind one overlay button opening a scrollable **half-screen** `Match Centre` panel, video still
  playing in the top half. The camera selector is now a compact strip over the video.
- **Phase 4 (docs):** `.scripts/CDN-CONFIG.md` — WHEP stays **direct** (a CDN cannot proxy WebRTC);
  HLS scales via BunnyCDN. Playlist URLs come from the **`CRICKET_HLS_BASE_URL` env lever**, not
  per-stream DB rows. The stream is a single rendition: `cricket_match_{matchId}_cam{N}.m3u8`
  (**no** `-master.m3u8`).

Also already verified this session: `whep.js` is **git-tracked** (not blocked by `.zedignore`), and
nginx already has `location ^~ /whep/` in `.nginx/cricket-public.conf`. **Still open:** TURN
reachability is a server-side check, the deployed `/whep` proxy needs a live confirm, and the
`CricketStreamUpdated` realtime event is still inert.

---

## 0b. NEW live observations, 2026-10-02 — the public screen is NOT playing WHEP

Owner's report, verbatim in substance. **Two earlier theories in this file are now WRONG — do not
repeat them.**

1. **WRONG: "the laptop needs the TURN relay."** The laptop is on **wired DSL**; the phone is on the
   *same network's* WiFi. So the laptop/mobile difference is not relay-vs-direct.
2. **WRONG: "Cloudflare edge-caches the playlist."** Measured on the origin:
   `curl -sI https://cricket.traceodd.com/hls/live/…_cam1.m3u8` →
   `cache-control: no-cache, no-store, must-revalidate` and **`cf-cache-status: DYNAMIC`**. The edge is
   not caching it.

### What actually happens

| # | Observation (owner) | Reading |
|---|---|---|
| A | Studio runs in Chrome; opening a **second Chrome window on top** → Studio keeps streaming **30–40 s**, then the tile goes **black**. **No** `Live video unavailable: …` text — the video just freezes/stays on "search". Returning to the window resumes it in ~1 s. | Client-side **Chrome occlusion/background throttling**. The players are **`muted`** (autoplay policy) and Chrome exempts *audible* pages from background timer throttling — a muted page is not exempt. Not a server fault. Engine already has `ICE_DISCONNECTED_GRACE_MS=300000` for exactly this. |
| B | Even with **nothing overlapping**, the public screen is **≥2 minutes behind** Studio. | 2 min of buffering is **not** WHEP (no playlist, no catch-up window). This is **HLS**. |
| C | The public video **repeats** and behaves like a **~2-minute recording**: after ~2 min it goes to "**search**" (buffering), and tapping restarts the same ~2 min **from its beginning**. | The signature of **HLS with a stalled segment stream**: the player drains the finite playlist window (≈2 min), hits the end → buffering, then restarts from the window start. |
| D | When it stalls, the gap grows to ~4 min. | The window kept draining while no new segments arrived. |
| E | "Public screen must track Todd Studio at run time; it currently starts from behind." | Correct expectation. Owner has decided: **WHEP only — HLS is no longer wanted.** |
| F | Owner **always waits for the GitHub Actions run to be green** before testing, so reported behaviour reflects the deployed commit. | Trust the commit, not the test timing. |
| G | Laptop overlay button: clicking it produced **no visible change** (tested before `77eaa923`). Re-tested later and reported differently — see G2. | `77eaa923` fixed a throwing `clamp()` / off-screen panel; needs a real-device confirm. |
| **G2** | **Laptop, stream full-screen:** the bottom bar was visible. Clicking the **Score** button made the panel **rise ~2 inches for less than one second**, then the **video (the public screen) overlaid it from the bottom** — the panel disappeared downwards, and even the **bottom taskbar's pinned icons** vanished. On **mobile the same button is 100% perfect** (opens and closes cleanly). | **Leading hypothesis: the Flutter-web platform-view overlay.** Both players are `HtmlElementView`s wrapping a real DOM `<video>` (`whep_video_player_web.dart`, `hls_video_player_web.dart`). A DOM element can paint **above** the Flutter canvas, so a Flutter widget sharing the Stack with it gets swallowed the moment the platform view is (re)laid out — which fits "visible during the ~260 ms animation, then covered". The **taskbar icons disappearing** additionally suggests the element went full-screen/full-viewport (note `video.controls = true`, i.e. native controls with their own full-screen button). **Verify (Qoder):** DevTools → Elements → the `<video>`'s computed width/height/position while the panel is open; the Flutter `flt-platform-view-slot` stacking; and whether `_scorePanelOpen` really shrank the video (`videoBottom` in `live_match_page.dart`). **Mitigations to weigh:** tear the platform view down / move it off-screen while the panel is open, or render the panel as a **top-level overlay** (`Overlay` / a route) rather than a sibling in the same `Stack`. |

### Hypotheses for Qoder to verify (in this order)

1. **Which transport is the public page actually using?** DevTools → Network: `POST /whep/watch/…`
   (201) vs `.m3u8`/`.ts`. Then the API:
   `GET /api/v1/cricket/public/matches/{id}/stream` → is `whep` non-null? If the page is on HLS,
   **why** is `_whep` null/stale — `whepViewerFor()` returns non-null only when `broadcasterCamera()`
   finds a camera with `kind == "whip"` **and** `active == true` in `/api/v1/room/list`.
   (`live_match_page.dart` now polls every 10 s as of `7146fd7f` — confirm the deployed bundle has it.)
2. **Does the engine→SRS bridge stagnate?** B/C/D describe a bridge that stops producing segments
   while `healthForMatch()` still says `running`. Sample over time:
   `curl -s http://127.0.0.1:1985/api/v1/streams/` (`kbps.recv_30s`, `frames`) +
   `ls -la /var/www/traceodd/cricket-hls/live/` twice, 20 s apart. The **underlying stall is still
   unfixed**: `forwarder.rs` `register_inputs()` is idempotent **per track name** and silently
   **drops a newly registered router receiver** (`~L235-268`), and `spawn_input_pump()` removes the
   **whole shared subscription by key** when it exits (`~L315`) — so a dying pump can remove the entry
   a freshly rebuilt pipeline depends on. (`ef4d97ec` only stopped the *health check* from flapping;
   it did not make the pipeline honest.)
3. **Studio black-on-occlusion:** confirm it is purely client-side (see table row A) by keeping the
   public page playing on **another device** while the Studio window is covered. Mitigations:
   ① keep the Studio window uncovered; ② a **silent audio keep-alive** (an audible page is exempt from
   Chrome's background timer throttling) plus a `visibilitychange` recovery; ③ note that the Studio's
   watchdog (`useWhepPlayer.ts` `~L111-129`) only restarts on `videoWidth === 0` or `paused`, so a
   **frozen** frame is never recovered.
4. **Multi-camera follow** still relies on the 10 s poll — the `CricketStreamUpdated` realtime event
   was deleted and remains inert.

### Corrections worth recording

- **HLS here is a pure remux (SRS `hls_fragment` only targets; no re-encode), so HLS quality ==
  WHEP quality.** A "low quality" picture is the **publisher's capture/bitrate** (the phone reports
  480×720), not the transport.
- **A CDN cannot proxy WebRTC.** WHIP/WHEP scale per **peer**: server egress ≈ `viewers × stream
  bitrate`, so a 1 Gbps NIC ≈ 300 viewers at 3 Mbps and 10 Gbps ≈ 3000 — while HLS behind a CDN
  scales to tens of thousands because it is cacheable. Low latency **and** mass scale needs LL-HLS via
  CDN, or a WHEP edge cluster (expensive), not a single bigger box.

---

## 0c. 2026-10-02 (second report) — transport PROVEN, plus why Qoder and the repo keep disagreeing

### TRANSPORT IS PROVEN: the public page is on **HLS**

Chrome's own console printed:
```
Blocked aria-hidden on an element because its descendant retained focus.
Element with focus: video#hls_video_traceodd_hls_382329251
Ancestor with aria-hidden: flt-platform-view#flt-pv-0 slot=flt-pv-slot-0
```
The focused element is **`hls_video_…`**, i.e. `CricketVideoPlayer` (HLS) — **not** `whep_video_…`.
So `_livePlayer()` fell through to HLS: **WHEP is not engaging.** Corroboration: the public screen ran
**30–60 s behind** Studio (HLS-class latency, not WebRTC). Owner also reported that when the public
window was shrunk and Studio was full-size below it, quality looked much better and Studio ran
**14 minutes** without stopping — i.e. the same HLS path, just no occlusion throttling.

### Minor notes (recorded, not for Qoder)

- **S4 (a11y):** Chrome warns `aria-hidden` on a focused descendant: the `<video>` keeps focus while
  Flutter's `flt-platform-view` marks it `aria-hidden="true"`. Cosmetic today; note it if the platform
  view is ever reworked.
- **S5 (cosmetic):** with native controls restored (`controlslist="nofullscreen nodownload"`,
  `5c5f8c4f`) the bar auto-hides when the cursor leaves the video. Owner would prefer it always visible.

### WHY QODER AND THE REPO KEEP DISAGREEING (the "done work looks undone" loop)

Twice now Qoder presented a plan whose items were **already committed**. The mechanism is not a
mis-read of one file:

1. **Qoder plans from its own session**, and its plan document is **not** this repo's brief. It does not
   run `git log`, so commits made here (`e18a58ff` … `5c5f8c4f`) are invisible to it.
2. **The brief carries the ground truth** (`§0`, `§0b`, `§0c`) — but only from `3a75399a` onward, and it
   is a *different file* from whatever Qoder edits as "the plan".
3. So it re-derives work from stale inputs and reports "full kaam nahi hua".

**Fix (tell Qoder explicitly):** ① run `git --no-pager log --oneline -25` **first**; ② read
§0 / §0b / §0c of this file **before** planning; ③ verify each item against the **actual files**, not
against a previous plan; ④ record its plan **in this repo** (append here) instead of only in its
session, so the next session sees it.

---

## 0d. 2026-10-03 — backend is WHEP-ready, but the page still runs HLS (0 frames)

Owner ran the §0c checks with the broadcaster **ON AIR**. Results:

| Check | Result | Reading |
|---|---|---|
| Public `GET /api/v1/cricket/public/matches/{id}/stream` | **`whep` POPULATED** — `/whep/watch/2838e471-07ea-4d2f-b9ff-ecc784ba8196/Cam-2` + token + `ice_servers` all pointing at the public `135.181.46.27`; `available: true` | The backend **is** handing the page a WHEP target. No null, no missing ICE. |
| `GET /api/v1/room/list` (needs the director bearer) | Room `Room-2` (`2838e471…`), camera `Cam-2`, `kind: "whip"`, **`active: true`** | A **live WHIP camera exists** — so `whepViewerFor()` is behaving correctly. |
| `grep ICE_PUBLIC_IPS /opt/todd-media-engine/.env` | `ICE_PUBLIC_IPS=135.181.46.27` | Phase 1 is live. |
| SRS `GET :1985/api/v1/streams/` | **`streams: []`** | The **engine→SRS bridge is NOT publishing** → nothing for the HLS fallback to play. |
| Browser console (`[...document.querySelectorAll('video')].map(v => ({id: v.id, w: v.videoWidth}))`) | **`[{ id: 'hls_video_traceodd_hls_382329251', w: 0 }]`** | The page is on **HLS** and has decoded **0 frames** → it sits on "search" forever (no segments, because of the SRS-empty row above). |

### Therefore, two independent findings

**(1) The page is not taking the WHEP target even though the API offers one.**
`_livePlayer()` chooses WHEP only when `_whep` is non-null, and `_whep` is filled by `getWhepTarget()`
(same endpoint as the check above). Since the API returns a full `whep` object, the page should be on
WHEP. Prime suspects, in order:
- **The served bundle is stale.** The zone rewrites `.js` cache headers (see the Cloudflare notes in
  `MASTER-TASK-LIST.md` item 10), so a returning browser can run an OLD `main.dart.js` for hours. The
  poll that upgrades HLS→WHEP landed in `7146fd7f`; if that bundle is not what the browser executes,
  the page can never upgrade. **Re-test in an Incognito window with DevTools open and "Disable cache"
  ticked, wait ~15 s while ON AIR, then re-run the console line.**
- If, in a fresh incognito window with the current bundle, the console **still** reports `hls_video_…`,
  then instrument `getWhepTarget()` (log its raw response) — the client is dropping or mis-parsing a
  `whep` block the API clearly returns.

**(2) The bridge is dead, so the HLS path has nothing to show.** SRS `streams: []` with a live camera =
the `forwarder.rs` **Engine Track** issue (this is the genuinely-open engine item — see §0b and the
Engine Track section). It also explains the "2-minute recording / repeat / search" behaviour.

### Owner's instruction (do not override)

**S1–S3 (the three score bugs) are NOT Qoder's** — the owner is fixing them separately, and they were
deliberately removed from this file in `e432cabd`. Do not add them to a plan.

---

## 1. The errors, verbatim (newest first)

These are the strings the **Cricket Manager panel** (Flutter web) and the **Todd Broadcaster**
(Android) actually showed. Every one has a precise origin — no guessing needed.

| # | On-screen text | Panel state | Where it comes from | What it really means |
|---|---|---|---|---|
| 1 | `pipeline reached end-of-stream` | `stopped` | `media-engine/crates/todd-transcode/src/forwarder.rs:843-847` — `watch_bus()` `MessageView::Eos(..)` calls `on_fail("pipeline reached end-of-stream")`; the engine stores it (`media-engine/crates/todd-sfu/src/engine.rs:1983`) | The pipeline's **input ended**: the camera's router subscription closed (publisher dropped / WHIP session torn down), **or the engine was restarted** and the camera had not re-published. Not a playback problem. |
| 2 | `engine reports the forwarder running, but SRS is receiving no media for this feed` | `stale` | `backend/app/Services/Cricket/CricketStreamSyncService.php` → `farEndProblem()` (`!$srs['receiving']`), where `receiving = kbps.recv_30s > 0` | **FALSE NEGATIVE** (see §2). SRS reports flow over a **30 s** window; a just-rebuilt forwarder reads `0` while media actually flows. **Fixed — `ef4d97ec`.** |
| 3 | `engine reports the forwarder running, but SRS has no active publish for this feed` | `stale` | same method, `!$srs['active']` | SRS has no publisher for the derived stream name `cricket_match_{matchId}_cam1`. |
| 4 | `bad request: no RTP received; camera is inactive` | `failed` | `media-engine/crates/todd-common/src/error.rs` (`BadRequest` renders as **`bad request: {0}`**) + `media-engine/crates/todd-transcode/src/forwarder.rs:441-443` | The forwarder was created but its router video channel **closed before the first video chunk arrived**. Two distinct causes: (a) the build raced a camera-session teardown; (b) **a stale engine row shadowed a live one** — see §2/§3. **Fixed — `e18a58ff`.** |
| 5 | `check the engine base URL and connectivity` (broadcaster) | HTTP **502** | `apps/broadcaster-android/app/src/main/java/com/todd/broadcaster/whip/WhipClient.kt:132` — the `else` arm of `hintFor()`, i.e. **any status other than 401/403/404/409/429** | nginx had **no upstream**: `todd-studio` was down. 502 is not a token/URL problem even though the message says "engine base URL". |
| 6 | `ingest token expired or invalid — generate a fresh one in the Studio` (broadcaster) | HTTP **401** | `WhipClient.kt:127` | The publisher **ingest token's TTL elapsed** (`INGEST_TOKEN_TTL_SECS=21600` = 6 h). Mint a fresh one (§6). |
| 7 | `Null check operator used on a null value` (Flutter web, minified `main.dart.js` stack) | crash / console | unknown throw site; recorded as an open item — START-HERE Appendix B §6.3 | Fires when navigating back to the dashboard. **Still unlocated** — part of this scan. |

**Note on the "stopped + error" combination (error #1).** `stop_forwarder()` marks a forwarder
`Stopped` **but keeps its previous `error` string** (`engine.rs:1097-1126`). So a forwarder that
ended normally (camera went away, match torn down) still displays its last error. That is why the
panel showed `state: stopped` **with** `pipeline reached end-of-stream` — see §4 item 1.

---

## 2. History of this issue (so it is never re-learned)

### The chain (unchanged)
```
Todd Broadcaster (Android, WHIP)
  → Todd Studio engine (todd-signaling + todd-sfu)      <- camera + SFU; Studio plays via WHEP
  → GStreamer forwarder (todd-transcode)                 <- engine -> SRS bridge
  → SRS (1935) -> HLS segments
  → /var/www/traceodd/cricket-hls/live/*.m3u8
  → nginx  → https://cricket.traceodd.com/hls/live/{key}.m3u8   (public page, HLS fallback)
  → WHEP: POST /whep/watch/{room}/{camera}                       (public page, PREFERRED)
```
**Asymmetry that keeps confusing people:** Todd Studio consumes **WHEP straight from the SFU**, the
public page prefers **WHEP** too (`PublicMatchController::streamUrl()` returns `'whep'` first, HLS
as fallback) — so a *working Studio picture* and a *dark/again-broken public page* are independent.
The engine→SRS→HLS hop is the **fallback**, and the Manager's "Live Video" screen is (today) an
**HLS/SRS-centric diagnostic**.

### Timeline (2026-09-30 → 2026-10-01)

1. **Symptom #1 (red, live video page):** `bad request: no RTP received; camera is inactive` while
   the mobile camera was clearly visible in Todd Studio, after an operator `Cut → Take` (PVW→PGM).
2. **Diagnosis (code):** the forwarder is created for the on-air camera. `forwarder.rs:441` returns
   that error when the router video channel closes before the first chunk. The engine **never deletes
   a terminal status row**, and `list_forwarders()` sorts by key `{room}/{camera}/{url}`, so **several
   rows for the same target URL** accumulate. `healthForMatch()` took the **first** match — an old
   dead row (`05904862…/CAM-09`) — and reported its stale error while a live forwarder existed
   (`f70e619c…/CAM-1`). **Live proof:** 4 rows, one URL, alphabetically-first held the error.
3. **Fix 1 — `e18a58ff`** (deployed): `healthForMatch()` now prefers the **running** row, else the
   **newest** by `started_at_ms`; and the Manager page renders its errors through
   `StickyErrorBanner` (sticky / copyable / closable) — that page had been **missed** by the item-7
   error-copy sweep.
4. **Symptom #2 (after a hard restart):** `engine forwarder state: stale` →
   `SRS has no active publish` then `SRS is receiving no media`.
5. **Investigation:** `systemctl status todd-studio` showed the service **`disabled`** and the
   container down (the owner had run `docker restart todd-studio`, which fights the `--rm` +
   systemd unit). After `systemctl restart todd-studio`, **HLS segments appeared**
   (`…-72.ts` … `…-77.ts.tmp`, playlist advancing) and the public URL returned **200**.
6. **Decisive evidence (media IS flowing):** SRS `/api/v1/streams/`:
   `publish.active=true`, `frames=6616`, `recv_bytes=22683448`, **`kbps.recv_30s=780`**,
   H264 480x720 + AAC 44100; camera `ROOM-3/CAM-3 active=true`; forwarder single row `running`.
7. **Root cause of #2:** `recv_30s` is a **30 s** window. The **every-minute** Laravel watchdog
   (`cricket:stream-watchdog` → `resyncMatch`) judged a freshly-rebuilt forwarder (window still `0`)
   as dead, tore it down, rebuilt it — resetting the window **again**. A **self-sustaining loop** that
   reported the bridge broken *forever* while it was working. It also made the public page's
   `available` flag false.
8. **Fix 2 — `ef4d97ec`** (deployed): a **`FAR_END_GRACE_MS = 90000`** settle window in
   `healthForMatch()` — the far-end verdict is applied only to a forwarder older than the grace. A
   genuinely dead feed is still caught, one grace period later. 3 regression tests added.

### Environment facts learned the hard way

- `todd-studio` runs as a **systemd unit** wrapping `docker run --rm --network host`
  (`media-engine/deploy/systemd/todd-studio.service`). **Always** `systemctl restart todd-studio`;
  **never** `docker restart todd-studio`.
- Health: `curl -fsS http://localhost:8082/healthz`. Public: `https://studio.traceodd.com/healthz`.
- The service was **`disabled`** → it does not come back on boot.
- The engine's forwarder/room state is **in memory**; a restart clears forwarders. **A WHIP publisher
  does NOT survive an engine restart — the broadcaster must re-publish.**
- `MEDIA_ENGINE_JWT_SECRET` (Laravel `.env`) and `JWT_SECRET` (`/opt/todd-media-engine/.env`) must
  match; ingest/viewer tokens are HS256 and verified locally by the engine.
- Ingest token TTL is 6 h (`INGEST_TOKEN_TTL_SECS=21600`); the broadcaster just 401s when it expires.

### ⚠️ Security incident found during the same session (context for the Qoder expert)

`crontab -l -u root` contained **two every-5-minute jobs** that downloaded a script from
`https://pastefy.app/vmoat1ic/raw` and used `https://pastefy.app/ekj0ynna/raw` to **append an
unrecognised RSA key into `/root/.ssh/authorized_keys`**, then made the cron spool immutable
(`chattr +ia`) to resist removal. It is **not** part of this project (nothing in the repo references
`pastefy`/`rsync-update`) and has **nothing to do with video**. It was removed by the owner; the
rogue key's fingerprint is `SHA256:MH5CE8TCaHjz6wzi1l50jxZe8Nh4HeW7Kut1GuJ8Twc` (RSA, no comment).
Auth logs showed **no login** with it (only `picks@pick`), but **assume compromise and rotate
secrets** (DB, `MEDIA_ENGINE_JWT_SECRET`, `APP_KEY`, GitHub secrets, Cloudflare). The cleanup also
emptied `authorized_keys` → **CI's deploy SSH key must be re-added** or deploys fail.

---

## 3. What is fixed (do not redo)

| Commit | Change | Tests |
|---|---|---|
| `e18a58ff` | `healthForMatch()` prefers the running/newest row (stale row no longer shadows a live one); `live_video_page.dart` uses `StickyErrorBanner` + an explanatory hint for `no RTP received` | `backend/tests/Feature/CricketStreamHealthTest.php` (4 cases) |
| `ef4d97ec` | `FAR_END_GRACE_MS` settle window so a freshly-rebuilt forwarder is not judged by SRS's 30 s window | +3 cases (young trusted / mature-no-media stale / mature-with-flow running) |

Suite: **35 tests, 131 assertions — green.** `dart analyze` clean on the touched page.

---

## 4. Still open (ranked)

1. **Engine marks a stopped forwarder with its old error.** `stop_forwarder()` sets `Stopped` but
   keeps `error` (`engine.rs:1097-1126`), so a forwarder that ended because the camera left still
   shows `pipeline reached end-of-stream`. → Clear `error` on stop, or add a terminal reason
   (`stopped_at`, `stop_reason`) and let the panel distinguish *"match ended / camera gone"* from
   *"bridge failed"*. **This is what the owner saw after the hard restart.**
2. **The Manager "Live Video" page is HLS/SRS-centric while viewers use WHEP.** Owner's directive
   (2026-10-01): *"HUM NE STREAM KO HLS PAR NAHEEN CHALANA."* → Make the page report **WHEP viewer
   readiness** (`whepViewerFor()` already exists) and keep the SRS/HLS bridge as a secondary line.
3. **Engine fan-out cross-delivers media types.** Log:
   `appsrc=video_src codec=Opus expected=[H264, Vp8, Vp9]` — the router's rid-scoped fan-out puts
   audio and video on one subscription. Currently **contained** by the forwarder's codec filter.
   Real fix belongs in `media-engine/crates/todd-sfu/src/router.rs` (scope fan-out by media type).
4. **`todd-studio.service` is `disabled`** → `systemctl enable todd-studio todd-turn todd-redis
   todd-broadcaster`. Same check for the other media units.
5. **TURN allocation failures** (seen 2026-10-01): `Failed to allocate on turn.Client
   172.17.0.1:3478 attribute not found`, `pingAllCandidates called with no candidate pairs`.
   Video worked afterwards (likely direct host candidates), but this must be verified — it breaks
   publishers on networks that need the relay. Check `todd-turn` / coturn credentials.
6. **Deploy SSH key removed** during the security cleanup → re-add (own key + the CI deploy key).
7. **The frontend `Null check operator used on a null value` crash** (error #7) — still unlocated.
8. **`forwarder.rs` registry race (suspected, unconfirmed):** `spawn_input_pump()` removes the whole
   shared subscription by key on exit (`forwarder.rs:315`), while `register_inputs()` is idempotent
   per track name (skips + **drops the new router receiver**, `forwarder.rs:235-268`). A dying pump
   can therefore remove an entry a freshly-registered pipeline depends on. Needs a stable
   generation/ownership token before removal. *(Do not change blindly — needs the gst build to verify.)*

---

## 5. THE SCAN TASK — what the Qoder expert must do

**Scope:** **every Cricket panel**, i.e. `lib/features/cricket/presentation/pages/**`.

| Group | Files (all under `lib/features/cricket/presentation/pages/`) |
|---|---|
| Manager | `manager/live_video_page.dart` · `manager/manager_dashboard_page.dart` · `manager/manager_login_page.dart` · `manager/manager_score_page.dart` · `manager/manager_replay_page.dart` · `manager/voice_score_page.dart` · `manager/media_management_page.dart` · `manager/fixture_scheduler_page.dart` · `manager/match_form_sheet.dart` · `manager/generate_fixtures_sheet.dart` · `manager/player_register_page.dart` · `manager/players_list_page.dart` · `manager/squad_setup_page.dart` · `manager/team_register_page.dart` · `manager/teams_list_page.dart` · `manager/tournament_setup_page.dart` · `manager/sponsor_manage_page.dart` · `manager/sponsor_form_sheet.dart` · `manager/assign_sponsor_sheet.dart` · `manager/dls_calculator_page.dart` |
| Public | `public/live_match_page.dart` · `public/scorecard_page.dart` · `public/tournament_home_page.dart` · `public/tournament_hub_page.dart` · `public/club_home_page.dart` · `public/match_analytics_page.dart` · `public/player_profile_page.dart` · `public/best_xi_page.dart` |
| Data layer | `lib/features/cricket/data/repositories/cricket_repository.dart` · `lib/features/cricket/presentation/bloc/**` |
| Backend | `backend/app/Http/Controllers/Cricket/**` · `backend/app/Services/Cricket/**` · `backend/routes/panels/cricket.php` |

### Defect classes to hunt (each has bitten this module already)

1. **A failure that is not sticky / not copyable.** Every error surface must use
   `StickyErrorBanner` (`lib/shared/widgets/feedback/`) — a fire-and-forget SnackBar is a bug.
   *(`live_video_page.dart` was missed; fixed in `e18a58ff`.)*
2. **Swallowed errors.** `catch (_) {}` or `catch (e) { /* ignore */ }` that turns a failure into a
   fake empty state. (`media_management_page`, `players_list_page` had this — see MASTER-TASK item 7.)
3. **Errors set but never rendered.** A bloc sets `_error` / `error` and the builder has no branch
   for it → the screen just looks empty.
4. **Stale/terminal state shown as current.** Rows or statuses that are never removed (see §4 item 1);
   matching a single item by a non-unique key; "first match wins" instead of "best match wins".
5. **Hardcoded / demo values** and **dead buttons** (MASTER-TASK items 9). Flag any hardcoded match
   id, camera id, URL, or plan limit.
6. **Raw engine/backend error strings shown to the operator with no explanation.** E.g.
   `bad request: no RTP received; camera is inactive` is meaningless to a match operator; pair every
   engine error with a one-line human hint.
7. **Null-check crashes** (`!` on a nullable that can be null), especially around navigation and
   list indexing — the `Null check operator` crash (error #7) is still open.
8. **State that does not survive / recover**: "offline" shown for any 404, no retry, no reconnect.

### Deliverable for the Qoder expert

For each file above: list the error surfaces found, the class (1–8) it falls into, and a patch.
Add a regression test where the backend is involved (`backend/tests/Feature/`). Record the commit
hash next to each item in `MASTER-TASK-LIST.md` as it lands.

---

## 6. Commands (diagnose + operate)

```bash
# Engine state (correct way: systemd, never `docker restart`)
systemctl status todd-studio --no-pager -l        # watch for: disabled
systemctl enable todd-studio todd-turn todd-redis todd-broadcaster
journalctl -u todd-studio --no-pager -n 120
curl -fsS http://localhost:8082/healthz

# Forwarders + cameras + program (admin token)
TOKEN=$(cd /var/www/traceodd/admin-panel && php artisan tinker --execute="echo app(App\Services\MediaEngineTokenService::class)->mint(role:'admin', subject:'diag', perms:['studio_director'], ttlSeconds:180);")
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/forward/list | python3 -m json.tool
curl -s -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8082/api/v1/room/list    | python3 -m json.tool

# Is media actually flowing (the only truth)
curl -s http://127.0.0.1:1985/api/v1/streams/ | python3 -m json.tool     # publish.active + kbps.recv_30s
ls -la /var/www/traceodd/cricket-hls/live/ ; sleep 10 ; ls -la /var/www/traceodd/cricket-hls/live/
curl -s -o /dev/null -w "%{http_code}\n" "https://cricket.traceodd.com/hls/live/cricket_match_<MATCH_ID>_cam1.m3u8"
docker logs --since 5m todd-studio 2>&1 | grep -aiE "forwarder started|forwarder running|pipeline build failed|EOS|not-negotiated|no RTP|keyframe"

# Fresh ingest token for a publisher (route: media-engine/crates/todd-signaling/src/app.rs:71)
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
  "http://127.0.0.1:8082/api/v1/room/<ROOM_ID>/camera/<CAMERA_ID>/token" | python3 -m json.tool

# Laravel side
cd /var/www/traceodd/admin-panel && php artisan cricket:stream-watchdog
tail -30 storage/logs/laravel.log
php artisan tinker --execute="print_r(app(App\Services\Cricket\CricketStreamSyncService::class)->healthForMatch('<MATCH_ID>'));"
```

---

## 7. Do NOT re-chase (false leads)

- **HLS latency / segment length is not a fault.** SRS runs pure remux; a segment ends only on a
  keyframe, so `#EXTINF` of 5–10 s (even 30–70 s) is normal and must not trigger a teardown.
- **`bad request: no RTP received` is not a camera problem** when the picture is fine in Studio — it
  is the engine→SRS forwarder's channel closing (see §1 #4).
- **502 on the broadcaster is not a token/URL problem** despite the message text — it means the
  engine was down (nginx had no upstream).
- **`state: stopped` with an old error is not necessarily broken** — `stop_forwarder` keeps the last
  error (§4 item 1).
- **Do not trust a green `cargo check --workspace`** for the forwarder: `forwarder.rs`, `mixer_gst.rs`
  and `audio.rs` sit behind `#[cfg(feature = "gst")]`. Use
  `cargo check -p todd-signaling -p todd-sfu --features gst` (needs GStreamer ≥ 1.24).
- **The `appsrc=video_src codec=Opus` warning is contained**, not the cause.
