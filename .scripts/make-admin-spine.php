<?php
/**
 * make-admin-spine.php — put an admin into the identity spine so the UNIFIED login works.
 *
 * WHY THIS EXISTS
 *   POST /api/v1/auth/login (GlobalAuthController) resolves an identifier through
 *   `identity_claims` -> `global_identities`. A row that exists only in `admin_users` is invisible to
 *   it, and the request fails at `claim_not_found` BEFORE the password is ever checked — a permanent
 *   401 that no password reset can fix. See docs/handoff/START-HERE.md §6.
 *
 * USAGE (on the server, inside the Laravel app directory)
 *   cp /path/to/make-admin-spine.php /var/www/traceodd/admin-panel/
 *   cd /var/www/traceodd/admin-panel
 *   sudo -u www-data php make-admin-spine.php <email>
 *   rm -f make-admin-spine.php          # do not leave it on the server
 *
 * DESIGN NOTES
 *   • Prints the LIVE column list for every table it touches first, so a schema mismatch between the
 *     migrations and the deployed database is visible instead of producing a silent failure.
 *   • Wraps each step in a `step()` guard that reports the real exception and continues, so a single
 *     missing/renamed column cannot abort the whole run.
 *   • Idempotent: re-running reuses the identity, skips existing claims/assignments and just resets the
 *     password.
 *   • Reads the password from a hidden prompt — it never reaches argv, shell history, psysh history, a
 *     chat, or a log.
 *   • Syncs `admin_users` too, so the legacy POST /api/v1/admin/login also works.
 *   • Ends with a verification block that mirrors GlobalAuthController@login exactly.
 */

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\GlobalIdentity;
use App\Models\IdentityClaim;
use App\Models\TenantAccount;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

$email = $argv[1] ?? null;
if (!$email) {
    fwrite(STDERR, "usage: php make-admin-spine.php <email>\n");
    exit(2);
}

// ── 0. Print the LIVE columns first, so a schema mismatch is visible ─────────
echo "--- live schema (a missing column is what makes the model fail below) ---\n";
foreach (['admin_users', 'global_identities', 'identity_claims', 'tenant_accounts', 'master_admin_assignments'] as $t) {
    if (!Schema::hasTable($t)) {
        echo "  !! MISSING TABLE: {$t}\n";
        continue;
    }
    echo "  {$t}: " . implode(', ', Schema::getColumnListing($t)) . "\n";
}
echo "\n";

/** Run a step, report its real error, and never let one failure abort the run. */
function step(string $label, callable $fn): void
{
    try {
        $fn();
        echo "OK   {$label}\n";
    } catch (\Throwable $e) {
        echo "FAIL {$label}\n     -> " . $e->getMessage() . "\n";
    }
}

// ── 1. Identity spine row ────────────────────────────────────────────────────
$identity = null;
step('global_identities: find-or-create the admin identity', function () use (&$identity) {
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
    }
});

if (!$identity) {
    fwrite(STDERR, "\nCannot continue: no admin identity could be created. Fix the FAIL above.\n");
    exit(1);
}
echo "     identity id = {$identity->id}\n";

// ── 2. Email claim — this is the lookup that was failing ─────────────────────
step('identity_claims: email claim', function () use ($identity, $email) {
    $normalized = IdentityClaim::normalize('email', $email);
    $exists = IdentityClaim::where('claim_type', 'email')
        ->where('claim_value', $normalized)
        ->where('is_revoked', false)
        ->exists();

    if (!$exists) {
        IdentityClaim::create([
            'global_identity_id' => $identity->id,
            'claim_type'         => 'email',
            'claim_value'        => $normalized,
            'is_primary'         => true,
            'verified_via'       => 'manual_kyc',
            'verified_at'        => now(),
        ]);
    }
});

// ── 3. Password (hidden prompt) ──────────────────────────────────────────────
function hidden(string $p): string
{
    echo $p;
    system('stty -echo');
    $v = rtrim((string) fgets(STDIN), "\r\n");
    system('stty echo');
    echo "\n";
    return $v;
}

$pw = hidden("Password for {$email} (typing hidden): ");
if (strlen($pw) < 12) {
    fwrite(STDERR, "Refusing: use at least 12 characters.\n");
    exit(1);
}
if ($pw !== hidden('Repeat: ')) {
    fwrite(STDERR, "Refusing: passwords did not match.\n");
    exit(1);
}

step('global_identities: set the password', function () use ($identity, $pw) {
    $identity->password = $pw;          // setPasswordAttribute -> password_hash
    $identity->save();
});

// ── 4. Super Admin rights ────────────────────────────────────────────────────
step('master_admin_assignments: grant', function () use ($identity) {
    $exists = DB::table('master_admin_assignments')
        ->where('global_identity_id', $identity->id)
        ->whereNull('revoked_at')
        ->exists();

    if (!$exists) {
        DB::table('master_admin_assignments')->insert([
            'id'                              => (string) Str::orderedUuid(),
            'global_identity_id'              => $identity->id,
            'appointed_by_global_identity_id' => $identity->id,
            'appointed_at'                    => now(),
            'created_at'                      => now(),
            'updated_at'                      => now(),
        ]);
    }
});

// ── 5. admin_users row — so the legacy /api/v1/admin/login works too ─────────
step('admin_users: sync the row', function () use ($identity, $email) {
    $row = DB::table('admin_users')->where('email', $email)->first();

    if ($row) {
        DB::table('admin_users')->where('id', $row->id)->update([
            'password' => $identity->password_hash,   // already hashed — never re-hash here
            'role'     => 'super_admin',
            'status'   => 'active',
        ]);
        return;
    }

    DB::table('admin_users')->insert([
        'id'       => (string) Str::orderedUuid(),
        'name'     => 'Trace Odd Super Admin',
        'email'    => $email,
        'password' => $identity->password_hash,
        'role'     => 'super_admin',
        'status'   => 'active',
    ]);
});

// ── 6. tenant_accounts bridge (optional — the sanctum 'tenant_accounts' provider) ──
step('tenant_accounts: bridge', function () use ($identity, $email) {
    $bridge = TenantAccount::where('global_identity_id', $identity->id)->first();

    if ($bridge) {
        $bridge->password = $identity->password_hash;
        $bridge->save();
        return;
    }

    TenantAccount::create([
        'account_name'       => 'Trace Odd Super Admin',
        'email'              => $email,
        'password'           => $identity->password_hash,
        'phone_number'       => '+920000000000',
        'global_identity_id' => $identity->id,
        'is_independent'     => true,
        'account_type'       => 'master_admin',
        'status'             => 'active',
    ]);
});

// ── 7. Verify exactly what the login endpoint will do ───────────────────────
echo "\n--- verification (mirrors GlobalAuthController@login) ---\n";
$normalized = IdentityClaim::normalize('email', $email);
$claim = IdentityClaim::where('claim_type', 'email')
    ->where('claim_value', $normalized)
    ->where('is_revoked', false)
    ->first();

echo '  claim found:  ' . ($claim ? 'YES' : 'NO') . "\n";
if ($claim) {
    $found = GlobalIdentity::find($claim->global_identity_id);
    echo '  identity:     ' . ($found ? "{$found->id} ({$found->identity_type}, {$found->status})" : 'MISSING') . "\n";
    echo '  password ok:  ' . (($found && $found->verifyPassword($pw)) ? 'YES' : 'NO') . "\n";
}
echo "\nLog in at https://admin.traceodd.com/login with {$email}\n";
echo "Then delete this script:  rm -f make-admin-spine.php\n";
