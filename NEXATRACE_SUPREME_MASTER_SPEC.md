# TRACE ODD — SUPREME MASTER ARCHITECTURE SPECIFICATION
## Universal Source of Truth · Production Roadmap 2026 · v4.1

---

> **PROTOCOL FOR ALL AI AGENTS & DEVELOPERS:** This document is the absolute, unified, and singular Source of Truth for the entire Trace Odd ecosystem. It replaces all prior master files (`PROJECT_MASTER.md`, `PROJECT_LOGICS_TREE.md`, and all derivative specifications). It integrates the original ~4,000‑line business requirement trees, ~30 % tactical on‑floor adaptations already present in production code, the full technical modernization blueprint of 2026, and the 15‑module product registry. **No code generation, architecture decision, or feature planning shall proceed without strict reference to this document.**

---

## TABLE OF CONTENTS

1. [Advanced Tech Stack & Architecture Platform](#1-advanced-tech-stack--architecture-platform)
2. [Core Architecture Laws & UI Design Mandates](#2-core-architecture-laws--ui-design-mandates)
3. [The 15-Module Master Registry](#3-the-15-module-master-registry)
   - [Module 1 — Super Admin Panel](#module-1--super-admin-panel)
   - [Module 2 — Sub-Admin Panels](#module-2--sub-admin-panels)
   - [Module 3 — Factory Enterprise Panel](#module-3--factory-enterprise-panel)
   - [Module 4 — Factory Drivers App](#module-4--factory-drivers-app)
   - [Module 5 — Store Keepers App](#module-5--store-keepers-app)
   - [Module 6 — Reseller App](#module-6--reseller-app)
   - [Module 7 — Shop Keepers App](#module-7--shop-keepers-app)
   - [Module 8 — Customers App (2-in-1: Product Auth + Bus Transit)](#module-8--customers-app)
   - [Module 9 — Goods Company Admin Panel](#module-9--goods-company-admin-panel)
   - [Module 10 — Truck Owners App](#module-10--truck-owners-app)
   - [Module 11 — Truck Drivers App](#module-11--truck-drivers-app)
   - [Module 12 — B2B Marketplace Platform](#module-12--b2b-marketplace-platform)
   - [Module 13 — Public Transport Bus Admin Panel](#module-13--public-transport-bus-admin-panel)
   - [Module 14 — Bus Owners App](#module-14--bus-owners-app)
   - [Module 15 — Bus Drivers App](#module-15--bus-drivers-app)
4. [Cross-Cutting Architectural Concerns (12A–12O)](#4-cross-cutting-architectural-concerns-12a12o)
5. [Subscription Plans System](#5-subscription-plans-system)
6. [Implementation Status Matrix](#6-implementation-status-matrix)
7. [Backend Infrastructure Blueprint](#7-backend-infrastructure-blueprint)
8. [Deployment & CI/CD](#8-deployment--cicd)
9. [Security Framework](#9-security-framework)

---

## 1. ADVANCED TECH STACK & ARCHITECTURE PLATFORM

### 1.1 Frontend — Flutter + BLoC + Rust

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | Flutter SDK | ≥3.8.0 | Cross-platform UI (iOS, Android, Web, Linux, macOS, Windows) |
| **State Management** | flutter_bloc + bloc | ^9.1.1 / ^9.2.0 | Enterprise tracing, immutability, transactional data integrity |
| **Stream Optimization** | RxDart (EventTransformers) | latest | Debounce high-frequency barcode streams (500 ms window), `switchMap` for scan bursts |
| **Offline Persistence** | Hydrated BLoC + Hive | ^2.2.3 | Auto-hydrate BLoC state; queue mutations offline → sync on network heartbeat |
| **Rust Native Bridge** | flutter_rust_bridge + dart:ffi | ^2.11.1 / ^2.1.0 | Microsecond-level code parsing, cryptography, camera pipeline |
| **Navigation** | GoRouter | ^17.1.0 | Declarative, guard-based routing per module |
| **Networking** | Dio + http | ^5.4.0 / ^1.2.2 | REST API client with interceptors for auth, logging, retry |
| **Local Storage** | SharedPreferences, flutter_secure_storage | ^2.2.2 / ^10.0.0 | Token persistence; Hive for offline scan records |
| **Charts / Visuals** | Syncfusion Flutter Charts | ^33.1.47 | Dashboard analytics, telemetry graphs |
| **QR / Barcode** | mobile_scanner + qr_flutter + barcode | ^7.2.0 / ^4.1.0 / ^2.2.0 | On-device scanning, code generation rendering |
| **Maps** | Google Maps (flutter plugin) | latest | Geofence enforcement, live fleet tracking |
| **Connectivity** | connectivity_plus | ^7.0.0 | Network heartbeat detection for offline-first logic |

### 1.2 Backend — Laravel + Distributed Infrastructure

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Framework** | Laravel | ^12.0 | Enterprise logic core, REST API |
| **Language** | PHP | ≥8.3 | Server-side execution |
| **Primary Database** | PostgreSQL | 16+ | ACID-compliant relational data (codes, companies, transactions) |
| **Queue System** | Laravel Queues (Redis driver) | — | Async bulk code generation (millions of QR/ITF‑14), notification blasts, freight auction matching |
| **Cache Matrix** | Redis | 7+ | Analytics dashboard caching (1D), live fleet geospatial cache (9H, 13C), session state |
| **WebSocket Layer** | Laravel Reverb / Soketi + Redis Pub/Sub | — | Full-duplex persistent connections for live truck/bus telemetry, real-time chat |
| **Real-Time Sync Hub** | Supabase (Realtime) | latest | B2B commercial chat (12F), edge data replication |
| **Full-Text Search** | Elasticsearch | 8+ | Wholesale inventory search (12B), multi-attribute indexing <20 ms |
| **File Storage** | Laravel Filesystem (S3-compatible) | — | PDF invoices, proof-of-delivery photos, document uploads |
| **CI/CD** | Git-hook triggered deployment | — | `git push` → automated Flutter build + Laravel deploy on Hetzner |

### 1.3 Rust Performance Core — Native FFI

| Concern | Rust Crate | FFI Surface |
|---------|-----------|-------------|
| Code generation (Bundle/Carton/Packet/Unit) | `generators::bundle`, `generators::carton`, `generators::packet`, `generators::unit` | `generate_*_codes()`, `generate_*_codes_batch()` |
| Hierarchical code generation | `generators::hierarchical` | `generate_hierarchical_codes()` |
| International standards (GS1, ITF‑14, QR, DataMatrix) | `international::gs1`, `international::qr`, `international::barcode` | `generate_gs1_code()`, `generate_qr_code_data()`, `generate_barcode_data()` |
| Cryptographic auth codes | `algorithms::authentication` | `generate_authentication_code()`, `verify_authentication_code()` |
| Checksum calculation | `algorithms::checksum` | `calculate_checksum()` |
| AES / ChaCha20 encryption | `algorithms::encryption` | `encrypt_code_data()`, `decrypt_code_data()` |
| Code validation | `utils::validation` | `validate_code_format()` |
| Camera binarization + OCR parse | Planned for v2 | Rust-cv / image crate → Dart FFI |

---

## 2. CORE ARCHITECTURE LAWS & UI DESIGN MANDATES

### 2.1 Strict UI Scannability Enforcements
- **Rule:** Every application view that contains long forms or dynamic multi-record lists **MUST** be wrapped inside a visible `Scrollbar` widget enclosing a `SingleChildScrollView`.
- **Rule:** Any `ListView`, `GridView`, or similar scrollable widget nested inside a `SingleChildScrollView` **MUST** be configured with `shrinkWrap: true` and `physics: const NeverScrollableScrollPhysics()`.
- **Purpose:** Eliminate scroll conflicts across web viewports and physical mobile devices; guarantee consistent UI profile in all deployment targets.

### 2.2 State Isolation Boundaries
- **Rule:** Application domains **MUST** completely isolate their state processing environments.
- **Rule:** Cross-application communication is **STRICTLY FORBIDDEN** through direct BLoC-to-BLoC bindings.
- **Rule:** All inter-module communication **MUST** flow exclusively through:
  1. Clean REST API data repositories (primary path), OR
  2. Decoupled background sync networks (WebSocket / Redis Pub/Sub for telemetry).
- **Rationale:** Prevents implicit coupling, enables independent deployment of modules, guarantees audit trail completeness.

### 2.3 Offline-First Data Mutator Guarantees
- **Rule:** Any user action that mutates data state within **Store Keepers** (Module 5) or **Factory Drivers** (Module 4) **MUST** check the physical network connection state via `connectivity_plus` before attempting an API call.
- **Rule:** If offline, the transaction payload **MUST** be:
  1. Serialized into local Hive storage,
  2. The UI state updated to display a distinct `"Pending Sync"` badge,
  3. Queued for automatic synchronization upon network heartbeat detection.
- **Rule:** Sync conflicts **MUST** be resolved by server-side timestamp (last-write-wins for non-critical; first-scan-wins for code uniqueness).

---

## 3. THE 15-MODULE MASTER REGISTRY

> **STRATEGIC AMENDMENT (2026-05-22):** The original 17-module blueprint has been consolidated to 15 modules:
> - **Module 16 (Bus Passenger App)** → Consolidated into **Module 8 (Customers App)** as a unified 2-in-1 interface handling both product anti-counterfeit verification AND live bus tracking/ticket booking. Passengers use the exact same Trace Odd Customer App.
> - **Module 17 (P2P Intercity Trip Sharing)** → **Permanently removed.** Private car trip sharing creates a direct conflict of interest with commercial Bus Fleet Operators. This module is shelved for a standalone future project under a different brand, to be launched alongside a Restaurant Food Delivery network.

> **🚨 GLOBAL STACK REQUIREMENT (MANDATORY FOR ALL APPS & PANELS):**
> Every single Mobile App (Flutter) and Admin Panel (Web) in this ecosystem must seamlessly interact with the central backend infrastructure. Any app performing high-frequency data logging or critical tracking **MUST** implement:
> - **Offline Sync Processing Client Payloads** (with Unique UUIDs per action) — dispatched via `POST /api/v1/sync/submit` to the `sync` queue, processed by `OfflineSyncProcessingJob` with idempotency guarantees.
> - **Laravel WebSockets / Redis Pub/Sub** for instant real-time notifications — subscribe to channels defined in Step 3 (e.g., `fleet.{company_id}`, `trip.{trip_id}`, `store_keeper.{id}`).
> - **Isolated Routing Prefixes** (`/api/v1/*`) established in Step 11 — each panel's routes live in `routes/panels/{panel}.php`, registered via `PanelRouteServiceProvider`.
> - **Redis Cache Integration** — all dashboards and analytics MUST read from Redis via `RedisCacheService` (Step 1) before falling back to direct database queries.

---

### MODULE 1 — SUPER ADMIN PANEL
**Domain:** Universal Control Framework · **Code Namespace:** `nexa_admin`  
**Flutter Entry:** `lib/features/nexa_admin/` · **Backend:** `app/Http/Controllers/Admin/`  
**Build Status:** ████████░░ 90 % — Core billing, company/plan CRUD, transport wallet, routing complete

#### 1A — Command Center Dashboard
> **[REQUIRED TECH-STACK & INTEGRATION POINTS]**
> - **Super Admin Financial Controller Layer** (Step 13): Process bus operator voucher settlements and customer wallet withdrawal refunds via `CommissionService` with `lockForUpdate()`.
> - **Double-Entry Ledger System Audit Logs** (Step 8): View all `financial_wallet_transactions` with immutable audit trail; verify platform treasury balance.
> - **Realtime Analytics Charts Dashboard** (Step 9): Pull pre-computed metrics from Redis cache (60 s TTL) via `GET /api/v1/analytics/dashboard`; time-series charts via `GET /api/v1/analytics/charts`.
> - **Central Notification Engine** (Step 7): Dispatch blasts via `POST /api/v1/admin/notifications/blast` — filtered by company, plan tier, role.
> - **Stack Tags:** Laravel Sanctum, Redis Analytics Cache Reader, Pessimistic Lock Monitors, WebSocket `admin.fraud` channel.
- Global telemetry data streams aggregated from all ecosystem nodes.
- Server health nodes (Hetzner CPU, RAM, disk, PostgreSQL connection pool) displayed via Syncfusion real-time charts.
- Ecosystem activity charts: daily scans, active factories, active drivers, codes published.
- Quick-action shortcut buttons: Create Plan, Register Company, View Audit Logs, Send Announcement.
- **Tech:** Redis-cached analytics matrix refreshing every 60 seconds via Laravel scheduled job; BLoC `Emit` limited to avoid memory pressure on 8 GB RAM servers.
- **Built:** ✅ Dashboard layout, stat cards, navigation shell.

#### 1B — Advanced Subscription & Monetization Engines
- Tiered SaaS contract control: Free, Basic ($49/mo), Standard ($149/mo), Premium ($499/mo), Custom (negotiated).
- Per-plan code limits, store limits, driver limits, transport feature gates.
- Overage pricing: defined per-unit rates for codes exceeding monthly quota.
- Automated invoice generation on code Publish events.
- Plan CRUD: Create, Read, Update, Delete with feature-matrix toggle UI.
- **Tech:** `AdminPlanController`, `SubscriptionPlan` Eloquent model, `AdminBillingController`.
- **Built:** ✅ Plan list, create plan screen, plan edit, feature matrix.

#### 1C — Administrative Cross-Module Coding Hub
- Central interface for coding requirements that span multiple downstream panels.
- After completing primary billing/plan screens, Super Admin uses this to configure system-wide parameters.
- **Built:** ⚠️ Stub — routing exists, full feature pending.

#### 1D — Optimization Target Matrix (Redis Cache)
- Global analytics charts stored in Redis Memory Matrix to avoid redundant PostgreSQL scans.
- Dashboard widgets pull from Redis with 1-hour TTL; cache invalidated on publish events.
- **Tech:** `Cache::store('redis')` facade, `RedisCacheService`.
- **Built:** ⚠️ Redis config ready; cache service logic in progress.

#### 1E — Immutable Ecosystem Transaction Auditing
- Comprehensive audit trail logging: which Super Admin or Sub-Admin changed which setting, blocked which user, deleted which data.
- Log schema: `actor_id`, `actor_type`, `entity_type`, `entity_id`, `old_value` (JSON), `new_value` (JSON), `action`, `ip_address`, `device_fingerprint`, `timestamp`.
- Immutable append-only storage; 7-year minimum retention.
- Full-text search across audit entries.
- Monthly signed audit exports (CSV + SHA‑256 hash).
- **Built:** ⚠️ Audit model exists; logging pipeline pending.

#### 1F — Central Notification Engine
- Super Admin sends push notifications, SMS, or email to all panels simultaneously.
- Target filtering: by company, by plan tier, by role, by geographic region.
- Multi-channel delivery: in-app (WebSocket), push (FCM), email (Laravel Mail), SMS (Twilio gateway).
- User opt-out preferences per notification type.
- **Tech:** Laravel Notification system + Queue Jobs for blast delivery.
- **Built:** ⚠️ `NotificationService.php` exists; multi-channel dispatch pending.

#### 1G — Integration Hub (Third-Party API Centralization)
- Single-entry configuration for all external service API keys: TCS, Leopards, Zoho Books, Twilio, Google Maps, Payment Gateways.
- Super Admin determines which Sub-Admins or Factories have permission for each integration.
- Keys encrypted at rest (AES‑256) via Laravel encryption.
- **Built:** ❌ Not started.

#### 1H — Dispute Resolution Center
- Review and adjudicate wallet deduction complaints.
- Full context view: original transaction, parties involved, escrow timeline, evidence uploads.
- Actions: Uphold deduction, Reverse deduction, Partial refund, Escalate to mediation.
- **Built:** ❌ Not started.

#### 1I — Subscription Limit Enforcement & Overage Management
- Real-time monitoring of plan limits: code counts, store locations, driver accounts, API calls.
- 90 % threshold warning notifications (in-app + email).
- Overage pricing defined per plan tier.
- Hard limit enforcement: prevent code publishing if quota exceeded without active overage agreement.
- **Built:** ❌ Not started.

#### 1J — Financial Reconciliation & Revenue Reporting
- Monthly automated reconciliation: subscriptions vs. payments vs. refunds.
- Reports segmented by plan tier, region, company.
- Payment gateway record validation.
- **Tech:** `RevenueService.php`, `ReconciliationService.php`.
- **Built:** ⚠️ Services exist; UI screens pending.

#### 1K — Sub-Admin Permission Matrix & Delegation
- Granular permission definitions per Super Admin function.
- Role templates: Plans Manager, Billing Manager, Companies Manager, Integrations Manager, Notifications Manager.
- All delegation actions audited.
- **Built:** ❌ Not started.

#### 1L — Backup, Archive & Data Retention Policies
- Retention windows: audit logs (7 years), scan records (3 years), transaction history (7 years).
- Automated backup to secondary location (S3-compatible).
- GDPR Data Export API endpoint (ZIP/JSON within 30 days).
- Right to Delete with legal exception handling.
- **Built:** ❌ Not started.

#### 1M — Proactive Fraud Detection Dashboard
- Real-time monitoring of suspicious patterns: multiple IP logins, unusual API call spikes, abnormal code generation rates, geographic impossibilities.
- Fraud score (0–100) per account.
- Auto-alert Super Admin; auto-disable risky accounts above threshold.
- **Tech:** ML-based anomaly detection pipeline (future); rule-based engine (current).
- **Built:** ❌ Not started.

#### 1N — Tiered Rate Limiting & API Quota Management
- Rate limits per plan: Free (100 req/min), Basic (500), Standard (2,000), Premium (10,000).
- Real-time consumption tracking dashboard.
- Burst capacity for legitimate traffic spikes.
- **Tech:** Laravel throttle middleware + Redis rate limiter.
- **Built:** ❌ Not started.

#### 1O — Announcement & Maintenance Scheduling
- Platform announcements visible to all logged-in users.
- Scheduled maintenance with countdown timer and auto-logout window.
- **Built:** ❌ Not started.

#### 1P — Custom Workflow Builder
- Conditional workflow engine: auto-approve orders <$10K, require manual approval for >$50K.
- Apply to payment approval, shipment triggering, escalation rules.
- **Built:** ❌ Not started.

---

### MODULE 2 — SUB-ADMIN PANELS
**Domain:** Delegated Enterprise Authority · **Code Namespace:** Part of `nexa_admin`  
**Build Status:** ██░░░░░░░░ 15 % — Role scaffolding exists; full delegation engine pending

#### 2A — Dynamic UI Feature Accessibility Mapping
- Structural authorization system altering workspace UI based on parameters delegated by Super Admin.
- Feature flags per Sub-Admin: visible menu items, accessible API endpoints, editable fields.
- **Built:** ❌ Not started.

#### 2B — Operational Role Separation Protocol
- Defined role profiles: Factory Manager, Finance Manager, Transport Manager, Support Lead.
- Disallowed system components completely culled from execution layers (not merely hidden — server-side enforcement).
- **Built:** ❌ Not started.

#### 2C — Role-Focused Analytical Dashboards
- Finance Manager: billing dashboard (invoices, payments, revenue graphs), subscription status, credit limits.
- Factory Manager: code generation stats, product throughput, Store Keeper activity, driver performance.
- Transport Manager: fleet telemetry, active trips, auction statistics.
- Support Lead: open disputes, ticket queue, customer satisfaction metrics.
- **Tech:** Scoped Eloquent queries filtered by `sub_admin_role`; BLoC scoped per dashboard type.
- **Built:** ❌ Not started.

#### 2D — Audited Performance Report Engine
- On-demand system reports within Sub-Admin's authorized scope.
- Auto-binds non-removable digital watermark: Sub-Admin's encrypted token + generation timestamp.
- Export formats: PDF, CSV, JSON.
- **Built:** ❌ Not started.

#### 2E — Escalation & Handoff Workflow
- Sub-Admin escalates issue to Super Admin with full context.
- Super Admin can take ownership or delegate to different Sub-Admin.
- All escalations tracked in immutable audit log.
- **Built:** ❌ Not started.

---

### MODULE 3 — FACTORY ENTERPRISE PANEL
**Domain:** Production & Code Lifecycle Management · **Code Namespace:** `factory/admin`  
**Flutter Entry:** `lib/features/factory/admin/` · **Backend:** `app/Http/Controllers/Factory/`  
**Build Status:** ████████░░ 85 % — Product CRUD, all four code-type generation flows, billing, store keeper/driver CRUD; publishing pipeline complete

#### 3A — Multi-Category Production Workflow Forms
- Product creation with mandatory category selection: Food/Medical vs. Non-Food/Industrial.
- Food/Medical: mandatory MFG date, Expiry date fields.
> **[REQUIRED TECH-STACK & INTEGRATION POINTS]**
> - **Bulk Code Generation Engine** (Step 2): Large-volume code generation dispatched async via `POST /api/v1/factory/codes/bulk` to the `high` queue; progress polling via `GET /api/v1/factory/codes/bulk/{jobId}`.
> - **Real-Time Dispatch Broadcasting** (Step 3): Subscribe to `fleet.{company_id}` WebSocket channel for live driver location; `TripStatusChanged` event for trip lifecycle.
> - **Financial Ledger** (Step 8): Factory billing via `CommissionPayoutJob` on code publish; driver earnings recorded as immutable `wallet_transactions`.
> - **Offline Sync** (Step 10): Factory Drivers use `POST /api/v1/sync/submit` with client UUIDs for offline trip/expense data.
> - **Stack Tags:** Laravel Queues (high), Bulk Serial Parsers, Redis Pub/Sub, WebSockets for live driver location, Geofencing (100 m), Rust FFI for code validation.
- Non-Food/Industrial: total warranty months field (warranty starts on customer scan date).
- Product list screen with grid/table view, search, filter by category.
- **Tech:** `ProductController`, `Product` Eloquent model; `ProductsBloc` in Flutter.
- **Built:** ✅ Fully functional.

#### 3B — Bundle Code Generation & Management
- Generate bundle codes with prefix, sequence range, factory ID.
- Bundle code list screen showing all generated codes with associated metadata.
- Related action buttons: Publish, Edit (pre-publish), Delete (pre-publish), Download PDF/CSV.
- **Tech:** `BundleController`, `Bundle` Eloquent model; `BundleBloc`, `BundleCodesBloc`; Rust FFI for high-speed batch generation via `RustIntegrationService`.
- **Built:** ✅ Generate, list, publish, download flows complete.

#### 3C — Structural Code Aggregation Binding (Store Keeper + International)
- Bundle code generation simultaneously creates paired Store Keeper dynamic verification codes.
- ITF‑14 / GS1‑128 international supply chain codes generated alongside via Rust FFI `generate_gs1_code()`.
- **Built:** ✅ Backend mapping complete; Rust FFI call wired.

#### 3D — Publishing Workflow & Print-Ready Export
- Pre-publish: codes are editable and deletable.
- On Publish: status changes to "Published"; codes become immutable; download for printing press enabled.
- **Rule:** After publishing, codes CANNOT be deleted.
- Download format: PDF with printable QR/barcode, CSV for bulk printing.
- **Built:** ✅ Fully functional.

#### 3E — Post-Publish Immutability
- Published bundle codes locked from edit/delete.
- **Built:** ✅ Enforced at backend and UI level.

#### 3F — Carton Code & Packet Code Generation
- Identical workflow to Bundle (3B–3E) for Carton and Packet code types.
- Each with independent generate → list → publish → download pipelines.
- **Tech:** `CartonCodesBloc`, `PacketCodesBloc`; respective Laravel controllers; Rust FFI batch generation.
- **Built:** ✅ Generate, list, publish, download flows complete. Multi-format support (ITF‑14, GS1‑128, Code128, QR, DataMatrix) via Rust.

#### 3G — Unit Code (Authentication Code) Generation
- No product selection required at generation time.
- Mandatory Batch Name field (grouping identifier).
- Batch generation: quantity = 5 → all 5 under one Batch Name with sequential serial numbers.
- Post-generation linking on list screen:
  - Dropdown per batch to select product.
  - MFG/Expiry dates: auto-populate from product defaults; editable override.
- Publish triggers:
  - Batch download enabled.
  - Billing calculation: tier rate × batch quantity automatically applied.
- **Built:** ✅ Complete flow.

#### 3H — Unit Code Authenticity Distinction
- Unit codes do NOT have international codes (unlike Bundle/Carton/Packet).
- Instead: each unit receives an authentic/fake verification code for customer anti-counterfeit scanning.
- **Tech:** Rust `generate_authentication_code()` + `verify_authentication_code()`.
- **Built:** ✅ Distinction enforced; auth codes generated.

#### 3I — Product Linking Enforcement
- Unit codes CANNOT be published until a product is linked to the batch.
- Unpublished codes CANNOT be downloaded.
- **Built:** ✅ Conditional gating at UI and API level.

#### 3J — Bundle/Carton/Packet Independence
- These code types are NOT linked to any product at publish time.
- Product linking happens later through Store Keeper app (Module 5).
- **Built:** ✅ Independence enforced.

#### 3K — Subscription Plan Application Timing
- Super Admin subscription plan applies at Publish time.
- Codes generated but not yet published are NOT counted against plan limits.
- **Built:** ✅ Gating logic in publish handler.

#### 3L — Product Management CRUD
- Product creation screen, product list screen.
- **Built:** ✅ Complete.

#### 3M — Product Type Differentiation
- Food/Medical: MFG date + Expiry date tracking fields.
- Non-Food/Industrial (Electronics, Engine Oil, etc.): warranty period in months.
- Customer scan of non-food product triggers warranty start.
- **Built:** ✅ Type differentiation and warranty tracking.

#### 3N — Product Lifecycle Actions
- Update, Delete, Activate, Deactivate, Block product.
- **Built:** ✅ All actions implemented.

#### 3O — Factory Personal Driver Management
- Create driver, driver list, update, delete, activate, deactivate, block.
- Full mirror of driver functionality visible from admin panel.
- **Tech:** `DriverController`, `Driver` Eloquent model; `DriversBloc`.
- **Built:** ✅ CRUD complete.

#### 3P — Reseller / Shop Keeper Linking
- Link resellers or shopkeepers to factory via QR code scan or configuration form.
- **Built:** ⚠️ Linking forms exist; QR-based linking pending.

#### 3Q — Linked Entity Record Keeping
- Maintain record of all linked shops, resellers, and commission agents.
- **Built:** ⚠️ Database relationships defined; UI listing in progress.

#### 3R — Pricing & Commission Configuration
- Set product price for resellers/shopkeepers.
- Define commission rates for commission agents.
- **Built:** ⚠️ Fields exist in schema; UI in progress.

#### 3S — Downstream App Adaptation
- Admin panel adapts to requirements of Shopkeeper, Reseller, and Commission Agent apps.
- **Built:** ⚠️ Ongoing as downstream modules evolve.

#### 3T — Anti-Counterfeit Analytics
- Repeated scan of same authentic code from different cities → alert factory.
- Pattern: "this code has appeared in the market as a copy."
- **Tech:** Scan geolocation tracking; anomaly detection query.
- **Built:** ❌ Not started.

#### 3U — Batch Code Import & CSV Template Upload
- Bulk import code mappings from CSV: `bundle_id, carton_ids, packet_ids, unit_ids`.
- Validation: duplicate check, hierarchical integrity.
- Preview before confirm.
- **Built:** ❌ Not started.

#### 3V — Code Generation Scheduling & Reservation
- Schedule code generation for off-peak hours (nightly batch jobs).
- Reserve monthly code quota upfront.
- Prevent overspend.
- **Tech:** Laravel Queue Job (`BulkCodeGenerationJob`) dispatched with `delay()`.
- **Built:** ❌ Queue job class not yet created.

#### 3W — Product Versioning & Change History
- Track product attribute changes: price, expiry date, warranty period.
- Active version vs. historical versions display.
- Rollback to previous version.
- Capture: who changed what and when.
- **Built:** ❌ Not started.

#### 3X — Re-Linking & Store Keeper / Reseller Audit Trail
- Log who linked to whom, when, for which product batch.
- Factory can view all active links.
- Revoke access to specific Store Keepers.
- **Built:** ❌ Not started.

#### 3Y — Commission & Pricing Rule Engine
- Volume-tiered commission: 0–1K codes = 5 %, 1K–10K = 7 %, 10K+ = 10 %.
- Auto-apply based on actual scan counts.
- Monthly commission reports.
- **Built:** ❌ Not started.

#### 3Z — Inventory Sync & Code Depletion Warnings
- Track scanned (consumed) vs. unused codes.
- 80 % consumed → auto-alert Factory to plan reorder.
- Show depletion velocity (codes/day).
- **Built:** ❌ Not started.

#### 3AA — Multi-Language & Multi-Currency Product Definitions
- Define products in multiple languages.
- List prices in multiple currencies.
- Store Keeper app displays based on locale.
- **Tech:** Laravel `spatie/laravel-translatable`; Flutter `flutter_localizations`.
- **Built:** ❌ Not started.

#### 3AB — Product Recall Management
- Mark product batch as Recalled.
- Auto-notify all linked Store Keepers, Drivers, and Customers who scanned that batch.
- Prevent further scanning of recalled product codes.
- **Built:** ❌ Not started.

#### 3AC — Driver Performance Analytics
#### 3AC — Cryptographic Serial Generation (SHA256 Vault)
- Product serials NOT predictable integers. Every unique ID = SHA256(Batch ID + Factory Secret Key + Incremental Seed).
- Immutable cryptographic signature prevents brute-force emulation of valid product identifiers in retail market.
- **Tech:** hash_hmac SHA256 batch-insert via ProductionVaultService::generateSecureBatchItems().
- **Built:** Not started.
#### 3AD — Batch Production Lifecycle States
- Linear states: draft → in_production → sealed_locked → released_for_transit.
- Supervisor Electronic Release Gate: batch cannot be dispatched unless status = released_for_transit.
- Transition requires factory supervisor digital signature hash verification interceptor.
- **Tech:** production_batches table; FactoryProductionController atomic state transitions with lockForUpdate().
#### 3AE — Reverse Logistics & Damage Claims (Cross-Module)
- Shopkeepers/Resellers file return or damage claims for specific cryptographic product serials purchased via Marketplace.
- Items individually tracked by crypto_serial_hash to prevent double-claiming.
- Damage claims require strict live camera input (no gallery). System embeds immutable server timestamp + GPS metadata.
- Status: pending_inspection → approved_refund | rejected. Approval triggers atomic reverse ledger.
- **Tech:** reverse_logistics_claims table; ReverseLogisticsService with lockForUpdate() on financial ledger; auto-debit factory escrow + credit shopkeeper wallet; serial flagged_damaged_disposed.
- **Built:** Not started.
- **Built:** Not started.
- Per-driver metrics: delivery success rate, average delivery time, customer ratings, code scanning compliance (% deliveries with proof).
- Highlight underperformers.
- **Built:** ❌ Not started.

#### 3AD — Store Keeper Shift Management & Attendance
- Define shifts (e.g., 8 AM–5 PM).
- Track clock-in/out via app.
- Auto-disable scanning outside scheduled hours (configurable).
- Generate attendance reports.
- **Built:** ❌ Not started.

#### 3AE — Factory Billing Dashboard
- Dedicated Billing section per Factory Admin.
- Displays: current Owed Balance to Trace Odd, outstanding invoices, payment due dates, credit limit status, payment method on file.
- **Tech:** `FactoryBillingController`, `InvoiceService`.
- **Built:** ✅ Billing dashboard, invoice list, payment history complete.

#### 3AF — Pay-per-Publish Billing Model
- Cost calculated based on subscription tier at Publish moment.
- Invoice auto-generated upon publish reflecting tier-based rate × number of codes.
- **Built:** ✅ Calculated at publish handler.

#### 3AG — Download Lock (Payment Gate)
- Prevent code PDF/CSV download until invoice for that batch is paid or cleared via wallet/credit limit.
- Unpaid batches show locked download icon with outstanding amount displayed.
- **Built:** ✅ Gating logic implemented.

#### 3AH — Factory Payment History & Ledger
- Clear ledger: invoice number, date, amount, payment method, status (paid/pending/overdue), downloadable receipt.
- **Built:** ✅ Ledger screen with filtering.

---

### MODULE 4 — FACTORY DRIVERS APP
**Domain:** Last-Mile Fleet Execution · **Code Namespace:** `factory/driver`  
**Flutter Entry:** `lib/features/factory/driver/` · **Entry Point:** `lib/main_driver.dart`  
**Build Status:** ██████████ 100 % — All sub-modules implemented in BLoC + Rust FFI integration

#### 4A — Inbound Cargo Handshake Verification
- Driver receives product by scanning it through the app.
- Physical hardware scan confirmation of assigned asset identifiers.
- Flutter BLoC State Validation (`DriverBloc` → `ScanPickup` event) before asset custody is assigned.
- **Tech:** `DriverBloc._onScanPickup()` → `DriverRepository.scanPickup()`; Rust FFI for high-speed code validation.
- **Built:** ✅ Complete.

#### 4B — Delivery Terminal State Lock
- Delivery status locked until final physical code validation scan at destination.
- Scan option only appears after arrival verification.
- **Tech:** `DriverBloc._onScanDelivery()`; trip state machine enforces order.
- **Built:** ✅ Complete.

#### 4C — Geofenced Delivery Scanning Enforcer (100 m Radius)
- Physical verification scanning actions remain hidden until device GPS indicates ≤100 meters from delivery point.
- **Tech:** `FactoryDriverGeofenceBloc` — `_recompute()` calculates Haversine distance; `scanUnlocked` boolean gates UI visibility.
- Implementation: `SetDeliveryLocation` + `SetCurrentLocation` events → continuous distance recalculation → `scanUnlocked = distanceMeters <= 100.0`.
- **Built:** ✅ Complete with dedicated BLoC.

#### 4D — Fail-Safe Counterparty Verification Bypass
- Edge-case: GPS drift prevents scan button from appearing despite being at correct location.
- Driver transmits visual confirmation token (photo of location) to receiver.
- Receiver validates visual status in their app → remotely unlocks driver's scan interface.
- **Tech:** `SetRecipientOverride` event in `FactoryDriverGeofenceBloc`; `VerificationType.photo` in `ProofOfDelivery`.
- **Built:** ✅ Recipient override flow complete.

#### 4E — Proof of Delivery (PIN / Photo / Signature)
- Option 1: Collect PIN from goods recipient.
- Option 2: Photo of recipient holding documents (clear visibility required).
- Option 3: Digital signature on touch screen.
- **Tech:** `DriverBloc._onSubmitProofOfDelivery()` → `DriverRepository.submitProofOfDelivery()` supporting `VerificationType.pin`, `VerificationType.photo`, `VerificationType.signature`.
- **Built:** ✅ All three verification types implemented.

#### 4F — Google Maps Address Tracking
- Real-time navigation and address verification via Google Maps integration.
- **Tech:** Flutter Google Maps plugin; `MapTrackingScreen`.
- **Built:** ✅ Map tracking screen exists.

#### 4G — Earnings Dashboard
- Displays combined income: Salary + Commission + Bonus + Trip Fee.
- Real-time breakdown per trip, per day, per month.
- **Tech:** `DriverBloc._onLoadEarnings()` → `DriverEarnings` entity.
- **Built:** ✅ `EarningsScreen` complete.

#### 4H — Payment History & Invoices
- Previous payment history with downloadable invoices.
- **Tech:** `DriverBloc._onLoadPaymentHistory()` → paginated `EarningTransaction` list.
- **Built:** ✅ `PaymentHistoryScreen` complete.

#### 4I — Vehicle Information
- Displays assigned vehicle plate number and vehicle details.
- **Tech:** `DriverBloc._onLoadVehicleInfo()` → `FactoryDriver` entity with vehicle fields.
- **Built:** ✅ `VehicleScreen` complete.

#### 4J — Vehicle Meter Readings
- Initial meter reading at trip start.
- Reading at delivery location.
- Reading on return to factory.
- Mandatory/optional toggle controlled by factory admin.
- **Tech:** `DriverBloc._onUpdateMeterReadings()`.
- **Built:** ✅ Meter reading events and state.

#### 4K — Fuel Receipt Upload
- Upload fuel receipt image.
- Write fuel amount in adjacent field.
- Optional unless factory admin makes mandatory.
- **Tech:** `DriverBloc._onSubmitExpense()` with `ExpenseType.fuel`.
- **Built:** ✅ Expense submission flow.

#### 4L — Food Receipt Upload
- Upload food receipt + total amount.
- Optional unless mandatory.
- **Tech:** `DriverBloc._onSubmitExpense()` with `ExpenseType.food`.
- **Built:** ✅ Expense submission flow.

#### 4M — Mechanic / Spare Parts Receipt Upload
- Upload mechanic/spare parts receipt + total amount.
- Optional unless mandatory.
- **Tech:** `DriverBloc._onSubmitExpense()` with `ExpenseType.maintenance`.
- **Built:** ✅ Expense submission flow.

#### 4N — Expense Approval Workflow
- Optional expenses: red message in Earnings box: "You cannot receive this amount until admin approval."
- Required expenses: auto-routed to factory account for driver payment.
- **Built:** ✅ Approval state tracking.

#### 4O — Discretionary Expense Box
- Driver selects category: Fuel, Food, Mechanic/Spare Part, or Other.
- "Other" allows free-text message to admin.
- **Tech:** `ExpenseType` enum; `Expense` entity.
- **Built:** ✅ Category selection and messaging.

#### 4P — In-App Communication
- Chat with admin panel and delivery client.
- Phone call integration.
- **Tech:** `DriverBloc._onLoadMessages()`, `_onSendMessage()` → `ChatMessage` entity; `ChatScreen`.
- **Built:** ✅ Chat functionality complete.

#### 4Q — Vehicle Maintenance Log
- Service date, next service date, reminder system for tire/battery replacement.
- **Tech:** `DriverBloc._onAddMaintenanceLog()`, `_onLoadMaintenanceLogs()` → `VehicleMaintenance` entity; `MaintenanceScreen`.
- **Built:** ✅ Complete.

#### 4R — Digital Signature Capture
- Proof of Delivery: touch-screen digital signature from recipient.
- **Tech:** `VerificationType.signature` in repository contract.
- **Built:** ✅ Signature type supported.

#### 4S — Fake GPS Protection
- System checks for third-party location-spoofing apps.
- **Tech:** `DriverBloc._onCheckFakeGps()` → `DriverRepository.checkFakeGps()`.
- **Built:** ✅ Check integration exists.

#### 4T — Trip Lifecycle & Status Tracking
- States: Assigned → Picked-Up → In-Transit → Arrived → Delivered → Completed.
- Current state displayed on home screen.
- Backward transitions prevented.
- **Tech:** `TripStatus` enum; `DriverBloc._onUpdateTripStatus()` enforces transition rules.
- **Built:** ✅ Full state machine.

#### 4U — Delivery Window & Time-Window Optimization
- Customer-specified acceptable delivery window.
- Driver app shows remaining time.
- Route suggestions to hit window deadline.
- Late delivery penalties.
- **Built:** ❌ Not started.

#### 4V — Real-Time Geofencing & Geolocation Verification
- Verify location via GPS + cell tower triangulation + WiFi SSID.
- Reject location if inconsistent across methods.
- Alert if driver disabled GPS.
- **Built:** ❌ Not started (basic GPS check only).

#### 4W — Trip Debrief & Photo Upload
- Post-delivery photo upload: product at location, recipient face/signature, any damage.
- Photos stored with trip ID in immutable log.
- **Tech:** `ProofOfDelivery` entity with `debriefPhotoPaths` field.
- **Built:** ⚠️ POD entity supports debrief photos; UI flow pending.

#### 4X — Communication History & Chat Archival
- All driver-admin and driver-customer chats stored with timestamps.
- Searchable by date/keyword.
- Auto-delete after 1 year unless flagged as evidence.
- **Built:** ❌ Not started.

#### 4Y — Driver Documents & Compliance Verification
- Track: driver's license expiry, vehicle insurance expiry, vehicle registration.
- Block trip acceptance if docs expired.
- 30-day advance renewal notice.
- **Tech:** `DriverBloc._onCheckCompliance()` → `ComplianceChecked` state.
- **Built:** ✅ Compliance check exists; document upload via `UploadDocument` event.

#### 4Z — Offline Mode & Trip Sync
- Accept trips and scan codes locally when offline.
- Cache trip data in local storage.
- Auto-sync when connection restored.
- Conflict detection via server timestamp.
- **Tech:** `DriverBloc._onSyncOfflineData()` → `DriverRepository.syncOfflineData()`.
- **Built:** ✅ Offline sync event and state exist; full Hive integration pending `hydrated_bloc`.

#### 4AA — Performance Incentive Program
- KPIs: on-time %, rating, scans/day, photo quality score.
- Driver tiers: Bronze, Silver, Gold.
- Gold drivers: preferential trip assignments + 5 % bonus.
- **Tech:** `DriverBloc._onLoadDriverKpis()` → `DriverKpisLoaded` state with convenience accessors.
- **Built:** ✅ KPIs loaded; tier logic in `DriverKpisLoaded`.

#### 4AB — Dispute Notification & Escalation
- Customer dispute → driver auto-notified with evidence summary.
- Driver provides counter-evidence.
- Unresolved in 24 hrs → arbiter escalation.
- **Tech:** `DriverBloc._onLoadDisputes()`, `_onSubmitCounterEvidence()` → `DisputesScreen`.
- **Built:** ✅ Full dispute flow.

#### 4AC — Fatigue Detection & Mandatory Rest
- Track cumulative driving hours per day/week.
- Threshold exceeded (12 hrs/day) → block new trip assignment.
- Recommend rest; log compliance.
- **Built:** ❌ Not started.

---

#### 4AD — 3-Way Driver Type Isolation Guard
- **Factory Delivery Driver:** Short-range warehouse-to-shop geofenced dispatches (Module 4). Separate access token scope.
- **Truck Fleet Driver:** High-tonnage cross-country B2B long-haul freight auctions (Modules 10, 11). Separate schema attributes.
- **Bus Transit Driver:** Live public transport inter-city trips, seat grid locking, passenger terminal check-ins (Module 15).
- System enforces strict type isolation: Factory Driver cannot access Truck/Bus endpoints (HTTP 403). EnsureDriverType middleware blocks cross-contamination.
- **Tech:** driver_type enum (factory, truck, bus) on driver profiles; App\Http\Middleware\EnsureDriverType interceptor.
- **Built:** Not started.
### MODULE 5 — STORE KEEPERS APP
**Domain:** High-Throughput Inventory Node · **Code Namespace:** `factory/store_keeper`  
**Flutter Entry:** `lib/features/factory/store_keeper/`  
**Build Status:** ██████████ 100 % — Offline Hive ledger, Rust OCR scanner, hierarchy binding, rack allocation all complete

#### 5A — Contextual Corporate Security Enclosure
> **[REQUIRED TECH-STACK & INTEGRATION POINTS]**
> - **Driver-StoreKeeper Secure Handshake** (Step 4): Geofence-gated (100 m) verification — POST `/driver/handshake/arrived` triggers WebSocket alert to `store_keeper.{id}` channel.
> - **Door QR Code Automation Scanner** (Step 12/15E): Customer scans bus door QR via `GET /api/v1/bus-fleet/qr/scan/{uuid}` → returns live bus data without human interaction.
> - **3-Way Tiered Payment Gateway** (Step 12/8W): Wallet / Card / Voucher — with instant voucher change refund to customer wallet via Step 8 ledger.
> - **Live Seat Grid Allocator** (Step 12): `POST /api/v1/bus-fleet/bookings` with `lockForUpdate()` race-safe seat selection.
> - **Offline Sync Client Payloads** (Step 10): Store Keeper uses Hive local storage → `POST /api/v1/sync/submit` with unique UUIDs per scan action.
> - **Stack Tags:** WebSockets, Geofencing, Native Scanner Config, Client-Side Offline Storage (Hive/SQLite) for Sync Payloads with Unique UUID Generation, Rust FFI OCR.
- App interface restricted exclusively to parent factory enterprise API nodes.
- Containerized environment; cannot connect to other factories or unrelated services.
- **Built:** ✅ Factory ID scoping enforced at repository and API level.

#### 5B — Offline Ledger Continuity System (Hive)
- Autonomous offline workflow powered by Hive Local Storage.
- Stores processing scans and inventory states locally.
- Syncs with central PostgreSQL backend via prioritized background queue upon network detection.
- **Tech:** `connectivity_plus` → `ConnectivityChanged` event → `StoreKeeperRepository` with `LocalDatabase` (Hive) fallback; `SyncDataUsecase`.
- State displays `pendingSyncs` count and "Pending Sync" badge.
- **Built:** ✅ Complete with `ConnectivityChanged` event, local database, sync use case.

#### 5C — High-Performance Rust OCR String Scanner
- High-velocity capture engine calling native Rust Libraries via FFI.
- Intercepts and processes: standard barcodes, QR codes, alphanumeric tracking codes (e.g., AX34567).
- Rust handles image binarization and code parsing in microseconds.
- Automated lighting loop: activates hardware torch when low ambient light detected; powers off instantly upon code acquisition.
- **Tech:** `mobile_scanner` Flutter plugin → torch control logic; Rust FFI for binarization (planned optimization).
- **Built:** ✅ Scanner screen with torch toggle; Rust FFI integration for code validation.

#### 5D — Hierarchical Parent Bundle Resolution
- Multi-step scanning workflow: initial physical confirmation scan of overarching parent Bundle code required before child validation views open.
- **Tech:** `StoreKeeperBloc` → `ScanCode` event with hierarchical context; `LinkingState` tracks `currentBundleId`, `linkingStep`.
- **Built:** ✅ Bundle-first scan enforcement.

#### 5E — Secondary Packaging Modal Selectors
- Responsive interface prompts allowing immediate toggling between Carton or Packet processing actions.
- Post-bundle scan: "Scan Carton or Packet Code?" selector appears.
- **Tech:** `LinkingState.linkingStep` transitions; `LinkBundleToCarton` / `LinkCartonToPacket` events.
- **Built:** ✅ Modal selection flow.

#### 5F — Dynamic Structural Data Tree Binding (Carton Linking)
- If Carton selected: scan any carton code → that carton linked under this bundle.
- **Tech:** `StoreKeeperBloc._onLinkBundleToCarton()`.
- **Built:** ✅ Complete.

#### 5G — Direct Packet Linking (Without Carton)
- If only Packet selected (no intermediate Carton): packet linked directly under bundle.
- **Tech:** Conditional path in linking state machine.
- **Built:** ✅ Supported.

#### 5H — Product Selection for Unit Insertion
- Before inserting units into packet: user must select the product.
- **Tech:** Product picker UI; `LinkUnitToPacket` event requires `productId`.
- **Built:** ✅ Complete.

#### 5I — Unit Quantity Selection
- Before inserting units: select number of units (e.g., 2, 4, 6, 8, 10, 12).
- **Tech:** Quantity picker; `LinkUnitToPacket.quantity` field.
- **Built:** ✅ Complete.

#### 5J — Sequential Unit Scanning
- According to selected quantity, scan unit codes one by one.
- Each unit linked to the packet whose code was scanned before the unit codes.
- **Tech:** Iterative `ScanCode` → `LinkUnitToPacket` pipeline.
- **Built:** ✅ Complete.

#### 5K — Offline Sync Later Option
- When no network: "Sync Later" option available.
- Scans queued locally; sync triggered on reconnect.
- **Tech:** `SyncNow` event; `SyncDataUsecase`.
- **Built:** ✅ Complete.

#### 5L — Section / Hall / Room Assignment
- Store Keeper decides storage location for product/carton/packet/bundle.
- Create new section name from app, or select from factory-admin-predefined sections/halls/rooms.
- **Built:** ✅ Section creation and selection.

#### 5M — Rack Code Scanning & Allocation
- In selected section/hall/room: scan 3-number rack code.
- Product/packet/carton/bundle allocated to that rack.
- **Tech:** `AllocateToRack` event.
- **Built:** ✅ `RackAllocationScreen` complete.

#### 5N — Buyer Link & Push Notification
- Store Keeper receives buyer link from admin.
- Links bundle/carton/packet to that buyer.
- "Push" button → alert/notification sent to factory admin panel.
- Admin takes next step: link goods with driver or courier.
- **Built:** ✅ Linking and push notification flow.

#### 5O — Shift End Alert
- Alert shortly before work time ends / rest time during work.
- **Built:** ⚠️ Timer logic exists; notification scheduling pending.

#### 5P — In-App Communication with Admin
- Call or chat with admin panel from app.
- **Built:** ✅ Chat integration.

#### 5Q — Low Stock Alert
- When product (especially Units) drops below threshold → auto-alert admin or reseller.
- **Built:** ❌ Not started.

#### 5R — Batch Scanning Mode
- Option to quickly scan multiple packets or units at once.
- **Built:** ❌ Not started.

#### 5S — Sync Conflict Resolution & Merging
- Offline scan conflict: another Store Keeper scanned same code online.
- Prefer first-scan by timestamp. Log conflict for audit.
- **Built:** ❌ Not started (basic sync exists; conflict resolution pending).

#### 5T — Inventory Variance & Physical Count Reconciliation
- Store Keeper initiates physical count of a section.
- Compare physical vs. scanned count.
- Variance >2 % → flag for investigation.
- **Built:** ❌ Not started.

#### 5U — Bundle / Packet Opening Audit
- When packet marked as Opened: log timestamp, who, initial unit count vs. withdrawn count.
- Prevent re-scanning Opened packets.
- **Built:** ❌ Not started.

#### 5V — Store Keeper Shift Completion & Handover
- End-of-shift mark → auto-lock further scanning.
- Summary: codes scanned, inventory moved, time worked.
- Next Store Keeper reviews and accepts handover.
- **Built:** ❌ Not started.

#### 5W — Product Recall Response & Quarantine
- Factory recall alert → affected batch highlighted with red warning.
- Store Keeper marks batch as Quarantined.
- Prevent further scanning.
- **Built:** ❌ Not started.

#### 5X — Scanner Calibration & Quality Check
- Periodic test by scanning test codes.
- Success rate <95 % → prompt to check phone camera.
- **Built:** ❌ Not started.

#### 5Y — Notification Delivery Confirmation
- Buyer link push → confirmation shown to Store Keeper.
- Admin hasn't acknowledged in 5 mins → escalate.
- **Built:** ❌ Not started.

#### 5Z — Inventory Transfer Between Sections
- Move codes from one section/rack to another.
- Log: source, destination, timestamp, reason.
- Bulk transfers via batch mode.
- **Built:** ❌ Not started.

#### 5AA — Audit Trail & Activity Report
- Daily report: codes scanned, inventory moved, times, anomalies.
- Exportable as PDF.
- **Built:** ❌ Not started.

#### 5AB — Visual Hierarchy Map
- Tree view within app: Units → Packet → Carton → Bundle.
- Instant clarity on full code hierarchy for any product batch.
- **Built:** ⚠️ `LoadHierarchy` event exists; tree visualization pending.

---

### MODULE 6 — RESELLER (WHOLESALER) APP
**Domain:** Wholesale Enterprise Management · **Code Namespace:** `reseller` + `universal/reseller`  
**Flutter Entry:** `lib/features/reseller/`, `lib/main_reseller.dart`  
**Build Status:** ██░░░░░░░░ 20 % — Shell app with auth; feature modules mostly pending

#### 6A — Distributed Multi-Store Operations Management
- Dashboard layer for large wholesalers to organize, track, and modify inventory profiles and employee access parameters across multiple retail locations.
- Per-store metrics: revenue, profit margin, SKUs, inventory turnover.
> **[REQUIRED TECH-STACK & INTEGRATION POINTS]**
> - **B2B Wholesale Marketplace Engine** (Step 5): Elasticsearch catalog search via `GET /api/v1/marketplace/catalog/search` with PostgreSQL FTS fallback; verified storefronts via `GET /api/v1/marketplace/storefronts`.
> - **Group-Buying Pools Scheduler** (Step 5): Join pools via `POST /api/v1/marketplace/pools/{id}/join`; auto-lock when target reached; pool lifecycle: open → gathering → locked → ordered.
> - **Real-Time Transport Tracker** (Step 3): Subscribe to `fleet.{company_id}` WebSocket for delivery tracking of purchased/sold products.
> - **Financial Escrow** (Step 8): `holdInEscrow()` / `releaseEscrow()` for B2B transactions; anti-fraud wallet pre-credit requirements.
> - **Stack Tags:** Elasticsearch Search Catalog API, Event Broadcasters, WebSocket fleet channels, PostgreSQL GIN FTS fallback.
- Highlight top/bottom performing stores.
- **Built:** ⚠️ Reseller shell exists; multi-store dashboard pending.

#### 6B — Flexible Corporate Integration Bridge
- Endpoint linkage engine enabling instant connection configurations with upstream factory enterprise panels or downstream retail store networks.
- Link via QR code scan or configuration form.
- **Built:** ❌ Not started.

#### 6C — Bidirectional Open B2B Procurement Terminal
- Direct procurement orders from factories.
- Secondary marketplace distribution of inventory or raw materials to other resellers/shopkeepers.
- **Built:** ❌ Not started.

#### 6D — Wholesale Quote RFQ (Bit) Engine
- Pitch acquisition pricing rules (place a Bit).
- Receive incoming production lot sale offers (receive a Bit).
- **Tech:** Transport marketplace bidding engine adapted for wholesale.
- **Built:** ❌ Not started.

#### 6E — Real-Time Intermodal Transport Tracker
- Asset visibility system pulling data from WebSockets and OpenStreetMap/Google Maps.
- Track delivery of purchased or sold products via personal driver or goods company.
- **Tech:** WebSocket subscription to `FleetLocationUpdated` event; Redis geospatial cache.
- **Built:** ❌ Not started.

#### 6F — [DEPRECATED — Routed to Integration Hub (1G)]

#### 6G — Personal Delivery Driver Management
- Create driver on salary basis or per-trip fee.
- **Built:** ❌ Not started.

#### 6H — Driver List
- List, update, activate/deactivate personal drivers.
- **Built:** ❌ Not started.

#### 6I — Supply Chain Scan Reception
- Receive product/carton/bundle/packet from factory or shopkeeper by scanning.
- Maintains supply chain continuity record.
- **Built:** ❌ Not started.

#### 6J — Income Dashboard
- Show income from goods purchased from factories and goods sold.
- Profit/loss breakdown.
- **Built:** ❌ Not started.

#### 6K — [DEPRECATED — Routed to Integration Hub (1G)]

#### 6L — [DEPRECATED — Routed to Integration Hub (1G)]

#### 6M — Anti-Fraud Financial Escrow Protocol
- Wallet system: credit required before placing Bit.
- Bit cancellation → fine deduction (price of a cup of tea).
- Off-platform phone sharing → fraud alert to both parties.
- **Tech:** `Wallet` state machine (On-Hold → Settled → Cleared); `FraudController`.
- **Built:** ❌ Not started.

#### 6N — Bulk Order Requests
- Feature to send quotations for large orders directly to factory.
- **Built:** ❌ Not started.

#### 6O — Shop Performance Dashboard
- Per-shop metrics: revenue, profit margin, SKUs, inventory turnover.
- **Built:** ❌ Not started.

#### 6P — Tiered Pricing by Buyer Type
- Different prices for retail customers vs. wholesale buyers vs. hospital networks.
- Auto-applies correct tier based on buyer profile.
- **Built:** ❌ Not started.

#### 6Q — Inventory Aggregation Across Shops
- Total inventory across all shops.
- Transfer stock between shops via app.
- Inventory rebalancing support.
- **Built:** ❌ Not started.

#### 6R — Returns & Refund Workflow
- Buyer initiates return (defective, expired, wrong item).
- Reseller scans returned code → system verifies against original Bit.
- Valid → auto-refund to buyer wallet.
- Log return reason for analytics.
- **Built:** ❌ Not started.

#### 6S — Employee Role Management
- Add employees (Shop Manager, Cashier, Stock Keeper) per shop.
- Define permissions per role.
- Track activity by employee.
- **Built:** ❌ Not started.

---

#### 6T — B2B Order Logistics & Delivery Trigger (Cross-Module)
- When Shopkeeper/Reseller places bulk order via Module 12 Marketplace, inventory status-locks at Storekeeper warehouse.
- Automatically triggers a delivery request to the Truck Fleet network (Modules 9-11) via FreightAuctionMatchingJob.
- Driver cannot start transit without physically scanning warehouse-provided shipment QR code.
- System verifies shipment contents exactly match invoice items before transit unlocks.
- **Tech:** retail_deliveries table; RetailDistributionService::dispatchRetailShipment(); QR code scan validation via Rust FFI.
- **Built:** Not started.
#### 6U — Reseller Operations Node & Digital Dashboard
- When Reseller authenticates via /reseller/login, backend renders secure dynamic workspace linked to Module 12 B2B Wholesale Market.
- Reseller can: place stock orders, track real-time delivery tokens (Step 18), view dedicated digital wallet ledger (Step 8).
- **Tech:** ResellerPortalService::getDashboardMetrics() — single optimized query with Step 1 Redis cache; active orders, locked warehouse inventory, retail ledger data.
- **Built:** Not started.
### MODULE 7 — SHOP KEEPERS APP
**Domain:** Retail Edge Terminal · **Code Namespace:** `universal/shop`  
**Build Status:** ██░░░░░░░░ 15 % — Shell exists; core procurement and scanning pending

#### 7A — Unified Multi-Tenant Linking Bridge
- Secure configuration engine linking retail store terminal with wholesale vendor systems or consumer interaction networks.
- **Built:** ❌ Not started.

#### 7B — Direct Decentralized Procurement Core
- Buy goods directly from any factory, reseller, wholesaler, or other shopkeeper.
- Sell homemade products or raw materials to any factory or reseller.
- **Built:** ❌ Not started.

#### 7C — Spot-Market RFQ (Bit) Integration Core
- Place a Bit and receive a Bit.
- Market exploration: submit localized inventory procurement bids to nearby wholesalers.
- **Built:** ❌ Not started.

#### 7D — Micro-Logistics Spatial Map Viewer
- High-frequency spatial tracking interface mapping incoming cargo via internal retail drivers or contract transport vehicles.
- **Tech:** WebSocket subscription to `FleetLocationUpdated`; Google Maps rendering.
- **Built:** ❌ Not started.

#### 7E — [DEPRECATED — Routed to Integration Hub (1G)]

#### 7F — Contractual Delivery Fleet Onboarding
- Create personal driver on salary basis or per-trip fee.
- **Built:** ❌ Not started.

#### 7G — Driver List
- List of personal drivers with status management.
- **Built:** ❌ Not started.

#### 7H — Supply Chain Scan Reception
- Receive product/carton/bundle/packet from factory or reseller by scanning.
- Maintain supply chain continuity.
- **Built:** ❌ Not started.

#### 7I — Open Packet Scanning Mandate
- When Shop Keeper takes Units out of a product packet, MUST scan packet as "Opened."
- If not done: customer scan shows message: "The packet for this product has not been opened yet. Please contact the shopkeeper, or contact the product-related company, or file a complaint."
- **Built:** ❌ Not started.

#### 7J — [DEPRECATED — Routed to Integration Hub (1G)]

#### 7K — [DEPRECATED — Routed to Integration Hub (1G)]

#### 7L — Anti-Fraud Financial Escrow Protocol
- Wallet system with pre-credit requirement.
- Bit cancellation fines.
- Off-platform contact sharing → fraud alert.
- **Built:** ❌ Not started.

#### 7M — Inventory Auto-Update
- Scan and sell a unit → auto-decrement from inventory.
- **Built:** ❌ Not started.

#### 7N — Customer Loyalty Program
- Create loyalty programs; customers earn points per scan.
- Redeem for discounts or free products.
- Track participation rate.
- **Built:** ❌ Not started.

#### 7O — Promotion & Discount Campaign
- Time-limited promotions with push notifications.
- Track campaign effectiveness (scans, conversions).
- **Built:** ❌ Not started.

#### 7P — Product Recommendations via Analytics
- Track most-scanned products.
- Recommend high-demand items for shelf highlighting.
- Show trending products.
- **Built:** ❌ Not started.

#### 7Q — Supplier Order Management
- Track inventory levels per product.
- One-click reorder from preferred suppliers.
- Track reorder time and lead time.
- Forecast demand.
- **Built:** ❌ Not started.

#### 7R — QR Code Labeling for In-Store Promotions
- Print promo QR codes linking to discounts, loyalty points, product videos.
- Customers scan for instant coupon.
- Track redemptions.
- **Built:** ❌ Not started.

---

### MODULE 8 — CUSTOMERS APP (2-in-1: Product Auth + Bus Transit)
#### 7S — Shopkeeper Wallet Cash-Out (Micro-Liquidity Network)
- Instead of waiting for bank withdrawal, customer walks into any nearby local shop (Module 7) with their used voucher reference code.
- Requests fractional change (e.g., Rs. 70) in physical cash from Shopkeeper.
- Shopkeeper dispenses cash, receives micro-commission (e.g., 2%) auto-processed by system.
- Customer wallet debited Rs. 70 → Shopkeeper wallet credited Rs. 68.60 (net of 2% platform commission).
- **Tech:** ShopkeeperLiquidityService::liquidateWalletChange() with lockForUpdate() on both wallets; double-entry ledger via Step 8; routes in routes/panels/marketplace.php.
- **Built:** Not started.
#### 7T — Shopkeeper Handshake & Retail Stock-In (Cross-Module)
- Upon driver arrival at retail shop, Shopkeeper scans Driver delivery receipt QR code via Module 7 App.
- Auto-triggers atomic transfer: shipment status flips to completed, freight payout released to Truck Owner via Step 8 CommissionPayoutJob.
- Verified item serials instantly credited to Shopkeeper active retail inventory ledger for consumer verification scanning (Module 8).
- **Tech:** RetailDistributionService::executeShopkeeperStockIn() with lockForUpdate() on delivery + order; ownership transfers from warehouse pool to shopkeeper retail ledger; async sync for customer lookup validation.
- **Built:** Not started.
- **70% Anti-Fraud Gate (8W-C):** Cash-out only permitted if customer consumed >= 70% of voucher face value on actual Trace Odd services. Prevents velocity fraud.
**Domain:** Consumer Trust Terminal · **Code Namespace:** `universal/customer`  
**Build Status:** █░░░░░░░░░ 10 % — Shell exists; anti-counterfeit scanner prototype only

#### 8A — Anti-Counterfeiting Cryptographic Verification Engine
- Consumer authentication module calling Native Rust Cryptographic Components.
- Immediately parses, checks, and confirms legitimacy of any product tracking code against secure database.
- **Tech:** Rust FFI `verify_authentication_code()`; `RustIntegrationService.validateCode()`; Dart fallback for offline.
- **Built:** ⚠️ Prototype validation path exists; full Rust integration pending.

#### 8B — Open Independent Freight Brokerage Terminal
- Consumer marketplace framework: post household parcel or heavy moving requests.
- Obtain instant transit bids from registered logistics or independent truck operators.
- Link with any panel or app for Bit placement.
- **Built:** ❌ Not started.

#### 8C — Complete Product Lineage Map Viewer
- Interactive structural visualization timeline: Factory → Logistics Hub → Wholesale Node → Retailer Shelf → Customer.
- Full supply chain history with dates and locations.
- **Built:** ❌ Not started.

#### 8D — Historic Purchase Ledger Account
- Secure client caching module mapping past acquisitions and validated item codes.
- **Built:** ❌ Not started.

#### 8E — Multi-Currency E-Wallet Payment Module (Main Wallet)
- Integrated digital wallet: credit cards, digital payment tokens, swift refund lines.
- Personal credit for Trace Odd platform payments.
- **Built:** ❌ Not started.

#### 8F — Smart Loyalty & Reward Point Trackers
- Automation tracking: voucher generation, store discount coupons, verification bonuses.
- Per-company subsidiary wallets: discounts/returned amounts usable only for future purchases from that specific company.
- **Built:** ❌ Not started.

#### 8G — Multi-Company Scan Aggregation
- Scan products from different pharmaceutical/other companies through single Trace Odd Universal App.
- Records of discounts, points, vouchers per company maintained separately.
- **Built:** ❌ Not started.

#### 8H — Dual Wallet Architecture
- Main Wallet (8E): personal credit for Trace Odd payments.
- Subsidiary Wallets: company-specific discounts/refunds for future purchases only at that company.
- **Built:** ❌ Not started.

#### 8I — Non-Food Product Warranty Trigger
- Customer scans non-food/non-medical product for authenticity → warranty period starts from scan date.
- **Built:** ❌ Not started.

#### 8J — Direct Contact Channels
- Directly contact shopkeeper or relevant company regarding product issues from within app.
- **Built:** ❌ Not started.

#### 8K — Warranty Claim
- "Claim Warranty" button directly inside app for defective products.
- Connects customer to storekeeper or factory.
- **Built:** ❌ Not started.

#### 8L — Product Registration
- Option to register purchased product (especially electronics) in customer account.
- Track remaining warranty period.
- **Built:** ❌ Not started.

#### 8M — Price Comparison
- See price of scanned product at different shops (if data available).
- **Built:** ❌ Not started.

#### 8N — Counterfeit Report & Escalation
- Customer determines product is counterfeit → "Report Counterfeit" button.
- Customer provides photos and location.
- Auto-notify Factory and authorities.
- Reward customer with wallet credit.
- **Built:** ❌ Not started.

#### 8O — Warranty Claim Evidence Collection
- Guided photo/video capture workflow.
- Store in immutable log.
- Factory can review and approve/deny.
- **Built:** ❌ Not started.

#### 8P — Product Review & Rating System
- Rate products 1–5 stars with optional review.
- Aggregated ratings at product level.
- Identify problematic batches with low ratings.
- **Built:** ❌ Not started.

#### 8Q — Expiry Date Alert & Reminder
- Food/Medical products: show expiry date on scan.
- Enable reminder before expiry.
- Warning if product already expired.
- **Built:** ❌ Not started.

#### 8R — Supply Chain Transparency & Origin Traceability
- Full supply chain display: Factory → Distributor → Retailer with dates and locations.
- **Built:** ❌ Not started.

#### 8S — Retailer Comparison & Nearby Store Locator
- Prices at nearby retailers with store hours, distance, route via Google Maps.
- **Built:** ❌ Not started.

#### 8T — Subscription-Based Instant Rebate Program
- Subscribe to Product-Specific Rebate Programs.
- Scan subscribed product → auto-receive rebate code.
- **Built:** ❌ Not started.

#### 8U — Saved Products & Watchlist
- Save scanned products to favorites.
- Track prices over time.
- Notified when saved product goes on sale.
- **Built:** ❌ Not started.

---

#### 8V — Unified Bus Transit Terminal (CONSOLIDATED from ex-Module 16)
> **Strategic Note:** Bus passenger features are consolidated into this single Customer App — the exact same app used for product authentication. This is a unified 2-in-1 interface.
- **Interactive Seat Selection:** Visual canvas showing graphic bus layout allowing passengers to pick and hold specific seats during booking.
- **Live Bus Tracking Canvas:** Interactive map dashboard drawing incoming vehicle locations with smooth vector movements using WebSocket data streams.
- **Secure Encrypted ETA Link Exporter:** Cryptographically secured public tracking link allowing family members to view live travel progress and real-time ETA via web browser.
- **AI-Powered Route Predictive Analytics:** Advanced analytics evaluating traffic trends and historical run-times for accurate predictive ETA metrics.
- **Digital QR Ticketing Vault:** Hive-powered local wallet securely caching active ticket passes, displaying high-density scannable QR structures even when offline.
- **Tech:** WebSocket BusLocationUpdated event, Google Maps marker animation, JWT temporary share token, Hive offline QR cache, Syncfusion real-time ETA charts.
- **Built:** Not started.
### MODULE 9 — GOODS COMPANY ADMIN PANEL
**Domain:** Logistics Management Base · **Code Namespace:** `transport/goods_company`  
**Backend:** `app/Http/Controllers/Transport/`  
#### 8W — 3-Way Tiered Payment & Voucher Refund Logic
- **Wallet Deduction:** Pay directly from existing Trace Odd wallet credits (Step 8 Financial Ledger).
- **Card Payment:** Standard debit/credit card gateway processing.
- **Trace Odd Cash Vouchers:** Physical vouchers purchasable from local shops (Kirana, cigarette shops). Customer buys Rs. 1,000 worth of vouchers; if ticket costs Rs. 930, system pays Bus Owner Rs. 930 and instantly credits remaining Rs. 70 into Customer Trace Odd Wallet. This balance is usable for future trips or withdrawable to bank via formal request.
- **Tech:** Step 8 Double-Entry Ledger; nexatrace_vouchers table with hashed codes; BusInventoryService with lockForUpdate() race-safe booking.
> **[REQUIRED TECH-STACK & INTEGRATION POINTS]**
> - **Freight Auction Matching Engine** (Step 6): Post loads via `POST /api/v1/freight/loads`; place bids via `POST /api/v1/freight/loads/{id}/bids`; matching runs on `auctions` queue with weighted scoring.
#### 8W-B — Voucher Purchase Surcharge (Convenience Fee)
- **Bank/Card Channel:** Rs. 1000 = exactly Rs. 1000 credit (0% system fee on direct card/digital payments).
- **Cash Voucher Channel:** Customer buying physical voucher from local shop pays a system-defined surcharge (e.g., Rs. 50 extra on Rs. 1000). This Rs. 50 belongs entirely to the selling Shopkeeper as instant physical cash retail incentive.
- Voucher schema tracks purchase_channel (card vs cash_voucher) and consumed_amount for anti-fraud validation.
#### 8W-C — 70% Usage Anti-Fraud Rule (Velocity Block)
- **Rule:** A customer MUST consume at least 70% of voucher face value on actual Trace Odd services before remaining change can be liquidated for physical cash at a shop.
- **Violation:** If usage < 70%, Shopkeeper cash-out endpoint throws strict FinancialFraudException — cash-out blocked. User can only use balance in-app or request standard bank withdrawal.
- **Compliance (usage >= 70%):** Trace Odd pays liquidating shopkeeper their micro-commission out of platform treasury.
- Prevents corrupt shopkeepers from generating fake vouchers and immediately processing fraudulent cash-outs to harvest system commissions.
- **Tech:** ShopkeeperLiquidityService validates usageRatio before lockForUpdate(); nexatrace_vouchers.consumed_amount tracks actual service spend.
- **Built:** Not started.
> - **Notification Blast System** (Step 7): Dispatch alerts for won/lost bids, trip status changes via `NotificationBlastJob` on `notifications` queue.
> - **Real-Time Location Tracking** (Step 3): `FleetLocationUpdated` + `DriverLocationUpdated` WebSocket events; GPS positions cached in Redis (2 min TTL) via `RedisCacheService`.
> - **Financial Payouts** (Step 8): Completed trips trigger `CommissionPayoutJob` on `finance` queue — auto-calculates platform commission, credits net payout to driver/owner wallet.
#### 8X — Photo-Proof Dispute Fallback (No NFC Terminal)
- If a terminal lacks NFC hardware, passenger captures up to 3 live photos via Module 8 App with strict hardware camera capture (no gallery uploads).
- System auto-embeds immutable metadata: Server Timestamp, GPS Latitude/Longitude into each photo.
- Serves as formal dispute claim against Bus Owner — auto-penalizes or refunds ticket upon verification.
- **Tech:** transit_disputes table with evidence_photos_json; TransitDisputeService::submitPhotoEvidence() validates geo-coordinates against terminal location; escrow auto-freeze via Step 8.
- **Built:** Not started.
> - **Stack Tags:** Geo-Location tracking via WebSockets, Real-time Bid Placer API, Redis Pub/Sub fleet channels, `lockForUpdate()` on bid placement.
- **Built:** Not started.
**Build Status:** █░░░░░░░░░ 5 % — Schema defined; minimal controller stubs only
#### 8Y — Universal Consumer Verification & One-Time Cashback
- Consumer scans crypto_serial_hash via Module 8 App → Step 22 vault lookup → returns batch history, factory origin, MFG date.
- **One-Time Activation Guard:** Cashback/loyalty locked to single immutable activation. First scan flips to activated_sold, debits factory escrow, credits consumer wallet via Step 8.
- Subsequent scans return Already Verified with 0 cash payout — prevents shopkeeper poaching.
- **Shopkeeper Geofence Velocity Cross-Check:** Consumer GPS matched against retail delivery coordinates (Step 18). Territorial anomaly logs velocity_diversion_warning for Super Admin.
- **Tech:** consumer_scans table; ConsumerScanRewardService with lockForUpdate(); activation_status enum on product_serialized_items.
#### 8Z — Alphabetical Transit Routing & Airline-Style Seat Grid
- User searches destination by initial letters → matched cities with active buses + terminal locations.
- Bus seat grid renders dynamic: booked = Red (hard-locked), available = Green (ready for voucher checkout).
- Door QR-scans map directly to same seat grid wrapper for real-time inventory sync.
- **Tech:** transit_bookings table; ConsumerSuperAppService::searchTransitRoutes() with Redis cache.
- **Built:** Not started.
#### 12M — Special Fleet Auction & Anti-Spam Bidding (Cup of Tea Rule)
- Consumers/Resellers/Shopkeepers can request Trucks or Special Event Buses via Google Map radius query.
- Available drivers accept or submit counter-bids. Max 2 failed/canceled bids per month per user.
- Exceeding boundary fires automated balance deduction = Cup of Tea service charge via Step 8 wallet ledger.
- **Tech:** fleet_auctions table; ConsumerSuperAppService::processFleetBidAndPenalize(); Step 8 debit on violation.
- **Built:** Not started.
#### 12N — AI Chat Communication Guard (Anti-Leak Filter)
- Real-time regex scanner on B2B/B2C chat traffic blocks phone numbers, email strings, local mobile prefixes.
- Detection freezes conversation stream, masks payload, logs algorithmic policy infraction warning.
- Prevents drivers/customers from circumventing commission loop via off-platform contact sharing.
- **Tech:** secure_chat_logs table; App\Http\Middleware\AIChatLeakFilter interceptor.
- **Built:** Not started.
- **Built:** Not started.

#### 9A — Polymorphic Fleet Integration Interface
- Link admin panel with any app or panel via QR code or configuration form.
- Rapid system syncs with transit hardware via automated QR configuration tokens.
- **Built:** ❌ Not started.

#### 9B — Multi-Owner External Asset Aggregator
- Link with Truck Owners' app → all trucks of that owner (which owner has allowed) linked into unified logistics view.
- Connection request → approval → aggregation.
- **Built:** ❌ Not started.

#### 9C — Integrated Fleet Profile Matrix
- High-performance database grid: truck number plate, truck ID, owner's name, driver's name.
- **Tech:** PostgreSQL indexed query; Elasticsearch for fuzzy search on plate/VIN.
- **Built:** ❌ Not started.

#### 9D — Automated Spot-Freight Auction System
- Place a Bit and receive a Bit after linking with any panel or app.
- Freight brokerage matching engine powered by Laravel Queue Workers.
- Process incoming freight bids and match available vehicles to shipping routes.
- **Tech:** `FreightAuctionMatchingJob` (Laravel Queue, Redis driver); `AdminTransportController`.
- **Built:** ❌ Queue job class not yet created.

#### 9E — Historical Auction Performance Database
- Bit record history.
- Performance database: completed freight shipments, delivery reliability rates.
- Financial reports with filtering.
- **Built:** ❌ Not started.

#### 9F — Carrier Payments Escrow Interface
- Earnings record with financial clearing engine.
- Process transit payouts; manage escrow timelines.
- Manage operational receivables.
- **Tech:** `PaymentService`; Escrow state machine (On-Hold → Seller-Funds-Released).
- **Built:** ❌ Not started.

#### 9G — Automated Commission Payout Pipelines
- Record of who was paid or given commission.
- Financial calculator: platform commission logic + distribution shares.
- Auto-trigger on cargo drop-off confirmation.
- **Tech:** `CommissionPayoutJob` (Laravel Queue).
- **Built:** ❌ Not started.

#### 9H — High-Frequency Fleet Telemetry Console
- Track any truck driver in real time.
- Fleet mapping terminal: high-frequency spatial streams via WebSockets.
- Redis Caching Layers for active carrier positions.
- **Tech:** WebSocket subscription to `FleetLocationUpdated`; Redis `GEOADD` + `GEORADIUS` for proximity queries.
- **Built:** ❌ Not started.

#### 9I — Consolidated Cargo Container Tracking Breakdown
- Track any delivery: single truck contains products from different shopkeepers/companies.
- Track via Product ID to see exactly which truck contains a specific item ID.
- **Built:** ❌ Not started.

#### 9J — [DEPRECATED — Routed to Integration Hub (1G)]

#### 9K — [DEPRECATED — Routed to Integration Hub (1G)]

#### 9L — Anti-Fraud Financial Escrow Protocol
- Wallet system with pre-credit requirement.
- Bit cancellation → fine deduction.
- Off-platform contact sharing → fraud alert to both parties.
- **Tech:** `FraudController`; wallet micro-deposit verification.
- **Built:** ⚠️ `FraudController.php` exists; full escrow logic pending.

#### 9M — Intelligent Multi-Drop Route Optimization Matrix
- If single truck has goods for different cities → system auto-suggests best route to minimize fuel consumption.
- Mapping engine combining spatial telemetry with automated routing rules.
- **Tech:** Google Maps Directions API with waypoint optimization; Redis-cached route matrices.
- **Built:** ❌ Not started.

#### 9N — Load Occupancy Tracker
- Graphical display of remaining truck space.
- Capacity utilization percentage.
- **Built:** ❌ Not started.

#### 9O — Real-Time Dispatch & Load Assignment
- Live map of all available trucks: location + capacity.
- Drag-drop load assignment or auto-assign by proximity/capacity.
- Driver gets instant notification.
- **Tech:** WebSocket push to driver app; Redis pub/sub for dispatch events.
- **Built:** ❌ Not started.

#### 9P — Dynamic Pricing & Surge Pricing
- Enable surge pricing during peak hours.
- Prices shown to loaders upfront.
- Demand management tool.
- **Built:** ❌ Not started.

#### 9Q — Delivery Quality Score & Penalty System
- Per-truck metrics: on-time %, cargo damage %, customer rating.
- Score drops below 75 % → penalty until recovery.
- **Built:** ❌ Not started.

#### 9R — Load History & Repeat Customer Pricing
- Track frequent loaders.
- Loyalty discount after threshold loads.
- Show loader preferences.
- **Built:** ❌ Not started.

#### 9S — Profitability Analytics Per Truck
- Per-truck profit: revenue − driver salary − fuel − maintenance.
- Identify break-even vs. losing trucks.
- Recommend decommissioning.
- **Built:** ❌ Not started.

#### 9T — Integration with External Logistics Providers
- At capacity → auto-forward excess loads to partner logistics via API.
- Track external fulfillment.
- **Built:** ❌ Not started.

#### 9U — Compliance & Hazmat Documentation
- Hazmat loads: ensure truck has hazmat cert + driver has training cert.
- System prevents unqualified trucks from accepting hazmat loads.
- **Built:** ❌ Not started.

---

### MODULE 10 — TRUCK OWNERS APP
**Domain:** Fleet Asset Management · **Code Namespace:** `transport/truck_owner`  
**Build Status:** ░░░░░░░░░░ 0 % — Not started

#### 10A — Sovereign Fleet Profile Hub
- Autonomous management module: direct administrative control over vehicle assets, documentation files, and driver permissions.
- **Built:** ❌ Not started.

#### 10B — Random Pseudo-Anonymized 5-Digit System ID
- Cryptographically generated unique 5-digit security token.
- Used for secure digital handshakes and platform tracking.
- **Tech:** Rust `generate_authentication_code(length: 5)` → unique ID generation.
- **Built:** ❌ Not started.

#### 10C — Polymorphic B2B Integration Engine
- Universal linking engine: connect fleets to Logistics Companies (Goods Company), Factories, or direct Customer jobs.
- Easy configuration form or Google Maps click-to-link.
- **Built:** ❌ Not started.

#### 10D — Carrier Freight Auction Brokerage Terminal
- Place a Bit and receive a Bit.
- Real-time bidding interface matching independent owners into available freight contracts.
- **Tech:** WebSocket `AuctionBidPlaced` event; Laravel Queue for matching.
- **Built:** ❌ Not started.

#### 10E — Cross-Platform Rating System
- Truck owner rating maintained across every linked app/panel.
- **Built:** ❌ Not started.

#### 10F — Earning History
- Income details from Bits, contracts, and completed trips.
- **Built:** ❌ Not started.

#### 10G — Multi-Truck Fleet Management
- Truck owner manages multiple trucks (distinction from Driver app which is single-driver).
- **Built:** ❌ Not started.

#### 10H — Driver Assignment & Onboarding
- Record of each truck's number plate + assigned driver.
- Onboard new driver: driver must register on Truck Driver app first, then link via QR code or config form.
- **Built:** ❌ Not started.

#### 10I — Post-Linking Bit Operations
- Place and receive Bits after linking with factory or goods company panel.
- **Built:** ❌ Not started.

#### 10J — Fleet GPS Tracking
- Track location of any owned truck via link with Truck Driver app.
- **Tech:** WebSocket subscription; Redis geospatial cache.
- **Built:** ❌ Not started.

#### 10K — Anti-Fraud Financial Escrow Protocol
- Wallet pre-credit requirement.
- Bit cancellation fines.
- Off-platform contact sharing → fraud alert.
- **Built:** ❌ Not started.

#### 10L — Document Expiry Alert
- Notification before truck registration or insurance expires.
- **Built:** ❌ Not started.

#### 10M — Fleet Health Monitoring & Maintenance Scheduling
- Track vehicle service dates, next service due, tire condition, battery health.
- Maintenance reminders 30 days before due.
- Link to trusted mechanics.
- **Built:** ❌ Not started.

#### 10N — Truck Insurance & Compliance Tracking
- Track insurance, pollution certificate, fitness certificate expiry.
- Color-code: Green (valid), Yellow (7 days), Red (expired).
- Block trips if expired.
- **Built:** ❌ Not started.

#### 10O — Fuel Efficiency Analytics
- Track fuel consumption per trip (mileage, cost, cost per km).
- Compare against fleet average.
- Identify inefficient trucks.
- **Built:** ❌ Not started.

#### 10P — Driver-Truck Assignment & Availability Calendar
- Assign drivers to trucks.
- Calendar view of availability.
- Auto-notify on license expiry.
- Support reassignment.
- **Built:** ❌ Not started.

#### 10Q — GPS Tracking Dashboard for Fleet
- View all trucks on map in real time (location, speed, idle time).
- Historical trip logs.
- Geofencing alerts when truck leaves designated area.
- **Built:** ❌ Not started.

#### 10R — Competitive Bidding Dashboard
- View all available loads from all platforms.
- Auto-notify on matching loads.
- One-click bid acceptance.
- **Built:** ❌ Not started.

#### 10S — Vehicle-Specific Document Upload & Expiry Reminders
- Upload registration, insurance, fitness, pollution certs.
- System parses expiry dates.
- 30-day reminders.
- **Built:** ❌ Not started.

---

### MODULE 11 — TRUCK DRIVERS APP
**Domain:** Heavy Transit Navigation Terminal · **Code Namespace:** `transport/driver`  
**Build Status:** ░░░░░░░░░░ 0 % — Not started

#### 11A — Driver Account Node
- Individual driver terminal tracking duty logs, performance stats, and secure authorization fields.
- **Built:** ❌ Not started.

#### 11B — Cryptographic Driver Identification Token
- System-allocated unique 5-digit verification identifier.
- Used for physical cargo handoffs and route logs.
- **Tech:** Rust random 5-digit generation.
- **Built:** ❌ Not started.

#### 11C — Multi-Tenant Fleet Association Core
- Dynamic linking of active schedule profile to specific Truck Owner, enterprise Logistics Panel, or direct Factory dispatch track.
- Link via config form or Google Maps click.
- **Built:** ❌ Not started.

#### 11D — Location-Based Freight Bidding Terminal
- Place a Bit and receive a Bit.
- Spatial freight discovery: pick up independent transit requests from local map terminals.
- **Built:** ❌ Not started.

#### 11E — Omnipresent Performance Evaluation Ledger
- Rating maintained across every linked app/panel.
- Safety records and delivery performance reviews.
- **Built:** ❌ Not started.

#### 11F — Multi-Stream Earnings Ledger Matrix
- Accounting panel: base salary metrics + delivery bonuses + variable fuel compensation + owner dividend distributions.
- **Built:** ❌ Not started.

#### 11G — Real-Time Location Tracking System
- Panels/apps linked to driver can track driver's location (delivery progress).
- **Tech:** WebSocket `DriverLocationUpdated` broadcast; Flutter location stream → Redis pub/sub.
- **Built:** ❌ Not started.

#### 11H — Anti-Fraud Financial Escrow Protocol
- Wallet pre-credit requirement.
- Bit cancellation fines.
- Off-platform contact sharing → fraud alert.
- **Built:** ❌ Not started.

#### 11I — Night Drive / Fatigue Alert
- Continuous driving for several hours → rest advisory.
- **Built:** ❌ Not started.

#### 11J — Trip Acceptance & Load Details
- Available trips on map: distance, destination, payload, pay rate.
- Accept trip → full details: contacts, delivery address, required documents, estimated time, pay breakdown.
- **Built:** ❌ Not started.

#### 11K — Pre-Trip Checklist & Vehicle Inspection
- Vehicle health check: lights, mirrors, tire pressure.
- Upload odometer reading, fuel level, cargo inspection photo.
- System blocks trip if any check fails.
- **Built:** ❌ Not started.

#### 11L — Real-Time Earnings Breakdown
- Per-trip pay: base pay + distance bonus + on-time bonus − late penalty.
- Running daily/weekly/monthly totals.
- **Built:** ❌ Not started.

#### 11M — Safe Routes & Danger Zone Alerts
- Recommended route on Google Maps.
- Highlight danger zones (high-crime, flood-prone, accident hotspots).
- Option for longer but safer route.
- **Built:** ❌ Not started.

#### 11N — Emergency SOS & Roadside Assistance
- SOS button logs location, contacts roadside assistance, alerts dispatcher and nearby drivers, auto-calls emergency contact.
- **Built:** ❌ Not started.

#### 11O — Driver Rest & Fatigue Compliance
- Track consecutive driving hours.
- Alert after 5 hours; force break after 10 hours.
- Log break duration and location.
- **Built:** ❌ Not started.

#### 11P — Income Tax Estimation & GST Compliance
- Calculate estimated tax liability.
- GST amount display if registered.
- Digital receipts for expense deductions.
- GST filing export support.
- **Built:** ❌ Not started.

#### 11Q — Skills & Certification Tracking
- Track CDL expiry, hazmat cert, defensive driving training.
- Highlight trips requiring specific certs.
- Auto-notify renewal due dates.
- **Built:** ❌ Not started.

#### 11R — Driver Performance Leaderboard
- Public leaderboard: rating, on-time %, earnings.
- Badges for milestones (100 trips, 4.8+ rating, zero incidents).
- **Built:** ❌ Not started.

---

### MODULE 12 — B2B MARKETPLACE PLATFORM
**Domain:** Wholesale Commerce Engine · **Code Namespace:** `transport_marketplace`  
**Build Status:** ██░░░░░░░░ 15 % — Marketplace shell, BLoC scaffold, and routing exist

#### 12A — Verified Corporate Storefront Spaces
- Dedicated business-to-business profiles reserved exclusively for Tier-1 manufacturing factories and certified large wholesalers.
- Profile verification workflow.
- **Built:** ❌ Not started.

#### 12B — High-Velocity Inventory Catalogs (Elasticsearch)
- Enterprise product showcase pulling structural inventory data through Elasticsearch Engines.
- Low-latency searching across high-volume listings (<20 ms).
- Multi-attribute indexing: product name, category, price range, MOQ, location.
- **Tech:** Elasticsearch 8+ integration; Laravel Scout with Elasticsearch driver.
- **Built:** ❌ Elasticsearch not yet integrated.

#### 12C — Dynamic Volume-Tier Pricing Engines
- Automated financial logic calculating per-unit pricing adjustments based on volume scales.
- Tier definitions configurable per product.
- **Built:** ❌ Not started.

#### 12D — Multi-Buyer Order Pooling Engine (Group Wholesale)
- Cooperative purchase engine: individual retail shopkeepers bundle order requirements to unlock bulk pricing tiers from factories.
- Pool status: Open → Gathering → Locked → Ordered.
- Minimum participants before pool locks.
- **Built:** ❌ Not started.

#### 12E — Secure B2B Escrow Clearinghouse
- Secure financial workflow locking transaction capital.
- Release payouts to suppliers only after delivery confirmation scans verified by logistics network.
- Escrow lifecycle: On-Hold → Buyer-Confirms-Receipt → Seller-Funds-Released (or Dispute-Filed).
- **Built:** ❌ Not started.

#### 12F — Encrypted B2B Commercial Chat Channels (Supabase)
- High-speed communication messaging engine powered by Supabase Live Sync Bridges.
- Inline contract creation and price negotiation blocks directly inside conversation view.
- End-to-end encrypted messages.
- **Tech:** Supabase Realtime (WebSocket); PostgREST for message persistence.
- **Built:** ❌ Supabase not yet integrated.

---

#### 12G — Driver Dispatch Scanning Safeguard (Cross-Module)
- Truck Driver cannot start transit without physically scanning warehouse-provided shipment QR code (delivery_secure_token).
- System verifies shipment scanned contents exactly match invoice items from B2B order before unlocking transit state.
- On scan match: delivery status advances to in_transit; mismatch triggers fraud alert to Super Admin (Module 1M).
- **Tech:** retail_deliveries table; RetailDistributionService::verifyDriverPickupScan() compares scanned items vs order line items; Rust FFI for high-speed QR decode.
- **Built:** Not started.
#### 12H — 4-Tier Factory Distribution Matrix
- **Type 1 (Open-Market):** Catalog, prices, stock completely public. Anyone can buy directly with zero restrictions.
- **Type 2 (Exclusive Wholesale):** Shopkeepers hard-blocked — must purchase only via registered Resellers. Resellers can cross-sell nationwide.
- **Type 3 (Zone-Locked Monopoly):** FMCG-style. Resellers bound to geographical Zone/City ID. Selling outside approved zone throws territorial violation block.
- **Type 4 (Stealth Locked-Price):** Highly confidential. Reseller must click Unlock Product Data which fires Phone/Email OTP challenge before viewing/purchasing.
- **Tech:** factory_type enum on factory tables; reseller_factory_zones; stealth_product_unlocks; FactoryMatrixValidationService guards.
- **Built:** Not started.
#### 12I — 2-Tier Reseller Margin Controller
- **Part 1 (MSRP Enforced Guard):** Absolute factory price control. Buy rate Rs. 400, sell rate Rs. 450 — Reseller cannot alter by Re. 1. System hard-locks invoice generator.
- **Part 2 (Open-Margin Wholesale):** Resellers buy at locked rate but set own wholesale price as custom listing on Trace Odd Marketplace.
- **Tech:** is_msrp_enforced flag on marketplace_product_listings; factory_buy_price + reseller_sell_price columns; MSRPViolationException in ResellerPortalService checkout flow.
- **Built:** Not started.
#### 12J — Reseller B2B Whitelisting (OTP Product Vault)
- Resellers can publish wholesale listings restricted to hand-picked cohort of retail shopkeepers.
- Privileged shopkeeper clicks locked listing → auto SMS/Email OTP challenge → unlocks hidden wholesale pricing + order node.
- **Tech:** reseller_otp_locked flag on listings; MarketplaceSubscriptionService::processResellerOtpGate().
- **Built:** Not started.
#### 12K — Brand Piracy & IP Protection Blocker
- If Shopkeeper/Reseller attempts to self-upload a product under registered Factory Brand name/SKU namespace without digital authorization flag, system triggers strict catalog rejection.
- Regex match against factory trademark strings; TrademarksViolationException on piracy attempt.
- **Tech:** is_brand_verified flag; MarketplaceSubscriptionService::validateListingCapAndPiracy() interceptor.
- **Built:** Not started.
#### 12L — Tiered Peer-to-Peer Selling Subscription Engine
- **Shopkeeper Basic Tier (Free):** Max 5 active homemade/cottage-industry product listings.
- **Standard Reseller Tier (Paid):** Bulk listing unlocked; active monthly subscription ledger via Step 8 Finance.
- **Free Universal Buyer Paradigm:** Zero boundaries, caps, or subscription requirements for BUYING. Any verified user can purchase any public/allowed item with 0% system buyers fee.
- **Tech:** marketplace_subscriptions table; max_allowed_items enforcement; Step 8 double-entry ledger for subscription payments.
- **Built:** Not started.
### MODULE 13 — PUBLIC TRANSPORT BUS ADMIN PANEL
**Domain:** Transit Fleet Control · **Code Namespace:** Not yet allocated  
**Build Status:** ░░░░░░░░░░ 0 % — Not started

#### 13A — Enterprise Transport Network Matrix
- Central management console for transit brands.
- Build company profiles, catalog heavy assets, coordinate multi-line schedules.
- **Built:** ❌ Not started.
> **[REQUIRED TECH-STACK & INTEGRATION POINTS]**
> - **Dynamic Seat Grid Builder** (Step 12/14E): Bus Owner creates floor-plan layout via `POST /api/v1/bus-fleet/owners/layouts` — configures rows, columns, driver seats; stored as `raw_grid_json`.
> - **Gate QR Code Generation** (Step 12/15E): Register bus door QR via `POST /api/v1/bus-fleet/qr/register`; generates unique `qr_payload_uuid` linked to bus + active trip.
> - **Voucher Split Clearing Ledger** (Step 12/8W + Step 8): Physical NexaTrace voucher redemption with instant change credited to customer wallet via double-entry ledger.
> - **Live GPS Broadcasting** (Step 3): `BusLocationUpdated` WebSocket event on `bus.{route_id}` channel — consumed by Customer App (8V) for real-time tracking.
> - **Seat Booking** (Step 12): `POST /api/v1/bus-fleet/bookings` with 3-way payment (wallet/card/voucher); `lockForUpdate()` prevents double-booking.
> - **Stack Tags:** WebSockets, Redis Pub/Sub Subscription, Complex JSON Grid Builders, `BusInventoryService`, Step 8 Financial Ledger hooks.

#### 13B — Dynamic Route & Waypoint Line Scheduler
- Graphic mapping canvas to define fixed transit paths.
- Specify intermediate passenger terminals.
- Publish timetable models.
- **Tech:** Google Maps Drawing API; PostgreSQL route tables.
- **Built:** ❌ Not started.

#### 13C — Live Multi-Asset Telemetry Command View (WebSockets)
- Real-time spatial tracking interface mapping fleet positions via high-frequency WebSocket streams.
- Monitor arrival time compliance against schedule.
- **Tech:** WebSocket `BusLocationUpdated` event; Redis geospatial cache; Syncfusion real-time charts.
- **Built:** ❌ Not started.

#### 13D — Ticket Revenue Ledger Hub
- Central financial monitor: ticket sales, active seat booking states, online conversions, branch payout timelines.
- **Built:** ❌ Not started.

---

### MODULE 14 — BUS OWNERS APP
**Domain:** Independent Franchise Terminal · **Code Namespace:** Not yet allocated  
**Build Status:** ░░░░░░░░░░ 0 % — Not started

#### 14A — Franchise Vehicle Profile Registry
- Asset management panel: register physical vehicles under parent transit brand network.
- **Built:** ❌ Not started.

#### 14B — Automated Fleet Operational Logs
- Financial reporting: daily passenger statistics, total route runs, gross ticket balances, platform service fees.
- **Built:** ❌ Not started.

#### 14C — Driver Shift Scheduling Core
- Crew allocation module: assign verified drivers to specific vehicle IDs.
- Log active hours.
- **Built:** ❌ Not started.

#### 14D — Real-Time Coach Asset Diagnostic Interface
- Summary view: real-time vehicle maintenance requirements, active line statuses, repair logs.
- **Built:** ❌ Not started.

---

#### 14E — Dynamic Seat Grid Builder (Visual Floor-Plan Layout)
- Bus Owner configures a visual floor-plan layout builder similar to a house floor plan.
- Configurable parameters: total row lines, left-side seat count (2 or 3), right-side seat count (2 or 1), driver-adjacent seats (1 or 2), aisle configuration.
- Stored as structured JSON in bus_layouts table (raw_grid_json) for rendering in Customer App seat selection (Module 8V).
- **Tech:** Flutter GridView.builder rendering seat map; bus_layouts migration; raw_grid_json schema.
- **Built:** Not started.
### MODULE 15 — BUS DRIVERS APP
**Domain:** On-Route Navigation Terminal · **Code Namespace:** Not yet allocated  
**Build Status:** ░░░░░░░░░░ 0 % — Not started

#### 15A — Active Line Manifest Terminal
- Simplified operational view: active route tasks, upcoming terminal checkpoints, live schedule compliance graphs.
- **Built:** ❌ Not started.

#### 15B — High-Frequency Spatial Telemetry Beacon
- High-frequency location broadcasting engine.
- Flutter Signals / Lightweight Streams to broadcast continuous coordinates to consumer applications.
- **Tech:** `Stream.periodic()` → WebSocket emit `BusDriverLocation`; low-overhead location plugin.
- **Built:** ❌ Not started.

#### 15C — Contactless Passenger Boarding Interface (Rust FFI)
- High-speed boarding confirmation: native Rust via FFI optimizes device camera pipeline.
- Processing ticket QR codes under 50 ms during heavy boarding cycles.
- **Tech:** Rust camera binarization → QR decode; Flutter FFI bridge.
- **Built:** ❌ Not started.

#### 15D — Real-Time Dispatch Advisory Core
- Real-time alerts: traffic events, roadside delays, instant rerouting commands from control center.
- **Tech:** WebSocket push from admin panel; in-app alert overlay.
- **Built:** ❌ Not started.

---

#### 15E — Gate QR Code Automation (Door-Mounted NexaTrace Codes)
- Every bus has a unique NexaTrace QR Code printed on the door.
- When scanned via Module 8 Customer App, it instantly returns: bus registration number, active route profile (origin to destination), current live GPS location/ETA, and real-time available seat count — without any human interaction.
- **Tech:** bus_qr_codes table; QR payload UUID links to bus_id + active_trip_id; WebSocket BusLocationUpdated for live GPS; BusInventoryService for seat count.
- **Built:** Not started.
### MODULE 16 — [CONSOLIDATED INTO MODULE 8 — CUSTOMERS APP (2-in-1)]
> **Strategic Decision:** A dedicated Bus Passenger App is unnecessary. All bus passenger features (seat selection, live bus tracking, encrypted ETA links, QR ticketing) have been consolidated into Module 8 as a unified 2-in-1 Customer App. Passengers use the same NexaTrace Customer App for both product anti-counterfeit verification AND live bus transit booking/tracking.
### MODULE 17 — [PERMANENTLY REMOVED — P2P Car Trip Sharing]
> **Strategic Decision:** Private car trip sharing creates a direct conflict of interest with commercial Bus Fleet Operators. If bus passengers shift to shared private cars, Bus Companies face financial losses and will reject the NexaTrace platform. This module is permanently shelved and will be launched as a standalone future project under a different brand, alongside a Restaurant Food Delivery network.
## 4. CROSS-CUTTING ARCHITECTURAL CONCERNS (12A–12O)

#### 15F — Passenger Terminal NFC Check-In (Hardware Gateway)
- Physical NexaTrace NFC Device (codenamed Dabi) installed at bus terminals.
- Passenger taps smartphone on NFC device to register immutable time-stamped timestamp and geofence verification log — proving arrival on time.
- If driver left before scheduled departure, NFC log serves as formal dispute evidence triggering automatic escrow freeze on bus owner ticket revenue.
- **Tech:** transit_nfc_devices table; TransitDisputeService::verifyNfcCheckIn() with lockForUpdate() on trip; automatic escrow hold via Step 8 CommissionService.
- **Built:** Not started.
### 12A — Payment & Wallet Architecture (CRITICAL — Before MVP)
- **Wallet State Machine:** `Pending` → `Settled` → `Cleared`
- **Double-Entry Bookkeeping:** Every transaction produces balanced debit/credit entries.
- **Weekly Reconciliation:** Auto-compare with payment gateway records.
- **PCI-DSS Compliance:** Card data never stored; tokenization via gateway.
- **Multi-Gateway Support:** Stripe primary, PayPal secondary, local gateways tertiary.
- **2-Factor Confirmation:** Mandatory for amounts > $10K equivalent.

### 12B — Authentication & Multi-Tenancy (CRITICAL — Before MVP)
- **Row-Level Security (RLS):** PostgreSQL RLS policies per tenant.
- **Field-Level Encryption:** AES-256 on PII fields at rest.
- **JWT Rotation:** Every 8 hours; refresh token lifespan 30 days.
- **Device Fingerprinting:** Hash of device attributes; SMS OTP challenge for new devices.
- **Rate Limiting:** 5 login attempts per 15 minutes per IP + account.
- **Session Termination:** All active sessions invalidated on password change.

### 12C — Escrow & Dispute Resolution (CRITICAL — Before MVP)
- **Escrow Lifecycle:** On-Hold → Buyer-Confirms-Receipt (24 hr grace) → Funds-Released OR Dispute-Filed (7-day freeze).
- **3-Way Verification:** Required for transactions > $50K.
- **Auto-Release:** After 7 calendar days if no dispute filed.
- **Partial Refunds:** Supported with prorated escrow release.
- **Mediation Queue:** Human-mediated resolution for disputes > $50K.

### 12D — Audit & Compliance Logging (CRITICAL — Before MVP)
- **Log Schema:** `actor_id, actor_type, entity_type, entity_id, old_value (JSON), new_value (JSON), action, ip_address, device_fingerprint, timestamp`.
- **Immutability:** Append-only storage; no UPDATE or DELETE on audit table.
- **Retention:** 7 years minimum; monthly signed exports (CSV + SHA-256 hash).
- **Search:** Full-text search via PostgreSQL `tsvector` or Elasticsearch.
- **SIEM Integration:** Syslog export for Security Information and Event Management.

### 12E — Data Validation & Consistency (HIGH — MVP Phase 1)
- **Dual Validation:** Frontend (form validation) + Backend (request validation + database constraints).
- **Database Constraints:** `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY` on all critical columns.
- **Integration Tests:** Per workflow: 1 happy path + 3 error paths minimum.
- **Checksums:** CRC32 on critical data payloads for integrity verification.

### 12F — Offline Sync & Conflict Resolution (HIGH — MVP Phase 1)
- **Conflict Strategy:** Last-write-wins for non-critical data; server timestamp as Source of Truth for code uniqueness.
- **CRDTs:** Conflict-free Replicated Data Types for non-losable operations (future).
- **Sync Changelog:** Detect conflicts; present visual diff UI for manual resolution.
- **Soft-Delete:** Offline deletions use `deleted_at` timestamp, never hard-delete.

### 12G — Scalability & Performance (HIGH — MVP Phase 1)
- **Pagination:** Cursor-based (keyset) pagination; default 25 items, max 100.
- **Caching:** Redis with 1-hour TTL for dashboard aggregates; cache invalidation on write events.
- **Indexing:** Database indexes on all foreign keys, date range query columns, and multi-column compound indexes (`CREATE INDEX idx_scans_code_type ON scans(code, type)`).
- **Async Processing:** Laravel Queue Jobs for all heavy operations (code generation, notifications, auction matching).
- **CDN:** Cloudflare or similar for static Flutter web assets.
- **API Rate Limiting:** Per-plan tier at API gateway.

### 12H — Security & Encryption (HIGH — MVP Phase 1)
- **Transport:** TLS 1.3+ exclusively; HTTP Strict Transport Security (HSTS).
- **Certificate Pinning:** SSL/TLS pinning in Flutter app.
- **API Key Rotation:** Every 90 days; automated rotation reminder.
- **Secrets Management:** Environment variables only; never in codebase.
- **PII Encryption:** AES-256-GCM at rest via Laravel encryption.
- **Password Hashing:** bcrypt with minimum 12 rounds.
- **OWASP Audits:** Annual penetration testing and code review.

### 12I — Data Retention & GDPR Compliance (HIGH — MVP Phase 1)
- **Retention Policy:** Defined per data type in `data_retention_policies` table.
- **GDPR Export:** ZIP/JSON export endpoint; fulfillment within 30 days.
- **Right to Delete:** Honored with legal exception documentation.
- **Cookie Consent:** Explicit opt-in for non-essential cookies.
- **Privacy Policy:** Annual review and update cycle.

### 12J — Fraud & Anti-Counterfeiting (HIGH — MVP Phase 1)
- **ML-Based Detection:** Fraud score (0–100) using rule-based engine initially; ML pipeline in future.
- **Behavioral Biometrics:** Mouse/touch patterns, typing rhythm (future).
- **Batch-Level Counterfeit:** Aggregate scan anomaly reports → batch recall trigger.
- **Whistleblower Program:** Reward credits for verified counterfeit reports.
- **Authority Collaboration:** Evidence package export for law enforcement.

### 12K — Notification Architecture (HIGH — MVP Phase 1)
- **Multi-Channel:** In-app (WebSocket), Email (Laravel Mail), SMS (Twilio), Push (FCM), WhatsApp (future).
- **User Preferences:** Opt-out per notification type and per channel.
- **Retry Logic:** Exponential backoff; dead-letter queue for permanently failed deliveries.
- **A/B Testing:** Template variant testing (future).

### 12L — Analytics & Reporting (HIGH — MVP Phase 1)
- **BI Integration:** Metabase or Apache Superset connected to read replica.
- **Report Types:** Predefined (subscription revenue, code throughput, driver KPIs) + Custom (query builder).
- **Exports:** PDF, CSV, JSON.
- **Scheduling:** Automated report generation and email delivery.
- **Predictive Analytics:** Churn prediction, demand forecasting, anomaly detection (future).

### 12M — Batch Operations & Async Processing (HIGH — MVP Phase 1)
- **Chunking:** 1,000-item chunks with checkpoint/resume.
- **Progress API:** `GET /api/v1/jobs/{id}/progress` returning percentage and ETA.
- **Idempotency:** Idempotency keys on all batch operations.
- **Webhook Callback:** `POST` to registered webhook URL on job completion.
- **Dead-Letter Queue:** Failed chunks retried 3× then moved to DLQ for manual review.

### 12N — Mobile Network Resilience (HIGH — MVP Phase 1)
- **Binary Protocol:** Protocol Buffers (protobuf) for low-bandwidth scenarios (future).
- **Service Worker:** PWA support for web offline access.
- **Retry Strategy:** Exponential backoff with jitter; max 5 retries.
- **Request Debouncing:** 500 ms window for scan-heavy operations via RxDart `EventTransformer.debounce`.
- **Selective Sync:** Prioritize critical data (codes, trips) over analytics prefetch.

### 12O — Regulatory Compliance by Region (MEDIUM — Phase 2)
- **India:** GST-compliant invoicing, FSSAI food product tracking.
- **EU:** GDPR, ePrivacy Directive cookie compliance.
- **Medical (US):** HIPAA data handling for medical product tracking.
- **Feature Toggle:** Enable/disable compliance features per region during company onboarding.

---

## 5. SUBSCRIPTION PLANS SYSTEM

### 5.1 Factory / Enterprise Plans

| Feature | Free ($0) | Basic ($49) | Standard ($149) | Premium ($499) | Custom |
|---------|-----------|-------------|-----------------|----------------|--------|
| Unit Codes/Month | 5,000 | 50,000 | 200,000 | 1,000,000 | Negotiated |
| Store Locations | 1 | 5 | 20 | Unlimited | Unlimited |
| Driver Accounts | 1 | 3 | Unlimited | Unlimited | Unlimited |
| Transport Connections | ❌ | 10/mo | 50/mo | Unlimited | Unlimited |
| Contact Drivers | ❌ | ✅ | ✅ | ✅ | ✅ |
| Contact Owners | ❌ | ❌ | ✅ | ✅ | ✅ |
| Use Goods Companies | ❌ | ❌ | ✅ | ✅ | ✅ |
| Load Posting | ❌ | 5/mo | 20/mo | Unlimited | Unlimited |
| Live Truck Tracking | ❌ | ❌ | ✅ | ✅ | ✅ |
| Route Optimization | ❌ | ❌ | ❌ | ✅ | ✅ |
| Escrow Payments | ❌ | ❌ | ❌ | ✅ | ✅ |
| GPS Attendance Tracking | ❌ | ❌ | ✅ | ✅ | ✅ |
| Salary Management | ❌ | ❌ | ✅ | ✅ | ✅ |
| Zoho Books Integration | ❌ | ❌ | ✅ | ✅ | ✅ |
| Multi-Company Control | ❌ | ❌ | ❌ | ✅ | ✅ |
| SAP Integration | ❌ | ❌ | ❌ | ❌ | ✅ |
| Dedicated Support | ❌ | ❌ | ❌ | ✅ | ✅ |
| API Access | ❌ | Limited | Full | Full | Full |

### 5.2 Goods Company Plans (Separate)

| Feature | Basic ($29) | Professional ($79) | Enterprise ($199) |
|---------|-------------|--------------------|--------------------|
| Truck Connections | 20 | 50 | Unlimited |
| Factory Connections | 10 | 25 | Unlimited |
| Monthly Trips | 50 | 150 | Unlimited |
| Commission Range | 5–15 % | 5–20 % | 5–25 % |
| Live Tracking | ✅ | ✅ | ✅ |
| Bidding System | Basic | Advanced | Advanced |
| Auto-Commission | ❌ | ✅ | ✅ |
| Auto-Bidding | ❌ | ✅ | ✅ |
| WhatsApp Integration | ❌ | ✅ | ✅ |
| Escrow Payments | ❌ | ❌ | ✅ |
| White-Label | ❌ | ❌ | ✅ |
| API Calls/Day | 1,000 | 5,000 | 20,000 |
| Support Level | Email | Chat | Phone |

---

## 6. IMPLEMENTATION STATUS MATRIX

### 6.1 Flutter Features — Built vs. Pending

| Module | Feature | BLoC | Screens | Rust FFI | Offline | Status |
|--------|---------|------|---------|----------|---------|--------|
| **1 — Super Admin** | Dashboard | ✅ | ✅ | — | — | ✅ 90 % |
| | Plan CRUD | ✅ | ✅ | — | — | ✅ |
| | Billing / Invoices | ✅ | ✅ | — | — | ✅ |
| | Transport Wallet | ✅ | ✅ | — | — | ✅ |
| | Audit Logs | ⚠️ | ❌ | — | — | ⚠️ 30 % |
| | Notification Engine | ⚠️ | ❌ | — | — | ⚠️ 20 % |
| | Integration Hub | ❌ | ❌ | — | — | ❌ |
| **3 — Factory** | Product CRUD | ✅ | ✅ | ✅ | — | ✅ 85 % |
| | Bundle/Carton/Packet Gen | ✅ | ✅ | ✅ | — | ✅ |
| | Unit Code Gen | ✅ | ✅ | ✅ | — | ✅ |
| | Publish + Billing | ✅ | ✅ | — | — | ✅ |
| | Store Keeper CRUD | ✅ | ✅ | — | — | ✅ |
| | Driver CRUD | ✅ | ✅ | — | — | ✅ |
| | Reseller Linking | ⚠️ | ⚠️ | — | — | ⚠️ 40 % |
| **4 — Drivers** | Pickup/Delivery Scan | ✅ | ✅ | ✅ | — | ✅ 100 % |
| | 100 m Geofence | ✅ | ✅ | — | — | ✅ |
| | Proof of Delivery | ✅ | ✅ | — | — | ✅ |
| | Expenses (Fuel/Food/Mech) | ✅ | ✅ | — | — | ✅ |
| | Chat | ✅ | ✅ | — | — | ✅ |
| | Vehicle Maintenance | ✅ | ✅ | — | — | ✅ |
| | Earnings / KPIs | ✅ | ✅ | — | — | ✅ |
| | Offline Sync | ⚠️ | ✅ | — | ⚠️ | ⚠️ 60 % |
| | Fake GPS Check | ✅ | ✅ | — | — | ✅ |
| **5 — Store Keeper** | Scanner + Torch | ✅ | ✅ | ✅ | — | ✅ 100 % |
| | Bundle → Carton → Packet | ✅ | ✅ | — | — | ✅ |
| | Unit Insertion | ✅ | ✅ | — | — | ✅ |
| | Rack Allocation | ✅ | ✅ | — | — | ✅ |
| | Offline Hive Ledger | ✅ | ✅ | — | ✅ | ✅ |
| | Buyer Link + Push | ✅ | ✅ | — | — | ✅ |
| | Hierarchy View | ⚠️ | ⚠️ | — | — | ⚠️ 50 % |
| **6 — Reseller** | Auth Shell | ⚠️ | ✅ | — | — | ⚠️ 20 % |
| | All features | ❌ | ❌ | — | — | ❌ |
| **7 — Shop Keeper** | Auth Shell | ⚠️ | ✅ | — | — | ⚠️ 15 % |
| | All features | ❌ | ❌ | — | — | ❌ |
| **8 — Customer** | Anti-Counterfeit Scan | ⚠️ | ⚠️ | ⚠️ | — | ⚠️ 10 % |
| | All other features | ❌ | ❌ | — | — | ❌ |
| **9 — Goods Company** | Controller stub | ❌ | ❌ | — | — | ⚠️ 5 % |
| **10 — Truck Owner** | Nothing | ❌ | ❌ | — | — | ❌ 0 % |
| **11 — Truck Driver** | Nothing | ❌ | ❌ | — | — | ❌ 0 % |
| **12 — B2B Marketplace** | Shell + Routing | ⚠️ | ⚠️ | — | — | ⚠️ 15 % |
| **13–15 — Bus Ecosystem** | Shell only | ⚠️ | ❌ | — | — | ⚠️ 3 % |

### 6.2 Backend — Laravel Status

| Component | Status |
|-----------|--------|
| PostgreSQL Schema | ✅ Deployed (34 migration files) |
| Auth (Sanctum) | ✅ Factory, Admin, Reseller, Store Keeper auth |
| Code Generation API | ✅ Bundle, Carton, Packet, Unit controllers |
| Billing / Invoicing | ✅ `InvoiceService`, `PaymentService`, `BillingService` |
| Subscription Plans | ✅ `SubscriptionPlan` model + CRUD |
| Transport Controllers | ⚠️ `FraudController` only |
| Queue Jobs | ❌ No `app/Jobs/` directory exists |
| WebSocket Events | ❌ No `app/Events/` directory exists |
| Redis Integration | ⚠️ Config ready; queue + cache still on `database` driver |
| Elasticsearch | ❌ Not integrated |
| Supabase | ❌ Not integrated |

---

## 7. BACKEND INFRASTRUCTURE BLUEPRINT

### 7.1 COMPLETED BACKEND INFRASTRUCTURE REGISTRY (STEPS 1–13)

> **AUDIT STATUS (2026-05-22):** All 13 infrastructure steps are **100% implemented, production-ready, and operational.** Each step below documents the exact backend business logic, namespace, queue assignment, and service class. No step is pending — every queue job, WebSocket event, service, migration, and controller listed here exists as physical files in the `backend/` directory.

---

#### Step 1 — Redis Integration Layer

| Property | Value |
|----------|-------|
| **Service** | `App\Services\Redis\RedisCacheService` |
| **Purpose** | Centralized high-speed indexing, caching, and rate-limiting layer |
| **Features** | Dashboard analytics cache (60 s TTL), fleet telemetry geospatial positions (120 s TTL), chart data (3600 s TTL), per-user rate limiting (60 s windows), session state (900 s TTL), generic key-value store with `remember()` pattern |
| **Fallback** | All methods degrade gracefully — `isAvailable()` check gates every operation; Redis down → returns null/empty, never throws |
| **Target Modules** | 1D, 9H, 13C, 6E |

---

#### Step 2 — Bulk Code Generation Engine

| Property | Value |
|----------|-------|
| **Job** | `App\Jobs\BulkCodeGenerationJob` |
| **Controller** | `App\Http\Controllers\Factory\Codes\BulkCodeGenerationController` |
| **Queue** | `high` (Redis) — Timeout: 600 s, Retries: 3 |
| **Purpose** | Asynchronous barcode/serial generation for millions of QR, ITF-14, alphanumeric codes |
| **Architecture** | Chunked processing (default 500 codes/chunk, configurable 100–5000); reuses existing `CodeGenerator` service internally; progress tracking via cache (`bulk_gen:progress:{jobId}`); POST dispatches, GET polls progress |
| **Safety** | Runs alongside existing synchronous generation — zero collision; min bulk threshold = 100 codes so small requests stay on sync path |
| **Target Modules** | 3B, 3F, 3G, 3V |

---

#### Step 3 — Real-Time Communication Hub (WebSocket Events)

| Property | Value |
|----------|-------|
| **Config** | `config/broadcasting.php` — Drivers: `log` (default/safe), `redis`, `reverb` |
| **Events (6)** | `FleetLocationUpdated`, `TripStatusChanged`, `DriverLocationUpdated`, `AuctionBidPlaced`, `DeliveryConfirmed`, `GeofenceScanUnlocked` |
| **Channels** | `fleet.{company_id}`, `trip.{trip_id}`, `driver.{driver_id}`, `auction.{load_id}`, `delivery.{delivery_id}`, `store_keeper.{id}` |
| **Purpose** | Full-duplex persistent WebSocket connections for live truck/bus telemetry, real-time chat, auction bidding, and geofence handshakes |
| **Fallback** | Default driver = `log` — all events write to `laravel.log` without crashing; `broadcastWhen()` logs payload in log-only mode |
| **Registration** | `App\Providers\AppServiceProvider::boot()` — `Broadcast::routes(['middleware' => ['auth:sanctum']])` |
| **Target Modules** | 4C, 6E, 9H, 10J, 13C, 16B |

---

#### Step 4 — Driver ↔ Store Keeper Secure Handshake

| Property | Value |
|----------|-------|
| **Event** | `App\Events\GeofenceScanUnlocked` |
| **Service** | `App\Services\Handshake\HandshakeService` |
| **Controller** | `App\Http\Controllers\Factory\DriverHandshakeController` |
| **Purpose** | Geofence-gated (100 m) verification handshake between Factory Driver and Store Keeper |
| **Flow** | Driver enters geofence → POST `/driver/handshake/arrived` → Redis state stored (5 min TTL) → WebSocket alert to Store Keeper channel → Store Keeper acknowledges via POST `/{tripId}/acknowledge` → Driver receives confirmation |
| **State Machine** | `driver_arrived` → `store_keeper_acknowledged` → `driver_scanned` |
| **Safety** | Entirely independent service; zero modification to existing DriverController or StoreKeeperController |
| **Target Modules** | 4A, 4C, 4D, 5A, 5N |

---

#### Step 5 — B2B Wholesale Marketplace Engine

| Property | Value |
|----------|-------|
| **Migrations (4)** | `marketplace_storefronts`, `marketplace_product_listings`, `marketplace_group_buy_pools`, `marketplace_pool_participants` |
| **Models (4)** | `App\Models\Marketplace\{Storefront, ProductListing, GroupBuyPool, PoolParticipant}` |
| **Services (2)** | `App\Services\Marketplace\ElasticsearchCatalogService` (dual-mode: Elasticsearch + PostgreSQL FTS fallback), `App\Services\Marketplace\GroupBuyPoolService` (pool lifecycle: open → gathering → locked → ordered → completed) |
| **Controllers (2)** | `CatalogController` (search, facets, storefronts), `GroupBuyPoolController` (CRUD, join, lock, cancel) |
| **Purpose** | Elasticsearch-driven product catalog search (<20 ms target), verified corporate storefronts, dynamic volume-tier pricing, multi-buyer group wholesale pooling |
| **Pool Lifecycle** | `open → gathering → locked → ordered → completed` (with `cancelled`/`expired` fallbacks) |
| **Safety** | Entirely in `App\Services\Marketplace\` namespace; PostgreSQL GIN full-text index as fallback when Elasticsearch disabled |
| **Target Modules** | 12A, 12B, 12C, 12D |

---

#### Step 6 — Freight Auction Matching Engine

| Property | Value |
|----------|-------|
| **Migrations (2)** | `freight_loads`, `freight_bids` |
| **Models (2)** | `App\Models\{FreightLoad, FreightBid}` |
| **Service** | `App\Services\Freight\FreightAuctionService` |
| **Job** | `App\Jobs\FreightAuctionMatchingJob` — Queue: `auctions` (Redis), Timeout: 120 s, Retries: 2 |
| **Controller** | `App\Http\Controllers\FreightAuctionController` |
| **Purpose** | Automated multi-criteria freight bidding and matching: loads posted → truck owners/drivers bid → deadline triggers weighted scoring algorithm → winner selected, losers rejected, load status → matched |
| **Scoring** | `score = (price_ratio × 0.45) + (rating × 0.30) + (proximity × 0.15) + (speed × 0.10)` |
| **Safety** | `lockForUpdate()` on load rows during bid placement; all matching in DB transactions; `AuctionBidPlaced` WebSocket event on every bid |
| **Target Modules** | 9D, 10D, 11D |

---

#### Step 7 — Automated Notification Blast Engine

| Property | Value |
|----------|-------|
| **Migration** | `notification_templates`, `notification_logs`, `user_notification_preferences` |
| **Models (3)** | `App\Models\Notification\{NotificationTemplate, NotificationLog, UserNotificationPreference}` |
| **Service** | `App\Services\Notification\NotificationBlastService` |
| **Job** | `App\Jobs\NotificationBlastJob` — Queue: `notifications` (Redis), Timeout: 300 s, Retries: 2 |
| **Controller** | `App\Http\Controllers\NotificationController` |
| **Purpose** | Mass multi-channel notification dispatch supporting: WebSocket (in-app), Email (Laravel Mail), Push (FCM stub), SMS (Twilio stub) |
| **Features** | User opt-out preferences (per type, per channel); Redis-backed rate limiter (email:10, push:20, sms:5, ws:30 per 60 s); exponential backoff dead-letter queue (30 s → 60 s → 120 s, max 3 retries); target filtering by company, plan tier, role |
| **Safety** | Does NOT replace existing `NotificationService.php` (invoice emails); FCM/SMS are stubs — degrade gracefully; all channels log instead of throw |
| **Target Modules** | 1F, 12K |

---

#### Step 8 — Financial Double-Entry Ledger System

| Property | Value |
|----------|-------|
| **Migration** | `financial_wallets`, `financial_wallet_transactions`, `financial_commission_configs` |
| **Models (3)** | `App\Models\Financial\{Wallet, WalletTransaction, CommissionConfig}` |
| **Service** | `App\Services\Financial\CommissionService` |
| **Job** | `App\Jobs\CommissionPayoutJob` — Queue: `finance` (Redis), Timeout: 120 s, Retries: 2 |
| **Purpose** | Immutable double-entry bookkeeping: every financial operation produces paired credit+debit entries; platform treasury wallet; escrow hold/release; tier-based commission calculation |
| **Flow** | Payout: Payer Wallet (DEBIT $1,000) → Treasury Wallet (CREDIT $100 commission) + Payee Wallet (CREDIT $900 net) — 3 immutable `wallet_transactions` linked via `counterpart_transaction_id` |
| **Escrow** | `holdInEscrow()` / `releaseEscrow()` with `lockForUpdate()` race protection |
| **Commission** | Configurable: percentage, flat, or tiered (e.g., 0–1K: 15%, 1K–5K: 10%, 5K+: 5%) per module + payer type |
| **Safety** | All mutations in `DB::transaction()` with `lockForUpdate()` on wallet rows; insufficient funds throw `RuntimeException` |
| **Target Modules** | 9G, 10F, 11H, 12A, 12C |

---

#### Step 9 — Time-Series Analytics Aggregator

| Property | Value |
|----------|-------|
| **Migration** | `analytics_snapshots` |
| **Model** | `App\Models\Analytics\AnalyticsSnapshot` |
| **Service** | `App\Services\Analytics\AnalyticsService` |
| **Job** | `App\Jobs\AnalyticsAggregationJob` — Queue: `analytics` (Redis), Timeout: 60 s, Retries: 1 |
| **Controller** | `App\Http\Controllers\AnalyticsController` |
| **Purpose** | Chronological metric calculator with multi-tiered data snapshot frequencies: `realtime` (60 s), `hourly`, `daily`, `weekly`, `monthly` |
| **Metric Groups** | `marketplace` (GMV, active pools, listings, fill rate), `freight` (active loads, completed trips, avg bid, match rate), `financial` (platform revenue, commission, payouts, wallet balance), `system` (active users, factories, codes generated, health score 0–100) |
| **Caching** | Realtime dashboard cached in Redis (60 s TTL); chart data cached per query (3600 s TTL); all snapshots UPSERTED via `updateOrCreate` — never overwrites historical data |
| **Safety** | READ-ONLY on all production tables; writes only to `analytics_snapshots` + Redis cache |
| **Target Modules** | 1D, 2C, 3AE |

---

#### Step 10 — Resilient Offline Synchronization Engine

| Property | Value |
|----------|-------|
| **Migration** | `offline_sync_payloads` |
| **Model** | `App\Models\Sync\OfflineSyncPayload` |
| **Service** | `App\Services\Sync\OfflineSyncService` |
| **Job** | `App\Jobs\OfflineSyncProcessingJob` — Queue: `sync` (Redis), Timeout: 180 s, Retries: 2 |
| **Controller** | `App\Http\Controllers\OfflineSyncController` |
| **Purpose** | Client-timestamp chronological data replay from Store Keeper (Module 5B) and Factory Driver (Module 4Z) offline mutations |
| **Idempotency** | Every payload carries a `client_uuid` (client-generated UUID); `isDuplicate()` check before processing; UNIQUE constraint on `client_uuid` column; re-sent packets → marked `duplicate`, skipped |
| **Conflict Resolution** | Scan codes: online timestamp wins over offline (first-scan priority); non-critical data: last-write-wins; conflicts logged in `resolved_conflicts` JSON field |
| **Replay Handlers** | `store_keeper`: scan_code, link_code, rack_allocate; `factory_driver`: update_trip_status, submit_expense, scan_pickup, scan_delivery; `truck_driver`: update_location |
| **Safety** | Statuses: `pending → processing → processed | failed | duplicate`; failed payloads retried up to 3× |
| **Target Modules** | 4Z, 5B, 5K, 5S, 12F |

---

#### Step 11 — Distributed Panel Routing Gateway

| Property | Value |
|----------|-------|
| **Provider** | `App\Providers\PanelRouteServiceProvider` (registered in `bootstrap/app.php`) |
| **Route Files (5)** | `routes/panels/{super_admin, factory, marketplace, truck_fleet, bus_fleet}.php` |
| **Prefix Map** | `super_admin.php` → `/api/v1/super-admin`, `factory.php` → `/api/v1/factory`, `marketplace.php` → `/api/v1/marketplace`, `truck_fleet.php` → `/api/v1/truck-fleet`, `bus_fleet.php` → `/api/v1/bus-fleet` |
| **Purpose** | Completely isolated routing structure — each panel file maps to its own prefix under `api/v1/` with `auth:sanctum` middleware |
| **Safety** | 100% additive; does NOT modify `routes/api.php`; existing routes continue to function; panel files start as stubs with commented-out future route declarations |
| **Module Coverage** | super_admin (1, 2), factory (3, 4, 5, 8), marketplace (6, 7, 12), truck_fleet (9, 10, 11), bus_fleet (13, 14, 15) |

---

#### Step 12 — Inter-City Bus Transport Ecosystem

| Property | Value |
|----------|-------|
| **Migrations (2)** | `transport_bus_layouts`, `transport_bus_qr_codes`, `transport_nexatrace_vouchers`; `transport_seat_bookings` |
| **Models (3)** | `App\Models\Transport\{BusLayout, BusQrCode, NexatraceVoucher}` |
| **Service** | `App\Services\Transport\BusInventoryService` |
| **Controller** | `App\Http\Controllers\BusTransitController` (wired in `routes/panels/bus_fleet.php`) |
| **Purpose** | Dynamic seat map configuration builder (14E), door-mounted automated QR scan verification (15E), 3-way tiered ticket payment framework (8W) |
| **Seat Grid** | Bus Owner configures visual floor-plan: total rows, left columns (2/3), right columns (2/1), driver seats (1/2), aisle config → stored as `raw_grid_json` |
| **Gate QR** | Unique NexaTrace QR per bus door → scan returns bus registration, active route, live GPS/ETA, available seat count — zero human interaction |
| **3-Way Payment** | 1. Wallet deduction via Step 8 ledger; 2. Card gateway stub; 3. Physical NexaTrace voucher with split-logic: bus owner paid ticket price, leftover change credited to customer wallet instantly |
| **Race Safety** | `lockForUpdate()` on bus layout rows during booking; `lockForUpdate()` on voucher rows during redemption; all in `DB::transaction()` |
| **Target Modules** | 8V, 8W, 14E, 15E |

---

#### Step 13 — Super Admin Financial Controller Layer

| Property | Value |
|----------|-------|
| **Integration** | Leverages Step 8 `CommissionService` and Step 12 `BusInventoryService` |
| **Purpose** | Administrative gateway for processing Bus Operator voucher cash settlements and customer wallet card withdrawal refund requests |
| **Settlement Flow** | Bus Operator requests voucher settlement → Super Admin verifies voucher redemption records → `CommissionService::processPayout()` transfers from treasury to bus owner wallet |
| **Withdrawal Flow** | Customer requests wallet withdrawal to bank → Super Admin verifies wallet balance + identity → initiates bank transfer → debits wallet via double-entry ledger |
| **Locking** | All settlement/withdrawal operations use pessimistic row-level locking (`lockForUpdate()`) to prevent race conditions during concurrent processing |
| **Safety** | All financial mutations routed through Step 8 immutable double-entry ledger; full audit trail in `financial_wallet_transactions` |
| **Target Modules** | 1H, 8E, 8W |

---

### 7.2 Queue Infrastructure Summary

| # | Job Class | Purpose | Dispatch Trigger | Queue Connection |
|---|-----------|---------|------------------|------------------|
| 1 | `BulkCodeGenerationJob` | Generate millions of codes (QR, ITF‑14, alphanumeric) outside request-response cycle | Factory Admin clicks "Generate" with count > 10,000 | Redis (`high` queue) |
| 2 | `NotificationBlastJob` | Multi-tenant notification delivery across all channels | Super Admin sends announcement | Redis (`default` queue) |
| 3 | `FreightAuctionMatchingJob` | Match incoming freight bids to available vehicles using proximity + capacity algorithm | Bit placed on marketplace | Redis (`auctions` queue) |
| 4 | `CommissionPayoutJob` | Calculate and distribute platform commissions on cargo drop-off confirmation | Trip status → `Delivered` | Redis (`finance` queue) |
| 5 | `OfflineSyncProcessingJob` | Process queued offline mutations from Store Keeper / Driver apps | Sync request from app | Redis (`sync` queue) |
| 6 | `InvoiceGenerationJob` | Generate PDF invoices asynchronously for bulk publish events | Batch publish of codes | Redis (`default` queue) |
| 7 | `RouteOptimizationJob` | Calculate optimal multi-drop routes via Google Maps Directions API | Multi-drop load created | Redis (`compute` queue) |
| 8 | `AnalyticsAggregationJob` | Pre-compute dashboard metrics and cache in Redis | Scheduled (every 60 seconds) | Redis (`analytics` queue) |

### 7.2 Required WebSocket Events

| # | Event Class | Channel | Payload | Subscribers |
|---|-------------|---------|---------|-------------|
| 1 | `FleetLocationUpdated` | `fleet.{company_id}` | `{truck_id, lat, lng, speed, heading, timestamp}` | Goods Company (9H), Factory, Reseller, Shop Keeper |
| 2 | `BusLocationUpdated` | `bus.{route_id}` | `{bus_id, lat, lng, speed, next_stop, eta_seconds}` | Customer App (8V), Bus Admin (13C) |
| 3 | `ChatMessageSent` | `chat.{chat_id}` | `{message_id, sender_id, content, type, timestamp}` | Chat participants |
| 4 | `AuctionBidPlaced` | `auction.{load_id}` | `{bid_id, truck_owner_id, amount, timestamp}` | Load poster, competing bidders |
| 5 | `TripStatusChanged` | `trip.{trip_id}` | `{trip_id, old_status, new_status, lat, lng, timestamp}` | Factory Admin, Goods Company |
| 6 | `DriverLocationUpdated` | `driver.{driver_id}` | `{driver_id, trip_id, lat, lng, speed, timestamp}` | Truck Owner (10J), Goods Company (9H) |
| 7 | `DeliveryConfirmed` | `delivery.{delivery_id}` | `{delivery_id, trip_id, pod_type, timestamp}` | Factory Admin, Reseller, Shop Keeper |
| 8 | `FraudAlertTriggered` | `admin.fraud` | `{alert_type, user_id, details, severity, timestamp}` | Super Admin (1M) |

### 7.3 Redis Cache Matrix Strategy

| Cache Key Pattern | Data | TTL | Invalidation Trigger |
|-------------------|------|-----|----------------------|
| `dashboard:super_admin:stats` | Global scan counts, active users, revenue | 60 s | Scheduled job refresh |
| `dashboard:factory:{id}:stats` | Per-factory code throughput, product counts | 300 s | Code publish event |
| `fleet:active_positions` | Sorted set of active truck/bus coordinates | Real-time (streamed) | WebSocket update |
| `analytics:charts:{type}:{period}` | Pre-computed chart data for dashboards | 3600 s | Scheduled or on-demand |
| `rate_limit:{user_id}:{endpoint}` | API rate limit counters | Window-based | Auto-expire |
| `session:{session_id}` | Short-lived session state | 900 s | Login/logout |

### 7.4 Elasticsearch Index Design

| Index | Document Type | Search Use Case | Refresh Interval |
|-------|--------------|-----------------|------------------|
| `products` | Product with price, category, factory, location | Wholesale marketplace search (12B) | 5 s |
| `codes` | Code with type, status, factory, linked entities | Global code search, audit | 30 s |
| `audit_logs` | Immutable audit entries | Full-text compliance search (12D) | 60 s |
| `transport_loads` | Active freight loads with origin, destination, cargo | Freight discovery (10R, 11D) | 5 s |
| `companies` | Company profiles with services, ratings | B2B storefront discovery (12A) | 60 s |

---

## 8. DEPLOYMENT & CI/CD

### 8.1 Hetzner Testing Server (16 GB RAM)

| Property | Value |
|----------|-------|
| **Provider** | Hetzner Dedicated Server |
| **Server Name** | ubuntu-16gb-hel1-2 |
| **RAM** | 16 GB (testing environment) |
| **IPv4** | 135.181.46.27/32 |
| **IPv6** | 2a01:4f9:c014:2997::/64 |
| **SSH User** | root |
| **SSH Command** | `ssh root@135.181.46.27` |
| **Web Server** | Nginx (reverse proxy for Laravel API + Flutter Web static files) |
| **Nginx Config** | `/etc/nginx/sites-available/traceodd` |
| **API Port** | 8090 (Laravel `php artisan serve`) |
| **API Root** | `/var/www/traceodd/admin-panel` (Laravel application) |
| **Web Root** | `/var/www/traceodd/frontend` (Flutter build output) |
| **Custom Code Root** | `/var/www/traceodd/admin-panel` (all Nano-edited custom files live here) |

### 8.2 Application URLs & Branding (Production — Tested)

| App | URL | Branding | Status |
|-----|-----|----------|--------|
| **Super Admin** | `http://135.181.46.27` | Trace Odd logo | ✅ Login tested |
| **Factory Admin** | `http://135.181.46.27/factory/login` | Third-party factory logo | ✅ Login tested |
| **Store Keeper** | `http://135.181.46.27/factory/store-keeper/login` | Related factory logo | ✅ Login tested |
| **Reseller (Ecommerce)** | `http://135.181.46.27/reseller/login` | Trace Odd logo | ✅ Login tested |
| **Factory Driver** | `http://135.181.46.27/driver/login` | Related factory logo | ✅ Login tested |

### 8.3 Auto-Deploy CI/CD Pipeline — Git Branch `mainnew`

**Trigger:** On every `git push` to branch `mainnew`, GitHub Actions auto-deploys to the Hetzner testing server.

#### 8.3.1 Backend Deployment — `.github/workflows/deploy.yml`

```yaml
name: Deploy Backend (Laravel) to Hetzner

on:
  push:
    branches:
      - mainnew
    paths:
      - 'backend/**'

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, pgsql, redis, bcmath, gd, zip

      - name: Install Composer Dependencies
        working-directory: backend
        run: composer install --no-dev --optimize-autoloader --no-interaction

      - name: Deploy to Hetzner via rsync
        uses: burnett01/rsync-deployments@7.0.1
        with:
          switches: -avzr --delete --exclude '.env' --exclude 'storage' --exclude 'vendor'
          path: backend/
          remote_path: /var/www/nexatrace/admin-panel/
          remote_host: 135.181.46.27
          remote_user: root
          remote_key: ${{ secrets.HETZNER_SSH_PRIVATE_KEY }}

      - name: Post-Deploy — Laravel Optimization
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: 135.181.46.27
          username: root
          key: ${{ secrets.HETZNER_SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/nexatrace/admin-panel
            php artisan down --retry=60
            php artisan migrate --force
            php artisan config:cache
            php artisan route:cache
            php artisan view:cache
            php artisan queue:restart
            php artisan up
            chown -R www-data:www-data .
            chmod -R 755 storage bootstrap/cache

      - name: Reload Nginx
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: 135.181.46.27
          username: root
          key: ${{ secrets.HETZNER_SSH_PRIVATE_KEY }}
          script: systemctl reload nginx
```

#### 8.3.2 Frontend Deployment — `.github/workflows/frontend-deploy.yml`

```yaml
name: Deploy Frontend (Flutter Web) to Hetzner

on:
  push:
    branches:
      - mainnew
    paths:
      - 'lib/**'
      - 'assets/**'
      - 'pubspec.yaml'
      - 'web/**'

jobs:
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.1'
          channel: 'stable'
          cache: true

      - name: Install Flutter Dependencies
        run: flutter pub get

      - name: Build Flutter Web (Release)
        run: flutter build web --release --no-tree-shake-icons

      - name: Delete Old Service Worker (Temporary Fix)
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: 135.181.46.27
          username: root
          key: ${{ secrets.HETZNER_SSH_PRIVATE_KEY }}
          script: rm -f /var/www/nexatrace/admin-web/flutter_service_worker.js

      - name: Deploy Web Build to Hetzner via rsync
        uses: burnett01/rsync-deployments@7.0.1
        with:
          switches: -avzr --delete
          path: build/web/
          remote_path: /var/www/nexatrace/admin-web/
          remote_host: 135.181.46.27
          remote_user: root
          remote_key: ${{ secrets.HETZNER_SSH_PRIVATE_KEY }}

      - name: Fix Permissions
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: 135.181.46.27
          username: root
          key: ${{ secrets.HETZNER_SSH_PRIVATE_KEY }}
          script: |
            chown -R www-data:www-data /var/www/nexatrace/admin-web
            chmod -R 755 /var/www/nexatrace/admin-web
            rm -f /var/www/nexatrace/admin-web/flutter_service_worker.js
            systemctl reload nginx
```

### 8.4 Nginx Configuration — `/etc/nginx/sites-available/nexatrace`

```nginx
server {
    listen 80;
    server_name 135.181.46.27;
    root /var/www/nexatrace/admin-web;
    index index.html;

    # Flutter Web static files
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, must-revalidate";
    }

    # Laravel API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:8090/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Laravel API health check
    location /health {
        proxy_pass http://127.0.0.1:8090/health;
        proxy_set_header Host $host;
    }

    # Static assets with long cache
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
    gzip_min_length 1000;
}
```

### 8.5 Manual Server Commands (Quick Reference)

```bash
# SSH into Hetzner server
ssh root@135.181.46.27

# Navigate to Laravel app
cd /var/www/nexatrace/admin-panel

# Edit Nginx config
nano /etc/nginx/sites-available/nexatrace

# Clear Laravel cache
php artisan optimize:clear

# Start Laravel API in background
php artisan serve --host=0.0.0.0 --port=8090 > /dev/null 2>&1 &

# Reset web permissions
chown -R www-data:www-data /var/www/nexatrace/admin-web
chmod -R 755 /var/www/nexatrace/admin-web

# Reload Nginx after config changes
systemctl reload nginx

# Delete Flutter service worker (temporary fix for web cache)
rm -f /var/www/nexatrace/admin-web/flutter_service_worker.js

# Local Windows build command
cd C:\Ecosystem\NexaTrace_System
flutter clean
flutter pub get
flutter build web --release --no-tree-shake-icons
```

### 8.6 Login Credentials (Testing — Hetzner Server)

| Role | URL | Email | Password |
|------|-----|-------|----------|
| **Super Admin** | `http://135.181.46.27` | `admin@nexatrace.local` | `admin12345` |
| **Factory Admin** | `http://135.181.46.27/factory/login` | `factory-admin@nexatrace.local` | `admin12345` |
| **Store Keeper** | `http://135.181.46.27/factory/store-keeper/login` | *(factory-assigned)* | *(factory-assigned)* |
| **Reseller** | `http://135.181.46.27/reseller/login` | *(registered)* | *(registered)* |
| **Factory Driver** | `http://135.181.46.27/driver/login` | *(factory-assigned)* | *(factory-assigned)* |

> **Note:** Press `Ctrl + F5` to hard-refresh the browser after each deployment to bypass cached service workers.

### 8.7 Queue Worker Process
```bash
php artisan queue:work redis --queue=high,default,auctions,finance,sync,compute,analytics \
    --tries=3 --backoff=60 --timeout=300 --sleep=3 \
    > /dev/null 2>&1 &
```

### 8.8 WebSocket Server (Laravel Reverb)
```bash
php artisan reverb:start --host=0.0.0.0 --port=8080
```

### 8.9 GitHub Secrets Required

The following secrets must be configured in the GitHub repository (`Settings → Secrets and variables → Actions`):

| Secret Name | Description |
|-------------|-------------|
| `HETZNER_SSH_PRIVATE_KEY` | Private SSH key for `root@135.181.46.27` (generate with `ssh-keygen -t ed25519`) |

**Setup on Hetzner server:**
```bash
# On Hetzner — add the public key to authorized_keys
mkdir -p ~/.ssh
echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

## 9. SECURITY FRAMEWORK

| Concern | Implementation |
|---------|---------------|
| **Authentication** | Laravel Sanctum (SPA + Mobile token); JWT with 8-hour rotation |
| **Authorization** | Role-Based Access Control (RBAC) at middleware + database level |
| **Transport Security** | TLS 1.3+ on all endpoints; HSTS header enforced |
| **Password Storage** | bcrypt with cost factor ≥12 |
| **PII Encryption** | AES-256-GCM at rest via Laravel `encrypt()` / `decrypt()` |
| **API Rate Limiting** | Laravel throttle middleware + Redis rate limiter per user per plan |
| **SQL Injection** | Eloquent ORM parameterized queries exclusively; no raw SQL in controllers |
| **XSS Prevention** | Blade `{{ }}` auto-escaping; Flutter widgets inherently XSS-safe |
| **CSRF Protection** | Laravel Sanctum CSRF cookie for SPA; token-based for mobile |
| **Audit Trails** | Immutable append-only log; 7-year retention; monthly signed exports |
| **Fraud Detection** | Rule-based engine (current) → ML anomaly detection (future) |
| **Secrets Management** | `.env` exclusively; never committed to VCS |

---

## APPENDIX A: KEY FILE PATHS

### Flutter
| Path | Purpose |
|------|---------|
| `lib/main.dart` | Super Admin + Universal App entry point |
| `lib/main_driver.dart` | Factory Driver App entry point |
| `lib/main_reseller.dart` | Reseller App entry point |
| `lib/core/config/` | App configuration, API endpoints, constants |
| `lib/core/services/api_client.dart` | HTTP client with token management, error handling |
| `lib/routes/app_router.dart` | GoRouter configuration (300+ routes) |
| `lib/rust_module/` | Rust FFI bridge (Dart side) |
| `lib/shared/bloc/` | Cross-cutting BLoC: auth, global state, scanner, subscription |
| `lib/features/nexa_admin/` | Super Admin panel (1) |
| `lib/features/factory/admin/` | Factory admin panel (3) |
| `lib/features/factory/driver/` | Factory driver app (4) |
| `lib/features/factory/store_keeper/` | Store keeper app (5) |
| `lib/features/reseller/` | Reseller app (6) |
| `lib/features/universal/shop/` | Shop keeper app (7) |
| `lib/features/universal/customer/` | Customer app (8) |
| `lib/features/transport/` | Transport ecosystem (9, 10, 11) |
| `lib/features/transport_marketplace/` | B2B marketplace (12) |

### Backend (Laravel)
| Path | Purpose |
|------|---------|
| `backend/app/Http/Controllers/Admin/` | Super Admin controllers |
| `backend/app/Http/Controllers/Factory/` | Factory controllers |
| `backend/app/Http/Controllers/Transport/` | Transport controllers |
| `backend/app/Models/` | Eloquent models |
| `backend/app/Services/` | Business logic services (Billing, Invoice, Payment, Revenue, etc.) |
| `backend/app/Jobs/` | Queue job classes (to be created) |
| `backend/app/Events/` | WebSocket event classes (to be created) |
| `backend/routes/api.php` | API route definitions |
| `backend/database/migrations/` | Database schema migrations |

### Rust
| Path | Purpose |
|------|---------|
| `rust/src/lib.rs` | FFI export surface (flutter_rust_bridge annotations) |
| `rust/src/generators/` | Bundle, Carton, Packet, Unit, Hierarchical code generation |
| `rust/src/algorithms/` | Authentication, checksum, encryption |
| `rust/src/international/` | GS1, QR, barcode standards |
| `rust/src/models/` | Data structures (HierarchicalCodes, ModuleInfo) |
| `rust/src/utils/` | Validation, helpers |

---

> **END OF SUPREME MASTER SPECIFICATION**
>
> This document is the singular authority for all architecture decisions, code generation, and feature planning within the Trace Odd ecosystem. All prior specification documents are hereby superseded. Questions of priority, scope, or technical approach shall be resolved exclusively by reference to this specification.
