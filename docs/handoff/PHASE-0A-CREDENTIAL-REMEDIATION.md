# Phase 0a — Credential Remediation Runbook

**Companion to:** `PANEL-SEPARATION-PLAN.md` §8 (Phase 0a) and §9b (quick-win checklist).
**Created:** 2026-09-25.

**Who does what:**

| Part | Owner |
|---|---|
| §2 — in-repo cleanup | **Done** (this cycle, committed) |
| §3 — server-side rotation and exposure check | **YOU (owner)** — cannot be done from a dev machine |
| §4 — flip super-admin enforcement | **YOU**, after §3 |
| §5 — turn the new secret scan into a hard gate | **Either** — 2-minute change |

> **Why this is urgent and why rotation is not optional:** these values sat in a git
> repository with a remote (`github.com/moontel72/nexanew`). Anyone with repo access — or
> anyone who ever has had it, or any fork — has already seen them. Removing a string from a
> file does **not** undo that. **Only rotation closes the window.** Deleting the text is
> hygiene; rotating the password is the fix.

---

## 1. What was found (2026-09-25 audit)

Six new locations were found in the working tree **beyond** what the earlier review knew
about. Two of them were live UI exposure, which is worse than a doc leak.

| # | Location | What | Severity |
|---|---|---|---|
| 1 | `lib/features/factory/admin/presentation/screens/factory_login_screen.dart` | **Login form pre-filled with `factory-admin@nexatrace.local` and the shared admin password** — anyone could sign in without knowing a password | 🔴 Critical |
| 2 | `lib/features/factory/store_keeper/presentation/screens/store_keeper_login_screen.dart` | **Login form pre-filled** with a real person's email and the same shared admin password | 🔴 Critical |
| 3 | `backend/database/deploy.ps1` | Four production passwords as **parameter defaults** (Postgres superuser + three app roles) | 🔴 Critical |
| 4 | `backend/database/backup.ps1` | Postgres superuser password as a parameter default | 🔴 Critical |
| 5 | `backend/database/seeders/NexaBootstrapSeeder.php` | Seeder created the Super Admin and Factory Admin with the same known password | 🟠 High |
| 6 | `README.md` | SSH **root** password and both admin panel passwords | 🔴 Critical |
| 7 | `backend/database/DEPLOYMENT.md` | `CREATE ROLE ... PASSWORD '...'` for all three roles, plus `.env` example password | 🟠 High |
| 8 | `NEXATRACE_SUPREME_MASTER_SPEC.md` §8.6 | A "Login Credentials" table listing the admin passwords | 🟡 Medium |
| 9 | `docs/handoff/PANEL-SEPARATION-{PLAN,RECOMMENDATIONS}.md` | Quote the compromised values as incident evidence | 🟡 Medium (already public in git history) |
| 10 | `backend/database/seeders/MasterAdminSeeder.php` | A hardcoded **Master Admin** password constant (the highest-privilege account in the system), which the seeder also printed to the console. *(Value deliberately not repeated here — read it from git history, then rotate.)* | 🔴 Critical |
| 11 | `backend/database/seeders/SubAdminSeeder.php` | A hardcoded **`DEFAULT_PASSWORD`** — one shared password for **every** sub-admin. *(Value deliberately not repeated here.)* | 🔴 Critical |
| 12 | `lib/features/nexa_admin/.../sub_admin_login_screen.dart` | Sub-admin login used `hintText: 'subadmin@nexatrace.com'` — discloses a real admin account name | 🟡 Medium |

Rows 1, 3, 4, 5, 6, 8, 10, 11 and 12 were **found by this audit** (rows 1, 5, 10 and 11 are the serious ones);
rows 2, 7, 9 were already known. Note that rows 10 and 11 create **live accounts** when the seeders
run — so those passwords must be rotated as well, not just removed from the code.

**Reused passwords matter here.** The Postgres **superuser** password was reused verbatim in at
least three files, and one admin password was shared across every admin account. Assume every
value listed above is compromised. (The literal values are deliberately not repeated in this
file — read them from git history if you need them, then rotate.)

