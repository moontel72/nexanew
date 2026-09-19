# REVIEW REQUEST — for the Qoder expert agent

**What I am asking you to do:** review the whole project independently, read
`docs/handoff/PANEL-SEPARATION-PLAN.md`, and record **your own advice in a new, separate
`.md` file**. Do **not** write code. Do **not** modify the plan file.

The owner will compare your advice with the plan, and only then does coding begin.

---

## 0. The rule that matters most

**Do not change any code, workflow, Dockerfile, nginx config, or route.** This is a
review-only task. Two earlier attempts at fixing this system pushed unverified changes and
broke a CI build — the history is in `docs/handoff/FAULT-REMEDIATION-HISTORY.md` (that is a
*different* remediation cycle, about GStreamer faults; read it for the process lessons, not
the subject matter).

The owner's standing instruction: **whatever is asked must be done, and no other panel's
already-tested work may be broken.**

---

## 1. What this system is

One repository containing several business departments, each with multiple Flutter web
panels/apps. A Laravel backend and a Rust media engine (GStreamer/WebRTC) sit alongside.

- Flutter web apps: `lib/` — entry points are `lib/main_*.dart`
- Backend API: `backend/` (Laravel, multi-guard auth)
- Media engine: `media-engine/` (Rust; GStreamer 1.24, WebRTC SFU)
- CI: `.github/workflows/` — `frontend-deploy.yml` builds and rsyncs the web apps
- Server: one Hetzner host (`135.181.46.27`) serving everything over nginx today

### The 7 target departments

1. **Platform** — Super Admin + all Sub-Admin panels + Universal Customer app
2. **B2B Commerce** — B2B Marketplace + Reseller panel + Shopkeeper panel (one group, three
   sub-apps with their own names and login pages)
3. **Factory** — Factory Admin + Store Keeper + Driver (factory employees, factory logo)
4. **Bus Fleet** — Fleet Admin + Bus Store Keeper + third-party Bus Owner + Driver + Conductor
5. **Goods / Truck** — Goods Company Admin + store keeper + third-party Truck Owner + Driver
   + Conductor
6. **Cricket** — Todd Studio + Cricket Manager + Broadcaster + Public Viewer
7. **Vehicle Security** — nothing built yet

**Owned domain:** `traceodd.com` (a subdomain per department). Separate servers later. One
`lib/shared/` for the whole project — deliberately **not** one per department.

---

## 2. Read these first

| File | Why |
|---|---|
| `docs/handoff/PANEL-SEPARATION-PLAN.md` | **The plan you are reviewing.** |
| `docs/handoff/STREAM-ISSUE-REPORT-FOR-QODER.md` | Earlier handoff: live video not reaching the public page. **Still open.** |
| `docs/handoff/FAULT-REMEDIATION-HISTORY.md` | Process lessons only (GStreamer cycle). |
| `NEXATRACE_SUPREME_MASTER_SPEC.md` | The project's own spec. **It contradicts the plan on fleet structure** — see §4. |
| `AGENTS.md` | Repo rules, incl. the ignored-files escape hatch. |

---

## 3. What we already established (verify, don't take on trust)

Two prior scans produced these findings. **Independently confirm or refute each** — if any is
wrong, that matters more than anything else you report.

| Finding | Evidence we recorded |
|---|---|
| `lib/routes/app_router.dart` is a 1141-line mega-router serving **every** department | route table; line-range split table in the plan §7 |
| `lib/core/widgets/app_initializer.dart` composes SUPER + FACTORY + **BUS** | `:14`, `:23-24`, `:56-62`, `:163-166`, `:188-202`, `:218-224` |
| `lib/shared/` imports `lib/features/` **backwards** (only 4 edges) | `shared/widgets/navigation/admin_sidebar.dart:4`, `shared/bloc/telemetry_tracking/telemetry_models.dart:6`, `shared/utils/fleet_bloc_setup.dart:10-11`, `shared/widgets/fleet_bloc_login_screen.dart:20-23` |
| The design "pencil"/3D button lives in **BUS** but is used by BUS, CRICKET, SUPER ×2 and `shared/` | `bus_operations/presentation/widgets/missile_3d_button.dart` |
| The design system is **not** actually shared — only `colors.dart` (7 depts) and `primary_button.dart` (4 depts) cross departments; 4 competing theme roots; **no spacing/radius/icon tokens exist** | 85 files with inline `Color(0x…)`, 182 with inline `TextStyle(`, 191 with inline `BorderRadius.circular(` |
| Circular dependency SUPER ↔ BUS | BUS `fleet_dashboard_page` → 4 SUPER screens; SUPER `bus_fleet_dashboard_screen` → 2 BUS widgets |
| The **live** Customer Super-App is in `bus_operations/`; `lib/features/universal/customer/` is the dead copy | `app_router.dart:632-637` vs 0 external importers |
| Sub-Admin has a database model but **no enforcement** | `SubAdminMiddleware.php:57-69` checks only that an assignment exists; `sub.admin` used in one place; `sub_admin_feature_grants` never checked |
| A hardcoded, non-dynamic vertical list in the Sub-Admin UI | `add_sub_admin_screen.dart:15-48` — owner wants **data-driven toggles** instead |
| Factory Admin and Sub-Admin appear to open the same thing | one bundle, one router, one auth warm-up; `app_router.dart:252-258` leaves `/sub-admin/*` unguarded |
| Dead code | `features/transport/**`, `features/transport_marketplace/**`, `features/broadcaster/whip_client.dart`, `universal/customer/**`, several `core/navigation` + `core/services` files, 7 `nexa_admin` billing stubs, 6 `bus_operations` pages, ~24 `shared/` widgets |
| `lib/core/config/database_config.dart` holds PostgreSQL credentials in client-side code | 0 importers, but real credential strings committed to the repo |

