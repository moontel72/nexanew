# PANEL SEPARATION PLAN — traceodd.com

**Status:** planning document. No code changed yet.
**Read with:** `docs/handoff/FAULT-REMEDIATION-HISTORY.md` (separate scope: GStreamer faults).

**Process:** this plan is finalised first, then shared with the Qoder expert agent, who
will independently scan the project and record their own advice in a separate `.md`
(the request is in `docs/handoff/REVIEW-REQUEST-FOR-QODER.md`).
Coding starts only after both are compared.

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
| **B5** | **`missile_3d_button` is the de-facto design identity but lives in BUS.** Used by BUS, CRICKET, SUPER ×2, **and `shared/`'s admin sidebar**. BUS cannot move until it is promoted. | `bus_operations/presentation/widgets/missile_3d_button.dart` |
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
| `core/services/{payment_service,subscription_validator,supabase_chat_service,multi_tenant_service,code_generator_service}.dart`, `core/constants/{fleet_constants,plan_limits}.dart` | class defined, never constructed | DELETE |
| 7 `nexa_admin` billing screens + `dunning_alert_widget` + 3 billing usecases | unrouted, 4 are literal placeholder stubs | DELETE |
| 6 `bus_operations` pages (`route_list/editor/detail`, `ticket_vault`, `driver_trip`, `live_bus_tracking`) + `qr_code_painter`, `driver_gps_beacon` | never routed or referenced | DELETE |
| ~24 UNUSED widgets under `lib/shared/` (incl. `app_decorations.dart`, `main_app_bar.dart`, `search_app_bar.dart`, `icon_button.dart`, 4 card types, dialogs) | 0 importers | DELETE (or adopt — see B11) |

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

## 7. Phase 1 reference — the router split

`lib/routes/app_router.dart` (1141 lines) splits by these line ranges:

| New file | Lines | Serves |
|---|---|---|
| `lib/routes/app_router.dart` (kept) | 1–202, 320–321, 1078, 1140 | shell + guard chain |
| `super_routes.dart` | 322–326, 342–351, 653–792, 287–317 | SUPER |
| `factory_routes.dart` | 327–331, 793–935, 936–1075, 203–234, 244–246 | FACTORY |
| `cricket_routes.dart` | 352–369, 370–486, 259–262 | CRICKET |
| `bus_routes.dart` | 332–336, 487–527, 600–631, 250–253, 263–281 | BUS |
| `goods_routes.dart` | 337–341, 528–568, 569–599, 282–283, 263–281 | GOODS |
| `customer_routes.dart` | 632–652, 284–285 | CUSTOMER |
| `b2b_routes.dart` | 247–249, 153–163 | B2B |

Also move the `goTo*()` helpers (1081–1138) beside their department's routes.
**No route path, widget or redirect logic changes — location only.**

---

## 8. Phases

### Working method: separate → verify → LOCK, one department at a time

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

Without step 4 the same class of bug returns: the owner has already lost tested work twice
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

### Phase 0 — Safety net + emergency security

#### The `database_config.dart` issue, explained plainly

`lib/core/config/database_config.dart` is a **Flutter (client-side) file** that contains the
**PostgreSQL server's address, port, database name, username and password**:

```
host 135.181.46.27 · port 5444 · db nexasystem_db
user nexa_app · password NexaAppPassword123!
and a second string: postgresql://postgres:awan1972@135.181.46.27:5444/...
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
- The second string is a **`postgres` superuser** credential — the most privileged account on
  the database — and it also reveals a **non-standard port (5444)**, which is exactly the kind
  of thing an attacker uses to find an exposed database.

**What to do:**

1. **Delete the file** (it is dead code; nothing breaks).
2. On the Hetzner server, check whether those two roles still exist and whether PostgreSQL
   accepts **external** connections on 5444. If yes:
   - **rotate both passwords**, and
   - restrict `pg_hba.conf` / the firewall so the database is not reachable from the internet.
3. If PostgreSQL is genuinely no longer used at all (everything moved to the app), then the
   passwords no longer matter — **but step 2 is how you confirm that**, rather than assuming.

This is cheap to check and expensive to get wrong. It is listed first because it is the only
item in this plan with a security consequence.

#### Baseline
1. **Rotate the database password** and delete `core/config/database_config.dart`.
2. Record the current working state **per panel** (URL, login works?, screens verified) as
   `docs/handoff/PANEL-BASELINE-STATE.md`, plus the current `nginx -T` and server listings.
3. Verify each existing panel's build before touching anything.

**Exit:** a written baseline to diff every later phase against.

### Phase 1 — Router extraction (behaviour-preserving)
Split `app_router.dart` per §7. `AppRouter` keeps composing the parts, so `main.dart` is
untouched. **One commit.** **Exit:** every working panel still works; file under ~250 lines.

### Phase 2 — Fix the layering (behaviour-preserving)
1. **Promote `missile_3d_button`** out of BUS into `lib/shared/widgets/buttons/` — this fixes
   B5 *and* is the single highest-value step toward the owner's "same design everywhere".
2. Break the other three `shared → features` edges (B4).
3. **Rule enforced from here on:** `lib/shared/**` must import **zero** `lib/features/**`.

**Exit:** a grep proves no `shared → features` import remains.

### Phase 3 — Design system consolidation
1. Promote the shared primitives that are trapped in features (B11, incl. the 3 parallel KPI
   cards and the BUS `_pencil()` dashboard style).
2. Converge the 4 theme roots onto one; adopt or delete `app_decorations.dart`.
3. Introduce **spacing / radius / icon tokens** — they do not exist today.
4. Retire inline literals as files are touched (not as one big commit).

**Exit:** every panel renders from one theme + one token set.

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
2. **Enforce the grants at request time.** Today `SubAdminMiddleware.php:57-69` checks only
   that an assignment *exists* — it never checks *which* features were granted, and
   `sub_admin_feature_grants` is never consulted on a request. This is the step that
   actually makes isolation real.
3. **Give every sub-admin its own dashboard.** Today only `cricket_ops` gets a distinct
   view; the other verticals all fall through to the **bus** console
   (`sub_admin_dashboard.dart:167-176`). The dashboard must be assembled from the granted
   features, not from a vertical switch.
4. Fix the 4 Flutter↔backend endpoint mismatches (`toggle-status`, `change-vertical`,
   `reset-password`, `restore`).
5. One API prefix + guard per department (`/api/v1/bus/…`, `/api/v1/goods/…`, …).
6. **Design the free-agent driver identity** (D1): a driver belongs to Trace Odd, not to a
   company; company association is a time-bounded `link`. Bus↔truck continuity lives in the
   **backend identity service**, never in shared Flutter code.
7. Unify the 5 auth stacks (B9) behind one interface.

**Exit:** a sub-admin created with only "goods" toggles enabled can reach goods surfaces and
**nothing else** — verified by attempting a bus route with that account and getting a denial.

### Phase 7 — Duplicate consolidation
Complete §6. Safe after departments are separate, because each duplicate then has exactly
one owner and deleting the wrong one is detectable.

### Phase 8 — Server separation
Only possible because Phase 6 made coupling API-only.
Move the **stateful media engine first**; then API; then frontend (which is trivial).
Add a load balancer + stateless app servers when the API is the bottleneck.

---

## 9. Hard rules

1. **Never move two departments in one commit.**
2. **Never change a route path and a folder in the same commit.**
3. **`lib/shared/` must never import `lib/features/`.**
4. **A widget used by 2+ departments belongs in `shared/`, not in either department.**
5. **Verify against the Phase-0 baseline after every phase.**
6. **Do not create `lib/features/fleet/{owner,driver,conductor}/`** — rejected in D1.
7. **The spec contradicts this plan** on fleet unification (it mandates `main_fleet_*.dart`
   and marks `main_driver.dart`/`main_reseller.dart` as deleted — none of which matches the
   code or the owner's requirement). Follow the owner; the spec needs a correction pass.

---

## 10. Open questions for the Qoder expert

1. Is staged server separation (§5) right, or should the media engine and API split sooner?
2. Sub-Admin enforcement (§6.1) — is middleware the right layer, or should grants be checked
   per-controller?
3. Any objection to the deletion list in §6?
4. Is one theme + token set (Phase 3) achievable without breaking the working panels?
5. The **free-agent driver identity** (D1) — best backend shape for a bus↔truck↔company
   link that preserves history?
6. Does the Cricket group need its own module record in the spec (it has none)?