---

## 2. Fixed in-repo (already committed)

| File | Change |
|---|---|
| `README.md` | All five password strings replaced with a pointer to the team password manager |
| `backend/database/deploy.ps1` | Passwords no longer defaulted — read from `NEXATRACE_PG_*` env vars, with a **hard gate that throws** rather than installing a database with an empty password |
| `backend/database/backup.ps1` | Same treatment for the superuser password |
| `backend/database/DEPLOYMENT.md` | `CREATE ROLE` passwords and the `.env` example replaced with placeholders |
| `backend/database/seeders/NexaBootstrapSeeder.php` | Password now comes from `NEXATRACE_BOOTSTRAP_ADMIN_PASSWORD` and **throws if unset**. Safe: `deploy.yml` only runs `CricketFeatureRegistrySeeder`, so this cannot break a deploy |
| Both factory login screens | Pre-filled credentials **removed** |
| `NEXATRACE_SUPREME_MASTER_SPEC.md` §8.6 | Password column replaced with a pointer |
| `.gitleaks.toml` + `.github/workflows/secret-scan.yml` | New working-tree secret scan (see §5) |

**⚠️ The PowerShell changes are untested** (no Windows runner here). Before the next database
deploy or backup, run the script once on a scratch container and confirm it either works with
the env vars set or **fails with the "missing required password" message** when they are not.

---

## 3. YOUR TASKS — server-side, in this order

Run these on the Hetzner server (`135.181.46.27`, `ubuntu-16gb-hel1-2`).
**Do not skip step 3.1 — it is how you find out whether this is theoretical or live.**

### 3.1 Check whether the database is exposed to the internet (DO THIS FIRST)

```bash
# (a) Is PostgreSQL listening on a public interface?
ss -tlnp | grep 5444

# (b) Where is pg_hba.conf, and what are the ACTIVE rules?
sudo -u postgres psql -t -c "SHOW hba_file;"
sudo grep -vE '^\s*#|^\s*$' /etc/postgresql/*/main/pg_hba.conf
```

**You are looking for lines ending in `0.0.0.0/0` or `::/0`:**

```
host   all   all   0.0.0.0/0   md5        <-- EXPOSED to the whole internet
host   all   all   ::/0        md5        <-- EXPOSED
```

If either is present **and** the port is reachable, the database is open to the internet right
now. Also check the **Hetzner Cloud Firewall** in the Hetzner console for a rule allowing port
5444 — that is the layer that matters most.

### 3.2 Close the exposure

```bash
# Firewall (second layer — fix the Hetzner Cloud Firewall in the console as the first layer)
sudo ufw deny 5444/tcp
sudo ufw status verbose

# pg_hba.conf — back it up, then restrict to localhost only
sudo cp /etc/postgresql/*/main/pg_hba.conf /etc/postgresql/pg_hba.conf.bak-phase0a
sudo nano /etc/postgresql/*/main/pg_hba.conf
```

Change every `0.0.0.0/0` line to Localhost, and prefer `scram-sha-256` over `md5`:

```
host   all   all   127.0.0.1/32   scram-sha-256
host   all   all   ::1/128        scram-sha-256
```

```bash
sudo systemctl reload postgresql
```

> If the Laravel app runs on a **different** host than the database, that host's IP must be
> listed explicitly — never `0.0.0.0/0`.

### 3.3 Rotate the database passwords

Generate four new strong passwords (different from each other) in your password manager first.

```bash
sudo -u postgres psql
```

```sql
ALTER ROLE postgres          WITH PASSWORD '<new-1>';
ALTER ROLE nexa_app          WITH PASSWORD '<new-2>';
ALTER ROLE nexa_readonly     WITH PASSWORD '<new-3>';
ALTER ROLE nexa_superadmin   WITH PASSWORD '<new-4>';
\q
```

### 3.4 Update the app on the server — or the app breaks

`nexa_app`'s password changed in step 3.3, so the Laravel `.env` must match **immediately**.

