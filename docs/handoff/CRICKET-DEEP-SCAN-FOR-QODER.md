# DEEP SCAN REQUEST — Cricket panels & apps (for the Qoder expert agent)

**What I am asking you to do:** independently deep-scan the **Cricket-related panels and apps**,
find the **real fault** that keeps the public stream dark, and propose a **solution**. Do **not**
write code. Put your findings and your recommendation in a **new `.md` file** so the owner can
compare them with the working notes.

---

## 0. Ground rules

- **Read-only.** Do not change code, workflows, nginx, Dockerfiles or routes.
- **Cite `file:line` for every factual claim.** Where you are unsure, say so — a confident wrong
  claim has cost this project real time (see §4).
- Some generated/vendored files are hidden from search and read per `AGENTS.md`. If a file seems
  missing, `node .scripts/agent-ignored-files.mjs find <name>` locates it; do **not** run its
  `allow` subcommand without the owner's permission.
- **Challenge the notes below if they are wrong.** That is the point of this scan.

---

## 1. The symptom, in the owner's words

> Video from the broadcaster displays in Todd Studio. The whole problem is stuck in the Cricket
> Manager panel — it has been for the last 10 days. Only when it clears from there can the
> stream work on the public screen.

Concretely:

| Where | State |
|---|---|
| Todd Studio (broadcaster preview) | **Video displays.** Broadcaster → SFU ingest works |
| Cricket Manager → Live Video | `BROKEN — the bridge failed`, step 2 `Engine → SRS bridge: Not running (failed)` |
| Public page `https://cricket.traceodd.com/` | Offline; the HLS playlist 404s |
| SRS | `curl http://127.0.0.1:1985/api/v1/streams/` → `"streams":[]` |
| `/var/www/traceodd/cricket-hls/live/` | **empty** |

So the RTMP publish **never reaches SRS**. The fault is upstream of HLS.

---

## 2. The engine's own error (primary evidence)

Captured from the operator's browser, then from `docker logs`, identical every 5 seconds:

```
/GstPipeline:pipeline446/GstAppSrc:audio_commentary: Internal data stream error
(debug: ../libs/gst/base/gstbasesrc.c(3177): gst_base_src_loop ():
 /GstPipeline:pipeline446/GstAppSrc:audio_commentary:
 streaming stopped, reason not-negotiated (-4))
```

Timing, from the engine log:

```
21:29:49.257173 INFO  forwarder started kind=Rtmp url=rtmp://135.181.46.27:1935/live/cricket_match_..._cam1
21:29:49.257240 INFO  forwarder running
21:29:49.257673 ERROR forwarder pipeline error ... audio_commentary: not-negotiated (-4)
```

**0.4 ms after `forwarder running`.** `pipeline446`, `447`, `448` … `pipeline464` — a new pipeline
number every 5 seconds, each dying immediately. The forwarder watchdog (`rearm_stale_forwarders`)
rebuilds it forever; it never survives.

---

## 3. The exact pipeline (captured via a diagnostic added on 2026-09-21)

```
appsrc name=video_src format=time is-live=true do-timestamp=true
  caps="application/x-rtp,media=video,encoding-name=H264,clock-rate=90000"
  ! rtph264depay ! h264parse ! queue name=vq max-size-time=1000000000 ! mux.

audiomixer name=mix ! audioconvert ! audioresample ! voaacenc bitrate=128000 ! aacparse
  ! queue name=aq max-size-time=1000000000 ! mux.

appsrc name=audio_commentary format=time do-timestamp=true is-live=false
  caps="application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000"
  ! queue max-size-time=200000000 leaky=downstream
  ! rtpopusdepay ! opusdec ! audioconvert ! audioresample
  ! volume name=vol_commentary volume=1.000000 ! mix.

flvmux streamable=true name=mux
  ! rtmpsink location="rtmp://135.181.46.27:1935/live/cricket_match_a2c0880f-..._cam1" sync=false
```

Built by `media-engine/crates/todd-transcode/src/forwarder.rs::build_description`.

### What is already ruled out (with evidence)

| Ruled out | How |
|---|---|
| Wrong caps string | an isolated `gst-launch` of the audio branch negotiated `application/x-rtp, media=(string)audio, encoding-name=(string)OPUS, clock-rate=(int)48000` **successfully** |
| Missing element | every element exists in the runtime image; no `no element` error |
| Declared-but-unfed branch | `audio_commentary` exists ⇒ it primed ⇒ it is fed. Fixed in `f0fc72e5` |
| Wrong codec on the audio branch | fixed in `e951903b`; the filter is deployed and firing (see §4) |

### The one structural difference that remains

The failing pipeline declares `audiomixer name=mix` **plus its output chain** in an earlier,
separate statement, and only then links the commentary branch into it with the **delayed link**
`! mix.`. The isolated test that negotiated fine declared the mixer **inline** at the end of the
chain (`! audiomixer name=mix ! ...`).

