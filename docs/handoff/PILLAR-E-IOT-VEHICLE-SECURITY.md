# Pillar E — TraceOdd Smart IoT Vehicle Security & Tracking

**Surface:** **#24** · **Group 7 — Vehicle Security** (see `PANEL-SEPARATION-PLAN.md` §11)
**Status:** spec only. **Zero code, zero backend, zero spec coverage before this file.**
**Read with:** `PANEL-SEPARATION-PLAN.md` §11 (registry), §12 (architecture per surface) and §15
(pillars tracked outside the plan).

**Provenance:** drafted 2026-09-25. Unlike Pillar A (whose content came from the owner), this is a
**proposed design** — every owner decision still open is listed in §11. The public commitments in §2
are quoted from `assets/landing/landing_content.json` and are **already published**, so the build has
to match them.

---

## 1. What this panel is

A hardware + software vertical: a TraceOdd-branded tracking device fitted to a vehicle
(motorbike, private car, or commercial fleet unit), reporting to the platform, with the owner
monitoring and controlling the vehicle from the app.

**Critical difference from every other surface in this repo:** this is the only pillar with a
**physical product**. Firmware, cellular connectivity, installation, SIM lifecycle and regulatory
type-approval all become part of the delivery. Software alone cannot ship this.

---

## 2. Published commitments (already on the website — must be honoured)

From `assets/landing/landing_content.json`, vertical `iot-security`:

| Claim | Source |
|---|---|
| Subscription-based IoT tracking for **cars, commercial fleets and motorbikes** | vertical copy |
| **Instant anti-theft remote immobilization** | vertical copy + Rider/Driver tiers |
| **Geofence & tamper alerts** | vertical copy |
| **High-frequency real-time GPS** | vertical copy; Driver tier specifies **5s** |
| **Fleet-wide dashboards** for commercial operators | vertical copy + Fleet tier |
| **"No upfront hardware cost"** — hardware is bundled into the monthly subscription | vertical copy |
| **Tamper & tow alerts**, **trip history reports** | Driver tier |
| **Driver behaviour analytics**, **API & dispatch integrations** | Fleet tier |
| Roadmap **Phase 4 — "IoT Devices Ship"** (after Cricket, Bus & Goods, Marketplace/Factory) | roadmap |
| Super-App feed shows **"Personal IoT vehicle alerts in one feed"** | super-app vertical |

**Launch pricing:** Rider — Motorbikes **PKR 499/month**; Driver — Cars & SUVs **PKR 899/month**
(highlighted); Fleet — **Custom per vehicle**.

**Two consequences worth stating plainly:**

1. **"No upfront hardware cost" makes the hardware an asset on the balance sheet**, recovered over
   the subscription term. That changes everything downstream: devices must be recoverable, ideally
   re-usable after a subscription ends, and abuse (device kept, subscription cancelled) needs a
   definition — see §11.