```bash
cd /var/www/traceodd/admin-panel     # or /var/www/nexatrace/admin-panel — use whichever exists
nano .env                            # set DB_PASSWORD=<new-2>

php artisan config:clear
php artisan optimize:clear
php artisan optimize

# Verify the app can still reach the database:
php artisan db:monitor --databases=pgsql
```

If the app is still down after this, check `storage/logs/laravel.log` for
`password authentication failed for user "nexa_app"`.

### 3.5 Rotate the SSH root password (and ideally stop using passwords at all)

```bash
passwd root
```

**Recommended instead — key-only SSH:**

1. Add your public key to `/root/.ssh/authorized_keys`.
2. **Open a SECOND terminal and confirm key login works before you change anything.**
3. Then set `PermitRootLogin prohibit-password` in `/etc/ssh/sshd_config`.
4. `sudo systemctl reload ssh`.

Locking yourself out of the server is a worse outcome than the leak — hence step 2.

### 3.6 Rotate the panel admin logins

> ⚠️ **CORRECTION (2026-09-26) — this section originally missed the table that actually matters.**
> The `admin.traceodd.com` login runs `AdminAuthController@login`, which authenticates against
> **`admin_users`** (`config/auth.php`: guard `admin` → provider `admin_users` → `App\Models\AdminUser`).
> `postgres`/`global_identities`/`tenant_accounts` are **different** logins. If you rotated only those,
> **the public Super Admin login was left unchanged.**
>
> There is **no self-service reset**: the login screen's *Forgot Password?* link is a placeholder —
> `lib/features/nexa_admin/presentation/screens/super_admin/login_screen.dart:360` carries
> `// TODO: Implement forgot password flow` and only shows *"Please contact the system administrator to
> reset your password."* So an operator must set it.

The Super Admin, **Master Admin** and **all sub-admins** had publicly readable passwords. Three separate
concerns:

**A. Fixing the seeders does NOT change existing accounts.** The rows already in the database keep
their old passwords. Removing a constant from code is hygiene; the accounts still need rotating.

**B. Two different tables hold the login**, and they must stay in sync:

| Table | Column | How it is written |
|---|---|---|
| `global_identities` | `password_hash` | `Hash::make($plain)` — the model has a `setPasswordAttribute` mutator |
| `tenant_accounts` | `password` | **stores the already-hashed string as-is** (no mutator — the seeder passes `$identity->password_hash`) |

So always write **the same hash** to both.

**Procedure — do not skip step 0.**

```bash
cd /var/www/traceodd/admin-panel

# ── STEP 0: full database backup (this is what makes the rest reversible) ──
sudo -u postgres pg_dump nexasystem_db > ~/nexasystem_db-backup-$(date +%F-%H%M).sql
ls -lh ~/nexasystem_db-backup-*.sql | tail -1

# ── STEP 1: see which records exist (no passwords shown) ──
sudo -u postgres psql -d nexasystem_db -c "SELECT identity_type, display_name, id FROM global_identities WHERE identity_type IN ('admin','sub_admin') ORDER BY 1,2;"
sudo -u postgres psql -d nexasystem_db -c "SELECT id, account_type, email, (global_identity_id IS NOT NULL) AS has_spine FROM tenant_accounts WHERE account_type IN ('master_admin','sub_admin') ORDER BY 2;"
sudo -u postgres psql -d nexasystem_db -c "SELECT count(*) AS admin_users_rows FROM admin_users;"
```

> If `admin_users_rows` is greater than 0, tell the developer before continuing — that table is a
> **separate** login path (`AdminAuthController`, the `admin` guard) and would need the same treatment.

```bash
# ── STEP 2: rotate, with a hash backup written first ──
cat > /var/www/traceodd/admin-panel/rotate-pw.php <<'PHP'
<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

// Alphabet deliberately excludes # $ " ' ` \ space and look-alike characters (0/O, 1/l/I).
// A '#' in a secret is what broke the .env load — do not reintroduce one.
$alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789-_!@%^*+';
$gen = function (int $len = 24) use ($alphabet): string {
    $s = '';
    for ($i = 0; $i < $len; $i++) { $s .= $alphabet[random_int(0, strlen($alphabet) - 1)]; }
    return $s;
};

