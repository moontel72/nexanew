# Panel Separation — Independent Recommendations & Isolation Blueprint

**Status:** Advisory only. No code was changed to produce this document.
**Scope:** Flutter frontend (`lib/`), Laravel backend (`backend/`), and CI/CD (`.github/workflows/`).
**Date:** 2026-09-20
**Companion documents:**

- `docs/handoff/PANEL-SEPARATION-PLAN.md` — the plan under review (764 lines). This file corrects and extends it; it does not replace it.
- `docs/handoff/FAULT-REMEDIATION-HISTORY.md` — separate scope (GStreamer / media engine faults).

**Purpose.** This is the deliverable of an independent architectural investigation. It:

1. Records factual errors and material omissions found in `PANEL-SEPARATION-PLAN.md`.
2. Describes the *actual* current state of the monorepo with exact `path:line` evidence.
3. Defines a target architecture that keeps every panel/app fully isolated.
4. Proposes a corrected, dependency-ordered roadmap with concrete containment mechanisms.

Every claim about existing code cites an exact path (and line where known) so a reader can verify it independently.

---

## 1. Executive Summary

The separation plan is directionally correct — splitting the monolith into independently deployed panels is the right goal — but it is **not yet safe to execute as written**. The router-split line ranges it prescribes are partly wrong, several security/dead-API gaps are unaddressed, and the plan proposes to split the router **before** the layering violations that cause coupling are fixed. Splitting first would simply re-mix the same coupled code across more files.

**Key findings:**

- **Layering must be fixed and *enforced* before the router is split.** `lib/shared/` imports `lib/features/` (4 confirmed violations) and panels import each other (BUS ↔ SUPER is a true circular dependency). Splitting `app_router.dart` without first extracting shared widgets and breaking these cycles just relocates the coupling.
- **`main.dart` is a MEGA-ENTRY with total cross-panel leakage.** It boots Super Admin + Factory auth + BUS `TicketVaultService` + the full 1142-line router carrying every panel's routes and state. Deployed to production (`admin.traceodd.com`).
- **Three P0 security/API gaps are an emergency:** plaintext DB superuser credentials in `database_config.dart` (password `awan1972`, IP `135.181.46.27:5444`); `super_admin.php` has **no admin middleware** (only `auth:sanctum`); `consumer.php` (5 endpoints) is never loaded — the customer Super-App API is dead code.
- **CI provides almost no containment.** All 8 deployed frontends rebuild all-or-nothing on any `lib/**` change; there are **zero Flutter tests** in CI; backend tests trigger on the wrong branch (`master`); no staging, no rollback, no secret scanning, no `dart analyze`.
- **A single 1142-line mega-router** (`lib/routes/app_router.dart`) registers *all* panels in one getter, and its redirect logic leaks panels across contexts (unguarded `/sub-admin/*`, `/bus-fleet/*`; non-web root redirects to Factory login).
- **Global mutable auth state** (`core/utils/auth_state.dart`) is read cross-panel by the router redirect — a Factory login sets state the Super Admin guard reads.
- **The isolated panels are the reference model.** `main_landing.dart`, `main_cricket_manager.dart`, `main_cricket_public.dart`, and `main_reseller.dart` each compose their own router + providers inline and never touch global `AppProviders`. Copy this pattern everywhere.
- **Sub-admin enforcement is nominal.** `SubAdminMiddleware` (lines 59-69) only checks `->exists()` — it never validates the vertical or feature grants. The frontend route guard (`route_guard_middleware.dart:123-131`) deliberately returns `null`.

**The single most important recommendation:** Fix layering violations + add automated boundary enforcement (import-lint + `dart analyze` + path-filtered CI) BEFORE splitting the router, and treat the P0 security/API gaps as an emergency to resolve first.

### Priority Table

| Priority | Meaning | Items |
|---|---|---|
| **P0** | Emergency — security or broken production surface. Do first. | Plaintext DB superuser creds in `database_config.dart` (rotate `awan1972`, `NexaAppPassword123!`); `super_admin.php` missing admin middleware; `consumer.php` never loaded (dead customer API); `goods_fleet.php:29` `auth:admin`; `truck_fleet.php:20` `auth:sanctum` only; hardcoded `root@135.181.46.27` in `frontend-deploy.yml`; `tests.yml` triggers on `master` not `main`/`mainnew`. |
| **P1** | Structural — must precede the router split. | Zero Flutter tests + no frontend CI validation; sub-admin vertical/feature grants never enforced at request time; all-or-nothing CI rebuilds all 8 panels on any `lib/**` change; extract cross-panel shared widgets; break SUPER↔BUS cycle; per-panel providers; scoped auth state; CI boundary enforcement (import-lint, `dart analyze`, secret scan, path filters). |
| **P2** | Separation — the actual split (safe only after P1). | SUPER↔BUS circular dependency; truck_driver/truck_conductor reuse BUS pages verbatim; `missile_3d_button` lives in BUS but used by 4 panels; split `app_router.dart`; eliminate `main.dart` mega-entry; finish backend `api.php` migration + per-panel gates. |
| **P3** | Quality — polish and consistency. | Plan §7 misclassifies error-builder text as B2B routes (E3); plan §7 assigns lines 263-281 to both bus and goods (E5); design-system consolidation (single token source); data-driven sub-admin verticals; localization; accessibility; per-panel docs/CODEOWNERS; changelog/versioning. |

---

## 2. Errors & Corrections in `PANEL-SEPARATION-PLAN.md`

These must be corrected in the plan **before execution**. The line-range errors (E3/E4/E5) are the most dangerous: following them literally would extract redirect logic and error text instead of the real feature routes, breaking the router split. The omissions (O1/O2/O3) are security/dead-API gaps the plan never mentions.

### 2.1 Factual Errors

| ID | Plan Claim | Reality | Evidence | Severity |
|---|---|---|---|---|
| **E1** | `app_router.dart` is "1141 lines" | It is **1142** lines | `lib/routes/app_router.dart` (1142 lines) | Trivial |
| **E2** | `app_initializer.dart` is "280 lines" | It is **281** lines | `lib/core/**/app_initializer.dart` (281 lines) | Trivial |
| **E3** | §7: `b2b_routes.dart` should contain lines "247-249, 153-163" | Lines 247-249 are a **redirect bypass** (`if path.startsWith('/reseller') return null`); lines 153-163 are **error-builder text** ("Reseller App is deployed separately"). Neither is a B2B feature route. The real reseller admin routes are at **760-769** (`/resellers`, `/resellers/add`). | `lib/routes/app_router.dart:247-249`, `:153-163`, `:760-769` | **Medium** |
| **E4** | §7: `factory_routes.dart` should contain lines "203-234, 244-246" | Lines 203-234 are **redirect logic inside `_safeRedirect`**; 244-246 is a **public-route bypass** — not route definitions. Actual Factory `GoRoute` definitions begin at **line 327** (`/factory/login`) and continue at **793+** (`FactoryShell`). | `lib/routes/app_router.dart:203-234`, `:244-246`, `:327`, `:793+` | **Medium** |
| **E5** | §7: lines "263-281" assigned to **both** `bus_routes.dart` and `goods_routes.dart` | An overlapping/duplicate assignment — the same range **cannot** belong to two files. Must be de-duplicated against the real route map (BUS 332-336/487-527/600-631; GOODS 337-341/528-568/569-599). | `lib/routes/app_router.dart:263-281` | **Medium** |
| **E6** | Cites `SubAdminMiddleware.php:57-69` | Line 57 is a **closing brace**; the identity check begins at **line 59**. Relevant code is 59-69. | `backend/app/Http/Middleware/SubAdminMiddleware.php:59-69` | Trivial |
| **E7** | Cites `cricket.php:246-250` for the `sub.admin` middleware | Line 246 is a **comment**; group starts at 247; the `sub.admin` declaration is on **line 248** | `backend/routes/panels/cricket.php:248` | Trivial |

### 2.2 Material Omissions