2. **The Super-App must surface IoT alerts** (surface #3), so this pillar is not standalone in the
   UI even though it is a separate panel (#24).

---

## 3. Regulatory gates (do these before hardware is ordered, not before code)

Pillar A has an SBP gate; **Pillar E has its own, and it is just as hard.**

| Gate | Why it matters |
|---|---|
| **PTA type approval** for the device's cellular module | Any device with a cellular radio sold/used in Pakistan needs telecom equipment authorisation. Without it the hardware cannot legally be imported or activated. |
| **SIM registration / CNIC binding** | Pakistani SIMs are issued against a CNIC. A fleet of devices means a fleet of registered SIMs, with a holder of record. Decide: TraceOdd-issued SIMs, or customer-supplied? |
| **Import / customs and duty position** | Affects unit economics directly, and the "no upfront cost" promise. |
| **Immobilizer safety and liability** | Remotely cutting a vehicle's engine is a safety-critical action. Most jurisdictions expect fail-safe rules (§7) and a liability position. **Get a written view before building it.** |
| **Insurance / aftermarket fitting** | Some insurers require approved installers or specific wiring practice. |

---

## 4. Device architecture

### 4.1 Physical form factor options

| Option | Fit | Notes |
|---|---|---|
| **Hardwired concealed unit** (recommended) | Cars, fleets, bikes | Tapped into ignition/fuel circuit; enables immobilization; concealed against theft |
| **OBD-II plug-in** | Cars only | Easiest install, but trivially removable by a thief — acceptable for *tracking*, weak for *security* |
| **Battery-powered magnetic unit** | Trailers, temporary | No install, but battery life and bulk; no immobilization |
| **Factory-fitted / CAN-integrated** | New fleets | Richest data, highest integration cost |

**Recommendation:** hardwired concealed unit as the primary product, because §2 promises
**immobilization** — an OBD dongle cannot credibly deliver that.

### 4.2 Connectivity

- **Avoid 2G-only designs.** 2G/3G is being wound down worldwide and is unreliable for a
  security product.
- **Prefer LTE Cat-M1 / NB-IoT**, falling back to **Cat-1 bis / Cat-4** where LPWAN coverage is thin.
  In Pakistan, NB-IoT coverage is limited, so **Cat-1-class is the pragmatic default** today.
- **Dual/multi-IMSI or eSIM** reduces roaming/coverage failures for vehicles crossing regions.
- **SMS as a fallback command path** is still pragmatic for immobilization when data is unavailable —
  but see §7 for why that needs strict controls.

### 4.3 Positioning

- Multi-constellation GNSS (GPS + GLONASS + Galileo + BeiDou) for faster fix and better urban accuracy.
- Cell-ID / Wi-Fi fallback when the sky view is blocked (garages, parking basements).
- Optional dead-reckoning with the on-board accelerometer/gyro for short tunnels.

### 4.4 Sensors and tamper detection (§2 requires this)

| Sensor | Detects |
|---|---|
| 3-axis accelerometer | Movement while ignition is off (**tow alert**), harsh braking/acceleration/cornering (Fleet tier analytics), crash |
| Case-open / tamper switch | Device being opened or dismantled |
| Backup battery | Device being unplugged from vehicle power |
| Supply-voltage monitor | Wiring cut or fuse pulled |
| GNSS jamming / spoofing detection | Deliberate signal suppression — a real theft pattern |

### 4.5 Power management

A parked vehicle must not drain its battery and the device must still wake on an event. Design:
deep sleep with motion-triggered wake, ignition-triggered reporting, and configurable heartbeat
(e.g. 5s while driving per the Driver tier, minutes while parked).

### 4.6 Device security (non-negotiable for a security product)

- **Per-device identity**: a unique X.509 certificate, **not** a shared API key. A shared secret
  leaking once compromises the whole fleet.
- **mTLS over TLS 1.3** on every ingestion and command connection, with certificate pinning.
- **Secure element** for key storage where the BOM allows it.
- **Signed firmware + OTA updates**, with rollback and a staged rollout — a fleet of devices that can
  only be updated by hand is unmaintainable.
- **Command authenticity**: an immobilization command must be signed and verified on-device.

---

## 5. Server architecture

### 5.1 Ingestion — evaluate before building

Do **not** hand-roll a GPS protocol parser. Two viable paths:

| Path | Why consider it |
|---|---|
| **Self-hosted Traccar** (open source) | Speaks dozens of device protocols; mature position/geofence/event core; battle-tested at fleet scale |
| **Own MQTT broker** (EMQX / Mosquitto) + Laravel consumer | Cleaner fit if we use our own firmware and our own message schema; MQTT is the right protocol for constrained devices |

**Recommendation:** own firmware → **MQTT with our own schema**, because the value here is the
TraceOdd integration (identity, wallet, super-app feed), not protocol breadth. Evaluate Traccar only
if we decide to support third-party trackers as well.

Whatever is chosen, the Laravel side consumes a stream and writes to a **time-partitioned positions
table**, never to the request/response path.

### 5.2 Data model (proposed)

| Table | Purpose |
|---|---|
| `iot_devices` | serial, model, firmware version, SIM ICCID, certificate reference, lifecycle status |
| `iot_device_installations` | device ↔ vehicle fitting record: installer, wiring profile, installed_at |
| `iot_vehicles` | make/model/plate/type (bike · car · fleet unit), owning identity |
| `iot_device_bindings` | **time-bounded** device ↔ vehicle ↔ owner association — the same *link record* pattern plan **D1** uses for drivers, so history survives a transfer or resale |
| `iot_positions` | **partitioned by time** (like the audit logs in §10.8): device_id, ts, lat, lng, speed, heading, ignition, sensor blob |
| `iot_geofences` | owner-scoped geometry, include/exclude kind, alert rules |
| `iot_security_events` | tow, tamper, jamming, unplugged, geofence enter/exit, immobilize requested/executed |
| `iot_device_commands` | command type, requested_by, status, **idempotency_key**, issued_at, **TTL**, executed_at |
| Billing | **reuse** `financial_wallets` + the existing billing/subscription tables — do not invent a parallel wallet |

### 5.3 Telemetry channel routing

Follow plan **§10.9**. Add `device.{device_id}` to the existing channel family, and deliver owner
alerts through the existing Reverb path. The Super-App feed (§2) subscribes to the owner's channels.

### 5.4 Command path

Immobilization is a **command with a two-phase acknowledgement** (accepted → executed/failed), never
fire-and-forget, and every state transition is written to the audit chain (§10.8).

---

## 6. Mobile app (Flutter BLoC)

Surface **#24** is a normal Flutter BLoC panel — **no native kernel needed** (see plan §12.2). Maps,
lists and alerts are I/O-bound, not compute-bound.

| Screen | Contents |
|---|---|
| Device list | Vehicles with live status (moving/parked/offline), battery, last-seen |
| Live map | Position, trail, geofences — **needs a real map SDK**, the same gap Pillar C has (the current map widget is a pseudo-position `CustomPainter`) |
| Geofence editor | Draw/edit zones, per-zone alert rules |
| Alert feed | Tow, tamper, jamming, geofence breach, low battery |
| Immobilization | Two-step confirmation + PIN/2FA, with the fail-safe rules in §7 |
| Trip history | Per-trip map + summary (Driver tier) |
| Fleet dashboard | Multi-vehicle overview + driver behaviour (Fleet tier) |

**Reuse, don't rebuild:**

| Existing component | Reuse for |
|---|---|
| `shared/bloc/telemetry_tracking/` (`VehicleTelemetry`, scope filtering, offline queue) | The telemetry state layer — already built for fleet tracking |
| `shared/services/geo_compute.dart` | Haversine distance, geofence math |
| `core/services/websocket_hub.dart` | Realtime alerts (single WS stack — see plan §14 debt item 2) |
| `GeofenceScanUnlocked` event pattern, `SupplyChainHandshakeService` 200 m geofence | Proven geofence-gated pattern to copy |

---

## 7. Immobilization — the highest-risk feature in the ecosystem

This is the one action that can **cause a crash or strand a driver**. Treat it like a financial
transaction, and design it before building it.

**Fail-safe rules (proposed — require owner sign-off):**

1. **Never cut while moving.** Only when speed ≈ 0 (or ignition off). A cut at speed is a safety incident.
2. **Two-step, two-factor.** App action **plus** a second factor (PIN/OTP). A stolen phone must not
   be enough to stop a vehicle — otherwise the app itself becomes the theft tool.
3. **Reversible by design.** Re-enable is always available to the verified owner, on the same
   channel, with no dependency on the immobilizing path.
4. **TTL on the command.** A queued command that never reached the device must **expire**; it must
   never fire hours later when the vehicle is back in use.
5. **Audited end-to-end.** Request, delivery, execution and reversal all land in the audit chain
   (§10.8), with the actor identity.
6. **Owner-visible state.** The app must always show the device's real immobilization state; a UI
   that lies about this is worse than no feature.
7. **Kill switch.** A platform-level disable for the whole command type if a defect is found.

---

## 8. Delivery phases (software first, hardware second — on purpose)

| Phase | Scope | Why this order |
|---|---|---|
| **1** | Server + **simulated devices** + data model + geofencing + alerts + app UI | The entire software stack can be built and demonstrated **before any hardware exists**. Removes the hardware dependency from 80% of the work. |
| **2** | Hardware pilot — one model (Rider/bike), PTA approval, SIM strategy, installer process | Proves the physical path on the cheapest, simplest vehicle class first |
| **3** | **Immobilization** with §7 fail-safes + audit | Highest risk, and only meaningful once the device is proven in the field |
| **4** | Driver behaviour analytics + API/dispatch integrations + fleet dashboards | Fleet tier features, which need real data volume to be worth building |

**Phase 1 is the recommendation for "start now"** — it is pure software, it de-risks everything, and
it makes Phase 2 a hardware problem only.

---

## 9. What already exists to build on

Verified in the repo — none of it is IoT-specific, but all of it is reusable:

| Existing | Where |
|---|---|
| Vehicle telemetry BLoC with scope filtering + offline queue | `lib/shared/bloc/telemetry_tracking/` |
| Haversine / geofence distance math | `lib/shared/services/geo_compute.dart`, `BusLiveTrackingService` |
| Broadcast event pattern + channels registry | `backend/app/Events/*`, `backend/routes/channels.php` |
| Geofence-gated handshake (200 m) | `backend/app/Services/Factory/SupplyChainHandshakeService.php` |
| Identity spine for owners/devices | `global_identities` + `identity_claims` (plan §10.1) |
| Wallet + subscription billing | `financial_wallets`, existing billing tables |
| Audit chain + partitioning | `audit_log_*` (plan §10.8) |
| Telemetry channel routing rules | plan §10.9 |

**What does *not* exist anywhere:** `iot_devices`, `iot_positions`, `iot_geofences`, any ingestion
path, any firmware, and **any immobilizer code**. Confirmed by search — the only "geofence" in the
backend today is factory *delivery* proximity.

---

## 10. Panel and grouping

- **Surface #24, Group 7 "Vehicle Security"** — the group was created for it (plan §1).
- **Backend:** a new panel route file and prefix, following `routes/panels/*.php` (the 11 existing
  panels are registered in `PanelRouteServiceProvider`).
- **Not in the legacy spec at all** — the spec must gain a module entry, or this pillar keeps being
  forgotten by agents that read only the spec (already flagged in plan §15).

---

## 11. Open items (owner decisions)

| # | Item |
|---|---|
| 1 | **Hardware strategy** — build, or OEM/rebrand an existing tracker? Owning firmware is a multi-year commitment. |
| 2 | **SIM strategy** — TraceOdd-issued SIMs vs customer-supplied |
| 3 | **"No upfront hardware cost" mechanics** — device recovery on cancellation, and what happens at the end of the subscription term |
| 4 | **PTA type approval** — who drives it, and when (gate for Phase 2) |
| 5 | **Immobilization fail-safe rules (§7)** — written sign-off required before Phase 3 |
| 6 | **Installation network** — in-house, or partner workshops; warranty and liability |
| 7 | **Map SDK choice** — shared with Pillar C; one decision serves both |
| 8 | **Own firmware (MQTT) vs third-party trackers (Traccar)** — decides §5.1 |
| 9 | **Data retention for positions** — high-volume time-series; retention policy and archive tier |
| 10 | **Whether Group 7 becomes its own server/department** at Phase 8 of the separation plan |

---

## 12. Provenance

| Date | Change |
|---|---|
| 2026-09-25 | File created. Surface **#24**, group **7 Vehicle Security**. Public commitments captured from `assets/landing/landing_content.json`. Proposed device, server, app and immobilization designs recorded, with the regulatory gates and open owner decisions listed. |