$stamp = date('Ymd-His');
$rows  = DB::table('global_identities')
    ->select('id','identity_type','display_name','password_hash')
    ->whereIn('identity_type', ['admin','sub_admin'])->get();

file_put_contents("/tmp/pw-backup-$stamp.json", json_encode($rows, JSON_PRETTY_PRINT));
echo "hash backup written to /tmp/pw-backup-$stamp.json\n\n";

foreach ($rows as $r) {
    $new  = $gen();
    $hash = Hash::make($new);          // ONE hash, written to BOTH tables
    DB::table('global_identities')->where('id', $r->id)->update(['password_hash' => $hash]);
    $n = DB::table('tenant_accounts')->where('global_identity_id', $r->id)->update(['password' => $hash]);
    printf("%-10s %-22s %s   (tenant rows: %d)\n", $r->identity_type, $r->display_name, $new, $n);
}
echo "\nStore these in the password manager, then delete this script.\n";
PHP

sudo -u www-data php rotate-pw.php
rm -f rotate-pw.php          # never leave a password-rotating script on the server
```

```bash
# ── STEP 3: verify by logging in via the app UI ──
#   master admin: admin@nexatrace.com
#   sub-admins:   bus.admin@ / goods.admin@ / market.admin@ / finance.admin@nexatrace.com
# If a login fails, restore before investigating:

# ── STEP 4: restore (only if needed) ──
cat > /tmp/restore-pw.php <<'PHP'
<?php
require '/var/www/traceodd/admin-panel/vendor/autoload.php';
$app = require_once '/var/www/traceodd/admin-panel/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
use Illuminate\Support\Facades\DB;
$rows = json_decode(file_get_contents($argv[1]), true);
foreach ($rows as $r) {
    DB::table('global_identities')->where('id', $r['id'])->update(['password_hash' => $r['password_hash']]);
    DB::table('tenant_accounts')->where('global_identity_id', $r['id'])->update(['password' => $r['password_hash']]);
    echo "restored {$r['display_name']}\n";
}
PHP
# sudo -u www-data php /tmp/restore-pw.php /tmp/pw-backup-<STAMP>.json
```

**Re-running the seeders later:** they now require env vars and will **throw** without them:

```env
NEXATRACE_BOOTSTRAP_ADMIN_PASSWORD='…'   # NexaBootstrapSeeder
NEXATRACE_MASTER_ADMIN_PASSWORD='…'      # MasterAdminSeeder
NEXATRACE_SUBADMIN_PASSWORD='…'          # SubAdminSeeder
```

Note `deploy.yml` runs only `CricketFeatureRegistrySeeder`, so none of these run automatically — they
are manual, one-off bootstrap seeders.

**Minor inconsistency noticed:** sub-admin emails use `@nexatrace.com` while other seeders use
`@nexatrace.local`. Two admin domains is confusing; worth unifying in a later pass.

### 3.6.1 Super Admin (`admin_users`) — setting the password safely

**This is the login at `https://admin.traceodd.com/login`.** Use this when the password is unknown or
needs rotating, and the requirement is that the value **never appears in any chat, ticket, or shell
history**.

The method below reads the password from a **hidden terminal prompt** and hashes it through the model's
own mutator. The value therefore never reaches: this repository, a chat message, `argv` (visible in
`ps`), bash history, psysh history, or a script left on disk.

**Step 1 — find the account** (no passwords are shown):

```bash
sudo -u postgres psql -d nexasystem_db -c \
  "SELECT id, email, name, role, status, force_password_change FROM admin_users ORDER BY email;"
```

**Step 2 — create the helper script** (`cat` with a quoted heredoc, so nothing is interpolated):

