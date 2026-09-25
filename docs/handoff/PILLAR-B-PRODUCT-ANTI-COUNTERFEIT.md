# Pillar B — Factory Anti-Counterfeit Product Scanner

**Surface:** the scanning feature belongs to **#3 Universal Customer App** (Group 1 Platform), and also
appears inside **#8 Factory Store Keeper**, **#9 Factory Driver**, **#6 Shop Keeper** and the
**#1 Super Admin** counterfeit-report view (Group 3 / 2 / 1).
**Status:** **backend READY.** Flutter work is ~70% present but sits in the *orphaned* copy — see §7.
**Read with:** `PANEL-SEPARATION-PLAN.md` §11 (registry), §12 (per-surface runtime), §15 (pillars).

**Provenance:** drafted 2026-09-25 from a direct read of the backend controllers, routes and the
existing Flutter scan code. Every endpoint, field name and response shape below was read from source,
not assumed.

---

## 1. What this feature is

A consumer points the app at a product's **Smart Auth Code**. The server checks the code against the
TraceOdd **SHA256 serial vault**, and answers whether the product is authentically coded, awards a
**one-time cashback** on first activation, and flags **territorial anomalies**.

Unlike Pillar A (banknotes), this feature **may** state a verdict — the brand owns its own codes and
the vault is authoritative. §6.4 covers how to phrase it without accusing honest shopkeepers.

---

## 2. Why this is the right pillar to build first

| Reason | Evidence |
|---|---|
| **The backend is fully implemented** | `ConsumerScanController`, `ConsumerScanRewardService`, `FactoryProductionController@verifySerial`, `smart_codes`, `consumer_scans` |
| **The Flutter scan flow already exists** | `CustomerSuperAppBloc` already has the scan → verify event/state pair (§7) |
| **No new dependencies needed for scanning** | `mobile_scanner ^7.2.0` is already in `pubspec.yaml` |
| **It reaches real users fastest** | One screen, one endpoint, one result card |
| **It is the same ticket as the duplicate consolidation** | Plan §6 already requires porting the orphaned copy — Pillar B *is* that port |

---

## 3. The backend contract — verified from source

### 3.1 Consumer verification (authoritative endpoint)

```
POST /api/v1/marketplace/consumer/verify
middleware: auth:sanctum
```
Defined in `backend/routes/panels/marketplace.php:34-37`, handled by
`App\Http\Controllers\ConsumerScanController@verify`.

**Request body** (`ConsumerScanController.php:30-34`):

| Field | Rules | Note |
|---|---|---|
| `serial_hash` | required, string, max 64 | The **64-char hex SHA256** of the code — see §4 |
| `lat` | **required**, numeric | ⚠️ See §5 — this is the one real blocker |
| `lng` | **required**, numeric | Same |

**Response envelope:** `{ "success": bool, "data": { ... } }`

`data` is produced by `ConsumerScanRewardService::verifyAndRewardConsumer()` and has exactly
**three shapes**:

| Outcome | Fields |
|---|---|
| **Not in the vault** | `is_authentic: false`, `message: "COUNTERFEIT. This serial is not in the NexaTrace vault."`, `cashback: 0` |
| **Already activated** | `is_authentic: true`, `already_activated: true`, `message: "Already Verified. Product is authentic. 0 cash payout."`, `cashback: 0`, `product_info` |
| **First activation** | `is_authentic: true`, `already_activated: false`, `message: "Product verified. Cashback Rs. {n} awarded."`, `cashback: {n}`, `product_info`, `velocity_diverted: bool` |

The whole flow runs inside a **transaction** and logs a `consumer_scans` row. `velocity_diverted`
comes from a consumer-GPS vs retail-delivery-coordinates cross-check.

### 3.2 Internal / staff variant (no cashback, no GPS)

```
POST /api/v1/factory/production/verify-serial
body: { serial_hash }        // no lat/lng
```
`FactoryProductionController@verifySerial` (`:130-147`). Returns `success: false` with
`"COUNTERFEIT DETECTED..."` when the serial is absent from the vault.

**Use this one for staff surfaces** (Factory Store Keeper, Factory Driver, Shop Keeper): it verifies
vault membership without triggering a consumer cashback or a velocity check.

### 3.3 ⚠️ The route map in the Flutter app is wrong

`lib/core/navigation/panel_routes.dart:305` lists `'/api/v1/consumer/verify'` under
`customerEndpoints`. **That route does not exist.** `backend/routes/panels/consumer.php` registers
exactly four routes, and none of them is `verify`:

```
GET  /api/v1/consumer/transit/search
POST /api/v1/consumer/fleet/auction
POST /api/v1/consumer/fleet/bid
POST /api/v1/consumer/chat/send
```

