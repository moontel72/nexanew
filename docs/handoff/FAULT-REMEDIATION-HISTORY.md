# FAULT REMEDIATION HISTORY — Media Engine (GStreamer / audio buses / Docker)

**Audience:** any agent (or human) picking up work on the NexaTrace media engine.
**Read this before touching `media-engine/crates/todd-transcode/`.**

This file is the history of one remediation cycle: an external agent (Qoder)
scanned the codebase and produced a fault report, a second agent implemented
fixes, and the first push **failed CI**. The mistakes are documented here on
purpose — they are more useful than the successes.

**2026-09-19 update:** a read-only investigation pass identified the actual cause
of the original outage. It is **not** one of the 11 faults and **not** one of the
bugs found during the work — it is a declare/feed mismatch inside
`todd-transcode/src/forwarder.rs`. See **§9** for the evidence, the commands that
produced it, and what is still unverified; §0.3 and §7 carry the corrected
one-paragraph summary.

---

## 0. TL;DR for the next agent

1. **The `gst` feature is not compiled by a plain `cargo check`.** It is behind
   `#[cfg(feature = "gst")]`, and `cargo check --workspace` silently skips
   `forwarder.rs`, `mixer_gst.rs` and `audio.rs` entirely. A green workspace
   build proves **nothing** about those files.
2. **Always run the CI command before pushing:**
   ```sh
   cargo check -p todd-signaling -p todd-sfu --features gst
   ```
   This needs `libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev`
   (GStreamer >= 1.24). See §6 for how to set it up on Windows.
3. **The original reported problem is still unsolved — but its root cause is
   now identified.** See §7 and, for the full evidence trail, **§9
   (2026-09-19)**. One line: `build_description` declares an audio `appsrc`
   branch for *every enabled bus* while only the *primed* buses get a push
   task, so `flvmux` waits for streams that never deliver and the video never
   reaches SRS. It is **not fixed yet** — §9.10 describes the change.
4. `pubsub`-style live debugging: the engine's own comments are unusually
   detailed. Trust them over any external report — including this one.

---

## 1. Where this started

The operator's actual symptom (from `STREAM-ISSUE-REPORT-FOR-QODER.md`):

> Live video was not reaching the public page. The broadcaster reached the
> engine, the forwarder reported "running", but SRS received nothing.

Qoder produced a **fault scan report** listing 11 defects. That report is
reproduced in §3, together with what was actually true for each item.

---

## 2. Commit history of this cycle

| Commit | Contents | CI |
|---|---|---|
| `6fab701e` | `DOCS: handoff report for QODER expert agent` | — |
| `4b4f1127` | 11-fault remediation, 8 files | ❌ **red** — 5 compile errors |
| `b9b5db9d` | Fixes for those 5 errors, 3 files | ⏳ unknown at time of writing |

`4b4f1127` is the cautionary tale: it was written, reviewed line-by-line by a
sub-agent, and pushed **without ever being compiled**, because GStreamer was
not installed on the authoring machine. The reviewer's static analysis caught
duplicate definitions and a `MutexGuard`-across-`.await` bug — but missed 5
errors a compiler finds instantly.

**Rule: an un-compiled push is not a fix. It is a guess.**

---

## 3. The 11 faults — report vs. reality

### CRITICAL

#### FAULT 1 — Deprecated `audiodelay` element
- **Report said:** `audiodelay` was removed in GStreamer 1.24; replace it with
  `audioecho` or a `queue`'s `min-threshold-time`.
- **Reality:** the report's *diagnosis* was wrong; its *suggestion* was right.
  `audiodelay` **is still shipped in 1.24** (in `gstreamer1.0-plugins-good`).
- **Actual bug:** the pipeline declared `identity name=adelay_{bus}` and
  `apply_audio_config()` then tried to set a `delay` property on it. `identity`
  has no `delay` property, so lip-sync delay was a silent no-op — the director
  moved a control, nothing happened on the wire, and no error was raised.
- **Fix:** replaced the `identity` with
  `queue name=adelay_{bus} min-threshold-time=0 max-size-time=1000000000`,
  and `apply_audio_config()` now sets `min-threshold-time` (nanoseconds),
  guarded by `find_property("min-threshold-time")`.
- **File:** `media-engine/crates/todd-transcode/src/mixer_gst.rs`
  (`build_description`, `apply_audio_config`).
- **Note:** `queue` is in `coreelements`, so it is always present — unlike an
  optional plugin element. `delay_ms` is clamped to `DELAY_MAX_MS = 500`, well
  under the queue's 1 s `max-size-time`.

#### FAULT 2 — `gst_mixer_skeleton` produced duplicate mixers
- **Report said:** `branches.join(" ! ")` emits `audiomixer name=mix` once per
  branch, which GStreamer rejects.