```bash
cd /var/www/traceodd/admin-panel
cat > reset-admin-pw.php <<'PHP'
<?php
// Set ONE admin_users password, entered WITHOUT echo.
// The value never appears in argv, shell history, psysh history, or any chat.
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

**Step 3 — run it and type the password at the prompt** (it will not be echoed):

```bash
sudo -u www-data php reset-admin-pw.php <the-email-from-step-1>
```

> If `stty` complains about no terminal, run it without `sudo` (as root) — the database connection
does not depend on the OS user.

**Step 4 — verify, then remove the script:**

```bash
# log in at https://admin.traceodd.com/login
rm -f reset-admin-pw.php
```

**Notes**

- `AdminUser` has a `setPasswordAttribute` mutator that calls `Hash::make`, so **assign the plaintext** —
do **not** hash it in the script.
- `force_password_change` is cleared, so the *"needs password change"* prompt will not reappear.
- **There is no self-service reset.** The login screen's *Forgot Password?* link is a placeholder
(`login_screen.dart:360`, `// TODO: Implement forgot password flow`). Implementing a real flow would
need a mail/token path — out of scope for Phase 0a.
- The API alternative exists — `POST /api/v1/admin/change-password` with `current_password` — but it
obviously requires knowing the current password, so it cannot recover a lost one.
- **Do not** paste the password into a chat, ticket, or commit, and do not leave the script on the
server after use.

### 3.7 Verify from outside

From Windows PowerShell on your own machine — this must **fail**:

```powershell
Test-NetConnection 135.181.46.27 -Port 5444
# TcpTestSucceeded : False
```

And confirm the app still works end-to-end (log in, load a dashboard).

### 3.8 Record the date

Note the rotation date in your own records. Anything that logged into the database before that
date with those credentials cannot be distinguished from legitimate traffic — knowing the date
is what defines the exposure window.

### 3.9 ⚠️ After rotating, Laravel may keep using a DIFFERENT password

This is the most likely thing to derail the rotation above — it is worth reading **before** you change
anything, so you recognise it immediately.

**Symptom:** `DB_PASSWORD` in `.env` is updated, PostgreSQL accepts the new password, but
`php artisan db:show` (or the app) still fails with `password authentication failed`, and
`config('database.connections.pgsql.password')` shows a value that is **neither the old nor the new**
one.

**Why:** `config/database.php` is a plain `env('DB_PASSWORD', '')` — verified in the repo, there is
**no hardcoded fallback**. So a third value can only come from Laravel's resolution order:

| # | Source | Effect |
|---|---|---|
| 1 | `bootstrap/cache/config.php` (**config cache**) | `config()` returns the **frozen** array and `env('DB_PASSWORD')` returns null — `.env` is ignored |
| 2 | A real **process/OS environment variable** `DB_PASSWORD` | Dotenv does **not** overwrite variables that already exist in the process, so this wins over `.env` |
| 3 | **`.env.production`** | Loaded instead of `.env` when `APP_ENV` is present in the process environment. Note `.env.example` ships with `APP_ENV=production`, and `.gitignore` lists `.env.production` — so this file is expected to exist on the server |
| 4 | `.env` | The intended source |

Relevant: `deploy.yml` runs `php artisan optimize`, which **caches the config**. So after every deploy
the configuration is frozen until it is cleared.

**Diagnose — no password value is ever printed:**

