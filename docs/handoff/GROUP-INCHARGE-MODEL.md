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
| `financial_auditor` | — **cross-cutting, and the LARGEST sub-admin role** (owner, 2026-09-26) |

> **`financial_auditor` — the owner's clarification.** It maps to no single group **on purpose**: it is
> the biggest of the sub-admin jobs. It **creates, controls, changes and applies the subscription plans
> of every group** (monthly / annual / etc.) and **controls and creates the invoices of every group's
> users**. Compare with the other sub-admins, who look after one group each — this one looks after the
> money across all of them. Design consequences:
>
> - It needs **read access across every group** for billing purposes (an explicit exception to the
>   one-group-per-sub-admin rule, and it must be scoped to billing data only).
> - It owns `plans/**` and `billing/**` — today those live in the **Super Admin** shell
>   (`/plans`, `/plans/create`, `/billing/invoices`).
> - It is the vertical most likely to need a **Feature-Grant gate** so it cannot read operational data
>   it has no business seeing, while still reading every invoice.

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

## 1.4 Group 9 — Marketing & Growth (new, owner-confirmed 2026-09-26)

**Owner's ruling:** the Marketing hierarchy deserves **its own Group**, not a corner of an existing one.
Reasons that hold up on inspection:

1. It has **four surfaces** (below) — no existing group's shape fits it.
2. It markets **every** group (cross-group) — so it cannot belong to Group 3 or 4.
3. It carries its own **payroll + commission** model.
4. The owner already intends a **separate server** for it — a new group gives the separation plan a clean
   starting point rather than a fifth special case inside an existing server.

### The four surfaces

| # (to allocate) | Surface | Notes |
|---|---|---|
| — | **Marketing Sub-Admin** | one, appointed by the Super Admin — same pattern as the other verticals |
| — | **District Marketing Administrator** | **4–5**, one per district |
| — | **District Marketing Manager** | one per district, under its administrator |
| — | **Marketing Agent** | many, under each manager |

**Group 9 = its own frontend + backend (schema) + database, and its own server later.**
Run its **LOCK** exactly like `PANEL-SUBDOMAIN-LINKING-PLAYBOOK.md` describes for the other groups.

### What makes it more than a panel — and why it needs its own design step (C1b)

| Feature (owner) | Design consequence |
|---|---|
| **Every level has its own APP** | four new surfaces in the §11 registry, each with a build target and a subdomain |
| **The Manager onboards clients** — registers the bus-fleet / factory accounts, uploads their documents, hands them their panel | this is also the **commission attribution** model: *whoever created the account earns it*. Needs an explicit `created_by` / attribution link on the company + subscription records |
| **A course per panel/app inside the Marketing panel** — video + screenshots | needs a content store (assets + a small CMS), not code-only |
| **Compensation per person, 3 modes:** salary only · salary + commission · commission only | per-agent compensation mode on the model, and the commission path **must reuse the idempotent split engine** (`PANEL-SEPARATION-PLAN.md` §10.5) — **no second ledger** |
| **"Include the world's marketing approaches"** | the design step must pick a concrete, finite set (referral, partner/reseller, commission tiers, district targets, campaigns) rather than an open-ended list |

### Open questions for C1b

1. Commission per **sale**, per **signed-up company**, or per **subscription renewal**?
2. Is a "district" a row in the existing **`districts`** table?
3. Does this hierarchy sit **under** the Group-Incharge model or **beside** it?
4. Do the four surfaces share one login identity with different roles, or four separate ones?

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
vertical. **The owner refined this (2026-09-26) — and the key rule is *which buttons stay live*:**