- **Reality: correct.** Each branch string already contained
  `audiomixer name=mix`, so two enabled buses produced
  `audiotestsrc ! audiomixer name=mix ! audiotestsrc ! audiomixer name=mix`.
- **Fix:** the mixer is declared **once** (`audiomixer name=amix`) and every
  bus links into it as `audiomixer.sink_N` (indices contiguous from 0, taken
  from `branches.len()` *before* the push). Empty config now emits a
  keep-alive silence pad so the mixer can still produce a buffer.
- **File:** `media-engine/crates/todd-transcode/src/audio.rs`
- **Status:** the function is **not called from production code** — it is a
  skeleton builder. It was a latent trap, not an active outage.

#### FAULT 3 — Stinger `uridecodebin` without a video caps filter
- **Report said:** add `decodebin ! video/x-raw` between `uridecodebin` and
  `videoconvert`.
- **Reality:** the problem is real, **the suggested fix is not reliable.**
  `uridecodebin` is a multi-stream source and can emit its *audio* pad first.
  Written as `uridecodebin ! video/x-raw ! videoconvert`, GStreamer may link
  the audio pad into the capsfilter, which fails negotiation and — because the
  link is made inside a `pad-added` handler — can take the whole compositor
  down.
- **Fix:** use the caps filter as a **pad template**:
  `uridecodebin name=stinger_src uri="…" ! video/x-raw ! videoconvert …`.
  This makes `uridecodebin` request a *video* pad; any audio pad is left
  unlinked.
- **File:** `mixer_gst.rs` (`build_description`)
- **⚠️ Not yet functionally verified.** Confirming this needs a stinger asset
  that actually contains an audio track. The pipeline parses; the runtime
  behaviour is unproven.

### MAJOR

#### FAULT 4 — Swallowed property errors
- **Report said:** replace `let _ = self.element.set_property_from_str(…)`
  with `if let Err(e) = …`.
- **Reality:** that is a **compile error**.
  `gst::prelude::GObjectExtManualGst::set_property_from_str` returns `()`, not
  a `Result` — it **panics** on an unknown property or an unparsable value
  (`gstreamer-0.23.7/src/gobject.rs:15`). There is no error to match on.
- **Fix:** added `set_prop_checked()`, which does what that method does
  internally but *fallibly*:
  ```rust
  GstValueExt::deserialize_with_pspec(value, &pspec)  // -> Result<Value, BoolError>
  target.set_property_from_value(name, &value);
  ```
  `set_props()` (elements) and `set_pad_geometry()` (pads) call it and emit
  `tracing::warn!` on failure, leaving the property at its previous value
  instead of unwinding the request task into an opaque 502.
- **Gotcha:** the crate depends on `gstreamer`, **not** on `glib`, so the path
  must be `gst::glib::Object` / `gst::glib::Value` — a bare `glib::…` does not
  resolve.
- **File:** `mixer_gst.rs`

#### FAULT 5 — Mutex poisoning
- **Report said:** `poisoned.into_inner()` blindly trusts stale data; reset
  instead.
- **Reality: correct.**
- **Fix:** `mod poison` with
  `lock_resetting<'a, T>(mutex: &'a Mutex<T>, label: &str, fresh: impl FnOnce() -> T) -> MutexGuard<'a, T>`.
  On poison it logs, discards the payload and writes `fresh()`. Safe because
  every guarded structure (`bindings`, `audio_bindings`, `audio_tasks`,
  `slots`, `current`) is a **cache** that the rebuild path re-derives.
- **Gotcha:** the explicit `'a` on `mutex` only. A single elided lifetime makes
  the guard's lifetime depend on `label` too, which is a compile error
  (`E0106`) when `label` is a `&str` from elsewhere.
- **File:** `mixer_gst.rs`

#### FAULT 6 — WebRTC viewer forwarding not implemented
- **Report said:** implement it, or handle it gracefully.
- **Action taken: NOT implemented.** `ForwardKind::WebRtcViewer` still returns
  an error. It needs a signaling service plus `gst-plugins-rs webrtcsink`,
  neither of which is in this build. Implementing it is a **feature**, not a
  fault fix.
- **What *was* done:** made the refusal honest and consistent.
  - One shared constant `WEBRTC_VIEWER_UNAVAILABLE` in
    `todd-transcode/src/forwarder.rs`.
  - Rejected **at the endpoint** in `todd-sfu/src/engine.rs`
    (`add_forwarder` and `add_program_forwarder`), so a `ForwardingStatus` is
    recorded. Previously the 501 came from deep inside the pipeline builder
    with **no status row**, which left the 5 s watchdog free to retry forever.
- **This is the one item where the implementation deliberately does less than
  the report asked.** Do not "finish" it by guessing; scope it properly.