```bash
# 1. Is the config cached?  (do this FIRST — it is the usual answer)
ls -la bootstrap/cache/config.php
php artisan about                       # look for the Cache section: CACHED / NOT CACHED

# 2. Which env file did Laravel actually load?
php artisan tinker --execute="echo app()->environmentFile(), PHP_EOL;"
ls -la .env .env.production .env.backup 2>/dev/null

# 3. Is DB_PASSWORD set in the process environment (which overrides .env)?
php -r 'foreach(["DB_PASSWORD","DB_USERNAME","DB_HOST","DB_DATABASE","APP_ENV"] as $k){$v=getenv($k);printf("%-12s %s\n",$k,($v===false?"NOT SET":(strlen($v)." chars, fingerprint ".substr(hash("sha256",$v),0,12))));}'

# 4. Compare .env's value with what Laravel resolved — by fingerprint, never by value
sed -n 's/^DB_PASSWORD=//p' .env | head -1 | tr -d '\r' | sed 's/^"//;s/"$//' | sha256sum
php artisan tinker --execute="echo hash('sha256',(string)config('database.connections.pgsql.password')),PHP_EOL;"

# 5. Which files define it?  (-l prints NAMES ONLY — never the value)
grep -rl DB_PASSWORD /etc/environment /etc/profile /etc/profile.d/ /root/.bashrc /root/.profile 2>/dev/null
grep -rl DB_PASSWORD /etc/systemd/system/ /lib/systemd/system/ /etc/supervisor/ 2>/dev/null

# 6. Is the .env value even correct in PostgreSQL?
PGPASSWORD="$(sed -n 's/^DB_PASSWORD=//p' .env | head -1 | tr -d '\r' | sed 's/^"//;s/"$//')" \
  psql -w -h 127.0.0.1 -U postgres -d nexasystem_db -c 'select current_user;'

# 7. Does psql actually NEED a password?  (a plain success does not prove the password is right)
env -u PGPASSWORD psql -w -h 127.0.0.1 -U postgres -d nexasystem_db -c 'select 1'
ls -la /root/.pgpass 2>/dev/null
```

> **`psql` succeeding proves nothing on its own.** If `pg_hba.conf` uses `trust` for that host, or a
> `/root/.pgpass` file exists, psql connects without your new password ever being checked. Step 7 is
> how you tell the difference.

**Fix per cause:**

| Cause | Fix |
|---|---|
| Config cache | `php artisan optimize:clear` |
| Process env var | Remove it where it is defined, then re-login (`exec bash -l`) so the stale value leaves the shell |
| `.env.production` | Update that file too, or stop it being loaded |
| CRLF (a `.env` edited on Windows) | `sed -i 's/\r$//' .env` |
| Quotes / `$` in the value | Wrap in single quotes — `$` is interpolated inside double quotes |

**Rule for the future:** after **any** `.env` change, run
`php artisan optimize:clear && php artisan optimize`.

---

### 3.9.1 CONFIRMED root cause and fix (live incident, 2026-09-25)

This section was written as a prediction; it then reproduced **exactly** on the production server. Recording
the confirmed version here.

**Root cause: the `DB_PASSWORD` value contained a `#` character and was **unquoted** in `.env`.**
phpdotenv treats an unquoted `#` as the start of a comment, so it **truncated the password** before
Laravel ever saw it. PostgreSQL held the full value; Laravel sent a shortened one — hence
`password authentication failed` for a password that "was neither the old nor the new".

**Evidence that proved it (no value ever printed):**

| Test | Result | Meaning |
|---|---|---|
| `has-#:YES` on the `.env` line | `#` present, unquoted | the trigger |
| `config(...password)` fingerprint vs `.env` fingerprint | **differed** | Laravel was not using the `.env` value |
| config cache present? | **absent**, `Config: NOT CACHED` | ruled out |
| process env `DB_PASSWORD`? | **NOT SET** | ruled out |
| `.env.production`? | **file does not exist** | ruled out |
| `psql` with the FULL value | **LOGIN OK** | the DB password is the full value |
| `psql` with `-w` and no `PGPASSWORD` | `no password supplied` | `trust` ruled out — a password really is required |

**The fix that worked:**

```bash
cd /var/www/traceodd/admin-panel
grep -c "^DB_PASSWORD=.*'" .env                     # must be 0 (no quote already present)
sed -i "s/^DB_PASSWORD=\([^']*\)$/DB_PASSWORD='\1'/" .env    # wrap in SINGLE quotes
php artisan optimize:clear
php artisan db:show                                  # verified: 150 tables listed
```

**Two general rules this produced:**

1. **Quote every secret in `.env`** — `DB_PASSWORD='…'`. Single quotes keep `#` and `$` literal;
double quotes still interpolate `$`. Unquoted values break on `#`, `$`, spaces, quotes and `\`.
2. **Prefer passwords without shell/env-hostile characters.** Safe alphabet:
`A–Z a–z 0–9` plus `- _ . ~ ! @ % ^ * +`. A `#` in a secret is a landmine in `.env`, shell,
`systemd EnvironmentFile` and Docker `env_file` alike.

