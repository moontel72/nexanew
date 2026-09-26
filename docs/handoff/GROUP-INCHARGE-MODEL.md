# Group-Incharge Model — Target Authority Structure & Phased Roadmap

**Owner's directive (2026-09-26):** every **Group** in `PANEL-SEPARATION-PLAN.md` gets **one Sub-Admin
incharge**, appointed by the Super Admin. Each Sub-Admin then **creates and approves the admin accounts
of its own group**. The Super Admin **loses the ability to create any group's accounts** and becomes an
**observer** — group activity, payments and graphs — plus a button to **enter any Sub-Admin's dashboard**
and watch what they are doing.

**Status:** plan only. No code written for this model yet.
**Read with:** `PANEL-SEPARATION-PLAN.md` §1 (the 8 groups), §10.2 (sub-admin hierarchy), and
`PHASE-0A-CREDENTIAL-REMEDIATION.md` (the account-recreation sequence this replaces).

---

## 1. What exists today (verified, not assumed)

### 1.1 Sub-Admin verticals in the database

`SubAdminSeeder` / `SubAdminController` seed **five** verticals:

| Vertical code | Maps to which plan Group |
|---|---|
`bus_transit` | Group 4 — Bus Fleet ✅ |
`goods_logistics` | Group 5 — Goods/Truck ✅ |
`commercial_marketplace` | Group 2 — B2B ✅ |
`cricket_ops` | Group 6 — Cricket ✅ |
`financial_auditor` | — **cross-cutting**, maps to no group |

**So three groups have no incharge vertical at all:**

| Group | Incharge vertical today |
|---|---|
**3 — Factory** | ❌ **missing** — this is the gap the owner found |
**7 — Vehicle Security** | ❌ missing (group has no panels yet either) |
**8 — Trust & Safety** | ❌ missing (group has no panels yet either) |

### 1.2 Who creates what today

| Account | Created from | Evidence |
|---|---|---|
Factories (Factory Admin) | **Super Admin** | `super_admin_shell.dart` → `/companies/register` ⇒ title *"Create New Factory"* |
Bus companies | **Sub-Admin** (full CRUD) | `SubAdminBloc` → `/api/v1/admin/bus-companies/*` |
Resellers | **Super Admin** | sidebar → `/resellers/add` |
Sub-Admins | **Super Admin** | sidebar → `/sub-admins/add` |
Factory Store Keeper + Driver | **Factory Admin** | `factory/admin/.../{store_keepers,drivers}/` |
Bus/Truck companies + admins | Sub-Admin (bus only so far) | — |

**Conclusion:** today the Super Admin creates two groups' accounts (Factory, and indirectly Reseller/B2B),
which is exactly what the owner wants removed.

### 1.3 Observation / impersonation

**Nothing exists.** No impersonation endpoint, no "enter sub-admin dashboard" route, no read-only mode.
The Super Admin dashboard has KPI tiles and quick actions, but no cross-tenant observation.

---

## 2. Target model

```
                          SUPER ADMIN
                    (observer + platform owner)
                    ┌──────────────────────────────┐
                    │ • group activity feed        │
                    │ • payments / graphs          │
                    │ • "enter sub-admin view"     │  ← audited impersonation

                    │ • appoints ONE sub-admin     │
                    │   per group                  │
                    │ • CANNOT create group        │
                    │   accounts any more          │
                    └──────────────┬───────────────┘
                                   │ appoints
        ┌──────────────┬───────────┼───────────┬──────────────┐
    Sub-Admin      Sub-Admin   Sub-Admin   Sub-Admin      Sub-Admin
    Factory        Bus         Goods       B2B            Cricket (+ IoT, Trust)
        │
        ├─ creates / approves the group's ADMIN accounts
        │     e.g. Factory Admin
        │
        └─ that admin then creates its own staff
              e.g. Factory Admin → Store Keeper + Driver
```

**Chain of creation becomes strictly top-down, one group at a time:**

```
Super Admin  →  Group Sub-Admin  →  Group Admin  →  group staff
```

---

## 3. ⚠️ The one part that needs real design — Super Admin "enters" a Sub-Admin dashboard

The owner's words: *"click karne se wohi kisi bhi sub-admin ke dashboard me daakhil ho kar dekhe"*.
Useful, but this is **impersonation**, and done casually it becomes an unaudited backdoor into every
vertical. Minimum requirements before it ships:

| # | Requirement | Why |
|---|---|---|
| 1 | **Read-only by default.** A visible switch to "act as" — and acting must be off. | Otherwise a bug in one screen silently becomes a cross-tenant write |
| 2 | **Never the sub-admin's password.** Issue a short-lived token with a marker claim (e.g. `impersonated_by`), not the account's own credentials | So it cannot be replayed or mistaken for a real session |
| 3 | **Time-boxed** (e.g. 15 min) and auto-expiring | Limits the blast radius of a leaked token |
| 4 | **Visible to the sub-admin.** Show a banner *"Super Admin is viewing this dashboard"* | An invisible observer is the definition of a backdoor |
| 5 | **Written to the audit chain** (`audit_log_security`, plan §10.8): who, which sub-admin, when, why, and every action taken | Non-negotiable for a financial system |
| 6 | **A reason is required** on entry (free text) | Turns "browsing" into a recorded, accountable act |
| 7 | **Cannot be used to change passwords, move money, or delete** — hard-blocked server-side, not just hidden in the UI | The point of the feature is *observation* |

> **Recommendation:** build this **last**, and build the read-only group-activity + payments view
> **first** — it delivers most of the owner's intent with none of the impersonation risk.

---

## 4. Phased roadmap

Small, safe phases first. Nothing in Phase A or B touches the authority model, so they can land while
the owner tests the panels.

### Phase A — small defects (≈1 session, near-zero risk)

| # | Item | Why now |
|---|---|---|
| **A1** | **Remove the double-hash footgun.** `AdminUser::setPasswordAttribute` (and `GlobalIdentity`'s) currently re-hash anything given to them, so passing an already-hashed value silently breaks login. Guard with `Hash::isHashed()` — Laravel's own `hashed` cast behaviour | The owner hit exactly this trap; one line prevents a lockout |
| **A2** | Check whether `CompanyRegisterBloc` is used only by the two **deleted** *Add … Company* screens (`126f618d`). Delete if orphaned | Finishes the duplicate removal |
| **A3** | Sub-Admin sidebar: `Missile3DButton(label: 'Bus Companies', onTap: () {})` at `sub_admin_dashboard.dart:1457-1463` — either wire it to the inline bus-company section or remove it | Dead button in a live panel |

**Verify:** `dart analyze <changed files>` + `node .scripts/check-panel-isolation.mjs` green.

### Phase B — auth correctness (small, verified)

| # | Item | Why now |
|---|---|---|
| **B1** | `PANEL-SEPARATION-PLAN.md` §17.9 **step 1** — migrate the 4 factory files to `FactoryAuthState`. This closes the **cross-domain token leak** (§17.8: after a super-admin login, `getFactoryAuthToken()` returns the *admin* token) | It is a live defect, and it is on the critical path for everything that follows |

### Phase C — the Group-Incharge program (largest; needs design + owner testing)

| # | Step | Notes |
|---|---|---|
| **C0** | **Design doc**: group → vertical → which accounts that vertical creates | Extends this file; no code |
| **C1** | **Add the missing verticals** — `factory`, and stubs for `vehicle_security` / `trust_safety` — to `sub_admin_verticals` (seeder + `SubAdminController` validation) | Mirrors the existing 5 |
| **C2** | **Factory account creation moves to the Factory Sub-Admin.** Backend endpoints (mirror the `bus-companies` CRUD pattern) + the Sub-Admin UI | Removes the Super Admin's `/companies/register` path for factory **admins** |
| **C3** | **Remove group-account creation from the Super Admin** for every group (Factory now; confirm B2B/Reseller). Super Admin keeps only *platform* accounts (sub-admins, plans, billing, registries as read-only) | This is the owner's core requirement |
| **C4** | **Super Admin observation view** — per-group activity feed + payment records/graphs, read-only | Delivers most of the intent safely |
| **C5** | **Audited "enter sub-admin view"** — the §3 requirements above | Build only after C4, and only with the audit chain in place |

---

## 5. Open questions for the owner

| # | Question | Why it matters |
|---|---|---|
| 1 | **`financial_auditor`** maps to no group. Keep it as a cross-cutting role, or fold it into a group? | Affects the vertical list in C1 |
| 2 | **Groups 7 (Vehicle Security) and 8 (Trust & Safety)** have no panels yet. Create their Sub-Admin now, or when the panels are built? | C1 scope |
| 3 | **Who approves a group's admin accounts** — does the Sub-Admin create them outright, or create-and-the-Super-Admin-approves? | Owner said *"create, approved etc"* — needs one decision |
| 4 | **Should the Super Admin keep read access to platform-wide company registries** after C3, or lose them too? | C3 scope |
| 5 | **Impersonation (§3)** — confirm read-only + audited + visible-to-sub-admin is acceptable | Security design |

---

## 6. Provenance

| Date | Change |
|---|---|
| 2026-09-26 | Created from the owner's directive. Gap analysis verified against `SubAdminSeeder`, `SubAdminController`, `super_admin_shell.dart` and the `SubAdminBloc` endpoint list. Phased roadmap and the impersonation safety requirements recorded. |