So the mixer's **output** is linked before its **first sink pad** exists. If `voaacenc` fixates the
mixer's output caps during the state change while the mixer has zero sink pads, adding the
commentary sink pad afterwards must renegotiate — and a failure there surfaces as
`NOT_NEGOTIATED` on the element that pushed, i.e. `GstAppSrc:audio_commentary`.

**This is a hypothesis, not a conclusion.** Three inferences in this cycle have already been wrong.

---

## 4. Two earlier faults on the same code path (fixed) — read to avoid repeating them

| Fault | Fix | Evidence it was real |
|---|---|---|
| `build_description` declared an audio branch for every **enabled** bus while only **primed** buses were fed | `f0fc72e5` — derives both from the same `live_buses` | error text changed; outage continued |
| The audio path never checked the **codec** it pushed, so a video chunk reached an `appsrc` whose caps say OPUS | `e951903b` — `VIDEO_CODECS` / `AUDIO_CODECS`, Opus-only priming, codec enforcement in `push_task` | the filter warning fires in production: `dropping chunk whose codec this branch cannot carry` |

**And a third, still open:** the audio branch fails caps negotiation at pipeline start.

### A live finding worth your attention

The codec filter log proves the **SFU router cross-delivers media types on both subscriptions**:

```
WARN dropping chunk whose codec this branch cannot carry;
     the router fan-out delivered a different media type
     appsrc=video_src codec=Opus expected=[H264, Vp8, Vp9]
```

The **video** appsrc received an **Opus** chunk. So rid-scoped fan-out is delivering both media
types on both receivers. The forwarder's filters contain the damage, but **the router is the real
place to fix it.** Please assess whether this is the root of the outage or an independent defect.

---

## 5. Process lessons that must shape your scan (this is not filler)

1. **Two timing-based inferences in a row were wrong.** Container timestamps suggested the CI
   pipeline was blocked; the operator confirmed both runs were green. **Ask for the fact rather
   than inferring it** — and prefer reading what the system already prints.
2. **A deployed fix is not a finished fix.** `f0fc72e5` was correct, compiled, tested, green in CI,
   deployed — and the outage continued, because a second fault sat on the same path.
3. **The failing UI is instrumentation.** The decisive evidence came from a photograph of the
   operator's browser, not from a log anyone had pulled.
4. **A green `cargo check --workspace` proves nothing about these files.**
   `forwarder.rs`, `mixer_gst.rs` and `audio.rs` are behind `#[cfg(feature = "gst")]`. The CI
   command is `cargo check -p todd-signaling -p todd-sfu --features gst`.

---

## 6. The client-side bug (separate, but reproduce it)

`Cricket Manager → back to dashboard` throws:

```
main.dart.20260920130554.js:36255 Null check operator used on a null value
```

The operator isolated it precisely: it fires **only when navigating back to the dashboard**, and
it reproduced **at the same point in two different browsers**. Treat that as a reliable repro.

`lib/features/cricket/presentation/pages/manager/live_video_page.dart` was inspected. Its new
error-banner code is null-safe, but the file mixes styles — line 171 uses
`_health?['rtmp_url']` while line 174 uses `_health!['rtmp_url']`. The guard on 171 makes 174
unreachable-when-null today, so it is a smell rather than a proven cause. **Find the actual
throw site** — a source-map build or a local repro should pin it quickly.

Also seen in the console and **benign** (confirm if you disagree): `WebSocket ... failed: Page
entered Back-Forward Cache` is Chrome's BF-cache notice, and `reverb read failed: Connection reset
by peer` is the engine reconnecting after a page navigation.

---

## 7. Where to look, and what to deliver

Reproduce the failure faithfully — the branch shape, the **ordering**, and a real buffer — then
bisect the ordering. A suggested starting point is in
`docs/handoff/FAULT-REMEDIATION-HISTORY.md` §10.10, but form your own.

**Deliverable:** a new file, e.g. `docs/handoff/QODER-CRICKET-DEEP-SCAN-<date>.md`:

1. **The root fault**, with `file:line` evidence for why the audio branch fails to negotiate at
   pipeline start (or why it is something else entirely).
2. **The full chain audit** — broadcaster → SFU → forwarder → SRS → HLS → public page — listing
   every place a failure can become silent again.
3. **A concrete solution**, with tradeoffs, and whether the router's cross-delivery must be fixed
   first or is independent.
4. **A verification procedure that does not require the operator to guess** — ideally a synthetic
   publisher through the real forwarder path asserting the HLS playlist returns `200`.
5. **The client-side `Null check operator`** throw site.
6. **Anything the notes above got wrong.**

**The notes are the current best understanding, not ground truth. Challenge them.**
