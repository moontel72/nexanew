# Panel → Subdomain Linking & LOCK Playbook

**Purpose:** give every app/panel its own subdomain and **LOCK** it, one at a time, in registry order —
the method in `PANEL-SEPARATION-PLAN.md` §8 (*separate → fix login/dashboard → own subdomain → LOCK*).

**Owner's flow per panel:** create the subdomain → register it in Cloudflare → change that panel's
login password → **prove login works with the new password** → move to the next number. Panels already
done are skipped.

**Status of the source material:** drafted 2026-09-25 from the real nginx configs in `.nginx/`, the
real build/deploy steps in `.github/workflows/frontend-deploy.yml`, and the actual `lib/main_*.dart`
entry points. Nothing here is assumed.

---

## 1. What already exists (verified)

`traceodd.conf` has **three** server blocks today:

| Host | Serves |
|---|---|
`traceodd.com` + `www` | Landing page (`/var/www/traceodd/landing/`) ✅ **done** |
`admin.traceodd.com` | Admin PWA at `/`, plus **sub-path** apps: `/reseller/`, `/bus-fleet/`, `/bus-owner/`, `/bus-driver/`, `/bus-conductor/`, `/truck-owner/`, `/truck-driver/`, `/truck-conductor/`, `/driver/` |
`localhost` + raw IP (`default_server`) | Same as the admin host — dev access |

Plus two dedicated confs that are the **model to copy** — `cricket-manager.conf` and
`cricket-public.conf` — because they lock each panel's API to its own prefix and `403` everything else.

**So most panels are currently sub-*paths* of `admin.traceodd.com`, not subdomains.** The job is to
convert them into dedicated subdomains, one at a time.

### The build pipeline today

`frontend-deploy.yml` builds **8 of the 13** `lib/main_*.dart` targets and rsyncs each to its own
directory:

| Step | Entry point | base-href | Server directory |
|---|---|---|---|
A | *(default `lib/main.dart`)* | `/` | `/var/www/traceodd/frontend/` |
B | `main_landing.dart` | `/` | `/var/www/traceodd/landing/` |
C | `main_cricket_public.dart` | `/` | `/var/www/traceodd/cricket-public-web/` |
D | `main_cricket_manager.dart` | `/` | `/var/www/traceodd/cricket-manager-web/` |
E | `main_reseller.dart` | `/reseller/` | `/var/www/traceodd/reseller/` |
F | `main_driver.dart` | `/driver/` | `/var/www/traceodd/driver/` |
G | `main_bus_owner.dart` | `/bus-owner/` | `/var/www/traceodd/bus-owner/` |
H | `main_bus_fleet.dart` | `/bus-fleet/` | `/var/www/traceodd/bus-fleet/` |

---

## 2. ⚠️ Two blockers before this can be done for every panel

### Blocker A — five panels have **no build at all**

`traceodd.conf` points nginx at `/bus-driver/`, `/bus-conductor/`, `/truck-owner/`, `/truck-driver/`
and `/truck-conductor/`, **but `frontend-deploy.yml` never builds those five targets.** Those
directories are empty, so those paths 404 today. They are the 5 unbuilt of 13.

**They cannot be linked to a subdomain until a build step exists for each.** This is a small CI
addition, but it is a blocker for #12, #13, #17, #18, #19.

### Blocker B — 🔴 the `main.dart` mega-entry cannot be *locked* by a subdomain

Five surfaces live inside **one bundle** (`lib/main.dart`, deploy Step A → `frontend/`):

```
Super Admin (#1) · Sub-Admin (#2) · Universal Customer (#3) · Factory Admin (#7) · Factory Store Keeper (#8)
```

That bundle boots **Super Admin + Factory Admin + Factory Driver + Store Keeper + B2B state at startup
regardless of which panel the visitor asked for**, and it carries **mutable auth globals**
(`isAuthenticatedCache`, `isFactoryAuthenticatedCache`) that the router reads — which is the verified
cause of the "Factory Admin and Sub-Admin open the same thing" bug (`PANEL-SEPARATION-PLAN.md` §7c).