| ID | What the Plan Never Mentions | Impact | Evidence | Severity |
|---|---|---|---|---|
| **O1** | `consumer.php` (5 endpoints) is **never loaded** — `PanelRouteServiceProvider.php` `$panels` array (lines 43-54) omits `'consumer'` | The entire Customer Super-App API is **unreachable dead code** | `backend/routes/panels/consumer.php`; `backend/app/Providers/PanelRouteServiceProvider.php:43-54` | **High** |
| **O2** | `goods_fleet.php` line 29 uses `auth:admin` | **Any** admin (of any vertical) can access goods endpoints — no goods-specific gate (unlike BUS which has `BusFleetGate`) | `backend/routes/panels/goods_fleet.php:29` | **High** |
| **O3** | `truck_fleet.php` line 20 uses only `auth:sanctum` | **Any authenticated user** can reach truck-fleet logistics endpoints | `backend/routes/panels/truck_fleet.php:20` | **High** |
| **O4** | `tests.yml` line 6 triggers on branch `master`, but deploys run from `main`/`mainnew` | Backend tests **likely never run** on the branches that deploy to production | `.github/workflows/tests.yml:6` | **Medium** |
| **O5** | **Zero Flutter tests in CI** — no workflow runs `flutter test`; only test is a 17-line placeholder testing a `SizedBox` | No automated safety net for the frontend during a large refactor | `test/widget_test.dart` (17 lines) | **Medium** |
| **O6** | `api.php` is a **986-line monolith** still mixing all panels (admin, factory, reseller, transport, freight, analytics, billing, notifications, offline sync); `panels/*.php` are only a **partial** migration | Backend separation is far less complete than the plan implies | `backend/routes/api.php` (986 lines) | **Medium** |

> **Action required:** E3/E4/E5 must be re-derived from the real route map (§3.2) before anyone touches `app_router.dart`. O1/O2/O3 must be added to the plan as P0 backend security work.

---

## 3. Current-State Reality Check

### 3.1 Entry Points — 13 `lib/main*.dart` Files

| Entry Point | Panel(s) Served | Key Imports / Coupling | Leakage | CI-Deployed? |
|---|---|---|---|---|
| `main.dart` | **MEGA-ENTRY**: Super Admin + Factory auth + BUS `TicketVaultService` + full 1142-line router | `AppInitializer` → `app_providers.dart` (59 imports); `app_router.dart` (all panels) | **TOTAL** | ✅ `admin.traceodd.com` |
| `main_landing.dart` | Landing only | Own minimal widget tree | None | ✅ `traceodd.com` |
| `main_cricket_manager.dart` | Cricket manager only | Own inline `GoRouter`; own `BlocProvider`s | None — **reference model** | ✅ `cricket-manager.traceodd.com` |
| `main_cricket_public.dart` | Cricket public viewer only | Own inline `GoRouter`; own `BlocProvider`s | None — **reference model** | ✅ `cricket.traceodd.com` |
| `main_reseller.dart` | B2B / reseller only | Own router (`reseller_router.dart`) + own initializer | None — **reference model** | ✅ (path-based) |
| `main_driver.dart` | Factory driver only | Own `driver_app_initializer.dart` | None (good) | ✅ (path-based) |
| `main_bus_fleet.dart` | BUS fleet admin | **Line 16 imports `features/storekeeper`** (`storekeeper_dashboard_screen`) | Storekeeper leak | ✅ (path-based) |
| `main_bus_owner.dart` | BUS owner only | Minimal, panel-scoped | None (good) | ✅ (path-based) |
| `main_bus_driver.dart` | BUS driver only | Minimal | None (good) | ❌ not deployed |
| `main_bus_conductor.dart` | BUS conductor only | Minimal | None (good) | ❌ not deployed |
| `main_truck_owner.dart` | Goods operations only | Minimal, panel-scoped | None (good) | ❌ not deployed |
| `main_truck_driver.dart` | Goods driver | **Line 6 imports BUS** `features/bus_operations/.../driver_dashboard_page.dart` | Reuses BUS pages verbatim | ❌ not deployed |
| `main_truck_conductor.dart` | Goods conductor | **Line 6 imports BUS** `features/bus_operations/.../conductor_dashboard_page.dart` | Reuses BUS pages verbatim | ❌ not deployed |

**Summary:** 8 of 13 entry points are CI-deployed via `frontend-deploy.yml`. 5 are never deployed: `main_bus_driver`, `main_bus_conductor`, `main_truck_owner`, `main_truck_driver`, `main_truck_conductor`.

### 3.2 The Single Mega-Router Problem

`lib/routes/` contains **exactly one file**: `app_router.dart` (1142 lines). All panel routes are registered in a single `_routes` getter:

| Panel / Concern | Line Range |
|---|---|
| SUPER admin | 321-326 |
| FACTORY login | 327-331 |
| BUS fleet | 332-336 |
| GOODS fleet | 337-341 |
| SUB-ADMIN | 342-351 |
| CRICKET admin | 352-369 |
| CRICKET manager | 370-486 |
| BUS owner / driver / conductor | 487-527 |
| GOODS truck | 528-568 |
| GOODS fleet dashboard | 569-599 |
| BUS fleet dashboard | 600-631 |
| CUSTOMER | 632-652 |
| SUPER shell | 653-792 |
| FACTORY shell | 793-1075 |

**Cross-panel exposure in redirect logic (lines 184-317):**

| Lines | Behaviour | Risk |
|---|---|---|
| 255-258 | All `/sub-admin/*` paths `return null` — **no guard** | Any user can reach sub-admin routes |
| 250-253 | All `/bus-fleet/*` paths `return null` — **no guard** | Any user can reach bus-fleet routes |
| 240 | Root on non-web redirects to `/factory/store-keeper/login` | Leaks Factory into any mobile context |
| 247-249 | `if path.startsWith('/reseller') return null` | Redirect bypass — **not a route** (plan E3 misclassifies this) |

**Isolated routers that already work (the model to follow):**

- `lib/features/reseller/routes/reseller_router.dart`
- `main_cricket_manager.dart` / `main_cricket_public.dart` build their own `GoRouter` inline
- `lib/features/factory/driver/app/driver_app_initializer.dart`

### 3.3 Layer-Boundary Violations & Circular Dependency

**Backward imports (`lib/shared/` → `lib/features/`) — 4 confirmed:**

| Shared File | Illegal Import Target | Line |
|---|---|---|
| `lib/shared/widgets/navigation/admin_sidebar.dart` | `features/bus_operations/presentation/widgets/missile_3d_button.dart` | :4 |
| `lib/shared/bloc/telemetry_tracking/telemetry_models.dart` | `features/bus_operations/data/services/bus_tracking_models.dart` | :6 |
| `lib/shared/utils/fleet_bloc_setup.dart` | `features/auth` (`panel_auth_repository`, `panel_auth_bloc`) | :10-11 |
| `lib/shared/widgets/fleet_bloc_login_screen.dart` | `features/auth` (repository, bloc, event, state) | :20-23 |

**Cross-feature imports (one panel importing another):**

| Importer (Panel) | Imports From (Panel) | Line |
|---|---|---|
| `manager_dashboard_page.dart` (CRICKET) | BUS `missile_3d_button` | :33 |
| `fleet_dashboard_page.dart` (BUS) | SUPER — 4 `nexa_admin` screens (`route_scheduler`, `ticket_management`, `voucher_management`, `bonus_management`) | :19-22 |
| `bus_fleet_dashboard_screen.dart` (SUPER) | BUS (`missile_3d_button`, `fleet_dispatch_dialog`) | :26-27 |
| `sub_admin_dashboard.dart` (SUPER) | BUS `missile_3d_button` | :16 |
| `main_truck_driver.dart` (GOODS) | BUS `driver_dashboard_page` | :6 |
| `main_truck_conductor.dart` (GOODS) | BUS `conductor_dashboard_page` | :6 |
| `main_bus_fleet.dart` (BUS) | STOREKEEPER `storekeeper_dashboard_screen` | :16 |

**Circular dependency SUPER ↔ BUS:** BUS `fleet_dashboard_page` imports 4 SUPER screens (`:19-22`); SUPER `bus_fleet_dashboard_screen` imports 2 BUS widgets (`:26-27`). Neither panel can be built or deployed independently.

**Shared widget pinning panels:** `missile_3d_button.dart` (lives in BUS) is imported by **5 files across 4 panels** (BUS, CRICKET, SUPER, shared). It must be moved out of `bus_operations` before BUS can be isolated.