The real endpoint is `/api/v1/marketplace/consumer/verify` — and it *is* correctly listed at
`panel_routes.dart` under `marketplaceEndpoints:262-266`. **An implementation that follows the
`customerEndpoints` entry will get a 404.** Fix the stale entry as part of step B1.

---

## 4. What the QR code actually contains

The endpoint takes a **hash**, not the printable product serial. `HardwareScanService` already
classifies exactly this shape (`_sha256Pattern = RegExp(r'^[a-fA-F0-9]{64}$')` →
`ScanPayloadType.cryptoSHA256`), and the vault is the `SHA256(batchId + secretKey + seed)` value
produced by the Rust code generator (the "Step 22 vault").

**The scan handler must accept two payload forms**, because both are plausible in the field:

1. A bare **64-hex string** → use it directly as `serial_hash`.
2. A **NexaTrace URL** containing the hash (also already classified as `nexaTraceUrl`) → extract the
   64-hex segment before sending.

Case-fold the hex to lowercase before sending, and validate `length == 64` client-side so an obvious
mis-scan never reaches the API.

---

## 5. ⚠️ The one real blocker: location

`lat` and `lng` are **required** by the consumer endpoint, but **this repository has no location
source at all** — no `geolocator`, no `flutter_map`, no permission plugin, no map SDK. Today nothing
can supply real coordinates.

| Option | Consequence |
|---|---|
| **A — add a location plugin (recommended)** | ⭐ **One decision serves three pillars**: Pillar B (this velocity check), Pillar C (bus live telemetry, currently stubbed/fake), Pillar E (IoT vehicle tracking). Add it once, correctly, with permission UX and a web fallback. |
| **B — relax the backend to accept an absent location** | Cheap, but `velocity_diverted` loses meaning and the anti-diversion control silently dies. The owner's Module 8W-C anti-fraud rule depends on this data. |

**Recommendation: A.** Handle the three cases explicitly — permission granted, permission denied, and
no fix available (indoors) — and let the server decide policy when the location is missing. Do **not**
send fake coordinates; a fabricated `0,0` would silently poison the fraud data.

---

## 6. Flutter design

### 6.1 Reuse — do not rebuild these

| Existing | Path | Reuse for |
|---|---|---|
| `HardwareScanService` | `lib/core/services/hardware_scan_service.dart` | UI-free payload classification, 1.5 s throttle, `scanUuid` idempotency key |
| `ScanViewMixin` | `lib/core/shared_widgets/scan_view_mixin.dart` | Branded scan-boundary overlay |
| Barcode scanner widget | `lib/shared/widgets/scanners/barcode_scanner.dart` | Camera preview + `mobile_scanner` wiring |
| Store-keeper scanner screen | `lib/features/factory/store_keeper/presentation/screens/scanner_screen.dart` | Reference implementation for torch, batch mode, manual entry, lifecycle |
| Existing scan bloc | `lib/features/universal/customer/presentation/bloc/customer_super_app_bloc.dart` | The scan → verify event/state pair (see §7) |

**⚠️ Do not extend the on-device Rust path.** `customer_super_app_bloc.dart:31-40` wires
`nativeVerifier` to `RustSerialValidator.verifySerialOnDevice(batchId: 'customer-scan-batch',
secretKey: 'NEXATRACE_CUSTOMER_VERIFY', seed: ...)` — those are **dummy constants**, and the native
symbol it looks up does not exist (§13.3). It can never return a correct answer. Worse, the vault
lives in Postgres, so on-device verification cannot be authoritative without shipping a synchronised
copy of the vault.

**Decision: the server is the authority. Remove the dummy native path.**

### 6.2 The flow

```
Dashboard "Scan" ──▶ Camera sheet (mobile_scanner)
                        │  raw string
                        ▼
              HardwareScanService.processPayload()
                        │  ScanResult(type, rawPayload, scanUuid)
                        ▼
        [classify] cryptoSHA256 / nexaTraceUrl → extract 64-hex
                        │
                        ▼
        ProductScanSubmitted(serialHash, scanUuid)
                        │
                        ├─ online  ──▶ POST /api/v1/marketplace/consumer/verify
                        │                 (+ lat/lng from the location source)
                        └─ offline ──▶ queue via the existing sync engine
                                          (scanUuid = idempotency key) → "Pending"
                        │
                        ▼
        ProductScanResultReceived(isAuthentic, alreadyActivated,
                                  cashback, productInfo, velocityDiverted)
                        │
                        ▼
              Result card ──▶ scan re-enabled
```

### 6.3 Event / state contract

**Events:** `ProductScanRequested`, `ProductScanSubmitted(serialHash, scanUuid)`,
`ProductScanResultReceived(payload)`, `ProductScanReset`.