---

## 4. The one genuine conflict you must rule on

`NEXATRACE_SUPREME_MASTER_SPEC.md` mandates a **unified fleet** layout:
`lib/features/fleet/{owner,driver,conductor}/` and `lib/main_fleet_*.dart`, and it marks
`main_driver.dart` / `main_reseller.dart` / the six `main_bus_*`/`main_truck_*` files as
**deleted**.

**None of that matches the code, and the owner explicitly rejects it.** The owner's ruling:

- **Bus Driver and Truck Driver apps stay SEPARATE** — Bus has seat management and ticketing;
  Truck has carton scanning and parcel tracking.
- But a driver's **account is one**: bus → truck → company → company moves keep the same
  account and history. The owner has **already tested this** (a third-party bus owner moved
  3–4 buses between fleet companies after ending a contract, preserving records).
- The mechanism is a **link** (time-bounded contract association), not a merged app.
- A bus/truck driver joining a **Factory** must create a **separate** account.
- Factory drivers and bus/truck drivers are different domains.

**Please state plainly whether you agree with the owner's model or the spec's, and why.** If
you believe the spec is right, say so — the owner has asked for disagreement to be raised.

---

## 5. Questions the owner would like your opinion on

1. **Server strategy.** The plan recommends: one `lib/shared/`, 7 separate builds/routers,
   7 subdomains, **one server now → N later**, with API-only coupling designed in from the
   start so the split is possible. The media engine is treated as a special case because it
   is **stateful** (a live call cannot migrate between servers; it needs room→server
   affinity), whereas the frontend is static files and the API can be made stateless. Is this
   staged approach right, or should anything split sooner?
2. **Sub-Admin enforcement.** Where should the grant check live — middleware, a policy per
   controller, or something else? The owner wants **dynamic toggles (roughly 1–40 roles per
   account)**, not a fixed vertical list.
3. **The deletion list.** Do you object to any item being deleted? Each entry in the plan
   states what was checked. Point out anything that is actually needed.
4. **Design unification.** The owner wants **one consistent design across every panel**, and
   dislikes hardcoded values. The plan promotes the BUS `missile_3d_button` into `shared/`
   first, then converges 4 theme roots and introduces spacing/radius/icon tokens. Is that
   order right, and can it be done without breaking working panels?
5. **The free-agent driver identity.** What is the best backend shape for a link that lets a
   driver move bus↔truck and company↔company while preserving history, given bus and truck
   are separate frontends?
6. **Cricket has no module record** in the spec's 15-module registry despite being a whole
   department here. Should it get one?
7. **The open streaming problem** (`STREAM-ISSUE-REPORT-FOR-QODER.md`) — it is unresolved and
   is the owner's original complaint. Anything you can add is valuable.

---

## 6. Deliverable

Write your advice to a **new file**, for example:

```
docs/handoff/QODER-REVIEW-<date>.md
```

Suggested structure:

1. **Corrections** — anything in the plan you believe is factually wrong, with evidence.
2. **Answers** to the seven questions above.
3. **Risks** the plan does not cover.
4. **Disagreements** — where you would do it differently, and why.
5. **Your recommended phase order**, if different from the plan's.

**Constraints:**

- Read-only. No code, workflow, nginx, or Dockerfile changes.
- Cite `file:line` for every factual claim. Where you are unsure, say so explicitly rather
  than guessing — a wrong confident claim is worse than an open question here.
- Some generated/vendored files are hidden from search and read per `AGENTS.md`. If a file
  appears missing, `node .scripts/agent-ignored-files.mjs find <name>` locates it; do **not**
  run its `allow` subcommand without the owner's permission.
- Report findings even when they contradict the plan. That is the point of this review.