#### FAULT 7 — Default audio buses
- **Report said:** only Commentary and Ambient are enabled by default; `sfx`
  and `music` publishers are silently dropped.
- **Reality: correct.**
- **Fix:** `default_buses()` in `todd-common/src/media.rs` now enables **all
  four** (`enabled: true`).
- **⚠️ Risk this introduces:** every bus now gets a branch in the forwarder.
  The audio *priming* logic (`AUDIO_PRIME_TIMEOUT`, 1.5 s) is what keeps a
  silent bus from stalling `flvmux`, and it was **added earlier** in
  `f6fc23b5` for exactly this class of bug. Do not remove the priming; the
  default-bus change depends on it.
- **Test updated:** `todd-common/src/media.rs`
  `default_mixer_enables_every_bus`.

### MINOR

#### FAULT 8 — Raw target URLs injected into pipeline strings
- **Report said:** escape/validate target URLs.
- **Reality: correct.** `gst_parse_launch` has no escaping: `"` closes the
  value, `#` starts a comment, `! , ;` separate elements, `=` breaks the
  property list.
- **Fix:** `sanitize_url()` in `forwarder.rs` strips
  `" \ # ! , ; = CR LF` and control characters, logs when it changes anything,
  and rejects an empty result. Applied in **both** `build_description` and
  `build_program_description`.
- **Gotcha:** it takes `&str`, so a `&String` needs `.as_str()`.

#### FAULT 9 — Docker non-root user had no GStreamer cache
- **Report said:** set `GST_REGISTRY_REUSE_PLUGIN_SCANNER=no` and configure
  `XDG_CACHE_HOME`.
- **Reality: correct.**
- **Fix:** in `media-engine/deploy/docker/Dockerfile`, the runtime stage now
  creates `/home/todd/.cache/gstreamer-1.0` with `todd:todd` ownership and sets
  `XDG_CACHE_HOME`, `GST_REGISTRY`, `HOME`.

#### FAULT 10 — Redis had persistence disabled
- **Report said:** `--save "" --appendonly no` loses all room state on restart.
- **Reality: correct, and it matters** because Studio runs with
  `ROOM_STORE=redis`.
- **Fix:** `media-engine/deploy/docker/docker-compose.yml` now uses
  `--save 60 100 --save 300 10 --dir /data` with a named volume `redis-data`.
- **⚠️ Scope note:** this is infrastructure tidiness. It has **nothing to do**
  with the reported streaming outage.

#### FAULT 11 — Hardcoded 16 ms animation steps
- **Report said:** derive the interval from `1000 / target_fps`.
- **Reality: correct.** The 16 ms step assumed 60 fps; at a 24 fps output it
  burns CPU on values that are overwritten before they can be rendered.
- **Fix:** `animation_steps(duration_ms, fps) -> (steps, step_ms)` with
  `MAX_ANIMATION_STEPS = 120` and `ANIMATION_FPS = 30` as a fallback. The
  mixer's configured `fps` is stored on `GstProgramMixer` and threaded through
  `animate_alpha`, `animate_sync`, `animate_rect` via `animation_fps()`.

---

## 4. Bugs found *during* the work (not in the report)

These matter more than the 11, because they were found by attacking the code
rather than by following instructions.

### 4.1 `fan_out` silently dropped frames (`forwarder.rs`)
First version only recovered the chunk from the `Full` arm of `try_send`:
```rust
if let Err(mpsc::error::TrySendError::Full(returned)) = tx.try_send(chunk) {
    chunk = returned;   // Closed arm dropped the chunk entirely
}
```
Any consumer whose receiver had closed caused every *subsequent* consumer in
the list to be skipped. Rewritten to take the value back out of **both** arms.

### 4.2 `MutexGuard` held across `.await` (`forwarder.rs`)
The first shared-subscription pump did:
```rust
let mut map = lock_fanouts(&fanouts);   // std::sync::MutexGuard — !Send
let chunk = rx.recv().await;            // guard still alive
```
`std::sync::MutexGuard` is `!Send`, so this is a hard `E0277` inside
`tokio::spawn` — and, separately, a deadlock: every registration path blocks
for as long as the source is quiet. Fixed by **moving the receiver out** of the
table (`std::mem::replace(slot, closed_channel())`), dropping the guard, and
awaiting outside the lock.

### 4.3 `fan_out` reused a moved value (`forwarder.rs`)
`try_send` takes the chunk by value, so on `Ok` the binding is moved and the
next loop iteration cannot reuse it (`E0382`). Fixed by tracking the remaining
copy in an `Option` and `take()`-ing it per iteration.

### 4.4 The audio prime loop ate `audio_rx` (`forwarder.rs`)
`for (bus, rx) in audio_rx` moves the vector, but the shared-subscription
registration later needed those same receivers. Fixed by collecting the
surviving receivers during priming instead of reading them back out of
`audio_rx`.