**States:** `idle` → `scanning` → `verifying` → one of
`verified` · `alreadyVerified` · `counterfeitRisk` · `queuedOffline` · `failed(retryable)`.

The bloc owns **no** cashback arithmetic — `cashback` comes back from the server.
(`customer_super_app_bloc.dart` currently hardcodes `_rewardPerScan = 5`; that is demo data and must
not survive into the real flow.)

### 6.4 Result wording rules

| Case | Wording |
|---|---|
| In the vault, first scan | "Verified — this is a genuine TraceOdd-coded product." + cashback amount from the server |
| In the vault, already scanned | "Already verified" + product info. **Not** an error — the same product may legitimately be re-checked |
| Not in the vault | **"Not found in TraceOdd records — possible counterfeit."** Offer a *report* action (Module 8N). |
| Location missing | Verify anyway; never fabricate coordinates |

**Never accuse the shopkeeper.** A genuine product can be mis-coded or a code mis-read. The negative
case must read as *"we could not confirm this"* plus a route to report — not as a verdict on the
seller. This is the same restraint logic Pillar A applies to banknotes, for the same reason: a false
negative damages a real business.

### 6.5 Localisation

Result strings belong in the translation resources (`assets/translations/{en,ur}.json`), following the
same key-parity rule as the banknote strings. Add a `productScan.*` group.

---

## 7. This pillar *is* the duplicate consolidation (plan §6)

There are **two** customer super-app implementations:

| | Live (routed) | Orphaned |
|---|---|---|
| Path | `lib/features/bus_operations/presentation/pages/customer_super_app_screen.dart` | `lib/features/universal/customer/` |
| Scan flow | a **synthetic demo event** (`_onScanPressed` — *"In production, this opens a camera scanner sheet"*) | **a real scan → verify bloc** |
| Routed? | ✅ `app_router.dart` → `/customer/home` | ❌ nothing imports it |

`PANEL-SEPARATION-PLAN.md` §6 already prescribes the correct order: **port the orphaned copy's unique
features into the live screen first, then delete the folder.**

**So step B2 is exactly that port, and it is the same work as plan Phase 7.** Doing Pillar B without
doing the merge would mean building the scan flow a third time.

---

## 8. Where else this scanner belongs

| Surface | Endpoint | Why |
|---|---|---|
| #3 Universal Customer App | `marketplace/consumer/verify` | Consumer cashback + trust |
| #8 Factory Store Keeper | `factory/production/verify-serial` | Verify before linking/stock-in |
| #9 Factory Driver | `factory/production/verify-serial` | Verify on delivery |
| #6 Shop Keeper | `factory/production/verify-serial` | Verify before stock-in |
| #1 Super Admin | counterfeit report queue | Review flagged codes |

One shared scan widget; the endpoint differs per surface. That is the design.

---

## 9. Delivery plan

| Step | Work | Depends on |
|---|---|---|
| **B1** | Fix the stale route-map entry in `panel_routes.dart:305` and decide the location source (§5) | — |
| **B2** | Consolidate the two customer super-app copies (plan §6): port the scan bloc into the live screen, delete `universal/customer/` | B1 |
| **B3** | Camera sheet + wire `HardwareScanService` → verify bloc → **server** verification; build the result card | B2 |
| **B4** | Offline path through the existing sync engine, `scanUuid` as the idempotency key | B3 |
| **B5** | Reuse the same sheet on the staff surfaces with `verify-serial` | B3 |
| **B6** | Counterfeit report action (Module 8N) — confirm the backend exists first | B5 |

**B1 and B2 are prerequisites for everything else** — and B2 is already a plan requirement, so nothing
here is wasted work.

---

## 10. Open items

| # | Item | Owner |
|---|---|---|
| 1 | **Location plugin decision** — one choice unblocks Pillars B, C and E (§5) | Owner + dev |
| 2 | Cashback policy — is a one-time cashback per serial intentional, and what governs the amount? (Currently only the server knows; the Flutter constant `5` is demo data) | Owner |
| 3 | Module 8N counterfeit-report backend — does it exist? (not verified in this pass) | Dev |
| 4 | Should the on-device Rust verification path be removed outright, or kept as an offline pre-filter? **Recommendation: remove** — the vault is server-side | Owner |
| 5 | Confirm the QR payload really is the 64-hex hash on live printed codes (§4 assumes it; check one real carton) | Owner |
| 6 | Localisation keys for the result card (`productScan.*`) | Dev |

---

## 11. Provenance

| Date | Change |
|---|---|
| 2026-09-25 | Created. Endpoint contract, response shapes and the `consumer.php` route-map mismatch verified from source. Existing Flutter reuse points and the dummy native-verification path identified. Delivery plan and open decisions recorded. |
