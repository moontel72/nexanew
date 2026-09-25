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

The Super Admin and Factory Admin passwords were publicly readable. Change both (via the admin
UI, or by re-seeding a fresh environment with `NEXATRACE_BOOTSTRAP_ADMIN_PASSWORD` set).

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
