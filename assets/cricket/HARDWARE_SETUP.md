# ═══════════════════════════════════════════════════════════
# NEXATRACE CRICKET — HARDWARE SETUP & PRODUCTION GUIDE
# ═══════════════════════════════════════════════════════════
# Target: Valley Soon Cricket Tournament 2026
# Scale: 10 Teams | 20,000 Concurrent Viewers | 5 Cameras
# ═══════════════════════════════════════════════════════════

---

## TABLE OF CONTENTS

1. [Hybrid Production Architecture (Three Modes)](#1-hybrid-production-architecture-three-modes)
   - [1.1 Mode Selector: Which Mode Should You Use?](#11-mode-selector-which-mode-should-you-use)
   - [1.2 Mode A — Hybrid DSLR + Mobile (Recommended)](#12-mode-a--hybrid-dslr--mobile-recommended)
   - [1.3 Mode B — Pure Smartphone Network (Zero Hardware Cost)](#13-mode-b--pure-smartphone-network-zero-hardware-cost)
   - [1.4 Mode C — Full Professional (Hardware Switcher)](#14-mode-c--full-professional-hardware-switcher)
   - [1.5 Camera Placement Plan (All Modes)](#15-camera-placement-plan-all-modes)
   - [1.6 Power & Weather Protection](#16-power--weather-protection)
2. [OBS Studio & RTMP Push Configuration](#2-obs-studio--rtmp-push-configuration)
3. [Final System Handover & Pre-Live Checklist](#3-final-system-handover--pre-live-checklist)
4. [Troubleshooting Quick Reference](#4-troubleshooting-quick-reference)
5. [Mode Switching Reference Card](#5-mode-switching-reference-card)

---

## 1. HYBRID PRODUCTION ARCHITECTURE (THREE MODES)

This system supports **any combination** of professional cameras and smartphones. Choose the mode that matches your available equipment on match day. You can switch modes between matches with zero code changes — only OBS sources change.

### 1.1 Mode Selector: Which Mode Should You Use?

| Mode | Equipment Needed | Cost | Latency | Quality | Best For |
|------|-----------------|------|---------|---------|----------|
| **Mode A — Hybrid** | 1-2 DSLRs + 3-4 smartphones | ~$100 (capture cards) | Low | High | Most tournaments — balances quality and cost |
| **Mode B — Pure Smartphone** | 3-5 smartphones (existing) | $0 | Medium | Good | Zero-budget events, quick setup, remote venues |
| **Mode C — Full Professional** | 5 camcorders + ATEM switcher | ~$800+ | Ultra-Low | Excellent | Sponsored tournaments, broadcast-grade production |

```
┌─────────────────────────────────────────────────────────────┐
│                    DECISION FLOWCHART                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Do you have a Blackmagic ATEM or similar hardware          │
│  switcher on-site?                                          │
│       │                                                      │
│       ├── YES ──► Use MODE C (Full Professional)            │
│       │                                                      │
│       └── NO ──► Do you have at least 1 DSLR/camcorder     │
│                  with clean HDMI output?                     │
│                      │                                       │
│                      ├── YES ──► Use MODE A (Hybrid)        │
│                      │                                 │
│                      └── NO ──► Use MODE B (Pure Smartphone) │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

### 1.2 Mode A — Hybrid DSLR + Mobile (Recommended)

**Concept:** Use 1-2 professional DSLRs/camcorders for main pitch coverage (wired via HDMI capture cards to OBS). Fill boundary/angle positions with smartphones streaming wirelessly via Larix Broadcaster. All sources converge in a single OBS instance.

#### 1.2.1 Signal Flow Diagram

```
                     ┌────────────────────────────────────┐
    WIRED (Pitch)    │            OBS LAPTOP              │
                     │                                    │
  DSLR 1 ──HDMI──►   │  ┌─ HDMI Capture Dongle ──► CAM 1 │
  (Main Wide)   │    │  │  (Elgato Cam Link / MiraBox)    │
                │    │  └─────────────────────────────────│
  DSLR 2 ──HDMI──►   │  ┌─ HDMI Capture Dongle ──► CAM 2 │
  (Long-Off)   │    │  │  (Elgato Cam Link / MiraBox)    │
                │    │  └─────────────────────────────────│
                     │                                    │
    WIRELESS         │  ┌─ Media Source ──► CAM 3        │
    (Boundary)       │  │  (Larix Broadcaster stream)    │
                     │  ├─────────────────────────────────│
  Phone 3 ──WiFi──►  │  ├─ Media Source ──► CAM 4        │
  (Mid-Wicket)  │    │  │  (Larix Broadcaster stream)    │
                │    │  ├─────────────────────────────────│
  Phone 4 ──WiFi──►  │  ├─ Media Source ──► CAM 5        │
  (Square Leg)  │    │  │  (Larix Broadcaster stream)    │
                │    │  └─────────────────────────────────│
  Phone 5 ──WiFi──►  │                                    │
  (Boundary)    │    │  RTMP Output ──► Hetzner SRS       │
                     └────────────────────────────────────┘
```

#### 1.2.2 Wired DSLR/Camcorder Setup (CAM 1-2)

| Item | Qty | Model (Budget) | Model (Pro) |
|------|-----|---------------|-------------|
| DSLR / Camcorder | 2 | Canon EOS 200D / Sony a6000 | Canon XA55 / Sony Z150 |
| HDMI cable (10m) | 2 | AmazonBasics High-Speed | BlueRigger 4K |
| HDMI capture dongle | 2 | MiraBox HSV321 ($25) | Elgato Cam Link 4K ($100) |
| Tripod (fluid head) | 2 | AmazonBasics 60" | Manfrotto 502AH |
| AC power adapter | 2 | Third-party dummy battery | OEM AC adapter |

**DSLR Clean HDMI Setup Steps:**

1. Mount DSLR on tripod. Connect HDMI cable to camera HDMI-out port.
2. Connect HDMI capture dongle to other end of HDMI cable.
3. Plug capture dongle USB into OBS laptop.
4. **CRITICAL: Enable Clean HDMI Output:**
   - Sony: Menu → Setup → HDMI Settings → HDMI Info. Display → OFF
   - Canon: Menu → HDMI Display → Mirroring → Disable overlays
   - Panasonic: Menu → HDMI Output → Info Display → OFF
5. Set camera to **Manual (M) mode**. Configure:
   - Shutter: 1/60 (for 30fps) or 1/120 (for 60fps)
   - Aperture: f/5.6-f/8 (daylight) | f/2.8-f/4 (overcast)
   - ISO: Auto (capped at 3200)
   - White Balance: 5600K (daylight preset)
6. **Disable auto-power-off:** Set camera sleep timer to "Off" or "30 min".
7. In OBS: Add → Video Capture Device → Select "USB Video" device → Name it "CAM 1 — Main Wide".

#### 1.2.3 Wireless Smartphone Setup via Larix Broadcaster (CAM 3-5)

**Larix Broadcaster** is a free Android/iOS app that turns any smartphone into a wireless RTMP/SRT camera feed visible as a network source in OBS.

**Step 1: Install Larix Broadcaster on each phone**

```
Android: Google Play Store → Search "Larix Broadcaster" → Install
iOS:     App Store → Search "Larix Broadcaster" → Install
```

**Step 2: Configure Larix on each phone**

```
1. Open Larix Broadcaster
2. Tap gear icon (Settings) → Connections → + New Connection
3. Configure:
   - Name:   CAM 3 — Mid-Wicket  (unique per phone)
   - URL:    rtmp://192.168.1.XXX:1935/live/cam3_midwicket
             ^^^^^^^^^^^^^^^^ OBS laptop's local IP address
   - Mode:   Audio + Video
   - Target: RTMP
4. Go back → Video Settings:
   - Resolution: 1280x720
   - Bitrate:    2500 Kbps
   - FPS:        30
   - Camera:     Rear (wide)
5. Go back → Audio Settings:
   - Bitrate: 96 Kbps (or mute if no commentary needed)
6. Return to main screen. You should see camera preview.
```

**Step 3: Set up local RTMP server on OBS laptop (nginx-rtmp or MediaMTX)**

Since smartphones stream over local WiFi to the OBS laptop, you need a lightweight RTMP receiver running on the laptop itself. The simplest option is **MediaMTX** (single binary, 10 MB):

```bash
# On the OBS laptop (Windows/Mac/Linux):
# Download MediaMTX: https://github.com/bluenviron/mediamtx/releases

# Windows (PowerShell, Run as Administrator):
.\mediamtx.exe
# Starts RTMP server on port 1935, with built-in HLS on port 8888

# Verify it's running:
# Open browser → http://localhost:8888 → Should show MediaMTX dashboard
```

**Alternative: Use SRS directly on Hetzner** (if local WiFi bandwidth to internet is good):

```
# Phone Larix → directly to Hetzner SRS (bypass local RTMP server):
URL: rtmp://cricket.traceodd.com:1935/live/cam3_midwicket
# Then in OBS: Add → Media Source →
# Input: https://cricket.traceodd.com/hls/live/cam3_midwicket.m3u8
# (This pulls the HLS from SRS back into OBS — slight delay but simpler)
```

**Step 4: Add Larix streams as OBS sources**

```
In OBS Studio:
1. Add → Media Source → Create new → Name "CAM 3 — Mid-Wicket"
2. Uncheck "Local File"
3. Input: rtmp://localhost:1935/live/cam3_midwicket
   (Or if using direct-to-SRS: https://cricket.traceodd.com/hls/live/cam3_midwicket.m3u8)
4. Input Format: rtmp (or hls for direct-to-SRS)
5. Check "Restart playback when source becomes active"
6. Network Buffering: 2 MB
7. OK
8. Repeat for CAM 4 (cam4_squareleg) and CAM 5 (cam5_boundary)
```

#### 1.2.4 Hybrid Scene Layout in OBS

Your OBS Sources panel will look like this (all sources coexist in the same scene):

```
OBS SOURCES (Scene: CAM 1 — Main Wide)
├── [Image]     Sponsor Banner
├── [Text]      Score Overlay
├── [Image]     Team A Logo
├── [Image]     Team B Logo
├── [Video Capture]  CAM 1 — Main Wide     ← Wired DSLR via HDMI dongle
│
├── (Hidden in this scene, used in other scenes)
│   ├── [Video Capture]  CAM 2 — Long-Off    ← Wired DSLR via HDMI dongle
│   ├── [Media Source]   CAM 3 — Mid-Wicket  ← Smartphone via Larix RTMP
│   ├── [Media Source]   CAM 4 — Square Leg  ← Smartphone via Larix RTMP
│   └── [Media Source]   CAM 5 — Boundary    ← Smartphone via Larix RTMP
```

> **IMPORTANT:** Wired sources (HDMI dongles) appear as "Video Capture Device". Wireless smartphone sources appear as "Media Source". Both work interchangeably in OBS scenes. The production director switches between them using the same Numpad 1-5 hotkeys regardless of source type.

#### 1.2.5 Mode A Equipment Checklist

| Category | Item | Check |
|----------|------|-------|
| **Wired** | DSLR 1 (Main Wide) — HDMI clean output verified | ☐ |
| **Wired** | DSLR 2 (Long-Off) — HDMI clean output verified | ☐ |
| **Wired** | 2× HDMI capture dongles recognized in OBS | ☐ |
| **Wireless** | Phone 3 (Mid-Wicket) — Larix installed + configured | ☐ |
| **Wireless** | Phone 4 (Square Leg) — Larix installed + configured | ☐ |
| **Wireless** | Phone 5 (Boundary) — Larix installed + configured | ☐ |
| **Network** | Local RTMP server (MediaMTX) running on OBS laptop | ☐ |
| **Network** | All phones on same WiFi as laptop (or strong 4G to Hetzner) | ☐ |
| **OBS** | All 5 sources previewing with picture | ☐ |

---

### 1.3 Mode B — Pure Smartphone Network (Zero Hardware Cost)

**Concept:** 100% mobile-phone production. Use 3-5 existing smartphones streaming via Larix Broadcaster directly to Hetzner SRS. OBS on a laptop pulls all HLS streams back in for scene switching, then pushes a single composited RTMP output.

```
┌──────────────────────────────────────────────────────────┐
│                     PURE MOBILE SETUP                     │
│                                                           │
│  Phone 1 (Main Wide)  ──Larix RTMP──►                    │
│  Phone 2 (Long-Off)   ──Larix RTMP──►                    │
│  Phone 3 (Mid-Wicket) ──Larix RTMP──┼──► Hetzner SRS     │
│  Phone 4 (Square Leg) ──Larix RTMP──┤   (Port 1935)      │
│  Phone 5 (Boundary)   ──Larix RTMP──►       │            │
│                                              │ HLS        │
│                                              ▼            │
│                                     OBS Laptop pulls      │
│                                     all 5 HLS streams     │
│                                     as Media Sources      │
│                                              │            │
│                                              ▼            │
│                                     OBS composites +      │
│                                     pushes RTMP output    │
│                                     to SRS stream_main    │
└──────────────────────────────────────────────────────────┘
```

#### 1.3.1 Mode B Larix Configuration (Direct-to-SRS)

Each phone pushes directly to Hetzner SRS using its own stream key. No local server needed.

```
Phone 1 (Main Wide):
  URL: rtmp://cricket.traceodd.com:1935/live/mobile_cam1_main

Phone 2 (Long-Off):
  URL: rtmp://cricket.traceodd.com:1935/live/mobile_cam2_longoff

Phone 3 (Mid-Wicket):
  URL: rtmp://cricket.traceodd.com:1935/live/mobile_cam3_midwicket

Phone 4 (Square Leg):
  URL: rtmp://cricket.traceodd.com:1935/live/mobile_cam4_square

Phone 5 (Boundary):
  URL: rtmp://cricket.traceodd.com:1935/live/mobile_cam5_boundary
```

**Larix Settings (each phone):**
```
Video Resolution: 1280x720
Video Bitrate:    2000 Kbps  (lower than wired — mobile encoders are less efficient)
FPS:              25  (reduce frame rate to save bandwidth)
Audio:            Muted (optional — prevents echo from multiple phones)
Camera:           Rear wide
Stabilization:    ON (if available)
```

#### 1.3.2 Mode B OBS Source Configuration

All camera sources are HLS pull streams from SRS:

```
In OBS, add each phone as a Media Source:

Source Name:     CAM 1 — Main Wide
Input:           https://cricket.traceodd.com/hls/live/mobile_cam1_main.m3u8
Input Format:    hls
Network Buffering: 3 MB  (higher for mobile networks)
Reconnect Delay:  2 seconds

Source Name:     CAM 2 — Long-Off
Input:           https://cricket.traceodd.com/hls/live/mobile_cam2_longoff.m3u8
...

(Repeat for CAM 3, 4, 5)
```

> **Latency Note (Mode B):** Each phone → SRS → OBS pull adds ~6-10 seconds delay vs real-time. This is acceptable for cricket broadcasts (not real-time scoring). The score overlay in OBS should also be delayed to match, or the Cricket Manager should update scores slightly ahead of the stream.

#### 1.3.3 Mode B Equipment Checklist

| Category | Item | Check |
|----------|------|-------|
| **Phones** | Phone 1 — Larix configured, battery > 80%, airplane mode OFF | ☐ |
| **Phones** | Phone 2 — Larix configured, battery > 80% | ☐ |
| **Phones** | Phone 3 — Larix configured, battery > 80% | ☐ |
| **Phones** | Phone 4 — Larix configured, battery > 80% | ☐ |
| **Phones** | Phone 5 — Larix configured, battery > 80% | ☐ |
| **Network** | Each phone: 4G signal strength > 3 bars | ☐ |
| **Network** | OBS laptop: stable internet (Ethernet preferred) | ☐ |
| **Power** | Power banks connected to each phone (streaming drains battery fast) | ☐ |
| **Mount** | Phone tripod mounts (universal clamp + mini tripod) for each phone | ☐ |
| **OBS** | All 5 HLS Media Sources previewing with picture | ☐ |
| **SRS** | Verify all 5 mobile streams active: `tail -20 /var/log/srs-cricket.log` | ☐ |

---

### 1.4 Mode C — Full Professional (Hardware Switcher)

**Concept:** The original professional setup using 5 camcorders/DSLRs → Blackmagic ATEM Mini Pro hardware switcher → OBS laptop.

#### 1.4.1 Signal Flow (Mode C)

```
Camera 1 ──HDMI──┐
Camera 2 ──HDMI──┤
Camera 3 ──HDMI──┼──► Blackmagic ATEM Mini Pro ──USB-C──► OBS Laptop
Camera 4 ──HDMI──┤       (or ATEM Mini Extreme ISO)
Camera 5 ──HDMI──┘
                     ┌─────────────────────────────┐
                     │ ATEM Software Control Panel │
                     │ (Multi-view monitoring on   │
                     │  separate HDMI monitor)      │
                     └─────────────────────────────┘
```

#### 1.4.2 Recommended Professional Camera Models

| Camera | Output Type | Resolution | Low-Light | Notes |
|--------|------------|------------|-----------|-------|
| **Sony NX100** | HDMI (Clean) | 1080p60 | Excellent | AVCHD + XAVC-S; 12x optical zoom |
| **Sony Z150** | HDMI + SDI | 4K UHD | Excellent | 1" sensor; built-in ND filters |
| **Panasonic UX180** | HDMI + SDI | 4K UHD | Very Good | 20x optical zoom; dual SD card |
| **Canon XA55** | HDMI (Clean) | 4K UHD | Excellent | Dual Pixel AF; compact form factor |
| **Canon XA40** | HDMI (Clean) | 4K UHD | Very Good | Budget-friendly; 20x optical zoom |

> **Critical: CLEAN HDMI Output.** Every camera MUST be configured to output **clean HDMI** (no on-screen overlays, focus boxes, battery indicators). This is configured in each camera's menu under `HDMI Output Settings → Clean Output = ON`.

#### 1.4.3 ATEM Setup Steps

1. Connect all 5 camera HDMI outputs to ATEM HDMI inputs 1-5.
2. Connect HDMI monitor to ATEM "HDMI Out" for multi-view preview.
3. Connect ATEM USB-C to OBS laptop — appears as a single webcam source.
4. Install Blackmagic ATEM Software Control on the OBS laptop.
5. In OBS, add "Blackmagic Device" as Video Capture Device source.
6. Use ATEM Software Control panel for live camera switching (hardware-cut — zero latency).

#### 1.4.4 Mode C Equipment Checklist

| Item | Qty | Model | Est. Cost |
|------|-----|-------|-----------|
| HDMI Switcher | 1 | Blackmagic ATEM Mini Pro | $295 |
| HDMI Cables (15m) | 5 | AmazonBasics / Cable Matters | $15/ea |
| HDMI Monitor | 1 | Any 15-22" with HDMI input | $80 |
| USB-C Cable | 1 | Included with ATEM | $0 |
| Tripods (fluid head) | 5 | Manfrotto / Benro | $80/ea |

#### 1.4.5 USB Capture Dongle Alternative (Mode C Lite)

If the ATEM switcher is unavailable but you have 5 DSLRs/camcorders, use individual HDMI-to-USB dongles per camera:

```
Camera 1 ──HDMI──► HDMI-to-USB Dongle ──USB──┐
Camera 2 ──HDMI──► HDMI-to-USB Dongle ──USB──┤
Camera 3 ──HDMI──► HDMI-to-USB Dongle ──USB──┼──► OBS Laptop
Camera 4 ──HDMI──► HDMI-to-USB Dongle ──USB──┤   (powered USB hub)
Camera 5 ──HDMI──► HDMI-to-USB Dongle ──USB──┘
```

| Item | Qty | Model | Est. Cost |
|------|-----|-------|-----------|
| HDMI Capture Dongle | 5 | Elgato Cam Link 4K / MiraBox | $100/ea |
| Powered USB 3.0 Hub | 1 | Anker 10-port 60W | $40 |

> **Trade-off:** Software switching in OBS adds ~200-400ms latency vs hardware ATEM. Acceptable for cricket broadcast.

---

### 1.5 Camera Placement Plan (All Modes)

```
                        ┌──────────────────────────────┐
                        │        CRICKET GROUND         │
                        │                                │
         CAM 3          │    ┌──────────────────┐       │          CAM 4
    (Mid-Wicket)  ◄─────┼────│    PITCH / WICKET  │──────┼──► (Square Leg)
                        │    └──────────────────┘       │
                        │                                │
         CAM 2          │         ▲  CAM 1              │          CAM 5
     (Long-Off)   ◄─────┼─────────┘  (Main Wide)        │──►  (Fine Leg /
                        │                                │      Boundary Cam)
                        └──────────────────────────────┘
                                      │
                                      ▼
                           PRODUCTION TENT
                    ┌─────────────────────────┐
                    │   OBS STUDIO LAPTOP     │
                    │   (Primary)             │
                    │   RTMP → Hetzner SRS    │
                    └─────────────────────────┘
```

| Camera # | Label | Position | Recommended Source | Lens/View | Purpose |
|----------|-------|----------|-------------------|-----------|---------|
| **CAM 1** | Main Wide | Elevated straight (press box / scaffold) | DSLR / Camcorder | 12-24x zoom | Master wide shot; follow ball trajectory |
| **CAM 2** | Long-Off | Behind bowler's arm, straight boundary | DSLR / Camcorder | 12-20x zoom | Bowler run-up + batsman front view |
| **CAM 3** | Mid-Wicket | Side-on, square boundary | Smartphone | Wide (1x) | Batsman side profile; run between wickets |
| **CAM 4** | Square Leg | Opposite side, square boundary | Smartphone | Wide (1x) | Alternative angle; LBW appeals |
| **CAM 5** | Boundary Cam | Roaming / fixed at fine leg | Smartphone | Wide (1x) | Crowd reactions; boundary catches |

> **Pro Tip:** Place wired cameras (DSLRs) at CAM 1 and CAM 2 — the two most-used angles. Place smartphones at boundary positions (CAM 3-5) where wireless freedom eliminates long cable runs.

---

### 1.6 Power & Weather Protection

- **DSLR Batteries:** Each camera needs 2× fully charged batteries (1 active + 1 spare per innings break swap).
- **Smartphone Power Banks:** 20,000 mAh power bank per phone (Larix streaming drains ~15-20% battery per hour). Connect via USB cable during entire match.
- **Power Strip:** Heavy-duty extension cord to production tent with surge protector.
- **Tripod Sandbags:** 5 kg per tripod (all cameras — phone tripods are lighter and more wind-prone).
- **Rain Covers:** Camera rain covers (Op/Tech Rainsleeve or similar) — $8/ea. For phones: zip-lock bag with lens hole cut out.
- **Laptop Power:** Both primary + backup laptops plugged in. Laptop battery as UPS.
- **Phone Cooling:** Direct sunlight + streaming = overheating. Shade phones with small umbrella or cardboard hood. If phone displays "Temperature warning", pause streaming for 2 minutes.

---

## 2. OBS STUDIO & RTMP PUSH CONFIGURATION

### 2.1 Primary OBS Laptop Specs

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | Intel i5 10th gen / AMD Ryzen 5 | Intel i7 12th gen / Ryzen 7 |
| RAM | 16 GB | 32 GB |
| GPU | GTX 1650 | RTX 3060 or better |
| Storage | 256 GB SSD | 512 GB NVMe SSD |
| OS | Windows 10 / macOS 12+ | Windows 11 |
| Network | Gigabit Ethernet | Dedicated 4G/5G hotspot as backup |
| USB Ports | 4× USB 3.0 | 6× USB 3.0 (or USB hub) |

### 2.2 OBS Installation & First Setup

```bash
# Download OBS Studio
https://obsproject.com/download

# Install with default settings. Launch OBS.

# Auto-Configuration Wizard (first launch):
#   → Select "Optimize for streaming, recording is secondary"
#   → Base Resolution: 1920x1080
#   → FPS: 30 (or 60 if bandwidth permits)
#   → Service: Custom → Server: rtmp://cricket.traceodd.com/live
#   → Stream Key: stream_main  (from cricket_streams table)
```

### 2.3 OBS Scenes Configuration

Create the following scenes in OBS (bottom-left panel → + → Create Scene):

#### Scene 1: CAM 1 — Full Screen (Main Wide)

```
┌──────────────────────────────────────────┐
│                                          │
│          CAMERA 1 — MAIN WIDE            │
│          (Blackmagic Device Source)       │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  SPONSOR BANNER (Image Overlay)    │  │
│  └────────────────────────────────────┘  │
│  ┌──────────────┐  ┌──────────────────┐  │
│  │  Team A Logo │  │  Score Overlay    │  │
│  └──────────────┘  └──────────────────┘  │
└──────────────────────────────────────────┘
```

**Sources (in order, top-to-bottom):**
| Layer | Type | Source |
|-------|------|--------|
| 5 | Image | Sponsor banner (PNG, 1920×100, top-aligned) |
| 4 | Text (GDI+) | Live score overlay (reads from text file updated by score bot) |
| 3 | Image | Team A logo (bottom-left, 120×120) |
| 2 | Image | Team B logo (bottom-right, 120×120) |
| 1 | Video Capture Device | Blackmagic ATEM / HDMI Capture Dongle CAM 1 |

#### Scene 2: CAM 2 — Long-Off (Bowler View)

Same layer structure as Scene 1, but Video Capture = CAM 2 source.

#### Scene 3: CAM 3 — Mid-Wicket (Side Profile)

Same layer structure, Video Capture = CAM 3 source.

#### Scene 4: CAM 4 — Square Leg

Same layer structure, Video Capture = CAM 4 source.

#### Scene 5: CAM 5 — Boundary / Crowd

Same layer structure, Video Capture = CAM 5 source.

#### Scene 6: SPLIT SCREEN — 50/50

```
┌────────────────────┬────────────────────┐
│                    │                    │
│    CAM 1 — MAIN    │    CAM 2 — LONG    │
│    (50% width)     │    OFF (50%)       │
│                    │                    │
│    Bowler running  │    Batsman front   │
│    in + ball       │    on + shot       │
│                    │                    │
├────────────────────┴────────────────────┤
│          SPONSOR BANNER BAR             │
└─────────────────────────────────────────┘
```

**Sources:**
| Layer | Type | Source |
|-------|------|--------|
| 3 | Image | Sponsor banner |
| 2 | Video Capture Device | CAM 2 — Cropped to left 960×1080, positioned (0, 0) |
| 1 | Video Capture Device | CAM 1 — Cropped to right 960×1080, positioned (960, 0) |

> **Cropping in OBS:** Right-click source → Transform → Edit Transform → Crop Left/Right to 960px. Position X=0 for left source, X=960 for right source.

#### Scene 7: PICTURE-IN-PICTURE (PiP) — Main + Bowler Corner

```
┌──────────────────────────────────────────┐
│          CAM 1 — MAIN WIDE (full)        │
│                              ┌──────────┐│
│                              │  CAM 2   ││
│                              │  320×180 ││
│                              └──────────┘│
├──────────────────────────────────────────┤
│          SPONSOR BANNER BAR              │
└──────────────────────────────────────────┘
```

**Sources:**
| Layer | Type | Source |
|-------|------|--------|
| 3 | Image | Sponsor banner |
| 2 | Video Capture Device | CAM 2 — Scaled to 320×180, positioned bottom-right corner |
| 1 | Video Capture Device | CAM 1 — Full screen |

#### Scene 8: GRAPHICS — Scorecard Full Screen (Innings Break)

```
┌──────────────────────────────────────────┐
│                                          │
│         INNINGS BREAK                    │
│                                          │
│     ┌──────────────────────────┐        │
│     │  BATTING SCORECARD       │        │
│     │  Batsman A   45 (32)     │        │
│     │  Batsman B   12 (18)     │        │
│     │  ...                     │        │
│     └──────────────────────────┘        │
│                                          │
│     ┌──────────────────────────┐        │
│     │  BOWLING SCORECARD       │        │
│     │  Bowler X   4-0-22-1     │        │
│     │  ...                     │        │
│     └──────────────────────────┘        │
│                                          │
│         SPONSORS ROW                    │
└──────────────────────────────────────────┘
```

Source: Browser source pointed at cricket.traceodd.com/scorecard-overlay/{match_id} (a dedicated Flutter web page showing full scorecard).

### 2.4 OBS Stream Output Settings

```
File → Settings → Stream

Service:          Custom...
Server:           rtmp://cricket.traceodd.com/live
Stream Key:       stream_main
                  (Must match cricket_streams.rtmp_stream_key in DB)

Settings → Output → Streaming

Video Bitrate:    4000 Kbps  (for 1080p30)
Encoder:          NVIDIA NVENC H.264 (if NVIDIA GPU available)
                  OR x264 (CPU encoding)

Encoder Preset:   P5: Slow (Good Quality) [NVENC]
                  OR veryfast [x264 CPU]

Rate Control:     CBR (Constant Bitrate)
Keyframe Interval: 2 seconds
Profile:          main

Settings → Video

Base Resolution:  1920x1080
Output Resolution: 1920x1080
Downscale Filter: Bicubic (Sharpened scaling, 16 samples)
FPS:              30

Settings → Audio

Sample Rate:      44.1 kHz
Channels:         Stereo
Audio Bitrate:    160 Kbps
```

### 2.5 Hotkey Configuration for Live Switching

```
File → Settings → Hotkeys

Scene 1 (CAM 1 — Main Wide) .......... NUMPAD 1
Scene 2 (CAM 2 — Long-Off) ........... NUMPAD 2
Scene 3 (CAM 3 — Mid-Wicket) ......... NUMPAD 3
Scene 4 (CAM 4 — Square Leg) ......... NUMPAD 4
Scene 5 (CAM 5 — Boundary) ........... NUMPAD 5
Scene 6 (Split Screen 50/50) ......... NUMPAD 6
Scene 7 (PiP Main + Bowler) .......... NUMPAD 7
Scene 8 (Scorecard Graphics) ......... NUMPAD 8

Start Streaming ....................... CTRL + ALT + S
Stop Streaming ........................ CTRL + ALT + X
```

### 2.6 Backup Stream Configuration

**Secondary Laptop Setup:**

Every match should have a **second laptop** on standby, pre-configured with the same OBS scenes but streaming to a **different stream key**:

```
Backup OBS Stream Settings:

Server:           rtmp://cricket.traceodd.com/live
Stream Key:       stream_backup
```

**Failover Procedure (if Primary Laptop fails):**

1. Primary laptop stops streaming (or crashes).
2. SRS detects RTMP stream loss within 3 seconds.
3. **Production Director switches to Backup:** Activate backup laptop's stream by pressing "Start Streaming" on backup OBS.
4. **Cricket Manager updates in panel:** Go to Camera Switcher → Activate "Backup Feed" camera.
5. CDN picks up the new HLS segments within 3-6 seconds.
6. Viewers see brief buffering (3-6s) then stream resumes on backup feed.

**Pre-Match Failover Test (Do This Before Every Match):**

```bash
# On Hetzner server, verify both streams can publish:
# (Check SRS logs after OBS starts pushing)
ssh root@135.181.46.27
tail -f /var/log/srs-cricket.log | grep -E 'accept|publish'
# Expected output:
# [2026-08-09 14:00:01] accept client, fd=12
# [2026-08-09 14:00:01] publish success, stream=live/stream_main
```

### 2.7 Scene Switching Strategy (Production Director's Playbook)

```
BALL CYCLE (6 deliveries per over):

  Ball 1-6 (CAM 1 — Main Wide):
  └─ Wide master shot. Cameraman follows ball after it leaves bowler's hand.

  AFTER EACH BALL (1-2 seconds post-delivery):
  └─ Quick cut to CAM 2 (Long-Off) → Show batsman reaction + field reset.
  └─ OR: Stay on CAM 1 if replay isn't needed.

  BOUNDARY (4/6):
  └─ CAM 1 tracks ball to boundary.
  └─ Cut to CAM 5 (Boundary Cam) → Crowd reaction + fielder retrieval.
  └─ Return to CAM 1.

  WICKET:
  └─ CAM 1 → Ball hits stumps / catch taken.
  └─ IMMEDIATE CUT to CAM 2 or CAM 3 → Show batsman walking off.
  └─ CUT to CAM 5 → Celebrating fielders / crowd.
  └─ Cut to SCENE 8 (Scorecard) → 10-second overlay showing fall of wicket.
  └─ New batsman walks in → Return to CAM 1.

  BETWEEN OVERS:
  └─ Cut to SCENE 8 (Full Scorecard) for 15-20 seconds.
  └─ Sponsor bumpers cycle automatically.
  └─ Return to CAM 1 for new over.

  DRINKS BREAK / INNINGS BREAK:
  └─ SCENE 8 (Scorecard Graphics) on loop.
  └─ Cycle through sponsor banners.
  └─ Optional: Pre-recorded highlights / replay package.
```

---

## 3. FINAL SYSTEM HANDOVER & PRE-LIVE CHECKLIST

### 3.1 Tournament Launch Sequence

Run these commands **in order** on the Hetzner server before the first match of the tournament:

```bash
# ═══════════════════════════════════════════════════════
# TOURNAMENT DAY — LAUNCH SEQUENCE
# ═══════════════════════════════════════════════════════

# 1. SSH into Hetzner
ssh root@135.181.46.27

# 2. WAKE the cricket module (enables Nginx, starts SRS)
sudo /usr/local/bin/cricket-wake.sh

# Expected output:
#   ✓ Cricket Nginx block enabled
#   ✓ HLS directory ready
#   ✓ SRS started successfully
#   ℹ API health check: HTTP 200
#   CRICKET MODULE AWAKE AND OPERATIONAL

# 3. Verify SRS is running and listening on port 1935
systemctl status cricket-srs
ss -tlnp | grep 1935
# Expected: LISTEN 0.0.0.0:1935

# 4. Verify HLS directory is writable
ls -la /var/www/traceodd/cricket-hls/
# Expected: drwxr-xr-x www-data:www-data

# 5. Verify Nginx cricket config is loaded
nginx -t
systemctl reload nginx

# 6. Check that cricket API is responding
curl -s http://localhost/api/v1/cricket/public/tournament/active | jq .
# Expected: { "tournament": { "id": "...", "name": "...", "status": "active" } }

# 7. Verify Reverb WebSocket is running
systemctl status nexatrace-reverb
ss -tlnp | grep 8080

# 8. Seed tournament data via Laravel Artisan (if not already done)
php /var/www/traceodd/admin-panel/artisan db:seed --class=CricketFeatureRegistrySeeder

# 9. Run database migrations (ensures cricket tables exist)
php /var/www/traceodd/admin-panel/artisan migrate --force

# 10. Clear and optimize cache
php /var/www/traceodd/admin-panel/artisan optimize:clear
php /var/www/traceodd/admin-panel/artisan optimize

# ═══════════════════════════════════════════════════════
# CRICKET MODULE IS NOW LIVE
# ═══════════════════════════════════════════════════════
```

### 3.2 Pre-Match Checklist (30 Minutes Before Each Match)

```
□ MODE SELECTION (Choose ONE based on available equipment)
  □ Mode A (Hybrid): _____ DSLRs + _____ Smartphones
  □ Mode B (Pure Smartphone): _____ Phones
  □ Mode C (Full Professional): _____ Camcorders + ATEM ☐ / USB Dongles ☐

□ CAMERAS & MOUNTS (Mode-specific — check applicable items)
  MODE A/B: Phone tripod mounts secured ☐  Power banks connected ☐
  MODE A/C: DSLR clean HDMI verified ☐  Batteries > 90% ☐
  MODE C:   ATEM recognized in OBS ☐  Multi-view monitor active ☐
  ALL:      Tripods locked, sandbags in place ☐
  ALL:      Rain covers available (check weather forecast) ☐
  MODE A/B: Phone cooling shades in place (sunny day) ☐

□ PRODUCTION LAPTOP (OBS)
  □ OBS primary laptop booted, OBS launched
  □ Mode A: MediaMTX local RTMP server running (for phone sources)
  □ Mode B: All 5 HLS Media Sources connected and previewing
  □ All 8 OBS scenes verified (preview each CAM input)
  □ Audio input working (ambient mic / commentator feed)
  □ Sponsor overlays loaded correctly in OBS
  □ Hotkeys tested (numpad 1-8 switch scenes)
  □ OBS backup laptop booted, OBS launched (standby)

□ NETWORK
  □ Primary laptop: Ethernet connected (not WiFi)
  □ Internet speed test: Upload > 6 Mbps (speedtest.net)
  □ Secondary network (4G hotspot) tested on backup laptop
  □ Mode A/B: All phones on same WiFi as laptop OR strong 4G (>3 bars)
  □ Mode A: Local RTMP port 1935 reachable from all phones:
    (From any phone browser: http://192.168.1.XXX:1935 → should respond)
  □ RTMP push test: "Start Streaming" in OBS → check SRS logs:
    ssh root@135.181.46.27 "tail -20 /var/log/srs-cricket.log"

□ SERVER (Hetzner)
  □ SRS running: systemctl status cricket-srs
  □ Nginx OK: nginx -t
  □ CDN Pull Zone active: check BunnyCDN dashboard → Status: Active
  □ Redis running: redis-cli ping → PONG
  □ Disk space > 10 GB: df -h /var/www/traceodd/cricket-hls/
  □ Mode B: Verify SRS receiving all 5 mobile streams:
    tail -20 /var/log/srs-cricket.log | grep 'publish success'

□ SCORING
  □ Cricket Manager logged into manager panel
  □ Match created in Sub-Admin panel with correct teams
  □ At least 2 Cricket Managers assigned to match (HA/failover)
  □ Voice-to-score tested (speak "Four runs" → verify parsed)
  □ Stream keys copied to OBS Stream settings
  □ Live score WebSocket test: open cricket website → verify score updates

□ PUBLIC VIEWER VERIFICATION
  □ Open cricket.traceodd.com on mobile → Home page loads
  □ Click active match → Stream player loads
  □ Scoreboard visible and updating
  □ Sponsor banners displaying correctly
  □ PWA "Add to Home Screen" working on Android Chrome

□ MODE SWITCHING READY (in case equipment fails during match)
  □ Fallback mode identified: If Mode __ fails → switch to Mode __
  □ Fallback equipment on standby in production tent
```

### 3.3 Post-Match Shutdown Checklist

```
□ Stop OBS streaming on primary laptop
□ Verify SRS has disconnected: tail /var/log/srs-cricket.log
□ Save OBS profile (File → Profiles → Export)
□ Power down cameras (or swap batteries for next match)
□ CAP camera SD cards (archive footage if recording locally)
```

### 3.4 Tournament Conclusion — Sleep Mode

After the final match and trophy ceremony, execute the sleep sequence:

```bash
# ═══════════════════════════════════════════════════════
# TOURNAMENT CONCLUSION — SLEEP SEQUENCE
# ═══════════════════════════════════════════════════════

ssh root@135.181.46.27

# 1. Execute sleep script
sudo /usr/local/bin/cricket-sleep.sh

# Expected output:
#   ✓ SRS stopped successfully
#   ✓ 1 tournament(s) deactivated
#   ✓ Cleared {N} cricket Redis keys
#   ✓ Cricket Nginx block disabled
#   ✓ All cricket processes terminated
#   ℹ Free memory: XXXX MB
#   CRICKET MODULE SLEEP MODE ACTIVATED
#   All resources returned to core 17 modules

# 2. Verify complete shutdown
systemctl status cricket-srs
# Expected: inactive (dead)

systemctl status nexatrace-reverb
# Expected: active (running) — still needed for main modules

nginx -t && systemctl reload nginx
# Main domain traceodd.com unaffected

# 3. Verify main 17 modules are unaffected
curl -s https://traceodd.com/api/health
# Expected: {"ok": true}

# 4. Optional: Archive cricket data
pg_dump -U postgres -t cricket_* nexatrace > /backups/cricket-valley-soon-2026.sql
```

### 3.5 Operational CLI Quick Reference

```bash
# ═══════════════════════════════════════════════════════
# CRICKET MODULE — QUICK REFERENCE CARD
# ═══════════════════════════════════════════════════════

# WAKE (Tournament Start)
sudo /usr/local/bin/cricket-wake.sh

# SLEEP (Tournament End)
sudo /usr/local/bin/cricket-sleep.sh

# SRS Status & Control
systemctl status cricket-srs         # Check if running
systemctl start cricket-srs          # Start manually
systemctl stop cricket-srs           # Stop manually
systemctl restart cricket-srs        # Restart (after config change)
journalctl -u cricket-srs -f         # Follow SRS logs live

# Nginx Cricket Block
ln -sf /etc/nginx/sites-available/cricket /etc/nginx/sites-enabled/cricket  # Enable
rm /etc/nginx/sites-enabled/cricket                                          # Disable
nginx -t && systemctl reload nginx                                           # Reload

# HLS Directory
ls -lh /var/www/traceodd/cricket-hls/       # List HLS segments
du -sh /var/www/traceodd/cricket-hls/       # Check disk usage
rm -rf /var/www/traceodd/cricket-hls/*      # Clear old segments (after sleep)

# Debugging RTMP Stream Issues
tail -100 /var/log/srs-cricket.log          # SRS logs
tcpdump -i any port 1935 -n                 # Watch RTMP traffic
ffprobe rtmp://localhost/live/stream_main   # Test stream locally

# Database Operations
php /var/www/traceodd/admin-panel/artisan migrate --force       # Run cricket migrations
php /var/www/traceodd/admin-panel/artisan db:seed --class=CricketFeatureRegistrySeeder  # Seed vertical
php /var/www/traceodd/admin-panel/artisan tinker                # Interactive query cricket tables
# In tinker:
# >>> App\Models\Cricket\Tournament::all();
# >>> App\Models\Cricket\CricketManager::where('status', 'active')->get();

# Redis Operations
redis-cli KEYS "cricket:*"                 # List all cricket cache keys
redis-cli GET "cricket:score:{match_id}"    # Read cached score
redis-cli FLUSHDB                           # ⚠️ WARNING: Clears ALL Redis data

# Health Checks
curl -s http://localhost/api/v1/cricket/public/tournament/active
curl -s http://localhost/api/v1/cricket/public/matches/live
curl -s http://localhost:1985/api/v1/versions  # SRS HTTP API version check
```

---

## 4. TROUBLESHOOTING QUICK REFERENCE

### 4.1 RTMP Stream Not Connecting (OBS → SRS)

| Symptom | Cause | Fix |
|---------|-------|-----|
| OBS shows "Failed to connect" | SRS not running / port blocked | `systemctl start cricket-srs` |
| OBS connects then disconnects | Stream key mismatch | Verify `stream_main` in both OBS and `cricket_streams` table |
| OBS shows "Connection timed out" | Firewall blocking port 1935 | `ufw allow 1935/tcp` |
| Stream connects but no HLS output | FFmpeg missing on Hetzner | `apt-get install ffmpeg` then restart SRS |

### 4.2 HLS Not Playing on Viewer Devices

| Symptom | Cause | Fix |
|---------|-------|-----|
| Video player spins forever | CDN not pulling from origin | Check BunnyCDN dashboard → Pull Zone status |
| "Network error" in player | CORS headers missing | Verify `cricket.conf` has `Access-Control-Allow-Origin *` |
| Choppy / stuttering video | Bitrate too high for viewer bandwidth | Reduce OBS bitrate to 2500 Kbps; check ABR renditions |
| No video, audio only | Codec mismatch | Verify OBS encoder is H.264, not H.265/HEVC |

### 4.3 Camera Issues On-Field

| Symptom | Fix |
|---------|-----|
| Camera HDMI output blank | Check camera is NOT in standby; press shutter half-way |
| HDMI output shows overlays | Camera menu → HDMI Output → Clean Output = ON |
| Flickering video | Replace HDMI cable; try shorter cable (<15m) |
| Camera overheating in sun | Shade with umbrella; open battery door for ventilation |

### 4.4 Emergency Contacts

| Role | Contact |
|------|---------|
| Server Admin | [YOUR NAME] — [PHONE] |
| CDN Support | BunnyCDN — support@bunny.net |
| SRS Community | https://github.com/ossrs/srs/issues |
| Production Director | [NAME] — [PHONE] |
| Cricket Manager (Primary) | [NAME] — [PHONE] |
| Cricket Manager (Backup) | [NAME] — [PHONE] |

---

## 5. MODE SWITCHING REFERENCE CARD

### 5.1 Quick Mode Switch (Between Matches)

Switching from one mode to another takes **under 5 minutes**:

```
┌──────────────────────────────────────────────────────────────┐
│                   MODE SWITCHING WORKFLOW                    │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. STOP current OBS stream (CTRL+ALT+X)                     │
│  2. REMOVE old camera sources from OBS:                      │
│     Right-click each source → Remove                         │
│  3. ADD new camera sources per the target mode:              │
│     Mode A: Video Capture Device (HDMI) + Media Source (RTMP)│
│     Mode B: Media Source (HLS from SRS) for all 5 cameras    │
│     Mode C: Blackmagic Device (ATEM) + Video Capture (HDMI)  │
│  4. VERIFY all sources show picture in preview               │
│  5. START streaming (CTRL+ALT+S)                             │
│                                                               │
│  Total downtime: ~5 minutes (between overs/inning break)     │
└──────────────────────────────────────────────────────────────┘
```

### 5.2 Emergency Mode Degradation (Mid-Match)

If primary equipment fails mid-match, degrade to the next available mode without stopping the stream:

| Failure | Degradation Path | Action |
|---------|-----------------|--------|
| **ATEM Switcher dies** | Mode C → Mode A | Disconnect ATEM USB. Plug HDMI dongles directly into laptop USB ports. Camera 1-5 sources switch from "Blackmagic Device" to individual "Video Capture Device" sources in OBS. |
| **DSLR battery dies** | Mode A → degraded Mode A | Switch to smartphone backup camera for that position. Activate Larix stream on phone → add as Media Source in OBS → hotkey to that scene. |
| **WiFi router fails** | Mode A → Mode B (direct-to-SRS) | Reconfigure Larix on all phones from `rtmp://192.168.1.XXX:1935/live/...` to `rtmp://cricket.traceodd.com:1935/live/...`. In OBS, swap Media Source inputs from local RTMP to SRS HLS URLs. |
| **Internet down** | All modes → Local recording | OBS: Start Recording (not streaming). Archive MP4 file locally. Upload to SRS after connection restores using `ffmpeg -re -i recording.mp4 -c copy rtmp://cricket.traceodd.com/live/stream_main`. |
| **All wired cameras fail** | Mode A/C → Mode B | Switch entirely to smartphone network. All 5 phones streaming via Larix direct-to-SRS. Replace all OBS sources with HLS Media Sources. |

### 5.3 Mode Comparison Matrix

| Feature | Mode A (Hybrid) | Mode B (Pure Mobile) | Mode C (Professional) |
|---------|----------------|---------------------|----------------------|
| **Setup time** | 20 min | 10 min | 30 min |
| **Cost (new equipment)** | ~$100 | $0 | ~$800+ |
| **Video quality** | High (DSLR) + Medium (phones) | Medium (720p mobile) | Excellent (1080p broadcast) |
| **Latency (glass-to-glass)** | 3-6 sec | 8-15 sec | 2-4 sec |
| **Internet required** | 5-6 Mbps up | 10-15 Mbps up (5 phones) | 5-6 Mbps up (single output) |
| **Cable runs** | 2× HDMI (20m total) | Zero | 5× HDMI (80m total) |
| **Failover complexity** | Medium | Low (just swap phones) | High (need spare hardware) |
| **Best for** | Club tournaments, semi-pro | Community events, remote venues | Sponsored leagues, broadcast TV |

### 5.4 Mode-Specific OBS Profile Files

Save each mode as a separate OBS Profile so you can switch in seconds:

```
OBS → Profile → New
  Name: "Cricket — Mode A Hybrid"
  Configure all sources for Mode A
  Export: Profile → Export → "cricket-mode-a-hybrid"

OBS → Profile → New
  Name: "Cricket — Mode B Mobile"
  Configure all sources for Mode B
  Export: Profile → Export → "cricket-mode-b-mobile"

OBS → Profile → New
  Name: "Cricket — Mode C Professional"
  Configure all sources for Mode C
  Export: Profile → Export → "cricket-mode-c-pro"

# To switch modes on match day:
OBS → Profile → Select the target mode → All sources swap instantly
```

---

> **Document Version:** 2.0 — Valley Soon Cricket Tournament 2026
> **Last Updated:** 2026-08-09
> **Maintained By:** NexaTrace Engineering Team