### 3.4 Backend Middleware Isolation

Two-tier routing: `api.php` (986-line monolith, all legacy routes) plus `backend/routes/panels/*.php` (11 files, partial migration) loaded by `PanelRouteServiceProvider`.

| Panel Route File | Prefix | Middleware | Assessment |
|---|---|---|---|
| `bus_fleet.php` | `/api/v1/bus-fleet` | `auth:sanctum` + `bus.fleet` (`BusFleetGate`) | ✅ **GOOD** |
| `cricket.php` (group 2) | `/api/v1/cricket/manager` | `cricket.manager` (`CricketManagerAuth`) | ✅ **GOOD** |
| `cricket.php` (group 3) | `/api/v1/cricket/admin` | `auth:sanctum` + `sub.admin` | ⚠️ PARTIAL (only `exists()`) |
| `bus_owner.php` | — | `auth:sanctum` only | ⚠️ WEAK |
| `goods_fleet.php` | — | `auth:admin` | ⚠️ WEAK (any admin) |
| `truck_fleet.php` | — | `auth:sanctum` only | ⚠️ WEAK |
| `super_admin.php` | — | `auth:sanctum` only | ⚠️ **WEAK — NO admin middleware** |
| `factory.php` | — | `auth:sanctum` only | ⚠️ WEAK |
| `passenger.php` | — | `auth:sanctum` only | ⚠️ WEAK |
| `consumer.php` | — | `auth:sanctum` | ❌ **DEAD — never loaded** |

**Sub-admin enforcement is nominal:**

- `sub.admin` middleware is used **exactly once** (`cricket.php:248`).
- `SubAdminMiddleware` (lines 59-69) only checks `->exists()` on `sub_admin_assignments` — never validates the **vertical** or **feature grants**.
- `route_guard_middleware.dart:123-131` is deliberately unimplemented (returns `null`).
- `sub_admin_dashboard.dart:167-176` switch falls through to `_busDashboard()` for everything except `cricket_ops`.

### 3.5 CI/CD Reality

| Aspect | Current State | Risk |
|---|---|---|
| Frontend triggers | `frontend-deploy.yml` on push to `main`/`mainnew` when `lib/**`, `web/**`, `assets/**`, `pubspec.yaml` change | All 8 panels rebuild **all-or-nothing** |
| Backend triggers | `deploy.yml` on `main`/`mainnew`: rsync + `php artisan migrate --force` every deploy | No staging; no rollback |
| Test triggers | `tests.yml` line 6: branch `master` | Tests **never run** on deploy branches |
| Media engine | `media-engine-build.yml` + `media-engine-deploy.yml` on `media-engine/**` only | ✅ Only truly isolated pipeline |
| Flutter tests | **None** — `test/widget_test.dart` is a 17-line `SizedBox` placeholder | No safety net |
| `dart analyze` | **Not in CI** | Lint/type regressions undetected |
| Secret scanning | **None** | Plaintext credentials persist |
| Server references | `frontend-deploy.yml` hardcodes `root@135.181.46.27` (lines 61, 90, 105, 145, 165-166, 185, 200, 214, 229); `deploy.yml` uses `${{ vars.VPS_HOST }}` | Inconsistent; IP in repo history |
| Rollback | `rsync --delete`; no versioned artifacts | Irreversible on failure |
| Staging | **None** — push to `main` = production | No pre-prod validation |

### 3.6 State / Data Isolation

- **Framework:** `flutter_bloc` + `RepositoryProvider`. Feature blocs per-panel (correct pattern).
- **CORE LEAK:** `core/providers/app_providers.dart` (284 lines, 59 imports) is **GLOBAL**. `AppInitializer` (`main.dart`) calls `getRepositoryProviders` (SUPER + FACTORY + B2B), `getDriverBlocProviders` (FACTORY driver), `getNexaAdminBlocProviders` (SUPER), `getFactoryAdminBlocProviders` (ALL factory). The `main.dart` bundle carries state for Super Admin + Factory Admin + Factory Driver + Factory Store Keeper + B2B at startup regardless of panel accessed.
- **Global mutable auth:** `core/utils/auth_state.dart` exposes mutable globals (`isAuthenticatedCache`, `isFactoryAuthenticatedCache`, `isAuthCheckCompleted`) read by the router redirect. A Factory login sets state the Super Admin guard reads.
- **Storage:** `SharedPreferences` keys are panel-scoped **by convention only** (`busFleet_fleet_role`, `cricket_manager_token`, `factory_auth_token`); nothing prevents cross-reads.
- **Correct model:** isolated panels (cricket, reseller, landing) create their own `BlocProvider`s inline and never touch global `AppProviders`.

### 3.7 Security / Secrets

`lib/**/database_config.dart` contains **plaintext credentials**:

| Line(s) | Content |
|---|---|
| 6-10 | Host, port, database name, username, password |
| 54 | Postgres **superuser** connection string: password `awan1972`, IP `135.181.46.27:5444` |
| (also present) | App password `NexaAppPassword123!` |

The server IP `135.181.46.27` is hardcoded in `frontend-deploy.yml`. There is **no secret scanning** in CI. These credentials must be treated as **compromised** (they are in git history).

### 3.8 Design / Theme

- `CricketColors` (`cricket_colors.dart:1-8`) documents WCAG contrast ratios — **the good standard**.
- `#0A0E21` is duplicated across `CricketColors:16`, `LandingPalette:15`, and `TraceOddBrandTokens:27`.
- Hardcoded colors at cricket call sites: manager dashboard lines 363, 537, 579, 586, 605.
- Sub-admin verticals are a hardcoded `static const _verticals` list of 5 entries at `add_sub_admin_screen.dart:15-48` — not data-driven.

---


## 4. Target Architecture — How to Keep Every Panel Fully Isolated

The governing principle: **each panel is a vertical slice that owns everything it needs and depends on nothing from another panel.** Dependencies flow one way only: `core` ← `shared` ← `features/<panel>`. Panels never import panels. `shared` never imports `features`. The isolated panels that already exist (cricket, reseller, landing) prove this model works in this codebase — the goal is to make everything look like them.

### 4.1 Per-Panel Vertical Slice

Each panel owns its **routes, blocs, models, API client, screens, widgets, and theme** under `lib/features/<panel>/`. Only *genuinely generic* code (design-system primitives, HTTP transport, storage adapter, telemetry contracts) lives in `lib/shared/` + `lib/core/`.

**Rules:**

- If two panels need the same widget/bloc, it belongs in `shared/` — **not** in one panel importing the other. This is exactly the `missile_3d_button.dart` case (§4.4).
- `shared/` may depend on `core/`; it may **never** depend on `features/`. The 4 backward imports in §3.3 are the anti-pattern to eliminate.
- Each panel folder is self-contained: it can be extracted into its own package/repo with zero changes to imports outside its boundary.

### 4.2 One Entry Point Per Panel — Kill the Mega-Entry

Each entry point composes **only** that panel's router + providers. Eliminate the `main.dart` mega-entry, or reduce it to a **thin launcher** that imports a single panel (Super Admin) and nothing else.

- `main.dart` must stop booting Factory auth, BUS `TicketVaultService`, and the all-panel router.
- Follow the `main_cricket_manager.dart` / `main_reseller.dart` shape: a small `main()` that builds its own `MultiBlocProvider` from **that panel's** provider module and its own router.
- Each panel's `main_*.dart` should be under 50 lines: initialize Flutter, wrap in `BlocProvider`s from `features/<panel>/providers.dart`, set the panel's router, run.

### 4.3 Split `app_router.dart` — But Only After §4.4/§4.5

Split the 1142-line mega-router into per-panel routers:

| New File | Panel | Source Lines (from §3.2 corrected map) |
|---|---|---|
| `platform_router.dart` | Super Admin + Sub-Admin shell | 321-326, 342-351, 653-792 |
| `factory_router.dart` | Factory (login + shell) | 327-331, 793-1075 |
| `bus_router.dart` | BUS fleet + owner/driver/conductor + fleet dash | 332-336, 487-527, 600-631 |
| `goods_router.dart` | GOODS fleet + truck + fleet dash | 337-341, 528-568, 569-599 |
| `cricket_router.dart` | Cricket admin + manager | 352-369, 370-486 |
| `b2b_router.dart` | Reseller admin | 760-769 |
| `customer_router.dart` | Customer Super-App | 632-652 |

