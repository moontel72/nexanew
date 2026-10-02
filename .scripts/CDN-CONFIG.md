# =============================================================================
# NEXATRACE CRICKET — CDN CONFIGURATION GUIDE
# =============================================================================
# This document guides the setup of BunnyCDN for offloading 20,000 concurrent
# live viewers from the single Hetzner origin server.
#
# HYBRID RULE — read this first
# -----------------------------------------------------------------------------
#   WHEP (WebRTC) -> DIRECT from the origin. NEVER put it behind a CDN: a CDN
#                    cannot proxy WebRTC media (nothing to cache, and the ICE
#                    /UDP path must reach a publicly routable SFU). Serves the
#                    first ~1-10 viewers at ~1-2s and is what the public page
#                    prefers.
#   HLS           -> CDN (BunnyCDN pull zone). Segmented and cacheable, and the
#                    only transport that scales to thousands of viewers. It is
#                    the page's FALLBACK, so scaling the CDN changes nothing in
#                    the player.
# The two paths share one origin, so the pull zone only ever touches /hls/.
# =============================================================================

## QUICK REFERENCE

| Parameter | Value |
|-----------|-------|
| Origin URL | https://cricket.traceodd.com |
| HLS path | /hls/ |
| CDN provider | BunnyCDN (recommended) or Cloudflare Stream |
| Estimated cost | ~$0.01/GB delivered (~$810 for full tournament) |

---

## OPTION A: BUNNYCDN PULL ZONE (Recommended)

### Step 1: Create Pull Zone

1. Log into https://bunny.net → CDN → Add Pull Zone
2. Configure:
   - **Name**: nexatrace-cricket-cdn
   - **Origin URL**: https://cricket.traceodd.com
   - **Origin Shield**: ENABLED (reduces origin requests for popular segments)
   - **Enable SSL**: YES
   - **Enable Smart Cache**: YES

### Step 2: Edge Rules

Add the following edge rules for HLS streaming:

| Rule | Value |
|------|-------|
| **HLS segments** (.ts) | Cache: Override → 30 seconds |
| **HLS playlists** (.m3u8) | Cache: Bypass (always from origin) |
| **Static assets** (.js, .css, .png) | Cache: 30 days |
| **API responses** (/api/) | Cache: Bypass |

### Step 3: CORS Headers

Ensure these headers are set:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, OPTIONS
```

### Step 4: DNS

Add a CNAME record:
- **cricket-cdn.traceodd.com → [BunnyCDN hostname]**

### Step 5: Point the backend's HLS base URL at the CDN

The playlist URL is a **config lever**, not a per-stream column — one env value
(`backend/config/cricket.php` → `CRICKET_HLS_BASE_URL`, consumed by
`CricketStreamSyncService::hlsUrlFor()`):

```bash
# backend/.env
CRICKET_HLS_BASE_URL=https://cricket-cdn.traceodd.com/hls/live
```

Then `php artisan config:clear`. No database row and no code change is needed.

Two corrections to what used to be written here:
- The stream is a **single rendition** directly remuxed by SRS, so the file is
  `cricket_match_{matchId}_cam{N}.m3u8` — there is **no** `-master.m3u8`.
- Do **not** point the WHEP path, `CRICKET_TURN_URL` or `CRICKET_STUN_URL` at the
  CDN. WHEP stays same-origin (`CRICKET_WHEP_BASE_PATH=/whep`).

---

## OPTION B: CLOUDFLARE STREAM (Alternative)

If Cloudflare is already handling DNS, Cloudflare Stream offers:
- Direct RTMP ingest (bypass SRS entirely)
- Server-side transcoding to ABR
- Global CDN delivery
- Cost: $1 per 1,000 minutes viewed

### Setup:

1. Enable Cloudflare Stream in dashboard
2. Get RTMP ingest URL: `rtmp://live.cloudflare.com:1935/live/{stream_key}`
3. Update cricket_streams entries with Cloudflare ingest URLs
4. Viewer URL: `https://customer-{code}.cloudflarestream.com/{video_uid}/manifest/video.m3u8`

### Trade-off:
- **PRO**: Zero server CPU for transcoding. Higher reliability.
- **CON**: ~5-10x more expensive than BunnyCDN for 20K viewers.

---

## OPTION C: HLS DIRECT FROM ORIGIN (Smallest Scale)

For <500 concurrent viewers (testing / small tournaments):
- Serve HLS directly from `https://cricket.traceodd.com/hls/`
- No CDN needed — Nginx handles it
- Enable `sendfile on;` and `tcp_nopush on;` in Nginx
- Expected bandwidth: 500 × 3 Mbps = 1.5 Gbps (near Hetzner NIC limit)

---

## CDN HEALTH CHECK

Verify CDN is serving segments:

```bash
# HLS via the CDN (single rendition, no -master)
curl -I https://cricket-cdn.traceodd.com/hls/live/cricket_match_<MATCH_ID>_cam1.m3u8

# A .ts segment
curl -I https://cricket-cdn.traceodd.com/hls/live/cricket_match_<MATCH_ID>_cam1-1.ts

# WHEP must NOT go through the CDN — it stays same-origin on the public host
curl -i -X POST "https://cricket.traceodd.com/whep/watch/probe/probe" \
  -H "Content-Type: application/sdp" --data "v=0"   # 401/400/404 JSON = proxy live
```

Both CDN URLs should return HTTP 200 with an `X-Cache: HIT` header.