**Putting that bundle on `admin.traceodd.com` does not isolate anything** — one build still serves
five panels, and one login still sets state another panel reads. Moving a sub-path to a subdomain
changes the URL, not the coupling.

**So for #1, #2, #3, #7 and #8 the order must be:**
1. `PANEL-SEPARATION-PLAN.md` **Phase 1** (layering, behaviour-preserving) — §5b.2 items 5–8:
   split `app_providers.dart`, replace the global auth globals, make `main.dart` a thin Super-Admin-only
   launcher.
2. **Then** give each of the five its own entry point, build step and subdomain.

Doing #1 first as planned will **re-produce the mixing bug** the whole exercise exists to remove.

---

## 3. The registry, with subdomains and readiness

Proposed subdomain names — **owner to confirm/adjust**. "Ready now" = an isolated entry point already
exists, so the subdomain step is pure plumbing.

| # | Surface | Proposed subdomain | Entry point | Built? | Ready now? |
|---|---|---|---|---|---|
| 1 | Super Admin | `admin.traceodd.com` *(exists)* | `main.dart` ⚠️ | ✅ A | 🔴 **Blocker B** |
| 2 | Sub-Admin | *(same host, path)* | `main.dart` ⚠️ | ✅ A | 🔴 **Blocker B** |
| 3 | Universal Customer | `app.traceodd.com` | `main.dart` ⚠️ | ✅ A | 🔴 **Blocker B** + duplicate copy |
| 4 | B2B Marketplace | `market.traceodd.com` | *(inside admin host)* | ✅ A | 🔴 **Blocker B** |
| 5 | Reseller | `reseller.traceodd.com` | `main_reseller.dart` | ✅ E | ✅ **yes** |
| 6 | Shop Keeper | `shop.traceodd.com` | — | ❌ | ⬜ not built |
| 7 | Factory Admin | `factory.traceodd.com` | `main.dart` ⚠️ | ✅ A | 🔴 **Blocker B** |
| 8 | Factory Store Keeper | *(path on factory host)* | `main.dart` ⚠️ | ✅ A | 🔴 **Blocker B** |
| 9 | Factory Driver | `driver.traceodd.com` | `main_driver.dart` | ✅ F | ✅ **yes** |
| 10 | Bus Fleet Admin | `bus-fleet.traceodd.com` | `main_bus_fleet.dart` | ✅ H | ✅ yes (see note) |
| 11 | Bus Owner | `bus-owner.traceodd.com` | `main_bus_owner.dart` | ✅ G | ✅ yes (see note) |
| 12 | Bus Driver | `bus-driver.traceodd.com` | `main_bus_driver.dart` | ❌ | 🚧 **Blocker A** |
| 13 | Bus Conductor | `bus-conductor.traceodd.com` | `main_bus_conductor.dart` | ❌ | 🚧 **Blocker A** |
| 14 | Bus Store Keeper | `bus-store.traceodd.com` | via `main_bus_fleet.dart` | ✅ H | ✅ yes (see note) |
| 15 | Goods Company Admin | `goods.traceodd.com` | — | ❌ | ⬜ not built |
| 16 | Goods Store Keeper | `goods-store.traceodd.com` | — | ❌ | ⬜ not built |
| 17 | Truck Owner | `truck-owner.traceodd.com` | `main_truck_owner.dart` | ❌ | 🚧 **Blocker A** |
| 18 | Truck Driver | `truck-driver.traceodd.com` | `main_truck_driver.dart` | ❌ | 🚧 **Blocker A** + imports BUS pages |
| 19 | Truck Conductor | `truck-conductor.traceodd.com` | `main_truck_conductor.dart` | ❌ | 🚧 **Blocker A** + imports BUS pages |
| 20 | Cricket Manager | `cricket-manager.traceodd.com` | `main_cricket_manager.dart` | ✅ D | ✅ **DONE** |
| 21 | Todd Studio | `studio.traceodd.com` | media-engine (Tauri) | n/a | ✅ **DONE** |
| 22 | Todd Broadcaster | `broadcaster.traceodd.com` | `apps/broadcaster-android` | n/a | ✅ **DONE** |
| 23 | Cricket Public | `cricket.traceodd.com` | `main_cricket_public.dart` | ✅ C | ✅ **DONE** |
| 24 | IoT Vehicle Security | `iot.traceodd.com` | — | ❌ | ⬜ not built |
| 25 | Note Authentication | `notes.traceodd.com` | — | ❌ | ⬜ not built |
| 26 | Landing | `traceodd.com` | `main_landing.dart` | ✅ B | ✅ **DONE** |