### 4.5 `tod_common` typo (`todd-sfu/src/engine.rs`)
`tod_common::types::ForwardKind` — missing a `d`. Only visible with the `gst`
feature on, because the line it sits on is inside a `#[cfg(feature = "gst")]`
block. **This is exactly the class of error a workspace-only check hides.**

### 4.6 Compile-error cluster in `4b4f1127`
For the record, the five errors CI reported:
| Error | Location | Cause |
|---|---|---|
| `E0106` | `mixer_gst.rs:892` | elided lifetime covered `label` as well as `mutex` |
| `E0382` | `forwarder.rs:478` | `audio_rx` moved by the prime loop |
| `E0308` | `mixer_gst.rs:826` | `sanitize_uri(url)` where `url: &String` |
| `E0382` | `forwarder.rs:312` | `chunk` moved into `try_send`, reused next iteration |
| `E0433` | `engine.rs:1800` | `tod_common` → `todd_common` |

---

## 5. Files touched

```
media-engine/crates/todd-common/src/media.rs        (Fault 7 + test)
media-engine/crates/todd-sfu/src/engine.rs          (Fault 6 + 4.5)
media-engine/crates/todd-transcode/src/audio.rs     (Fault 2 + tests)
media-engine/crates/todd-transcode/src/forwarder.rs (Faults 6/8 + 4.1–4.4)
media-engine/crates/todd-transcode/src/mixer.rs     (ScenePlan: Default)
media-engine/crates/todd-transcode/src/mixer_gst.rs (Faults 1/3/4/5/11)
media-engine/deploy/docker/Dockerfile               (Fault 9)
media-engine/deploy/docker/docker-compose.yml       (Fault 10)
```

Beyond the report, `forwarder.rs` also **gained** a shared-subscription
fan-out layer (`SharedSubscription`, `register_consumer`,
`release_consumer`, `register_inputs`, `spawn_input_pump`) so several outputs
for one URL — and the MJPEG websocket — can share a single router
subscription. **This layer has never been exercised at runtime.**

---

## 6. How to actually compile the `gst` feature (Windows)

This is the setup that finally made real compilation possible. Reuse it.

1. Download `gstreamer-1.0-devel-msvc-x86_64-1.24.13.msi`
   (~712 MB) from `gstreamer.freedesktop.org/data/pkg/windows/1.24.13/msvc/`.
   `curl -sL` **without `-C -`** truncates and gives MSI error 1620.
2. Extract without admin rights:
   ```
   msiexec /a gs-devel.msi /qn TARGETDIR=C:\gs-dev\extract
   ```
3. Point the build at it (note `env` — the var is not exported through this
   shell, and the path separator must be `;`):
   ```
   env PKG_CONFIG_PATH="C:/gs-dev/extract/gstreamer/1.0/msvc_x86_64/lib/pkgconfig;C:/gs-dev/extract/gstreamer/1.0/msvc_x86_64/lib/gstreamer-1.0/pkgconfig" \
       PATH="/c/Users/<you>/.cargo/bin:/c/gs-dev/extract/gstreamer/1.0/msvc_x86_64/bin:/c/msys64/mingw64/bin:/usr/bin" \
       cargo check -p todd-signaling -p todd-sfu --features gst
   ```
4. **Known limitation:** `cargo test --features gst` compiles but the test
   binary dies with `STATUS_DLL_NOT_FOUND` (0xc0000135) because the GStreamer
   DLLs are not on the runtime search path. Adding the `bin` dir to `PATH` did
   **not** fix it in the attempt made here. **Consequence: the `gst`-gated unit
   tests have still never been executed.** Ubuntu CI is the place to run them.

---

## 7. ⚠️ THE ORIGINAL PROBLEM IS STILL OPEN

> **UPDATE 2026-09-19 — the root cause has been identified. See §9.**
> The priming logic described below is **not innocent, it is incomplete**: it
> drops a silent bus from the *push* side, but `build_description` still
> *declares* a branch for that bus. The real fault is a declare/feed mismatch,
> and this section's conclusion that "the priming logic is not the bug" was
> **wrong**. Read §9 before acting on anything below.

> **Todd-Studio's stream does not appear on the public page.**

Nothing in §3 or §4 fixes this. The fixes are real defects, but they are
*other* defects. Be honest with yourself about that before reporting success.

Qoder's own analysis of the audio path was **correct** and should be the
starting point:

- `engine.rs` only subscribes buses in `router.audio_tracks()` — i.e. buses the
  publisher actually registered.
- `forwarder.rs` gives each bus a 1.5 s `AUDIO_PRIME_TIMEOUT` and drops it if
  it sends no frame, logging
  `"audio bus produced no frames within the prime window; forwarding without it"`.