---

### 3.10 Other findings from the same live investigation

Found while diagnosing the above, on the production server. Independent of the password issue.

| # | Finding | Impact | Fix |
|---|---|---|---|
| 1 | **`Debug Mode … ENABLED` while `Environment: production`** | Any error response leaks stack traces, file paths and environment values to the caller | `APP_DEBUG=false` in `.env`, then `php artisan optimize:clear`. **Do this now.** |
| 2 | **`intl` PHP extension missing** — `php artisan db:show` dies in `Number.php:443` | Number/currency formatting and parts of localisation fail | `apt install php8.3-intl && systemctl reload php8.3-fpm && php -m \| grep intl` |
| 3 | **`bootstrap/cache/config.php` owned by `root`** (created by running `php artisan optimize` as root) | The web app runs as `www-data`; a later `optimize:clear`/`optimize` from the app user can fail with *permission denied* | `chown -R www-data:www-data bootstrap/cache storage`, and run artisan as the app user: `sudo -u www-data php artisan …` |
| 4 | **`.env` mode `644` (world-readable)** | Any local user can read the DB password | `chmod 640 .env && chown www-data:www-data .env` |
| 5 | **A stray `md5` line in `pg_hba.conf`** (`host all all 127.0.0.1/32 md5`, after the `scram-sha-256` lines) | Dead today (first match wins) but deprecated and confusing | Delete the line, reload PostgreSQL |
| 6 | **Server code drifts from the repo** — `NexaBootstrapSeeder.php` on the server contains `'contact_person_email' => 'factory-adminnexatrace.local'` (missing `@`), but the repo has it correct | The deployed code is not identical to the repo; the seeder fixes committed on 2026-09-25 are **not** on the server yet | Re-deploy, then verify the file matches |

---

## 4. After rotation — flip super-admin enforcement

`super_admin.php` currently uses `super.admin.shadow`, which **logs but does not deny** unless
`SUPER_ADMIN_GATE_ENFORCE` is truthy (plan §7b.4).

1. Read the `super_admin_gate.shadow` log lines.
2. Confirm your own admin account appears as **authorised**.
3. Set `SUPER_ADMIN_GATE_ENFORCE=true` in the server `.env`.
4. `php artisan config:clear && php artisan optimize`

Only then are the platform-admin endpoints actually protected.

---

## 5. The new secret scan — how to read it, and how to make it a real gate

The scan is `.github/workflows/secret-scan.yml`, configured by `.gitleaks.toml`.

**It scans the working tree only (`--no-git`), not git history** — on purpose. History still
contains the credentials removed this cycle, so a history scan would be red forever for no
useful reason. Once §3 is complete, history scanning can be switched on (with an allowlist
entry for the old commits).

**⚠️ It currently runs with `continue-on-error: true`,** so it reports without blocking. That is
deliberate: it is a new workflow that could not be verified before its first run.

**To make it a hard gate:**

1. Open the Actions tab and look at the first `Secret scan (working tree)` run.
2. Confirm it reports **0 leaks**. If it reports a false positive, add a *narrow, commented*
   entry to `.gitleaks.toml` — never a broad `lib/**` or `backend/**` allowlist.
3. Once it is green, delete `continue-on-error: true` from the workflow.
4. Add a `main`-branch protection rule requiring this check to pass.

---

## 6. Do NOT

- Do **not** re-commit any of the removed values, even in an example or a comment.
- Do **not** open port 5444 to `0.0.0.0/0` again for convenience.
- Do **not** assume deleting a file removes a secret — git history is permanent, and the
  repository has a remote. Assume it is public.
- Do **not** skip §3.4 — rotating the DB password without updating `.env` takes the app down.

---

## 7. Provenance

| Date | Change |
|---|---|
| 2026-09-25 | Created. Six additional in-repo credential locations found and fixed. Working-tree gitleaks scan added. Server-side steps written for the owner. |
