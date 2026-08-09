# ═══════════════════════════════════════════════════════════
# NEXATRACE CRICKET — HARDWARE SETUP & PRODUCTION GUIDE
# ═══════════════════════════════════════════════════════════
# Target: Valley Soon Cricket Tournament 2026
# Scale: 10 Teams | 20,000 Concurrent Viewers | 5 Cameras
# ═══════════════════════════════════════════════════════════

---

## TABLE OF CONTENTS

1. [Professional Camera Ingest Setup](#1-professional-camera-ingest-setup)
2. [OBS Studio & RTMP Push Configuration](#2-obs-studio--rtmp-push-configuration)
3. [Final System Handover & Pre-Live Checklist](#3-final-system-handover--pre-live-checklist)
4. [Troubleshooting Quick Reference](#4-troubleshooting-quick-reference)

---

## 1. PROFESSIONAL CAMERA INGEST SETUP

### 1.1 Recommended Camera Models

| Camera | Output Type | Resolution | Low-Light | Notes |
|--------|------------|------------|-----------|-------|
| **Sony NX100** | HDMI (Clean) | 1080p60 | Excellent | AVCHD + XAVC-S; 12x optical zoom |
| **Sony Z150** | HDMI + SDI | 4K UHD | Excellent | 1" sensor; built-in ND filters |
| **Panasonic UX180** | HDMI + SDI | 4K UHD | Very Good | 20x optical zoom; dual SD card |
| **Canon XA55** | HDMI (Clean) | 4K UHD | Excellent | Dual Pixel AF; compact form factor |
| **Canon XA40** | HDMI (Clean) | 4K UHD | Very Good | Budget-friendly; 20x optical zoom |

> **Critical: CLEAN HDMI Output.** Every camera MUST be configured to output **clean HDMI** (no on-screen overlays, focus boxes, battery indicators). This is configured in each camera's menu under `HDMI Output Settings → Clean Output = ON`.

### 1.2 Camera Placement Plan (5-Camera Setup)

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
                    │   Blackmagic ATEM Mini  │
                    │   Pro / ISO             │
                    │   (Hardware Switcher)    │
                    └───────────┬─────────────┘
                                │ USB-C Out
                                ▼
                    ┌─────────────────────────┐
                    │   OBS STUDIO LAPTOP     │
                    │   (Primary)             │
                    │   RTMP → Hetzner SRS    │
                    └─────────────────────────┘
```

| Camera # | Label | Position | Lens | Purpose |
|----------|-------|----------|------|---------|
| **CAM 1** | Main Wide | Straight, elevated (press box / scaffold) | 12-24x zoom | Master wide shot; follow ball trajectory |
| **CAM 2** | Long-Off | Behind bowler's arm, straight boundary | 12-20x zoom | Bowler run-up + batsman front view |
| **CAM 3** | Mid-Wicket | Side-on, square boundary | 8-12x zoom | Batsman side profile; run between wickets |
| **CAM 4** | Square Leg | Opposite side, square boundary | 8-12x zoom | Alternative angle; LBW appeals |
| **CAM 5** | Boundary Cam | Roaming / fixed at fine leg | Wide angle | Crowd reactions; boundary catches |

### 1.3 Signal Flow Architecture

#### OPTION A: Hardware Switcher (Recommended — Lowest Latency)

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

**Equipment Required:**

| Item | Qty | Model | Est. Cost |
|------|-----|-------|-----------|
| HDMI Switcher | 1 | Blackmagic ATEM Mini Pro | $295 |
| HDMI Cables (15m) | 5 | AmazonBasics / Cable Matters | $15/ea |
| HDMI Monitor | 1 | Any 15-22" with HDMI input | $80 |
| USB-C Cable | 1 | Included with ATEM | $0 |
| Tripods (fluid head) | 5 | Manfrotto / Benro | $80/ea |

**ATEM Setup Steps:**
1. Connect all 5 camera HDMI outputs to ATEM HDMI inputs 1-5.
2. Connect HDMI monitor to ATEM "HDMI Out" for multi-view preview.
3. Connect ATEM USB-C to OBS laptop — appears as a single webcam source.
4. Install Blackmagic ATEM Software Control on the OBS laptop.
5. In OBS, add "Blackmagic Device" as Video Capture Device source.
6. Use ATEM Software Control panel for live camera switching (hardware-cut — zero latency).

#### OPTION B: USB Capture Dongles (Budget / No Switcher)

```
Camera 1 ──HDMI──► HDMI-to-USB Dongle ──USB──┐
Camera 2 ──HDMI──► HDMI-to-USB Dongle ──USB──┤
Camera 3 ──HDMI──► HDMI-to-USB Dongle ──USB──┼──► OBS Laptop (5 USB ports)
Camera 4 ──HDMI──► HDMI-to-USB Dongle ──USB──┤       │
Camera 5 ──HDMI──► HDMI-to-USB Dongle ──USB──┘       │
                                                     ▼
                                              OBS Software Switcher
                                              (Scene-based switching)
```

| Item | Qty | Model | Est. Cost |
|------|-----|-------|-----------|
| HDMI Capture Dongle | 5 | Elgato Cam Link 4K / MiraBox | $100/ea |
| Powered USB 3.0 Hub | 1 | Anker 10-port 60W | $40 |

> **Trade-off:** Software switching in OBS adds ~200-400ms latency vs hardware ATEM. Acceptable for cricket (not esports). Cost savings: ~$200.

### 1.4 Power & Weather Protection

- **Batteries:** Each camera needs 2× fully charged batteries (1 active + 1 spare per innings break swap).
- **Power Strip:** Heavy-duty extension cord to production tent with surge protector.
- **Tripod Sandbags:** 5 kg per tripod to prevent wind tipping.
- **Rain Covers:** Camera rain covers (Op/Tech Rainsleeve or similar) — $8/ea.
- **Laptop Power:** Both primary + backup laptops plugged in. Laptop battery as UPS.

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
□ CAMERAS
  □ All 5 cameras powered on, clean HDMI output verified
  □ All tripods locked, sandbags in place
  □ Camera batteries > 90% (or AC power connected)
  □ Rain covers available (check weather forecast)

□ PRODUCTION TENT
  □ OBS primary laptop booted, OBS launched
  □ OBS backup laptop booted, OBS launched (standby)
  □ ATEM / capture dongles all recognized in OBS
  □ All 8 OBS scenes verified (preview each CAM input)
  □ Audio input working (ambient mic / commentator feed)
  □ Sponsor overlays loaded correctly in OBS
  □ Hotkeys tested (numpad 1-8 switch scenes)

□ NETWORK
  □ Ethernet connected (not WiFi) — primary laptop
  □ Internet speed test: Upload > 6 Mbps (speedtest.net)
  □ Secondary network (4G hotspot) tested on backup laptop
  □ RTMP push test: "Start Streaming" in OBS → check SRS logs:
    ssh root@135.181.46.27 "tail -20 /var/log/srs-cricket.log"

□ SERVER (Hetzner)
  □ SRS running: systemctl status cricket-srs
  □ Nginx OK: nginx -t
  □ CDN Pull Zone active: check BunnyCDN dashboard → Status: Active
  □ Redis running: redis-cli ping → PONG
  □ Disk space > 10 GB: df -h /var/www/traceodd/cricket-hls/

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

> **Document Version:** 1.0 — Valley Soon Cricket Tournament 2026
> **Last Updated:** 2026-08-09
> **Maintained By:** NexaTrace Engineering Team
