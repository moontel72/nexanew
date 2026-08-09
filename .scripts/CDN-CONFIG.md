# =============================================================================
# NEXATRACE CRICKET — CDN CONFIGURATION GUIDE
# =============================================================================
# This document guides the setup of BunnyCDN for offloading 20,000 concurrent
# live viewers from the single Hetzner origin server.
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

### Step 5: Update Stream Endpoint URLs

In the Cricket Manager panel, set each stream's `hls_playlist_url` to:
```
https://cricket-cdn.traceodd.com/hls/live/{stream_key}-master.m3u8
```

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
# Check master playlist
curl -I https://cricket-cdn.traceodd.com/hls/live/match_12_cam1-master.m3u8

# Check a .ts segment
curl -I https://cricket-cdn.traceodd.com/hls/live/match_12_cam1-00001.ts
```

Both should return HTTP 200 with `X-Cache: HIT` header.