- The audio branches are only built when `has_audio` is true.

So: **partly wrong — the priming logic is not *sufficient*.** It removes a
silent bus from the push side only; the description still declares its branch
(§9). The evidence-gathering steps below are still the right first move:

1. Broadcaster logs — search for `audio bus produced no frames`. Its **absence**
   when audio is missing means the publisher never registered the track at all.
2. `forwarder_status` API output — `state` (`Starting`/`Running`/`Failed`) and
   `error`. `Running` with no SRS output means the **bus** reported success
   while the sink failed: read the `watch_bus` error text.
3. SRS logs — did the publish attempt arrive at all?
4. Public page console — the report in
   `STREAM-ISSUE-REPORT-FOR-QODER.md` §3.9 mentions **403s**; a permissions
   problem on the viewer side would look identical to a media problem from the
   outside.

Do not start by editing pipelines. Start by reading logs.

---

## 8. Process lessons

1. **Never push un-compiled code.** `4b4f1127` looked correct, passed a
   line-by-line review, and broke the build in 5 places. Static review is not
   a substitute for a compiler — it is a supplement to one.
2. **A green `cargo check --workspace` is not coverage.** It skips the entire
   `gst` surface. Know which command CI actually runs and run that one.
3. **Do not trust an external fault report blindly.** Of the 11 items, 1 had a
   wrong diagnosis (Fault 1), 1 had a wrong fix (Fault 3), 1 had an impossible
   fix (Fault 4), and 1 was a feature request masquerading as a bug (Fault 6).
4. **Check whether generated pipeline strings are tested at all.** The
   `gst`-gated tests (`description_contains_*`, `audio_branch_survives_a_silent_bus`)
   parse nothing — they assert on substrings. They cannot catch an invalid
   pipeline. Treat them as documentation, not verification.
5. **State what you did *not* verify.** "Compiled" ≠ "tested" ≠ "works". The
   stinger caps fix and the whole fan-out layer are both in the first category
   only.
6. **Fix the reported problem first.** Fixing 11 side-faults while the reported
   outage persists is a very expensive way to not solve anything.

---

## 9. UPDATE — 2026-09-19: root cause identified (declare/feed mismatch in the forwarder)

**Investigation:** read-only pass over the current tree (`b0a755ca`), both
handoff documents, and the operator's live browser console output from
`studio.traceodd.com` and `cricket.traceodd.com`. **No code was changed.**

**Verdict:** the outage is a **logic conflict inside
`todd-transcode/src/forwarder.rs`**. It is not a missing feature, not a config
value, and not the delivery chain. Every item in §3 and §4 is a real defect, but
none of them is the cause.

### 9.1 The fault in one sentence

`build_description()` declares an audio `appsrc` branch for **every bus whose
mixer config is `enabled`**; `build_with_callback()` attaches a push task only to
the buses that **actually primed**. A branch in the first set but not the second
is never fed a buffer, so the shared `audiomixer` never prerolls and `flvmux`
waits for a stream that never arrives — which means the **video** never leaves
either.

### 9.2 Declare side and feed side — the two loops that disagree

**Declare side** — `forwarder.rs::build_description` (**L899–L940**):

```rust
let mut audio_branches: Vec<String> = Vec::new();
if has_audio {                       // <- a single bool (L900)
    audio_branches.push("audiomixer name=mix ! audioconvert ! audioresample \
                         ! voaacenc bitrate=128000 ! aacparse \
                         ! queue name=aq max-size-time=1000000000 ! mux.".to_string());
    for bus in AudioBus::ALL {       // L907 — ALL FOUR buses
        let bus_cfg = audio_cfg.bus(bus);
        if !bus_cfg.enabled { continue; }     // L909
        // ...
        audio_branches.push(format!(
            "appsrc name=audio_{} format=time do-timestamp=true is-live=false ... ! mix.",
            bus.as_str(), bus.as_str()));     // L931
    }
}
```

**Feed side** — `forwarder.rs::build_with_callback`:

- **L434–L453** — prime: keep only buses that delivered a chunk inside
  `AUDIO_PRIME_TIMEOUT` (**L48**, 1500 ms) → `live_audio`.
- **L455** — `let has_audio = !live_audio.is_empty();`
- **L458–L466** — `build_description(..., has_audio)`. **The live bus set is
  never passed** — only this boolean.
- **L523–L536** — push tasks are spawned **only for `live_audio`**.

`build_description` therefore cannot know which buses primed; it re-derives the
branch list from the mixer config, which is a **superset** of what is fed.

### 9.3 Why it fires on every normal broadcast

- `todd-common/src/media.rs` **L184–L193** — `default_buses()` enables **all
  four** buses (that is the "fix" for §3 Fault 7).