> *"Super Admin should not be able to change anything in a sub-admin's panel. But **every button must be
> clickable** so the Super Admin can open it and read the detail. Buttons that change nothing are live;
> buttons that **do** change something — delete account, edit account, etc. — are **LOCKED** for the
> Super Admin."*
>
> So the rule is: **inspect everything, mutate nothing.**
>
> | Behaviour | Super Admin, inside a sub-admin panel |
> |---|---|
> | Navigate every screen, open every detail view, read every list/report | ✅ allowed |
> | Click a **mutating** button (delete, edit, approve, suspend, pay, reset password) | ⛔ **locked** — disabled, with a clear *"read-only observation"* tooltip |
> | Any write that slips past the UI | ⛔ **still refused server-side** — the UI lock is convenience, the API gate is the real control |
>
> **Implementation note:** enforce it with **one server-side middleware**, not per-screen checks — an
> `observation.mode` flag on the token that makes every non-GET request fail. Then a screen added later
> is automatically safe, which is what makes this maintainable rather than a game of whack-a-mole.

Minimum requirements before it ships:

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

## 4. Phased roadmap — **confirmed order** (owner approved: small → large)

| Order | Phase | Gate |
|---|---|---|
| **1** | **A** — A1 ✅ done · A2 (`CompanyRegisterBloc`) · A3 (dead sidebar button) | none — safe |
| **2** | **B** — B1: factory auth domain split (`§17.9` step 1) | closes the cross-domain token leak |
| **3** | **C0** — design, with the owner's answers folded in | none |
| **4** | **C1** — add the missing verticals, and expand `financial_auditor` to own `plans/**` + `billing/**` | needs C0 |
| **5** | **C2 → C3 → C4 → C5** | C5 last, and only with the audit chain |

Small, safe phases first. Nothing in Phase A or B touches the authority model, so they can land while
the owner tests the panels.

### Phase A — small defects (≈1 session, near-zero risk)

| # | Item | Why now |
|---|---|---|
| **A1** | **Remove the double-hash footgun.** `AdminUser::setPasswordAttribute` (and `GlobalIdentity`'s) currently re-hash anything given to them, so passing an already-hashed value silently breaks login. Guard with `Hash::isHashed()` — Laravel's own `hashed` cast behaviour | The owner hit exactly this trap; one line prevents a lockout |
| **A2** | ✅ **Checked 2026-09-26 — no action needed.** `CompanyRegisterBloc` is used by `super_admin/companies/register_company_screen.dart`, which was **not** deleted (it is the generic factory registry at `/companies/register`, and §6 keeps it as platform). So it is **not orphaned** — leave it | Finishes the duplicate removal |
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

## 5. Owner's answers (2026-09-26) — questions closed

| # | Question | Answer |
|---|---|---|
| 1 | `financial_auditor` scope | **Not cross-cutting by accident — it is the biggest sub-admin role.** Creates/controls/changes the subscription plans of **every** group and the invoices of **every** group's users. See §1.1 |
| 2 | Groups 7 (Vehicle Security) / 8 (Trust & Safety) | **Work on them per their phase** — their incharges are created with the rest in C1, not ahead of their panels |
| 3 | Who approves a group's admin accounts | **Still open** — the owner said *"create, approved etc"*. Fold into **C0** |
| 4 | Super Admin keeps read access to company registries? | **Still open** — folded into **C0 / C3** |
| 5 | Impersonation design | ✅ **Agreed, with one refinement:** every button stays **clickable for inspection**, but mutating buttons are **locked**, and the real block is server-side. See §3 |

**Also agreed:** build the **read-only group activity + payments view first** (C4), and the
"enter dashboard" click-through (C5) **last**, with the audit chain.

### 5.1 Still open after this round

| # | Item |
|---|---|
| a | Sub-Admin **creates** accounts outright, or creates and the Super Admin **approves**? (Q3) |
| b | After C3, does the Super Admin keep **read** access to the company registries? (Q4) |
| c | `financial_auditor` — confirm it reads **billing data only** across groups, not operational data |

---

## 6. Provenance

| Date | Change |
|---|---|
| 2026-09-26 | Created from the owner's directive. Gap analysis verified against `SubAdminSeeder`, `SubAdminController`, `super_admin_shell.dart` and the `SubAdminBloc` endpoint list. Phased roadmap and the impersonation safety requirements recorded. |