**This step must come after §4.4 and §4.5** — splitting first just re-mixes the same coupled imports across more files. Use the corrected line map above, **not** the plan's §7 ranges (which contain errors E3/E4/E5).

### 4.4 Extract Cross-Panel Shared Widgets Out of Feature Folders

Move `missile_3d_button.dart` (and any similar shared widget) **out of** `bus_operations` into `lib/shared/widgets/` (or a `design_system` package). Today it is imported by 5 files across 4 panels (§3.3) — a widget that everyone uses cannot live inside one panel's internals.

Similarly, `bus_tracking_models.dart` is imported by `lib/shared/bloc/telemetry_tracking/telemetry_models.dart` — either the models belong in `shared/` or the telemetry bloc belongs in BUS.

### 4.5 Break the SUPER ↔ BUS Circular Dependency

Two actions required:

1. **Extract the 4 shared fleet screens** (`route_scheduler`, `ticket_management`, `voucher_management`, `bonus_management`) from SUPER `nexa_admin` into a **neutral shared fleet module** (`lib/shared/fleet/` or `lib/features/fleet_common/`) that both SUPER and BUS may import without creating a cycle.

2. **Give truck_driver/truck_conductor their OWN pages** inside `goods_operations` instead of importing BUS `driver_dashboard_page.dart` / `conductor_dashboard_page.dart`. If the pages are truly identical in layout, extract the common structure to `shared/` — do **not** have GOODS depend on BUS.

### 4.6 Split `app_providers.dart` Into Per-Panel Provider Modules

`core/providers/app_providers.dart` (284 lines, 59 imports) is the single biggest state leak. Break it into:

| New Module | Registers |
|---|---|
| `features/nexa_admin/providers.dart` | Super Admin repos + blocs |
| `features/factory/providers.dart` | Factory Admin + Driver + Store Keeper repos + blocs |
| `features/bus_operations/providers.dart` | BUS fleet repos + blocs |
| `features/goods_operations/providers.dart` | GOODS fleet repos + blocs |
| `features/reseller/providers.dart` | B2B repos + blocs |
| `features/cricket/providers.dart` | Cricket repos + blocs (already inline — formalize) |

Each entry point registers **only its own** providers. Remove all global cross-panel registration so `main.dart` no longer carries Factory + B2B + Super state at startup.

### 4.7 Replace Global Mutable Auth State With Per-Panel Scoped Auth

`core/utils/auth_state.dart` exposes mutable globals (`isAuthenticatedCache`, `isFactoryAuthenticatedCache`, `isAuthCheckCompleted`) read by the router redirect. Replace with:

- **Per-panel auth state** scoped to that panel's `BlocProvider` tree.
- Each panel's router reads **only its own** auth state — a Factory login cannot influence the Super Admin guard.
- Also implement `route_guard_middleware.dart:123-131` (currently returns `null`) so panel-vs-route validation is actually enforced at navigation time.

### 4.8 Enforce a One-Directional Dependency Rule (in CI)

**Allowed direction:** `core` ← `shared` ← `features/<panel>`.

**Forbidden:** `shared` → `features` and `feature` → `feature` (different panels).

This must be **machine-enforced**, not just documented:

1. **`analysis_options.yaml` + `custom_lint` / `import_lint`:** Define rules that flag any import from `lib/shared/` to `lib/features/` or from `lib/features/<A>/` to `lib/features/<B>/`.
2. **Dependency-cruiser script:** A Dart/Python script that walks the import graph and **fails CI** on any forbidden edge.
3. **`dart analyze` in CI:** Currently absent (§3.5). Add it to catch type errors and lint violations before deploy.
4. **Pre-commit hook:** Extend `.githooks/pre-commit` to run the dependency check locally.

### 4.9 Backend: Finish Separation + Per-Panel Gates

1. **Finish migrating `api.php`** (986 lines) into per-panel route files under `backend/routes/panels/`. The current panel files are a partial migration (§2.2 O6).
2. **Register `consumer.php`** in `PanelRouteServiceProvider.php` `$panels` (lines 43-54) — or delete the dead customer surface entirely. Do not leave unreachable API code.
3. **Add a per-panel gate middleware for EVERY panel**, mirroring the good `BusFleetGate` / `CricketManagerAuth` pattern:

| Panel | Required Gate | Current State |
|---|---|---|
| Super Admin | `super.admin` (role check) | ❌ Missing — only `auth:sanctum` |
| Goods Fleet | `goods.fleet` (vertical check) | ❌ Missing — `auth:admin` (any admin) |
| Truck Fleet | `truck.fleet` (vertical check) | ❌ Missing — `auth:sanctum` only |
| Factory | `factory.auth` (role check) | ❌ Missing — `auth:sanctum` only |
| Passenger | `passenger.auth` | ❌ Missing — `auth:sanctum` only |
| BUS Owner | `bus.owner` | ❌ Missing — `auth:sanctum` only |

4. **Enforce sub-admin vertical + feature grants at request time** in `SubAdminMiddleware` (lines 59-69). Currently it only checks `->exists()` — it must validate that the sub-admin's assigned vertical matches the route's panel, and that the specific feature grant permits the action.

### 4.10 Storage / Namespace Isolation

- Use **compile-time namespaced storage keys per panel** so `SharedPreferences` keys cannot be cross-read. Today they are convention-only (`busFleet_fleet_role`, `cricket_manager_token`) — nothing prevents `main.dart` from reading a BUS key.
- Ideally each panel is its own build target with its own storage origin (web: distinct `localStorage` origin per subdomain; mobile: distinct `SharedPreferences` namespace via compile-time prefix injection).
- Define a `StorageKeys` class per panel with a mandatory prefix constant, enforced by lint.

### 4.11 Recommended Target Folder Layout

```
lib/
├── core/
│   ├── constants/           # App-wide constants (no panel logic)
│   ├── network/             # HTTP client, interceptors, base URL config
│   ├── storage/             # Storage adapter, namespace prefix injection
│   ├── utils/               # Pure utilities (no auth state globals)
│   └── errors/              # Shared failure/exception types
│
├── shared/
│   ├── widgets/             # Generic UI primitives (missile_3d_button lives HERE)
│   │   ├── navigation/
│   │   └── design_system/   # Tokens, typography, spacing, color palettes
│   ├── bloc/                # Generic blocs (telemetry, connectivity)
│   ├── fleet/               # Neutral shared fleet screens (extracted from SUPER)
│   │   ├── route_scheduler/
│   │   ├── ticket_management/
│   │   ├── voucher_management/
│   │   └── bonus_management/
│   └── models/              # Shared data models (bus_tracking_models if truly shared)
│
├── features/
│   ├── nexa_admin/          # SUPER ADMIN panel
│   │   ├── presentation/    # Screens, pages
│   │   ├── bloc/            # Panel-specific blocs
│   │   ├── data/            # Repositories, API client, models
│   │   ├── routes/          # platform_router.dart
│   │   ├── providers.dart   # Panel's BlocProvider registrations
│   │   └── theme.dart       # Panel design tokens (extends shared)
│   │
│   ├── factory/             # FACTORY panel (admin + store_keeper + driver)
│   │   ├── admin/
│   │   ├── store_keeper/
│   │   ├── driver/
│   │   ├── routes/          # factory_router.dart
│   │   ├── providers.dart
│   │   └── theme.dart
│   │
│   ├── bus_operations/      # BUS FLEET panel
│   │   ├── presentation/
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── routes/          # bus_router.dart
│   │   ├── providers.dart
│   │   └── theme.dart
│   │
│   ├── goods_operations/    # GOODS/TRUCK panel (own driver + conductor pages)
│   │   ├── presentation/
│   │   │   ├── driver_dashboard_page.dart    # OWN — not importing BUS
│   │   │   └── conductor_dashboard_page.dart # OWN — not importing BUS
│   │   ├── bloc/
│   │   ├── data/
│   │   ├── routes/          # goods_router.dart
│   │   ├── providers.dart
│   │   └── theme.dart
│   │
│   ├── cricket/             # CRICKET panel (already isolated — reference model)
│   │   ├── manager/
│   │   ├── public/
│   │   ├── routes/
│   │   ├── providers.dart
│   │   └── theme.dart
│   │
│   ├── reseller/            # B2B COMMERCE panel (already isolated — reference model)
│   │   ├── routes/          # reseller_router.dart (exists)
│   │   ├── providers.dart
│   │   └── theme.dart
│   │
│   ├── storekeeper/         # STOREKEEPER (shared between BUS + FACTORY? decide)
│   │   ├── routes/
│   │   └── providers.dart
│   │
│   ├── customer/            # CUSTOMER Super-App
│   │   ├── routes/          # customer_router.dart
│   │   └── providers.dart
│   │
│   ├── auth/                # Auth feature (login flows, token management)
│   │   ├── data/
│   │   └── bloc/
│   │
│   └── landing/             # Landing page (already isolated)
│       └── ...
│
├── main.dart                # Thin launcher: Super Admin ONLY
├── main_bus_fleet.dart      # BUS fleet admin ONLY
├── main_bus_owner.dart      # BUS owner ONLY
├── main_bus_driver.dart     # BUS driver ONLY
├── main_bus_conductor.dart  # BUS conductor ONLY
├── main_truck_owner.dart    # GOODS owner ONLY
├── main_truck_driver.dart   # GOODS driver ONLY (own pages, no BUS import)
├── main_truck_conductor.dart# GOODS conductor ONLY (own pages, no BUS import)
├── main_cricket_manager.dart# Cricket manager (reference model)
├── main_cricket_public.dart # Cricket public (reference model)
├── main_reseller.dart       # B2B (reference model)
├── main_driver.dart         # Factory driver (reference model)
└── main_landing.dart        # Landing (reference model)
```

