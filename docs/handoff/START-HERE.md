# START HERE — read this file first

**Purpose:** the entry point for a **fresh agent session**. It says what to read, in what order, and what
the owner has already decided — so none of the agreed work is lost when a chat gets long and a new one
has to start.

**Last updated:** 2026-09-26 (end of a long session — see §6 for what it produced).

---

## 1. Read order

1. **this file**
2. `docs/handoff/PANEL-SEPARATION-PLAN.md` — §11 registry, §15b provider split (DONE), §17 auth globals,
   §18 provenance
3. `docs/handoff/GROUP-INCHARGE-MODEL.md` — the authority model + the phase order
4. `docs/handoff/PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md` — subdomains, LOCK, the two blockers
5. `docs/handoff/PHASE-0A-CREDENTIAL-REMEDIATION.md` — credentials; **§3.6.1 = Super Admin password**
6. per-pillar specs: `PILLAR-A-BANKNOTE-AUTHENTICATION.md`, `PILLAR-B-PRODUCT-ANTI-COUNTERFEIT.md`,
   `PILLAR-E-IOT-VEHICLE-SECURITY.md`

---

## 2. ⭐ The owner's TOP-LEVEL priority order (2026-09-26)

**Where this conflicts with the phase order in §3, THIS wins.** The owner stated it explicitly.

| # | Priority | What it means |
|---|---|---|
| **1** | **End the mixing. Remove junk files and code.** Take the Super Admin panel out of every group's account creation; confine every sub-admin to its own domain. Cleaning the Super Admin panel is current work | ← **we are here** |
| **2** | **Build the missing dashboards** — any panel/app whose build or dashboard does not exist yet |
| **3** | **Test that every panel/app can LOG IN and reach its own dashboard.** Login + dashboard entry **only** |
| **4** | **Subdomain + Cloudflare** for every panel/app not yet linked |

**Standing scope rule (owner, same message):** *"for now we are not doing much internal coding."*
Priority 3 means **login + dashboard entry only** — do **not** start fixing what is inside each dashboard.

> This makes priority 3 a *verification* phase, not a build phase. It is the fastest route to the owner's
> actual goal: every group's panels and apps usable and reachable.

---

## 3. The confirmed phase order (small → large) — with live status

| Order | Phase | Content | Status |
|---|---|---|---|
| **1** | **A** | **A1** double-hash footgun · **A2** `CompanyRegisterBloc` check · **A3** dead sidebar button | A1 ✅ · A2 ✅ · **A3 ⏳ remaining** |
| **2** | **B1** | factory auth domain split (`PANEL-SEPARATION-PLAN.md` §17.9 step 1) — closes the cross-domain **token leak** (§17.8) | ⏳ |
| **3** | **C0** | design for the Group-Incharge model (owner's answers already folded in) | ⏳ |
| **4** | **C1** | add the missing verticals + give `financial_auditor` `plans/**` + `billing/**` | ⏳ needs C0 |
| **5** | **C2 → C3 → C4 → C5** | factory creation → remove group-account creation from Super Admin → read-only group activity + payments → audited "enter sub-admin view" | ⏳ C5 last |

### A3 — the one remaining item in Phase A

`lib/features/nexa_admin/presentation/screens/sub_admin/sub_admin_dashboard.dart:1457-1463` builds:

```dart
Missile3DButton(
  label: 'Bus Companies',
  icon: Icons.directions_bus,
  color: const Color(0xFF16A34A),
  height: 64,
  onTap: () {},      // ← does nothing
)
```

**Recommended resolution: remove the button.** The bus-company management already lives **inline** in the
same dashboard (an *Add Bus Company* action plus a registered-companies list), so **nothing is lost** —
and a dead button in a live panel is worse than no button. Re-adding a *wired* shortcut later is trivial.
(Wiring it instead is also valid; removing is the zero-risk option and matches the owner's
"no extra internal coding for now" rule.)

---

## 4. Super Admin password — the simplest possible steps

`https://admin.traceodd.com/login` authenticates against the **`admin_users`** table
(`AdminAuthController@login`). The screen's *Forgot Password?* link is a **placeholder** — there is no
self-service reset, so an operator sets it. **Full detail: `PHASE-0A-CREDENTIAL-REMEDIATION.md` §3.6.1.**

```bash
cd /var/www/traceodd/admin-panel

# (1) create the helper script — the exact file is in runbook §3.6.1, copy-paste it
# (2) run it for your account:
sudo -u www-data php reset-admin-pw.php admin@nexatrace.local
#     -> it will ask for the new password TWICE. Type it. Nothing is shown on screen.
# (3) log in at https://admin.traceodd.com/login
# (4) remove the script so it cannot be reused:
rm -f reset-admin-pw.php
```

**The script never prints, logs or stores the password** — it reads it from a hidden prompt and the model
hashes it. So the value never reaches a chat, a shell history, or this repository.
**Do not** hash manually — the `AdminUser` mutator already hashes (and now safely skips an
already-hashed value).

---

## 5. New requirement not yet designed — Marketing hierarchy (owner, 2026-09-26)

A **new sub-admin vertical** the owner wants: **Marketing**. It is unlike the others — it is a
**4-level field hierarchy** that can market **every group at once**.

```
Marketing Sub-Admin                       (1, appointed by the Super Admin — like the other verticals)
   └── District Marketing Administrator    (4–5, one per district)
          └── District Marketing Manager   (one per district, under its administrator)
                 └── Marketing Agent       (many, under each manager)
```

**Two things make it its own design task:**

1. **Every level has its own APP** — so this is not one new panel, it is *four* new surfaces.
2. **Compensation is per person, in three modes:** *salary only* · *salary + commission* · *commission
   only*. That means the data model needs a per-agent compensation mode, and the commission path must
   reuse the existing **idempotent commission split engine** (`PANEL-SEPARATION-PLAN.md` §10.5) rather
   than inventing a second ledger.

**Status:** recorded only — **needs its own design step (call it C1b)**, because it adds four surfaces to
the registry in §11 and an attribution/commission model that does not exist yet.
**Open questions:** does an agent earn commission per *sale*, per *signed-up company*, or per
*subscription*? Is a district a `districts` table row (that table already exists)? Does the marketing
hierarchy sit under the Group-Incharge model or beside it?

---

## 6. What the long session of 2026-09-24 → 26 produced

| Commit | What | Isolation baseline |
|---|---|---|
| `ca591a98` | CI boundary guard (`.scripts/check-panel-isolation.mjs`) + measured the real coupling | 84 |
| `969aab00` | 4 dead `core/` files removed | 77 |
| `3be02476` | dead `transport` + `transport_marketplace` removed (20 files, −6,116 lines) | 75 |
| `eba16ee6` | provider split — **`core → features` is now 0** | **28** |
| `9f59ef28` | **`/sub-admin/*` route guard** (owner smoke-tested: all pass) | 28 |
| `126f618d` | **duplicate Super Admin bus/goods company registration removed** (−2,346 lines) | 28 |
| `5c16d006` | **A1** — double-hash lockout footgun removed | 28 |
| `303eebf8` | owner's answers folded into the Group-Incharge model | 28 |

Also in this period: Phase 0a credential remediation, the pillar specs (A/B/E), the subdomain playbook,
the plan's §15b/§17 (provider split + auth globals + the `/sub-admin` fix), and §18 provenance.

**Not started:** A3 (§3), B1, C0–C5, the Marketing design (§5), and the four per-pillar builds.