- `todd-common/src/types.rs` **L249–L250** — `ForwardTarget.audio` is
  `#[serde(default)]`.
- `backend/app/Services/Cricket/CricketStreamSyncService.php` **L124–L133** —
  the Laravel→engine POST sends only `camera_id / source / kind / url /
  bitrate_kbps`. It sends **no `audio` object**, so the engine applies the
  four-enabled default.

Consequence: as soon as **one** Opus track primes, the description declares
**four** branches and only one is fed. The only shape that works is "all four
buses registered **and** all four primed inside 1.5 s", which this broadcaster
does not produce. Fault 7 (all four enabled) turned a 2-branch / 1-starved
pipeline into a 4-branch / 3-starved one; the mismatch itself is older than that
commit.

### 9.4 Git proof that the priming fix was one-sided

`git --no-pager show f6fc23b5 -- media-engine/crates/todd-transcode/src/forwarder.rs`
(`f6fc23b5`, *"FIX(engine): a silent audio bus no longer blocks video egress"*):

```diff
-            !audio_rx.is_empty(),
+            has_audio,
```

```diff
-        for (bus, rx) in audio_rx {
+        for (bus, rx, primed) in live_audio {
```

The commit message claims *"any bus that stays silent is dropped before the
pipeline is built"*. The diff contains **no hunk for `build_description`** — the
`for bus in AudioBus::ALL` loop is untouched. The drop happened on the push side
only. That, in one sentence, is the whole bug.

### 9.5 The test encodes the bug as expected behaviour

`forwarder.rs` **L1173–L1204**:

```rust
fn audio_buses_appear_in_description() {
    // The default mixer enables every bus, so each one gets a branch.
    for bus in AudioBus::ALL {
        assert!(description.contains(&format!("name=audio_{}", bus.as_str())));
    }
}
```

The test asserts exactly the wrong invariant (`has_audio = true` ⇒ four
branches), which is why a green `--features gst` run (§4.8, "31 passed") proved
nothing about the failing shape. This is §8 lesson 4 with a name and a line
number.

### 9.6 Why this explains the operator's symptoms

```
 broadcaster --WHIP--> SFU room             video OK (Studio plays it)
                          |
                    add_forwarder
                          |
        +-----------------+-------------------+
        |                                     |
 audio_rx (registered+enabled)      build_description(has_audio: bool)
        |                                     |
 prime 1.5 s  (L434-455)            for bus in AudioBus::ALL { if enabled }
        |                                     |
 live_audio: 1 bus  --push-->   audio_commentary  (fed)
        (L523-536)               audio_ambient     (declared, NEVER fed)
                                 audio_sfx         (declared, NEVER fed)
                                 audio_music       (declared, NEVER fed)
                                          |
                                    audiomixer name=mix   <-- 3 pads never preroll
                                          |
                                       flvmux          <-- waits for a stream
                                          |                 that never arrives
                              (nothing reaches SRS -> HLS 404)
```

| Observed | Explained by |
|---|---|
| Studio plays the camera (WHEP, direct from the SFU) | the viewer hop never builds the audio bus mixer — only the forwarder does |
| Public page `.../hls/live/cricket_match_a2c0880f-..._cam1.m3u8` → **404** | SRS received no RTMP publish, so no segments were ever written. The names are **not** the problem: `streamNameFor` / `rtmpUrlFor` / `hlsUrlFor` (`CricketStreamSyncService.php` L60–L79) and `config/cricket.php` L29–L33 all agree |
| Manager Live Video: `BROKEN — the bridge failed` | `live_video_page.dart` L207–L211 renders that label for `forwarder_state == 'failed'`; `watch_bus` (`forwarder.rs` L700–L769) catches the appsrc `not-negotiated (-4)` and `on_fail` (`engine.rs` L1907–L1922) writes `Failed` |
| No error visible to the operator | `forwarder_error` does reach the client (`cricket_repository.dart` L657–L663) but `live_video_page.dart` **never renders it** (§9.11) |
| Status alternates `missing` ↔ `failed` every ~5 s | the re-arm watchdog rebuilds the same broken pipeline (§3.7), and `rearm_stale_forwarders` sets `audio: Default::default()` (`engine.rs` L2039–L2051) — so it reproduces the identical shape |

### 9.7 Commands run in this pass (and what they showed)

