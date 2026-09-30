# START HERE — read this file first

**Purpose:** the entry point for a **fresh agent session**. It says what to read, in what order,
what the owner has decided, how to work here, and what the live bugs are — plus the two runbooks
that have no other home (credentials, and the streaming fault history).

**Last updated:** 2026-09-30 (item 9 done — factory plan-limits endpoint + real-plan gating; the 4th pinch-zoom cause fixed: the white band).

**The plan lives in `docs/handoff/MASTER-TASK-LIST.md`** — the single ordered queue. This file is
how you work; that file is what to do.

---

## 0. ⏭ RESUME HERE — for a fresh chat

**Where the work stopped:** the "errors stay + copy" sweep is finished for every panel the owner has worked on — **items 5, 6, 7, 8 are ✅ done**, and the sweep also closed **Store Keeper** and the **Bus panel** (`fleet_dashboard_page`, `passenger_seat_selection_screen`, `bus_operations/.../customer_super_app_screen.dart`). `MASTER-TASK-LIST.md` §4 has the done-ledger.

**The next work, in this order (the plan's own order — do not re-order):**
1. **Zoom: DONE and confirmed on a phone** (owner tested a second phone). A fourth cause was then found and fixed — zoomed panning left a growing WHITE band on the right/bottom (`3e1fe3d2`: a `visualViewport` shim + a page background). The served HTML on both hosts now carries all five markers; **re-check the white band on a phone** (see below) and report.
2. **Then follow `MASTER-TASK-LIST.md` §3 strictly from its own START HERE** — **item 9 is ✅ done (`3e1fe3d2`)**, so the START HERE is now **item 10** (`flutter_service_worker.js` as `text/html`), then **item 11** (the analytics 500 — read `laravel.log` first), **item 12** (the two literal-IP bugs), **item 13** (the CORS log flood), **item 14** (the location-plugin + map-SDK decision — it unblocks Pillar B/C/E **and** items 48/49), and straight down the queue. State the item number you are doing and record the commit hash next to it when it lands.

**Copy-error status (item 7, for reference):** done for Factory admin, Sub-Admin, Super Admin, Reseller, Cricket, **Store Keeper** and the **Bus** panel. **Not yet swept:** the goods/truck panel, and `marketplace_public` / landing error surfaces — check them when you pass those panels.

**Do NOT re-do these (all landed):** #9–#13 marketplace work · the error-banner sweep (items 5–8) · the Sub-Admin full edit form · `subadmin.traceodd.com` vhost · the error-copy fix · A1/A3 · B1 · C0/C1/C2/C2b/C3 · the provider split · the `/sub-admin/*` guard · **Group Vertical #10 recorded** (spec Module 20 + plan item 49) · **item 9** (the factory plan-limits endpoint + the real-plan gating of the Transport tab — `3e1fe3d2`).

### ⚠️ FIRST TASK — verify the pinch-zoom, and WHY it kept failing

Owner, 2026-09-30: on a phone `traceodd.com` and `market.traceodd.com` are "stuck" — two-finger pinch does not zoom and the text stays tiny. An earlier agent twice said it was fixed; it was not. **Four separate causes, and a `user-scalable=yes` meta alone fixes none of them:**

1. **No viewport at all** → Flutter's engine injected its own restrictive one (`maximum-scale=1.0, user-scalable=no`). *(fixed: the template declares one now)*
2. **The engine replaces it at runtime** → a static meta can be overwritten while the app boots, so the file looks right and the phone still will not zoom. *(fixed: a `MutationObserver` keeps re-asserting it)*
3. **`touch-action: none` on Flutter's canvas** → even with a permissive viewport, the engine owns every gesture, so the browser is not allowed to zoom. *(fixed: a `pinch-zoom`-only override — NOT `pan-x pan-y`, which would steal in-app scrolling)*
4. **The engine mistakes zoom for a resize** → once zoom worked, panning left a growing WHITE band on the right/bottom (owner, 2026-09-30: *"jitna ziada qareeb karo itna ziada white"*). Flutter's web engine reads `window.visualViewport`, sees the zoomed (smaller) view as "the window shrank", re-lays the app out to `screen / zoom` and shrinks its canvas — while the browser still lets you pan the full LAYOUT viewport, so everything beyond the shrunken canvas is empty. 2× zoom ⇒ ~half the screen white, which is exactly what the screenshots showed. *(fixed: a `visualViewport` shim that reports the layout-viewport size but keeps the real `scale`)*

**Verify it, don't assume it.** The served file is the only truth (browser cache and Cloudflare can hide a good deploy):

```sh
# both hosts: the four markers must ALL be present in the SERVED html
for u in https://traceodd.com/ https://market.traceodd.com/; do
  echo "== $u"
  curl -s "$u" | grep -o 'content="width=device-width[^"]*"' | head -1
  curl -s "$u" | grep -c 'MutationObserver'          # expect >= 1
  curl -s "$u" | grep -c 'touch-action: pinch-zoom'   # expect >= 1
  curl -s "$u" | grep -c 'visualViewport'             # expect >= 1
  curl -s "$u" | grep -c 'background-color: #0a0e21'  # expect >= 1
done
```

**On the phone, zoom must do all three:** pinch in → text gets bigger, **and** panning around shows app content the whole way (no white band at the right/bottom), **and** one-finger in-app scrolling still works.

If a marker is missing, in this order: ① the deploy did not run (check the Actions run) ② **Cloudflare/browser cached the old `index.html`** (the conf sends `no-cache`, but verify with `curl -H 'Cache-Control: no-cache'`) ③ the PWA service worker is serving a cached shell — hard-reload / unregister the SW ④ **an installed PWA** (Add to Home Screen) can ignore zoom even when the page is correct — test in a normal browser tab ⑤ then **test on a real phone** with two fingers, and check whether the app's own scrolling still works (it must).

**Then** report the result; only after zoom is confirmed working move to item 10.

### The loop (this is the whole workflow)

1. **Edit** the files.
2. **Push** — this is what deploys:
   ```sh
   cd C:\Ecosystem\NexaTrace_System
   git add .
   git commit -m "FIX: <what changed and why>"
   git push origin mainnew        # ⬅ BRANCH IS `mainnew` (not main, not master)
   ```
   The push triggers **Deploy Flutter Web Frontend** (`frontend-deploy.yml`, builds + rsyncs + nginx),
   **Deploy to Hetzner** (`deploy.yml`, backend migrate + seeders) and **Tests** (`tests.yml`).
   **Wait ~10 minutes and read the result** — red or green. That is faster and more reliable than
   building locally.
3. **Only if red**, read the log and fix.

**Heavy commands are automatic — never run them locally.** The push itself starts them:
`frontend-deploy.yml` runs `flutter build web` for every app + rsync + nginx, `deploy.yml` runs
`migrate`/seeders, `media-engine-build.yml` builds the Rust image, and `tests.yml` runs the tests.
All of them are already running by the time your push returns, and they report red/green in ~10–12
minutes. So: **edit → push → read the CI result**. Do not run `flutter build`, `composer install`,
`cargo build`, or a whole-tree `dart analyze` in the IDE (they take 15–25 minutes here and are the
reason turns used to time out).

### Commands: which may run in the IDE, and which may NOT

| Allowed (fast) | Never run here (heavy — CI does them) |
|---|---|
| `php -l <file>` | ❌ `flutter build web …` (any target — 15–25 min, used to time out) |
| `cd backend && php -d extension_dir=C:/php/ext -d extension=pdo_sqlite vendor/bin/phpunit --no-coverage` | ❌ a whole-tree `dart analyze lib/` |
| `dart analyze --no-fatal-warnings <only the files you touched>` | ❌ `composer install`, `cargo build` |
| `python -c "import yaml; yaml.safe_load(open('.github/workflows/<f>.yml'))"` to check a workflow edit | ❌ re-running a deploy locally |
| `node .scripts/check-panel-isolation.mjs` (the layering guard) | ❌ `cargo check --workspace` as proof of the gst files |

**Dart/Flutter binary path** (Flutter is NOT on the Zed shell's PATH — it is only on the Windows PATH):

```sh
/c/src/flutter/bin/dart analyze --no-fatal-warnings <files>
/c/src/flutter/bin/flutter pub get          # only if pubspec changed
```

**Backend tests** need the sqlite driver enabled explicitly — it exists but is not loaded by default:

```sh
cd backend && php -d extension_dir=C:/php/ext -d extension=pdo_sqlite vendor/bin/phpunit --no-coverage
```

**Media engine (Rust) — the only check that proves anything:**

```sh
cargo check -p todd-signaling -p todd-sfu --features gst   # the CI command
cargo test  -p todd-transcode --features gst
```
A green `cargo check --workspace` proves **nothing** about `forwarder.rs`, `mixer_gst.rs` and
`audio.rs` — they are behind `#[cfg(feature = "gst")]`. Windows setup is in Appendix B §7.

### Rules the owner has repeated (do not relearn these)

- **Only essential commands in the IDE.** Builds belong to CI (see the table).
- **Restore, don't rebuild**; no new features while a phase is being restored.
- **A failure must STAY, be COPYABLE and be CLOSABLE** — use `StickyErrorBanner`
  (`lib/shared/widgets/feedback/`) and never a fire-and-forget SnackBar.
- **The Super Admin and every Sub-Admin own no factory and no product** — oversight is read-only.
- **Kisan / agri belongs to the B2B side** (`market.traceodd.com`), never the B2C Universal app.
- **The branch is `mainnew`.** A push to it deploys.

---

## 1. Read order

1. **this file** (workflow, commands, runbooks, live bugs).
2. `docs/handoff/MASTER-TASK-LIST.md` — **the running order.** Every outstanding item, numbered, in
   the order to do it, plus the done-ledger, the decisions, the isolation model, the surface
   registry, Phase K and **Module 19 (Services & Skilled Workers Grid)**. **A fresh session
   continues from the first ⏳ item there** — nothing gets re-done and nothing gets skipped.
   It also carries the ground rules, the hard rules and the key findings.
3. Appendices in this file, only when the task needs them:
   - **Appendix A** — the credential-remediation runbook (was `PHASE-0A-CREDENTIAL-REMEDIATION.md`).
     Needed before/while doing `MASTER-TASK-LIST.md` items 1–3. **§3.6.1 = the Super Admin
     (`admin_users`) password procedure.**
   - **Appendix B** — the streaming / media-engine fault history (was
     `STREAMING-HISTORY-AND-FIX.md` + `QODER-CRICKET-STREAM-BRIEF.md`). Read before touching
     `media-engine/**`. **§7 = Windows GStreamer setup.**

---

## 2. ⭐ The owner's TOP-LEVEL priority order (2026-09-26)

Full table in `MASTER-TASK-LIST.md` §2. Summary:

| # | Priority |
|---|---|
| **1** | **End the mixing. Remove junk files and code.** Super Admin out of every group's account creation; every sub-admin confined to its own domain |
| **2** | **Build the missing dashboards** — any panel/app whose build or dashboard does not exist yet |
| **3** | **Test that every panel/app can LOG IN and reach its own dashboard.** Login + dashboard entry **only** |
| **4** | **Subdomain + Cloudflare** for every panel/app not yet linked |

**Standing scope rule:** *"for now we are not doing much internal coding."* Priority 3 is a
*verification* phase, not a build phase — do **not** start fixing what is inside each dashboard.

---

## 3. Phase status (summary — the authority is `MASTER-TASK-LIST.md` §3)

| Phase | Content | Status |
|---|---|---|
| **A** | A1 double-hash footgun · A2 `CompanyRegisterBloc` · A3 dead sidebar button | ✅ all (A3 = `3b072d09`) |
| **B1** | factory auth domain split — closes the cross-domain token leak | ✅ factory done; admin/sub-admin = item 26 |
| **C0** | Group-Incharge design | ✅ |
| **C1** | missing verticals + `financial_auditor` owns `plans/**` + `billing/**` | ✅ |
| **C2 / C2b** | factory + reseller account creation move to their Sub-Admins | ✅ |
| **C3** | remove group-account creation from the Super Admin (Factory) | ✅ |
| **C3b → C4 → C5** | registries genuinely read-only → read-only group activity + payments → audited "enter sub-admin view" | ⏳ items 22, 24, 25 |
| **Error sweep** | errors stay + Copy everywhere | ✅ item 5 (Sub-Admin) · ⏳ items 6–9 |
| **Marketplace** | upload flow · products · panel sections · public site · cart | ✅ built; DNS = item 4; order = item 19 |
| **Phase K (Kisan)** | K1–K6 | ⏳ item 47 |
| **Module 19 (Services)** | S1–S4 | ⏳ item 48 (spec = `MASTER-TASK-LIST.md` §8) |

---

## 4. Super Admin password — the simplest possible steps

`https://admin.traceodd.com/login` authenticates against the **`admin_users`** table
(`AdminAuthController@login`). The screen's *Forgot Password?* link is a **placeholder** — there is
no self-service reset, so an operator sets it. **Full detail: Appendix A §3.6.1.**

```bash
cd /var/www/traceodd/admin-panel

# (1) create the helper script — the exact file is in Appendix A §3.6.1, copy-paste it
# (2) run it for your account:
sudo -u www-data php reset-admin-pw.php admin@nexatrace.local
#     -> it will ask for the new password TWICE. Type it. Nothing is shown on screen.
# (3) log in at https://admin.traceodd.com/login
# (4) remove the script so it cannot be reused:
rm -f reset-admin-pw.php
```

**The script never prints, logs or stores the password** — it reads it from a hidden prompt and the
model hashes it. So the value never reaches a chat, a shell history, or this repository.
**Do not** hash manually — the `AdminUser` mutator already hashes (and safely skips an
already-hashed value).

There is also **`.scripts/make-admin-spine.php`** — the maintained, defensive script that puts an
admin into the **identity spine** (the fix for §6 below). `php -l` clean.

---

## 5. New requirement not yet designed — Marketing hierarchy (owner, 2026-09-26)

A **new sub-admin vertical**: **Marketing**. Unlike the others it is a **4-level field hierarchy**
that markets **every** group at once:

```
Marketing Sub-Admin                       (1, appointed by the Super Admin — like the other verticals)
   └── District Marketing Administrator    (the sub-admin decides how many districts each holds)
          └── District Marketing Manager   (district(s) allowed by the sub-admin)
                 └── Marketing Agent       (many, under each manager)
```

**Two things make it its own design task:** (1) **every level has its own APP** — four new
surfaces, not one; (2) **compensation is per person, in three modes** — *salary only* ·
*salary + commission* · *commission only* — and the commission path must reuse the **idempotent
split engine** (`MASTER-TASK-LIST.md` §8 / spec §10.5) rather than inventing a second ledger.

**Status:** it is `MASTER-TASK-LIST.md` **item 46 (C1b)** — the full spec (four surfaces, the
time-tiered split table, per-person compensation, district allowances, courses, the open questions)
is in `MASTER-TASK-LIST.md` §3 item 46 and the decisions in §7.

---

## 6. ⚠️ Known live bug — Super Admin login returns 401 (diagnosed 2026-09-26)

**Reported:** an `AdminUser` row exists (`email: tahawan72@gmail.com`, `role: super_admin`,
`status: active`) yet `POST /api/v1/auth/login` always returns **401 "Invalid credentials"**.

### The diagnosis — this is NOT a password problem

There are **two different login endpoints**, reading **two different tables**:

| Endpoint | Controller | Reads | Used by |
|---|---|---|---|
| `POST /api/v1/auth/login` | `GlobalAuthController` | **`identity_claims` → `global_identities`** (the §10.1 identity spine) | the Flutter **Super Admin** screen (`AdminAuthRepository:159`) **and** the Sub-Admin screen (`SubAdminBloc:53`) |
| `POST /api/v1/admin/login` | `AdminAuthController` | **`admin_users`** | nothing in the Flutter app (a legacy/API-only path) |

`GlobalAuthController@login` resolves like this:

```php
$claim = IdentityClaim::where('claim_type', $claimType)
    ->where('claim_value', $normalized)
    ->where('is_revoked', false)->first();

if (!$claim) {                      // <-- this is the 401 the owner sees
    return response()->json(['status' => 'error', 'message' => 'Invalid credentials.'], 401);
}
$identity = GlobalIdentity::find($claim->global_identity_id);
...
if (!$identity->verifyPassword($password)) { ... 401 ... }
```

**So:** a row in `admin_users` is invisible to `/api/v1/auth/login`. With no matching
`identity_claims` row, the request fails at `claim_not_found` **before the password is ever
checked** — which is why **resetting the password cannot fix this**, and why the reported symptom
is a hard, constant 401.

### Confirm it in one query

```bash
sudo -u postgres psql -d nexasystem_db -c "
  SELECT 'identity_claims' AS t, count(*) FROM identity_claims WHERE claim_value ILIKE '%tahawan72%'
  UNION ALL
  SELECT 'global_identities', count(*) FROM global_identities
    WHERE display_name ILIKE '%tahawan%' OR identity_token ILIKE '%tahawan%'
  UNION ALL
  SELECT 'admin_users', count(*) FROM admin_users WHERE email = 'tahawan72@gmail.com';"
```

Expected: `admin_users = 1`, and `identity_claims = 0`, `global_identities = 0`. That is the whole bug.

### The fix — two options, and they are NOT equivalent

| Option | What | Verdict |
|---|---|---|
| **A — put the admin in the identity spine** (create `global_identities` + `identity_claims` + the `tenant_accounts` bridge, exactly as `MasterAdminSeeder` does) | the account then exists where the unified login looks | ⭐ **Correct.** The token carries spine claims, so `TokenVersionGuard` / `IdentityStatusGate` / feature grants keep working |
| **B — point the Super Admin screen at `/api/v1/admin/login`** | a one-line client change; it reads `admin_users` | ❌ **Do not.** The token would lack spine claims, and every §10.10 middleware that expects them breaks |

**Recommended, concretely:** run **`.scripts/make-admin-spine.php`** (option A, maintained and
defensive). It prints the live column list first, wraps every step in a guard that reports the real
exception and continues, syncs `admin_users` too, and ends with a verification block that mirrors
`GlobalAuthController@login` exactly.

**First, inspect the live schema** if anything fails:

```bash
sudo -u postgres psql -d nexasystem_db -c "
  SELECT table_name, column_name, data_type, is_nullable
  FROM information_schema.columns
  WHERE table_name IN ('global_identities','identity_claims','admin_users','master_admin_assignments','tenant_accounts')
  ORDER BY table_name, ordinal_position;"
```

**Then run the script** — copy the file from `.scripts/make-admin-spine.php` to the server:

```bash
cd /var/www/traceodd/admin-panel
# copy .scripts/make-admin-spine.php here (scp, or paste it into nano)
sudo -u www-data php make-admin-spine.php tahawan72@gmail.com
rm -f make-admin-spine.php
```

**Send the script's full output** if anything says `FAIL` — the first block prints every column, so
the cause will be visible. The FK column is confirmed correct: `identity_claims.global_identity_id`
→ `global_identities.id`.

**Still owed to the owner:** an Artisan command `php artisan admin:reset-password <email> <password>`
that reports **which table holds the account** and sets the password in the right place (spine **and**
`admin_users`) instead of silently doing nothing. Until then, Appendix A §3.6.1 handles the
`admin_users` half and this script handles the spine half.

---

## 6b. Live issues found while testing (2026-09-26/27) — one fixed, two open

Three **separate** causes; do not confuse them.

### ✅ FIXED — every panel called the API over plain HTTP (`Mixed Content`)

**Symptom:** `admin.traceodd.com/companies` showed *"Unexpected error: failed to fetch"*, and no
factory appeared in either panel.

**Cause:** there were **three** base-URL sources and only one was correct:
`core/config/environment.dart` → `ApiConfig.apiBaseUrl` (✅ correct) vs
`core/constants/api_endpoints.dart` → `ApiEndpoints.baseUrl`
(`String.fromEnvironment('API_BASE_URL', defaultValue: 'http://135.181.46.27/api/v1')` — ❌ the web
bundle is built **without** the define, so a hardcoded **HTTP** IP) vs
`core/constants/app_constants.dart` + `core/navigation/panel_routes.dart` (❌ hardcoded
`http://135.181.46.27`). The admin Dio client used `ApiEndpoints.baseUrl`, so every call went to
`http://…` and an HTTPS page may not fetch that — the browser blocked it, which is why lists looked
*empty* rather than erroring in the app. **Fix (`a93dbb1f`):** all three now resolve at **runtime**
through `ApiConfig.apiBaseUrl`.

### ⏳ OPEN (item 11) — `GET /api/v1/admin/analytics/dashboard` returns **500**

Not caused by C0–C2b. It is `AnalyticsService` (Module 1D, marked *"additive"*); the route itself is
fine — the admin group's `analytics` block is only **mis-indented**, so it really is
`admin/analytics/dashboard`.

**Get the real exception:**

```bash
sudo tail -n 100 /var/www/traceodd/admin-panel/storage/logs/laravel.log
```

Two suspects, in order: (1) **`AnalyticsService.php:233`** —
`DB::getPdo()->getAttribute(\PDO::ATTR_CONNECTION_STATUS)`, a **MySQL** feature; pgsql commonly
answers `SQLSTATE[IM001] Driver does not support this function`. It is the only use in the whole
backend and it is on this exact path. (2) `base_codes.generated_at` — read at
`computeRealtimeDashboard():216` and `computeHealthScore():231,234`. **Do not blind-fix** — one line
in the log names the culprit.

### ⏳ OPEN (item 10) — service worker served as `text/html`

```
Failed to register a ServiceWorker … 'flutter_service_worker.js' … unsupported MIME type ('text/html')
```

nginx fell through to `try_files … /index.html` for that path, so `flutter_service_worker.js` is
**missing from the deployed directory** (or a `location` block for it is absent). Cosmetic — the app
still runs — but it also means Flutter's own cache-busting is off. Check the deployed bundle and
`.nginx/*.conf`.

---

## 6c. FIXED — the Sub-Admin's factory list was empty while the API returned `200`

**Symptom:** the Factory Sub-Admin created a factory successfully, the Super Admin's `/companies`
showed it, but the Sub-Admin's own list stayed empty. Server evidence:
`GET /api/v1/admin/factory-companies` → **200** with `{"success":true,"data":[]}`, and the token was
the right sub-admin (Zahid, `global_identity_id = a2d85a17-2a9f-4e78-8842-432d45ee5008`).

**Root cause:** the C2 controller scoped the list with a **JSON path**
(`where('metadata->>created_by_sub_admin_id', $id)`). That predicate returns the row in **psql** but
produced an **empty result inside Laravel** — so the API answered 200 with no rows, and the UI (which
only renders `state.factoryCompanies`) showed an empty list and **hid the truth**. The Super Admin's
list worked because it applies **no such filter** at all — the owner spotted exactly that.

**Fix (2026-09-27):**

| Piece | Change |
|---|---|
| `2026_09_27_000002_add_created_by_sub_admin_id_to_companies.php` | **new** — a real indexed `created_by_sub_admin_id` column on `companies`, **backfilled** from the metadata key the first version wrote (with a uuid-regex guard) |
| `Company::$fillable` | the column added — without it `create()` silently drops it (the same trap as `Reseller`) |
| `SubAdminFactoryCompanyController` | `ownedQuery()` is now a plain `where('created_by_sub_admin_id', $id)`; `store` writes the column as well as the metadata (metadata kept for the creator's **name** and audit) |

**Lesson recorded:** for scoping, use a **real indexed column** — the same decision
`SubAdminResellerController` had already made. A JSON-path filter that "looks right" and passes
`psql` can still silently return nothing through Eloquent.

**✅ Fixed (item 5, this commit):** the Sub-Admin dashboards now render their list/`form`/`action`
failures through `StickyErrorBanner` (sticky + Copy + Close), so a failed request can no longer look
like "no data". Dismissing a list error hides the banner **without** falling back to the empty box.

---

## 6d. FIXED — `market.traceodd.com` rendered BLANK (live)

The marketplace deploy step copied a hand-written `web/index-marketplace.html` **over the BUILT**
`build/web/index.html` to add a zoomable viewport. That template carried Flutter's build-time
placeholder `<base href="$FLUTTER_BASE_HREF">`; Flutter had already resolved it in the built file, so
the copy put the **literal placeholder** back and the loader refused the page:
*"The base href has to end with a \"/\" to work correctly"*.

**Fix:** never overwrite the built file — `web/index-marketplace.html` is **deleted** and
`.scripts/patch-marketplace-head.py` **patches** the built `index.html` in place (viewport + title +
description + theme colour) and never touches `<base href>`. The deploy step now **fails loudly** if
the literal placeholder is present or the base href does not end with `/`, and warns if the viewport
patch did not apply.

---

## 7. Owner's decisions recorded 2026-09-26 (second round)

| Topic | Decision |
|---|---|
| **The 3 legacy `company_admin` rows** (`armi@`, `aziz@`, `khan@gmail.com`) | **Suspend, don't delete** (keeps FK-dependent records intact). Check `companies` for rows referencing them first. *(An earlier decision said delete; suspend is the later, safer ruling.)* |
| **Marketing hierarchy** | **Its own top-level Group** — its own frontend + backend + database, its own server later. Four surfaces. The Marketing *Manager* also does **client onboarding** (register bus-fleet / factory accounts, upload documents, hand the panel over) — that is how commission is attributed |
| **Marketing courses** | Each Marketing panel must carry **how-to-use material for every panel/app** — video and screenshots — so a manager can train the client they onboarded |
| **Compensation** | Per-agent mode: *salary only* · *salary + commission* · *commission only*. Commission must reuse the **idempotent split engine** (`MASTER-TASK-LIST.md` §8 / spec §10.5) — no second ledger |
| **Scope reminder** | *"for now we are not doing much internal coding"* — priority 3 is **login + dashboard entry only** |

---

## 8. What the long session of 2026-09-24 → 26 produced

The full commit → change → isolation-baseline table is in `MASTER-TASK-LIST.md` §10 (provenance).

| Commit | What | Isolation baseline |
|---|---|---|
| `ca591a98` | CI boundary guard + measured the real coupling | 84 |
| `969aab00` | 4 dead `core/` files removed | 77 |
| `3be02476` | dead `transport` + `transport_marketplace` removed (20 files, −6,116 lines) | 75 |
| `eba16ee6` | provider split — **`core → features` is now 0** | **28** |
| `9f59ef28` | **`/sub-admin/*` route guard** (owner smoke-tested: all pass) | 28 |
| `126f618d` | duplicate Super Admin bus/goods company registration removed (−2,346 lines) | 28 |
| `5c16d006` | **A1** — double-hash lockout footgun removed | 28 |
| `303eebf8` | owner's answers folded into the Group-Incharge model | 28 |

**Not started (see `MASTER-TASK-LIST.md` §3):** C3b–C5, the Shop Keeper / B2B builds, the Marketing
design (C1b), Module 19, and the per-pillar builds.

---

# Appendix A — Credential remediation runbook

> Was `docs/handoff/PHASE-0A-CREDENTIAL-REMEDIATION.md` (2026-09-25). **The original §-numbers are
> kept** so code/CI comments that cite `§3.6.1`, `§5`, `§3.6`, `§2` still resolve.
> **The compromised password values are deliberately NOT quoted here** — they are already in git
> history; read them there if you must, then rotate. Nothing in this file should trip a secret scan.

**Thesis:** the values were committed to a repo with a remote, so anyone with repo access (or any
fork, ever) has seen them. *Removing a string does not undo that. **Only rotation closes the
window.*** Deleting the text is hygiene; rotating the password is the fix.

**Who does what:** §2 done in-repo · **§3 = the owner, server-side** · §4 = owner, after §3 · §5 =
2-minute change, either party.

## §1 What was found (2026-09-25 audit)

The audit found credential exposure in, at least: the factory + store-keeper login screens
(pre-filled credentials, so anyone could sign in — 🔴 critical) · `backend/database/deploy.ps1`
(four production passwords as parameter defaults) · `backend/database/backup.ps1` ·
`backend/database/seeders/NexaBootstrapSeeder.php` · `README.md` (SSH **root** password + both admin
passwords) · `backend/database/DEPLOYMENT.md` (`CREATE ROLE … PASSWORD '…'` + the `.env` example) ·
`NEXATRACE_SUPREME_MASTER_SPEC.md` §8.6 (a credentials table) ·
`backend/database/seeders/MasterAdminSeeder.php` (a hardcoded highest-privilege password) ·
`backend/database/seeders/SubAdminSeeder.php` (one shared password for **every** sub-admin) ·
`lib/features/nexa_admin/…/sub_admin_login_screen.dart` (`hintText` disclosing a real account name) ·
`lib/core/config/database_config.dart` (a **`postgres` superuser** URL + the non-standard port
**5444**) · the separation-plan/recommendations docs (quoting the values as evidence).
The Postgres **superuser** password was reused verbatim in at least three files, and one admin
password was shared across every admin account. The seeders **create live accounts** when they run —
so those passwords must be **rotated**, not just removed from code.

## §2 Fixed in-repo (committed)

`README.md` (values → a password-manager pointer) · `deploy.ps1` / `backup.ps1` (no defaults; read
`NEXATRACE_PG_*`, **throw** when missing) · `DEPLOYMENT.md` (placeholders; it had *instructed
creating* `database_config.dart` — the root cause) · `NexaBootstrapSeeder.php` (password from
`NEXATRACE_BOOTSTRAP_ADMIN_PASSWORD`, throws if unset — safe, because `deploy.yml` only runs
`CricketFeatureRegistrySeeder`) · both factory login screens (pre-filled credentials removed) ·
`NEXATRACE_SUPREME_MASTER_SPEC.md` §8.6 · `.gitleaks.toml` + `.github/workflows/secret-scan.yml`
(new working-tree scan) · `lib/core/config/database_config.dart` **deleted** (`bdb3001d`).
⚠️ **The PowerShell changes are untested** (no Windows runner). Before the next DB deploy/backup,
run the script once on a scratch container and confirm it works with the env vars set **and** fails
with the "missing required password" message when they are not.

## §3 YOUR TASKS — server-side, in this order

Run these on the Hetzner server (`135.181.46.27`, `ubuntu-16gb-hel1-2`). **Do not skip §3.1.**

### §3.1 Check whether the database is exposed to the internet (DO THIS FIRST)

```bash
ss -tlnp | grep 5444
sudo -u postgres psql -t -c "SHOW hba_file;"
sudo grep -vE '^\s*#|^\s*$' /etc/postgresql/*/main/pg_hba.conf
```
Look for lines ending `0.0.0.0/0` or `::/0`. **Also check the Hetzner Cloud Firewall** in the console
for a rule allowing port **5444** — that is the layer that matters most.

### §3.2 Close the exposure

```bash
sudo ufw deny 5444/tcp
sudo ufw status verbose
sudo cp /etc/postgresql/*/main/pg_hba.conf /etc/postgresql/pg_hba.conf.bak-phase0a
sudo nano /etc/postgresql/*/main/pg_hba.conf
# change every 0.0.0.0/0 line to 127.0.0.1/32 (and ::/0 to ::1/128), prefer scram-sha-256 over md5
sudo systemctl reload postgresql
```
If the Laravel app runs on a **different** host, list that host's IP explicitly — never `0.0.0.0/0`.

### §3.3 Rotate the database passwords

Generate four different strong passwords in the password manager first, then:

```sql
ALTER ROLE postgres        WITH PASSWORD '<new-1>';
ALTER ROLE nexa_app        WITH PASSWORD '<new-2>';
ALTER ROLE nexa_readonly   WITH PASSWORD '<new-3>';
ALTER ROLE nexa_superadmin WITH PASSWORD '<new-4>';
```

### §3.4 Update the app on the server — or the app breaks

```bash
cd /var/www/traceodd/admin-panel     # or /var/www/nexatrace/admin-panel — whichever exists
nano .env                            # set DB_PASSWORD='<new-2>'
php artisan config:clear && php artisan optimize:clear && php artisan optimize
php artisan db:monitor --databases=pgsql
```
If it still fails, check `storage/logs/laravel.log` for
`password authentication failed for user "nexa_app"`. **Never skip this step** (§6).
**Quote every secret in `.env`** — `DB_PASSWORD='…'`. An unquoted `#` is parsed as a comment and
truncates the value (that was a real live incident, §3.9.1).

### §3.5 Rotate the SSH root password (and ideally stop using passwords)

```bash
passwd root
```
Better: add your public key to `/root/.ssh/authorized_keys`, **open a SECOND terminal and confirm
key login works before changing anything**, then set `PermitRootLogin prohibit-password` in
`/etc/ssh/sshd_config` and `sudo systemctl reload ssh`.

### §3.6 Rotate the panel admin logins

⚠️ **Fixing the seeders does NOT change existing accounts** — rows already in the DB keep the old
passwords. Two tables hold the login and must stay in sync: `global_identities.password_hash`
(written via `Hash::make`, the model has a mutator) and `tenant_accounts.password` (**stores the
already-hashed string as-is** — no mutator). So always write **the same hash** to both.

```bash
cd /var/www/traceodd/admin-panel
# STEP 0 — full database backup (this is what makes the rest reversible)
sudo -u postgres pg_dump nexasystem_db > ~/nexasystem_db-backup-$(date +%F-%H%M).sql
# STEP 1 — see which records exist (no passwords shown)
sudo -u postgres psql -d nexasystem_db -c "SELECT identity_type, display_name, id FROM global_identities WHERE identity_type IN ('admin','sub_admin') ORDER BY 1,2;"
sudo -u postgres psql -d nexasystem_db -c "SELECT id, account_type, email, (global_identity_id IS NOT NULL) AS has_spine FROM tenant_accounts WHERE account_type IN ('master_admin','sub_admin') ORDER BY 2;"
sudo -u postgres psql -d nexasystem_db -c "SELECT count(*) AS admin_users_rows FROM admin_users;"   # >0 → tell the dev; that is a SEPARATE login path (§3.6.1)
```
Generate a fresh hash for each identity, write it to **both** `global_identities.password_hash` and
`tenant_accounts.password` for that `global_identity_id`, write a hash backup to
`/tmp/pw-backup-<STAMP>.json` **first**, print the new plaintext **once** so it can be stored in the
password manager, then `rm -f` the script. **Never leave a password-rotating script on the server.**
Verify by logging in through the app UI; the accounts are `admin@nexatrace.com` (master) and the
`*.admin@nexatrace.com` sub-admins. Restore from the JSON backup if a login fails.

Re-running the seeders later requires the env vars or they **throw**:
`NEXATRACE_BOOTSTRAP_ADMIN_PASSWORD`, `NEXATRACE_MASTER_ADMIN_PASSWORD`,
`NEXATRACE_SUBADMIN_PASSWORD`. (`deploy.yml` runs only `CricketFeatureRegistrySeeder`, so none of
these run automatically.) Minor inconsistency to unify later: sub-admin emails use
`@nexatrace.com`, other seeders use `@nexatrace.local`.

### §3.6.1 Super Admin (`admin_users`) — setting the password safely

**This is the login at `https://admin.traceodd.com/login`.** Use it when the password is unknown or
needs rotating, with the value **never** appearing in a chat, a ticket, `argv`, shell history, psysh
history, or a script left on disk.

Step 1 — find the account (no passwords shown):

```bash
sudo -u postgres psql -d nexasystem_db -c \
  "SELECT id, email, name, role, status, force_password_change FROM admin_users ORDER BY email;"
```

Step 2 — create the helper script (`cat` with a **quoted** heredoc, so nothing is interpolated):

```bash
cd /var/www/traceodd/admin-panel
cat > reset-admin-pw.php <<'PHP'
<?php
// Set ONE admin_users password, entered WITHOUT echo.
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\AdminUser;

$email = $argv[1] ?? null;
if (!$email) { fwrite(STDERR, "usage: php reset-admin-pw.php <email>\n"); exit(2); }

$u = AdminUser::where('email', $email)->first();
if (!$u) { fwrite(STDERR, "No admin_users row for {$email}\n"); exit(1); }

function hidden(string $prompt): string {
    echo $prompt;
    system('stty -echo');
    $v = rtrim((string) fgets(STDIN), "\r\n");
    system('stty echo');
    echo "\n";
    return $v;
}

$pw = hidden("New password for {$email} (typing hidden): ");
if (strlen($pw) < 12) { fwrite(STDERR, "Refusing: use at least 12 characters.\n"); exit(1); }
if ($pw !== hidden('Repeat: ')) { fwrite(STDERR, "Refusing: passwords did not match.\n"); exit(1); }

$u->password = $pw;              // AdminUser::setPasswordAttribute -> Hash::make()
$u->force_password_change = false;
$u->password_changed_at = now();
$u->save();

echo "Updated {$u->email}. Log in to verify, then delete this script.\n";
PHP
```

Step 3 — run it and type the password at the prompt:

```bash
sudo -u www-data php reset-admin-pw.php <the-email-from-step-1>
```
If `stty` complains about no terminal, run it as root without `sudo` (the DB connection does not
depend on the OS user).

Step 4 — verify then remove:

```bash
# log in at https://admin.traceodd.com/login
rm -f reset-admin-pw.php
```

Notes: `AdminUser` has a `setPasswordAttribute` mutator that calls `Hash::make`, so assign the
**plaintext** — do **not** hash it in the script. `force_password_change` is cleared. **There is no
self-service reset** (`login_screen.dart:360` = `// TODO: Implement forgot password flow`).
`POST /api/v1/admin/change-password` exists but requires knowing the current password.
**This resets `admin_users` only** — it does **not** put the account in the identity spine, so
`/api/v1/auth/login` still 401s (see `START-HERE.md` §6 and `.scripts/make-admin-spine.php`).

### §3.7 Verify from outside

From Windows PowerShell — this must **fail**: `Test-NetConnection 135.181.46.27 -Port 5444` →
`TcpTestSucceeded : False`. Then confirm the app works end-to-end (log in, load a dashboard).

### §3.8 Record the date

Note the rotation date. Anything that logged into the database before that date with those
credentials cannot be distinguished from legitimate traffic — the date defines the exposure window.

### §3.9 ⚠️ After rotating, Laravel may keep using a DIFFERENT password

Symptom: `.env` updated, PostgreSQL accepts the new password, but `php artisan db:show` still fails,
and `config('database.connections.pgsql.password')` shows a value that is **neither the old nor the
new** one. `config/database.php` is a plain `env('DB_PASSWORD', '')` — no hardcoded fallback — so a
third value can only come from: (1) a **config cache** (`bootstrap/cache/config.php` — `deploy.yml`
runs `php artisan optimize`, which freezes it); (2) a real **process/OS env var** `DB_PASSWORD`
(Dotenv does not overwrite existing variables); (3) **`.env.production`** (loaded when `APP_ENV` is
in the process environment; `.gitignore` expects the file on the server); (4) `.env` itself.
Diagnose **without printing any value** (`ls -la bootstrap/cache/config.php`, `php artisan about`,
`php artisan tinker --execute="echo app()->environmentFile()"`, fingerprint both values with
`sha256`, `grep -rl DB_PASSWORD /etc/environment /etc/profile.d/ /root/.bashrc /etc/systemd/system/`,
and `env -u PGPASSWORD psql -w …` to prove a password really is required). Fix per cause:
config cache → `php artisan optimize:clear`; process env → remove it and re-login; `.env.production`
→ update it too; CRLF → `sed -i 's/\r$//' .env`; quotes/`$` → single-quote the value.
**Rule:** after any `.env` change, run `php artisan optimize:clear && php artisan optimize`.

### §3.9.1 CONFIRMED root cause (live incident, 2026-09-25)

The `DB_PASSWORD` value contained a `#` character and was **unquoted** in `.env`. phpdotenv treats
an unquoted `#` as the start of a comment, so it **truncated** the password before Laravel saw it —
PostgreSQL held the full value, Laravel sent a shortened one. Evidence (no value printed): config
cache absent; process env `DB_PASSWORD` NOT SET; `.env.production` does not exist; `psql` with the
full value LOGS IN; `psql -w` without `PGPASSWORD` says `no password supplied`. Fix:

```bash
grep -c "^DB_PASSWORD=.*'" .env                                    # must be 0
sed -i "s/^DB_PASSWORD=\([^']*\)$/DB_PASSWORD='\1'/" .env        # wrap in SINGLE quotes
php artisan optimize:clear && php artisan db:show
```

**Two general rules:** quote every secret in `.env`; and prefer passwords without shell/env-hostile
characters (safe alphabet: `A–Z a–z 0–9` plus `- _ . ~ ! @ % ^ * +`; a `#` is a landmine in `.env`,
shell, `systemd EnvironmentFile` and Docker `env_file`).

### §3.10 Other findings from the same live investigation

| # | Finding | Fix |
|---|---|---|
| 1 | **`Debug Mode … ENABLED` while `Environment: production`** — error responses leak stack traces, paths and env values | `APP_DEBUG=false` + `php artisan optimize:clear`. **Do this now** |
| 2 | **`intl` PHP extension missing** — `php artisan db:show` dies in `Number.php:443` | `apt install php8.3-intl && systemctl reload php8.3-fpm` |
| 3 | **`bootstrap/cache/config.php` owned by `root`** (created by running `optimize` as root) — later clears as `www-data` fail | `chown -R www-data:www-data bootstrap/cache storage`; run artisan as the app user |
| 4 | **`.env` mode `644` (world-readable)** | `chmod 640 .env && chown www-data:www-data .env` |
| 5 | **A stray `md5` line in `pg_hba.conf`** (dead today, deprecated) | delete the line, reload PostgreSQL |
| 6 | **Server code drifts from the repo** (`NexaBootstrapSeeder.php` on the server had `factory-adminnexatrace.local`, missing `@`) | re-deploy, then verify the file matches |

## §4 After rotation — flip super-admin enforcement

`super_admin.php` uses `super.admin.shadow`, which **logs but does not deny** unless
`SUPER_ADMIN_GATE_ENFORCE` is truthy. ① Read the `super_admin_gate.shadow` log lines. ② Confirm your
own admin account appears **authorised**. ③ Set `SUPER_ADMIN_GATE_ENFORCE=true` in the server
`.env`. ④ `php artisan config:clear && php artisan optimize`. Only then are the platform-admin
endpoints actually protected. (→ `MASTER-TASK-LIST.md` item 2.)

## §5 The new secret scan — how to read it, and how to make it a real gate

The scan is `.github/workflows/secret-scan.yml`, configured by `.gitleaks.toml`.
- It scans the **working tree only** (`--no-git`), not history — on purpose (history still contains
the removed credentials). Once §3 is complete, history scanning can be switched on with an
allowlist entry for the old commits.
- ⚠️ It currently runs with **`continue-on-error: true`** — deliberate for a new workflow.
- To make it a hard gate: ① open the Actions tab, look at the first `Secret scan (working tree)`
  run; ② confirm **0 leaks** (if a false positive appears, add a **narrow, commented** entry to
  `.gitleaks.toml` — **never** a broad `lib/**` or `backend/**` allowlist); ③ delete
  `continue-on-error: true`; ④ add a `main` branch-protection rule requiring this check.

## §6 Do NOT

- Do **not** re-commit any removed value, even in an example or a comment.
- Do **not** open port 5444 to `0.0.0.0/0` again for convenience.
- Do **not** assume deleting a file removes a secret — git history is permanent and the repo has a
  remote. Assume it is public.
- Do **not** skip §3.4 — rotating the DB password without updating `.env` takes the app down.

---

# Appendix B — Streaming (media-engine) fault history

> Was `docs/handoff/STREAMING-HISTORY-AND-FIX.md` (+ the Qoder brief, whose asks are folded into
> §6). **Original §-numbers kept** — `AGENTS.md` cites **§7** for the Windows GStreamer setup, and
> `MASTER-TASK-LIST.md` item 38 cites the drift-check. It consolidated four now-deleted handoff docs
> (`STREAM-ISSUE-REPORT-FOR-QODER.md`, `FAULT-REMEDIATION-HISTORY.md`, `CRICKET-DEEP-SCAN-FOR-QODER.md`,
> `STREAMING-FAULTS-AND-SOLUTIONS-LATEST.md`) — readable in git history.

**Status: WORKING.** The engine → SRS → HLS → public-page chain publishes again (verified
2026-09-22: SRS reported an active publish for `cricket_match_a2c0880f-…_cam1` with fresh HLS
segments). Three fixes were needed on the one broken hop, plus two recovery fixes.

## §1 The chain

```
Todd Broadcaster (Android, WHIP)
      |  RTMP/WHIP
Todd Studio engine (todd-signaling + todd-sfu)   <- camera + SFU; Studio itself plays via WHEP
      |  on-air camera (PGM)
GStreamer forwarder (todd-transcode)             <- the hop that was broken
      |  RTMP
SRS (1935)  ->  HLS segments
/var/www/traceodd/cricket-hls/live/*.m3u8
      |  nginx  location /hls/ { alias /var/www/traceodd/cricket-hls/; }
https://cricket.traceodd.com/hls/live/{key}.m3u8
      |
Public Flutter web page (HLS player)
```
HLS stream key is **derived from the match id**: `cricket_match_{matchId}_cam1`. The public page
consumes **HLS**; Todd Studio consumes **WHEP** straight from the SFU — that asymmetry is why Studio
looked fine while the public page was dark. Infra: `root@135.181.46.27`, Docker host networking,
containers `todd-studio` (:8082), `todd-broadcaster` (:8081), `todd-redis`; SRS RTMP 1935 / API 1985
/ HLS HTTP 8088 / HLS dir `/var/www/traceodd/cricket-hls`; images on Ubuntu 24.04 + **GStreamer 1.24**
(`media-engine/deploy/docker/Dockerfile`).

## §2 The outage and the fix

| Commit | What |
|---|---|
| `6fab701e` | DOCS: first handoff report |
| `4b4f1127` | 11 reported faults "fixed" — **CI red: 5 compile errors** (written without GStreamer, never compiled) |
| `b9b5db9d` | fixes for those 5 errors |
| `f6fc23b5` | silent audio bus no longer blocks video egress (1500 ms `AUDIO_PRIME_TIMEOUT`) — one-sided, no `build_description` change |
| `f0fc72e5` | **FIX: declare/feed count mismatch** on audio branches — deployed, error text changed, outage continued |
| `e951903b` | **FIX: codec filter** (`VIDEO_CODECS`/`AUDIO_CODECS`) — deployed and firing; console errors gone, bridge still failed |
| `04fa702c` | DIAG: print the built pipeline in the forwarder failure text (this made the bug readable) |
| `e1e181b2` | `tests.yml` triggers moved to `main`/`mainnew` |
| `535ba3c1` `17e4393d` | `composer.lock` synced; `deploy.yml` runs `composer install` |
| `11dbaf8f` | `consumer.php` routes registered (0 → 4) |
| `bdb3001d` | deleted plaintext Postgres credentials in `lib/core/config/database_config.dart` |
| **`ead72810`** | **THE FIX**: declare `rtpopusdepay`'s required RTP payload type on audio branches (§3) |
| `5bebdf76` | public player: stage sized from the viewport; HLS starts at the live edge |
| **`01f5905e`** | **recovery fix**: verify forwarder health at the *far end* (SRS) so a stale `running` state cannot block recovery |
| `269478ef` | health also checks the **HLS playlist is advancing** (`cricket.streaming.hls_dir`, 30 s threshold) |
| `6c57fdc0` | `docs/handoff/` consolidated into the streaming history; **and the Laravel scheduler is now installed by the deploy** |

**Operational gap found:** `cricket:stream-watchdog` is scheduled `everyMinute()` in
`backend/routes/console.php`, but **nothing installed `schedule:run`** (`/etc/cron.d` had no entry;
root crontab held only unrelated rsync jobs) so the watchdog **never ran automatically**. `deploy.yml`
now writes `/etc/cron.d/nexatrace-scheduler` idempotently. Worth confirming this is the only missing
supervisor/cron in the stack. Regression tests were added (gst-gated): a string-level caps assertion,
and a push-level test that builds the real description, pushes one Opus RTP packet and asserts no bus
error (it **skips** with a reason when the needed elements are absent — CI's `check-gst` job installs
only GStreamer's *base* plugins).

## §3 The three root causes — and the WRONG theories

**Root causes (all on the forwarder hop):**
1. **Declared vs fed branch count** (`f0fc72e5`). `build_description` emitted a branch for every
   *enabled* bus while a push task attached only to *primed* buses. Unfed `audiomixer` pads never
   preroll, `flvmux` waits forever, **video never leaves either**. Fixed by deriving both from the
   same `live_buses`.
2. **Wrong codec pushed to an audio branch** (`e951903b`). Priming accepted the first chunk
   regardless of codec → an H.264 chunk reached an `appsrc` whose caps say OPUS →
   `not-negotiated (-4)`. Fixed with an enforced codec filter.
3. **The actual blocker** (`ead72810`). Audio `appsrc` caps were
   `application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000` — **missing `payload`**.
   `rtpopusdepay`'s sink template *fixes* `payload` to `[96, 127]` and a caps event must carry
   **fixed** caps, so `set_caps` failed; the first pushed buffer came back as
   `GST_FLOW_NOT_NEGOTIATED`, reported by the appsrc as
   `streaming stopped, reason not-negotiated (-4)`. `rtph264depay`'s template lists **no**
   `payload` — which is exactly why **only the audio branch died** and the error always named
   `audio_commentary`.

**FALSE LEADS (do not re-chase):**
- **The "mixer declaration ordering" hypothesis was WRONG.** Declaring `audiomixer name=mix` in an
  earlier statement than the branch that links into it is harmless — the full pipeline with real
  Opus RTP reaches EOS and the mixer renegotiates/resamples happily. **Never spend time on this.**
- **The old `gst-launch` A/B "ordering bisect" cannot decide anything.** With no buffer pushed, a
  non-live `appsrc` never negotiates, so the pipeline sits at PLAYING and *looks healthy*. A branch
  must be **fed a real buffer** to be tested.
- Wrong caps string and missing elements were both ruled out.
- `state:"running"` was a lie: nothing watched the bus, so a dead forwarder reported itself healthy
  (fixed by `watch_bus()`).
- **Do not trust a string-level test for a negotiation bug.**

## §4 The fix, in code

- `media-engine/crates/todd-transcode/src/media.rs` — `RtpChunk::rtp_payload_type()` (low 7 bits of
  RTP byte 1) and `FALLBACK_OPUS_PAYLOAD_TYPE = 96`.
- `…/todd-transcode/src/forwarder.rs` — `build_description(live_buses: &[(AudioBus, u8)])` now emits
  `...,payload={pt}` in each audio branch. Camera path takes the **real** payload type from the
  primed chunk; program path uses `mixer_gst::PROGRAM_OPUS_PAYLOAD_TYPE`.
- `…/todd-transcode/src/mixer_gst.rs` — Bus `appsrc` caps get `payload={FALLBACK_OPUS_PAYLOAD_TYPE}`;
  `rtpopuspay pt=` uses the shared `PROGRAM_OPUS_PAYLOAD_TYPE` const.
- `lib/features/cricket/presentation/pages/public/live_match_page.dart` — player stage height from
  the viewport (was fixed 220 px).
- `lib/shared/widgets/hls_video_player_web.dart` — hls.js live config.

**Schema fact to verify the fix:** `gst-inspect-1.0 rtpopusdepay | grep -A6 "SINK template"` shows
`payload: [ 96, 127 ]` — required, and it must be **FIXED**.

## §5 Proof (2026-09-22)

Reproduced locally on GStreamer 1.24.13; adding `payload=111` made caps negotiate and the error
disappeared. Production: `docker logs todd-studio | grep -c not-negotiated` every ~5 s → **0**; SRS
`api/v1/streams/` went from `"streams":[]` to a **publish active**
(`cricket_match_a2c0880f-…_cam1`, 20461 frames, H264 480x800, **audio AAC 44100 stereo** — which also
proves the audio branch negotiates now); the HLS dir went from empty to `.m3u8` + `.ts`; the public
screen went from dark to playing.

## §6 Open items (source of `MASTER-TASK-LIST.md` items 38–39)

**The failure mode that still bites: the publish stalls, the engine keeps saying `running`.** After
the payload fix the feed publishes, but a session can still end with the pipeline alive and idle:
publisher goes away, no buffers reach `flvmux`, SRS drops the feed and deletes the HLS files, engine
still reports `state: running`. That stale state used to be **self-locking** (every recovery path
skips a forwarder that claims to be running → the operator saw a 404, a panel that said healthy,
and *nothing* in the engine logs). The two recovery fixes make it survivable; **the real engine-side
fix — make the state honest — is still to be written.** Leading suspect: the shared-subscription pump
in `forwarder.rs` (`spawn_input_pump`) returns when its router receiver closes but leaves the
consumer channels open, so `spawn_push_task` blocks forever and the appsrcs never reach EOS.
**Complication:** `register_inputs()` is idempotent per track name — it **skips** a name already in
`track_order`, so a re-arm cannot restart a dead track. Any fix must also make a dead track
**revivable** and must not shift consumer indices while other pumps are alive (likely shape:
HashMap keyed by stable track id, or per-track generation). Also check whether a WHIP reconnect with
the same rid re-registers a new router receiver and whether `remove_camera` runs on a plain publisher
drop.

**Everything else:**
1. **HLS latency and startup stutter (top priority).** Player-side fixed (hls.js now uses
   `liveSyncDurationCount: 1`, `liveMaxLatencyDurationCount: 3`, `maxLiveSyncPlaybackRate: 1.5`, plays
   on `MANIFEST_PARSED`). **But** the operator's HLS directory showed segments closing ~1 minute
   apart, not every 3 s. SRS runs **pure remux** (`hls_fragment 3` is only a target) and remux can
   only cut a segment **on a keyframe** → the publisher's GOP governs segment length. Diagnose with
   `cat /var/www/traceodd/cricket-hls/live/cricket_match_<ID>_cam1.m3u8` (look at `#EXTINF`) and
   `docker logs -f --since 2m todd-studio 2>&1 | grep -a "keyframes received"`. If `#EXTINF` is ~3 →
   the player fix was the answer; if ~30–60 → shorten the **Broadcaster's keyframe interval to 1–2 s**
   (server-side, no re-encode). Classic HLS cannot match Studio's WHEP (<1 s); best case ~6–10 s;
   near-instant needs **LL-HLS** or **WHEP**. **Owner's decision: stay on HLS now, migrate to WHEP
   later, carefully** (the public player's earlier WHEP code still exists → a re-wire, not a rewrite).
2. **SFU router cross-delivers media types on its rid-scoped fan-out.** Log proof:
   `appsrc=video_src codec=Opus expected=[H264, Vp8, Vp9]`. The forwarder's codec filter contains the
   damage; the real fix belongs in `todd-sfu/src/router.rs` (scope fan-out by media type).
3. **Cricket Manager `Null check operator used on a null value`** — fires when navigating **back to
   the dashboard**, reproduced in two browsers.
   `lib/features/cricket/presentation/pages/manager/live_video_page.dart` mixes null styles (~L171
   `_health?['rtmp_url']` vs ~L174 `_health!['rtmp_url']`) — a smell, not a proven cause; find the
   throw site.
4. **Dead realtime path `stream.updated`** — Flutter still subscribes
   (`cricket_repository.dart` L542–L553, `stream_player_bloc.dart` L110) but the Laravel event
   `CricketStreamUpdated` was deleted in the camera-registry removal, so "manager switches camera →
   viewers follow" is **inert** (initial playback unaffected).
5. **Non-streaming items recorded in the deleted docs (do not lose these):** `super_admin.php` has
   19 routes behind `auth:sanctum` only (see Appendix A §4 / `MASTER-TASK-LIST.md` §7b.4); 37
   composer advisories across 11 packages, untriaged; stale references to the deleted camera registry
   in `.nginx/srs-cricket.conf` L135–141, `.scripts/CDN-CONFIG.md`, `assets/cricket/*.md`; Todd
   Studio repeats a 409 for a ghost camera with no publisher; `forwarder_error` is fetched but not
   always rendered in the manager panel; `stream_player_bloc.dart` shows a generic "offline" for any
   404; the stinger `uridecodebin` caps fix was never functionally verified; `ForwardKind::WebRtcViewer`
   is deliberately not implemented.

### §6 (Qoder brief) — the requested WHEP work (sub-second public screen)

The brief asked for a **confirmation/refutation** of the §6 stall and a **WHEP** public path. Server
side is **already implemented** (`media-engine/crates/todd-signaling/src/routes/whep.rs`):
`POST /api/v1/whep/watch/{room_id}/{camera_id}` (viewer, room-scoped → `201` + answer),
`DELETE /api/v1/whep/session/{session_id}`, `POST /api/v1/whep/program/{room_id}`. A working browser
reference is in-repo (`media-engine/ui/todd-studio-gui/src/lib/webrtc/whep.ts`,
`src/hooks/useWhepPlayer.ts`, `src/components/MultiviewTile.tsx`). **The build:** ① backend — add
`whep_url` (+ optionally a short-lived viewer token) beside `hls_url` in
`PublicMatchController::streamUrl()`; ② nginx — proxy WHEP signaling same-origin on the public host
(copy `.nginx/todd-studio.conf`); ③ Flutter web player — mirror the vendored-JS pattern of
`hls_video_player_web.dart` but bind `srcObject` to an `RTCPeerConnection`, port the retryable-vs-
permanent error handling, the 10 s black-frame watchdog restart and the `videoWidth > 0` render
check; ④ prefer WHEP, fall back to HLS; ⑤ only ever watch the **on-air** camera
(`CricketStreamSyncService::broadcasterCamera()`), never a ghost. **Constraints:** each WHEP viewer is
a peer on the SFU (CPU + egress, **no CDN**) → plan *hybrid* and measure; Cloudflare cannot proxy
WebRTC media (ICE must reach a publicly routable SFU/TURN address, not a private IP); sub-second
depends on frequent keyframes; this is **not** the same as `ForwardKind::WebRtcViewer` (deliberately
unimplemented and not needed). **Verification must not depend on the operator:** a synthetic WHIP
publisher through the real forwarder path + a scripted WHEP client asserting a decoded frame, then
kill the publisher and assert EOS + the state flips out of `running`.

## §7 Commands worth keeping

**Deploy chain (push to `mainnew`):** a `media-engine/**` change runs *Media Engine — Build & Push
Docker Image* (`check-gst` → `build-and-push`, which has `needs: check-gst`) and its success triggers
*Media Engine — Deploy to VPS* (`workflow_run`). A `lib/**` change runs *Deploy Flutter Web
Frontend* **and** *Deploy to Hetzner*.

**CI parity (must run before pushing engine changes):**
```sh
cargo check -p todd-signaling -p todd-sfu --features gst
cargo test  -p todd-transcode --features gst
```
A green `cargo check --workspace` proves **nothing** about `forwarder.rs`, `mixer_gst.rs`, `audio.rs`
— they are behind `#[cfg(feature = "gst")]`.

**Deploy verify / baselines:**
```sh
docker ps --format "{{.Names}} | {{.Status}} | {{.Image}}"
docker logs --since 10m todd-studio 2>&1 | grep -ac "not-negotiated"   # expect 0
curl -s http://127.0.0.1:1985/api/v1/streams/; echo
ls -la /var/www/traceodd/cricket-hls/live/
```

**Live diagnostics (during a broadcast):**
```sh
docker logs -f --since 2m todd-studio 2>&1 | grep -a --line-buffered -E "forwarder started|forwarder running|not-negotiated|dropping chunk|pipeline error|keyframe"
docker logs --since 5m todd-studio 2>&1 | grep -a -A 12 "pipeline error" | tail -60   # includes the built pipeline
```

**Acceptance:**
```sh
curl -s -o /dev/null -w "%{http_code}\n" "https://cricket.traceodd.com/hls/live/cricket_match_<MATCH_ID>_cam1.m3u8"   # 200
curl -s http://127.0.0.1:1985/api/v1/streams/ | grep -a "cricket_match_"                                              # stream listed
```

**Recovery — the public page 404s while SRS is empty:**
```sh
docker logs --since 5m todd-studio 2>&1 | grep -aE "forwarder started|forwarder running|forwarder failed|pipeline error"
curl -s http://127.0.0.1:1985/api/v1/streams/ | head -c 300; echo
ls -la /var/www/traceodd/cricket-hls/live/
tail -20 /var/www/traceodd/admin-panel/storage/logs/laravel.log
docker restart todd-studio
cd /var/www/traceodd/admin-panel && php artisan cricket:stream-watchdog
ls -la /etc/cron.d/; grep -rn "schedule:run" /etc/cron.d/ /etc/crontab 2>/dev/null
```
The engine's forwarder state is **in memory only**; a container restart clears it, then
`cricket:stream-watchdog` (or the panel's "Reconnect live video", now working) can create a fresh
forwarder. A publisher must be **on air** — `resyncMatch()` returns silently when the engine reports
no live broadcaster camera.

### §7 Windows: building the `gst` feature

The devel MSI alone is **not** enough.
1. Download `gstreamer-1.0-devel-msvc-x86_64-1.24.13.msi` (~712 MB) from
   `gstreamer.freedesktop.org/data/pkg/windows/1.24.13/msvc/`. Use `curl -sL` **without** `-C -`,
   else the MSI is truncated (error 1620).
2. Extract without admin rights: `msiexec /a gs-devel.msi /qn TARGETDIR=C:\gs-dev\extract`
3. Build with:
   ```sh
   env PKG_CONFIG_PATH="C:/gs-dev/extract/gstreamer/1.0/msvc_x86_64/lib/pkgconfig;C:/gs-dev/extract/gstreamer/1.0/msvc_x86_64/lib/gstreamer-1.0/pkgconfig" \
       PATH="/c/Users/<you>/.cargo/bin:/c/gs-dev/extract/gstreamer/1.0/msvc_x86_64/bin:/c/msys64/mingw64/bin:/usr/bin" \
       cargo check -p todd-signaling -p todd-sfu --features gst
   ```
4. **The devel MSI ships zero DLLs** (`bin/` holds only `.pdb` symbols). To **run** anything (tests,
   `gst-launch`), also install/extract the separate **runtime** MSI and put its `bin` on `PATH`.

## §8 Lessons

Compile before pushing (`4b4f1127` was written with no GStreamer and broke CI with 5 errors); a green
`cargo check --workspace` says nothing about `#[cfg(feature = "gst")]`, and the gst-gated tests had
**never executed anywhere** until `media-engine-build.yml` added
`cargo test -p todd-transcode --features gst`; **a deployed fix is not a finished fix**
(`f0fc72e5` was correct, tested and deployed yet the outage continued because a second fault sat on
the same path); **do not trust a string-level test for a negotiation bug**; watch the bus and report
status from the **far end** (bytes reaching SRS), not "the pipeline object was constructed"; ask for
the fact instead of inferring.

---

## Provenance of this file (2026-09-29)

Consolidated from `START-HERE.md`, `PHASE-0A-CREDENTIAL-REMEDIATION.md`,
`STREAMING-HISTORY-AND-FIX.md` and `QODER-CRICKET-STREAM-BRIEF.md`. Those four are now this file plus
`MASTER-TASK-LIST.md`; the originals remain in git history. Original section numbers were preserved
so every existing citation still resolves.