**Dependency rule enforced by CI:**

```
core/ ← shared/ ← features/<panel>/
              ↗
main_<panel>.dart
```

- `core/` depends on nothing in `lib/`.
- `shared/` depends only on `core/`.
- `features/<panel>/` depends on `core/` + `shared/` — **never** on another `features/<other_panel>/`.
- `main_<panel>.dart` depends on exactly one `features/<panel>/` + `shared/` + `core/`.

---


## 5. Professional / High-Standard Additions (Per Panel + Systemic)

The table below lists what each panel (and the system overall) is **missing** and what to **add** to reach a professional, production-grade standard. The isolated panels (cricket, reseller, landing) are the **reference model** — they already get several of these right.

### 5.1 Per-Panel Gaps

| Capability | Current State | Target | Reference |
|---|---|---|---|
| **Widget tests** | Zero across all panels | Per-panel widget test suite covering key screens | — |
| **Bloc tests** | Zero | Per-panel bloc unit tests (state transitions, error handling) | — |
| **Integration tests** | Zero | Per-panel integration test (login → dashboard → key action) | — |
| **CI path filters** | None — all 8 panels rebuild on any `lib/**` change | `paths: lib/features/cricket/**` per-panel workflow triggers | `media-engine-build.yml` (only truly isolated pipeline) |
| **Frontend route guards** | `route_guard_middleware.dart:123-131` returns `null` (unimplemented) | Per-panel guard that validates auth + vertical + feature grants before navigation | — |
| **Backend middleware** | 7 of 10 panel route files have WEAK or NO gate | Per-panel gate middleware mirroring `BusFleetGate`/`CricketManagerAuth` | `bus_fleet.php`, `cricket.php` group 2 |
| **Design tokens** | `#0A0E21` duplicated in 3 places; hardcoded hex at cricket dashboard lines 363, 537, 579, 586, 605 | Single token source (`shared/widgets/design_system/tokens.dart`); per-panel theme extends it; zero hardcoded hex | `CricketColors` (WCAG documented) |
| **Error tracking** | None | Per-panel Sentry project with distinct DSN; panel name in every event tag | — |
| **Analytics** | None visible | Per-panel analytics (mixpanel/posthog) with panel-scoped events | — |
| **Versioning / changelog** | None per panel | Per-panel semver + auto-changelog from conventional commits | — |
| **Accessibility** | Only `CricketColors` documents WCAG ratios | Extend WCAG contrast discipline to ALL panels; automated a11y audit in CI | `cricket_colors.dart:1-8` |
| **Localization** | `assets/translations/` directory is empty (`.gitkeep` only) | Per-panel ARB files; `flutter_localizations`; CI check for missing keys | — |
| **Module documentation** | None per panel | `README.md` inside each `features/<panel>/` describing purpose, routes, blocs, API contract | — |
| **CODEOWNERS** | None | Per-panel directory ownership in `.github/CODEOWNERS` requiring panel-owner review | — |
| **Sub-admin verticals** | Hardcoded `static const _verticals` list of 5 entries (`add_sub_admin_screen.dart:15-48`) | Data-driven verticals from API; dynamic feature grants; backend validates at request time | — |

### 5.2 Systemic Gaps

| Capability | Current State | Target |
|---|---|---|
| **Staging environment** | None — push to `main` = production | Separate staging URL; deploy on PR merge to `main`; promote to prod manually or on tag |
| **Rollback mechanism** | `rsync --delete` with no versioned artifacts | Versioned builds (e.g. `releases/v1.2.3/`); symlink switch for atomic rollback |
| **Secret scanning** | None | `gitleaks` or `trufflehog` in CI; fail on any detected credential |
| **`dart analyze`** | Not in CI | Run on every PR; fail on errors/warnings |
| **`flutter test`** | Not in CI | Run on every PR (once tests exist); fail on any failure |
| **Dependency graph audit** | None | Periodic (weekly) script that walks imports and reports any new cross-panel edge |
| **Contract tests** | None | Per-panel frontend ↔ backend API contract test (e.g. Pact or schema validation) |
| **Build size monitoring** | None | Per-panel web build size tracked; alert on >10% regression |

---

## 6. Preventing One Panel From Breaking Another (Cross-Panel Bug Containment)

This section addresses the specific concern: *how do we guarantee that a change in one panel cannot break another panel?* Today there is no such guarantee — all 8 panels rebuild together, share state, and import each other.

### 6.1 CI Boundary Enforcement

**Mechanism:** `custom_lint` / `import_lint` rules + `dart analyze` in CI.

- Define forbidden import patterns in `analysis_options.yaml`:
  - `lib/shared/**` → `lib/features/**` = ERROR
  - `lib/features/<A>/**` → `lib/features/<B>/**` = ERROR (where A ≠ B)
- A dependency-cruiser script (Dart or Python) walks the full import graph and **fails the CI build** on any violation.
- This runs on every PR — a cross-panel import cannot merge.

**Impact:** No new coupling can be introduced. Existing violations (§3.3) are grandfathered temporarily but tracked as tech-debt tickets that block Phase 2 completion.

### 6.2 Path-Filtered Per-Panel CI/CD

**Mechanism:** GitHub Actions `paths:` filter per panel.

```yaml
# Example: .github/workflows/cricket-deploy.yml
on:
  push:
    branches: [main, mainnew]
    paths:
      - 'lib/features/cricket/**'
      - 'lib/main_cricket_*.dart'
      - 'web/manifest-cricket*.json'
```

**Current problem:** `frontend-deploy.yml` triggers on `lib/**` — a cricket-only change rebuilds all 8 panels, meaning a bug in the cricket build script could block all panels.

**Target:** Each panel has its own workflow (or a matrix strategy with per-panel path filters). A change to `lib/features/bus_operations/**` triggers **only** the BUS deploy. Other panels are untouched.

**Blast-radius containment:** If a panel's build fails, only that panel's deploy is blocked. The other 7 remain at their last-known-good version.

### 6.3 Per-Panel Test Gates

**Mechanism:** Each panel must pass its own test suite before deploy.

- Widget tests: verify key screens render without crash.
- Bloc tests: verify state machine correctness.
- Integration tests: verify login → dashboard → primary action flow.
- Contract tests: verify the panel's API client matches the backend's response schema.

