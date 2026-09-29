# MASTER TASK LIST — the single plan (the only planning file)

**Purpose:** ONE ordered plan for the whole project. Every outstanding item, in the order it
should be done, with what is already finished recorded so nothing is re-done and nothing is
skipped. A **fresh session** reads `START-HERE.md` first, then this file, and **continues from
the first ⏳ item in §3**.

**Last updated:** 2026-09-29 (handoff folder consolidated: 12 files → 2).

**Consolidated on 2026-09-29 — this file now owns the material that used to live in:**
`PANEL-SEPARATION-PLAN.md` · `PANEL-SEPARATION-RECOMMENDATIONS.md` · `GROUP-INCHARGE-MODEL.md` ·
`PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md` · `PILLAR-A-BANKNOTE-AUTHENTICATION.md` ·
`PILLAR-B-PRODUCT-ANTI-COUNTERFEIT.md` · `PILLAR-E-IOT-VEHICLE-SECURITY.md`.
`PHASE-0A-CREDENTIAL-REMEDIATION.md`, `STREAMING-HISTORY-AND-FIX.md` and
`QODER-CRICKET-STREAM-BRIEF.md` were folded into **`START-HERE.md`**.
All ten files are deleted; their full text remains readable in git history
(`git log --oneline -- docs/handoff/`). The **original section numbers are preserved** in the
appendix (§14) and in `START-HERE.md`'s appendices, so every existing code/CI comment that cites
`…PLAN.md §7b.4`, `…PHASE-0A… §3.6.1`, etc. still resolves — only the file name changed.

**Read with:** `START-HERE.md` (workflow, commands, runbooks, live bugs).

---

## 0. How to use this file

1. Read `START-HERE.md` §0 first (the loop, the command rules, the restore-don't-rebuild rule).
2. Come here. **Start at the first ⏳ item in §3.** Do not re-do anything in §4.
3. State which item number you are doing; record the commit hash next to it when it lands.
4. Nothing here is optional and nothing is "obvious" — every item exists because it was decided.

---

## 1. Ground rules (earned the hard way — follow them)

1. **Evidence before edits.** `git log -S "<string>"` and a live `psql` query settle "is this
   pre-existing or did we break it?" in one minute. Guessing cost real time (a JSON-path filter
   that passed `psql` but returned nothing through Eloquent; a blanket data migration that
   cross-assigned companies between groups).
2. **Restore, don't rebuild.** The owner's rule for this phase: bring back what was already
   tested; **no new features** while a phase is being restored.
3. **Never blind-fix.** If the cause is not proven, ask for the one command or file that proves it.
4. **Own it.** When the breakage is ours, say so plainly and fix it.
5. **Only essential commands in the IDE** (owner, 2026-09-29). Heavy commands — `flutter build`,
   release builds, whole-tree `dart analyze` — take 15–25 minutes, time out and waste the turn.
   CI already runs exactly those on every push. **Edit + push, read the CI result**; run locally
   only what is fast (`php -l`, `phpunit` on sqlite, `dart analyze` on the one feature touched).
6. **A failure must STAY, be COPYABLE and be CLOSABLE** — use `StickyErrorBanner`
   (`lib/shared/widgets/feedback/`), never a fire-and-forget SnackBar.
7. **The Super Admin and every Sub-Admin own no factory and no product** — oversight is read-only.
8. **Kisan / agri belongs to the B2B side** (`market.traceodd.com`), never the B2C Universal app.
9. **The branch is `mainnew`.** A push to it deploys (`frontend-deploy.yml`, `deploy.yml`, `tests.yml`).

### Hard rules (§9 of the separation plan — verbatim)

1. **Never move two departments in one commit.**
2. **Never change a route path and a folder in the same commit.**
3. **`lib/shared/` must never import `lib/features/`.**
4. **A widget used by 2+ departments belongs in `shared/`, not in either department.**
5. **Enforce the layering rule in CI, not by convention.** A rule that lives only in a document
   gets broken again. (`node .scripts/check-panel-isolation.mjs` — already live.)
6. **Verify against the Phase-0b baseline after every phase.**
7. **Do not create `lib/features/fleet/{owner,driver,conductor}/`** — rejected in D1.
8. **The legacy spec contradicts this plan** on fleet unification. Follow the owner; the spec
   needs a correction pass.

---

## 2. ⭐ The owner's TOP-LEVEL priority order (2026-09-26)

Where this conflicts with the phase order in §3, **THIS wins**.

| # | Priority | What it means |
|---|---|---|
| **1** | **End the mixing. Remove junk files and code.** Take the Super Admin panel out of every group's account creation; confine every sub-admin to its own domain | ← largely done (C2/C3/C2b); the error-surface sweep is the live part |
| **2** | **Build the missing dashboards** — any panel/app whose build or dashboard does not exist yet |
| **3** | **Test that every panel/app can LOG IN and reach its own dashboard.** Login + dashboard entry **only** |
| **4** | **Subdomain + Cloudflare** for every panel/app not yet linked |

**Standing scope rule (owner, same message):** *"for now we are not doing much internal coding."*
Priority 3 means **login + dashboard entry only** — do **not** start fixing what is inside each dashboard.

---

## 3. THE ORDERED QUEUE — work top to bottom

Old item numbers from the previous `MASTER-TASK-LIST.md` are given in brackets where useful;
**the new numbers below are the authority**.

### STAGE 0 — Owner-side security (runs in parallel; blocks nothing else)

