# 06 — ICE Resilience & Telemetry (Phase 1)

What changed in the media engine's networking, and how to operate it.

## 1. Why the original WebRTC watching failed

The prototype applied a **global IPv4-only blanket** to ICE candidate
gathering (`set_network_types([Udp4, Tcp4])`) plus ad-hoc link-local
filters. On a host with no IPv6 route, IPv6 candidate gathering errored
and broke the ICE keep-alive heartbeat (`Connected → Disconnected →
Failed`), freezing video. The engine's only reaction to failure was
teardown — no `Disconnected` handling, no renegotiation, no reconnect.

Phase 1 replaces the blanket with a **per-interface policy**, tuned ICE
**consent freshness**, a **grace-based `Disconnected` watchdog** and
**takeover reconnects** — plus a real telemetry pipeline instead of
temporary test scripts.

## 2. Per-interface candidate harvesting

At startup (`crates/todd-broadcaster/src/net.rs`) the engine enumerates
host interfaces and derives an ICE policy:

- **Link-local / APIPA / loopback addresses are always excluded** — they
  are never routable and only produce pairs that time out.
- `ICE_INTERFACES` allow-lists interfaces by name (empty = all).
- `ICE_INTERFACE_DENY` excludes interface families by name prefix
  (defaults: docker, veth, br-, virbr, vmnet, vEthernet, VMware,
  VirtualBox, Hyper-V, wsl, utun).
- **IPv6 is adaptive**: `Udp6`/`Tcp6` candidates are gathered only when
  the host actually has a routable IPv6 address on an allowed interface.
  IPv4-only hosts behave exactly like before; dual-stack hosts keep
  full IPv6.
- `ICE_PUBLIC_IPS` advertises 1:1 NAT public addresses as host
  candidates (cloud floating IPs) — the general replacement for the
  loopback-only dev hack (`ICE_LOOPBACK=1` still appends 127.0.0.1).
- `ICE_UDP_PORT_MIN/MAX` pins the ephemeral UDP port range via a bound
  `EphemeralUDP` network — supported port pinning, replacing ad-hoc
  firewall workarounds. Open that range (UDP) instead of "any ephemeral".

The resolved interfaces are logged at startup
(`ICE candidate interface` lines, `RUST_LOG=info`).

## 3. ICE consent freshness & timeouts

`set_ice_timeouts` tunes:

| Env | Default | Meaning |
|---|---|---|
| `ICE_DISCONNECTED_TIMEOUT_MS` | 5000 | No network activity before `Disconnected` |
| `ICE_FAILED_TIMEOUT_MS` | 15000 | After `Disconnected`, before `Failed` |
| `ICE_KEEPALIVE_INTERVAL_MS` | 2000 | STUN consent heartbeat when no media flows |
| `ICE_DISCONNECTED_GRACE_MS` | 8000 | Server-side grace before proactive close |

`Disconnected` is no longer fatal: a watchdog waits
`ICE_DISCONNECTED_GRACE_MS`; if the connection recovers (typical for
Wi-Fi roams) nothing is torn down. If it stays `Disconnected`/`Failed`,
the session is closed proactively and accounted
(`todd_ice_disconnected_closures_total`).

## 4. Reconnect semantics (takeover)

A WHIP re-POST for an already-live `(room, camera)` **replaces** the
existing session instead of accumulating zombies or rejecting with
"camera busy" (`todd_whip_sessions_replaced_total`). WHEP viewers
re-watch the same way (browser `restartWatch` → new POST). A takeover
briefly closes fan-out subscribers of that camera — viewers must
re-watch. (Keeping subscribers across reconnects is a Phase 2 SFU
concern.)

## 5. Telemetry

Two surfaces, mounted on **both** Studio (embedded mode) and the
standalone Broadcaster:

| Endpoint | Format | Purpose |
|---|---|---|
| `GET /metrics` | Prometheus text 0.0.4 | Scrape target for Prometheus/Grafana |
| `GET /api/v1/telemetry/ws` | WebSocket, JSON snapshot per `TELEMETRY_WS_INTERVAL_MS` | Live diagnostics feed (Studio UI, dashboards) |

### Metric reference

| Metric | Type | Meaning |
|---|---|---|
| `todd_whip_ingests_total` | counter | WHIP sessions accepted |
| `todd_whip_sessions_replaced_total` | counter | Takeover reconnects |
| `todd_whep_watches_total` | counter | WHEP viewer sessions accepted |
| `todd_sessions_active` / `todd_viewers_active` | gauge | Live sessions |
| `todd_rtp_packets_in_total` / `todd_rtp_bytes_in_total` | counter | Ingress RTP |
| `todd_rtp_packets_forwarded_total` | counter | Fan-out deliveries |
| `todd_rtp_packets_dropped_total` | counter | Router backpressure drops |
| `todd_ice_disconnects_total` / `todd_ice_failures_total` | counter | ICE state transitions |
| `todd_ice_disconnected_closures_total` | counter | Grace-period closes |
| `todd_rtt_ms` | gauge | Max sampled ICE RTT (candidate pair stats) |
| `todd_jitter_ms` | gauge | Max RFC 3550 interarrival jitter across streams |
| `todd_ingress_bitrate_bps` / `todd_egress_bitrate_bps` | gauge | Aggregate bitrates |

RTT is sampled from WebRTC `get_stats()` nominated candidate pairs every
`TELEMETRY_SAMPLE_MS`. Jitter is measured on the RTP hot path (RFC 3550
§6.4.1) — webrtc-rs 0.11 does not expose jitter in its stats.

The WebSocket snapshot additionally carries per-camera stream stats
(packets/bytes in, dropped, forwarded, rtt, ingress/egress bitrate,
jitter) and per-session live ICE state.

## 6. Firewall guidance (Phase 1 single VPS)

```bash
# signaling stays on 443 via nginx; media is UDP:
#   default: ephemeral UDP ports (OS range)
#   or pin the range and open exactly that:
sudo ufw allow 10000:10100/udp   # if ICE_UDP_PORT_MIN/MAX=10000/10100
# TURN (mandatory for cameras on carrier NAT):
sudo ufw allow 3478/tcp && sudo ufw allow 3478/udp && sudo ufw allow 5349/tcp
sudo ufw allow 49160:49200/udp
```
