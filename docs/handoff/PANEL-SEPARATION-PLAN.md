# PANEL SEPARATION PLAN — traceodd.com

**Status:** planning document. No code changed yet.
**Read with:** `docs/handoff/FAULT-REMEDIATION-HISTORY.md` (separate scope: GStreamer faults).
**Updated 2026-09-24:** §11–§16 added from the ecosystem audit — the numbered panel registry,
the per-surface architecture standard (BLoC vs native), the verified native/Rust layer state,
the corrected risk register, the pillars tracked outside this plan, and the **verified
developer-environment diagnosis** (Dart fixed; YAML blocked on the machine's Node v26 — see §16).
**Nothing already in this file was removed.** §11 is now the counting authority for
app/panel numbers; it supersedes the informal "18 panels" figure and the spec's "15 modules".
**Governance:** this file remains the master. `NEXATRACE_SUPREME_MASTER_SPEC.md` is the legacy
base and now carries a correction notice; see §11 and plan hard rule 8.

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

### The 9 groups *(Group 8 added 2026-09-24; Group 9 added 2026-09-26 — see §11)*

| Group | Contents | Current folders |
|---|---|---|
| **1 — Platform** | Super Admin + all Sub-Admin panels + **Universal Customer** app (scan any factory's product; buy/book/track bus tickets; track goods parcels; track own vehicle-security device) | `lib/features/nexa_admin/`, `lib/main.dart`; live customer screen currently lives in `bus_operations/` |
| **2 — B2B Commerce** | **One group, three separate sub-apps with their own names and login pages:** B2B Marketplace · Reseller panel · Shopkeeper panel. Factories, resellers/wholesalers and shopkeepers all buy **and** sell. A reseller may be linked to **many factories at once**; same for a shopkeeper. | `lib/features/reseller/` (misnamed) |
| **3 — Factory** | Factory Admin + Store Keeper + Driver — **factory employees**, factory logo | `lib/features/factory/{admin,store_keeper,driver}/`, `lib/main_driver.dart` |
| **4 — Bus Fleet** | Bus Fleet Admin + Bus Store Keeper + third-party Bus Owner app + Bus Driver + Bus Conductor | `lib/features/bus_operations/`, `lib/features/storekeeper/`, `lib/main_bus_*.dart` |
| **5 — Goods / Truck** | Goods Company Admin + Goods Store Keeper + third-party Truck Owner + Truck Driver + Truck Conductor | `lib/features/goods_operations/`, `lib/main_truck_*.dart` |
| **6 — Cricket** | Todd Studio + Cricket Manager + Todd Broadcaster (field cameras) + Public Viewer screen | `lib/features/cricket/`, `lib/main_cricket_*.dart`, `media-engine/` |
| **7 — Vehicle Security** | Nothing exists yet | — |
| **8 — Trust & Safety** | **NEW (2026-09-24, §11)** — Jaali / Asli / Naqli note panel (**#25**). Future home for trust/verification surfaces | — |
| **9 — Marketing & Growth** | **NEW (2026-09-26)** — a 4-level field hierarchy (Marketing Sub-Admin → District Marketing Administrator ×4–5 → District Marketing Manager → Marketing Agent) that markets **every** group. Each level has its **own app**. Managers also **onboard clients** (register bus-fleet/factory accounts, upload documents, train them) which is how commission is attributed. Per-agent compensation: salary · salary+commission · commission-only. **Detail: `docs/handoff/GROUP-INCHARGE-MODEL.md` §1.4.** Its own frontend + backend + database, own server later | — |

> Group 8 is a **surface group**; whether it also becomes a separate server/department is decided in
> Phase 8. §5's server strategy still says "7" because it counts current departments.

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
| 1 | **CI boundary enforcement** — `.scripts/check-panel-isolation.mjs`, run by `.github/workflows/panel-isolation.yml`; **fails the build** on `shared → features`, `features/A → features/B`, and `core → shared/features` | stops new coupling merging. Documented rules get broken; enforced ones do not. **✅ DONE 2026-09-25 (`ca591a98`).** The gate is **statement-level**, so a brand-new file cannot start crossing an already-tracked boundary; verified by adding a deliberate violation and confirming a non-zero exit. Measured progress: **84 → 77** (dead-code deletions) → **28** (§15b provider split). **28 remain**, all tracked in `.scripts/panel-isolation-baseline.json` |
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
| `lib/features/transport/**` (8 files) | 0 importers anywhere; no route; no `main_*.dart`; no CI target | **✅ DELETED 2026-09-25** |
| `lib/features/transport_marketplace/**` | Only importer is the dead `transport/` bloc. The **live** `/transport/marketplace` route points at `nexa_admin/…/TransportMarketplaceAdminScreen`, not this folder | **✅ DELETED 2026-09-25** |
| `lib/features/broadcaster/data/services/whip_client.dart` | 0 importers **in `lib/`** — but it **has a test** (`test/features/broadcaster/whip_client_test.dart`). This row originally missed that, so the file is **not** unreferenced. WHIP ingest is done by the Rust engine, not this class | **KEPT 2026-09-25** — deleting tested code is an owner decision. Either remove file + test together, or keep both |
| `lib/features/universal/customer/**` (8 files) | 0 external importers, no route. **Duplicate of the LIVE customer app** | **MERGE → then delete** (see below) |
| `core/navigation/router_integration.dart`, `core/di/panel_bloc_providers.dart`, `core/providers/panel_provider_binder.dart`, `core/bootstrap/app_bootstrapper.dart` | 0 importers | **✅ DELETED 2026-09-25** — verified two ways: no file path (package: or relative) and no class name (`PanelBlocProviders`, `RouterIntegration`, `PanelProviderBinder`, `AppBootstrapper`) is referenced anywhere in the repo |
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
| `super_admin/bus_fleet_dashboard_screen.dart`, `super_admin/bus_fleet/**`, `bus_company_login_screen` | **BUS** |
| **`super_admin/companies/bus_companies_list_screen.dart` + `add_bus_company_screen.dart`** | ⚠️ **DELETE, not move** — see note below |
| `super_admin/goods_fleet_dashboard_screen.dart`, `super_admin/goods_fleet/**`, `goods_company_login_screen` | **GOODS** |
| **`super_admin/companies/goods_companies_list_screen.dart` + `add_goods_company_screen.dart`** | ⚠️ **DELETE, not move** — see note below |
| `super_admin/transport/**` (wallet, marketplace admin, drivers, fraud), `super_admin/reseller_management/**`, `bloc/{transport_admin,reseller_management}` | **B2B** |
| `sub_admin/cricket/**` (manager CRUD) | **CRICKET** |
| `sub_admin/{sub_admin_list_screen,add_sub_admin_screen}` | **stay** (platform) |
| `super_admin/{dashboard,login,shell}`, `site_content/`, `plans/**`, `billing/**`, `companies/**` (registry), `data/**`, `domain/**`, `presentation/bloc/{auth,billing,invoices,plans,companies,dashboard}` | **stay** (platform) |

> **⚠️ Duplicate company-registration path — verified 2026-09-26, still present.**
>
> The owner reported that bus-fleet companies should be registered by the **Bus-Fleet Sub-Admin**, not the
> Super Admin — and that an earlier agent said it had been moved but **never removed the Super Admin
> side**. That is correct, and the Super Admin side is still live:
>
> | Still on the Super Admin side | Evidence |
> |---|---|
> | `/bus-companies` → `BusCompaniesListScreen` | `app_router.dart:695-698` |
> | `/bus-companies/add` → `AddBusCompanyScreen` | `app_router.dart:699-705` |
> | `/goods-companies` → `GoodsCompaniesListScreen` | `app_router.dart:709-712` |
> | `/goods-companies/add` → `AddGoodsCompanyScreen` | `app_router.dart:713-719` |
>
> **The Sub-Admin panel already owns this completely** — `SubAdminBloc` performs **full CRUD** against
> `/api/v1/admin/bus-companies/*`: `create`, list, `{id}/status` (patch), `{id}` (put), `{id}` (delete),
> `{id}/restore`. Its dashboard has the *Add Bus Company* action and the registered-companies list inline.
> So the Super Admin screens are a **strict subset duplicate** — nothing is lost by removing them.
>
> **✅ REMOVED 2026-09-26 — commit `126f618d`.** The duplicate Super Admin company-registration path
> is gone: 4 screen files deleted, 2 `GoRoute` blocks, 4 unused `goTo*` helpers and 4 imports removed,
> the *Goods Fleet* sidebar section removed, the `/goods-companies` title + breadcrumb branches removed,
> and the 2 dashboard quick-action tiles removed. **2,346 lines deleted.** Verified: zero dangling
> references, `dart analyze` clean on all 3 changed files, isolation guard green.
>
> The nav-link check (below) was the piece that made this safe — done first, as asked.
>
> | Where | What | Action |
> |---|---|---|
> | `app_router.dart:695-705` | `GoRoute` `/bus-companies` + `/bus-companies/add` | ✅ removed |
> | `app_router.dart:709-719` | `GoRoute` `/goods-companies` + `/goods-companies/add` | ✅ removed |
> | `app_router.dart` imports (4) | the four screens | ✅ removed |
> | `app_router.dart:1132-1143` | the four `goTo*` helpers (the two `Add*` helpers had **no callers**) | ✅ removed |
> | `super_admin_shell.dart:124-139` | the whole *Goods Fleet* sidebar section | ✅ removed |
> | `super_admin_shell.dart:240-242` | `_titleForLocation` branches | ✅ removed |
> | `super_admin_shell.dart:275-280` | breadcrumb branches | ✅ removed |
> | `super_admin/dashboard_screen.dart:1098-1113` | the two quick-action `ListTile`s | ✅ removed |
> | 4 screen files | bus/goods list + add screens | ✅ deleted |
>
> **Execution order used (keep this for any similar removal):** entry points first, then routes, then
> files. ⚠️ The reverse order crashes — `go_router` throws when navigating to an unknown route, so
> removing a route while a link to it still exists produces a visible crash instead of a tidy removal.
> Each step above left the tree consistent, so a stop mid-way would not have broken the app.
>
> **Still to check:** whether `CompanyRegisterBloc` is used only by the two deleted *add* screens.
>
> **Data note:** `admin_users` holds an `admin@nexatrace.local` (super_admin) plus **three
> `company_admin` rows** (`armi@gmail.com` "Organization", `aziz@gmail.com` "Awan Express Admin",
> `khan@gmail.com` "Ahmed Khan") — these look like the legacy registrations made through the Super Admin
> path. Whether to delete them is a **data decision for the owner**. The owner's ruling (2026-09-26):
> **suspend, do not delete** — accounts and data can be removed manually from inside each panel by
> whoever wants to, once they are in. That keeps every FK-dependent record intact.
>
> **Small bug found in the Sub-Admin sidebar:** `sub_admin_dashboard.dart:1457-1463` builds a
> `Missile3DButton(label: 'Bus Companies', ...)` with **`onTap: () {}`** — an empty action. The real bus
> company management lives inline in the dashboard body, so either wire this button to it or drop it.

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

> **FIXED in `11dbaf8f`.** Decision: **register, not delete.** `routes/panels/` holds 11 files
> and `consumer` was the only one missing from the array. The 4 endpoints
> (`GET transit/search`, `POST fleet/auction`, `POST fleet/bid`, `POST chat/send`) are all
> implemented by `ConsumerSuperAppController`, which exists, and the Flutter app already calls
> them (`lib/core/navigation/panel_routes.dart:301-305`). Verified by clearing the route cache:
> 0 routes before, 4 after; and all 11 panels now load (702 routes total).
>
> **Operational discovery made while verifying this — worth knowing:** the repo's local
> `bootstrap/cache/routes-v7.php` was dated **April** and predated the entire panel route
> system, so `artisan route:list` reported only **149 routes and none of the panels**. That file
> is gitignored (only `.gitkeep` is tracked) and `deploy.yml:244-245` runs `optimize:clear`
> then `optimize` on every deploy, so **production rebuilds it fresh — which is why the panels
> work there.** Consequence for anyone debugging: **a stale local route cache makes every
> `routes/panels/*.php` file look absent.** Clear the cache before concluding a panel route is
> missing.

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

### 7b.4 Decision — `super_admin.php` admin middleware: **do NOT apply blind**

`super_admin.php:6` guards 19 live routes with `auth:sanctum` only, so **any** authenticated
account can reach platform-admin endpoints. The Flutter super-admin panel really does call them
(`lib/core/navigation/panel_routes.dart:210-216` — `/financial/vouchers/pending`,
`/security/audit-ledger`, …). This is a genuine privilege-escalation hole.

**The obvious fix is `auth:admin` (`AdminMiddleware`). It was investigated and NOT applied,
because it would very likely lock the owner out.**

`AdminMiddleware` is a three-tier check, and for a super admin **tiers 1 and 2 cannot pass**:

| Tier | Requires | Why a super admin fails it |
|---|---|---|
| 1 | `TenantAccount::isAdmin()` → `account_type === 'master_admin'` | `GlobalAuthController.php:345-347` sets `account_type` to `{fleet_type}_{role}` when there is a fleet assignment, and **`'global_identity'`** otherwise. A super admin has no fleet assignment, so it is `global_identity`. |
| 2 | `$user->getAttribute('identity_type') === 'admin'` | `$user` is a **`TenantAccount`**, and `identity_type` is a **`GlobalIdentity`** column. `TenantAccount`'s fillable list (`app/Models/TenantAccount.php:18`) does not include it, so this reads `null`. |
| 3 | a row in `master_admin_assignments` or `sub_admin_assignments` for the identity | **This is the only tier that can pass — and it cannot be verified from here (no DB access).** |

If tier 3 has no row for the owner's account, adding the middleware returns **403 on every
super-admin call** — the most critical panel in the system goes down. That is exactly the
"project crash" this work must avoid.

**The correct approach, therefore, is a shadow gate:**

1. A middleware that runs the *same* three-tier check, **logs** the decision, and **passes the
   request through regardless** while `SUPER_ADMIN_GATE_ENFORCE` is false (the default).
2. Apply it to `super_admin.php` together with `auth:sanctum`. Zero behaviour change.
3. The owner reads the logs, confirms their own account appears as *authorised* (or adds the
   missing `master_admin_assignments` row), then flips the env var to `true`.
4. **Enforcement becomes a config change, not a code change** — and a rollback is one env var.

**Before that middleware is even written, one query settles it.** Run on the server:

```sql
SELECT global_identity_id, revoked_at FROM master_admin_assignments;
SELECT id, email, account_type, global_identity_id FROM tenant_accounts WHERE email LIKE '%admin%';
```

If the owner's `global_identity_id` appears in the first result with `revoked_at IS NULL`, the
gate can be applied directly and the shadow step is unnecessary.

### 7b.5 Decision — `gitleaks`: scan the tree first, history later

`gitleaks` defaults to scanning **git history**, which still contains
`database_config.dart:54` (`awan1972`). Enabling it as-is would fail the build on a finding
that has already been removed and is pending rotation — a red build that says nothing useful.

**Add it against the working tree first** (`gitleaks detect --no-git --source . --redact`),
which still catches any secret committed from now on, because a committed secret is present in
the checked-out tree. **Once the passwords are rotated**, switch to history scanning (or add an
allowlist entry for the historical commit with a note that it was rotated) so the old finding
cannot hide a new one.

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

- **Contrast with the panels that work:** `main_cricket_manager.dart`, `main_cricket_public.dart`
and `reseller_app_initializer.dart` create their **own** `BlocProvider`s inline. **Correction (2026-09-25):**
the reseller claim in the line above was wrong — `reseller_app_initializer.dart` **does** call
`AppProviders.getRepositoryProviders(...)`. What made it harmless is that reseller uses **none** of
the nexa_admin/factory providers it was receiving — pure leakage. See §15b.3. Cricket is the true
reference model.

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

> **Per-panel subdomain + LOCK checklist:** `docs/handoff/PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md` — the
> 24-surface table with proposed subdomains, the nginx vhost template and API-prefix map, the
> Cloudflare records, the **two blockers** (five panels have no build step at all; the `main.dart`
> mega-entry cannot be locked by a subdomain until Phase 1 fixes the shared auth state), and the
> recommended wave order. Read it before starting any subdomain work.

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

**Progress log — update this list as items land.** `[x]` shipped, with the commit hash.

- [ ] **Rotate the compromised passwords** (`awan1972`, `NexaAppPassword123!`) — they are in git
      history permanently. **Owner's task (server-side).** The file holding them has been
      deleted (`bdb3001d`), but deletion does not undo the exposure.
- [x] **Delete the plaintext DB credentials** from `lib/core/config/database_config.dart` —
      **`bdb3001d`**. Also fixed `backend/database/DEPLOYMENT.md` §8.3, which *instructed
      creating that file* — the root cause. Verified 0 imports and `dart analyze` still clean.
- [x] **Fix `tests.yml`** — **`e1e181b2`**. `master`/`*.x` → `main`/`mainnew`. Verified with a
      YAML parse.
- [ ] **Replace the hardcoded `root@135.181.46.27`** in `frontend-deploy.yml` with the same
      `vars.VPS_HOST` variable `deploy.yml` already uses. **Needs the repo variable to exist
      first, or the deploy breaks** — 9 hardcoded occurrences (lines 61, 90, 105, 145, 165-166,
      185, 200, 214, 229).
- [x] **Register `consumer`** in the `PanelRouteServiceProvider` panels array — **`11dbaf8f`**.
      **Decision: register, not delete.** `routes/panels/` holds 11 files and `consumer` was the
      only one absent from the array, so its 4 endpoints under `/api/v1/consumer` were 404.
      All four are implemented by `ConsumerSuperAppController`, which exists, and the Flutter app
      already calls them (`lib/core/navigation/panel_routes.dart:301-305`). Deleting would have
      destroyed intended functionality. Verified: 0 routes before, 4 after; all 11 panels load.
- [x] **Add admin middleware to `super_admin.php`** — **`6a400138`**, as a **shadow gate**: the
      same three-tier check, logged, passing requests through unless
      `SUPER_ADMIN_GATE_ENFORCE` is truthy. See §7b.4 for why `admin` could not be applied
      directly. **Owner's next step: read the `super_admin_gate.shadow` log lines, confirm the
      intended admin accounts appear as authorised, then set the variable to `true`.**
- [x] **Add `dart analyze` to CI** — **`ce560194`**. Runs after `flutter pub get`, before the
      builds. Uses `--no-fatal-warnings` because the tree carries a 57-warning backlog (0
      errors); verified the gate is *not* vacuous by confirming a deliberate type error makes
      it exit non-zero.
- [ ] **Add `gitleaks` (or `trufflehog`) secret scanning to CI** — prevents the next credential
      commit. **Not done yet; see §7b.5 for the safe configuration** (scan the tree, not
      history, until the passwords are rotated).
- [ ] **Resolve the 37 dependency advisories** — `composer audit` reported *37 security
      vulnerability advisories affecting 11 packages* during the lock sync. **Pre-existing**,
      not caused by any change in this cycle, and not yet triaged. Run `composer audit` for the
      list; this is a hygiene item that needs its own reviewable change, not a quick win.
- [x] **Move `missile_3d_button.dart`** into `lib/shared/widgets/buttons/` — **`3fbbeb90`**.
      6 import sites across 4 domains; git recorded it as a 100% rename. `shared → features`
      backward imports dropped **4 edges → 3**.
- [x] **Add the CI boundary check (containment mechanism 1)** — **`ca591a98`**.
      `.scripts/check-panel-isolation.mjs` + `.github/workflows/panel-isolation.yml`.
      **This is the change that makes every later extraction stick.** Statement-level baseline of
      **84 existing violations across 12 folder-pairs** (see §5c #1). Verified non-vacuous.
      Report command: `node .scripts/check-panel-isolation.mjs --report`.
- [x] **Delete the dead files listed in §6** — **`969aab00`** (4 dead `core/` files) and **`3be02476`**
      (`features/transport/**` + `features/transport_marketplace/**`, 20 files, −6,116 lines).
      Verified by path **and** class-name grep across `lib/` **and** `test/`.
      ⚠️ **`whip_client.dart` was restored** — §6's row said "0 importers" but missed that it has a
      test (`test/features/broadcaster/whip_client_test.dart`). Row corrected.
- [x] **Split `app_providers.dart` into per-panel providers (§15b)** — **`eba16ee6`**.
      `lib/app/app_initializer.dart` (moved out of `core/`), `features/nexa_admin/providers.dart`,
      `features/factory/providers.dart`; `core/providers/app_providers.dart` is now core-only.
      **Isolation baseline 75 → 28.** Verified with `dart analyze` on all five touched files.
- [ ] **Add `.github/CODEOWNERS`** — per-panel ownership requiring review. *(Low value on a
      single-owner repo; CODEOWNERS only has effect with org teams.)*
- [ ] **Add per-panel `paths:` filters** to the deploy workflow — stops the all-or-nothing
      rebuild of all 8 panels. **Do this with Phase 5**, per the phase plan.
- [x] **Write ONE real Flutter test** — **`d95ac9f1`**, and it corrected the premise. There
      were never "zero Flutter tests": `flutter test` reports **35**, including real bloc tests
      such as `test/features/cricket/presentation/blocs/team/team_bloc_test.dart`. **The actual
      gap was that no workflow ran `flutter test` at all**, so none of them had ever executed in
      CI. Adding the step was the fix; a new widget test for the shared `Missile3DButton` was
      added alongside it.
      **Writing that test found a defect:** `Missile3DButton.height` is **ignored** — its
      `CustomPaint` is built with a child, and `CustomPaint.size` is only consulted when the
      child is null, so the body takes its height from the content (52 px) instead of the
      parameter. `manager_dashboard_page.dart` passes `height: 72` and does not get it. The test
      pins the current behaviour as a characterisation test so the fix is noticed; fixing it
      changes four panels, so it belongs with D4. Details in the test file's comments.

### Still-open structural work this checklist does not cover

The remaining three `shared → features` backward edges (telemetry models → BUS, and two files
→ `features/auth`) are Phase 1 items 2–4 in §5b.2 — they need the same treatment as
`missile_3d_button`, and the CI boundary check (containment mechanism 1) should land with them
so they cannot come back.

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

---

# 11. Ecosystem registry — every app and panel, numbered **[NEW — owner + audit, 2026-09-24]**

The "18 apps and panels" figure was always **an estimate** — the owner's own words: *"18 andazan
kaha tha, is se kam zyada ho sakte hain."* This section replaces estimates with a counted
registry, so no future document or agent has to guess a number.

**This registry is the counting authority.** The spec's "15 modules" (§3) and its "6 entry points"
(§10.11) both describe an older shape of the system; they are corrected in §12–§16 and in the
spec's correction notice.

**Numbering is by group.** The table runs in plan group order (Group 1 → Group 8), so every group's
surfaces hold consecutive numbers. **26 surfaces** in total.

| # | Surface | Group | Entry point / folder | Backend panel | Architecture | Status |
|---|---|---|---|---|---|---|
| 1 | Super Admin Panel | 1 Platform | `main.dart` | `super_admin.php` | Flutter BLoC | Live |
| 2 | **Sub-Admin Panel** | 1 Platform | `main.dart`, `sub_admin_login_screen.dart` | `super_admin.php` (`sub.admin` guard) | Flutter BLoC | Live (roles static) |
| 3 | Universal Customer App | 1 Platform | ⚠️ **2 copies** — see §6 | `consumer.php` | Flutter BLoC + Rust kernel | Partial |
| 4 | B2B Marketplace | 2 B2B | own entry point | `marketplace.php` | Flutter BLoC | Live |
| 5 | Reseller App | 2 B2B | `main_reseller.dart` | `marketplace.php` | Flutter BLoC | Live |
| 6 | Shop Keeper App | 2 B2B | — | `marketplace.php` | Flutter BLoC | **0 work** |
| 7 | Factory Admin Panel | 3 Factory | `main.dart` | `factory.php` | Flutter BLoC | Live |
| 8 | Factory Store Keeper App | 3 Factory | `main.dart`, `features/factory/store_keeper/` | `factory.php` | Flutter BLoC | Live |
| 9 | Factory Driver App | 3 Factory | `main_driver.dart`, `features/factory/driver/` | `factory.php` | Flutter BLoC | Live |
| 10 | Bus Fleet Admin Panel | 4 Bus | `main_bus_fleet.dart` | `bus_fleet.php` | Flutter BLoC | Live |
| 11 | Bus Owner App | 4 Bus | `main_bus_owner.dart` | `bus_owner.php` | Flutter BLoC | Live |
| 12 | Bus Driver App | 4 Bus | `main_bus_driver.dart` | `bus_fleet.php` | Flutter BLoC | Live (GPS stub) |
| 13 | Bus Conductor App | 4 Bus | `main_bus_conductor.dart` | `bus_fleet.php` | Flutter BLoC | Live |
| 14 | **Bus Fleet Store Keeper App** | 4 Bus | `features/storekeeper/` (18 files) — via `main_bus_fleet.dart` → `StorekeeperDashboardScreen(bus-fleet)` | `bus_fleet.php` | Flutter BLoC | Live |
| 15 | **Goods Company Admin Panel** | 5 Goods | — (no entry point) | `goods_fleet.php` + `Admin\GoodsFleetController` | Flutter BLoC | **Missing** |
| 16 | **Goods Store Keeper App** | 5 Goods | — | `goods_fleet.php` (planned) | Flutter BLoC | **Not built** |
| 17 | Truck Owner App | 5 Goods | `main_truck_owner.dart` | `truck_fleet.php` | Flutter BLoC | Live |
| 18 | Truck Driver App | 5 Goods | `main_truck_driver.dart` | `truck_fleet.php` | Flutter BLoC | Live (imports BUS pages) |
| 19 | Truck Conductor App | 5 Goods | `main_truck_conductor.dart` | `truck_fleet.php` | Flutter BLoC | Live (imports BUS pages) |
| 20 | Cricket Manager Panel | 6 Cricket | `main_cricket_manager.dart` | `cricket.php` | Flutter BLoC | Live |
| 21 | **Todd Studio** | 6 Cricket | `media-engine/ui/todd-studio-gui/` | `studio.php` | **Rust + Tauri** | Live |
| 22 | Todd Broadcaster App | 6 Cricket | `apps/broadcaster-android/` | media-engine | **Native Android + Rust engine** | Live (WHIP untested) |
| 23 | Cricket Public Viewer | 6 Cricket | `main_cricket_public.dart` | `cricket.php` | Flutter BLoC | Live |
| 24 | Device Security (IoT) Panel | **7 Vehicle Security** | — | — | Flutter BLoC | **0 work** |
| 25 | Jaali / Asli / Naqli Note Panel | **8 Trust & Safety** | — | — | Flutter BLoC + Rust CV kernel | **0 work** |
| 26 | Landing Page (company website) | — *(ungrouped)* | `main_landing.dart` | `public/content` | Flutter (web) | Live |

### The contested surfaces — all settled

| Surface | Owner's ruling | Number |
|---|---|---|
| **Bus Fleet Store Keeper** | Confirmed — belongs to **Group 4 (Bus)**. Shares its link with the Bus Fleet Admin but has its own login page | **#14** — last in the Bus group, immediately after the other bus surfaces |
| **Goods Store Keeper** | Confirmed — belongs to **Group 5 (Goods / Truck)** | **#16** |
| **Sub-Admin Panel** | Confirmed — belongs with Super Admin in **Group 1 (Platform)**. Numbered, because it has its own login screen and its own backend guard (`sub.admin`) | **#2** |

**Group 8 — Trust & Safety** is new and was created at the owner's instruction to hold the note panel
(#25). It is the natural home for future trust/verification surfaces.

**#26 (Landing Page) is deliberately ungrouped.** It is the public company website, not an
operational panel. The owner may assign it to Group 1 (Platform) later, or leave it outside group
numbering.

### Numbering map — first pass → group order (2026-09-24)

This pass is the **one-time re-baseline** from arrival order to group order. Old numbers are kept
here so documents written before this date remain readable.

| Old | Surface | New |
|---|---|---|
| 20 | Super Admin Panel | **1** |
| — | *Sub-Admin Panel (new)* | **2** |
| 19 | Universal Customer App | **3** |
| 12 | B2B Marketplace | **4** |
| 13 | Reseller App | **5** |
| 18 | Shop Keeper App | **6** |
| 1 | Factory Admin Panel | **7** |
| 2 | Factory Store Keeper App | **8** |
| 3 | Factory Driver App | **9** |
| 7 | Bus Fleet Admin Panel | **10** |
| 4 | Bus Owner App | **11** |
| 5 | Bus Driver App | **12** |
| 6 | Bus Conductor App | **13** |
| 24 | Bus Fleet Store Keeper App | **14** |
| 11 | Goods Company Admin Panel | **15** |
| — | *Goods Store Keeper App (new)* | **16** |
| 8 | Truck Owner App | **17** |
| 9 | Truck Driver App | **18** |
| 10 | Truck Conductor App | **19** |
| 14 | Cricket Manager Panel | **20** |
| 15 | Todd Studio | **21** |
| 16 | Todd Broadcaster App | **22** |
| 17 | Cricket Public Viewer | **23** |
| 21 | Device Security (IoT) Panel | **24** |
| 22 | Jaali / Asli / Naqli Note Panel | **25** |
| 23 | Landing Page | **26** |

### Counting rules adopted

1. **A surface counts if it has its own login and/or its own entry point or build target** —
   even when it shares a link, a subdomain, or a bundle with another surface.
2. **Shared code is not a surface.** `lib/shared/`, `lib/core/` and a group's `lib/features/<dept>/`
   are code, not apps.
3. **Numbers run in group order** — Group 1 first, then Group 2 … Group 8, ungrouped last. A group's
   surfaces therefore hold consecutive numbers.
4. **Numbers are stable after this re-baseline.** The 2026-09-24 pass above is the **one-time
   exception** (numbers moved from arrival order to group order). From here on a retired surface
   keeps its number and is marked retired, so older documents stay readable.

### Group assignments — all settled

- **#24 (IoT / Device Security)** → **Group 7 Vehicle Security** (the group exists for it).
- **#25 (Jaali / Asli / Naqli note panel)** → **Group 8 Trust & Safety**, a new group created at the
  owner's instruction in this pass and now listed in §1.
- **#26 (Landing Page)** → deliberately ungrouped (see above).
- **#2 / #14 / #16** → confirmed and numbered (table above).

No surface is left without a group except the deliberately-ungrouped landing page.

---

# 12. Architecture standard — BLoC vs native, per surface **[NEW — audit 2026-09-24]**

This plan separates *folders, builds and servers*. This section separates **runtimes** — which is a
different axis, and answers the owner's question directly (*"koi koi se panel full Flutter BLoC,
koi Flutter+Rust, koi Rust+Tauri?"*).

## 12.1 The governing rule

> **Dart/Flutter BLoC owns orchestration, state, UI and platform I/O. Native (Rust) owns only work
> that is a measured hotspot, that runs per-frame, or that must reuse a native library.**
>
> **No surface is "a Rust app". Every surface is a Flutter app that may call a native kernel.**

Practical test before adding native code to any surface: *is this a measurable hotspot, or am I
adding FFI boundary cost for nothing?* For forms, lists, seat maps, dashboards and bidding UIs, the
answer is the second one.

## 12.2 Per-surface decision

| # | Surface | Runtime | Rationale |
|---|---|---|---|
| 1–2, 4–20, 23–24, 26 | All platform-admin, B2B, factory, bus, goods, cricket-manager, public-viewer, shopkeeper, IoT and landing surfaces | **Flutter BLoC only** | UI-shaped work. Native adds cost, not speed |
| 3 | Universal Customer App | **Flutter BLoC + native kernel** | 95% BLoC; only camera-frame work crosses into native |
| 21 | Todd Studio | **Rust + Tauri (desktop)** | Heavy media pipeline; desktop-only by design |
| 22 | Todd Broadcaster | **Native Android (Kotlin) + Rust media engine** | WHIP/WebRTC ingest — not a Flutter use case |
| 25 | Jaali / Asli / Naqli Note Panel | **Flutter BLoC + Rust CV kernel + platform-native inference** | Heaviest compute in the ecosystem |

Net: **22 surfaces are pure Flutter BLoC; 2 are Flutter BLoC + native kernel (#3, #25); 1 is
Rust + Tauri (#21); 1 is native + Rust engine (#22).**

## 12.3 The jank trap — synchronous FFI on the UI thread

This is the single most important engineering rule for surfaces #3 and #25, and it is the answer
to the owner's worry that a Flutter app will *"hang, ruk ruk kar chale"*:

- Flutter's UI runs on **one main isolate**. Heavy work there = jank.
- **Calling Rust synchronously from that isolate is equally janky.** Being written in Rust does not
  make a call asynchronous. This is the trap: a correct, fast Rust kernel can still freeze the app
  if it is called synchronously from the main isolate.
- Therefore, one of:
  - `flutter_rust_bridge` **v2**'s async API (v1 has no equivalent — see §13.2), **or**
  - `Isolate.run(...)` / a worker isolate around the raw FFI call, **or**
  - a native thread that posts results back (port/callback).
- Camera frames must **not** cross into the Dart heap — pass handles, not byte lists.
- The camera surface must be **isolated** so its processing never touches the rest of the app.

## 12.4 Why the Customer App must NOT follow Todd Studio

Owner's question: *"Customer app BLoC me theek rahegi ya Todd Studio ki tarah bina BLoC, taake
halki rahe?"*

**Answer: keep Flutter BLoC.**

- **Todd Studio is desktop-only.** It is a Tauri shell built by `desktop-build.yml` into
  NSIS/MSI installers for Windows/macOS. It has no mobile target, and never will under this shape.
- **The Customer App ships to Play Store and App Store.** Rust-only or Tauri gives up mobile
  deployment entirely.
- **BLoC is not the cause of stutter.** Main-thread work is. The fix is §12.3, not abandoning the
  app's architecture.
- A Flutter Web build compiles Dart to JavaScript in the visitor's browser (§8, Phase 0a) — one
  more reason architecture decisions here are deployment decisions.

## 12.5 Which surfaces get a native kernel, and when

| Surface | Kernel | When |
|---|---|---|
| #3 Customer App | Camera frame prep, QR/scan payload validation, later OVI/frame features | **After** Phase 6 (API-only coupling) + the §6 customer-app merge |
| #25 Note Panel | Frame prep, ROI crop, blur/exposure gating, binarization, thread/fibre features | Pillar A, on its own track (see §15) |
| #8 / #12 (Factory Store Keeper, Bus Driver) | Optional: reuse the existing `algorithms::*` (SHA-256, auth-code verify) | Only if a measured hotspot appears — not by default |
| Everything else | None | Never |

---

# 13. Native / Rust layer — verified state and remediation **[NEW — audit 2026-09-24]**

This plan has so far said nothing about the native layer, yet Group 3 (factory code generation) and
Group 6 (cricket) both depend on it. The audit found it **half-broken**. This section records the
verified state so the fixes can be scheduled, not re-discovered.

## 13.1 `rust/` crate — facts

| Fact | Value |
|---|---|
| Package / lib | `trace_odd_rust` v0.1.0, edition 2021 |
| Crate type | `["cdylib", "staticlib"]` + a `trace_odd_rust` CLI binary |
| Declared bridge | `flutter_rust_bridge = "1.82.4"` (v1) in `rust/Cargo.toml` |
| **Declared in app** | `flutter_rust_bridge: ^2.11.1` (**v2**) in `pubspec.yaml` |
| Real FFI surface | `rust/src/ffi_abi.rs` — 11 hand-written `#[no_mangle] extern "C"` symbols returning NUL-terminated JSON |
| Vestigial surface | 29 `#[frb]` items in `rust/src/lib.rs` (v1 macro style) |
| What actually does work | `algorithms/` (SHA-2, AES-GCM, ChaCha20-Poly1305, Argon2, PBKDF2, HMAC, TOTP/HOTP, Luhn/EAN/UPC checksums), `generators/` (bundle → carton → packet → unit + hierarchical) |
| What is a stub | `international/{gs1,qr,barcode}` emit formatted **strings**, not encodings (`Cargo.toml`: *"qr-code, barcode, gs1 removed — crates not available on crates.io"*) |
| Camera / CV / AI | **None.** No `image`, `opencv`, `onnx`, `tflite`, `candle`, `imageproc` — no matches anywhere |

## 13.2 The bridge is dead — dual-version, no generated artifacts

- `rust/Cargo.toml` pins **1.82.4 (v1)**; `pubspec.yaml` declares **^2.11.1 (v2)**. The two APIs are
  incompatible, so neither side can be right.
- **Zero generated artifacts**: no `frb_generated.rs`, no `frb_generated.dart`, no `rust_builder/`,
  no `flutter_rust_bridge.yaml`, and **no `build.rs`** — so the declared build-dependency never runs.
- **Zero Dart files import `package:flutter_rust_bridge`.**
- The operative contract is therefore `ffi_abi.rs` + `dart:ffi` in `lib/rust_module/ffi_config.dart`
  (`DynamicLibrary.open` + `lookupFunction`), whose 11 symbol names **match** `ffi_abi.rs` exactly.

**Decision required (owner):** complete a **v2 migration**, or **remove `flutter_rust_bridge`** and
make `ffi_abi.rs` the official, documented contract. The recommendation is to **remove it** —
`ffi_abi.rs` already works, deployment stays simple, and the v1/v2 conflict disappears permanently.

## 13.3 Symbol mismatch — `verify_serial_on_device`

`lib/core/crypto/rust_serial_validator.dart:111` looks up **`verify_serial_on_device`**, which **no
Rust code exports**. Its exception path catches `CryptographicBridgeException` and rethrows, so once
the native library loads (`isNativeAvailable == true`) the intended Dart fallback is **bypassed** and
the call throws instead of degrading.

## 13.4 Memory ownership

Rust allocates response strings with `CString::into_raw`; the Dart side frees only the **request**
pointer (`calloc.free`). **Responses are never freed** — a per-call leak. A free contract is needed
(e.g. an exported `nexatrace_free_string`) before any long-running native path ships.

## 13.5 Packaging gap — the native library is never shipped to a device

No `CMakeLists.txt`, no `*.podspec`, and no Gradle step invokes `cargo`. The `cdylib` is built only
by `deploy.yml` **for the server**. Consequence: on Android/iOS/desktop `DynamicLibrary.open` fails,
`isAvailable == false`, and the Dart fallback silently takes over. **Any plan that puts a Rust kernel
inside the Customer or Note app is blocked on this** — it must be fixed before §12.5 work starts.

## 13.6 Cricket drift check — broken, and how to fix it

`backend/app/Services/Cricket/LiveScoreService.php` shells out to the configured Rust binary with
`cricket --recompute`. But `rust/src/main.rs` handles **only** `generate` and `--version`; every other
argument falls into the `other =>` arm and `exit(1)`. **So the drift check can never succeed**, and it
fails silently. Cause: score recomputation moved to the `todd-cricket` crate in `media-engine/`
(`main.rs`'s own comment says so), but PHP was never repointed, and **no workflow deploys the
`todd-cricket` binary** — its default path `/opt/nexatrace/trace_odd_rust` is a *different* binary.

| Option | What it means | Verdict |
|---|---|---|
| **A — restore the old contract** | Re-add a `cricket` arm to `main.rs` that calls `todd-cricket`'s `recompute()` | **Rejected.** Scoring logic would exist in two places — the exact duplication the owner ruled against |
| **B — point PHP at the right binary** | Build + deploy `todd-cricket`, set `CRICKET_RUST_BINARY` (default is the wrong binary today) | **Do this — immediate fix** |
| **C — ship it in the media-engine image** | Include `todd-cricket` in the media-engine Docker image (it already has CI) and have PHP call it | **Target state** |

**Owner's ruling recorded:** A is rejected; **B now, C later.** Option A was previously proposed by
another agent and declined on the grounds that duplicate scoring logic "would not matter" — the owner
disagrees, and this plan follows the owner. **Duplicated scoring logic is treated as a defect, not a
shortcut.**

### Streaming context for Phase S (read before running the A/B test)

The drift check sits in the same Group 6 (Cricket) domain as the streaming problem, so the two get
confused. The owner's account of the sequence:

1. Public viewer stream ran over **HLS** and stuttered.
2. Further problems followed.
3. The most recent change moved the ingest path to **WHIP — and it has not been tested yet.**

**Consequence for Phase S:** confirm **which transport is now canonical (HLS or WHIP)** before running
the §9.9 A/B experiment, because the last change moved the transport and is unverified. Verifying an
HLS path against a server that now serves WHIP would produce a misleading result. Phase S is still
the first phase; only its target URL/path needs to be confirmed first.

## 13.7 Build / CI matrix

| Workflow | Rust | What it builds |
|---|---|---|
| `deploy.yml` | yes | `cd rust && cargo build --release` → `trace_odd_rust`; rsync to `/opt/nexatrace`. **No features** (Linux only) |
| `media-engine-build.yml` | yes | `cargo check -p todd-signaling -p todd-sfu --features gst`; GStreamer tests; Docker images with `FEATURES=gst` |
| `media-engine.yml` | yes | fmt, clippy `-D warnings`, `cargo test --workspace`; **trigger branch `master`** — stale vs `main`/`mainnew` |
| `desktop-build.yml` | yes | Tauri shell → NSIS + MSI (Windows) |
| **any workflow** | — | **No workflow builds or deploys `todd-cricket`** |

Reminder from `AGENTS.md`: `cargo check --workspace` does **not** compile `forwarder.rs`, `mixer_gst.rs`
or `audio.rs` — they sit behind `#[cfg(feature = "gst")]`. The CI command
`cargo check -p todd-signaling -p todd-sfu --features gst` is the one that proves anything.

## 13.8 Media engine boundary — do not merge

`media-engine/` is a **separate Rust workspace** (`todd-signaling`, `todd-sfu`, `todd-transcode`,
`todd-replay`, `todd-cricket`, `todd-common`, `todd-telemetry`). It has **no path dependency** in
either direction with `rust/`, and `media-engine/docs/01-architecture.md` explicitly says not to merge
them (*"that one is flutter_rust_bridge FFI glue … a completely different build and deployment
lifecycle"*). Keep them separate; §13.6 option C couples them only at the image/packaging level.

---

# 14. Risk register — corrected status and fix steps **[NEW — audit 2026-09-24]**

An earlier draft of the audit listed items that have **since been fixed**. The corrected table follows;
several rows are already shipped and only need an owner action.

| Risk | Status now | Fix | Owner |
|---|---|---|---|
| **Super-admin endpoints non-enforcing** | **Mitigated** — shadow gate shipped (`6a400138`), per §7b.4 | Read the `super_admin_gate.shadow` log lines, confirm the intended admin accounts appear as authorised, then set `SUPER_ADMIN_GATE_ENFORCE=true` | **Owner** |
| **Plaintext DB credentials** | **File deleted** (`bdb3001d`) — but the **passwords are not rotated** and are in git history permanently | Phase 0a order: (1) check `pg_hba.conf` for `0.0.0.0/0` on port **5444**, (2) restrict, (3) **rotate both `postgres` and `nexa_app`**, (4) add `gitleaks` to CI | **Owner (server-side)** |
| **Realtime/Redis silently degraded** | Live — `BROADCAST_DRIVER` defaults to `log`, `CACHE_STORE=database`, `QUEUE_CONNECTION=database` | Set `BROADCAST_DRIVER=reverb`, `CACHE_STORE=redis`, `QUEUE_CONNECTION=redis` in production `.env`; add a startup health check that warns when they are not real | Owner + dev |
| **Fabricated telemetry in shipped UI** | Live — driver dashboard shows hardcoded GPS strings; `shared/widgets/maps/fleet_live_map_canvas.dart` documents itself as pseudo-position by vehicle-ID hash | Either wire a real source or label it honestly as a demo. Note §6 already lists `driver_gps_beacon` and `live_bus_tracking_screen` as **never referenced** — so first decide: delete, or wire | Dev |
| **`/customer/my-tickets` is not a route** | Live — the live customer screen pushes a path `app_router.dart` does not define | Add the route during the §6 customer-app merge, or remove the button | Dev |
| **`verify_serial_on_device` symbol mismatch** | Live — throws once the native lib loads | Fix inside §13 rust hygiene: export it in Rust, or remove the Dart lookup | Dev |
| **`dart analyze` backlog** | CI gate shipped (`ce560194`), `--no-fatal-warnings`, **57 warnings / 0 errors** | Burn down the 57, then flip to fatal | Dev |
| **37 composer advisories** (11 packages) | Untriaged, pre-existing | `composer audit`, triage, upgrade as its own reviewable change | Dev |
| **Hardcoded `root@135.181.46.27`** | Live — 9 occurrences in `frontend-deploy.yml` | Use the same `vars.VPS_HOST` that `deploy.yml` uses — **create the repo variable first**, or the deploy breaks | Owner + dev |
| **Live LLM API key in plaintext** | Not in git — `%APPDATA%/Zed/settings.json` stores `language_models.openai.api_key` in **plaintext**. Exposed to screenshots, settings sync and backups, and it bills against the owner's account | Move to an environment variable or the OS keyring; **rotate the key** if that file has ever been shared, synced or screenshotted | **Owner** |

### Additional debt found by this audit, not yet in §6 or §9b

| # | Debt | Evidence |
|---|---|---|
| 1 | **Three parallel HTTP clients** | `core/network/api_client_v2.dart` (Dio), `core/services/api_client.dart` (http), `core/services/api_service.dart` — different features use different ones, and `app_initializer.dart` carries a *"C4 FIX: Token sync bridge"* shim to reconcile their tokens |
| 2 | **Two parallel WebSocket stacks** | `core/services/websocket_hub.dart` + `ws_socket*` **vs** `bus_operations/data/services/bus_tracking_websocket_*` — both speak Pusher/Reverb, both duplicate the `dart:io`/`dart:html` split |
| 3 | **`get_it` declared but unused** | `app_initializer.dart`: *"Replaces get_it initialization with Flutter BLoC's RepositoryProvider"* |
| 4 | **`setState()` backlog** | Hundreds of calls across cricket (top: `player_register_page` 12, `players_list_page` 8), factory code-gen screens, and bus_ops. Rule 1 in the owner's standing instructions forbids `setState`; the pattern has drifted. Freeze new usage, burn down old |
| 5 | **1142-line `app_router.dart`** | Covered by §7, but worth restating as the root coupling artefact |

---

# 15. Tracked outside this plan's scope **[NEW — audit 2026-09-24]**

Five product pillars were identified in the audit. Only two overlap this plan's groups; the rest are
recorded here so they are not lost, with their **full technical plans to be written into the new
master document** (owner's instruction: *"yeh abhi mere liye nahi likhna, jab final new md file
create karenge us mein sab likhna hai"*).

| Pillar | Group | Backend state | Frontend state | Next step |
|---|---|---|---|---|
| **B — Factory anti-counterfeit scanner** | 3 Factory | **Ready** — `ConsumerScanController@verify`, `FactoryProductionController@verifySerial`, `smart_codes`, `code_verification_history`, `consumer_scans` | Camera sheet missing; scan bloc exists in the orphaned copy | **Full plan drafted → `docs/handoff/PILLAR-B-PRODUCT-ANTI-COUNTERFEIT.md`** — fastest win |
| **C — Bus fleet super-app** | 4 Bus / 1 Platform | Strong — bookings, holds, `absolute_bus_layouts` + revisions, vouchers, wallets, `passenger_safety_tokens`, family stream | Seat map excellent; telemetry/map stubbed | Real GPS + real map SDK (Pillar C plan) |
| **D — Goods transport & freight** | 5 Goods | Freight ✅ (`freight_loads`/`freight_bids`, `FreightAuctionService`, matching job, `BiddingMeshController`); **relocation ❌**; **no `trucks` table**; **no `parcels` table** | Minimal (`goods_operations` = 5 files) | Pillar D plan |
| **E — IoT vehicle security** | **7 Vehicle Security** | **Nothing.** No `devices`, `geofences`, or telemetry tables; **no immobilizer anywhere** | Nothing | **Full plan drafted → `docs/handoff/PILLAR-E-IOT-VEHICLE-SECURITY.md`** |
| **A — PKR banknote authentication** | **8 Trust & Safety** | **Nothing** | Nothing | **Full plan drafted → `docs/handoff/PILLAR-A-BANKNOTE-AUTHENTICATION.md`** |

### Pillar B — note on status

The **full Pillar B plan now lives in `docs/handoff/PILLAR-B-PRODUCT-ANTI-COUNTERFEIT.md`**. Its
backend is **already implemented**, and the scan→verify bloc already exists — in the **orphaned**
customer-app copy. So Pillar B's first two steps (fix the stale route-map entry, consolidate the two
customer-app copies per §6) are work this plan already requires. Two findings worth noting here:

- `lib/core/navigation/panel_routes.dart:305` declares `/api/v1/consumer/verify`, **which does not
exist** — `consumer.php` registers four routes and none is `verify`. The real endpoint is
`POST /api/v1/marketplace/consumer/verify`.
- That endpoint **requires `lat`/`lng`**, and the repo has **no location source at all**. One plugin
decision unblocks Pillars B, C and E together.

### Pillar A — decisions already taken by the owner

The **full Pillar A plan now lives in `docs/handoff/PILLAR-A-BANKNOTE-AUTHENTICATION.md`** — it carries
the owner's disclaimer wording, the approved result wording, the training-dataset blueprint, the
reference data model and the legal gate. The bindings are repeated here in short form so this plan
stands alone:

1. **No 100% verdict.** The product flags *suspicious* notes; it does not certify authenticity.
   Messaging must be built around suspicion, not judgement.
2. **Dedicated hardware is permitted.** The mobile camera is not the only capture device — a
   purpose-built capture device is acceptable for features the phone cannot resolve.
3. **SBP is asked first.** Serial-number verification is pursued **only** if State Bank rules permit
   it. **Legal clearance precedes coding.**
4. **Three phases:** capture + quality + OVI heuristic (on-device) → thread/fibre verification
   (native kernel) → server-side model + continuous improvement.
5. **Known hard limit, recorded honestly:** PKR micro-text is ~0.2 mm; phone-camera optical and
   diffraction limits make reliable press-fidelity comparison an **optical** problem, not only a
   software one. This is the reason for point 2.

### Pillar E — note on scope

The **full Pillar E plan now lives in `docs/handoff/PILLAR-E-IOT-VEHICLE-SECURITY.md`**. It records
the published commitments (quoted from `assets/landing/landing_content.json`), the regulatory gates
(PTA type approval, SIM registration, immobiliser safety), proposed device/server/app designs, the
immobiliser fail-safe rules, and a phased plan that **starts with software + simulated devices** so
the hardware is not on the critical path.

The IoT vertical **does not exist in the legacy spec at all**. It appears only in
`assets/landing/landing_content.json` (vertical `iot-security`, PKR 499/899 per month, roadmap
Phase 4). Group 7 was created for it. **It must be registered as a first-class module in the new
master document**, or it will keep being forgotten by agents that read only the spec.

---

# 15b. Phase 1 — the provider split **[✅ DONE 2026-09-25 — `eba16ee6`]**

> **RESULT: the isolation baseline went 75 → 28 violating imports.** The three biggest edges
> (`core -> features/factory` 25, `core -> features/nexa_admin` 20, `core -> features/bus_operations`
> 1) are **gone**. What was done, exactly:
>
> | Step | Outcome |
> |---|---|
> | `app_initializer.dart` moved `core/widgets/` → **`lib/app/`** | git recorded it as an 88 % rename — content preserved |
> | **`lib/features/nexa_admin/providers.dart`** created | `NexaAdminProviders.repositoryProviders()` + `.blocProviders()` |
> | **`lib/features/factory/providers.dart`** created | `FactoryProviders.repositoryProviders()`, `.adminBlocProviders()`, `.driverBlocProviders()`, `.storeKeeperBlocProviders()` |
> | `lib/core/providers/app_providers.dart` slimmed | now **core services only** — imports nothing from `features/` |
> | Call site composed | `lib/app/app_initializer.dart` builds `[...core, ...nexa, ...factory]` in the original order |
> | `reseller_app_initializer.dart` | **unchanged** — verified it uses none of the panel repos, so losing them is not a behaviour change |
>
> **Verified by the real Dart analyzer** (`dart analyze` on all five touched files: *No issues found!*)
> and by the guard (no new coupling). `dart analyze` on a **targeted file** works fine — only the
> whole-project run is unreliable locally.
>
> **Still open for a later pass:** `main.dart` is still a mega-launcher (Super Admin + Factory +
> Store Keeper in one bundle). This section removed the *coupling*; slimming `main.dart` to
> Super-Admin-only is the next Phase 1 item (§5b.2 item 8) and is what finally unblocks subdomains
> #1, #2, #7 and #8.

§5b.2 item 5 says *"Split `app_providers.dart` (284 lines, 59 imports) into
`features/<panel>/providers.dart`"*. This section records everything needed to do it safely, after a
read of the real file. **It is the single highest-leverage change toward group isolation**, because
the same file is the mechanism behind the Factory/Sub-Admin mixing bug (§7c).

## 15b.1 Why it is a *pure move* — and why that makes it low-risk

`lib/core/providers/app_providers.dart` currently holds one class (`AppProviders`) with six static
methods. It imports **19 factory files and 20 nexa_admin files**, plus 4 core files.

Move each panel-specific method into that panel's own folder and the imports become
`features/<panel> → features/<panel>` — **the same layer, which the model allows**. No logic changes,
no behaviour changes. The violation disappears because the *file* moved, not because the code changed.

| Violation today | After the move |
|---|---|
| `core -> features/factory` — 25 statements | **0** |
| `core -> features/nexa_admin` — 20 statements | **0** |
| **Baseline total 77** | **~32** |

## 15b.2 The dump

| `AppProviders` method | Contents | New home |
|---|---|---|
| `getRepositoryProviders` | SharedPreferences, SecureStorageInterface, ApiClient, ApiService, Dio **+ all nexa_admin repos + all factory repos** | **split**: core services stay in `core/`; the rest goes to the two panel files |
| `getNexaAdminBlocProviders` | 7 blocs | `features/nexa_admin/providers.dart` |
| `getFactoryAdminBlocProviders` | 11 blocs | `features/factory/providers.dart` |
| `getDriverBlocProviders` | 2 blocs (factory driver) | `features/factory/providers.dart` |
| `getStoreKeeperBlocProviders` | **empty list** | `features/factory/providers.dart` |
| `getGlobalBlocProviders` | **empty list** | stays (no feature imports) |

## 15b.3 ⚠️ Two assumptions that are WRONG — found by reading, 2026-09-25

1. **§7c claims `reseller_app_initializer.dart` "never touches `AppProviders`". It does.**
   `lib/features/reseller/app/reseller_app_initializer.dart:70-80` calls
   `AppProviders.getRepositoryProviders(...)` as its base. So the reseller app currently receives
   **nexa_admin + factory repositories it does not need** — B2B leakage. The split must therefore
   decide explicitly what reseller keeps (see step 4), and cannot simply strip the list.
2. **`app_initializer.dart` lives in `core/widgets/` — it is itself a violation.**
   `lib/core/widgets/app_initializer.dart` imports `features/bus_operations/.../ticket_vault_service.dart`
   (that is the whole `core -> features/bus_operations: 1`). Any per-panel providers file it imports
   would add more. **App-level composition does not belong in `core/`** — it belongs to the layer the
   model calls "other" (entry points and routing), which may import anything.

## 15b.4 Step list (each step is independently verifiable)

1. **Move `app_initializer.dart` out of `core/`** — to `lib/app/app_initializer.dart` (new folder,
   layer "other"). Update the one import in `lib/main.dart`. Verify: `dart analyze lib/main.dart`.
   *Do this first — it is the precondition for the next steps being clean.*
2. **Create `lib/features/nexa_admin/providers.dart`** — `NexaAdminProviders.repositoryProviders()` and
   `.blocProviders()`, moved verbatim, same order.
3. **Create `lib/features/factory/providers.dart`** — `FactoryProviders.repositoryProviders()`,
   `.adminBlocProviders()`, `.driverBlocProviders()`, `.storeKeeperBlocProviders()`, moved verbatim.
4. **Slim `lib/core/providers/app_providers.dart` to core services only** — SharedPreferences,
   SecureStorageInterface, ApiClient, ApiService, Dio. It must import **no** `features/` file when done.
5. **Compose at the call sites** (both are layer "other", so both are allowed to import features):
   - `lib/app/app_initializer.dart` — `[...core, ...NexaAdminProviders.repo(), ...FactoryProviders.repo()]`,
     then the bloc lists. **Keep the exact order** — `RepositoryProvider` dependencies are resolved by
     `context.read` during `create`, so order is behavioural, not cosmetic.
   - `reseller_app_initializer.dart` — decide what B2B actually needs. **Behaviour-preserving default:**
     keep all three lists unchanged, then open a separate task to trim the unused ones.
6. **Delete nothing else.** `getGlobalBlocProviders`/`getStoreKeeperBlocProviders` returning empty
   lists are harmless; they can be removed when their callers are touched.

## 15b.5 Verification gates (all runnable)

```bash
# The guard: must drop from 77 to ~32, and the check must still PASS
node .scripts/check-panel-isolation.mjs --report
node .scripts/check-panel-isolation.mjs

# Then re-baseline, which is the point of the exercise:
node .scripts/check-panel-isolation.mjs --write-baseline
```

- `dart analyze <changed paths>` — works and is fast on a narrow scope; the **full-project** run
  exceeded 10 minutes locally, so scope it to the touched files.
- `frontend-deploy.yml` runs `dart analyze` **before** any build, so a compile error fails CI and
  never reaches the server. That is the backstop — but do not rely on it in place of local analysis.
- Runtime smoke test: the admin bundle must still boot, log in, and load a dashboard.

## 15b.6 Order relative to the subdomain work

This (§15b) **is Blocker B** from `PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md` §2. Until it is done, panels
#1, #2, #3, #7 and #8 cannot be locked to their own subdomains — one bundle still serves five panels
and one login still sets state another panel reads.

---

# 16. Developer environment — Zed language servers **[DIAGNOSED 2026-09-24 · CORRECTED 2026-09-25]**

Both servers were failing repeatedly in this workspace. Diagnosed from `Zed.log` and **reproduced
directly** — they have different causes, and only one of them was a settings problem.

## 16.1 Dart — **fixed**

`Zed.log` (18 occurrences):

```
Failed to start language server "dart": from extension "Dart" version 0.4.1:
dart must be installed from dart.dev/get-dart or pointed to by the LSP binary settings
```

**Cause:** `dart` and `flutter` are **not on `PATH`** on this machine (`command -v dart` → not found),
so the Dart extension cannot locate the SDK.

**Verified toolchain:**

| Tool | Result |
|---|---|
| `dart` | **not on PATH** |
| `flutter` | **not on PATH** |
| `node` | `C:\Program Files\nodejs\node.exe` — **v26.7.0** |
| `npm` | present |
| `yaml-language-server` | not installed globally |

**Two Flutter SDKs exist:** `C:/flutter` (Dart 3.11.1) and `C:/src/flutter` (Dart 3.12.2). The
project's `.dart_tool/package_config.json` resolves to **`C:/src/flutter`**, so that is the SDK in use.

**Fix applied — in USER settings, not project settings.** Two things must be right, and the first
attempt got only one of them:

1. **The path** must point at the **real executable** (`dart.exe` in the Flutter cache), **not**
   `bin/dart` (a shell script) or `bin/dart.bat` (a batch file) — Zed spawns processes directly.
2. **The arguments** must be supplied explicitly. A bare `dart.exe` does **not** start a language
   server: it prints the Dart CLI usage text and exits. That produced a *second, different* error
   after the path fix:
   ```
   ERROR [crates/lsp/src/lsp.rs:644] cannot read LSP message headers
   ERROR [crates/lsp/src/lsp.rs:671] The pipe is being closed. (os error 232)
   ```

**Verified directly:** `dart.exe language-server --protocol=lsp` answers an LSP `initialize` with
**2727 bytes** of valid response, while bare `dart.exe` prints usage. Both were tested by hand.

`%APPDATA%/Zed/settings.json` = `C:\Users\picks\AppData\Roaming\Zed\settings.json` (backed up to
`settings.json.bak` first):

```json
"lsp": {
  "dart": {
    "binary": {
      "path": "C:/src/flutter/bin/cache/dart-sdk/bin/dart.exe",
      "arguments": ["language-server", "--protocol=lsp"]
    }
  }
}
```

**Why user settings and not `.zed/settings.json`:** the path is **machine-specific**. Putting it in
the repo's shared settings would break every other clone. Do not move it there. Restart Zed (or run
`workspace: reload`) for it to take effect.

## 16.2 Node-based servers — Node version is **NOT** the cause (corrected)

**Correction to an earlier draft of this section**, which concluded the cause was Node v26.7.0.
**That conclusion was wrong.** Direct testing proved the YAML server works on **both** Node versions.

What the log shows (ids 22/25/26/29 on 2026-09-25, plus 11 earlier occurrences):

```
INFO  [lsp] starting language server process. binary path: "C:\Program Files\nodejs\node.exe",
  args: [".../yaml-language-server/bin/yaml-language-server", "--stdio"]
...
ERROR [lsp] Cancelled LSP request task for "initialize" id 0 which took over 120s
ERROR [project::lsp_store] Failed to start language server "yaml-language-server":
  Caused by: Request timed out
```

**Direct verification — the server itself is healthy:**

| Test | Result |
|---|---|
| `node <bin> --version` | `1.24.0` ✅ |
| LSP `initialize` on **Node v22.14.0** | **755 bytes of valid response** ✅ |
| LSP `initialize` on **Node v26.7.0** | **755 bytes of valid response** ✅ |
| Package install | complete — 378 files, full `out/` tree, all deps present |

So the server binary, its dependencies and **both** Node runtimes are fine. The failure is in how Zed
starts or talks to these servers, not in the servers themselves.

Every Node-based server shows the same 120s initialize timeout — the signature of a common Zed-side
cause rather than a per-server one:

| Server | Timeouts in log |
|---|---|
| `dart` | 18 — different cause, see §16.1 |
| `yaml-language-server` | 11 |
| `vtsls` | 2 |
| `bash-language-server` | 2 |
| `vscode-html-language-server` | 1 |
| `tailwindcss-language-server` | 1 |

`rust-analyzer` — a **native** binary, not Node — also hit a 120s timeout
(*"Get diagnostics via rust-analyzer failed: Request timed out"*), which further rules Node out.

**⚠️ Known current breakage — the manual `node.exe` rename.** During this diagnosis the owner renamed
`C:\Program Files\nodejs\node.exe` → `node_v26.exe` to force a different Node onto `PATH`. Zed's log
still launches Node-based servers from the literal path `C:\Program Files\nodejs\node.exe`,
**which no longer exists**, so those servers now fail to spawn at all. This must be undone (§16.3).

## 16.3 Action required — revert the `node.exe` rename

1. **Restore `C:\Program Files\nodejs\node.exe`.** The Node version was never the problem — both
   versions work. Renaming a file inside `Program Files` is also fragile: any Node update silently
   restores it, and tools that hardcode that path break in the meantime.
2. If a specific Node version should be the default, change it **cleanly** instead — via nvm's own
   `use` command, or by fixing `PATH` order — not by renaming the binary.
3. **Restart Zed** so it re-resolves `node` from `PATH`.
4. **If the timeouts persist on a working Node**, the cause is Zed-side. Reduce what Zed is asked to
   start: this repo is Flutter + Laravel + Rust and does **not** need the Tailwind, HTML or ESLint
   servers, and each disabled server removes one concurrent 120s stall. `rust-analyzer` diagnostics
   over `rust/` + `media-engine/` are also expensive here.
5. Disabling the YAML server remains a last resort (this repo has about two YAML files) — but the
   evidence above does **not** justify it:
   ```jsonc
   "lsp": { "yaml-language-server": { "enabled": false } }
   ```

**Do not** commit a `yaml-language-server` binary path into `.zed/settings.json`; it is
Node-installed and machine-specific, exactly like the Dart path.

## 16.4 Constraint to respect

`.githooks/validate-json-config.mjs` validates `.zed/settings.json` before commit. If that file is
ever edited, run `node .githooks/validate-json-config.mjs .zed/settings.json` — the hook is JSONC-aware
and confirmed working (*"JSON config valid (7 files checked)"* on commit `29a5fc28`).

---

# 17. Phase 1 — auth-state globals and the `/sub-admin` guard **[step 5 ✅ DONE 2026-09-25 — `9f59ef28`; steps 1-4, 6 pending]**

> **Step 5 is done:** `/sub-admin/*` now requires a sub-admin session. What changed —
>
> | File | Change |
> |---|---|
> | `lib/core/utils/auth_state.dart` | added `isSubAdminAuthenticatedCache` / `setSubAdminAuthenticatedCache()` — deliberately **not** cleared by `resetAuthState()`, so a super-admin logout cannot bounce a valid sub-admin session |
> | `lib/app/app_initializer.dart` | loads `sub_admin_token` from prefs **before** `setAuthCheckCompleted(true)`, so the cache is populated on cold start |
> | `lib/routes/app_router.dart` | `/sub-admin/login` stays public; every other `/sub-admin/*` route now redirects to the sub-admin login when the cache is empty |
> | `.../bloc/sub_admin/sub_admin_bloc.dart` | sets the cache to `true` on login success, `false` on logout |
>
> **Verified:** `dart analyze` — *No issues found!* on all four touched files (including `app_router.dart`, the largest graph) and the isolation guard stays green.
>
> ### ⚠️ A human MUST smoke-test this — it cannot be verified statically
>
> - [ ] Sub-admin: login → lands on `/sub-admin/dashboard` (**no redirect loop**)
> - [ ] Sub-admin: hard-refresh `/sub-admin/dashboard` while logged in → **stays** logged in
> - [ ] Sub-admin: logout → then visit `/sub-admin/dashboard` → **bounced** to `/sub-admin/login`
> - [ ] In a private/incognito window, visit `/sub-admin/dashboard` directly with no session → **bounced** to login
> - [ ] Super-admin: login → dashboard → logout → `/login` (unchanged)
> - [ ] Factory: login → factory dashboard → logout (unchanged)
>
> The first two are the ones that matter most: a wrong redirect here shows up as a **login loop**, not as an error.

Research and consumer inventory for the remaining steps are complete; steps 1-4 and 6 were
**deliberately not attempted**. Everything needed to execute them is below.

## 17.1 The concrete bug, found by reading the router — **✅ FIXED 2026-09-25**

`lib/routes/app_router.dart:254-258` **before** the fix:

```dart
if (path == '/sub-admin/login') return null;
if (path == '/sub-admin/dashboard') return null;
if (path.startsWith('/sub-admin/')) return null;   // no auth check at all
```

The sub-admin panel has **no client-side guard whatsoever**. Any visitor reaches the panel shell.

This is the direct cause of the owner's observed symptom — *"Factory Admin and Sub-Admin open the same
thing"*. All panels live in **one bundle**, so once the sub-admin dashboard is reachable, it renders
inside the same running app the factory admin is already in.

**Severity: UI exposure, not data loss.** The API is protected by the `sub.admin` middleware, so data
calls return 401 — but the panel itself is openly reachable, and that is what was seen.

## 17.2 Why the obvious fix needs care

Sub-admin auth is a **`sub_admin_token` in SharedPreferences** — written by `SubAdminBloc` on login
(`sub_admin_bloc.dart:62`) and removed on logout (`:530-536`). It is **not** one of the router's globals,
so the existing flags cannot guard those routes.

A guard must therefore read that token. `_safeRedirect` is already `async`, so it *could* await
`SharedPreferences` — but its own doc comment states it *"NEVER makes API calls, only checks local
cached state"*, precisely to avoid redirect loops. Adding an async read there is a **design change that
must be tested, not assumed**.

**Suggested shape:** cache the sub-admin token in memory at startup (alongside the other flags) and let
the redirect read the cache — preserving the "no I/O inside redirect" invariant.

## 17.3 The globals to remove (§5c containment mechanism #4)

`lib/core/utils/auth_state.dart` is 162 lines of **module-level mutable state** shared by every panel:

```
bool _authCheckCompleted, _isAuthenticatedCache, _isFactoryAuthenticatedCache
String? _userTypeCache, _userIdCache, _factoryIdCache, _tokenCache
+ 12 getters/setters, getFactoryAuthToken(), getFactoryId(),
  resetAuthState(), resetFactoryAuthState(), setSuperAdminAuthState(), setFactoryAuthState()
```

It mixes **two independent auth domains** in one process-wide bag, and any panel can write any field.

## 17.4 Full consumer inventory (the expensive part — already done)

| File | Uses |
|---|---|
| `lib/routes/app_router.dart` | reads `isAuthCheckCompleted`, `isAuthenticatedCache`, `isFactoryAuthenticatedCache` — ≈10 sites, L190-313 |
| `lib/app/app_initializer.dart` | writes both flags + `setAuthCheckCompleted`, `setFactoryAuthState` |
| `lib/features/factory/admin/presentation/bloc/auth/factory_auth_bloc.dart` | `setFactoryAuthState`, `resetFactoryAuthState` |
| `lib/features/factory/admin/presentation/screens/factory_login_screen.dart` | `isFactoryAuthenticatedCache`, `setFactoryAuthState` |
| `lib/features/nexa_admin/presentation/screens/super_admin/login_screen.dart` | `setIsAuthenticatedCache`, `setAuthCheckCompleted` |
| `lib/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart` | `resetAuthState` (logout, twice) |
| `lib/features/factory/admin/data/datasources/billing_remote_datasource.dart` | `getFactoryAuthToken()`, `getFactoryId()` |
| `lib/features/factory/admin/presentation/screens/codes/unit_codes/unit_code_generate_screen.dart` | `getFactoryId()` |
| *(plus)* readers of `getAuthToken`, `getUserId`, `userTypeCache`, `tokenCache` | see the grep from this session |

**≈12+ files on the auth critical path.**

## 17.5 Ready-to-execute steps

1. **Split the state by domain** — `AdminAuthState` and `FactoryAuthState`, each owning only its own
   fields. After this a factory write *cannot* touch an admin field — the mixing dies by construction.
2. **Provide one instance each** — create both in `lib/app/app_initializer.dart`, expose via
   `RepositoryProvider`, and pass the admin instance into `AppRouter`'s constructor (it already takes
   `authRepo`).
3. **Update the writers** — factory bloc + factory login screen → `FactoryAuthState`; super-admin login
   screen + `admin_auth_bloc` → `AdminAuthState`.
4. **Update the readers** — the router reads the admin instance; the factory datasources read the
   factory instance.
5. **Guard `/sub-admin/*`** (§17.1/§17.2) using the sub-admin token cache.
6. **Delete `lib/core/utils/auth_state.dart`** — then prove it: `node .scripts/check-panel-isolation.mjs`
   green, plus a grep for every removed name returning nothing in `lib/`.

## 17.6 Verification — and its honest limit

- ✅ `dart analyze <each touched file>` — reliable on targeted files (proven in §15b).
- ✅ `node .scripts/check-panel-isolation.mjs` — must stay green.
- ✅ grep every removed global name — must return nothing in `lib/`.
- ❌ **Runtime login flows cannot be verified from here.** A human MUST smoke-test these afterwards:
  - super-admin: login → dashboard → logout → `/login`
  - factory: login → factory dashboard → logout
  - sub-admin: login → `/sub-admin/dashboard`, **and** a direct visit to `/sub-admin/dashboard`
    *without* a token (must be blocked)
  - a hard refresh on each dashboard (the redirect runs on cold start, and `isAuthCheckCompleted` gating
    is exactly where loops appear)
- ⚠️ Do this when the owner is **not** mid-rotation — a mistake here locks every panel out at once.

## 17.7 Recommendation, and why steps 1-4 and 6 were not executed

**Step 5 is done** (§17 top). It was the ~10-line change that fixed the observed symptom directly.

The full globals removal (steps 1-4 and 6) is the architectural fix from §5c mechanism #4, and it should
land **with a human available to test logins**. It was not started because:

- it touches **≈12 files on the authentication critical path** — the one place where a subtle mistake
  locks every panel out;
- its correctness is **runtime behaviour** (login, logout, cold-start redirect), which cannot be
  verified by `dart analyze`, by the isolation guard, or by any static check available here; and
- the owner was **actively logging in** during the credential rotation at the time.

Shipping this blind would risk a worse outcome than shipping it next, verified.

## 17.8 The concrete cross-domain defect — found while preparing steps 1-4 (2026-09-25)

Steps 1-4 are hygiene **with one real bug behind them**. This is that bug, and it is worth fixing for its
own sake.

`auth_state.dart` keeps `_tokenCache`, `_userIdCache` and `_userTypeCache` as **shared** fields, but
**both domains write them**:

- `setSuperAdminAuthState(...)` → `_tokenCache = token`
- `setFactoryAuthState(...)` → `_tokenCache = token`

And the **factory** side reads them back as if they were its own:

```dart
// billing_remote_datasource.dart
final token = getFactoryAuthToken();   // returns _tokenCache
final factoryId = getFactoryId();      // returns _factoryIdCache
```

**So: after a super-admin login, `getFactoryAuthToken()` returns the *admin* token.** Any factory billing
call made in that state sends the admin's Bearer token to a factory endpoint. `_factoryIdCache` is *not*
overwritten by the admin path, so it can still hold a stale factory id — producing a request carrying an
admin token together with a factory id.

That is exactly what §5c mechanism #4 was written to prevent — *"one bag of mutable state any panel can
write"*. It is a **credential-mixing defect**, not a style issue.

### Why a compatibility shim would be unsafe here

The obvious cheap fix — split the fields into domain classes and keep the old top-level names as
delegating wrappers — **cannot be done safely**, because for the shared fields (`tokenCache`,
`userIdCache`, `userTypeCache`, `isAuthCheckCompleted`) the shim would have to guess which domain a
*reader* meant. `getFactoryAuthToken()` clearly means factory; a bare `tokenCache` read has no recorded
intent. Guessing there is how you hand the wrong token to the wrong API.

**So the call sites must be migrated explicitly.** That is steps 3-4: mechanical, but per-file, with
`dart analyze` after each file.

## 17.9 Complete call-site inventory — the 11 files importing `auth_state.dart`

Obtained by grepping for **the import itself** (the precise method — it also surfaced two files an
earlier symbol-grep had missed). Every file below must be migrated:

| # | File | Domain it touches |
|---|---|---|
| 1 | `lib/routes/app_router.dart` | admin + factory + sub-admin reads (≈10 sites) |
| 2 | `lib/app/app_initializer.dart` | both writers + sub-admin |
| 3 | `lib/features/factory/admin/presentation/bloc/auth/factory_auth_bloc.dart` | factory |
| 4 | `lib/features/factory/admin/data/datasources/billing_remote_datasource.dart` | factory — **the §17.8 leak** |
| 5 | `lib/features/factory/admin/presentation/screens/factory_login_screen.dart` | factory |
| 6 | `lib/features/factory/admin/presentation/screens/codes/unit_codes/unit_code_generate_screen.dart` | factory (`getFactoryId`) |
| 7 | `lib/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart` | admin (`resetAuthState`) |
| 8 | `lib/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart` | sub-admin |
| 9 | `lib/features/nexa_admin/presentation/screens/super_admin/login_screen.dart` | admin |
| 10 | `lib/features/nexa_admin/presentation/screens/super_admin/bus_company_login_screen.dart` | admin — symbol set not yet read |
| 11 | `lib/features/nexa_admin/presentation/screens/super_admin/goods_company_login_screen.dart` | admin — symbol set not yet read |

**Suggested order** (safest first — and it closes the leak early):

1. `billing_remote_datasource.dart`, `unit_code_generate_screen.dart`, `factory_auth_bloc.dart`,
   `factory_login_screen.dart` → `FactoryAuthState`. **This step alone closes the §17.8 leak.**
2. `login_screen.dart`, `bus_company_login_screen.dart`, `goods_company_login_screen.dart`,
   `admin_auth_bloc.dart` → `AdminAuthState`.
3. `sub_admin_bloc.dart` → `SubAdminAuthState`.
4. `app_router.dart` → read the three instances instead of the shim.
5. `app_initializer.dart` → provide/write the instances last.
6. Delete the shim, then delete `auth_state.dart`; the guard and a grep must both be clean.

Each step is independently verifiable with `dart analyze <file>` (proven to work on targeted files,
including the largest graph) plus the human smoke-test list at the top of §17.

## 17.10 Why steps 1-4 were not executed in this session

Not for lack of information — §17.9 is complete and §17.8 proves the need. The blocker is **verification
depth**: the migration is ≈35-40 call sites across 11 files on the authentication path, each needing its
own analysis pass — and a **partially** migrated file, mixing the shim with a domain instance, is exactly
the state that hands the wrong token to the wrong API. Landing it half-done is worse than not landing it.

**Recommended next session:** run the §17.9 order, one file at a time, `dart analyze` after each, and the
§17 smoke-test list before the commit that deletes the shim.

---

# 18. Provenance — what this cycle changed

| Commit | What | Isolation baseline |
|---|---|---|
| `ca591a98` | CI boundary guard; measured the real debt | 84 |
| `969aab00` | 4 dead `core/` files removed | 77 |
| `3be02476` | dead `transport` + `transport_marketplace` removed (20 files, −6,116 lines) | 75 |
| `eba16ee6` | **§15b provider split** — `core → features` is now 0 | **28** |
| `9f59ef28` | **§17 step 5** — `/sub-admin/*` guard (owner smoke-tested: all pass) | 28 |
| `e723bcc0`, `22742200`, `3ada51b8` | plan records for the above, plus §17 research | 28 |

Also in this cycle (separate work streams, recorded in their own files): Phase 0a credential
remediation (`PHASE-0A-CREDENTIAL-REMEDIATION.md`), Pillar A and Pillar B and Pillar E specs, and the
subdomain linking playbook (`PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md`).