| # | Task | Notes |
|---|---|---|
| **1** | **Rotate the leaked credentials and close the DB exposure** — owner, server-side | See `START-HERE.md` Appendix A (was `PHASE-0A-CREDENTIAL-REMEDIATION.md` §3.1→§3.10): check `pg_hba.conf` for `0.0.0.0/0` on port **5444** → restrict (Hetzner Cloud Firewall first, `ufw` second) → `ALTER ROLE` ×4 (`postgres`, `nexa_app`, `nexa_readonly`, `nexa_superadmin`) → update `.env` `DB_PASSWORD` **immediately** → SSH root key-only → panel logins (`global_identities` + `tenant_accounts`, same hash) → Super Admin `admin_users` via Appendix A §3.6.1 → verify from outside. Deleting the string does **not** undo exposure; only rotation does |
| **1b** | **Correct the §3.10 server findings** while on the box | ① `APP_DEBUG=false` (production was leaking stack traces) ② install `php8.3-intl` ③ `chown -R www-data:www-data bootstrap/cache storage` and run artisan as `www-data` ④ `chmod 640 .env` ⑤ delete the stray `md5` line in `pg_hba.conf` ⑥ re-deploy so the seeder fixes reach the server |
| **2** | **Flip the super-admin shadow gate to enforce** — owner | Read the `super_admin_gate.shadow` log lines, confirm the intended admins appear **authorised**, then set `SUPER_ADMIN_GATE_ENFORCE=true` + `php artisan optimize:clear && php artisan optimize`. Until then `super_admin.php`'s 19 routes are `auth:sanctum` only |
| **3** | **Make the secret scan a hard gate** | Confirm `Secret scan (working tree)` reports **0 leaks**, then delete `continue-on-error: true` from `.github/workflows/secret-scan.yml` and add a `main` branch-protection rule. Once §1 is done, switch scanning to history (with an allowlist entry + rotation note) |
| **4** | **Add the Cloudflare `market` A-record** — owner | `market` → `135.181.46.27`, **proxied** (orange cloud), TTL auto — exactly like the existing `cricket`/`studio`/`broadcaster` records. Completes the public marketplace site (old #12) |

### STAGE 1 — Finish the "errors stay + copy" sweep  ← **START HERE (dev)**

| # | Task | Notes |
|---|---|---|
| **5** | **Errors stay + Copy — Sub-Admin panel screens** ✅ **done (this commit)** [old #6] | `StickyErrorBanner` now covers: the 3 list failures in `sub_admin_dashboard.dart` (bus / factory / reseller — each with its endpoint as the `source` line), the 3 create+edit form errors, the 3 sheet `actionError`s, the login screen's `authError`, and the Cricket Manager list/add/edit pages (list fetch, activate/suspend/delete, create, update). `ClearSubAdminError` now also clears `factoryFormError` / `resellerFormError`, so a dismissed banner really goes away (and a retry with the same message can show again). Dismissing a **list** error hides the banner but does **not** fall back to the "Nothing here yet" empty box |
| **6** | **Errors stay + Copy — Super Admin screens** ⏳ **[START HERE (dev) — in progress]** [old #7] | **Done (this batch):** the 6 fleet list screens — `bus_fleet/{fleet_drivers,fleet_owners,fleet_conductors}_screen.dart` and `goods_fleet/{goods_fleet_drivers,goods_fleet_owners,goods_fleet_conductors}_screen.dart`. Each keeps one `_error` + `_errorSource`, gains a `_fail(e, source)` helper, and renders a `StickyErrorBanner` + Retry above the list — so a failed load **or** a failed add/edit/status/delete stays, copies and closes (and a dismissed list error never falls back to the "Nothing here yet" empty box). **Still to convert:** `bus_company_login_screen`, `goods_company_login_screen`, `all_tickets`, `bonus_management`, `route_scheduler` (2 classes), `ticket_management`, `voucher_management`, `bus_fleet_dashboard_screen` (4 classes), `companies_list`, `company_detail`, `plans/plan_detail`, `reseller_management_list`, `billing/*` (5), `site_content/*`, `transport/*`, `dashboard_screen`, `super_admin_shell` — **plus the two Sub-Admin management screens** (`sub_admin_list_screen.dart`, `add_sub_admin_screen.dart`), which sit in the `sub_admin/` folder but are reached from the Super Admin shell |
| **7** | **Errors stay + Copy — other apps** ⏳ [old #8] | Reseller, Shop Keeper, Cricket |
| **8** | **Drivers list → `StickyErrorBanner`** ⏳ [M7] | The drivers list still uses the day-long SnackBar stopgap from the original #4. It already stays and copies; this is a consistency move |
| **9** | **Dead placeholder buttons on the Factory dashboard** ⏳ [M8] | `_showSnackbar('Navigate to products management')`, `'Generate Codes'`, `'View Reports'`, `'Settings'`, `'Add new product'`, `'upgrade screen'`, `'Driver contact flow not wired yet'`, `'Load posting flow not wired yet'` — they look wired but do nothing (same class as old #32/A3). The real destinations already exist as routes |

### STAGE 2 — Small live defects and one blocking decision

| # | Task | Notes |
|---|---|---|
| **10** | `flutter_service_worker.js` served as `text/html` ⏳ [old #25] | nginx falls through to `index.html`, so the file is missing from the deployed dir (or its `location` block is absent). Cosmetic but it disables Flutter's own cache-busting. Check the deployed bundle + `.nginx/*.conf` |
| **11** | `GET /api/v1/admin/analytics/dashboard` → **500** ⏳ [old #26] | Pre-existing `AnalyticsService` (Module 1D). Get the real exception from `laravel.log` first. Prime suspect: the pgsql-unsupported `PDO::ATTR_CONNECTION_STATUS` at `AnalyticsService.php:233`; second: `base_codes.generated_at` |
| **12** | Two remaining **literal-IP** bugs ⏳ [old #27] | `live_bus_tracking_screen.dart:48` and the reseller link copy in `reseller_management_list_screen.dart` |
| **13** | **Log flood** ⏳ [old #28] | The CORS logger writes 3 INFO lines per request, hiding real errors and growing the disk |
| **14** | **⭐ Decide the location plugin + map SDK** ⏳ | **One decision.** No map SDK, no API key and no "nearby" radius query exist anywhere today. This single choice unblocks **Pillar B** (velocity check), **Pillar C** (real bus telemetry), **Pillar E** (IoT), and **Module 19** (nearby workers). Recommended: `google_maps_flutter` + a real PostGIS/Redis-GEO radius query (see §14 appendix §13 note) |
| **15** | **Developer-environment fix:** revert the `node.exe` rename ⏳ [§16] | The owner renamed `C:\Program Files\nodejs\node.exe` → `node_v26.exe`; Zed still launches the literal path so its Node language servers fail to spawn. Restore the name, change the default Node version cleanly, restart Zed; if timeouts persist, reduce the LSP set (this repo is Flutter + Laravel + Rust; it does not need Tailwind/HTML/ESLint). Do **not** commit a machine-specific binary path into `.zed/settings.json` |

### STAGE 3 — Make the B2B marketplace usable end-to-end (owner priority 2 + 3)

| # | Task | Notes |
|---|---|---|
| **16** | **B2B its own login page + attach the old tested screen** ⏳ [old #15] | Group 2 must enter through its own door |
| **17** | **Reseller — verify + attach the existing login** ⏳ [old #16] | `main_reseller.dart` is live; confirm and wire |
| **18** | **Shop Keeper — minimal CRUD first (login + dashboard)** ⏳ [old #17, M2] | There is **no shop-keeper account type in the backend at all** (`POST /reseller/orders` is the only order endpoint). This is a Group-2 feature build |
| **19** | **#13 remainder — the cart must be able to place an ORDER** ⏳ [M1] | Decision required: **(a)** hand the visitor to the reseller app to finish, or **(b)** introduce a *buying session* where a visitor submits an order request the factory confirms. The cart + buying door are already live |
| **20** | **Orders / sell / buy visible in each panel's own marketplace section** ⏳ [old #14] | Factory: its own orders + history. Sub-Admin + Super Admin: read-only, platform-wide (already have `admin/marketplace/orders` + `summary`) |
| **21** | **`most sold` ordering + complete storefront category chips** ⏳ [M3, M5] | Storefront currently sorts by *most viewed* (real `view_count + inquiry_count`); true best-selling needs an aggregate over `reseller_orders.items`. Category chips come from the first unfiltered page only — a `/reseller/categories` endpoint fixes it |

### STAGE 4 — Authority, isolation, subdomains, separation phases

| # | Task | Notes |
|---|---|---|
| **22** | **C3b — make the Super Admin registries genuinely read-only** ⏳ [old #21] | `CompanyDetailScreen` still exposes status / verification / plan-assignment; the reseller list still exposes edit / suspend / approve / delete. C3/C2b removed **creation** only |
| **23** | **Verify callers, then remove `AdminCompanyController@store` / `POST /api/v1/admin/companies`** ⏳ [old #22] | Nothing in Flutter calls it now. **Verify first — do not remove blind** |
| **24** | **C4 — Super Admin read-only group activity + payments view** ⏳ | Per-group activity feed + payment records/graphs, read-only. Delivers most of the observation intent safely |
| **25** | **C5 — audited "enter sub-admin view"** ⏳ | Only after C4 and only with the audit chain. The 7 requirements: read-only by default; never the sub-admin's password (short-lived token with an `impersonated_by` claim); time-boxed (~15 min); visible to the sub-admin (banner); written to `audit_log_security`; a reason required on entry; hard-blocked server-side from changing passwords / moving money / deleting. Enforce with **one middleware** (`observation.mode` on the token → every non-GET fails) |
| **26** | **§17.9 steps 2–6 — finish the auth-domain split** ⏳ [old #24] | Admin + sub-admin domains still live in `lib/core/utils/auth_state.dart`. Migrate per §14 appendix §17.9 order (one file at a time, `dart analyze` after each), make `app_router.dart` read the three instances, then **delete `auth_state.dart`**. Human smoke-test the six flows before the delete commit. (Factory half already done: `FactoryAuthCache`) |
| **27** | **Phase 0b — record the baseline before any design/behaviour change** ⏳ | Write `docs/handoff/PANEL-BASELINE-STATE.md` (per-panel URL, login works?, screens verified) + `nginx -T` + server listings, **and screenshot every panel** (Phase 3 restyles 4 theme roots). Verify each panel's build |
| **28** | **Phase 1 remainder — the layering extractions** ⏳ | ① make `main.dart` a thin **Super-Admin-only** launcher ② move `bus_tracking_models.dart` → `shared/` (or the telemetry bloc → BUS) ③ break the SUPER ↔ BUS cycle (extract `route_scheduler` / `ticket_management` / `voucher_management` / `bonus_management` → neutral `shared/fleet/`) ④ give GOODS its **own** driver + conductor pages (today `main_truck_driver.dart` / `main_truck_conductor.dart` open BUS pages verbatim). (Providers split and the CI guard are already done) |
| **29** | **Phase 2 — router extraction** ⏳ | Split `lib/routes/app_router.dart` per the corrected map in §14 appendix §7. One commit. Public bypasses (`return null`) stay in the base router. ⚠️ Open decision: whether `/resellers`, `/resellers/add` (lines 759–772) move to `b2b_routes.dart` or stay with the Super Admin shell |
| **30** | **Blocker A — add the 5 missing builds** ⏳ | `frontend-deploy.yml` never builds `main_bus_driver`, `main_bus_conductor`, `main_truck_owner`, `main_truck_driver`, `main_truck_conductor`, yet `traceodd.conf` points nginx at their directories → those paths 404. Blocks surfaces #12, #13, #17, #18, #19 |
| **31** | **Subdomain + LOCK, in waves** ⏳ | Method: separate → verify → LOCK, **one panel per commit** (hard rule 1). Waves per §14 appendix (was the playbook §7): **W1** #5 Reseller · #9 Factory Driver · #10 Bus Fleet · #11 Bus Owner · #14 Bus Store Keeper → **W2** the 5 Blocker-A surfaces → **W3** #1/#2/#3/#7/#8 (need item 28) → **W4** the unbuilt ones. Each LOCK needs: own entry point + build step, own nginx vhost with exact `server_name` and no catch-all, Cloudflare A record, password rotated + login proven, another panel's prefix → **403**, `dart analyze` clean |
| **32** | **Phase 3 — design-system consolidation (D4)** ⏳ | Canonical = Cricket's pencil + colour style, **tokenised**. Converge the 4 theme roots (`AppTheme`, `shared/app_scaffold.dart` inline `ThemeData`, `LandingPalette`, `CricketColors` + `core/theme/branding_config.dart`); adopt `shared/theme/app_decorations.dart` (do **not** delete it); introduce accent-role tokens; retire the 85 inline `Color(0x…)`, 182 `TextStyle(`, 191 `BorderRadius.circular(`. Restyles approved panels → the item-27 screenshots are mandatory |
| **33** | **Phase 4 — pilot: B2B (Group 2) end-to-end** ⏳ | Rename `features/reseller/` → `features/b2b/`; add the Shopkeeper sub-app; `lib/main_b2b.dart` → `B2bApp` → `B2bAppInitializer` → `B2bRouter` (each sub-app keeps its **own login page**); add the build + deploy; `b2b.traceodd.com`. Leave the old `/reseller/` path working until verified |
| **34** | **Phase 5 — remaining departments, in dependency order** ⏳ | B2B ✅(item 33) → Cricket → Factory → Bus → Goods → Customer → Super Admin. (Bus before Goods; Super Admin last.) Per department: `main_*.dart` → initializer → router → deploy step → subdomain |
| **35** | **Phase 6 — dynamic Sub-Admin roles + per-department API** ⏳ | ① drive the Super Admin create/edit UI from `feature_registry` (persist to `sub_admin_feature_grants`) — remove the hardcoded 5-vertical list ② enforce grants at request time via a **route-to-feature map** (one middleware check against one map — no per-controller policies) ③ **apply `sub.admin` to every panel route group** (today exactly one place: `routes/panels/cricket.php:248`) ④ every sub-admin gets its own dashboard from its grants (today only `cricket_ops` differs; `vehicle_security`/`trust_safety` land on the bus console) ⑤ free-agent driver identity: `driver_identities` + `driver_company_links` (time-bounded, fleet-typed) ⑥ unify the 5 auth stacks ⑦ one API prefix + guard per department. **Exit:** a sub-admin with only "goods" toggles reaches goods and nothing else. ⚠️ Before this: narrow `commercial_marketplace`'s wildcard `factory.*` bundle |
| **36** | **Phase 7 — duplicate consolidation** ⏳ | Complete the §6 deletion list (§14 appendix). Key one: **merge** the orphaned `lib/features/universal/customer/**` into the **live** `lib/features/bus_operations/presentation/pages/customer_super_app_screen.dart` (port the real scan bloc + Bluetooth/hardware-scan + websocket bloc first), **then** delete the folder. Also: 7 unrouted `nexa_admin` billing screens + billing usecases; 6 unrouted `bus_operations` pages (`route_list/editor/detail`, `ticket_vault`, `driver_trip`, `live_bus_tracking`) + `qr_code_painter` + `driver_gps_beacon`; ~24 unused `shared/` widgets (except `app_decorations.dart`); `core/services/{payment_service,subscription_validator,supabase_chat_service,multi_tenant_service,code_generator_service}.dart` + `core/constants/{fleet_constants,plan_limits}.dart` (after the §10/Q3 "planned dependency" check). Fix the name collisions (`storekeeper` vs `factory/store_keeper`; `SearchAppBar` ×2; `PanelAuthState` ×2) |
| **37** | **Phase 8 — server separation** ⏳ | Only possible because Phase 6 made coupling API-only. **Move the media engine first** (nearly free: own CI `media-engine-build.yml` + `media-engine-deploy.yml`, self-contained Docker image, own host — but stateful, needs room→server affinity). Then split the API (stateless app servers + shared DB + Redis behind a load balancer); the frontend last (static, trivial) |

### STAGE 5 — Hygiene and tracked debt

| # | Task | Notes |
|---|---|---|
| **38** | **Native / Rust layer hygiene** ⏳ [§13] | ① **Owner decision:** migrate `flutter_rust_bridge` to v2 **or** remove it and make `ffi_abi.rs` the documented contract (**recommended: remove** — Cargo pins 1.82.4, `pubspec` declares ^2.11.1, zero generated artifacts, no `build.rs`) ② fix the `verify_serial_on_device` symbol mismatch (`rust_serial_validator.dart:111` looks up a symbol no Rust code exports → the intended Dart fallback is bypassed) ③ add a free contract for response strings (per-call leak; e.g. `nexatrace_free_string`) ④ fix the **packaging gap** (§13.5 — no `CMakeLists.txt` / `*.podspec` / Gradle `cargo`, so the `cdylib` never reaches a device; this blocks any Rust kernel inside a mobile surface) ⑤ `todd-cricket` drift-check: **option B now, C later** (build + deploy `todd-cricket`, set `CRICKET_RUST_BINARY`; no workflow builds it today; option A is rejected — duplicate scoring logic is a defect) |
| **39** | **`§14` risk-register debt** ⏳ | ① set `BROADCAST_DRIVER=reverb`, `CACHE_STORE=redis`, `QUEUE_CONNECTION=redis` in production + add a startup health check (realtime is silently degraded on `log`/`database` today) ② stop shipping fabricated telemetry (driver GPS strings; `fleet_live_map_canvas.dart` is a pseudo-position painter) ③ `/customer/my-tickets` is not a route — add it during the item-36 merge or remove the button ④ burn down the 57 `dart analyze` warnings, then flip to fatal ⑤ triage the 37 composer advisories (11 packages) ⑥ three parallel HTTP clients, two WebSocket stacks, unused `get_it`, the `setState()` backlog |
| **40** | **CI / ops remainder** ⏳ [§9b + the recommendations doc] | ① replace the hardcoded `root@135.181.46.27` (**28 occurrences**) in `frontend-deploy.yml` with `${{ vars.VPS_HOST }}` — **create the repo variable first** ② add `.github/CODEOWNERS` ③ per-panel `paths:` filters (do this with item 34) ④ weekly dependency-graph audit (`schedule:`) ⑤ the five proposals unique to the old recommendations doc: Contract tests (Pact/schema) · build-size monitoring (>10% regression) · per-panel Sentry DSNs · per-panel analytics (mixpanel/posthog) · per-panel semver ⑥ accessibility (WCAG) discipline + a per-feature `README.md` under each `features/<panel>/` (also from that doc; low priority) |

### STAGE 6 — The product pillars

| # | Task | Notes |
|---|---|---|
| **41** | **Pillar B — product anti-counterfeit (fastest win)** ⏳ | Backend is **READY**; the Flutter scan flow exists but sits in the **orphaned** copy. **B1** fix the stale route-map entry (`panel_routes.dart:305` says `/api/v1/consumer/verify`, which 404s; real = `POST /api/v1/marketplace/consumer/verify`) + settle the location source (item 14) → **B2** consolidate the two customer super-app copies (item 36) → **B3** camera sheet + wire `HardwareScanService` → verify bloc → **server** verification + result card → **B4** offline path (`scanUuid` idempotency) → **B5** reuse on staff surfaces with `/factory/production/verify-serial` → **B6** counterfeit-report action (confirm Module 8N backend exists). **Never accusatory wording**; `lat`/`lng` are required — never fabricate coordinates. Remove the dummy on-device Rust scan path; `_rewardPerScan = 5` must not survive |
| **42** | **Pillar C — bus fleet super-app: real GPS + real map SDK** ⏳ | Backend strong (bookings, holds, `absolute_bus_layouts` + revisions, vouchers, wallets, `passenger_safety_tokens`, family stream). Frontend: seat map excellent; telemetry/map stubbed. Shares the map-SDK decision with Pillars B/E and item 14 |
| **43** | **Pillar D — goods transport & freight** ⏳ | Freight ✅ (`freight_loads`/`freight_bids`, `FreightAuctionService`, matching job, `BiddingMeshController`); **relocation ❌**; **no `trucks` table**; **no `parcels` table**. Frontend minimal (`goods_operations` = 5 files). **A plan for this pillar has not been written yet** |
| **44** | **Pillar E — IoT vehicle security** ⏳ | Phase 1 = **server + simulated devices** + data model + geofencing + alerts + app UI (pure software, de-risks everything) → Phase 2 hardware pilot (needs **PTA type approval** + SIM strategy) → Phase 3 **immobilization** with the §7 fail-safes (required written sign-off) → Phase 4 fleet analytics. Reuse `financial_wallets` and the §10.8 audit chain; do **not** hand-roll a GPS parser; device identity = per-device X.509 + mTLS, never a shared key |
| **45** | **Pillar A — PKR banknote authentication** ⏳ | **Gate:** SBP written clarification (currency handling, note imaging, serial verification) **before Phase 1 coding**. Then Phase 1 guided capture + quality gate + OVI heuristic (on-device) → Phase 2 thread/fibre (native kernel) → Phase 3 server model. **Owner decisions bound:** no authenticity verdict ever; wording "Standard Pattern Matched" / "Suspicious Pattern Detected" only; never "Authentic"/"Fake"/"Jaali"; the bank-branch advisory is mandatory on the result screen. Depends on §13.5 packaging for the Rust kernel |

### STAGE 7 — Remaining modules

| # | Task | Notes |
|---|---|---|
| **46** | **Group 9 — Marketing & Growth (C1b)** ⏳ [old #23] | Its own design step. Four surfaces (each its own app): Marketing Sub-Admin → District Marketing Administrator (sub-admin decides how many districts each holds) → District Marketing Manager → Marketing Agent. Commission is a **time-tiered split** of the subscription, always shared by Agent + Manager + Administrator + TraceOdd, executed by the **idempotent split engine — no second ledger**. Per-person compensation mode (salary / salary+commission / commission-only) set at approval. Managers also **onboard clients** (needs `created_by` attribution). Carries **how-to courses per panel/app**. District allowances stored **per person**, not derived from a fixed hierarchy. Open: is a district a `districts` row? Under or beside the Group-Incharge model? Shared or separate identity per level? Who edits the split percentages? **No clawback** — accrual is per month actually paid |
| **47** | **Phase K — KISAN (agri-marketplace) & advance demand** ⏳ | **K1** B2B Kisan onboarding + Agri-Producer Dashboard on `market.traceodd.com` (role `kisan_producer`, `poster_type='kisan'`) → **K1b** Kisan Verification Manager panel (B2B Sub-Admin creates unlimited managers, one per district/open area; producers only) → **K2** crop listing + direct bidding (`FreightAuctionController` — a kisan is a `poster_type`, not a new schema) → **K3** automatic logistics hand-off to nearby trucks (`BiddingMeshController` + `TruckCategory.shahzoreLoader`) → **K4** batch QR on loading → **K5** forward demand (3–6 months) → **K6** advance token/escrow via the split engine. **Boundary rule:** no B2B trading code in the B2C Universal app, and no Kisan account type in it |
| **48** | **⭐ MODULE 19 — Services & Skilled Workers Grid** ⏳ | New module. Full specification + the 3-section review in **§8** below. Sequence **S1 → S2 → S3 → S4**. Depends on items 14 (map/location), 16–18 (B2B auth + roles), and 35 (real request-time enforcement of sub-admin/vertical grants) |

### Parked by the owner (do not start without a new instruction)

| # | Parked item | Why |
|---|---|---|
| **P1** | **Factory logo** in the panel (`companies.logo_url`; decide where the factory uploads it) ⏳ [old #18] | Parked until this panel is worked on properly |
| **P2** | **Three reseller types** — wire the fields that already exist: `is_msrp_enforced`, `factory_buy_price`, `reseller_sell_price`, `ResellerPortalService::enforceMSRP()` ⏳ [old #19] | Parked until all groups are done. **These are wiring, not invention** — the schema is already half-built |
| **P3** | **Type 3 (middle man)** — `agent_code` on the order + `commission_rate` + `payout_frequency` (weekly/15-day/monthly) + `payment_terms`. Payment **always direct to the factory**; the factory pays the agent a fixed commission through the **existing idempotent split engine** ⏳ [old #20] | Parked with P2 |
| **P4** | **`most sold`** / chips — see item 21 | Kept honest rather than faked today |
| **P5** | Revisit **Kisan bulk onboarding** when a real cohort needs scale — likely shape: a Marketing-style field hierarchy that onboards producers | Recorded so it is not re-designed as a separate app |

---

## 4. ✅ Done — do not redo (ledger)

Old item numbers are shown; they are **closed**. Full commit hashes live in §11 provenance.

| Old # | Item | Landed |
|---|---|---|
| 1 | Factory's own registered name in the panel header (+ cold start) | `59df9beb` |
| 2 | Remove the Factory dashboard's hardcoded demo figures + demo product rows | `39bb81c6`, `606fdef6` |
| 3 | Shared `StickyErrorBanner` widget (stay + Copy + X) | `a9c0ecec` |
| 4 | Errors **stay + Copy** — Drivers screen (first screen) | `a180f573` |
| 5 | Errors **stay + Copy** — 15 remaining **Factory panel** screens | done |
| 6 | Errors **stay + Copy** — **Sub-Admin panel screens** (dashboard · login · Cricket Manager list/add/edit) | this commit |
| 9 | **Marketplace upload flow** — `MarketplaceListingService` + wired into `ProductController` `store`/`update`/`marketplace-toggle`; storefront created on first upload | done |
| 10 | Publish the **6 existing factory products** (`marketplace:publish-products --all`) | live 2026-09-28 |
| 11 | A **Marketplace section** on each of the three panel dashboards | `Factory` section + read-only Sub-Admin/Super-Admin oversight; backend `admin/marketplace/orders` + `summary` |
| 12 | **Public read-only marketplace site** (`market.traceodd.com`) — app + nginx + deploy built; **only the Cloudflare record is left** → item 4 | built |
| 13 | **Cart + the buying door** on `market.traceodd.com` (add to cart, MOQ-aware cart, register page) | built — the **order** is item 19 |
| — | Sub-Admin **full edit form** (name, email, phone, vertical, password) + `phone` support in `SubAdminController@update` | done |
| — | `subadmin.traceodd.com` vhost | done |
| — | **Error-copy fix** (#37 — sticky panel for uncaught errors + manual-copy fallback over plain HTTP) | done |
| — | Canonical brand lockup on the market site | done |
| — | **A1** double-hash footgun removed (`AdminUser`/`GlobalIdentity` `setPasswordAttribute` guard) · **A2** `CompanyRegisterBloc` (superseded by C3) · **A3** dead sidebar button | `3b072d09` |
| — | **B1** factory auth domain split (`FactoryAuthCache`) — closed the cross-domain token leak both directions | done 2026-09-26 |
| — | **C0** Group-Incharge design · **C1** missing verticals + `financial_auditor` owns `plans.*`/`billing.*` · **C2** factory creation → Factory Sub-Admin · **C3** Super Admin no longer creates factories · **C2b** reseller creation → `commercial_marketplace` | done 2026-09-26 |
| — | **§15b** provider split (`core → features` = 0) · **§17 step 5** `/sub-admin/*` guard | `eba16ee6`, `9f59ef28` |
| — | **CI boundary guard** + dead-file removals + duplicate Super Admin bus/goods registration removed (−2,346 lines) | `ca591a98`, `969aab00`, `3be02476`, `126f618d` |
| — | Plaintext DB credentials deleted; `tests.yml` branch trigger fixed; `consumer` panel registered; super-admin shadow gate; `dart analyze` in CI; `missile_3d_button` promoted; one real Flutter test added | `bdb3001d`, `e1e181b2`, `11dbaf8f`, `6a400138`, `ce560194`, `3fbbeb90`, `d95ac9f1` |
| — | **Streaming forwarder fix** (declare/feed + codec filter + the RTP `payload` fix) + far-end health + HLS-advancing check + scheduler cron | `f0fc72e5`, `e951903b`, `ead72810`, `01f5905e`, `269478ef`, `6c57fdc0` |

### Items that were wrong and are fixed (kept so nobody "re-fixes" them)

| Old # | What happened | Fixed by |
|---|---|---|
| 29 | **Cross-group data assignment.** Every unowned company was handed to the Factory incharge → a bus-fleet and a goods company appeared in the Factory Sub-Admin panel. Corrected to assign by the row's own type (`company_type`/`company_type_tag`), NULL = platform-owned | `a1457b09` → `7d0eb639` |
| 30 | **JSON-path scoping.** The Factory Sub-Admin list filtered on `metadata->>created_by_sub_admin_id`; that predicate returned the row in `psql` but **nothing** through Eloquent → API answered `200` with `[]` and the UI showed "no data". Replaced with a real indexed column | `facc964f` |
| 31 | **Mixed content.** `ApiEndpoints.baseUrl`, `AppConstants.baseUrl`, `PanelRouteConfig.baseUrl` were compile-time constants holding an **HTTP IP** → every admin call blocked on HTTPS | `a93dbb1f` |
| 32 | **Dead sidebar entries.** Any `AdminSidebar` item **with children** got `onTap: () {}` → Products / Store Keepers / Drivers / all Codes permanently dead | `deb1d661` |
| 33 | **Missing `drivers` table.** Dropped in the Wave-1 cutover but `Factory\DriverController` still used it → 500 on list/create, hidden because the sidebar entry was dead (#32). Table restored | `328490ee` |
| 34 | **Factory name never reached the header.** Login writes the cache from two places; the bloc ran first without `companyName`, and the screen listener was guarded by "if not already authenticated" | `59df9beb` |
| 35 | **Four Sub-Admin actions 404'd silently** (`toggle-status`, `change-vertical`, `reset-password`, `restore`) | fixed in the Flutter bloc |
| 36 | **`market.traceodd.com` rendered BLANK.** The deploy copied a hand-written `index-marketplace.html` over the **built** `index.html`, restoring the literal `<base href="$FLUTTER_BASE_HREF">` placeholder. Fix: never overwrite the built file — `.scripts/patch-marketplace-head.py` patches it in place | fixed |
| 37 | **"The error shows but it does not copy."** ① an uncaught error never reached the banner → `installCopyableErrorSurface()` overrides `ErrorWidget.builder`; ② `Clipboard.setData` fails silently over plain `http://` (needs a secure context) → manual-copy dialog fallback | fixed |
| **37b** | **"Neither before nor now does it copy" — still, on the raw IP.** The #37 fallback only fired when `Clipboard.setData` **threw**. In an insecure context it does not throw — it silently does nothing — so the button looked like it worked while the clipboard stayed empty. Now the insecure context is detected up front (`clipboardLikelyUnavailable` in `lib/shared/widgets/feedback/copyable_error_surface.dart`: `!kIsWeb`-safe, `https`/`localhost` exempt) and the manual-copy dialog is shown directly. `StickyErrorBanner` also gained an optional `stack` (appended to the copied text, never rendered), so a **minified** web error ("minified:SU") arrives with its trace. `/factory/orders` additionally: parses `reseller-orders` **eagerly** (`Map<String,dynamic>.from`, not a lazy `.cast` view — a rejected cast threw later, during build, and became a screen-level error), captures+logs the stack, and shows status-update failures in a banner instead of a fire-and-forget SnackBar. The **bundle tab's** error ("Failed to load bundles") is now a `StickyErrorBanner` too (it was plain grey text), and the reseller error text is `SelectableText` | this commit |
| **37c** | ⚠️ **RULE — do NOT "fix" the minified type error.** Owner, 2026-09-29, on `TypeError: type 'minified:SV' is not a subtype of type 'String'` on `/factory/orders`: *"maine aap ko error theek karne ka nahi kaha, balkeh error COPY hona chahiye."* The requirement is that every failure be **copyable** (and stay + close) — **not** that the underlying defect be patched. A defensive rewrite of `BundleModel.fromJson` (coercing the String fields) was written and then **reverted** for exactly this reason. If a screen is unusable because of an error, the fix is to make that error reportable and hand the report on — fixing the defect itself is a **separate, owner-approved** task | recorded |

---

## 5. Registry — surfaces, groups, modules

### §11 — Ecosystem registry: every app and panel (26 surfaces, 8 groups)

This is the **counting authority** (supersedes the informal "18 panels" and the spec's "15 modules"). Numbers are **stable**; a retired surface keeps its number and is marked retired.

| # | Surface | Group | Entry point / folder | Backend panel | Status |
|---|---|---|---|---|---|
| 1 | Super Admin Panel | 1 Platform | `main.dart` | `super_admin.php` | Live |
| 2 | Sub-Admin Panel | 1 Platform | `main.dart`, `sub_admin_login_screen.dart` | `super_admin.php` (`sub.admin`) | Live (roles static) |
| 3 | Universal Customer App | 1 Platform | ⚠️ **2 copies** — see item 36 | `consumer.php` | Partial |
| 4 | B2B Marketplace | 2 B2B | own entry point | `marketplace.php` | Live |
| 5 | Reseller App | 2 B2B | `main_reseller.dart` | `marketplace.php` | Live |
| 6 | Shop Keeper App | 2 B2B | — | `marketplace.php` | **0 work** |
| 7 | Factory Admin Panel | 3 Factory | `main.dart` | `factory.php` | Live |
| 8 | Factory Store Keeper App | 3 Factory | `main.dart`, `features/factory/store_keeper/` | `factory.php` | Live |
| 9 | Factory Driver App | 3 Factory | `main_driver.dart`, `features/factory/driver/` | `factory.php` | Live |
| 10 | Bus Fleet Admin Panel | 4 Bus | `main_bus_fleet.dart` | `bus_fleet.php` | Live |
| 11 | Bus Owner App | 4 Bus | `main_bus_owner.dart` | `bus_owner.php` | Live |
| 12 | Bus Driver App | 4 Bus | `main_bus_driver.dart` | `bus_fleet.php` | Live (GPS stub) |
| 13 | Bus Conductor App | 4 Bus | `main_bus_conductor.dart` | `bus_fleet.php` | Live |
| 14 | Bus Fleet Store Keeper App | 4 Bus | `features/storekeeper/` via `main_bus_fleet.dart` | `bus_fleet.php` | Live |
| 15 | Goods Company Admin Panel | 5 Goods | — (no entry point) | `goods_fleet.php` + `Admin\GoodsFleetController` | **Missing** |
| 16 | Goods Store Keeper App | 5 Goods | — | `goods_fleet.php` (planned) | **Not built** |
| 17 | Truck Owner App | 5 Goods | `main_truck_owner.dart` | `truck_fleet.php` | Live |
| 18 | Truck Driver App | 5 Goods | `main_truck_driver.dart` | `truck_fleet.php` | Live (imports BUS pages) |
| 19 | Truck Conductor App | 5 Goods | `main_truck_conductor.dart` | `truck_fleet.php` | Live (imports BUS pages) |
| 20 | Cricket Manager Panel | 6 Cricket | `main_cricket_manager.dart` | `cricket.php` | Live |
| 21 | Todd Studio | 6 Cricket | `media-engine/ui/todd-studio-gui/` | `studio.php` | Live |
| 22 | Todd Broadcaster App | 6 Cricket | `apps/broadcaster-android/` | media-engine | Live (WHIP untested) |
| 23 | Cricket Public Viewer | 6 Cricket | `main_cricket_public.dart` | `cricket.php` | Live |
| 24 | Device Security (IoT) Panel | 7 Vehicle Security | — | — | **0 work** (Pillar E) |
| 25 | Jaali / Asli / Naqli Note Panel | 8 Trust & Safety | — | — | **0 work** (Pillar A) |
| 26 | Landing Page | *(ungrouped)* | `main_landing.dart` | `public/content` | Live |

**Groups:** 1 Platform · 2 B2B Commerce · 3 Factory · 4 Bus Fleet · 5 Goods/Truck · 6 Cricket · 7 Vehicle Security · 8 Trust & Safety · **9 Marketing & Growth** (added 2026-09-26, item 46 — its **four surfaces are not yet numbered**).
**Counting rules:** a surface counts if it has its own login and/or its own entry point or build target. Shared code (`lib/shared/`, `lib/core/`, a group's `lib/features/<dept>/`) is **not** a surface. **One-time re-baseline happened 2026-09-24**; numbers are stable after it.

### Module registry (`NEXATRACE_SUPREME_MASTER_SPEC.md`)

| Module | Name |
|---|---|
| 1–17 | as in the spec (1 Super Admin · 2 Sub-Admin · 3 Factory · 4 Factory Drivers · 5 Store Keepers · 6 Reseller · 7 Shop Keepers · 8 Customers (2-in-1) · 9 Goods Company Admin · 10 Truck Owners · 11 Truck Drivers · 12 B2B Marketplace · 13 Public Transport Bus Admin · 14 Bus Owners · 15 Bus Drivers · **16 consolidated into 8** · **17 permanently removed**) |
| **18** | **KISAN (Agri-Marketplace) & Advance Demand Forecasting** — Phase K, item 47 |
| **19** | **SERVICES & SKILLED WORKERS GRID** — item 48, full spec in **§8** |

---

## 6. Decisions and the isolation model

### Owner decisions (the plan's D1–D4)

- **D4 — design language.** Cricket's pencil style + colour style, **tokenised into `shared/`** and applied to every panel/app. Canonical palette from `CricketColors`: background `#0A0E21` · surface `#141829` · surfaceElevated `#1E2238` · inputFill `#1A1E31` · border `#2A2E41` · textPrimary `#F5F5F5` · textSecondary `#A0AAB8` · textTertiary `#6B7280` · textAccent `#00C49F`. Accent roles currently hardcoded at `manager_dashboard_page.dart:363,537,579,586,605`: `accentPrimary #10B981` · `accentInfo #2563EB` · `accentWarning #F59E0B` · `accentFeature #8B5CF6` · `accentMuted #1A3A4A` · `accentDanger #F44336`. Order of work: canonical token file → repoint the old palettes as thin aliases → promote `missile_3d_button` to read accent roles → migrate panels one department at a time → retire raw literals. Item 32.
- **D1 — bus vs goods.** Driver apps **stay separate** (bus = seats/ticketing; truck = carton scanning/parcel tracking). The driver's **account is one**, shared through a backend **link record** (time-bounded contract/association). A driver joining a **Factory** creates a separate account. Problem contact = that fleet's Sub-Admin. **`lib/features/fleet/{owner,driver,conductor}/` is rejected — do not create it.** Schema for the link: `driver_identities` (id, global_identity_id, license_number, license_class, created_at) + `driver_company_links` (id, driver_identity_id, company_id, `fleet_type` bus|truck, `role` driver|conductor, started_at, `ended_at` NULL = current, status active|terminated|suspended, UNIQUE(driver_identity_id, company_id, fleet_type, ended_at IS NULL)).
- **D2 — B2B is one group, three sub-apps** (B2B Marketplace · Reseller · Shopkeeper), each with its **own name and own login page**. Rename `features/reseller/` → `features/b2b/` with sub-apps inside (item 33).
- **D3 — department admin panels move OUT of `nexa_admin`**; no cross-links; the Super Admin links up. **Sub-Admin roles must be DYNAMIC, not hardcoded.**

### §5b.1 — the governing layering rule

> **Each panel is a vertical slice that owns everything it needs and depends on nothing from another panel.**

```
core  ←  shared  ←  features/<panel>
                  ↗
            main_<panel>.dart
```

- `core/` depends on nothing else in `lib/`.
- `shared/` depends only on `core/` — **never** on `features/` (hard rule 3).
- `features/<panel>/` depends on `core/` + `shared/` — **never** on another `features/<other>/`.
- `main_<panel>.dart` depends on exactly **one** panel, plus `shared/` and `core/`.
- Machine form: `core <- shared <- features/<panel> <- main_<panel>.dart` (enforced by `.scripts/check-panel-isolation.mjs`, `.github/workflows/panel-isolation.yml`).

### §5b.2 — the concrete extractions, in order

1. Extract `missile_3d_button` out of `bus_operations` → `shared/widgets/` ✅ (`3fbbeb90`)
2. Move `bus_tracking_models.dart` → `shared/`, or the telemetry bloc → BUS *(item 28)*
3. Extract the 4 fleet screens (`route_scheduler`, `ticket_management`, `voucher_management`, `bonus_management`) out of SUPER → neutral `shared/fleet/` *(item 28)*
4. Give GOODS its **own** `driver_dashboard_page` / `conductor_dashboard_page` *(item 28)*
5. Split `app_providers.dart` into `features/<panel>/providers.dart` ✅ (`eba16ee6`)
6. Replace the global auth globals in `core/utils/auth_state.dart` with per-panel scoped auth *(item 26)*
7. Split the router per §7 — **only after 1–6** *(item 29)*
8. Make `main.dart` a thin launcher — **Super Admin only** *(item 28)*

Target: each `main_*.dart` ends up **under ~50 lines**. Target layout: every panel folder gains a `providers.dart` + `routes/`; `theme.dart` extends the shared design system.

### §5b.4 — storage isolation

Web panels share a browser origin; `SharedPreferences` keys are panel-scoped **by convention only** (`busFleet_fleet_role`, `cricket_manager_token`, `factory_auth_token`). Target: a `StorageKeys` class per panel with a **mandatory compile-time prefix** enforced by lint, plus a separate `localStorage` origin per subdomain as a second layer *(item 40)*.

### §5c — containment: how one panel cannot break another

| # | Mechanism | Status |
|---|---|---|
| 1 | **CI boundary enforcement** — `.scripts/check-panel-isolation.mjs` + `.github/workflows/panel-isolation.yml`; fails the build on `shared → features`, `features/A → features/B`, `core → shared/features` | ✅ `ca591a98` (84 → 77 → 28 tracked; baseline `.scripts/panel-isolation-baseline.json`) |
| 2 | **Path-filtered per-panel CI** (each panel its own workflow with `paths:`) | ⏳ item 40 |
| 3 | **Per-panel test gates** (widget + bloc + integration + contract) | ⏳ partly (suite runs in CI) |
| 4 | **No shared mutable globals** — delete `auth_state.dart` globals | ⏳ item 26 (factory done; admin/sub-admin left) |
| 5 | **Staging + versioned artifacts + rollback** — today `rsync --delete` to prod, no staging/rollback/history | ⏳ |
| 6 | **Secret scanning** — `gitleaks` in CI | ⏳ item 3 (working-tree scan exists; not yet a hard gate) |
| 7 | **CODEOWNERS per panel** | ⏳ item 40 |
| 8 | **Weekly dependency-graph audit** | ⏳ item 40 |

Re-baseline/report commands: `node .scripts/check-panel-isolation.mjs --report` · `--write-baseline`. **Never add a baseline entry without an owner decision; remove an entry once that import is extracted.**

---

## 7. Authority, authorisation and the auth-state fix

### §2b — the Group-Incharge model (authority chain)

```
Super Admin  →  Group Sub-Admin  →  Group Admin  →  group staff
```

Super Admin = **observer + platform owner** (group activity feed, payments/graphs, audited "enter sub-admin view", appoints ONE sub-admin per group, **cannot** create group accounts). Each Sub-Admin **creates its group's admin accounts outright, audited** (no second approver) → that admin creates its own staff.

**Verticals in the DB** (`sub_admin_verticals` + `sub_admin_assignments` + `sub_admin_feature_grants` + `feature_registry`):

| Group | Vertical | Sub-Admin | Panel |
|---|---|---|---|
| 1 Platform | *(none — the Super Admin is not a vertical)* | — | ✅ |
| 2 B2B | `commercial_marketplace` | 3 — Commercial Marketplace | ✅ |
| 3 Factory | `factory` | 6 — Factory | ✅ |
| 4 Bus | `bus_transit` | 1 — Bus Transit | ✅ |
| 5 Goods | `goods_logistics` | 2 — Goods & Logistics | ✅ |
| 6 Cricket | `cricket_ops` | 5 — Cricket Tournament Operations | ✅ |
| 7 Vehicle Security | `vehicle_security` | 7 | ❌ stub |
| 8 Trust & Safety | `trust_safety` | 8 | ❌ stub |
| 9 Marketing | *(own group, own design — item 46)* | — | ❌ C1b |
| cross-cutting money | `financial_auditor` | 4 — Financial & Subscription Auditor | ✅ owns `plans.*` + `billing.*` for **every** group; **no operational accounts** |

**Creation matrix:** `factory` creates Factory Admin (not staff — the Factory Admin does that); `bus_transit` creates the bus company + admin; `goods_logistics` creates the goods/truck company + admin; `commercial_marketplace` creates factories/resellers/shopkeepers; `cricket_ops` creates Cricket Manager accounts; `vehicle_security`/`trust_safety` create nothing yet.

**⚠️ Ownership is metadata until Phase 6 (item 35):** `AdminMiddleware` admits **any** `sub_admin_assignments` row and `SubAdminMiddleware` never checks *which* vertical — so every sub-admin can already call `plans/*` and `billing/*` today. Closing it is the route-to-feature map.

**⚠️ Wildcard over-grant to settle before item 35:** `commercial_marketplace`'s baseline bundle contains the wildcard **`factory.*`**, which also covers the new `factory.admin.provision` / `factory.registry.view` codes — the B2B incharge would silently hold factory-admin provisioning.

### §7b — backend authorisation gaps

- **§7b.1 `consumer.php`** was never loaded (`PanelRouteServiceProvider::$panels` omitted `consumer`) → the whole Customer API was dead code. **Fixed `11dbaf8f` (register, not delete).** ⚠️ A **stale local route cache** (`bootstrap/cache/routes-v7.php`) makes every `routes/panels/*.php` look absent — `deploy.yml` rebuilds it fresh.
- **§7b.2 weak middleware.** ✅ Model to copy: `bus_fleet.php` = `auth:sanctum` + `bus.fleet` (`BusFleetGate`); `cricket.php` group 2 = `cricket.manager`. ❌ Open: `super_admin.php` = `auth:sanctum` only (mitigated by the shadow gate — item 2); `goods_fleet.php` = `auth:admin` (any admin of any vertical); `truck_fleet.php` = `auth:sanctum` only; `bus_owner.php` / `factory.php` / `passenger.php` = weak.
- **§7b.3 unguarded redirect paths.** Every `/sub-admin/*` and `/bus-fleet/*` path returned `null` (no guard); root on non-web redirected to `/factory/store-keeper/login`. The `/sub-admin/*` half is fixed (`9f59ef28`).
- **§7b.4 super-admin shadow gate.** `auth:admin` was **investigated and NOT applied** — a super admin fails tiers 1–2 (`account_type` is `global_identity`; `TenantAccount` has no `identity_type`), so it would lock the owner out. Instead `SuperAdminShadowGate` (`super.admin.shadow`, log channel `super_admin_gate.shadow`, env `SUPER_ADMIN_GATE_ENFORCE`) logs and passes through. **Enforcement is a config change** → item 2. Decision queries: `SELECT global_identity_id, revoked_at FROM master_admin_assignments;` and `SELECT id, email, account_type, global_identity_id FROM tenant_accounts WHERE email LIKE '%admin%';`
- **§7b.5 secret-scan scope.** `gitleaks` defaults to git history, which still contains `database_config.dart:54` → a red build for an already-removed, pending-rotation finding. **Scan the working tree first** (`gitleaks detect --no-git --source . --redact`); switch to history once rotated. Implemented as `.github/workflows/secret-scan.yml` + `.gitleaks.toml` (with deliberate `continue-on-error: true` → item 3).

### §7c — the state-isolation mechanism behind the Factory/Sub-Admin bug

`lib/core/providers/app_providers.dart` was global (284 lines, 59 imports); `main.dart` → `AppInitializer` composed SUPER + FACTORY + BUS providers, and `lib/core/utils/auth_state.dart` exposed **mutable globals** (`isAuthenticatedCache`, `isFactoryAuthenticatedCache`) read by the router redirect → **a Factory login set state the Super Admin guard read**. Cricket (`main_cricket_manager.dart`, `main_cricket_public.dart`) creates its own `BlocProvider`s inline — **the reference model**. (`reseller_app_initializer.dart` *did* call `AppProviders.getRepositoryProviders(...)` — harmless because it used none of the providers it received.)

### §17 — auth-state globals and the `/sub-admin` guard

- **Step 5 ✅ `9f59ef28`:** `/sub-admin/*` now requires a sub-admin session — `isSubAdminAuthenticatedCache` / `setSubAdminAuthenticatedCache()` in `auth_state.dart` (deliberately **not** cleared by `resetAuthState()`, so a super-admin logout cannot bounce a valid sub-admin session); loaded from `sub_admin_token` before `setAuthCheckCompleted(true)`; `/sub-admin/login` public; every other `/sub-admin/*` redirects when the cache is empty.
- **Factory half ✅ (§17.11):** own owner `lib/features/factory/factory_auth_cache.dart` (`FactoryAuthCache`; `set()` / `requireToken()` / `reset()`). Closed the **cross-domain defect (§17.8)**: `getFactoryAuthToken()` returned the *admin* token after a super-admin login (both domains wrote the shared `_tokenCache`), and `getFactoryId()` could pair an admin token with a factory id. Files touched (8): the new cache, `auth_state.dart`, `factory_auth_bloc.dart`, `factory_login_screen.dart`, `billing_remote_datasource.dart` (the leak site), `unit_code_generate_screen.dart`, `lib/app/app_initializer.dart`, `lib/routes/app_router.dart`.
- **Remaining (item 26) — §17.9 steps 2–6.** The 11 files that import `auth_state.dart`: ① `lib/routes/app_router.dart` (admin + factory + sub-admin reads, ≈10 sites) ② `lib/app/app_initializer.dart` (both writers + sub-admin) ③ `factory_auth_bloc.dart` ④ `billing_remote_datasource.dart` (**the §17.8 leak site**) ⑤ `factory_login_screen.dart` ⑥ `unit_code_generate_screen.dart` ⑦ `admin_auth_bloc.dart` ⑧ `sub_admin_bloc.dart` ⑨ `super_admin/login_screen.dart` ⑩ `bus_company_login_screen.dart` ⑪ `goods_company_login_screen.dart`. Steps ③–⑥ are already done (factory domain, `FactoryAuthCache`). Order: (2) admin domain → `AdminAuthState`: `login_screen.dart`, `bus_company_login_screen.dart`, `goods_company_login_screen.dart`, `admin_auth_bloc.dart`; (3) `sub_admin_bloc.dart` → `SubAdminAuthState`; (4) `app_router.dart` reads the three instances; (5) `app_initializer.dart` provides/writes instances last; (6) delete the shim, then delete `auth_state.dart`. **≈35–40 call sites across 11 files on the authentication path** — one file at a time, `dart analyze` after each. Do it when the owner is **not** mid-rotation. Human smoke-test: sub-admin login→dashboard (no loop), hard-refresh stays, logout bounces, incognito bounces; super-admin login→dashboard→logout→`/login`; factory login→dashboard→logout; factory billing sends the **factory** token.

---

## 8. ⭐ MODULE 19 — SERVICES & SKILLED WORKERS GRID (On-Demand Services / Technicians)

**Registry entry:** `NEXATRACE_SUPREME_MASTER_SPEC.md` **MODULE 19** (added 2026-09-29).
**Queue item:** 48.

### 8.1 What it is

A flexible grid of technicians / on-demand skilled workers. **No rigid fixed categories** — any
worker specifies their own skill in free text. The Universal Customer App shows nearby workers on a
map, supports link-share tracking, date/time slot booking and direct bids. Workers register on the
B2B side (`market.traceodd.com`) and their typed skill auto-renders as a category badge/filter in
the Universal app.

**The strict isolation lock (a hard rule):** a **technician** account type must be **100% LOCKED**
from wholesalers / resellers / shopkeepers / factories — no catalogs, wholesale pricing, inventories
or ordering systems, and no B2B trading data. Their dashboard is restricted to **their own service
bookings, bids and schedule slots**.

---

### Section 1 — Existing architecture review (what can be reused)

**Geolocation / nearby tracking.** There is **no Google Maps integration and no "nearby" radius
query anywhere**. No `google_maps_flutter`/`mapbox` dependency in `pubspec.yaml`, no `AIzaSy…` key,
no PostGIS, and **no Redis `GEOADD`/`GEORADIUS`**. `shared/widgets/maps/fleet_live_map_canvas.dart`
and `factory/driver/.../map_tracking_screen.dart` are *placeholder* canvases
explicitly commented "add google_maps_flutter to enable live tracking". "Nearby" in
`FreightAuctionController::indexLoads` is a **city text match**; `BiddingMeshController` accepts
`radial_range_km` but never queries it.
**Reusable:** the Haversine helpers — `lib/features/factory/driver/domain/utils/geo_utils.dart`
(`distanceMeters`), `BusRouteController.php:482` (`haversineKm`),
`BusLiveTrackingService.php:249` — plus the telemetry plumbing (`driver_gps_beacon.dart`,
`FleetLocationUpdated`, `RedisCacheService::updateVehiclePosition`). The map itself is net-new
(the decision in item 14).

**Dynamic bidding — high reuse.** There is **no class named `FreightBiddingEngine`**; the engine is
`App\Services\Freight\FreightAuctionService` (weights `W_PRICE 0.45`, `W_RATING 0.30`,
`W_PROXIMITY 0.15`, `W_SPEED 0.10`; `placeBid()` transactional + `lockForUpdate`; `matchLoad()`;
`computeScore()`; `matchAllExpiredLoads()`), driven by `FreightAuctionController`
(`routes/api.php` prefix `freight`, `auth:sanctum` only) over `freight_loads` (`poster_type`,
`origin/destination_city`, `*_lat/lng` decimal(10,7), `bidding_deadline`) and `freight_bids`
(`bidder_type`, `bid_amount`, `bidder_proximity_km`, `match_score`, unique `[load_id, bidder_id]`).
`App\Http\Controllers\Exchange\BiddingMeshController` gives the ready-made
**broadcast → submit-bid → accept-bid** shape (`routes/panels/super_admin.php` prefix `exchange`:
`broadcast-trip`, `submit-bid`, `accept-bid/{proposalId}`, `trip-bids/{tripId}`) over
`trip_bidding_requests` / `bidding_proposals`. `ConsumerSuperAppService` adds the **anti-spam
penalty pattern** (Cup-of-Tea, wallet `lockForUpdate`). ⚠️ These are **three separate bid models**,
none role-gated beyond `auth:sanctum`.

**Link-share tracking — pattern only.** `Telemetry\TrackingRouterController`:
`generateFamilyShareToken()` → `Str::random(64)` token → row in `passenger_safety_tokens`
(`share_token` unique, `trip_id`, `passenger_id`, `expires_at`) → returns
`share_url = config('app.url')."/track/{$token}"`; `getPublicFamilyStream($token)` is **public, no
auth**. ⚠️ **There is no page behind `/track/{token}`** (no `web.php` route, no Flutter
`/track/:token`), and it is bus-specific — the token model is copyable, the destination is not.

**Auth roles / RBAC.** There is **no `users.role`**. Roles live in: `tenant_accounts.account_type`,
`global_identities.identity_type`/`status` (the identity spine), `fleet_assignments.role`, and the
sub-admin set (`feature_registry`, `sub_admin_verticals`, `sub_admin_assignments`,
`sub_admin_feature_grants` with `scope_filter` JSON). Enforcement middleware (aliases in
`backend/bootstrap/app.php`): `AdminMiddleware`, `SubAdminMiddleware`, `EnsureDriverType`,
`SuperAdminShadowGate`, `TenantContextResolver`, `VendorAllowanceShield`, `IdentityStatusGate`,
`TokenVersionGuard`, `ResponseMaskSerializer`. **The isolation pattern to copy** is the sub-admin
scoping column: `companies.created_by_sub_admin_id` / `resellers.created_by_sub_admin_id` used in
`SubAdminFactoryCompanyController::ownedQuery()` (a real indexed column, **never** a JSON path).
`stage1` how `market.traceodd.com` enforces roles: it **does not** — `lib/main_marketplace.dart` is
a public, **no-login, read-only** storefront whose repository always calls `requiresAuth: false`,
and `.nginx/marketplace.conf` **403s** every `/api/` path except `/api/v1/reseller/` +
`/api/v1/public/`. **Consequence:** worker self-registration and a technician dashboard cannot live
on that host as-is; they need a new authenticated surface (a new subdomain + nginx allowlist, or a
new panel in the `main.dart` bundle registered in `PanelRouteServiceProvider::$panels` — an
unregistered panel file is **silently unreachable**).

**Categories / skills.** **No taxonomy tables exist.** `marketplace_product_listings.category` /
`sub_category` and `products.category` are free-text `VARCHAR`; facets come from
`ElasticsearchCatalogService::getFacets()` (`GROUP BY category`). The closest analogue for a custom
list is `catering_categories` (`company_id`, `name`, **no slug**). **The slugify pattern to copy**
is `MarketplaceListingService::uniqueSlug()` (`Str::slug($name)` + numeric suffix, `withTrashed`
uniqueness).

**How the isolation lock will be enforced (RBAC).** Not by nginx alone. The pattern is the existing
one: **(a)** a new panel route file registered in `PanelRouteServiceProvider::$panels`, guarded by
its own middleware (mirror `BusFleetGate`, not bare `auth:sanctum`); **(b)** a new `UserPanel` enum
entry + its own `apiPrefix` + `tokenStorageKey` in `lib/core/navigation/panel_routes.dart` (per-panel
token isolation) and its own guard entry in `route_guard_middleware.dart`; **(c)** a dedicated
`/api/v1/services/*` (or `/api/v1/technician/*`) prefix that **shares no controller, table or
presence with `/api/v1/reseller/*`, `marketplace_product_listings`, `freight_*` or the B2B
catalog**; **(d)** a nginx vhost that proxies **only** that prefix and returns 403 for every other
`/api/` path. That is the same three-layer LOCK every other panel uses, and it is what makes the
B2B catalog physically unreachable from a technician session.

> The lock is **structural**, not a UI toggle: the technician's token is accepted by the services
> prefix only, and no technician route queries a catalog table. There is no shared bundle — the
> panel gets its own `main_services.dart` (item 33 pattern).

---

### Section 2 — Technical suggestions

**(a) Dynamic skill indexing (dedupe "Electrician" vs "AC Electrician").**

Do **not** store the typed string as the category. Use a three-part model:

1. **`service_skills`** — the worker's own record: `worker_id`, `skill_title` (as typed, for
display), `skill_slug` (`Str::slug`, the raw normalised form), `skill_category_id` (FK, nullable),
`description` (the short free-text box), `is_approved`, `approved_by`.
2. **`skill_categories`** — the taxonomy: `id`, `slug` (unique), `canonical_name`, `parent_id`
   (nullable, for grouping), `worker_count` (denormalised), `is_approved`.
3. **`skill_aliases`** — `alias_slug` (unique) → `skill_category_id`. This is the **dedupe table**:
   `electrician`, `ac-electrician`, `ac-technician` all point at the `electrical` parent.

**Resolution at onboarding (one service, e.g. `SkillResolverService`):**
normalise → `Str::slug` → ① exact `skill_categories.slug` match → attach; ② else `skill_aliases`
lookup → attach; ③ else **trigram/fuzzy match** (Postgres `pg_trgm` `similarity()`, threshold ~0.4)
against `canonical_name` → if it clears the threshold, attach **and** write a new `skill_aliases`
row (so the next identical typo resolves instantly); ④ else **create a new `skill_categories` row
with `is_approved = false`** and queue it for the Sub-Admin/Verification-Manager to confirm or
merge into an existing parent. This means a brand-new local skill is never blocked, but the
taxonomy converges instead of exploding.

**Render:** the Universal app reads one **public, read-only** endpoint
`GET /api/v1/services/skill-categories` returning the approved categories with `worker_count`, and
renders them as chips/filters (exactly the mock the site's product-category chips already use).
The badge on a worker's card is `service_skills.skill_title` (the human string) linked to its
category. Merge tooling: a Sub-Admin action that re-points all `service_skills` of category A to B
and deletes A.

**(b) Service slot engine — 1–2 concrete improvements.**

1. **A real slot table with an overlap constraint, not a JSON blob.**
   `service_slots`: `worker_id`, `starts_at` / `ends_at` (`timestamptz`), `capacity` (default 1),
   `status` (`open|held|booked|blocked`), `booking_id` (nullable). In Postgres add
   `EXCLUDE USING gist (worker_id WITH =, tstzrange(starts_at, ends_at) WITH &&)` — the database
   then makes double-booking **impossible**, which a `SELECT … then INSERT` in PHP cannot.
   Pair it with `service_jobs` (`poster_id`, `skill_category_id`, `pricing_mode` hourly|job,
   `budget`, `lat`/`lng`, `status`, `bidding_deadline`) and `service_bids` (mirror `freight_bids`:
   `job_id`, `bidder_id`, `bid_amount`, `match_score`, unique `[job_id, bidder_id]`).
2. **Reuse the two engines that already exist rather than inventing a third bid model.** Route
   service bidding through the **`FreightAuctionService` scoring contract** (swap the entity pair;
   keep price/rating/proximity/speed weights configurable per vertical) and route every payout
   through the **§10.5 idempotent split engine** (`split_transactions` /
   `split_transaction_recipients`, `idempotency_key = SHA-256(source_event_type:source_event_id:rule_version)`,
   `INSERT … ON CONFLICT DO NOTHING`, five-state recipient lifecycle, suspense account on
   partial failure). **No second ledger** — the same rule Kisan and Marketing are bound by.

**API-level note:** the slot endpoints should return the worker's free slots computed as
`open` slots intersected with the worker's availability window, and a booking must be created in a
**transaction that first flips the slot to `held`** (`lockForUpdate`), so a bid and a direct
booking cannot both win the same slot.

---

### Section 3 — Roadmap entry & work plan

**Module placement:** `NEXATRACE_SUPREME_MASTER_SPEC.md` → **MODULE 19 — SERVICES & SKILLED
WORKERS GRID** (Module 18 = Kisan stays; 16/17 remain consolidated/removed).

**Task sequence (queue item 48):**

| Step | Work | Reuses |
|---|---|---|
| **S1 — Onboarding & Custom Skill Input** | New authenticated services surface (own `main_services.dart` / panel route file + `UserPanel` entry + `PanelRouteServiceProvider::$panels` registration + nginx vhost). Registration form: fixed dropdowns **plus** the open `skill_title` text box **plus** the `description` short-text area. `SkillResolverService` + `service_skills` / `skill_categories` / `skill_aliases` tables; Sub-Admin moderation queue for unapproved skills | `SubAdminVerticalExpansionSeeder` pattern (additive, idempotent upsert), `MarketplaceListingService::uniqueSlug()`, the panel-scaffold pattern from `main_marketplace.dart` |
| **S2 — Strict Isolation RBAC** | The technician account type + vertical, its own middleware (mirror `BusFleetGate`), its own `/api/v1/services/*` prefix, and the nginx 403 for everything else. **Verification test:** a technician token calling any `/api/v1/reseller/*`, `/api/v1/marketplace/*` or `freight/*` route returns **403/404**, and no services controller touches a catalog table | `SubAdminFactoryCompanyController::ownedQuery()` scoping pattern; the `created_by_sub_admin_id` real-column rule; §11 `panel-isolation` guard |
| **S3 — Universal App Dynamic Category Rendering** | Public `GET /api/v1/services/skill-categories` (approved categories + worker_count) → chips/filters in the Universal Customer App; the worker's `skill_title` renders as the category badge. Nearby-worker map + list (item 14's map SDK + a real radius query) | the existing storefront category-chip UI; `geo_utils.dart` Haversine; item 14's location decision |
| **S4 — Geo Bidding & Link-Share Hand-off** | `service_jobs` / `service_bids` + the slot engine (Section 2b); date/time slot booking; direct bids through the `FreightAuctionService` scoring contract; **link-share** of a booking using the `passenger_safety_tokens` token pattern (this time with the public page actually built); payouts through the §10.5 split engine | `FreightAuctionService`, `BiddingMeshController` API shape, `TrackingRouterController` token model, `split_transactions` |

**Dependency & priority order.** Module 19 must come **after**:
1. **item 14** — the location-plugin + map-SDK decision (no map and no radius query exist today;
   this is the single biggest missing dependency);
2. **items 16–18** — the B2B auth gateway and the Reseller/Shopkeeper role dashboards the worker
   registration and dashboard must sit beside;
3. **item 26** (§17 auth-domain split) — so the new panel gets a clean, non-shared identity rather
   than joining the shared-global bundle;
4. **item 35** (Phase 6) — **real** request-time enforcement of verticals/feature grants. Until
   Phase 6, isolation is metadata; building S2 on top of the unenforced middleware would give a
   false sense of security;
5. the **error-surface sweep** (items 5–9) and the marketplace usability work (items 16–21) first,
   because those are the owner's stated priorities and Module 19 is new scope.

It can then run **beside Phase K** (both are new B2B-side modules reusing the same bidding + split
engines). The **boundary rule** applies: the Universal app gets the *map view, booking and
link-share* only — **no** B2B trading code and **no** catalog access.

---

## 9. Key findings to carry forward

1. **The marketplace is populated and the publish step works.** `MarketplaceListingService` creates
   the storefront on the first upload and writes `marketplace_product_listings`; the controller's
   create/update/toggle sync it; `php artisan marketplace:publish-products --all` published the 6
   existing products (one storefront per company). ⚠️ Storefronts are created
   `verification_status = 'verified'` **on purpose**, because the catalog and search only show
   verified storefronts.
2. **The three-reseller-types model is already half-built in the schema** (`is_msrp_enforced`,
   `factory_buy_price`, `reseller_sell_price`, plus `is_homemade`, `is_brand_verified`,
   `reseller_otp_locked`, a factory matrix type system and `ResellerPortalService::enforceMSRP()`).
   Parked items P2/P3 are **wiring, not invention**.
3. **The sub-admin panel is the same bundle as the Super Admin** (`main.dart` serves five panels).
   Giving it a subdomain changes the URL, not the coupling (Blocker B). The sub-admin has **no**
   separate subdomain — which is why it never had a Cloudflare record.
4. **The factory panel's `factory_dashboard.dart` is at its first-commit state**
   (`git log -S "45,000"` → `82f3ef9a`, only two commits ever). Its demo data and dead entries were
   **pre-existing**, not caused by the separation work.
5. **The Sub-Admin's scoping key is a real column** — `companies.created_by_sub_admin_id` and
   `resellers.created_by_sub_admin_id` (migrations `2026_09_27_000002`, `2026_09_27_000001`).
   **Do not go back to a JSON path.**
6. **The two blockers for subdomain work.** **Blocker A:** five panels have no build step at all
   (surfaces #12, #13, #17, #18, #19) → their nginx paths 404 today. **Blocker B:** the `main.dart`
   mega-entry serves five surfaces (#1, #2, #3, #7, #8) and cannot be locked by a subdomain until
   item 28. Doing #1 first would **re-produce the mixing bug**. → items 30, 28.
7. **`FreightAuctionService` is schema-agnostic** and directly adaptable to service bidding; it
   only needs a different entity pair. Three separate bid models exist today — do not add a fourth.
8. **The map/geo gap is the project-wide one decision.** It blocks Pillar B (velocity check),
   Pillar C (real telemetry), Pillar E (IoT) and Module 19. → item 14.

---

## 10. Design-reference appendix (original section numbers preserved)

> The headings below deliberately keep their **original numbers** so that every existing reference
> in code, CI and other docs (`…PLAN.md §7b.4`, `GROUP-INCHARGE-MODEL.md §2b.3`, etc.) still
> resolves after the file-name change. Treat them as an appendix, not as the work order — **the work
> order is §3**.

### §2b.3 — what `financial_auditor` owning `plans/**` + `billing/**` means

| Area | Prefix today | Controllers |
|---|---|---|
| **Plans** | `/api/v1/admin/plans/*` | `Admin\AdminPlanController` |
| **Billing / invoices** | `/api/v1/admin/billing/invoices*`, `/billing/payments*`, `/billing/refunds*`, `/billing/companies/*`, `/billing/credits*` | `Admin\AdminBillingControllerNew`, `Admin\AdminInvoiceController`, `Admin\AdminBillingController` |

C1 registered ownership as feature codes `plans.*` and `billing.*` under `financial_auditor` in its
`default_feature_bundle_codes`. ⚠️ **Ownership is metadata until item 35.** The `plans`/`billing`
**screens** are Flutter routes in the Super Admin shell today (`/plans`, `/plans/create`,
`/billing/invoices`); a sub-admin cannot reach them (the router guard requires
`isAuthenticatedCache`; sub-admins use `isSubAdminAuthenticatedCache`). Moving the screens +
per-vertical guard reach is Phase 6.

### §6 — keep / delete advisory (item 36)

Whole-tree importer scan (772 files). **Delete (after the checks named):**
`lib/features/universal/customer/**` (8 files — **merge first**: it is the copy that carries the real
scan bloc + Bluetooth/hardware-scan + websocket bloc; the **live** customer app is
`lib/features/bus_operations/presentation/pages/customer_super_app_screen.dart`, routed at
`app_router.dart:632-637`); 7 unrouted `nexa_admin` billing screens + `dunning_alert_widget` + 3
billing usecases; 6 unrouted `bus_operations` pages (`route_list`, `route_editor`, `route_detail`,
`ticket_vault`, `driver_trip`, `live_bus_tracking`) + `qr_code_painter` + `driver_gps_beacon`;
~24 unused `lib/shared/` widgets — **except `app_decorations.dart`** (§10/Q4 says *adopt* it);
`core/services/{payment_service,subscription_validator,supabase_chat_service,multi_tenant_service,code_generator_service}.dart`
and `core/constants/{fleet_constants,plan_limits}.dart` — **only after** the §10/Q3 check that no
backend migration references `payment_service`/`subscription_validator` as a *planned* dependency.
**Keep:** `lib/features/goods_operations/`, `lib/features/reseller/`,
`lib/features/storekeeper/` (BUS depot), `lib/features/factory/store_keeper/` (FACTORY warehouse —
**no merge**), `lib/features/auth/` (login path live; trim the dead guard layer),
`shared/models/wallet/wallet_model.dart`, and **`broadcaster/data/services/whip_client.dart`**
(it has a test, `test/features/broadcaster/whip_client_test.dart` — the original "0 importers" row
missed it). **Name collisions to fix:** `features/storekeeper/` (BUS) vs
`features/factory/store_keeper/` (FACTORY) → rename the BUS one;
`SearchAppBar` declared twice (`shared/widgets/app_bars/main_app_bar.dart`, `search_app_bar.dart`);
`PanelAuthState` exists in both `core/navigation/panel_routes.dart` and `features/auth`.

**⚠️ Moves out of `nexa_admin/` (B7):** `super_admin/bus_fleet*` + `bus_company_login_screen` → BUS;
`super_admin/goods_fleet*` + `goods_company_login_screen` → GOODS;
`super_admin/transport/**` + `super_admin/reseller_management/**` + `bloc/{transport_admin,reseller_management}`
→ B2B; `sub_admin/cricket/**` → CRICKET. **Stay (platform):**
`sub_admin/{sub_admin_list_screen,add_sub_admin_screen}`, `super_admin/{dashboard,login,shell}`,
`site_content/`, `plans/**`, `billing/**`, `companies/**` (registry), `data/**`, `domain/**`,
`presentation/bloc/{auth,billing,invoices,plans,companies,dashboard}`.
**Deleted, not moved:** `super_admin/companies/{bus,goods}_companies_list_screen.dart` +
`add_{bus,goods}_company_screen.dart` ✅ (`126f618d`, −2,346 lines).

**Execution order for any removal (keep this):** entry points first, then routes, then files —
reverse order crashes (`go_router` throws on an unknown route).

### §7 — Phase 2 router-extraction map (corrected)

Three content kinds: ① `GoRoute` definitions; ② redirect logic inside `_safeRedirect`; ③ public
bypasses (`return null`). **All bypasses stay in the base router** — they are guard decisions, not
routes.

| New file | `GoRoute` definitions | Department |
|---|---|---|
| `lib/routes/app_router.dart` *(kept)* | 320–321 (the `_routes` list), 1078, 1140 | shell |
| `super_routes.dart` | 321–326, 342–351, 653–792 | SUPER |
| `factory_routes.dart` | 327–331, 793–1075 | FACTORY |
| `cricket_routes.dart` | 352–369, 370–486 | CRICKET |
| `bus_routes.dart` | 332–336, 487–527, 600–631 | BUS |
| `goods_routes.dart` | 337–341, 528–568, 569–599 | GOODS |
| `customer_routes.dart` | 632–652 | CUSTOMER |
| `b2b_routes.dart` | **759–772 (`/resellers`, `/resellers/add`)** | B2B — **open decision** |

**Redirect logic to move with its department:** 203–234 factory redirect rules → FACTORY; 236–242
root-path redirect → global; 287–317 protected-route redirects (incl. dashboards) → SUPER +
BUS/GOODS dashboards. **`263–281` stays in the base router** (mixed bus/truck owner/driver/conductor
bypass). Corrected errors from the first version: `b2b_routes.dart` does **not** get 247–249 / 153–163
(those are a bypass and error-builder text); `factory_routes.dart` does **not** get 203–234 / 244–246.
**Exit:** every working panel works; the file is under ~250 lines. Target: `AppRouter` composes parts.

### §8 — the LOCK method and the subdomain playbook

**Working method (one department at a time):** separate → verify → LOCK. **Rollback rule:** every
phase on its own feature branch; merge to `mainnew` only after the deploy is verified against the
Phase-0b baseline; **no phase merged while a previous phase's verification is outstanding**; on
failure revert — **do not "fix forward"** on the live branch.

**What LOCK means (all must be true):**
- [ ] Its own `lib/main_*.dart` **and** its own build+rsync step in `frontend-deploy.yml`.
- [ ] Its own nginx vhost with an **exact `server_name`** and **no catch-all** `try_files … /index.html`
      that could swallow another panel's paths.
- [ ] A Cloudflare **A** record → `135.181.46.27`, **proxied**. (Never a wildcard `*.traceodd.com`.)
- [ ] Its login password rotated and **login proven with the new password**.
- [ ] A request to **another** panel's API prefix on this host returns **403**.
- [ ] `dart analyze` clean.

**Per-panel nginx template** (based on the real `cricket-manager.conf`; replace `<panel>` `<dir>`
`<api-prefixes>`):

```nginx
server {
    listen 80;
    server_name <panel>.traceodd.com;
    client_max_body_size 10m;

    root /var/www/traceodd/<dir>/;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, must-revalidate";
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            add_header Cache-Control "no-cache, must-revalidate";
            add_header Pragma "no-cache";
            expires -1;
        }
    }

    # ALWAYS include the shared platform prefixes, or LOGIN BREAKS:
    #   /api/v1/auth/  unified login (GlobalAuthController)
    #   /api/v1/user/  notifications / preferences
    #   /api/v1/sync/  offline sync
    #   /api/v1/files/ uploads
    location ~ ^/api/v1/(auth|user|sync|files)/ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME /var/www/traceodd/admin-panel/public/index.php;
        fastcgi_param HTTP_AUTHORIZATION $http_authorization;
        include fastcgi_params;
    }

    location ^~ <api-prefixes> {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME /var/www/traceodd/admin-panel/public/index.php;
        fastcgi_param HTTP_AUTHORIZATION $http_authorization;
        include fastcgi_params;
    }

    # Everything else is another panel's business.
    location ^~ /api/ { return 403; }

    location /storage/ {
        alias /var/www/traceodd/admin-panel/storage/app/public/;
        add_header Access-Control-Allow-Origin *;
    }

    location /app/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```

**Backend prefix per surface** (from `routes/panels/*.php`): Super Admin/Sub-Admin `/api/v1/super-admin/`;
Universal Customer `/api/v1/consumer/` + `/api/v1/marketplace/consumer/`; B2B/Reseller/Shop Keeper
`/api/v1/marketplace/`; Factory `/api/v1/factory/`; Bus Fleet `/api/v1/bus-fleet/`; Bus Owner
`/api/v1/bus-owner/`; Truck Fleet `/api/v1/truck-fleet/`; Goods Fleet `/api/v1/goods-fleet/`; Cricket
Manager `/api/v1/cricket/manager|admin|public|live/`; Cricket Public `/api/v1/cricket/public|live/`;
**IoT `/api/v1/iot/` · Notes `/api/v1/notes/` · Services (Module 19) `/api/v1/services/`** *(planned)*.

**Proposed subdomain per surface** (owner to confirm/adjust; "ready" = an isolated entry point exists).
`traceodd.com` → Landing (#26) ✅ · `admin.traceodd.com` → #1 Super Admin + #2 Sub-Admin path +
#4 B2B Marketplace (🔴 Blocker B) · `app.traceodd.com` → #3 Universal Customer (🔴 Blocker B +
duplicate copy) · `reseller.traceodd.com` → #5 ✅ · `shop.traceodd.com` → #6 (not built) ·
`factory.traceodd.com` → #7 (+ #8 Store Keeper path) (🔴 Blocker B) · `driver.traceodd.com` → #9 ✅ ·
`bus-fleet.traceodd.com` → #10 ✅ · `bus-owner.traceodd.com` → #11 ✅ ·
`bus-store.traceodd.com` → #14 ✅ · `bus-driver.traceodd.com` → #12 (🚧 Blocker A) ·
`bus-conductor.traceodd.com` → #13 (🚧 Blocker A) · `goods.traceodd.com` → #15 (not built) ·
`goods-store.traceodd.com` → #16 (not built) · `truck-owner.traceodd.com` → #17 (🚧 Blocker A) ·
`truck-driver.traceodd.com` → #18 (🚧 Blocker A, imports BUS pages) · `truck-conductor.traceodd.com` →
#19 (🚧 Blocker A, imports BUS pages) · `cricket-manager.traceodd.com` → #20 ✅ ·
`studio.traceodd.com` → #21 ✅ · `broadcaster.traceodd.com` → #22 ✅ · `cricket.traceodd.com` → #23 ✅ ·
`iot.traceodd.com` → #24 (not built) · `notes.traceodd.com` → #25 (not built) ·
**`services.traceodd.com` → Module 19 (not built)**.

**Recommended wave order (the registry numbering is a checklist, not an execution order):**
**W1** #5 Reseller · #9 Factory Driver · #10 Bus Fleet · #11 Bus Owner · #14 Bus Store Keeper
(isolated entry points already exist) → **W2** #12, #13, #17, #18, #19 (add the 5 missing builds
first; #18/#19 also need the BUS→GOODS page extraction) → **W3** #1, #2, #3, #7, #8 (require Phase 1
first — Blocker B) → **W4** #4, #6, #15, #16, #24, #25, **and the Module 19 services surface** (not
built yet — a build order, not a linking order).

### §12 — architecture standard: BLoC vs native

> **Dart/Flutter BLoC owns orchestration, state, UI and platform I/O. Native (Rust) owns only work
> that is a measured hotspot, that runs per-frame, or that must reuse a native library. No surface is
> "a Rust app".**

22 surfaces are pure Flutter BLoC; #3 Universal Customer = Flutter BLoC + native kernel; #25 Note
Panel = Flutter BLoC + Rust CV kernel + platform-native inference; #21 Todd Studio = Rust + Tauri
(desktop); #22 Todd Broadcaster = native Android + Rust engine. **The jank trap (§12.3):** never call
Rust synchronously from the UI isolate — use `flutter_rust_bridge` v2's async API, `Isolate.run(...)`,
or a native thread posting results back; **camera frames must not cross into the Dart heap**.

### §13 — native / Rust layer, verified state

`rust/` is `trace_odd_rust` v0.1.0 (`cdylib` + `staticlib` + a CLI binary). The declared bridge is
**dead**: `Cargo.toml` pins `flutter_rust_bridge = "1.82.4"` (v1) while `pubspec.yaml` declares
`^2.11.1` (v2); zero generated artifacts, no `build.rs`, and **zero Dart files import
`package:flutter_rust_bridge`**. The operative contract is `rust/src/ffi_abi.rs` (11
`#[no_mangle] extern "C"` symbols returning NUL-terminated JSON) + `dart:ffi` in
`lib/rust_module/ffi_config.dart`. 29 vestigial `#[frb]` items remain in `rust/src/lib.rs`.
**Works:** `algorithms/` (SHA-2, AES-GCM, ChaCha20-Poly1305, Argon2, PBKDF2, HMAC, TOTP/HOTP,
Luhn/EAN/UPC) and `generators/` (bundle→carton→packet→unit). **Stubs:** `international/{gs1,qr,barcode}`
emit formatted *strings*, not encodings. **No camera/CV/AI crates at all.** §13.3 symbol mismatch
`verify_serial_on_device`; §13.4 response strings never freed; **§13.5 packaging gap** — no
`CMakeLists.txt` / `*.podspec` / Gradle `cargo` step, so the `cdylib` is built only for the server,
and mobile `DynamicLibrary.open` fails → **blocks any Rust kernel inside a mobile surface**.
§13.6 cricket drift check: `LiveScoreService.php` shells out to `cricket --recompute`, but
`rust/src/main.rs` handles only `generate`/`--version` → **the drift check can never succeed**, and
**no workflow builds or deploys `todd-cricket`** (option **B now, C later**; A rejected).
§13.7 CI matrix: `deploy.yml` builds `rust/` (no features); `media-engine-build.yml` runs
`cargo check -p todd-signaling -p todd-sfu --features gst`; `media-engine.yml` triggers on the
**stale branch `master`**. §13.8 `media-engine/` is a separate workspace — **do not merge**.

### §14 — risk register (corrected)

| Risk | Status | Fix |
|---|---|---|
| Super-admin endpoints non-enforcing | **Mitigated** (shadow gate `6a400138`) | item 2 |
| Plaintext DB credentials | file deleted (`bdb3001d`); **passwords not rotated**, in git history permanently | item 1 |
| Realtime/Redis silently degraded | Live — `BROADCAST_DRIVER=log`, `CACHE_STORE=database`, `QUEUE_CONNECTION=database` | item 39 |
| Fabricated telemetry in shipped UI | Live — hardcoded GPS strings; pseudo-position map canvas | item 39 |
| `/customer/my-tickets` is not a route | Live | item 39 |
| `verify_serial_on_device` symbol mismatch | Live — throws once the native lib loads | item 38 |
| `dart analyze` backlog | CI gate live (`--no-fatal-warnings`), **57 warnings / 0 errors** | item 39 |
| 37 composer advisories (11 packages) | Untriaged, pre-existing | item 39 |
| Hardcoded `root@135.181.46.27` | Live — **28 occurrences** in `frontend-deploy.yml` | item 40 |
| LLM API key in plaintext | `%APPDATA%/Zed/settings.json` holds `language_models.openai.api_key` in plaintext | owner |
| Additional debt | 3 parallel HTTP clients; 2 WebSocket stacks; `get_it` declared-but-unused; `setState()` backlog; the 1142-line router | items 29, 39 |

### §15 — the pillars (tracked outside the separation scope)

| Pillar | Group | Backend | Frontend | Plan |
|---|---|---|---|---|
| **B — Factory anti-counterfeit scanner** | 3 Factory | **Ready** — `ConsumerScanController@verify`, `FactoryProductionController@verifySerial`, `smart_codes`, `code_verification_history`, `consumer_scans` | Camera sheet missing; scan bloc exists in the orphaned copy | item 41 |
| **C — Bus fleet super-app** | 4 Bus / 1 Platform | Strong — bookings, holds, `absolute_bus_layouts` + revisions, vouchers, wallets, `passenger_safety_tokens`, family stream | Seat map excellent; telemetry/map stubbed | item 42 |
| **D — Goods transport & freight** | 5 Goods | Freight ✅; relocation ❌; **no `trucks`/`parcels` tables** | Minimal (`goods_operations` = 5 files) | item 43 |
| **E — IoT vehicle security** | 7 Vehicle Security | **Nothing** — no `devices`/`geofences`/telemetry tables; **no immobilizer** | Nothing | item 44 |
| **A — PKR banknote authentication** | 8 Trust & Safety | **Nothing** | Nothing | item 45 |

**Pillar B endpoint contract:** `POST /api/v1/marketplace/consumer/verify` (`auth:sanctum`; body
`serial_hash` (64-hex), `lat` **required**, `lng` **required**) → `{success, data}` with a ternary
shape (not-in-vault / already-activated / first-activation + `velocity_diverted`). Staff variant:
`POST /api/v1/factory/production/verify-serial` (`serial_hash` only, no cashback, no GPS).
**Never** send fake coordinates; never accusatory wording. **Pillar E** published commitments (from
`assets/landing/landing_content.json`): PKR 499/mo Rider (bikes), 899/mo Driver (cars/SUVs), custom
Fleet; "no upfront hardware cost"; immobilization, geofence/tamper alerts, 5s GPS on the Driver tier.
**Pillar A** binding owner decisions: no authenticity verdict ever; result wording table; SBP legal
gate **before** Phase 1 coding; three delivery phases; the bank-branch advisory is mandatory.

### §15b — the provider split (done)

`lib/app/app_initializer.dart` (moved out of `core/widgets/`), `lib/features/nexa_admin/providers.dart`
(`NexaAdminProviders.repositoryProviders()` / `.blocProviders()`),
`lib/features/factory/providers.dart` (`FactoryProviders.repositoryProviders()` / `.adminBlocProviders()`
/ `.driverBlocProviders()` / `.storeKeeperBlocProviders()`);
`lib/core/providers/app_providers.dart` is now core-only. **Order is behavioural**
(`context.read` in `create`). Isolation baseline went **75 → 28** (`core → features` = 0).
**Still open:** `main.dart` is still a mega-launcher (item 28).

### §18 / provenance — commits in this cycle

| Commit | What | Baseline |
|---|---|---|
| `ca591a98` | CI boundary guard; measured the real debt | 84 |
| `969aab00` | 4 dead `core/` files removed | 77 |
| `3be02476` | dead `transport` + `transport_marketplace` removed (20 files, −6,116 lines) | 75 |
| `eba16ee6` | §15b provider split | **28** |
| `9f59ef28` | §17 step 5 — `/sub-admin/*` guard | 28 |
| `e723bcc0`, `22742200`, `3ada51b8` | plan records + §17 research | 28 |
| §17.11 | B1 factory auth split (`FactoryAuthCache`) | 28 |
| `11dbaf8f` | `consumer` panel registered | — |
| `6a400138` | super-admin shadow gate | — |
| `ce560194` | `dart analyze` in CI | — |
| `3fbbeb90` | `missile_3d_button` promoted | — |
| `d95ac9f1` | one real Flutter test | — |
| `126f618d` | duplicate Super Admin bus/goods registration removed | 28 |
| `a93dbb1f` | mixed-content (base-URL) fix | — |
| `deb1d661` | dead sidebar entries fixed | — |
| `328490ee` | `drivers` table restored | — |
| `f0fc72e5`, `e951903b`, `ead72810` | streaming forwarder fixes | — |
| `01f5905e`, `269478ef`, `6c57fdc0` | streaming far-end health, HLS-advancing check, scheduler cron | — |

---

## 11. Provenance of this consolidation (2026-09-29)

- **12 files → 2.** This file + `START-HERE.md`. The other ten are **deleted** (readable in git
  history): the separation plan, the recommendations doc, the group-incharge model, the subdomain
  playbook, the three pillar specs, the credential-remediation runbook, the streaming history, and
  the Qoder cricket-stream brief.
- **Duplicate work removed.** `PANEL-SEPARATION-RECOMMENDATIONS.md` was ~95% redundant — its
  findings were already folded into the plan's §5b/§5c/§7/§7b/§7c/§9b/§17, and three of its central
  claims are known false (reseller as "reference model"; "zero Flutter tests"; "translations empty").
  Its five genuinely unique proposals survive in **item 40**. `QODER-CRICKET-STREAM-BRIEF.md` is
  superseded by the streaming history's §6 (both now in `START-HERE.md` Appendix B).
- **Done work removed** from the plan order and moved to the §4 ledger.
- **Renumbered** into one linear order (§3) with Stage headers; dependencies are stated per item.
- **Original section numbers preserved** in §10 and in `START-HERE.md`'s appendices, so existing
  citations still resolve; the doc **file name** references elsewhere in the repo were updated by a
  mechanical replacement (`…PLAN.md`/`…RECOMMENDATIONS.md`/`GROUP-INCHARGE-MODEL.md`/`…PLAYBOOK.md`/`PILLAR-*.md`
  → `MASTER-TASK-LIST.md`; `PHASE-0A-….md`/`STREAMING-….md`/`QODER-….md` → `START-HERE.md`).
- **Nothing open was dropped.** Every open item from the ten deleted files is present in §3 (as a
  numbered task), §7–§10 (as a decision/constraint) or the §4 ledger (as done).
