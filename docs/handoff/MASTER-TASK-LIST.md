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
> 5. **Only essential commands in the IDE** (owner, 2026-09-29). Heavy commands — `flutter build`,
>    release builds, full-tree `dart analyze` — take 15–25 minutes on a dev box, time out, and waste the
>    whole turn. CI already does exactly those on every push (`frontend-deploy.yml`, `tests.yml`) and
>    reports red/green within ~10 minutes. So: **edit + push, read the CI result**; run locally only what
>    is fast (`php -l`, `phpunit` on sqlite, `dart analyze` on the ONE feature you touched).

---

## The queue, in order

| # | Task | Status |
|---|---|---|
| 1 | Factory's own registered name in the panel header (+ cold start) | ✅ `59df9beb` |
| 2 | Remove the Factory dashboard's hardcoded demo figures + demo product rows | ✅ `39bb81c6`, `606fdef6` |
| 3 | Shared `StickyErrorBanner` widget (stay + Copy + X) | ✅ `a9c0ecec` |
| 4 | Errors **stay + Copy** — Drivers screen (first screen) | ✅ `a180f573` |
| 5 | Errors **stay + Copy** — remaining **Factory panel** screens: Products, Store Keepers, Unit/Packet/Carton/Bundle codes, Add/Edit dialogs, dashboard | ✅ **done** — **15 screens** use `StickyErrorBanner` (sticky + Copy + X): Products list · Store Keepers list · Unit/Packet/Carton codes lists · Carton/Packet codes overview · Bundle codes list · Bundle insights · Bundle packing · Bundle list · Orders hub · Create/Edit Product · Create Store Keeper · Create Driver · Carton/Packet/Bundle code **generate**. **No error path existed on the Factory dashboard** (its only `_showSnackbar` calls are placeholders for unwired buttons), so there was nothing to convert there. **Not part of #5:** the drivers list still uses the #4 stopgap SnackBar — upgrading it to the banner is recorded under MUSTAQBIL M7 |
| 6 | Errors **stay + Copy** — **Sub-Admin** panel screens | ⏳ **START HERE** |
| 7 | Errors **stay + Copy** — **Super Admin** screens | ⏳ |
| 8 | Errors **stay + Copy** — other apps (reseller, shop keeper, cricket) | ⏳ |
| 9 | **Marketplace upload flow**: product → `marketplace_product_listings`, and the company's **storefront is created on first upload** | ✅ **done** — `MarketplaceListingService` + wired into `ProductController` `store` / `update` / `marketplace-toggle`; deploy re-syncs flagged products |
| 10 | Publish the **6 existing factory products** (Maxi Electronic 2, Moon Medi 4) onto the marketplace | ✅ **done live 2026-09-28** — `php artisan marketplace:publish-products --all` published 6 listings (Zanni 500mg, Bonbo 300 mg, Mixer 500 watt, GUDO MIXER, Dero Dan 50 mg, testy 50) |
| 11 | A **Marketplace section** on each of the three panel dashboards: preview the full marketplace, upload a product, view orders, order history | ✅ **done** — Factory panel section (`/factory/marketplace`: Preview · My Listings · Orders) + one shared **read-only** oversight screen for the Sub-Admin (`commercial_marketplace`, `/sub-admin/marketplace`) and the Super Admin (`/marketplace`). Backend: `admin/marketplace/orders` + `summary` |
| 12 | **Public read-only marketplace site** — **no login page**; browse everything with wholesale price + MOQ (Alibaba-style) | ⏳ **START HERE** — app + nginx + deploy wiring built (`lib/main_marketplace.dart` → `market.traceodd.com`). **Owner action: add the Cloudflare DNS record** (see §#12 below) |
| 13 | **Buy → cart + "register your factory / reseller / shop"** — the account is the buying door, the marketplace is not | ⏳ **START HERE** — **cart + the buying door are built** on market.traceodd.com (add to cart, MOQ-aware cart page, register page for the three account types). **Not yet: the order itself** — see §#13 below |
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

### #13 — cart + the buying door (on `market.traceodd.com`)

Built:

| Piece | Path |
|---|---|
| Cart (persisted on the device) | `lib/features/marketplace_public/data/marketplace_cart.dart` — `MpCart`, JSON in `shared_preferences` |
| Cart page | `.../presentation/pages/marketplace_cart_page.dart` — MOQ-aware quantity stepper, remove, per-currency subtotals |
| Buying door | `.../presentation/pages/marketplace_register_page.dart` — explains the three account types (Factory · Reseller/Wholesaler · Shop Keeper) and opens the registration |
| Add to cart | the round button on every product card, plus "Add to cart" in the detail sheet |
| Header | cart icon with a live item-count badge |

Routes: `/cart`, `/register`.

**Still open (the honest gap):** the cart does not yet *place* an order. Creating one needs an
authenticated business, and the endpoints that exist today are `POST /reseller/orders` (a reseller
account) — there is **no shop-keeper account type in the backend at all** (`GROUP-INCHARGE-MODEL.md`
§2b.8: *"Shop Keeper has no creation path anywhere"*). So the next step for #13 is a decision, not
only code: either (a) the cart hands the visitor to the reseller app to finish the order, or
(b) a buying session is introduced so a visitor can submit an order request that a factory confirms.

---

## Phase K — KISAN (Agri-Marketplace) & Advance Demand Forecasting  [NEW — owner, 2026-09-29]

**Module registry entry:** `NEXATRACE_SUPREME_MASTER_SPEC.md` **MODULE 18**.

### K.0 — Where it sits in the sequence (dependency, not preference)

It goes **after the groups' essential work**, because every one of its five parts reuses something that
is not finished yet:

```
#5–#8   error banners everywhere            ── independent, quick wins
#14     orders/sell/buy per panel            ─┐
#15     B2B login + old tested screen         │  the marketplace must be usable
#16     Reseller verify + attach login        │  by a real buyer before a farmer
#17     Shop Keeper login + dashboard        ─┘  lists into it
#21     C3b read-only registries              ─┐
#22     verify/remove AdminCompanyController@store │ money & authority settled
#24     §17.9 auth domains steps 2–6          │  before escrow is added
#25–#28 service worker · analytics 500 · IP bugs · log flood ─┘
        ↓
PHASE K  K1 → K2 → K3 → K4 → K5 → K6
```

| # | Task | Reuses (already exists) | Depends on |
|---|---|---|---|
| **K1** | **B2B Kisan onboarding + Agri-Producer Dashboard on `market.traceodd.com`** — registration, document/profile verification, Admin/Verification-Manager approval, and a streamlined producer dashboard (post a crop lot, see bids, accept, track pickup, view contracts). Adds auth role **`kisan_producer`** (`poster_type = 'kisan'`) wired to the market B2B auth gateway. **NOT in the Universal Customer app** | market B2B auth gateway; the Reseller/Shopkeeper role-dashboard pattern; `companies` / users role columns | #15/#16 (a B2B role already provisioned next to them) |
| **K1b** | **Kisan Verification Manager panel** — the B2B Sub-Admin creates **as many managers as it wants**, each over a **district or open area**, with a scoped producer-approval queue (pending → documents → approve / reject / suspend). Producers only: marketplace content, disputes and reseller/shop-keeper accounts stay with the Sub-Admin | the existing delegated sub-role mechanism (`sub_admin_assignments` + feature grants) and the district vocabulary already used by smart codes | K1 |
| **K2** | **Crop listing + direct bidding** (place / list / accept a bid) | `FreightAuctionController` (`loads`, `loads/{id}/bids`, `loads/{id}/match`) + `freight_loads` / `freight_bids` — a kisan is a **`poster_type`**, not a new schema | K1 |
| **K3** | **Automatic logistics hand-off**: on accept, offer the load to nearby trucks | `BiddingMeshController` (`submit-bid`, `accept-bid`) + Goods/Truck fleet map; `TruckCategory.shahzoreLoader` is already documented as *kisaan-to-mandi produce* | K2 |
| **K4** | **Batch QR** on loading, verified like any NexaTrace product | `base_codes` + production vault + consumer verify (`/marketplace/consumer/verify`) | K3 |
| **K5** | **Forward demand** on market.traceodd.com: factory publishes *"500 t cotton in 3 months at X"*; kisan accepts before sowing | market site (#12, done) + a `kisan_demands` table | K1 |
| **K6** | **Advance token / escrow** behind the forward contract | the **existing idempotent split engine** (`PANEL-SEPARATION-PLAN.md` §10.5) — **no second ledger** | K5, #21/#22 (authority + money settled) |

### K.1 — Entry flow & the boundary rule (CORRECTED — owner, 2026-09-29)

**Superseded:** an earlier agent suggestion put Kisan inside the **Universal Customer App**. That was wrong -
it is an architectural/policy violation and is recorded here so it is not repeated.

**The rule:**

| Who | Is | Enters through |
|---|---|---|
| Universal Customer App | **B2C** — the general public | consumer features only (bus ticketing, freight tracking, product QR verify, IoT) |
| `market.traceodd.com` | **B2B only** — verified Factories, Wholesalers, Resellers, Shopkeepers | the market B2B auth gateway, per role |
| **Kisan** | a **Produce Producer / Supplier — a B2B SELLER** supplying raw material to factories. **Not a consumer** | **`market.traceodd.com`**, under a Vendor/Producer role (`kisan_producer`), approved by the Admin / Verification Manager, with its own **Agri-Producer Dashboard** |

**Where the Universal app comes in:** *logistics only*. When either side needs a truck, the existing
Goods & Logistics / Driver flow handles pickup, trip execution, live Google Maps tracking and QR batch scanning.

**Boundary check to run after every Phase K change:** the B2C Universal app carries **no** B2B marketplace
trading code, and **no** Kisan account type. Sign-up, verification, listing, bidding and contracts all live on
the B2B side. (The reverse is also true: the market site does not grow consumer features.)

**Why the producer queue needs its own layer (owner, 2026-09-29):** one `commercial_marketplace` Sub-Admin
cannot personally approve **shopkeepers + resellers + kisan** — the third queue turns the approval desk into the
bottleneck. So the Sub-Admin appoints **Kisan Verification Managers** (unlimited, one per district or open
area) to run the producer queue, and keeps everything else (content, disputes, reseller/shop accounts) itself.
That is **K1b**, and it is the precursor to the Marketing hierarchy (District → Manager → Agent).

**Why not a separate Kisan app, and not a Sub-Admin vertical:** the owner's Sub-Admin rule is *"no personal
products, only platform oversight"* — a Kisan vertical would need a provisioning/verification/account
lifecycle nobody has asked to manage. The K1 **producer dashboard** gives the kisan everything he needs
inside the B2B portal, and it sits beside the Reseller/Shopkeeper role dashboards that already exist.

> **Revisit when** a real kisan cohort needs bulk onboarding/verification at scale — then the likely shape is a
> **Marketing-style field hierarchy** (District → Manager → Agent) that onboards producers, not a marketplace
> Sub-Admin vertical and not a separate consumer app.

---

## MUSTAQBIL — deferred to a later round (recorded so nothing is lost)

Owner, 2026-09-29: *"ab itna kaafi — baqi kaam second round me jab tamam groups ke basic aur zaroori kaam
mukammal kar lain."*

| # | Deferred item | Why it waits |
|---|---|---|
| **M1** | **#13 remainder — the cart does not place an order.** Choices: (a) hand the visitor to the reseller app to finish, or (b) introduce a *buying session* where a visitor submits an order request the factory confirms | Needs a decision **and** a business identity to be meaningful. The cart + buying door are already live (#13, built). |
| **M2** | **Shop Keeper has no account type in the backend at all** — `POST /reseller/orders` is the only order endpoint | The "register your shop" card is honest about it; building it is Group-2 feature work |
| **M3** | **`most sold` ordering.** The storefront sorts by *most viewed* (real `view_count + inquiry_count`). True best-selling needs an aggregate over `reseller_orders.items` | Kept honest rather than faked — the sort dropdown says "Most viewed" |
| **M4** | **Blocker B — the five panels share ONE bundle** (`main.dart` serves Super Admin · Sub-Admin · Customer · Factory Admin · Store Keeper) | Real isolation is `PANEL-SEPARATION-PLAN.md` **Phase 1** (§17.9 steps 2–6 are already queued as #24). Until then a subdomain changes the URL, not the coupling — `subadmin.traceodd.com` redirects to `/sub-admin/login` but `/dashboard` on that host still reaches the Super Admin dashboard |
| **M5** | Storefront **category chips** are captured from the first unfiltered page, so a category that only appears on page 3 is not offered as a chip | Filtering itself is server-side now; a `/reseller/categories` endpoint would make the chip list complete |
| **M6** | #18 factory logo upload · #19 three reseller types · #20 middle-man agent · #23 marketing (Group 9) | Already parked in the queue above by the owner |
| **M7** | **Drivers list** still uses the #4 stopgap (a day-long SnackBar with a Copy action) instead of `StickyErrorBanner`. It already stays and copies, so it is cosmetic next to the 15 converted screens — but it should be moved to the banner for one consistent behaviour | Cosmetic; #5's own screen list did not include it (drivers was #4) |
| **M8** | **Dead placeholder buttons on the Factory dashboard** — `_showSnackbar('Navigate to products management')`, `'Generate Codes'`, `'View Reports'`, `'Settings'`, `'Add new product'`, `'upgrade screen'`, `'Driver contact flow not wired yet'`, `'Load posting flow not wired yet'`. They look wired but do nothing (the same class of defect as #32/A3) | Outside #5 (behaviour, not error display); the real destinations already exist as routes |

### Items that were wrong and are fixed (kept so nobody "re-fixes" them)

| # | What happened | Fixed by |
|---|---|---|
| 29 | **Cross-group data assignment.** *We* handed **every** unowned company to the Factory incharge, so a bus-fleet company and a goods company appeared in the Factory Sub-Admin panel. Corrected to assign by the row's own type (`company_type` / `company_type_tag`), with NULL = platform-owned when a group has no incharge yet | `a1457b09` → corrected by `7d0eb639` |
| 30 | **JSON-path scoping.** The Factory Sub-Admin's list filtered on `metadata->>created_by_sub_admin_id`; that predicate returns the row in `psql` but returned **nothing** through Eloquent, so the API answered `200` with an empty list and the UI hid the failure. Replaced with a real indexed column (the pattern `SubAdminResellerController` already used) | `facc964f` |
| 31 | **Mixed content.** `ApiEndpoints.baseUrl`, `AppConstants.baseUrl` and `PanelRouteConfig.baseUrl` were compile-time constants holding an **HTTP IP**, so on an HTTPS host every admin call was blocked — the lists merely looked empty | `a93dbb1f` |
| 32 | **Dead sidebar entries.** In `AdminSidebar`, any item **with children** was built with a literal `onTap: () {}`, so Products / Store Keepers / Drivers / all Codes were permanently dead — and its children only rendered when one of them was already the route. Now the parent navigates to its own route | `deb1d661` |
| 33 | **Missing `drivers` table.** `2026_06_03_000700_drop_legacy_drivers_table` dropped it in the Wave-1 cutover, but `Factory\DriverController` still uses it → 500 on list and create. The breakage was invisible because the sidebar entry was dead (#32). Table restored with the union of its original definition and every later addition (`email` nullable) | `328490ee` |
| 34 | **Factory name never reached the header.** The login writes the cache from **two** places; the bloc runs first (without `companyName`) and the login screen's listener is guarded by "if not already authenticated", so it was skipped | `59df9beb` |
| 35 | **Four Sub-Admin actions 404'd silently.** The Super Admin's Sub-Admin menu called endpoints that do not exist: `POST /toggle-status` (real route is `PATCH /{id}/status`), `POST /change-vertical` and `POST /reset-password` (both are `PUT /{id}` with one key), and `POST /restore` (real route is `PATCH`). The buttons looked wired and did nothing. Fixed in the Flutter bloc; **plus** the full edit form (name, email, phone, vertical, password) and `phone` support in `SubAdminController@update` (it was validated then ignored), with the phone claim added to `index()` so the form prefills | this commit |
| 36 | **`market.traceodd.com` rendered BLANK (live).** The marketplace deploy step copied a hand-written `web/index-marketplace.html` OVER the BUILT `build/web/index.html` to add a zoomable viewport. That template carried Flutter's build-time placeholder `<base href="$FLUTTER_BASE_HREF">`; Flutter had already resolved it in the built file, so the copy put the **literal placeholder** back and the loader refused the page: *"The base href has to end with a \"/\" to work correctly"*. Fix: never overwrite the built file — `web/index-marketplace.html` is **deleted** and `.scripts/patch-marketplace-head.py` **patches** the built `index.html` in place (viewport + title + description + theme colour) and never touches `<base href>`. The deploy step now **fails loudly** if the literal placeholder is present or the base href does not end with `/`, and warns if the viewport patch did not apply | this commit |
| 37 | **"The error shows but it does not copy"** (owner, on `/factory/orders`, where the visible failure was an uncaught `type error … SR is not a subtype of type 'string'`). Two separate causes, both fixed: (a) **an uncaught error never reached the banner at all** — it went to Flutter's own error widget, which has no copy affordance. Now `installCopyableErrorSurface()` (called from `main.dart` and `main_marketplace.dart`) overrides `ErrorWidget.builder` so ANY uncaught error renders as a sticky panel with the message + stack + **Copy**, and stores the details via `FlutterError.onError` / `PlatformDispatcher.onError`. (b) **`Clipboard.setData` fails silently over plain `http://`** — the browser Clipboard API only exists in a SECURE context, so on `http://135.181.46.27` the Copy button did nothing and said nothing. Both the banner and the new panel now catch that and fall back to a **manual-copy dialog** with the text selectable. The `type error` itself is left alone on purpose (`MASTER-TASK-LIST` #1) — only the copy path was fixed | this commit |

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
3. Start at the **first ⏳ item in the queue above** — for now that is **#6, the Sub-Admin panel's error
   surfaces**. #9–#13, the Sub-Admin edit form and #5 are done.
4. Keep the two habits: state which item number you are doing, and record the commit hash in the table when
   it lands.