| Command | Result |
|---|---|
| `git --no-pager log --oneline -20` | HEAD `b0a755ca`; `f6fc23b5` (priming), `4b4f1127` (11-fault remediation), `b9b5db9d` (compile fixes), `b0a755ca` (this history) all present |
| `git --no-pager show f6fc23b5 -- .../forwarder.rs` | the two hunks in §9.4; **no `build_description` hunk** |
| `grep AUDIO_PRIME_TIMEOUT\|audio_tracks\|audio bus produced no frames` | priming in `forwarder.rs` L48 / L434–L455; track subscription in `engine.rs` L1852–L1861 |
| `grep Conflict` (media-engine) | the 409 sources are `engine.rs` L657–L675 ("camera … is not live") and L1791–L1795 ("forwarder … already exists"); neither is the forwarder failure path |
| `node ../.scripts/check-php-syntax.mjs` (from `backend/`) | 8 files OK, then **ENOENT** on `app/Http/Controllers/Cricket/StreamController.php` — deleted in 4.7, still listed at `.scripts/check-php-syntax.mjs:17`. The script is broken |
| `grep cricket_streams\|StreamEndpoint\|StreamController` | table created once (`2026_08_09_000001_...`) and dropped once (`2026_09_17_000001_drop_cricket_streams_table.php`); all remaining hits are stale docs/config comments |
| `find_path` for cricket controllers / camera switcher | `StreamController.php`, `StreamEndpoint.php`, `CameraSwitcher*` confirmed **absent** |
| `grep stream.updated\|streamUpdates\|CricketStreamUpdate` | Flutter still subscribes (`cricket_repository.dart` L542–L553, `stream_player_bloc.dart` L110); the Laravel event that published it was deleted in 4.7 |

### 9.8 Chain audit — where a failure can still become silent

| Hop | File | Silent-failure risk |
|---|---|---|
| Broadcaster → Engine | `whip_peer.rs` | none found |
| Engine router → forwarder audio | `engine.rs` L1852–L1861 | a *registered* track is not a *delivering* track |
| **Forwarder: declare vs feed** | `forwarder.rs` L899–L940 vs L523–L536 | **the fault (§9.1)** |
| Forwarder → SRS | `forwarder.rs` `watch_bus` L700–L769 | now logged (since `f6fc23b5`) |
| Forwarder status | `engine.rs` L1936–L1956 | `Running` still means "the object was built", not "bytes reached SRS" |
| Engine → Laravel health | `CricketStreamSyncService::healthForMatch` L159–L179 | matches on URL, so a stale status can survive |
| Laravel → Manager UI | `live_video_page.dart` | `forwarder_error` is fetched and **never rendered** |
| Laravel → Public API | `PublicMatchController::streamUrl` L194–L211 | URL is derived, no row dependency — correct |
| Public player | `stream_player_bloc.dart` L86–L102 | shows "offline" for any 404, no cause |
| nginx → HLS dir | `.nginx/cricket-public.conf` L43–L56 | verified working (§3.1 DIAGTEST) |

### 9.9 Runtime confirmation (NOT YET RUN) and acceptance test

⚠️ The investigating machine has no GStreamer and no engine-host access, so the
experiment below was **not** executed here. It is the decisive one: it
reproduces the declared-but-unfed shape with `audiomixer` + `flvmux` alone.

```sh
# A) 1 fed branch + 3 declared-but-unfed branches  -> expect exit=124 (hang)
docker exec todd-studio timeout 14 gst-launch-1.0 -q \
  flvmux streamable=true name=mux ! rtmpsink location="rtmp://127.0.0.1:1935/live/DIAG_MISMATCH" sync=false \
  videotestsrc is-live=true num-buffers=200 ! videoconvert ! \
  x264enc tune=zerolatency speed-preset=ultrafast key-int-max=30 ! h264parse ! queue name=vq ! mux. \
  audiomixer name=mix ! audioconvert ! audioresample ! voaacenc bitrate=128000 ! aacparse ! queue name=aq ! mux. \
  audiotestsrc is-live=true num-buffers=200 ! audioconvert ! volume name=vol_commentary volume=1.0 ! mix. \
  appsrc name=audio_ambient is-live=false caps="application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000" \
    ! queue max-size-time=200000000 leaky=downstream ! rtpopusdepay ! opusdec ! audioconvert ! audioresample ! mix. \
  appsrc name=audio_sfx is-live=false caps="application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000" \
    ! queue max-size-time=200000000 leaky=downstream ! rtpopusdepay ! opusdec ! audioconvert ! audioresample ! mix. \
  appsrc name=audio_music is-live=false caps="application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000" \
    ! queue max-size-time=200000000 leaky=downstream ! rtpopusdepay ! opusdec ! audioconvert ! audioresample ! mix.
echo "exit=$?"

# B) same pipeline with only the one fed branch -> expect exit=0 and an SRS publish
```

Live-engine checks that discriminate between the two hypotheses:

```sh
docker logs --since 10m todd-studio | grep -aE \
  "audio bus produced no frames|forwarder pipeline error|not-negotiated|forwarder failed|forwarder running"

# Acceptance, after a fix is deployed:
curl -s -o /dev/null -w "%{http_code}\n" \
  "https://cricket.traceodd.com/hls/live/cricket_match_<MATCH_ID>_cam1.m3u8"   # expect 200
curl -s http://127.0.0.1:1985/api/v1/streams/ | grep -a "cricket_match_"        # stream must be listed
docker logs --since 2m todd-studio | grep -ac "audio bus produced no frames"    # expect 0
```