**Current state:** Zero tests (§2.2 O5). Target: every panel has a minimum test gate that runs in its path-filtered CI workflow.

### 6.4 No Shared Mutable Global State

**Mechanism:** Eliminate `core/utils/auth_state.dart` globals; per-panel scoped state only.

- Today: `isAuthenticatedCache` / `isFactoryAuthenticatedCache` / `isAuthCheckCompleted` are mutable globals. A Factory login writes `isFactoryAuthenticatedCache = true`; the Super Admin router redirect reads it.
- Target: each panel's auth state lives inside its own `BlocProvider` tree. No panel can read another panel's auth state because they are in separate widget trees (separate `main_*.dart` entry points).
- For the web (where panels share a browser origin): use compile-time-prefixed storage keys and per-panel `StorageNamespace` injection so keys cannot collide.

### 6.5 Staging + Versioned Artifacts + Blue-Green / Rollback

**Mechanism:** Never deploy directly to production from a push.

| Step | Current | Target |
|---|---|---|
| Build | On push to `main` | On push to `main` → build versioned artifact (`v1.2.3-abc1234/`) |
| Deploy to staging | Does not exist | Automatic deploy to `staging.traceodd.com` |
| Promote to prod | `rsync --delete` directly | Manual or tag-triggered symlink switch |
| Rollback | Impossible (artifacts deleted) | Switch symlink to previous version |

**Blue-green:** Keep two release directories (`current` and `previous`). Deploy writes to a new versioned dir, then atomically switches the nginx `root` symlink. Rollback = switch symlink back.

### 6.6 Secret Scanning

**Mechanism:** `gitleaks` or `trufflehog` in CI.

- Runs on every push/PR.
- Fails the build if any credential pattern is detected (database passwords, API keys, private keys).
- Would have caught `database_config.dart` line 54 (`awan1972`) before it was committed.

### 6.7 CODEOWNERS Review Per Panel

**Mechanism:** `.github/CODEOWNERS` file.

```
# Example CODEOWNERS
lib/features/bus_operations/    @bus-team
lib/features/cricket/           @cricket-team
lib/features/goods_operations/  @goods-team
lib/features/nexa_admin/        @platform-team
lib/shared/                     @platform-team @bus-team @cricket-team
```

- Any PR touching `lib/features/bus_operations/` requires review from `@bus-team`.
- Changes to `lib/shared/` require review from all teams that depend on it.
- Prevents a developer working on one panel from accidentally breaking another.

### 6.8 Periodic Dependency-Graph Audit

**Mechanism:** A scheduled CI job (weekly) that:

1. Walks all Dart imports in `lib/`.
2. Builds a directed graph of panel → panel dependencies.
3. Reports any edge that crosses panel boundaries.
4. Fails if new violations appeared since last audit.
5. Produces a visual graph (Mermaid/DOT) for human review.

This catches re-coupling that slips through (e.g. via a barrel file or re-export).

---

## 7. Security Emergency (P0) — Do First

These items must be resolved **before any architectural refactoring begins**. They represent active security exposure in production.

### 7.1 Remove Plaintext DB Credentials

**Problem:** `lib/**/database_config.dart` contains:
- Lines 6-10: host, port, database, username, password in plaintext.
- Line 54: Postgres **superuser** connection string with password `awan1972` for `135.181.46.27:5444`.
- App password `NexaAppPassword123!` also present.

**Action:**
1. **Immediately rotate** both passwords (`awan1972` and `NexaAppPassword123!`) — treat them as compromised (they are in git history permanently).
2. Remove all credentials from `database_config.dart`.
3. Replace with **build-time environment injection** (`--dart-define=DB_HOST=...`) or **secure storage** (flutter_secure_storage for mobile; server-side env vars for web API calls).
4. The frontend should **never** contain a direct DB connection string. All DB access goes through the Laravel API.

### 7.2 Add Admin Middleware to `super_admin.php`

**Problem:** `backend/routes/panels/super_admin.php` uses only `auth:sanctum` — any authenticated user can potentially reach super-admin endpoints.

**Action:** Add a `super.admin` middleware (or equivalent role check) that verifies the authenticated user has the Super Admin role. Mirror the `BusFleetGate` pattern.

### 7.3 Register `consumer.php` or Remove Dead Customer Surface

**Problem:** `backend/routes/panels/consumer.php` (5 endpoints) is never loaded because `PanelRouteServiceProvider.php` `$panels` array (lines 43-54) omits `'consumer'`. The customer Super-App frontend has routes at `app_router.dart:632-652` pointing to a dead API.

**Action:** Either:
- Add `'consumer'` to the `$panels` array and verify the endpoints work, **or**
- Remove the dead frontend routes (lines 632-652) and the dead `consumer.php` file.

Do not leave unreachable code that gives a false sense of functionality.

### 7.4 Replace Hardcoded `root@IP` in `frontend-deploy.yml`

**Problem:** `frontend-deploy.yml` hardcodes `root@135.181.46.27` at lines 61, 90, 105, 145, 165-166, 185, 200, 214, 229. The server IP is in the repo. `deploy.yml` correctly uses `${{ vars.VPS_HOST }}`.

**Action:**
1. Replace all hardcoded `root@135.181.46.27` with `${{ vars.VPS_HOST }}` (or a GitHub secret).
2. Use SSH key authentication via `${{ secrets.VPS_SSH_KEY }}` — not password.
3. Consider rotating the server's SSH keys since the IP + root user are public in the repo.

### 7.5 Fix `tests.yml` Branch Trigger

**Problem:** `.github/workflows/tests.yml` line 6 triggers on branch `master`, but deploys run from `main`/`mainnew`. Backend tests never execute on deploy branches.

**Action:** Change the trigger to `main` and `mainnew` (matching `deploy.yml` and `frontend-deploy.yml`).

### 7.6 Fix `goods_fleet.php` and `truck_fleet.php` Middleware

**Problem:**
- `goods_fleet.php:29` uses `auth:admin` — any admin of any vertical can access goods endpoints.
- `truck_fleet.php:20` uses only `auth:sanctum` — any authenticated user can access truck logistics.

**Action:** Add panel-specific gate middleware (`goods.fleet`, `truck.fleet`) that validates the user's vertical assignment, mirroring `BusFleetGate`.

---


## 8. Recommended Phased Roadmap

This roadmap is **corrected and dependency-ordered**. It supersedes the plan's phase order where they conflict. The critical insight: **layering + enforcement must precede the router split** — splitting first just re-mixes the same coupled code across more files without actually decoupling anything.

### Why Layering + Enforcement Must Come First

The plan proposes Phase 2 = "router split". But today:

- `missile_3d_button.dart` (BUS) is imported by CRICKET, SUPER, and `shared/`.
- BUS `fleet_dashboard_page` imports 4 SUPER screens; SUPER imports 2 BUS widgets (circular).
- `main_truck_driver.dart` imports BUS pages verbatim.
- `app_providers.dart` globally registers ALL panels' blocs.
- `auth_state.dart` globals are read cross-panel.

If you split the router now, you get 7 router files that still import each other's panels. The coupling is unchanged — you've just made it harder to see. **Fix the dependency graph first, lock it with CI enforcement, then split.**

### Phase 0 — Security Emergency (P0)

**Duration:** 1-2 days. **Blocker for all other phases.**

| # | Action | File(s) |
|---|---|---|
| 0.1 | Rotate compromised passwords (`awan1972`, `NexaAppPassword123!`) | Database server |
| 0.2 | Remove plaintext credentials from frontend; use `--dart-define` or secure storage | `lib/**/database_config.dart` |
| 0.3 | Add admin middleware to `super_admin.php` | `backend/routes/panels/super_admin.php` |
| 0.4 | Register `consumer.php` in provider OR remove dead customer routes | `backend/app/Providers/PanelRouteServiceProvider.php:43-54`; `app_router.dart:632-652` |
| 0.5 | Replace hardcoded `root@135.181.46.27` with `${{ vars.VPS_HOST }}` | `.github/workflows/frontend-deploy.yml` (lines 61, 90, 105, 145, 165-166, 185, 200, 214, 229) |
| 0.6 | Fix `tests.yml` branch trigger: `master` → `main`, `mainnew` | `.github/workflows/tests.yml:6` |
| 0.7 | Add `goods.fleet` gate to `goods_fleet.php`; add `truck.fleet` gate to `truck_fleet.php` | `backend/routes/panels/goods_fleet.php:29`; `backend/routes/panels/truck_fleet.php:20` |

