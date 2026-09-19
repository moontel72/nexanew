# FAULT REMEDIATION HISTORY — Media Engine (GStreamer / audio buses / Docker)

**Audience:** any agent (or human) picking up work on the NexaTrace media engine.
**Read this before touching `media-engine/crates/todd-transcode/`.**

This file is the history of one remediation cycle: an external agent (Qoder)
scanned the codebase and produced a fault report, a second agent implemented
fixes, and the first push **failed CI**. The mistakes are documented here on
purpose — they are more useful than the successes.

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
3. **The original reported problem is still unsolved.** See §7. None of the
   work below addresses "Todd-Studio stream not showing on the public page".
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

So: **the priming logic is not the bug.** To locate the real fault, gather
evidence before changing code:

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