### 9.10 Proposed change (described, not implemented)

**Core — make the declared set equal to the fed set.**

1. Replace `build_description`'s `has_audio: bool` parameter with
   `live_buses: &[AudioBus]` (or the bus names collected in `live_audio`).
2. Replace `for bus in AudioBus::ALL { if bus_cfg.enabled { … } }` (L907–L909)
   with `for bus in live_buses { … }`. Volume/mute continue to come from
   `audio_cfg.bus(bus)`.
3. Delete the boolean concept: an empty `live_buses` **is** the video-only case.
   The `enabled` filter in `engine.rs` L1858 stays only as an early-out.

**Supporting changes:**

- Rewrite `audio_buses_appear_in_description` (L1173–L1204) so it asserts the
  description's `appsrc name=audio_*` set is **exactly** the live set. The
  current test would have to fail for the fix to be real.
- `rearm_stale_forwarders` (L2039–L2051) should preserve the target's real
  `audio`/`bitrate_kbps`/`keyframe_interval` instead of hardcoding defaults.
- `live_video_page.dart` should render `forwarder_error`, otherwise the next
  debugging cycle is just as blind.
- `CricketStreamSyncService::broadcasterCamera()` (L275–L277) should require
  `active == true` for the PGM camera too, not only `kind == 'whip'`.
- Remove the deleted `StreamController.php` from `.scripts/check-php-syntax.mjs`.

**Rejected alternative:** making the publisher not negotiate Opus. That is
source-side only and does not satisfy the standing requirement — *the pipeline
must be able to publish with zero audio branches, always*. The engine-side fix
is required either way; doing both is optional.

### 9.11 Secondary findings (conflicts, stale artefacts, database)

- **Studio's repeating `409`** on `/api/v1/whep/watch/{room}/Cam-03` is
  `engine.rs` L657–L675: the room has a **registered camera with no publisher**
  (`lowest_video_rid` is `None`). Room camera entries persist in the room store;
  `rooms.rs::rooms_with_liveness` (L131–L140) only recomputes the `active` flag,
  it never removes the entry — so the Studio tile retries forever. This is
  console noise, **not** the outage, but it is the same ghost-camera class as
  the Sep 11 split-screen.
- **`forwarder_error` is never rendered.** `live_video_page.dart` reads `_health`
  and prints `bridge: $state`, but the `forwarder_error` field is unused. That is
  why the operator sees `BROKEN` with no reason anywhere in the UI or console.
- **`rearm_stale_forwarders` loses the target's settings** (`bitrate_kbps: 0`,
  `keyframe_interval: 0`, `audio: Default::default()`, L2039–L2051). Harmless for
  H.264 passthrough, wrong for any re-encode path.
- **Stale references to the deleted camera registry:** `.scripts/check-php-syntax.mjs:17`
  (breaks the script), `.nginx/srs-cricket.conf` L135–L141, `.scripts/CDN-CONFIG.md`,
  `assets/cricket/HARDWARE_SETUP.md`, `assets/cricket/CRICKET_SYSTEM_ARCHITECTURE.md`.
  No functional effect; high confusion value for the next agent.
- **Dead realtime path:** Flutter still subscribes to `stream.updated`
  (`cricket_repository.dart` L542–L553) but the Laravel event that published it
  (`CricketStreamUpdated`) was deleted in 4.7. "Manager switches camera → viewers
  follow" is currently inert (initial playback is unaffected).
- **Database:** no duplicate or conflicting stream table. `cricket_streams` is
  created once (`2026_08_09_000001_…`) and dropped once
  (`2026_09_17_000001_drop_cricket_streams_table.php`);
  `2026_08_10_000002_create_cricket_v2_tables.php` does not recreate it. All
  surviving mentions are documentation, not schema.

### 9.12 What this section does *not* prove

1. The §9.9 A/B experiment has **not** been run here. The exact runtime mode
   (hang vs `not-negotiated (-4)`) is inferred from §3.5/§3.6, not re-measured.
2. How many Opus tracks the current broadcaster registers and feeds has not been
   observed directly. The reasoning needs `primed < 4`; that is a near-certain
   inference, not a measurement.
3. The proposed change has not been compiled (`--features gst`) or run.
4. No engine-host access in this pass — no live logs were read.

**Next step:** run §9.9 A on the server. If it returns `exit=124` with nothing in
SRS, the diagnosis is confirmed and §9.10 can be implemented — remembering §0.2:
an un-compiled `gst` push is not a fix.