### Phase 1 — Break Layering Violations (P1)

**Duration:** 3-5 days. **Must complete before Phase 2.**

| # | Action | File(s) |
|---|---|---|
| 1.1 | Move `missile_3d_button.dart` from `features/bus_operations/presentation/widgets/` to `lib/shared/widgets/` | Update 5 import sites across 4 panels |
| 1.2 | Move `bus_tracking_models.dart` to `shared/models/` (or move telemetry bloc into BUS) | `lib/shared/bloc/telemetry_tracking/telemetry_models.dart:6` |
| 1.3 | Extract `panel_auth_repository` + `panel_auth_bloc` imports out of `shared/` into a shared auth contract | `lib/shared/utils/fleet_bloc_setup.dart:10-11`; `lib/shared/widgets/fleet_bloc_login_screen.dart:20-23` |
| 1.4 | Break SUPER↔BUS cycle: extract 4 fleet screens (`route_scheduler`, `ticket_management`, `voucher_management`, `bonus_management`) to `lib/shared/fleet/` | BUS `fleet_dashboard_page.dart:19-22`; SUPER `bus_fleet_dashboard_screen.dart:26-27` |
| 1.5 | Create OWN driver/conductor pages in `goods_operations`; remove BUS page imports | `main_truck_driver.dart:6`; `main_truck_conductor.dart:6` |
| 1.6 | Split `app_providers.dart` (284 lines) into per-panel provider modules | `core/providers/app_providers.dart` |
| 1.7 | Replace `auth_state.dart` globals with per-panel scoped auth state | `core/utils/auth_state.dart` |
| 1.8 | Implement `route_guard_middleware.dart` (currently returns `null`) | `:123-131` |
| 1.9 | Remove storekeeper import from `main_bus_fleet.dart` (or move storekeeper to shared if genuinely shared) | `main_bus_fleet.dart:16` |

### Phase 2 — Lock Boundaries With CI Enforcement (P1)

**Duration:** 2-3 days. **Must complete before Phase 3.**

| # | Action | File(s) |
|---|---|---|
| 2.1 | Add `custom_lint` / `import_lint` package; define forbidden-import rules | `pubspec.yaml`; `analysis_options.yaml` |
| 2.2 | Add dependency-cruiser script that fails on cross-panel imports | `.scripts/check-imports.dart` (new) |
| 2.3 | Add `dart analyze` step to CI (all workflows) | `.github/workflows/frontend-deploy.yml` or a new `flutter-ci.yml` |
| 2.4 | Add secret scanning (`gitleaks`) to CI | New workflow or step in existing |
| 2.5 | Add path filters per panel to `frontend-deploy.yml` (or split into per-panel workflows) | `.github/workflows/frontend-deploy.yml` |
| 2.6 | Add `.github/CODEOWNERS` with per-panel directory ownership | New file |
| 2.7 | Verify: all Phase 1 changes pass the new lint rules with zero violations | CI green |

### Phase 3 — Split the Mega-Router (P2)

**Duration:** 3-5 days. **Safe only after Phases 1-2.**

| # | Action | File(s) |
|---|---|---|
| 3.1 | Create per-panel router files using the **corrected** line map (§4.3) | New files: `platform_router.dart`, `bus_router.dart`, `goods_router.dart`, `cricket_router.dart`, `factory_router.dart`, `b2b_router.dart`, `customer_router.dart` |
| 3.2 | Reduce `main.dart` to a thin Super Admin launcher (own router + own providers only) | `lib/main.dart` |
| 3.3 | Update all other `main_*.dart` to use their panel's router | 12 entry points |
| 3.4 | Delete `lib/routes/app_router.dart` (the 1142-line monolith) | — |
| 3.5 | Fix redirect logic: remove unguarded `/sub-admin/*` and `/bus-fleet/*` bypasses; remove non-web Factory root redirect | Previously lines 240, 250-253, 255-258 |
| 3.6 | Verify: each panel builds and deploys independently | CI green per panel |

### Phase 4 — Complete Backend Route Separation (P2)

**Duration:** 5-7 days.

| # | Action | File(s) |
|---|---|---|
| 4.1 | Migrate remaining routes from `api.php` (986 lines) into per-panel files | `backend/routes/api.php` → `backend/routes/panels/*.php` |
| 4.2 | Add per-panel gate middleware for ALL panels (see §4.9 table) | New middleware classes |
| 4.3 | Enhance `SubAdminMiddleware` to validate vertical + feature grants (not just `exists()`) | `backend/app/Http/Middleware/SubAdminMiddleware.php:59-69` |
| 4.4 | Apply `sub.admin` middleware to ALL sub-admin routes (currently used once) | All panel route files |
| 4.5 | Add backend integration tests per panel | `backend/tests/Feature/Panels/` |
| 4.6 | Verify: each panel's API group is accessible only with correct credentials + vertical | Manual + automated |

### Phase 5 — Per-Panel CI/CD + Staging + Rollback + Tests (P1/P2)

**Duration:** 5-7 days.

| # | Action | File(s) |
|---|---|---|
| 5.1 | Create staging environment (separate URL or subdomain) | Infrastructure + nginx config |
| 5.2 | Implement versioned artifact builds (no more `rsync --delete` without backup) | `.github/workflows/frontend-deploy.yml`; `.github/workflows/deploy.yml` |
| 5.3 | Implement blue-green deploy with symlink switch + rollback command | Deploy scripts |
| 5.4 | Write per-panel Flutter tests (widget + bloc + integration) | `test/features/<panel>/` |
| 5.5 | Add `flutter test` to CI (per-panel path-filtered) | CI workflows |
| 5.6 | Add contract tests (frontend API client ↔ backend response schema) | Per panel |
| 5.7 | Add per-panel Sentry project with distinct DSN | `main_*.dart` initialization |
| 5.8 | Document each panel: `features/<panel>/README.md` | Per panel |

### Phase 6 — Design-System Consolidation + Data-Driven Verticals (P3)

**Duration:** 3-5 days.

| # | Action | File(s) |
|---|---|---|
| 6.1 | Create single design-token source (`shared/widgets/design_system/tokens.dart`) | New file |
| 6.2 | Remove duplicate `#0A0E21` from `CricketColors:16`, `LandingPalette:15`, `TraceOddBrandTokens:27` — all extend the single token | 3 files |
| 6.3 | Replace hardcoded hex in cricket manager dashboard (lines 363, 537, 579, 586, 605) with tokens | Cricket dashboard |
| 6.4 | Extend WCAG contrast documentation to ALL panels (following `CricketColors` standard) | Per-panel `theme.dart` |
| 6.5 | Make sub-admin verticals data-driven: fetch from API instead of `static const _verticals` | `add_sub_admin_screen.dart:15-48`; new API endpoint |
| 6.6 | Populate `assets/translations/` with per-panel ARB files | `assets/translations/` |
| 6.7 | Add automated accessibility audit to CI | CI workflow |

---

## 9. Quick-Win Checklist

Highest-value, lowest-risk actions that can be done immediately (many in under an hour each):

