# MASTER TASK LIST — the running queue

**Purpose:** one place that survives a chat limit. A **fresh session** reads `START-HERE.md` first, then
this file, and **continues from the first item that is not ✅** — nothing gets re-done and nothing gets
skipped.

**Last updated:** 2026-09-28 (marketplace upload flow — item #9 done).
**Read with:** `START-HERE.md` (read order / live status), `GROUP-INCHARGE-MODEL.md` §2b (the design and
the C-phase record), `PANEL-SEPARATION-PLAN.md` §17 (auth globals).

> **Ground rules earned the hard way in this session — follow them:**
> 1. **Evidence before edits.** `git log -S "<string>"` and a live `psql` query settle "is this pre-existing
>    or did we break it?" in one minute. Guessing cost real time (a JSON-path filter that passed `psql` but
>    returned nothing through Eloquent; a blanket data migration that cross-assigned companies between groups).
> 2. **Restore, don't rebuild.** The owner's rule for this phase: bring back what was already tested; no new
>    features.
> 3. **Never blind-fix.** If the cause is not proven, ask for the one command or file that proves it.
> 4. **Own it.** When the breakage is ours, say so plainly and fix it (see #29, #30 below).

---

## The queue, in order

| # | Task | Status |
|---|---|---|
| 1 | Factory's own registered name in the panel header (+ cold start) | ✅ `59df9beb` |
| 2 | Remove the Factory dashboard's hardcoded demo figures + demo product rows | ✅ `39bb81c6`, `606fdef6` |
| 3 | Shared `StickyErrorBanner` widget (stay + Copy + X) | ✅ `a9c0ecec` |
| 4 | Errors **stay + Copy** — Drivers screen (first screen) | ✅ `a180f573` |
| 5 | Errors **stay + Copy** — remaining **Factory panel** screens: Products, Store Keepers, Unit/Packet/Carton/Bundle codes, Add/Edit dialogs, dashboard | ⏳ |
| 6 | Errors **stay + Copy** — **Sub-Admin** panel screens | ⏳ |
| 7 | Errors **stay + Copy** — **Super Admin** screens | ⏳ |
| 8 | Errors **stay + Copy** — other apps (reseller, shop keeper, cricket) | ⏳ |
| 9 | **Marketplace upload flow**: product → `marketplace_product_listings`, and the company's **storefront is created on first upload** | ✅ **done** — `MarketplaceListingService` + wired into `ProductController` `store` / `update` / `marketplace-toggle`; deploy re-syncs flagged products |
| 10 | Publish the **6 existing factory products** (Maxi Electronic 2, Moon Medi 4) onto the marketplace | ✅ **done live 2026-09-28** — `php artisan marketplace:publish-products --all` published 6 listings (Zanni 500mg, Bonbo 300 mg, Mixer 500 watt, GUDO MIXER, Dero Dan 50 mg, testy 50) |
| 11 | A **Marketplace section** on each of the three panel dashboards: preview the full marketplace, upload a product, view orders, order history | ✅ **done** — Factory panel section (`/factory/marketplace`: Preview · My Listings · Orders) + one shared **read-only** oversight screen for the Sub-Admin (`commercial_marketplace`, `/sub-admin/marketplace`) and the Super Admin (`/marketplace`). Backend: `admin/marketplace/orders` + `summary` |
| 12 | **Public read-only marketplace site** — **no login page**; browse everything with wholesale price + MOQ (Alibaba-style) | ⏳ **START HERE** — app + nginx + deploy wiring built (`lib/main_marketplace.dart` → `market.traceodd.com`). **Owner action: add the Cloudflare DNS record** (see §#12 below) |
| 13 | **Buy → cart + "register your factory / reseller / shop"** — the account is the buying door, the marketplace is not | ⏳ |
| 14 | Orders / sell / buy visible in each panel's own marketplace section | ⏳ |
| 15 | **B2B** its own login page + attach the old tested screen | ⏳ |
| 16 | **Reseller** — verify + attach the existing login | ⏳ |
| 17 | **Shop Keeper** — minimal CRUD first (login + dashboard), then marketplace | ⏳ |
| 18 | **Factory logo** in the panel (`companies.logo_url`; decide where the factory uploads it) | ⏳ **parked by the owner** until this panel is worked on properly |
| 19 | **Three reseller types** — wire the fields that **already exist**: `is_msrp_enforced` (true = factory fixed both rates = fixed-rate reseller; false = wholesaler sets its own margin), `factory_buy_price`, `reseller_sell_price`, and `ResellerPortalService::enforceMSRP()` | ⏳ **parked** until all groups are done — see §Key findings below |
| 20 | Type 3 (**middle man**): `agent_code` on the order + `commission_rate` + `payout_frequency` (weekly / 15-day / monthly, agent's choice) + `payment_terms` (advance / on delivery / net-15/30/60 / split). Payment always goes **directly to the factory**; the factory pays the agent a fixed commission; commission must run through the **existing idempotent split engine** — no second ledger | ⏳ parked (with #19) |
| 21 | **C3b** — make the Super Admin's registries genuinely **read-only** (the company detail and reseller list still expose edit/suspend/approve actions) | ⏳ |
| 22 | `AdminCompanyController@store` / `POST /api/v1/admin/companies` — nothing in Flutter calls it now; **verify callers first**, then decide to remove | ⏳ |
| 23 | **Marketing (Group 9 / C1b)** — the four surfaces, commissions, courses, district hierarchy | ⏳ |
| 24 | §17.9 steps 2–6 — the admin + sub-admin auth domains, the router's instance reads, then delete `core/utils/auth_state.dart` | ⏳ |
| 25 | `flutter_service_worker.js` served as `text/html` (nginx falls through to `index.html`) | ⏳ |
| 26 | `GET /api/v1/admin/analytics/dashboard` → **500** (pre-existing `AnalyticsService`; needs the `laravel.log` ERROR line — prime suspect: the pgsql-unsupported `PDO::ATTR_CONNECTION_STATUS` at `AnalyticsService.php:233`) | ⏳ |
| 27 | Two remaining **literal-IP** bugs: `live_bus_tracking_screen.dart:48` and the reseller link copy in `reseller_management_list_screen.dart` | ⏳ |
| 28 | **Log flood** — the CORS logger writes 3 INFO lines per request, which hides real errors and grows the disk | ⏳ |

### #11 design — what each panel's Marketplace section is (owner, 2026-09-28)

| Panel | Its Marketplace section |
|---|---|
| **Factory** | Preview the marketplace; **upload a product** (the existing product create + `marketplace-toggle`); view **its own** orders + order history (`/factory/reseller-orders`) |
| **Sub-Admin** (`commercial_marketplace`) | **Read-only.** It controls the *marketplace platform*: disputes, marketplace content, reseller / shop-keeper account issues (approve, suspend). **No** product upload, **no** factory products of its own |
| **Super Admin** | **Read-only.** Preview the full marketplace + all orders |

Owner's rule: *both the Super Admin and every group's Sub-Admin have no factory and no product of their own*, so neither creates or edits listings — oversight is **read-only by construction**, and its scope is the whole
platform (a role that owns no factories cannot be scoped to "its own" factories; it would see nothing and could
never resolve a dispute).

Backend delivered for it: `MarketplaceAdminController` — `GET /api/v1/admin/marketplace/orders` and
`GET /api/v1/admin/marketplace/summary` (read-only, platform-wide), covered by `MarketplaceAdminOrdersTest`.
Preview already had an API: `GET /api/v1/marketplace/catalog/search` and `/storefronts` (both `auth:sanctum`).

### #12 — the public marketplace site (host: `market.traceodd.com`)

**Subdomain to register in Cloudflare: `market`** → `market.traceodd.com`
Add it exactly like the existing `cricket` / `studio` / `broadcaster` records: a proxied **A** record to
`135.181.46.27` (the same origin those subdomains already use). The origin nginx listens on port 80 like the
other server blocks, so no TLS setting has to change — Cloudflare terminates it, as it does for `cricket`.
*(Alternatives if `market` is taken: `marketplace` or `b2b`.)*

What was built:

| Piece | Path |
|---|---|
| Public app (no login) | `lib/main_marketplace.dart` — routes `/` (browse) and `/store/:factoryId` |
| Feature code | `lib/features/marketplace_public/` — its own brand theme (indigo/coral/teal), repository, home page, storefront page, product card + detail sheet |
| Data | the public read endpoints only: `/reseller/products`, `/reseller/factories`, `requiresAuth: false` — **no token anywhere** |
| nginx | `.nginx/marketplace.conf` — serves `/var/www/traceodd/marketplace-web/`, proxies **only** `/api/v1/reseller/` + `/api/v1/public/`, returns **403** for every other `/api/` path |
| Deploy | `frontend-deploy.yml` STEP H2 (build + rsync) and the nginx step now scp's `marketplace.conf`, links it, and checks the block |
| PWA | `web/manifest-marketplace.json` copied over `manifest.json` on deploy |

Design: a modern storefront, not Alibaba's blue — deep-ink text, indigo→teal hero gradient, coral price
accents, card grid (responsive 1/2/3/4 columns), category chips, MOQ pills, verified-factory badges,
and a factory storefront page. Buying is deliberately absent: the CTA hands the visitor to the account
door (item #13).

### Items that were wrong and are fixed (kept so nobody "re-fixes" them)

| # | What happened | Fixed by |
|---|---|---|
| 29 | **Cross-group data assignment.** *We* handed **every** unowned company to the Factory incharge, so a bus-fleet company and a goods company appeared in the Factory Sub-Admin panel. Corrected to assign by the row's own type (`company_type` / `company_type_tag`), with NULL = platform-owned when a group has no incharge yet | `a1457b09` → corrected by `7d0eb639` |
| 30 | **JSON-path scoping.** The Factory Sub-Admin's list filtered on `metadata->>created_by_sub_admin_id`; that predicate returns the row in `psql` but returned **nothing** through Eloquent, so the API answered `200` with an empty list and the UI hid the failure. Replaced with a real indexed column (the pattern `SubAdminResellerController` already used) | `facc964f` |
| 31 | **Mixed content.** `ApiEndpoints.baseUrl`, `AppConstants.baseUrl` and `PanelRouteConfig.baseUrl` were compile-time constants holding an **HTTP IP**, so on an HTTPS host every admin call was blocked — the lists merely looked empty | `a93dbb1f` |
| 32 | **Dead sidebar entries.** In `AdminSidebar`, any item **with children** was built with a literal `onTap: () {}`, so Products / Store Keepers / Drivers / all Codes were permanently dead — and its children only rendered when one of them was already the route. Now the parent navigates to its own route | `deb1d661` |
| 33 | **Missing `drivers` table.** `2026_06_03_000700_drop_legacy_drivers_table` dropped it in the Wave-1 cutover, but `Factory\DriverController` still uses it → 500 on list and create. The breakage was invisible because the sidebar entry was dead (#32). Table restored with the union of its original definition and every later addition (`email` nullable) | `328490ee` |
| 34 | **Factory name never reached the header.** The login writes the cache from **two** places; the bloc runs first (without `companyName`) and the login screen's listener is guarded by "if not already authenticated", so it was skipped | `59df9beb` |

---

## Key findings to carry forward

1. **The marketplace is now populated.** Live counts before #9: `marketplace_product_listings = 0`,
   `marketplace_storefronts = 0`, `products = 6` (Maxi Electronic 2 + Moon Medi 4 — the old factory
   accounts). Nothing was "lost": the **publish step never wrote a listing**.
   **✅ Fixed by #9:** `MarketplaceListingService` creates the storefront on the first upload and writes the
   `marketplace_product_listings` row; the controller's create/update/toggle all sync it, and the deploy
   re-syncs products already flagged `marketplace_enabled`. **✅ #10 done live 2026-09-28** —
   `php artisan marketplace:publish-products --all` published all 6 (one storefront per company).
   ⚠️ Storefronts are created `verification_status = 'verified'` on purpose, because the catalog and the
   search service only show verified storefronts.
2. **The three-types model is already half-built in the schema** (`is_msrp_enforced`, `factory_buy_price`,
   `reseller_sell_price`, plus `is_homemade`, `is_brand_verified`, `reseller_otp_locked`, a `factory matrix`
   type system and `ResellerPortalService::enforceMSRP()`). #19/#20 are **wiring**, not invention.
3. **The sub-admin panel is the same bundle as the Super Admin** (`main.dart` serves five panels). That is
   `PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md` Blocker B: giving it a subdomain changes the URL, not the coupling.
   The sub-admin has **no** separate subdomain — that is why it never had a Cloudflare record.
4. **The factory panel's `factory_dashboard.dart` is at its first-commit state** (`git log -S "45,000"` →
   `82f3ef9a`, only two commits in its whole history: the initial commit and one import rename). Its demo
   data and dead entries were **pre-existing**, not caused by the separation work.
5. **The Sub-Admin's scoping key is a real column** — `companies.created_by_sub_admin_id` and
   `resellers.created_by_sub_admin_id` (migrations `2026_09_27_000002`, `2026_09_27_000001`). Do not go back
   to a JSON path.

---

## How to run a fresh session

1. Read `START-HERE.md` (its read order).
2. Read this file.
3. Start at the **first ⏳ item in the queue above** — for now that is **#12, the public read-only marketplace
   site**. #9 (upload flow), #10 (the 6 existing products) and #11 (the three panel sections) are done.
4. Keep the two habits: state which item number you are doing, and record the commit hash in the table when
   it lands.
