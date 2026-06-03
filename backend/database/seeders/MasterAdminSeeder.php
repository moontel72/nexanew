<?php

namespace Database\Seeders;

use App\Models\GlobalIdentity;
use App\Models\IdentityClaim;
use App\Models\TenantAccount;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Wave 2 — Master Admin & Sub-Admin Bootstrap Seeder (v2 — Defects Fixed)
 *
 * Per Section 10.12 Wave 2.
 *
 * Fixed:
 *   - Defect #4: Uses dedicated global_identity_id column
 *   - Defect #3: Uses Str::orderedUuid() for index locality
 *
 * Idempotent — skips if records already exist.
 */
class MasterAdminSeeder extends Seeder
{
    private const MASTER_ADMIN_EMAIL  = 'admin@nexatrace.com';
    private const MASTER_ADMIN_PHONE  = '+920000000000';
    private const MASTER_ADMIN_NAME   = 'Trace Odd Master Admin';
    private const MASTER_ADMIN_PASS   = 'NexaTrace@2026!Secure';

    public function run(): void
    {
        $this->command?->info('Bootstrapping Master Admin identity...');

        $identity = $this->createMasterIdentity();
        $this->createClaim($identity, 'phone', self::MASTER_ADMIN_PHONE, true);
        $this->createClaim($identity, 'email', self::MASTER_ADMIN_EMAIL, true);
        $this->createMasterAssignment($identity);
        $this->createTenantBridge($identity);
        $this->call(FeatureRegistrySeeder::class);

        $this->command?->info('Master Admin bootstrap complete.');
        $this->command?->info("  Email:    " . self::MASTER_ADMIN_EMAIL);
        $this->command?->info("  Password: " . self::MASTER_ADMIN_PASS);
        $this->command?->info("  Token:    " . $identity->identity_token);
    }

    private function createMasterIdentity(): GlobalIdentity
    {
        $identity = GlobalIdentity::where('identity_type', 'admin')->first();

        if (!$identity) {
            $identity = GlobalIdentity::create([
                'display_name'   => self::MASTER_ADMIN_NAME,
                'password'       => self::MASTER_ADMIN_PASS,
                'identity_type'  => 'admin',
                'kyc_status'     => 'verified',
                'kyc_tier'       => 3,
                'status'         => 'active',
                'primary_locale' => 'en-PK',
            ]);
            $this->command?->info("  Created Master Admin identity: {$identity->identity_token}");
        } else {
            $this->command?->info("  Master Admin identity already exists: {$identity->identity_token}");
        }

        return $identity;
    }

    private function createClaim(GlobalIdentity $identity, string $type, string $value, bool $primary): void
    {
        $normalized = IdentityClaim::normalize($type, $value);
        $existing = IdentityClaim::where('claim_type', $type)
            ->where('claim_value', $normalized)
            ->where('is_revoked', false)
            ->first();

        if (!$existing) {
            IdentityClaim::create([
                'global_identity_id' => $identity->id,
                'claim_type'         => $type,
                'claim_value'        => $normalized,
                'is_primary'         => $primary,
                'verified_via'       => 'manual_kyc',
                'verified_at'        => now(),
            ]);
        }
    }

    private function createMasterAssignment(GlobalIdentity $identity): void
    {
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
            $this->command?->info('  Created Master Admin assignment record.');
        }
    }

    private function createTenantBridge(GlobalIdentity $identity): void
    {
        $exists = TenantAccount::where('email', self::MASTER_ADMIN_EMAIL)->exists();

        if (!$exists) {
            TenantAccount::create([
                'account_name'        => self::MASTER_ADMIN_NAME,
                'email'               => self::MASTER_ADMIN_EMAIL,
                'password'            => $identity->password_hash,
                'phone_number'        => self::MASTER_ADMIN_PHONE,
                'global_identity_id'  => $identity->id,    // Defect #4 fix: dedicated column
                'is_independent'      => true,
                'account_type'        => 'master_admin',
                'status'              => 'active',
            ]);
        }
    }
}