- [ ] **Rotate compromised passwords** (`awan1972`, `NexaAppPassword123!`) — they are in git history permanently.
- [ ] **Remove plaintext DB credentials** from `lib/**/database_config.dart` — the frontend should never have a direct DB connection string.
- [ ] **Fix `tests.yml` branch** — change line 6 from `master` to `[main, mainnew]` (one-line fix; backend tests start running immediately).
- [ ] **Add `'consumer'` to `PanelRouteServiceProvider.php` `$panels` array** (line ~50) — or delete `consumer.php` + customer routes. Either way, remove the dead code.
- [ ] **Add admin middleware to `super_admin.php`** — mirror `BusFleetGate` pattern.
- [ ] **Replace hardcoded `root@135.181.46.27`** in `frontend-deploy.yml` with `${{ vars.VPS_HOST }}` — consistency with `deploy.yml`.
- [ ] **Add `dart analyze` to CI** — a single step in `frontend-deploy.yml` that catches type/lint errors before deploy.
- [ ] **Add `gitleaks` secret scanning to CI** — prevents future credential commits.
- [ ] **Move `missile_3d_button.dart`** from `features/bus_operations/presentation/widgets/` to `lib/shared/widgets/` — unblocks 4 panels (update 5 import paths).
- [ ] **Add `.github/CODEOWNERS`** — per-panel directory ownership requiring review.
- [ ] **Add path filters** to `frontend-deploy.yml` per panel (or split into per-panel workflows) — stops all-or-nothing rebuilds.
- [ ] **Write ONE real Flutter test** (replace the 17-line `SizedBox` placeholder) — proves the test infrastructure works and sets the pattern.
- [ ] **Document the corrected route line map** in `PANEL-SEPARATION-PLAN.md` §7 — replace E3/E4/E5 ranges with the verified ranges from §3.2 of this document.

---

## 10. Appendix: Evidence Index

Compact reference table of key `file:line` citations used throughout this document.

| Evidence ID | File Path | Line(s) | What It Shows |
|---|---|---|---|
| Router size | `lib/routes/app_router.dart` | (total) | 1142 lines — the single mega-router |
| SUPER routes | `lib/routes/app_router.dart` | 321-326 | Super Admin route definitions |
| FACTORY routes | `lib/routes/app_router.dart` | 327-331 | Factory login route |
| BUS routes | `lib/routes/app_router.dart` | 332-336 | BUS fleet route definitions |
| GOODS routes | `lib/routes/app_router.dart` | 337-341 | GOODS fleet route definitions |
| SUB-ADMIN routes | `lib/routes/app_router.dart` | 342-351 | Sub-admin route definitions |
| CRICKET admin | `lib/routes/app_router.dart` | 352-369 | Cricket admin routes |
| CRICKET manager | `lib/routes/app_router.dart` | 370-486 | Cricket manager routes |
| BUS owner/driver/conductor | `lib/routes/app_router.dart` | 487-527 | BUS sub-role routes |
| GOODS truck | `lib/routes/app_router.dart` | 528-568 | GOODS truck routes |
| GOODS fleet dash | `lib/routes/app_router.dart` | 569-599 | GOODS fleet dashboard routes |
| BUS fleet dash | `lib/routes/app_router.dart` | 600-631 | BUS fleet dashboard routes |
| CUSTOMER routes | `lib/routes/app_router.dart` | 632-652 | Customer Super-App routes (dead API) |
| SUPER shell | `lib/routes/app_router.dart` | 653-792 | Super Admin shell/layout routes |
| Reseller admin (real) | `lib/routes/app_router.dart` | 760-769 | `/resellers`, `/resellers/add` — the actual B2B routes |
| FACTORY shell | `lib/routes/app_router.dart` | 793-1075 | Factory shell/layout routes |
| Redirect: sub-admin bypass | `lib/routes/app_router.dart` | 255-258 | All `/sub-admin/*` return null — no guard |
| Redirect: bus-fleet bypass | `lib/routes/app_router.dart` | 250-253 | All `/bus-fleet/*` return null — no guard |
| Redirect: non-web root | `lib/routes/app_router.dart` | 240 | Redirects to `/factory/store-keeper/login` |
| Redirect: reseller bypass | `lib/routes/app_router.dart` | 247-249 | `startsWith('/reseller') return null` |
| Error-builder text | `lib/routes/app_router.dart` | 153-163 | "Reseller App is deployed separately" — NOT a route |
| _safeRedirect logic | `lib/routes/app_router.dart` | 203-234 | Redirect logic — NOT route definitions |
| Public-route bypass | `lib/routes/app_router.dart` | 244-246 | Public route bypass — NOT factory routes |
| Overlapping range | `lib/routes/app_router.dart` | 263-281 | Assigned to BOTH bus and goods in plan (E5) |
| Shared → BUS | `lib/shared/widgets/navigation/admin_sidebar.dart` | :4 | Imports `missile_3d_button` from bus_operations |
| Shared → BUS models | `lib/shared/bloc/telemetry_tracking/telemetry_models.dart` | :6 | Imports `bus_tracking_models` |
| Shared → auth | `lib/shared/utils/fleet_bloc_setup.dart` | :10-11 | Imports `panel_auth_repository`, `panel_auth_bloc` |
| Shared → auth | `lib/shared/widgets/fleet_bloc_login_screen.dart` | :20-23 | Imports auth repository, bloc, event, state |
| CRICKET → BUS | `manager_dashboard_page.dart` | :33 | Imports `missile_3d_button` |
| BUS → SUPER (cycle) | `fleet_dashboard_page.dart` | :19-22 | Imports 4 SUPER screens |
| SUPER → BUS (cycle) | `bus_fleet_dashboard_screen.dart` | :26-27 | Imports `missile_3d_button`, `fleet_dispatch_dialog` |
| SUPER → BUS | `sub_admin_dashboard.dart` | :16 | Imports `missile_3d_button` |
| GOODS → BUS | `main_truck_driver.dart` | :6 | Imports BUS `driver_dashboard_page` |
| GOODS → BUS | `main_truck_conductor.dart` | :6 | Imports BUS `conductor_dashboard_page` |
| BUS → STOREKEEPER | `main_bus_fleet.dart` | :16 | Imports `storekeeper_dashboard_screen` |
| Global providers | `core/providers/app_providers.dart` | (total) | 284 lines, 59 imports — registers ALL panels |
| Global auth state | `core/utils/auth_state.dart` | — | Mutable globals: `isAuthenticatedCache`, `isFactoryAuthenticatedCache`, `isAuthCheckCompleted` |
| Route guard (inert) | `route_guard_middleware.dart` | :123-131 | Returns `null` — unimplemented |
| Sub-admin dashboard fallthrough | `sub_admin_dashboard.dart` | :167-176 | Falls through to `_busDashboard()` |
| Consumer dead | `backend/routes/panels/consumer.php` | (all) | 5 endpoints never loaded |
| Provider omits consumer | `backend/app/Providers/PanelRouteServiceProvider.php` | :43-54 | `$panels` array missing `'consumer'` |
| Goods weak gate | `backend/routes/panels/goods_fleet.php` | :29 | `auth:admin` — any admin |
| Truck weak gate | `backend/routes/panels/truck_fleet.php` | :20 | `auth:sanctum` only |
| Super admin no gate | `backend/routes/panels/super_admin.php` | — | `auth:sanctum` only — NO admin middleware |
| SubAdmin weak check | `backend/app/Http/Middleware/SubAdminMiddleware.php` | :59-69 | Only `->exists()`, no vertical/grant validation |
| sub.admin used once | `backend/routes/panels/cricket.php` | :248 | Only usage of `sub.admin` middleware |
| Tests wrong branch | `.github/workflows/tests.yml` | :6 | Triggers on `master`, not `main`/`mainnew` |
| Hardcoded IP | `.github/workflows/frontend-deploy.yml` | :61,90,105,145,165-166,185,200,214,229 | `root@135.181.46.27` |
| DB credentials | `lib/**/database_config.dart` | :6-10, :54 | Plaintext host/port/db/user/pass; superuser string with `awan1972` |
| App password | `lib/**/database_config.dart` | — | `NexaAppPassword123!` present |
| api.php monolith | `backend/routes/api.php` | (total) | 986 lines mixing all panels |
| Initializer size | `lib/core/**/app_initializer.dart` | (total) | 281 lines |
| Token duplication | `cricket_colors.dart:16`, `LandingPalette:15`, `TraceOddBrandTokens:27` | — | `#0A0E21` in 3 places |
| Hardcoded hex | Cricket manager dashboard | :363,537,579,586,605 | Colors not using tokens |
| WCAG good standard | `cricket_colors.dart` | :1-8 | Documents contrast ratios |
| Hardcoded verticals | `add_sub_admin_screen.dart` | :15-48 | `static const _verticals` list of 5 |
| Placeholder test | `test/widget_test.dart` | (total) | 17 lines, tests a `SizedBox` |
| Translations empty | `assets/translations/` | — | Only `.gitkeep` |

---

*End of document. This file is advisory — no code was modified during its production.*