> **Note on #10 / #11 / #14:** they have their own entry points but share `FleetApp.run` +
> `fleetBlocProvider()` and the `FleetBlocLoginScreen`. That is *sufficient* for a URL-level split
> today, but the shared scaffold is exactly what `PANEL-SEPARATION-PLAN.md` §5b.2 wants promoted into
> `shared/` first. Link them if you want progress now; treat the shared scaffold as tracked debt.

---

## 4. Per-panel LOCK procedure (the 6 steps)

Run these for one panel at a time. **Never two panels in one commit** (plan hard rule 1).

### Step 1 — entry point + build target exist
Confirm the panel has its own `lib/main_*.dart` **and** a build+rsync step in
`frontend-deploy.yml` writing to `/var/www/traceodd/<panel>/`.
*If not → this is Blocker A; add the build first.*

### Step 2 — Cloudflare DNS record

| Field | Value |
|---|---|
Type | `A` |
Name | `<subdomain>` (e.g. `reseller`) |
IPv4 | `135.181.46.27` |
Proxy status | 🟠 **Proxied** (orange cloud) |
TTL | Auto |

Do **not** add a wildcard `*.traceodd.com` record — per-panel records are what make the isolation
auditable.

### Step 3 — nginx vhost (per subdomain)
Create `/etc/nginx/sites-available/<panel>` from the template in §5, symlink into `sites-enabled`,
`nginx -t`, then `systemctl reload nginx`.

> **Critical rule (plan §8):** the vhost must have an **exact `server_name`** and must **not** contain
> a catch-all `try_files … /index.html` at a level that could swallow another panel's paths.

### Step 4 — rotate that panel's login password
Follow `PHASE-0A-CREDENTIAL-REMEDIATION.md` **§3.6** (DB backup → hash backup → rotate → verify).
Do it **before** declaring the panel locked, so the proof in step 5 is meaningful.

### Step 5 — prove it
```bash
# from outside, with the NEW password
curl -sS -o /dev/null -w '%{http_code}\n' https://<subdomain>.traceodd.com/       # 200
curl -sS -o /dev/null -w '%{http_code}\n' https://<subdomain>.traceodd.com/api/v1/auth/login
# then log in through the UI and load the dashboard
```
Also confirm the isolation: a request to **another** panel's prefix on this host must be **403**.

### Step 6 — remove the old sub-path
Only after step 5 passes: delete the `location /<panel>/` block from `traceodd.conf`, reload nginx, and
remove the panel's entry from `admin.traceodd.com`'s expectations. This is what makes the move
irreversible in a good way.

---

## 5. nginx vhost template (per subdomain)

Based on the real `cricket-manager.conf`. Replace `<panel>` / `<dir>` / `<api-prefixes>`.

