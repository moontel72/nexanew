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
| **1** | **A** | **A1** double-hash footgun · **A2** `CompanyRegisterBloc` check · **A3** dead sidebar button | A1 ✅ · A2 ✅ · **A3 ✅ (commit `3b072d09`)** |
| **2** | **B1** | factory auth domain split (`PANEL-SEPARATION-PLAN.md` §17.9 step 1) — closes the cross-domain **token leak** (§17.8) | **✅ factory domain done 2026-09-26** — admin/sub-admin steps 2-4, 6 pending |
| **3** | **C0** | design for the Group-Incharge model (owner's answers already folded in) | ⏳ |
| **4** | **C1** | add the missing verticals + give `financial_auditor` `plans/**` + `billing/**` | ⏳ needs C0 |
| **5** | **C2 → C3 → C4 → C5** | factory creation → remove group-account creation from Super Admin → read-only group activity + payments → audited "enter sub-admin view" | ⏳ C5 last |

### A3 — ✅ done (`3b072d09`)

The dead button below is **already removed**. Recorded for the next session so it is not re-done:

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

**So:** a row in `admin_users` is invisible to `/api/v1/auth/login`. With no matching `identity_claims`
row, the request fails at `claim_not_found` **before the password is ever checked** — which is why
**resetting the password cannot fix this**, and why the reported symptom is a hard, constant 401.

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

**Recommended, concretely:** the existing **`MasterAdminSeeder`** already does option A correctly
(`GlobalIdentity(identity_type='admin')` + phone/email claims + `master_admin_assignments` +
`TenantAccount` bridge) and now takes its password from `NEXATRACE_MASTER_ADMIN_PASSWORD`.
Its email is the constant `MASTER_ADMIN_EMAIL = 'admin@nexatrace.com'` — so either use that account, or
change the constant to the owner's address before seeding.

**Still owed to the owner:** an Artisan command
`php artisan admin:reset-password <email> <password>` that reports **which table holds the account** and
sets the password in the right place (spine **and** `admin_users`) instead of silently doing nothing.
Until then, `PHASE-0A-CREDENTIAL-REMEDIATION.md` §3.6.1 handles the `admin_users` half.

### The concrete fix (owner chose Option A, 2026-09-26)

Confirmed on the live server: `identity_claims = 0`, `global_identities = 0`, `admin_users = 1`. The fix
is to put that admin into the spine.

> **⚠️ Use the CURRENT script, not the inline one further down.** The inline copy below was the first
> attempt and hit database column errors on the live server. The maintained, **defensive** version is
> version-controlled at **`.scripts/make-admin-spine.php`** — `php -l` clean. It differs in four ways:
>
> 1. **Prints the live column list** for `admin_users`, `global_identities`, `identity_claims`,
>    `tenant_accounts` and `master_admin_assignments` **first** — so a mismatch between the migrations
>    and the deployed database is visible instead of silent.
> 2. Wraps every step in a guard that **reports the real exception and continues** (one bad column can
>    no longer abort the run).
> 3. Also **syncs `admin_users`** (`role='super_admin'`, `status='active'`) so the legacy
>    `/api/v1/admin/login` works too.
> 4. Ends with a **verification block that mirrors `GlobalAuthController@login`** exactly (claim found →
>    identity → password ok).
>
> **The FK column is confirmed correct:** `identity_claims.global_identity_id` → `global_identities.id`
> (`2026_06_03_000500_create_identity_claims.php:36,48`). So if the live database rejects it, the
> deployed table differs from the migrations — and step 1's column dump is what proves it.

**First, inspect the live schema** (this is the answer to "which column is it really?"):

```bash
sudo -u postgres psql -d nexasystem_db -c "\d global_identities"
sudo -u postgres psql -d nexasystem_db -c "\d identity_claims"
sudo -u postgres psql -d nexasystem_db -c "\d master_admin_assignments"
sudo -u postgres psql -d nexasystem_db -c "\d tenant_accounts"
```

Or, one query for every column name at once:

```bash
sudo -u postgres psql -d nexasystem_db -c "
  SELECT table_name, column_name, data_type, is_nullable
  FROM information_schema.columns
  WHERE table_name IN ('global_identities','identity_claims','admin_users','master_admin_assignments','tenant_accounts')
  ORDER BY table_name, ordinal_position;"
```

**Then run the script** — copy the file from `.scripts/make-admin-spine.php` to the server and run:

```bash
cd /var/www/traceodd/admin-panel
# copy .scripts/make-admin-spine.php here (scp, or paste it into nano)
sudo -u www-data php make-admin-spine.php tahawan72@gmail.com
rm -f make-admin-spine.php
```

**Send me the script's full output** if anything says `FAIL` — the first block prints every column, so
the cause will be visible in the output.

**Superseded — the original inline script, kept only for the record.**

Confirmed on the live server: `identity_claims = 0`, `global_identities = 0`, `admin_users = 1`. This
script puts that admin into the spine — it is the seeder's logic, but takes **any** email and reads the
password from a hidden prompt so nothing is stored in history or in a chat.

```bash
cd /var/www/traceodd/admin-panel
cat > make-admin-spine.php <<'PHP'
<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
use App\Models\GlobalIdentity;
use App\Models\IdentityClaim;
use App\Models\TenantAccount;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

$email = $argv[1] ?? null;
if (!$email) { fwrite(STDERR, "usage: php make-admin-spine.php <email>\n"); exit(2); }

$identity = GlobalIdentity::where('identity_type', 'admin')->first();
if (!$identity) {
    $identity = GlobalIdentity::create([
        'identity_token' => GlobalIdentity::generateToken('admin'),
        'display_name'   => 'Trace Odd Super Admin',
        'identity_type'  => 'admin',
        'kyc_status'     => 'verified',
        'kyc_tier'       => 3,
        'status'         => 'active',
        'primary_locale' => 'en-PK',
    ]);
    echo "created global_identities row: {$identity->id}\n";
} else {
    echo "reusing existing admin identity: {$identity->id}\n";
}

$normalized = IdentityClaim::normalize('email', $email);
$claim = IdentityClaim::where('claim_type', 'email')->where('claim_value', $normalized)->where('is_revoked', false)->first();
if (!$claim) {
    IdentityClaim::create([
        'global_identity_id' => $identity->id,
        'claim_type'         => 'email',
        'claim_value'        => $normalized,
        'is_primary'         => true,
        'verified_via'       => 'manual_kyc',
        'verified_at'        => now(),
    ]);
    echo "created email claim for {$email}\n";
} else {
    echo "email claim already exists\n";
}

function hidden(string $p): string {
    echo $p; system('stty -echo');
    $v = rtrim((string) fgets(STDIN), "\r\n");
    system('stty echo'); echo "\n"; return $v;
}
$pw = hidden("Password for {$email} (typing hidden): ");
if (strlen($pw) < 12) { fwrite(STDERR, "Refusing: use at least 12 characters.\n"); exit(1); }
if ($pw !== hidden('Repeat: ')) { fwrite(STDERR, "Refusing: passwords did not match.\n"); exit(1); }
$identity->password = $pw;
$identity->save();
echo "spine password set\n";

$hasAssignment = DB::table('master_admin_assignments')->where('global_identity_id', $identity->id)->whereNull('revoked_at')->exists();
if (!$hasAssignment) {
    DB::table('master_admin_assignments')->insert([
        'id' => (string) Str::orderedUuid(),
        'global_identity_id' => $identity->id,
        'appointed_by_global_identity_id' => $identity->id,
        'appointed_at' => now(), 'created_at' => now(), 'updated_at' => now(),
    ]);
    echo "created master_admin_assignments row (Super Admin rights)\n";
} else {
    echo "master_admin_assignments already present\n";
}

$bridge = TenantAccount::where('global_identity_id', $identity->id)->first();
if (!$bridge) {
    TenantAccount::create([
        'account_name' => 'Trace Odd Super Admin',
        'email' => $email,
        'password' => $identity->password_hash,
        'phone_number' => '+920000000000',
        'global_identity_id' => $identity->id,
        'is_independent' => true,
        'account_type' => 'master_admin',
        'status' => 'active',
    ]);
    echo "created tenant_accounts bridge\n";
} else {
    $bridge->password = $identity->password_hash;
    $bridge->save();
    echo "synced tenant_accounts bridge password\n";
}

echo "\nDONE. Log in at https://admin.traceodd.com/login with {$email}\n";
echo "Then delete this script:  rm -f make-admin-spine.php\n";
PHP

sudo -u www-data php make-admin-spine.php tahawan72@gmail.com
rm -f make-admin-spine.php
```

**Then log in.** Verified with `php -l` (no syntax errors). Notes:

- It is **idempotent** — run it again for the same admin and it reuses the identity, skips existing
  claims/assignments, and just resets the password.
- It deliberately does **not** touch `admin_users`. If both must work, run §3.6.1 for that table as well.
- The password is typed by you, hidden, and never printed — consistent with the owner's rule.

---

## 7. Owner's decisions recorded 2026-09-26 (second round)

| Topic | Decision |
|---|---|
| **The 3 legacy `company_admin` rows** (`armi@`, `aziz@`, `khan@gmail.com`) | **Delete them.** The owner confirms they are test data, not needed, and can be recreated. Still: check `companies` for rows that reference them first |
| **Marketing hierarchy** | **Its own top-level Group** — its own frontend + backend + database, and its own server later. See §5 (four surfaces). **Plus** the Marketing *Manager* panel should do **client onboarding** (register the bus-fleet / factory accounts, upload their documents, hand them their panel) — because that is how the manager earns commission |
| **Marketing courses** | Each Marketing panel must carry **how-to-use material for every panel/app** — video and screenshots — so a manager can train the client they onboarded |
| **Compensation** | Per-agent mode: *salary only* · *salary + commission* · *commission only*. Commission must reuse the **idempotent split engine** (`PANEL-SEPARATION-PLAN.md` §10.5) — no second ledger. Include the full set of real-world marketing approaches |
| **Scope reminder** | *"for now we are not doing much internal coding"* — priority 3 is **login + dashboard entry only** |

## 8. What the long session of 2026-09-24 → 26 produced

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

**Not started:** C0–C5, the Marketing design (§5), and the four per-pillar builds.

> **Correction (2026-09-26, later session):** this §8 line originally listed **A3** and **B1** as not started.
> A3 was in fact already done in `3b072d09` (the same commit that added this file), and **B1** (the factory
> auth domain split) landed in a later session. See §3 for live status.
