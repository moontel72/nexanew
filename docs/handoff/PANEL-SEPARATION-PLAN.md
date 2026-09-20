# PANEL SEPARATION PLAN — traceodd.com

**Status:** planning document. No code changed yet.
**Read with:** `docs/handoff/FAULT-REMEDIATION-HISTORY.md` (separate scope: GStreamer faults).

**Process:** this plan was reviewed twice by independent agents. Both reviews' findings were
verified against the files and folded in here — accepted changes are marked **[Q]** with the
reason. **This file is the master document.**

**Companion:** `docs/handoff/PANEL-SEPARATION-RECOMMENDATIONS.md` holds the second review's
full text. Its verified findings are already integrated here (§5b, §5c, §7, §7b, §7c, §9b);
the file is kept for its detail on the target architecture and containment mechanisms, and as
evidence. **Read this plan first; consult that file for depth, not for decisions.**

**Working method per department:** separate → fix login/dashboard → own subdomain →
**LOCK** → then continue that department's feature work. See §8.

---

## 1. Goal

- **One domain now:** `traceodd.com` (one subdomain per group). Separate servers later.
- **1 Super Admin**, then **one Sub-Admin per department**.
- A department's admin panel must have **no link** to another department's admin panel.
- Every department links **up** to the Super Admin who created its admins.
- Departments talk to Sub-Admin / Super Admin **over an API**.
- **One global `lib/shared/`** (owner's decision — see §5), and **one consistent design**
  across every admin panel and app.
- Work lands in **phases**, so already-tested panels do not crash.

### The 7 groups

| Group | Contents | Current folders |
|---|---|---|
| **1 — Platform** | Super Admin + all Sub-Admin panels + **Universal Customer** app (scan any factory's product; buy/book/track bus tickets; track goods parcels; track own vehicle-security device) | `lib/features/nexa_admin/`, `lib/main.dart`; live customer screen currently lives in `bus_operations/` |
| **2 — B2B Commerce** | **One group, three separate sub-apps with their own names and login pages:** B2B Marketplace · Reseller panel · Shopkeeper panel. Factories, resellers/wholesalers and shopkeepers all buy **and** sell. A reseller may be linked to **many factories at once**; same for a shopkeeper. | `lib/features/reseller/` (misnamed) |
| **3 — Factory** | Factory Admin + Store Keeper + Driver — **factory employees**, factory logo | `lib/features/factory/{admin,store_keeper,driver}/`, `lib/main_driver.dart` |
| **4 — Bus Fleet** | Bus Fleet Admin + Bus Store Keeper + third-party Bus Owner app + Bus Driver + Bus Conductor | `lib/features/bus_operations/`, `lib/features/storekeeper/`, `lib/main_bus_*.dart` |
| **5 — Goods / Truck** | Goods Company Admin + Goods Store Keeper + third-party Truck Owner + Truck Driver + Truck Conductor | `lib/features/goods_operations/`, `lib/main_truck_*.dart` |
| **6 — Cricket** | Todd Studio + Cricket Manager + Todd Broadcaster (field cameras) + Public Viewer screen | `lib/features/cricket/`, `lib/main_cricket_*.dart`, `media-engine/` |
| **7 — Vehicle Security** | Nothing exists yet | — |

---

## 2. Decisions resolved by the owner

### D4 — The design language: Cricket's pencil + colour style, tokenised, everywhere

Owner's ruling: *"I like the Cricket Manager pencil style and its colour style. Instead of
hardcoding it, make it dynamic, put it in the shared folder, and apply this same pencil style
and colour style to every panel and app."*

**This settles the open question in Phase 3** — previously "converge the 4 theme roots" did not
say which style wins. **Cricket's wins**, and it becomes the project's design language.

#### Why this is mostly consolidation, not a redesign

The dark base is **already agreed in four places** — the same `#0A0E21` appears in
`CricketColors.background`, `LandingPalette`, and `TraceOddBrandTokens.dark`. The accent
`#00C49F` is already `AppColors.secondary`. So the work is **de-duplication of an agreed
palette**, not invention.

#### Canonical palette — take it from `CricketColors`

That file is the only one with its contrast ratios **documented and WCAG-verified**
(comment block at `cricket_colors.dart:1-8`: textPrimary 16.9:1 AAA, textSecondary 6.8:1 AA,
placeholder 5.1:1 AA, accent 5.0:1 AA). Use it as the source of truth:

| Role | Token | Value |
|---|---|---|
| Background | `background` | `#0A0E21` |
| Cards / app bars | `surface` | `#141829` |
| Hover / active | `surfaceElevated` | `#1E2238` |
| Input fill | `inputFill` | `#1A1E31` |
| Borders | `border` | `#2A2E41` |
| Text primary | `textPrimary` | `#F5F5F5` |
| Text secondary | `textSecondary` | `#A0AAB8` |
| Text tertiary | `textTertiary` | `#6B7280` |
| Accent / links | `textAccent` | `#00C49F` |

#### The pencil button needs its own accent-role tokens

The colours the owner likes on the Cricket pencil buttons are **hardcoded at the call site**, not
in `CricketColors` (`manager_dashboard_page.dart:363,537,579,586,605`). They must become **named
semantic roles**, not one flat colour — a design system needs a "danger" and a "success",
otherwise the next panel invents its own again:

| Role | Token | Current literal |
|---|---|---|
| Primary action | `accentPrimary` | `#10B981` |
| Informational | `accentInfo` | `#2563EB` |
| Warning / voice | `accentWarning` | `#F59E0B` |
| Feature / sponsor | `accentFeature` | `#8B5CF6` |
| Muted / inactive | `accentMuted` | `#1A3A4A` |
| Live / danger / wicket | `accentDanger` | `#F44336` *(already `CricketColors.live`)* |

**[Q] "Dynamic" is the important word.** The goal is not "one hardcoded colour everywhere" —
that would just move the hardcoding into `shared/`. It is **one token set** so that every panel
looks the same *and* colours mean the same thing everywhere.

#### ⚠️ This changes panels that already work

Five panels currently use a **light** theme or their own root (`shared/app_scaffold.dart:116`
seeds `#1F5E6B`; Super Admin and Factory mount `AppTheme`; Landing and both Cricket builds have
their own). Making everything dark will visibly change the look of Super Admin, Factory and the
seven fleet apps — panels the owner has already approved.

**That is accepted** (it is what was asked for), **but it is exactly why the Phase-0b screenshot
baseline is mandatory.** Without before/after screenshots a visual regression is undetectable.

#### Order of work

1. Create the canonical token file in `shared/theme/` (surfaces, text, accent roles, spacing,
   radius, icon sizes).
2. Repoint `CricketColors`, `LandingPalette`, `TraceOddBrandTokens` and `AppColors` at it
   (thin aliases first, so nothing breaks).
3. Promote `missile_3d_button` and have it read the accent roles **by default**, with an
   optional override so a control can still be semantic (e.g. a destructive action is red).
4. Migrate panels one department at a time — **same phase as that department's separation**, so
   a panel is only restyled when it is already being touched.
5. Retire the raw literals as files are touched (85 files with inline `Color(0x…)`).

### D1 — Bus and Goods: **separate apps, shared driver identity**

Owner's ruling:

- **Bus Driver app and Truck Driver app stay SEPARATE.** Their features differ:
  Bus has **seat management and ticketing**; Truck has **carton scanning, parcel tracking**.
- **The driver's account is ONE.** A driver who moves *bus → truck*, *truck → bus*, or
  *company → company*, keeps the **same account and history**. The owner has **already
  tested this**: a third-party bus owner moved 3–4 buses from one fleet company to another
  after ending a contract, preserving records.
- **Mechanism = a link system** (contract/association records), not a unified app.
- **A bus/truck driver who joins a Factory must create a SEPARATE account.** Factory drivers
  are a different domain (factory employees).
- If an app or account has a problem, a bus/truck driver contacts that fleet's
  **Trace Odd Sub-Admin**, not the company.

**Architectural consequence — this is an API concern, not a code-sharing concern:**
the bus↔truck identity continuity must live in the **backend identity service**. The two
Flutter apps stay independent; both authenticate against the same identity, and a
`link`/contract table carries company association as a **time-bounded** record so history
survives a move. Two separate frontends must never share a driver model by importing each
other's code.

**Therefore:** the spec's `lib/features/fleet/{owner,driver,conductor}/` (one unified app)
is **rejected**. Do not create it.

### D2 — B2B: one group, three sub-apps

Group 2 is **one group** but contains **three distinct sub-apps**, each with its **own name
and own login page**: B2B Marketplace, Reseller panel, Shopkeeper panel. Folder rename
`reseller` → `b2b` is recommended (§6), with sub-apps inside it.

### D3 — Department admin panels move OUT of `nexa_admin`

- Each department's admin panel stays **separate**; Factory admin and Bus-Fleet admin must
  have **no link** between them.
- Every admin panel links **up** to the Super Admin that created its admins.
- A Sub-Admin **cannot** interfere with another department's panel.

**Corrected finding — the Sub-Admin system is PARTIAL.** The owner believed it was complete;
the scan shows the **concept and data model exist, but isolation is not enforced**:

| Layer | State |
|---|---|
| Backend tables (`sub_admin_verticals`, `sub_admin_assignments`, `sub_admin_feature_grants`, `feature_registry`) | ✅ exist |
| 5 verticals: `bus_transit`, `goods_logistics`, `commercial_marketplace`, `financial_auditor`, `cricket_ops` | ✅ seeded |
| Super Admin creates sub-admins; login resolves the vertical | ✅ works |
| **Vertical ENFORCEMENT in middleware** | ❌ `SubAdminMiddleware.php:57-69` checks only that an assignment *exists*, never *which* vertical |
| `sub.admin` middleware applied | ❌ exactly **one** place: `routes/panels/cricket.php:246-250` |
| `sub_admin_feature_grants` enforcement | ❌ written and read, **never checked at request time** |
| Flutter route guards for sub-admin | ❌ `route_guard_middleware.dart:123-131` deliberately unimplemented; `/sub-admin/*` returns `null` for every path (`app_router.dart:252-258`) |
| Flutter UI scoping | ⚠️ **only `cricket_ops`** gets a restricted sidebar. The other 4 verticals fall through to the **same bus dashboard** (`sub_admin_dashboard.dart:167-176`) — a `goods_logistics` sub-admin sees the **bus** console |
| Sub-admin management endpoints | ❌ 4 Flutter↔backend mismatches: `toggle-status`, `change-vertical`, `reset-password`, `restore` |

**This is a security/isolation defect, not just a layout issue — it belongs in Phase 6.**

**[NEW] The concrete mechanism is now identified** — see §7c. The `main.dart` bundle warms up
Super Admin **and** Factory auth, and `core/utils/auth_state.dart` holds **mutable globals**
that the router redirect reads. So a Factory login sets state the Super Admin guard then reads.
That is why the two panels "open the same thing". The panels that never had this bug
(Cricket, B2B) create their **own** `BlocProvider`s inline and never touch the global
`AppProviders` — that is the reference model, and it is what separation must reproduce.

#### Owner's requirement: make the Sub-Admin roles DYNAMIC, not hardcoded

The 5 verticals in the table above are **hardcoded in Flutter**
(`add_sub_admin_screen.dart:15-48`). That is not what is wanted. The requirement is:

- The Super Admin creates a sub-admin account and then **ticks toggles** for that account.
- The toggle set is **data-driven** (support roughly 1–40 roles/features per account), not a
  fixed list of five.
- Whatever is toggled ON is exactly what that sub-admin can reach — **nothing more**.

**This is already half-built and just needs wiring and enforcing.** The database has the
right shape:

| Piece | State |
|---|---|
| `feature_registry` — the catalogue of features that *can* be granted | ✅ exists + seeded |
| `sub_admin_feature_grants` — per-account, per-feature grant rows | ✅ written + read |
| `sub_admin_assignments` — which account is an active sub-admin | ✅ exists |
| Flutter UI driven by `feature_registry` (toggles) | ❌ renders the 5 hardcoded verticals instead |
| Request-time enforcement of `sub_admin_feature_grants` | ❌ never checked |

**So the deliverable in Phase 6 is: drive the UI from `feature_registry`, store the toggles in
`sub_admin_feature_grants`, and enforce them on every request.** No new tables are needed —
the design is correct, the enforcement is missing.

---

## 3. What already works (templates to copy)

| Folder | Why |
|---|---|
| `lib/features/reseller/` | Self-contained: `routes/reseller_router.dart` + `app/reseller_app_initializer.dart` |
| `lib/features/factory/driver/` | Own `app/driver_app_initializer.dart` with its own `GoRouter` |
| `lib/main_cricket_public.dart`, `lib/main_cricket_manager.dart` | Each builds its own `GoRouter` |
| `lib/main_landing.dart` | Plain `MaterialApp`, zero coupling |

**Pattern to replicate:**
```
lib/main_<panel>.dart → <Panel>App → <Panel>AppInitializer → <Panel>Router
flutter build web --target=lib/main_<panel>.dart [--base-href /x/]
rsync → /var/www/traceodd/<panel>/     nginx → <panel>.traceodd.com
```

---

## 4. Blockers

| # | Blocker | Evidence |
|---|---|---|
| **B1** | **Mega-router.** `lib/routes/app_router.dart` (1141 lines) registers every department's routes; imported by SUPER ×4 + FACTORY ×1 which call `goTo*()` on it. | §7 table |
| **B2** | **Mega-initializer.** `lib/core/widgets/app_initializer.dart` (280 lines) composes SUPER + FACTORY + **BUS**. | `:14`, `:23-24`, `:56-62`, `:163-166`, `:188-202`, `:218-224` |
| **B3** | `lib/core/providers/app_providers.dart` wires SUPER + FACTORY + B2B (40+ imports). | |
| **B4** | **`lib/shared/` imports features backwards** (layering violation). Only 4 such edges exist, but they block every department move. | `shared/widgets/navigation/admin_sidebar.dart:4` (BUS), `shared/bloc/telemetry_tracking/telemetry_models.dart:6` (BUS), `shared/utils/fleet_bloc_setup.dart:10-11` (auth), `shared/widgets/fleet_bloc_login_screen.dart:20-23` (auth) |
| **B5** | **`missile_3d_button` is the de-facto design identity but lives in BUS.** Importers (verified by grep): BUS `fleet_dashboard_page.dart:12` + `owner_dashboard_page.dart:14`, **CRICKET `manager_dashboard_page.dart:33`** (comment: "Manager Dashboard — 3D Pencil Sidebar layout"), SUPER `bus_fleet_dashboard_screen.dart:26` + `sub_admin_dashboard.dart:16`, and **`shared/`'s `admin_sidebar.dart:4`**. BUS cannot move until it is promoted. | `bus_operations/presentation/widgets/missile_3d_button.dart` |
| **B5b** | **The button is shared; its COLOURS are not.** Every panel passes raw hex at the call site, so the same component renders differently per panel — e.g. CRICKET `manager_dashboard_page.dart:363,537,579,586,605` passes `0xFF10B981 / 0xFF1A3A4A / 0xFF2563EB / 0xFFF59E0B / 0xFF8B5CF6` instead of `AppColors`. **Promoting the widget alone will not unify the look — the colours must be tokenised too.** | `manager_dashboard_page.dart:359-606`; contrast with the panel-specific `CricketColors` palette |
| **B6** | **Circular dependency SUPER ↔ BUS.** BUS `fleet_dashboard_page` imports 4 SUPER screens; SUPER `bus_fleet_dashboard_screen` imports 2 BUS widgets. | |
| **B7** | **`nexa_admin/` is not SUPER-only** — holds CRICKET, BUS, GOODS and B2B admin panels. | §6 tables |
| **B8** | **GOODS has no driver/conductor UI** — `main_truck_driver.dart:6` / `main_truck_conductor.dart:6` open **BUS** pages verbatim. | |
| **B9** | **5 parallel auth stacks** (`features/auth/` + one per department). | |
| **B10** | **`lib/features/bus_operations/` hosts the LIVE Customer Super-App** (`customer_super_app_screen.dart`, routed at `app_router.dart:632-637`) — a Customer (Group 1) screen living in the BUS folder. | |
| **B11** | **Design system is not actually shared.** Only `colors.dart` (7 depts) and `primary_button.dart` (4 depts) cross departments. **4 competing theme roots**: `AppTheme`, `shared/app_scaffold.dart`'s inline `ThemeData`, `LandingPalette`, `CricketColors` (+ `core/theme/branding_config.dart` as a second brand layer). **No spacing/radius/icon token system exists.** 85 files carry inline `Color(0x…)`, 182 inline `TextStyle(`, 191 inline `BorderRadius.circular(`. `shared/theme/app_decorations.dart` (the container/shape token set) is **unused**. | |

---

## 5. Shared folder and server strategy

### One `lib/shared/` — confirmed

The owner first proposed a per-group `shared/` copy, then corrected it. **One global
`lib/shared/` is right, and copy-paste would actively break the owner's other requirement
(a single consistent design across every panel):**

- Copy-paste means one bug fix becomes N fixes.
- Copy-paste guarantees **design drift** — exactly what the owner wants to avoid.

Ownership rule that makes one folder safe:

- `lib/shared/` holds **design + generic code only** and must **never** import `lib/features/`.
- Department code lives in `lib/features/<dept>/` and **must not** import another
  department's feature.
- A widget used by 2+ departments does **not** belong to either — promote it to `shared/`.

### Server strategy: staged, not either/or

**Key point: the `shared/` folder has no bearing on server separation.** Flutter `shared/`
is *compile-time*; servers are *runtime*. Each department's build compiles only what it
imports. So all of these are compatible at once:

| | Possible? |
|---|---|
| **One** `lib/shared/` | ✅ |
| **7** separate `main_*.dart` + routers | ✅ |
| **7** subdomains on `traceodd.com` | ✅ |
| **1** server now → N servers later | ✅ |

**Recommendation: one server now, architected so it can split later.**

The three layers scale differently, and this is what decides the schedule:

| Layer | How it scales | Difficulty |
|---|---|---|
| **Frontend** (Flutter bundles) | Static files — CDN or several nginx | Easy |
| **API** (Laravel + Postgres + Redis) | Stateless app servers + shared DB + Redis, behind a load balancer | Moderate |
| **Media engine** (Rust SFU / WebRTC) | **Stateful** — each room lives on one server | **Hard** |

"Automatic load shifting" therefore means:
- Frontend — trivial.
- API — feasible once app servers are stateless (sessions/state in Redis, which already
  exists and now has persistence).
- **Media — not a config change.** A live call cannot migrate between servers. It needs
  room→server placement/affinity logic. That is a project, not a toggle.

**Therefore:** keep the media engine on its **own** server early (it is stateful and must be
separate anyway — `broadcaster.traceodd.com` already exists), and design the **API boundary
now** so the rest can split later without a rewrite.

> The single thing that makes server separation possible later is **API-only coupling**.
> If one department's frontend reaches into another's models/database directly, no amount
> of server planning will help. That is why Phase 6 is mandatory before Phase 9.

---

# 5b. The isolation model **[from the second review — the "how" of separation]**

This is the part the first draft of this plan was missing: *how* a panel is actually kept
separate, rather than just which files move where.

## 5b.1 The governing rule

**Each panel is a vertical slice that owns everything it needs and depends on nothing from
another panel.** One direction only:

```
core  ←  shared  ←  features/<panel>
                  ↗
            main_<panel>.dart
```

- `core/` depends on nothing else in `lib/`.
- `shared/` depends only on `core/` — **never** on `features/`.
- `features/<panel>/` depends on `core/` + `shared/` — **never** on another `features/<other>/`.
- `main_<panel>.dart` depends on exactly **one** panel, plus `shared/` and `core/`.

**This model is already proven in this codebase.** `cricket/`, `reseller/` and `landing/`
follow it and have never had a mixing bug. The goal is simply to make everything else look
like them.

## 5b.2 The concrete extractions, in order

| # | Action | Why |
|---|---|---|
| 1 | **Extract `missile_3d_button`** out of `bus_operations` into `shared/widgets/` | imported by 5 files across 4 "panels" — a widget everyone uses cannot live inside one panel (B5) |
| 2 | **Move `bus_tracking_models.dart`** to `shared/`, or move the telemetry bloc to BUS | `shared/bloc/telemetry_tracking/` imports it from BUS today (B4) |
| 3 | **Extract the 4 fleet screens** (`route_scheduler`, `ticket_management`, `voucher_management`, `bonus_management`) out of SUPER into a neutral `shared/fleet/` | breaks the SUPER↔BUS cycle (B6) — both panels may import a neutral module without a cycle |
| 4 | **Give GOODS its own** `driver_dashboard_page` / `conductor_dashboard_page` | today it imports BUS's verbatim (B8); if the layout is truly identical, extract the shared structure to `shared/` — do **not** have GOODS depend on BUS |
| 5 | **Split `app_providers.dart`** (284 lines, 59 imports) into `features/<panel>/providers.dart` | it is the single biggest state leak (B3) |
| 6 | **Replace the global auth globals** in `core/utils/auth_state.dart` with per-panel scoped auth | this is the Factory/Sub-Admin bug itself (§7c) |
| 7 | **Split the router** per §7 — **only after 1–6** | splitting first just re-mixes the same coupled imports across more files |
| 8 | **Make `main.dart` a thin launcher** — Super Admin only | it currently boots Factory auth, BUS `TicketVaultService` and the all-panel router (B2) |

**Each panel's `main_*.dart` should end up under ~50 lines:** init Flutter, wrap in that panel's
`providers.dart`, set that panel's router, run. `main_cricket_manager.dart` and
`main_reseller.dart` already have this shape.

## 5b.3 Target folder layout

```
lib/
├── core/          constants, network, storage, utils, errors   (no panel logic)
├── shared/
│   ├── widgets/              ← missile_3d_button lives HERE
│   │   └── design_system/    ← tokens, typography, spacing, palettes (D4)
│   ├── fleet/                ← neutral screens extracted from SUPER
│   ├── bloc/  models/
└── features/
    ├── nexa_admin/           presentation/ bloc/ data/ routes/ providers.dart theme.dart
    ├── factory/              admin/ store_keeper/ driver/ routes/ providers.dart
    ├── bus_operations/       presentation/ bloc/ data/ routes/ providers.dart
    ├── goods_operations/     … own driver + conductor pages, no BUS import
    ├── cricket/              manager/ public/ routes/ providers.dart   (reference model)
    ├── reseller/             routes/ providers.dart                    (reference model)
    ├── customer/ storekeeper/ auth/ landing/
```

Every panel folder gains a **`providers.dart`** (its own registrations) and a **`routes/`**
(its own router). `theme.dart` per panel extends the shared design system rather than
redefining it.

## 5b.4 Storage isolation

Web panels share a browser origin today, so `SharedPreferences` keys are panel-scoped **by
convention only** (`busFleet_fleet_role`, `cricket_manager_token`). Nothing stops `main.dart`
reading a BUS key. Target: a `StorageKeys` class per panel with a **mandatory compile-time
prefix**, enforced by lint — and, once each panel is on its own subdomain, a separate
`localStorage` origin as a second layer.

---

# 5c. Containment — how one panel cannot break another **[the owner's specific question]**

Today there is **no** such guarantee: all 8 panels rebuild together, share auth state, and
import each other. Eight mechanisms, in priority order.

| # | Mechanism | What it fixes |
|---|---|---|
| 1 | **CI boundary enforcement** — `analysis_options.yaml` rules + a dependency-cruiser script that **fails the build** on `shared → features` or `features/A → features/B` | stops new coupling merging. Documented rules get broken; enforced ones do not. Existing 4 edges are grandfathered as tracked debt |
| 2 | **Path-filtered per-panel CI** — each panel its own workflow with a `paths:` filter on its feature folder and `main_*.dart` | today `frontend-deploy.yml` triggers on `lib/**`, so **any** change redeploys **all 8**. A cricket-only change can block every panel |
| 3 | **Per-panel test gates** — widget + bloc + integration + contract tests, run in that panel's workflow | there are **zero** Flutter tests today (a 17-line placeholder) |
| 4 | **No shared mutable globals** — delete `auth_state.dart` globals; per-panel scoped state | the exact mechanism of the Factory/Sub-Admin bug (§7c) |
| 5 | **Staging + versioned artifacts + rollback** — build `v1.2.3-abc1234/`, deploy to staging, promote by symlink switch, roll back by switching the symlink back | today: `rsync --delete` straight to production, **no staging, no rollback, no history** |
| 6 | **Secret scanning** — `gitleaks`/`trufflehog` in CI | would have caught `database_config.dart:54` before it was committed |
| 7 | **CODEOWNERS per panel** — a PR touching `features/<panel>/` needs that panel's reviewer; `shared/` needs all dependents | prevents one developer's panel work silently breaking another |
| 8 | **Weekly dependency-graph audit** — scheduled job that graphs panel→panel edges and fails on new crossings | catches re-coupling that slips through a barrel file or re-export |

**Mechanisms 1, 2 and 4 are the ones that directly answer "one panel must not break
another".** 5 and 6 answer "if it does break, recover". The plan's Phase 0a and Phase 1 carry
1, 4, 5 and 6; the per-panel workflow (2) lands with Phase 5 as each department gets its own
deploy step.

---

## 6. Keep / delete advisory

Evidence from a whole-tree importer scan (772 files) plus route, entry-point and CI checks.
Deletion is irreversible — each row states what was verified.

### Dead — safe to remove

| Path | Verified | Action |
|---|---|---|
| `lib/core/config/database_config.dart` | 0 importers. **Contains the PostgreSQL host, port, user and password in client-side code** — including a `postgres` superuser string. See Phase 0 for the full explanation. | **DELETE + verify/rotate on the server** |
| `lib/features/transport/**` (8 files) | 0 importers anywhere; no route; no `main_*.dart`; no CI target | DELETE |
| `lib/features/transport_marketplace/**` | Only importer is the dead `transport/` bloc. The **live** `/transport/marketplace` route points at `nexa_admin/…/TransportMarketplaceAdminScreen`, not this folder | DELETE |
| `lib/features/broadcaster/data/services/whip_client.dart` | 0 importers, no route. WHIP ingest is done by the Rust engine, not this class | DELETE |
| `lib/features/universal/customer/**` (8 files) | 0 external importers, no route. **Duplicate of the LIVE customer app** | **MERGE → then delete** (see below) |
| `core/navigation/router_integration.dart`, `core/di/panel_bloc_providers.dart`, `core/providers/panel_provider_binder.dart`, `core/bootstrap/app_bootstrapper.dart` | 0 importers | DELETE |
| `core/services/{payment_service,subscription_validator,supabase_chat_service,multi_tenant_service,code_generator_service}.dart`, `core/constants/{fleet_constants,plan_limits}.dart` | class defined, never constructed. **[Q] Caveat:** confirm no backend migration references `payment_service` / `subscription_validator` as a *planned* dependency before deleting — if billing is "coming soon", keep the interface and drop only the stub | DELETE (after that check) |
| 7 `nexa_admin` billing screens + `dunning_alert_widget` + 3 billing usecases | unrouted, 4 are literal placeholder stubs | DELETE |
| 6 `bus_operations` pages (`route_list/editor/detail`, `ticket_vault`, `driver_trip`, `live_bus_tracking`) + `qr_code_painter`, `driver_gps_beacon` | never routed or referenced | DELETE |
| ~24 UNUSED widgets under `lib/shared/` (incl. `main_app_bar.dart`, `search_app_bar.dart`, `icon_button.dart`, 4 card types, dialogs) | 0 importers | DELETE — **[Q] except `app_decorations.dart`**, which Phase 3 may adopt as the container/shape token set instead |

**My earlier draft of this plan was wrong about the customer app. Corrected:** the *live*
Customer Super-App is `lib/features/bus_operations/presentation/pages/customer_super_app_screen.dart`
(routed at `app_router.dart:632-637`). `lib/features/universal/customer/` is the **unreachable**
copy. It is larger and carries a Bluetooth/hardware-scan + websocket bloc, so **port its
unique features into the live screen first**, then delete the folder.

### Live — keep

| Path | Owner |
|---|---|
| `lib/features/goods_operations/` | GOODS — deployed (`main_truck_owner.dart`) |
| `lib/features/reseller/` | B2B — deployed (`main_reseller.dart`) |
| `lib/features/storekeeper/` | BUS depot (catering/inventory/HR) — wired to bus-fleet panel |
| `lib/features/factory/store_keeper/` | FACTORY warehouse (serial/carton linking) — different domain, **no merge**; the shared name is a coincidence |
| `lib/features/auth/` (panel auth) | **Partial**: the login path is live and used by all fleet mains; the *guard* layer is dead code and should be trimmed |
| `shared/models/wallet/wallet_model.dart` | B2B + GOODS — live (unlike `transport/`'s wallet blocs) |

⚠️ **Name collision to fix:** `lib/features/storekeeper/` (BUS) vs `lib/features/factory/store_keeper/`
(FACTORY). Rename the BUS one → `bus_operations/storekeeper/`.

⚠️ **Other name collisions:** `SearchAppBar` is declared **twice** (`shared/widgets/app_bars/main_app_bar.dart`
and `search_app_bar.dart`, both unused); `PanelAuthState` exists in both `core/navigation/panel_routes.dart`
and `features/auth` — rename one.

### Move out of `nexa_admin/` (B7)

| Item | Destination |
|---|---|
| `super_admin/bus_fleet_dashboard_screen.dart`, `super_admin/bus_fleet/**`, `bus_company_login_screen`, `bus_companies_list`, `add_bus_company` | **BUS** |
| `super_admin/goods_fleet_dashboard_screen.dart`, `super_admin/goods_fleet/**`, `goods_company_login_screen`, `goods_companies_list`, `add_goods_company` | **GOODS** |
| `super_admin/transport/**` (wallet, marketplace admin, drivers, fraud), `super_admin/reseller_management/**`, `bloc/{transport_admin,reseller_management}` | **B2B** |
| `sub_admin/cricket/**` (manager CRUD) | **CRICKET** |
| `sub_admin/{sub_admin_list_screen,add_sub_admin_screen}` | **stay** (platform) |
| `super_admin/{dashboard,login,shell}`, `site_content/`, `plans/**`, `billing/**`, `companies/**` (registry), `data/**`, `domain/**`, `presentation/bloc/{auth,billing,invoices,plans,companies,dashboard}` | **stay** (platform) |

---

## 7. Phase 2 reference — the router split **[CORRECTED]**

`lib/routes/app_router.dart` (1142 lines) splits by these ranges.

> **A review found real errors in the first version of this table, and they are confirmed.**
> The table below separates the three kinds of content, because they do not move the same way.
> **Do not treat it as one list of line ranges** — that was the mistake.

**Three content kinds:**

1. **`GoRoute` definitions** — the actual routes. Move to the department that owns them.
2. **Redirect logic inside `_safeRedirect` (lines 184–317)** — per-department rules. Move beside
   that department's routes and get composed back into the redirect chain.
3. **Public bypasses (`return null`)** — *stay in the base router.* They are guard decisions,
   not routes.

### 7.1 `GoRoute` definitions — corrected map

| New file | GoRoute definitions | Department |
|---|---|---|
| `lib/routes/app_router.dart` *(kept)* | 320–321 (the `_routes` list), 1078, 1140 | shell |
| `super_routes.dart` | 321–326, 342–351, 653–792 | SUPER |
| `factory_routes.dart` | 327–331, 793–1075 | FACTORY |
| `cricket_routes.dart` | 352–369, 370–486 | CRICKET |
| `bus_routes.dart` | 332–336, 487–527, 600–631 | BUS |
| `goods_routes.dart` | 337–341, 528–568, 569–599 | GOODS |
| `customer_routes.dart` | 632–652 | CUSTOMER |
| `b2b_routes.dart` | **759–772 (`/resellers`, `/resellers/add`)** | B2B — see 7.3 |

### 7.2 Redirect logic — move with its department, not into the route files

| Lines | Rule | Belongs to |
|---|---|---|
| 203–234 | factory-route redirect rules | FACTORY |
| 236–242 | root-path redirect (see the leak in §3 below) | global |
| 287–317 | protected-route redirects (incl. dashboards) | SUPER + BUS/GOODS dashboards |

### 7.3 Three errors in the first version, confirmed

| Error | What was wrong | Correction |
|---|---|---|
| **Duplicate range** | `263–281` was assigned to **both** `bus_routes.dart` and `goods_routes.dart`. The same range cannot belong to two files. | `263–281` is a mixed block: it holds the bus-owner/driver/conductor **and** truck-owner/driver/conductor bypasses. It is *redirect bypass logic*, not routes — it **stays in the base router**. |
| **B2B had no real routes** | `b2b_routes.dart` was given only `247–249` (a `return null` bypass) and `153–163` (error-builder text). Neither is a route. | The real B2B-domain routes are **759–772** (`/resellers`, `/resellers/add`), which sit **inside the SUPER shell range (653–792)**. Decide explicitly: move them to `b2b_routes.dart`, or keep them with SUPER as platform-admin CRUD. Do not leave this implicit. |
| **Redirect logic mislabelled** | Ranges like `203–234` and `244–246` were listed as if they were route definitions. | They are redirect logic and a bypass. Moved to 7.2 / the base router as above. |
| **Public bypasses** | `247–249`, `250–253`, `255–258`, `282–285` were scattered into department files. | All bypasses **stay in the base router**, because they are guard decisions that run *before* routing. |

---

## 7b. P0 backend authorisation gaps **[NEW — from the second review, verified]**

These were not in the first draft of this plan. All three were verified directly against the
files.

### 7b.1 `consumer.php` is never loaded — the whole Customer API is dead code

`backend/app/Providers/PanelRouteServiceProvider.php:43-54` defines the `$panels` array:

```
super_admin, factory, marketplace, truck_fleet, bus_fleet,
bus_owner, goods_fleet, passenger, cricket, studio
```

**`consumer` is absent.** So `backend/routes/panels/consumer.php` (5 endpoints) is never
registered — the Customer Super-App's backend is unreachable. Group 1's customer app cannot
work until this is fixed.

### 7b.2 Panel middleware is weak almost everywhere

| Route file | Middleware | Verdict |
|---|---|---|
| `bus_fleet.php` | `auth:sanctum` + `bus.fleet` (`BusFleetGate`) | ✅ **the model to copy** |
| `cricket.php` group 2 | `cricket.manager` (`CricketManagerAuth`) | ✅ good |
| `cricket.php` group 3 | `auth:sanctum` + `sub.admin` | ⚠️ partial — `exists()` only |
| `super_admin.php` | `auth:sanctum` **only** | ❌ **no admin middleware at all** |
| `goods_fleet.php` | `auth:admin` | ❌ any admin, of *any* vertical |
| `truck_fleet.php` | `auth:sanctum` **only** | ❌ *any* authenticated user |
| `bus_owner.php`, `factory.php`, `passenger.php` | `auth:sanctum` only | ⚠️ weak |
| `consumer.php` | `auth:sanctum` | ❌ never loaded (7b.1) |

**`super_admin.php` having no admin guard is the most serious:** a plain authenticated account
can reach platform-admin endpoints.

### 7b.3 Redirect logic leaves routes reachable

| Lines | Behaviour | Risk |
|---|---|---|
| 255–258 | every `/sub-admin/*` path returns `null` — **no guard** | any user can reach sub-admin routes |
| 250–253 | every `/bus-fleet/*` path returns `null` — **no guard** | any user can reach bus-fleet routes |
| 240 | root on non-web redirects to `/factory/store-keeper/login` | leaks Factory into any mobile context |

This is the same class of defect as §8's "known bug" and is the concrete reason the
**LOCK** step exists.

---

## 7c. The state-isolation mechanism behind the Factory/Sub-Admin bug **[NEW, verified]**

This is now the best explanation we have, and it is a **code** cause, not a guess:

- `lib/core/providers/app_providers.dart` (284 lines, **59 imports**) is global.
  `main.dart` → `AppInitializer` calls `getRepositoryProviders` (SUPER + FACTORY + B2B),
  `getDriverBlocProviders` (FACTORY driver), `getNexaAdminBlocProviders` (SUPER) and
  `getFactoryAdminBlocProviders` (all of FACTORY). So the `main.dart` bundle carries **Super
  Admin + Factory Admin + Factory Driver + Store Keeper + B2B state at startup**, regardless of
  which panel the visitor asked for.
- `lib/core/utils/auth_state.dart` exposes **mutable globals** (`isAuthenticatedCache`,
  `isFactoryAuthenticatedCache`, `isAuthCheckCompleted`) which the router redirect reads.
  **A Factory login sets state that the Super Admin guard then reads** — so a factory user can
  land in an admin-authenticated state, and vice versa. That is the mixing the owner saw.
- Storage keys are panel-scoped **by convention only** (`busFleet_fleet_role`,
  `cricket_manager_token`, `factory_auth_token`); nothing prevents a cross-read.

**Contrast with the panels that work:** `main_cricket_manager.dart`, `main_cricket_public.dart`
and `reseller_app_initializer.dart` create their **own** `BlocProvider`s inline and never touch
`AppProviders`. That is the reference model, and it is why Cricket and B2B never had this bug.

---

## 8. Phases

### Working method: separate → verify → LOCK, one department at a time

**[Q] Rollback rule — a bad push goes live immediately.** CI deploys on push to
`main`/`mainnew`, so there is no staging step. Therefore:

- **Every phase on its own feature branch.** Merge to `mainnew` only after the deploy has been
  verified against the Phase-0 baseline.
- **No phase may be merged while a previous phase's verification is outstanding.**
- If a phase fails verification, revert the merge (or the deploy) — do not "fix forward" on the
  live branch.

The owner's method, applied to every department (not only the pilot):

1. **Separate** that department's entry point + router out of the shared bundle.
2. **Fix** its login page and dashboard.
3. Give it **its own subdomain**, register it in Cloudflare.
4. **LOCK it** — so a later agent cannot mix it back in.
5. Only then continue that department's remaining feature coding.

**What "lock" concretely means** (otherwise it is just an intention):

- Its own `main_*.dart` and its own router file — it cannot be reached through another
  build's route table.
- An nginx vhost with an exact `server_name` and **no catch-all `try_files … /index.html`**
  that could swallow another panel's paths.
- A **CI check** asserting the isolation, e.g. the department's route prefix appears in
  exactly one entry point, and its build target is the only one importing its feature folder.
- **[Q] `dart analyze` clean** — a phase does not exit while analysis reports problems.

Without "lock" the same class of bug returns: the owner has already lost tested work twice
because two panels ended up sharing one bundle and one auth state.

### Known bug to verify while working the Factory department

The owner reports that **Factory Admin and the Sub-Admin panel open the same thing**, even
though they were tested separately and both logins existed. The likely cause is now visible
in the code:

- Both live in the **same `main.dart` bundle** with **one router** and **one auth warm-up**
  that loads *both* tokens (`app_initializer.dart:163-166`, `:188-202`).
- `app_router.dart:252-258` returns `null` for every `/sub-admin/*` path, so sub-admin routes
  are **unguarded**, while `/factory/*` has its own redirect chain (`:203-234`).
- `app_router.dart:240-241` makes the root path fall back to `/login`
  (or `/factory/store-keeper/login` off-web), so an unauthenticated visitor can be routed into
  an unrelated panel's login.

**Reproduce it before fixing it,** and fix it by separation (Phase 5), not by adding another
redirect. This is the concrete case that justifies the whole plan.

### Phase S — Verify the streaming fix (do this FIRST) **[Q]**

The forwarder declare/feed fix is committed (`f0fc72e5`) and its unit tests pass (34/34,
including the three new ones). What is **not** verified is the live path: the pipeline has
never been run against SRS with the fix in place.

1. Run the A/B experiment from `FAULT-REMEDIATION-HISTORY.md` §9.9 on the live server.
2. Confirm `https://cricket.traceodd.com/hls/live/{key}.m3u8` returns **200** with a valid
   playlist.
3. Only then start Phase 0a.

**Why first:** a working public stream is the owner's original complaint. Refactoring the whole
repository before confirming the fix leaves the real problem unproven.

### Phase 0a — EMERGENCY: credentials **[Q — split out, security is hours not days]**

#### The `database_config.dart` issue, explained plainly

`lib/core/config/database_config.dart` is a **Flutter (client-side) file** that contains the
**PostgreSQL server's address, port, database name, username and password**:

```
host 135.181.46.27 · port 5444 · db nexasystem_db
user nexa_app · password NexaAppPassword123!
line 54: postgresql://postgres:awan1972@135.181.46.27:5444/nexasystem_db
```

The concern is not that the app *uses* it — the file has **zero importers**, it is dead code.
The concern is that these are **real credential strings sitting in the repository**:

- A Flutter web build compiles Dart into JavaScript that runs **in the visitor's browser**.
  Any file reachable from an entry point would have its contents exposed to anyone who opens
  DevTools. This file is currently unreachable, so it is not leaking today — but it is one
  accidental import away from leaking, and nothing prevents that.
- The repository has a remote (`github.com/moontel72/nexanew`), so **anyone with repo access
  has already seen these strings**. "I never shared it with anyone" and "it is in the repo"
  are not compatible statements — committing *is* sharing.
- Line 54 is a **`postgres` SUPERUSER** credential — the most privileged account on the
  database — and it also reveals a **non-standard port (5444)**, which is exactly the kind of
  thing an attacker uses to find an exposed database.

**Do, in this order:**

1. **Check `pg_hba.conf` on the Hetzner server now.** If it allows connections from
   `0.0.0.0/0` on port **5444**, the database is **exposed to the internet right now** — that
   is the actual emergency, not the file.
2. **Restrict** it (firewall + `pg_hba.conf` to localhost or the app host only).
3. **Rotate** both passwords (`postgres` and `nexa_app`).
4. **Delete the file** (dead code; nothing breaks).
5. Add a secret-scanning check to CI so a credential string cannot be committed again.

If PostgreSQL is genuinely no longer used at all (everything moved to the app), then the
passwords no longer matter — **but step 1 is how you confirm that**, rather than assuming it.

#### Also in 0a — the backend authorisation gaps **[NEW — verified]**

See §7b. These are as urgent as the DB password:

- **`super_admin.php` has no admin middleware** (`auth:sanctum` only) — a plain authenticated
  account can reach platform-admin endpoints.
- **`consumer.php` is never loaded** (absent from `PanelRouteServiceProvider::$panels`,
  lines 43-54) — the Customer Super-App API is dead code, so Group 1's customer app cannot work.
- **`goods_fleet.php` uses `auth:admin`** — any admin of *any* vertical; **`truck_fleet.php`
  uses only `auth:sanctum`** — any authenticated user.

`bus_fleet.php` (`auth:sanctum` + `bus.fleet` / `BusFleetGate`) is the pattern to copy.

#### Also in 0a — CI cannot detect any of this **[NEW]**

| Gap | Current state |
|---|---|
| Backend tests | `tests.yml:6` triggers on branch **`master`**; the repo deploys from `main`/`mainnew`, so push-triggered tests never run (only the nightly cron and `pull_request` fire) |
| Flutter tests | **None in CI** — `test/widget_test.dart` is a 17-line placeholder |
| `dart analyze` | **Not in CI** |
| Secret scanning | **None** — which is how the DB credentials in this section survived |
| Build blast radius | `frontend-deploy.yml` triggers on `lib/**` — **any change rebuilds and redeploys all 8 panels** |
| Staging / rollback | None. `rsync --delete`, no versioned artifacts; push to `mainnew` **is** production |
| Server IP | Hardcoded `root@135.181.46.27` in `frontend-deploy.yml`, while `deploy.yml` uses `${{ vars.VPS_HOST }}` |

**Fix `tests.yml` to the deploy branches, and add `dart analyze` + secret scanning to CI in
this phase.** The path-filtered build (blast-radius control) belongs with Phase 5, when each
department gets its own deploy step.

### Phase 0b — Baseline **[Q — split from the emergency]**

Record the current working state **per panel** (URL, login works?, screens verified) as
`docs/handoff/PANEL-BASELINE-STATE.md`, plus the current `nginx -T` and server listings, and
verify each existing panel's build before touching anything.

**[Q] Screenshot every panel as part of this baseline.** Phase 3 merges 4 theme roots, which can
subtly change colours and shadows in panels the owner has already approved. Without before/after
screenshots that regression is invisible.

**[Q] Also record which entry points are CI-deployed vs. file-only.** Today CI builds 8 of
the 13 `main_*.dart` files (see §6). This is **expected, not a defect**: the owner has
confirmed the five undeployed apps (`main_bus_driver`, `main_bus_conductor`,
`main_truck_owner`, `main_truck_driver`, `main_truck_conductor`) currently contain **only a
login page** — their remaining feature coding has not been done yet. They are listed here so
that Phase 5 adds each one to `frontend-deploy.yml` as that department is separated, rather
than being mistaken for a missing deployment.

**Exit:** a written baseline to diff every later phase against.

### Phase 1 — Fix the layering (behaviour-preserving) **[Q — moved ahead of the router split]**

**[Q] Why this is now first:** if the layering is still dirty when the router is split, the
backward dependencies get carried into the new route files and have to be unpicked twice.
Clean foundation first, then the clean split. **Do these in the order in §5b.2.**

1. **Promote `missile_3d_button`** out of BUS into `lib/shared/widgets/` — unblocks 4 panels;
   only 5 import paths need updating. This is B5 *and* the highest-value step toward D4
   ("same design everywhere"). Grep-verified importers: BUS `fleet_dashboard_page.dart:12` +
   `owner_dashboard_page.dart:14`, CRICKET `manager_dashboard_page.dart:33`, SUPER
   `bus_fleet_dashboard_screen.dart:26` + `sub_admin_dashboard.dart:16`, and
   `shared/widgets/navigation/admin_sidebar.dart:4`.

   > **Note for whoever reads this next — a review got this wrong.** A review claimed "no
   > CRICKET file imports it" and that the CRICKET mention was a factual error. That claim is
   > **false**: `manager_dashboard_page.dart:33` imports it, under the comment *"Manager
   > Dashboard — 3D Pencil Sidebar layout"*. The likely cause of the confusion is **B5b** — the
   > widget is shared but every call site passes raw hex colours, so CRICKET's button *renders*
   > in different colours and looks like a different component. **Do not remove CRICKET from the
   > importer list.**

   **[Q] Colour tokenisation is part of this phase, not optional.** Promoting the widget while
   call sites keep hardcoding `Color(0xFF…)` leaves the same component looking different in
   every panel — the exact outcome the owner wants to eliminate. See B5b, D4 and Phase 3.
2. **Move `bus_tracking_models.dart`** to `shared/` (or the telemetry bloc to BUS).
3. **Break the SUPER ↔ BUS cycle** — extract the 4 fleet screens out of SUPER into a neutral
   `shared/fleet/`. Needs coordination with Phase 5's Super Admin work (B6).
4. **Replace the global auth globals** in `core/utils/auth_state.dart` with per-panel scoped
   auth — this is the Factory/Sub-Admin bug itself (§7c).
5. **Rule enforced from here on:** `lib/shared/**` must import **zero** `lib/features/**`.
6. **[Q] Enforce it in CI, not by convention** (§5c mechanism 1) — a rule that only lives in a
   document gets broken again. A `custom_lint`/`import_lint` rule plus a dependency-cruiser
   script that fails the build on a forbidden edge.

**Exit:** a grep proves no `shared → features` import remains; the CI check is live;
`dart analyze` clean.

### Phase 2 — Router extraction (behaviour-preserving)
Split `app_router.dart` per §7. `AppRouter` keeps composing the parts, so `main.dart` is
untouched. **One commit.** **Exit:** every working panel still works; file under ~250 lines.

### Phase 3 — Design system consolidation

**Canonical style: D4 — Cricket's pencil + colour style, tokenised, applied everywhere.**

1. Promote the shared primitives that are trapped in features (B11, incl. the 3 parallel KPI
   cards and the BUS `_pencil()` dashboard style).
2. **[Q] Merge the 4 competing theme roots** onto the D4 canonical palette: `AppTheme`,
   `shared/app_scaffold.dart`'s inline `ThemeData`, `LandingPalette`, `CricketColors`
   (+ `core/theme/branding_config.dart`). Adopt or delete `app_decorations.dart`.
   **[Q — sequencing note]** this lands *before* the departments are split, while the panels are
   still bundled — that is when the duplication is cheapest to reconcile, and it means each
   department inherits one theme instead of dragging its own root into its new build.
3. **[Q] Tokenise the colours and geometry, not just the widgets.** The hardcoded values are
   the actual source of the drift: 85 files with inline `Color(0x…)` (B5b is one instance),
   182 with inline `TextStyle(`, 191 with inline `BorderRadius.circular(`. Introduce spacing /
   radius / colour / icon tokens and retire the literals as files are touched.
4. **Introduce the pencil accent-role tokens from D4** (`accentPrimary` / `accentInfo` /
   `accentWarning` / `accentFeature` / `accentMuted` / `accentDanger`) so a panel picks a
   *meaning*, not a hex value.

**⚠️ This restyles panels the owner has already approved** (Super Admin, Factory, the 7 fleet
apps go from light to dark). Accepted deliberately — but it makes the Phase-0b screenshots
mandatory, and each panel should be restyled in the same phase that separates it, not all at once.

**Exit:** every panel renders from one theme + one token set; a grep for `Color(0xFF` outside
`lib/shared/theme/` trends to zero in the touched departments; `dart analyze` clean.

### Phase 4 — Pilot: B2B (Group 2) end-to-end
1. Rename `features/reseller/` → `features/b2b/`; add the Shopkeeper sub-app alongside.
2. Create `lib/main_b2b.dart` → `B2bApp` → `B2bAppInitializer` → `B2bRouter`
   (template: the existing reseller pair). Marketplace / Reseller / Shopkeeper each keep
   their **own login page**.
3. Add build + deploy steps to `frontend-deploy.yml`.
4. Deploy to `/var/www/traceodd/b2b-web/`; nginx `b2b.traceodd.com`.
5. **Leave the old `/reseller/` path working** until the new subdomain is verified.

**Exit:** `b2b.traceodd.com` works; every other panel unchanged.

### Phase 5 — Remaining departments, in dependency order

```
B2B ✅(P4) → Cricket → Factory → Bus → Goods → Customer → Super Admin
```

Rationale: **Bus before Goods** (Goods' truck UI currently reuses BUS pages — B8);
**Super Admin last** (entangled with everything, B7; and must be split in a coordinated step
with BUS because of the circular dependency, B6).

Per department: `main_*.dart` → initializer → router → deploy step → subdomain.
Plus:
- **Cricket** — decide SUPER-vs-CRICKET ownership of manager CRUD.
- **Factory** — lift factory-only bloc providers out of `app_initializer.dart`
  (lines 163–166 partial, 186–202, 221, 223).
- **Bus** — coordinated with Super Admin (B6).
- **Goods** — build **its own** driver/conductor UI (B8). Truck driver is a **free agent**
  (D1), so BUS's company-bound screens cannot be reused unchanged.
- **Customer** — move the live `customer_super_app_screen.dart` out of `bus_operations/`
  (B10) into Group 1; port features from the dead `universal/customer/` first (§6).
- **Super Admin** — receive the platform-only items from §6; everything else leaves.

### Phase 6 — Dynamic Sub-Admin roles + per-department API

1. **Replace the hardcoded vertical list with data-driven toggles.** Load the feature
   catalogue from `feature_registry`; render it as checkboxes in the Super Admin's
   "create/edit sub-admin" screen; persist the result to `sub_admin_feature_grants`.
   Remove the 5-entry hardcoded list in `add_sub_admin_screen.dart:15-48`.
2. **Enforce the grants at request time — middleware + a route-to-feature map** (see §10/Q2).
   Today `SubAdminMiddleware.php:57-69` checks only that an assignment *exists*; it never
   checks which features were granted, and `sub_admin_feature_grants` is never consulted.
   **[Q] Do not scatter per-controller policies** — one middleware check against one map.
3. **[Q] Apply the middleware to every panel route group.** It is currently used in exactly
   one place (`routes/panels/cricket.php:246-250`), so most routes are unenforced regardless of
   how correct the middleware is.
4. **Give every sub-admin its own dashboard**, assembled from the granted features rather than
   a vertical switch — today only `cricket_ops` differs and the rest fall through to the bus
   console (`sub_admin_dashboard.dart:167-176`).
5. Fix the 4 Flutter↔backend endpoint mismatches (`toggle-status`, `change-vertical`,
   `reset-password`, `restore`).
6. One API prefix + guard per department (`/api/v1/bus/…`, `/api/v1/goods/…`, …).
7. **Free-agent driver identity** (D1) — use the `driver_identities` + `driver_company_links`
   schema in §10/Q5. One identity, many time-bounded links, `fleet_type` distinguishes bus
   from truck, and a factory driver is a separate identity.
8. Unify the 5 auth stacks (B9) behind one interface.

**Exit:** a sub-admin created with only "goods" toggles enabled can reach goods surfaces and
**nothing else** — verified by attempting a bus route with that account and getting a denial.

### Phase 7 — Duplicate consolidation
Complete §6. Safe after departments are separate, because each duplicate then has exactly
one owner and deleting the wrong one is detectable.

### Phase 8 — Server separation
Only possible because Phase 6 made coupling API-only.

**[Q] Move the media engine first — it is nearly free.** It already has its own CI path
(`media-engine-build.yml` + `media-engine-deploy.yml`) and ships as a self-contained Docker
image (`traceodd/media-engine`), so this is a DNS + dedicated-host step, not a rewrite. It is
also the layer that *must* be separate, because it is stateful: a live call cannot migrate
between servers and needs room→server affinity.

Then split the API (stateless app servers + shared DB + Redis behind a load balancer), and
last the frontend, which is static files and therefore trivial.
Move the **stateful media engine first**; then API; then frontend (which is trivial).
Add a load balancer + stateless app servers when the API is the bottleneck.

---

## 9. Hard rules

1. **Never move two departments in one commit.**
2. **Never change a route path and a folder in the same commit.**
3. **`lib/shared/` must never import `lib/features/`.**
4. **A widget used by 2+ departments belongs in `shared/`, not in either department.**
5. **Enforce the layering rule in CI, not by convention. [NEW]** A rule that lives only in a
document gets broken again — that is how this repo reached its current state. Add a check
(script or lint) that fails the build when `lib/shared/**` imports `lib/features/**`, or when
one department's folder imports another's. This is the concrete implementation of rule 3, and
it is the single change that stops this problem recurring.
6. **Verify against the Phase-0b baseline after every phase.**
7. **Do not create `lib/features/fleet/{owner,driver,conductor}/`** — rejected in D1.
8. **The spec contradicts this plan** on fleet unification (it mandates `main_fleet_*.dart`
   and marks `main_driver.dart`/`main_reseller.dart` as deleted — none of which matches the
   code or the owner's requirement). Follow the owner; the spec needs a correction pass.

---

## 9b. Quick-win checklist **[from the second review — do these first, many take under an hour]**

Lowest-risk, highest-value actions:

- [ ] **Rotate the compromised passwords** (`awan1972`, `NexaAppPassword123!`) — they are in git
      history permanently.
- [ ] **Delete the plaintext DB credentials** from `lib/core/config/database_config.dart` — the
      frontend must never carry a direct DB connection string.
- [ ] **Fix `tests.yml:6`** — change `master` to `[main, mainnew]`; backend tests start running
      immediately (one-line fix).
- [ ] **Register `consumer`** in the `PanelRouteServiceProvider` panels array — or delete
      `consumer.php`. Either way, remove the dead code (§7b.1).
- [ ] **Add admin middleware to `super_admin.php`** — mirror the `BusFleetGate` pattern (§7b.2).
- [ ] **Replace the hardcoded `root@135.181.46.27`** in `frontend-deploy.yml` with the same
      `vars.VPS_HOST` variable `deploy.yml` already uses.
- [ ] **Add `dart analyze` to CI** — one step, catches type/lint errors before deploy.
- [ ] **Add `gitleaks` (or `trufflehog`) secret scanning to CI** — prevents the next credential
      commit.
- [ ] **Move `missile_3d_button.dart`** into `lib/shared/widgets/` — unblocks 4 panels
      (5 import paths).
- [ ] **Add `.github/CODEOWNERS`** — per-panel ownership requiring review.
- [ ] **Add per-panel `paths:` filters** to the deploy workflow — stops the all-or-nothing
      rebuild of all 8 panels.
- [ ] **Write ONE real Flutter test** to replace the 17-line placeholder — proves the test
      infrastructure works and sets the pattern.

---

## 10. Answers from the independent review **[Q]**

The six questions in the first draft of this plan were put to an independent reviewer
(Qoder expert). Their answers are folded in here; the review documents were then deleted so
this file is the single source of truth.

### Q1 — Server strategy: staged separation is approved

Agreed as planned: frontend = static files, API = make stateless (sessions in Redis), media
engine = stateful and needs its own host. Nothing should split sooner; the single-server model
is correct until load demands otherwise, and API-only coupling is the right gate.

**[Q] Addition — Phase 8 is nearly free for the media engine.** It is *already* on its own CI
path (`media-engine-build.yml` + `media-engine-deploy.yml` are separate workflows) and ships as
a self-contained Docker image (`traceodd/media-engine`). Moving it is a DNS + dedicated-host
step, not a re-architecture. Do it first, as planned.

### Q2 — Sub-Admin enforcement: middleware **plus a route-to-feature map**

Middleware is the right layer, but it needs a mapping:

1. After `SubAdminMiddleware.php` confirms the identity is a sub-admin (Tier 3, lines 60-63),
   query `sub_admin_feature_grants` for that `global_identity_id`.
2. Compare the requested route's prefix against the grant set.
3. Return **403** when the grant does not cover the endpoint.

**[Q] The map:** a lightweight `feature_route_map` (a config array, or a column on
`feature_registry`) associating each grant code with an API prefix — e.g.
`bus_fleet_management → /api/v1/bus/*`, `goods_logistics → /api/v1/goods/*`,
`cricket_ops → /api/v1/cricket/manager/*`. One check in one place.

**[Q] Why not per-controller policies:** 40+ enforcement points must each be correct, which is
exactly where a gap hides for months. Middleware + map is simpler and auditable.

**[Q] The prerequisite everyone forgets:** the middleware must actually be *applied*. Today it
is used in exactly one place (`routes/panels/cricket.php:246-250`). Phase 6 has to attach it to
every panel route group, or the enforcement never runs.

### Q3 — Deletion list: no objections

Every entry was independently verified as dead. **[Q] One caveat:** before deleting
`core/services/payment_service.dart` and `subscription_validator.dart`, confirm no backend
migration references them as a *planned* dependency. If billing is "coming soon" rather than
"abandoned", keep the interface contract and delete only the empty stub.

### Q4 — Design unification: order approved, with a real risk

Approved as: promote the button → converge theme roots → introduce tokens → retire literals
incrementally (never as one big-bang commit).

**[Q] Risk:** the 4 theme roots produce subtly different visual output, so merging them can
change colours/shadows in panels the owner has already approved. **Mitigation: screenshot every
panel before Phase 3 and diff after.** This belongs in the Phase-0 baseline.

**[Q] Suggestion:** `shared/theme/app_decorations.dart` is currently unused and on the delete
list. Since Phase 3's goal is a token system, consider **adopting** it as the container/shape
token set instead of deleting it.

### Q5 — Free-agent driver identity: concrete schema

The link-table model in D1 is correct. **[Q] Recommended shape:**

```
driver_identities
  id (PK), global_identity_id (FK -> global_identities),
  license_number, license_class, created_at

driver_company_links
  id (PK), driver_identity_id (FK), company_id (FK),
  fleet_type ENUM('bus','truck'), role ENUM('driver','conductor'),
  started_at, ended_at (NULL = current),
  status ENUM('active','terminated','suspended'),
  UNIQUE(driver_identity_id, company_id, fleet_type, ended_at IS NULL)
```

Properties that matter:

- **One identity, many links** — history accumulates across companies.
- **Time-bounded** — `ended_at` is set when a contract ends and the history remains.
- **Fleet-typed** — bus and truck live under the *same* identity, distinguished by
  `fleet_type`, not by separate identities.
- **Factory stays separate** — a factory driver is a different `global_identity`.

This is exactly the link the owner already tested when moving buses between fleet companies.

### Q6 — Cricket needs a module record: yes

It is a whole department with its own media engine, 2 Flutter entry points, 2 CI workflows, a
subdomain, and a Sub-Admin feature set — and it is the most technically complex part of the
system (GStreamer / WebRTC / SRS / HLS). Its absence from the spec means future agents have no
canonical reference. **[Q] The record should carry the stream pipeline, the roles, the
infrastructure, and the declare/feed contract that caused the outage.**

### Q7 — The streaming problem: diagnosis agreed

The reviewer independently agreed with the declare/feed root cause in
`FAULT-REMEDIATION-HISTORY.md` §9, and added:

1. **The test rewrite is as important as the code fix** — the old test asserted the wrong
   invariant, so the new tests must be the acceptance gate. *(Since folded into the fix:
   `only_live_buses_get_an_audio_branch`, `description_declares_exactly_the_live_buses`,
   `no_live_buses_means_no_audio_stage` — all three now **execute and pass locally**, 34/34.)*
2. The `rearm_stale_forwarders` target-fidelity fix prevents the watchdog silently downgrading
   a re-armed forwarder. Real bug, correctly fixed.
3. `live_video_page.dart` rendering `forwarder_error` is essential — without it the next failure
   is just as blind.
4. **The fix has been compiled and its tests pass, but it has never run against SRS.** The §9.9
   A/B experiment on the live server is the definitive verification.

**[Q] Recommendation, adopted as Phase S below:** verify the stream **before** starting panel
separation. A working public stream is the owner's original complaint.