```nginx
server {
    listen 80;
    server_name <panel>.traceodd.com;
    client_max_body_size 10m;

    # ── 1. The Flutter SPA ──────────────────────────────────────────────
    root /var/www/traceodd/<dir>/;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, must-revalidate";

        # Flutter web reuses the same main.dart.js filename every build —
        # without this a browser can serve a stale bundle for weeks.
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            add_header Cache-Control "no-cache, must-revalidate";
            add_header Pragma "no-cache";
            expires -1;
        }
    }

    # ── 2. API — ONLY what this panel needs ─────────────────────────────
    # ALWAYS include the shared platform prefixes, or LOGIN BREAKS:
    #   /api/v1/auth/            unified login (GlobalAuthController)
    #   /api/v1/user/            notifications / preferences
    #   /api/v1/sync/            offline sync
    #   /api/v1/files/           uploads
    # Then add ONLY this panel's own prefixes, e.g. <api-prefixes>.
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

    # ── 3. Uploads ──────────────────────────────────────────────────────
    location /storage/ {
        alias /var/www/traceodd/admin-panel/storage/app/public/;
        add_header Access-Control-Allow-Origin *;
    }

    # ── 4. Reverb WebSocket (only if this panel uses live telemetry) ────
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

**Backend prefixes per panel** (from `routes/panels/*.php`):

| Surface | Prefix |
|---|---|
Super Admin / Sub-Admin | `/api/v1/super-admin/` *(plus `/api/v1/auth/`)* |
Universal Customer | `/api/v1/consumer/` + `/api/v1/marketplace/consumer/` |
B2B / Reseller / Shop Keeper | `/api/v1/marketplace/` |
Factory (Admin / Store Keeper / Driver) | `/api/v1/factory/` |
Bus Fleet (Admin / Store Keeper) | `/api/v1/bus-fleet/` |
Bus Owner | `/api/v1/bus-owner/` |
Truck Fleet | `/api/v1/truck-fleet/` |
Goods Fleet | `/api/v1/goods-fleet/` |
Cricket Manager | `/api/v1/cricket/manager/` + `/api/v1/cricket/admin/` + `/api/v1/cricket/public/` + `/api/v1/cricket/live/` |
Cricket Public | `/api/v1/cricket/public/` + `/api/v1/cricket/live/` |
IoT / Notes *(not built)* | `/api/v1/iot/` · `/api/v1/notes/` |

---

## 6. Definition of LOCK (a panel is not locked until all five are true)

- [ ] Its own `lib/main_*.dart` **and** its own build+rsync step in `frontend-deploy.yml`
- [ ] Its own nginx vhost with an **exact `server_name`** and **no catch-all** that could swallow another panel
- [ ] Cloudflare **A** record → `135.181.46.27`, proxied
- [ ] Its login password rotated, and **login proven with the new password**
- [ ] A request to another panel's API prefix on this host returns **403**
- [ ] `dart analyze` clean (plan §8 requires this before a phase exits)

---

## 7. Recommended execution order

The numbering is a good **checklist**; it is a bad **execution order**, because #1 is the hardest case
and #12–#13/#17–#19 cannot start at all.

| Wave | Panels | Why |
|---|---|---|
**W1** | #5 Reseller · #9 Factory Driver · #10 Bus Fleet · #11 Bus Owner · #14 Bus Store Keeper | Isolated entry points already exist — pure plumbing, fastest wins, proves the pattern |
**W2** | #12 · #13 · #17 · #18 · #19 | Add the missing 5 build steps (**Blocker A**), then link. #18/#19 also need the BUS→GOODS page extraction (plan §5b.2 item 4) |
**W3** | #1 · #2 · #3 · #7 · #8 | **Requires Phase 1 first (Blocker B)** — split `app_providers.dart`, kill the auth globals, thin out `main.dart` |
**W4** | #4 · #6 · #15 · #16 · #24 · #25 | Not built yet — build order, not a linking order |

---

## 8. Provenance

| Date | Change |
|---|---|
| 2026-09-25 | Created. Derived from `.nginx/traceodd.conf`, `.nginx/cricket-manager.conf`, `.github/workflows/frontend-deploy.yml` and the `lib/main_*.dart` entry points. Records the two blockers and the recommended wave order. |
