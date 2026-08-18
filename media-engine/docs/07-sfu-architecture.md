# 07 — SFU Architecture (Phase 2)

The crate decomposition, webrtc-rs upgrade, simulcast/PLI/NACK behavior
and the hardware acceleration matrix.

## 1. Crate decomposition

`todd-broadcaster` and `todd-studio` were replaced by three crates with
strict dependency edges:

| Crate | Role | Depends on |
|---|---|---|
| `todd-signaling` | Control plane: room store, auth, token minting, WHIP/WHEP HTTP signaling, media-plane abstraction. **Binary: `todd-studio`** | common, sfu, telemetry |
| `todd-sfu` | Media plane: webrtc-rs engines, simulcast track router, PLI broker, ICE policy, telemetry sampler. **Binary: `todd-broadcaster`** | common, telemetry, transcode |
| `todd-transcode` | GStreamer pipelines: HW encode matrix, zero-copy passthrough, multichannel audio mixer | common |
| `todd-common` | Auth, config, HTTP helpers, **media DTOs** (`EncoderKind`, `AudioBus`, mixer config) | — |
| `todd-cricket` | Cricket scoring math | — |
| `todd-telemetry` | Metrics registry, per-stream stats, diagnostics feed | — |

The deploy artifacts (`todd-studio` / `todd-broadcaster` binary names,
systemd units, compose service names) are unchanged — only the cargo
package names (`-p`) changed.

## 2. webrtc-rs 0.17 upgrade

The workspace pins `webrtc = "0.17"` (with matching `webrtc-ice` /
`webrtc-util` 0.17). Highlights used by the SFU:

- `TrackRemote::rid()` — simulcast layer id of each inbound track.
- `TrackLocalStaticRTP::new_with_rid` — the viewer's track carries the
  layer RID so simulcast-aware clients can switch layers later.
- Default interceptor set registers **NACK generator + responder**,
  RTCP sender/receiver reports and the **TWCC receiver** — end-to-end
  retransmission and congestion control without custom code.

## 3. Simulcast

- The WHIP offer's `a=simulcast:send` line is parsed; the layer order
  (first = lowest) is recorded on the router.
- Each layer arrives as its own `on_track` with a RID; streams are keyed
  `(room, camera, rid)`.
- WHEP viewers select a layer with `?rid=` (default: lowest live layer).
- Forwarders select the layer via `ForwardTarget.rid`.
- Live layer *switching* mid-call requires renegotiation — a Phase 3
  item (viewer re-POST today).

## 4. PLI forwarding

A shared `PliBroker` connects two custom RTCP interceptors:

- **Writer** (on the WHIP API): drains pending keyframe requests and
  sends them as PLI packets to the publisher.
- **Reader** (on the WHEP API): observes viewer PLIs and maps them (via
  the viewer-facing SSRC → publisher SSRC table) into pending requests.
- On viewer subscribe, the SFU requests a keyframe immediately — new
  viewers get an IDR instead of waiting for the keyframe interval.

## 5. Hardware acceleration matrix

`todd-transcode/src/hw.rs` plans the encoder stage; detection is runtime
(`gst::ElementFactory::find`):

| Preference | Elements | Notes |
|---|---|---|
| NVENC (NVIDIA) | `nvh264enc` | `rc-mode=cbr`, low-latency preset |
| AMF (AMD) | `amfh264enc` → `vah264enc` | VA-API fallback covers Intel too |
| QuickSync (Intel) | `qsvh264enc` → `vah264enc` | |
| x264 (software) | `x264enc` | Universal fallback |

`EncoderKind::Auto` probes NVENC → QuickSync → AMF → x264. Selection is
per-forwarder via `ForwardTarget.encoder`.

**Zero-copy passthrough:** H.264 sources reaching RTMP/SRT/file targets
skip decode+encode entirely (`depay → parse → mux`). No CPU/GPU cost, no
generation loss.

## 6. Multichannel audio buses

Four buses — `commentary`, `ambient`, `sfx`, `music` — routed by the
publisher's track RID (no RID = commentary). `ForwardTarget.audio`
carries per-bus enable/mute/volume (dB); the GStreamer pipeline builds
one `appsrc → opus decode → volume → audiomixer` branch per enabled bus
and muxes AAC into the output container.

## 7. Verification notes

- The `gst` feature (transcode pipelines, encoder detection) is
  compile-verified by CI on ubuntu-24.04 (`check-gst` job); this Windows
  dev box has no GStreamer toolchain. The pure-Rust matrix logic and
  pipeline-string construction are unit-tested locally.
- `webrtc` 0.20/0.21 exist but are a fresh re-architecture
  (sans-io/runtime split); 0.17 is the battle-tested API line.
