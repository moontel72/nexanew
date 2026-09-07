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

## 6. Constraints (unchanged)

- Do NOT weaken engine F1–F19 (PLI scope, SDP SSRC parsing, 409-not-live gate, etc.).
- Client-side codec preference is explicitly allowed by brief #2 suspect 2.
- Validate: Gradle `compileDebugKotlin` green; commit on `mainnew`; push (CI rebuilds
  and uploads the APK); then re-run section 4. Delete this file before the final commit.
