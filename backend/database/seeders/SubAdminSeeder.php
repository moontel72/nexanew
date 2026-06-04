<?php

namespace Database\Seeders;

use App\Models\GlobalIdentity;
use App\Models\IdentityClaim;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Wave 2 — Quad Sub-Admin Bootstrap Seeder
 *
 * Per Section 10.2.1 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
 * Seeds exactly four sub-admin vertical identities with credentials
 * and assignments for instant testing deployment.
 *
 * Verticals:
 *   bus_transit            — Bus Transit Manager
 *   goods_logistics        — Goods & Logistics Manager
 *   commercial_marketplace — Commercial Marketplace Manager
 *   financial_auditor      — Financial & Subscription Auditor
 *
 * Each profile gets:
 *   - A GlobalIdentity with identity_type='sub_admin'
 *   - Email + phone identity claims
 *   - A sub_admin_assignments row linking to their vertical
 *   - A TenantAccount bridge for Sanctum token login
 *
 * Default password for all sub-admins: SubAdmin@2026!
 */
class SubAdminSeeder extends Seeder
{
    private const DEFAULT_PASSWORD = 'SubAdmin@2026!';

    private const VERTICALS = [
        [
            'code'         => 'bus_transit',
            'name'         => 'Ahmed Khan',
            'email'        => 'bus.admin@nexatrace.com',
            'phone'        => '+923001111001',
        ],
        [
            'code'         => 'goods_logistics',
            'name'         => 'Fatima Noor',
            'email'        => 'goods.admin@nexatrace.com',
            'phone'        => '+923001111002',
        ],
        [
            'code'         => 'commercial_marketplace',
            'name'         => 'Bilal Mahmood',
            'email'        => 'market.admin@nexatrace.com',
            'phone'        => '+923001111003',
        ],
        [
            'code'         => 'financial_auditor',
            'name'         => 'Zainab Ali',
            'email'        => 'finance.admin@nexatrace.com',
            'phone'        => '+923001111004',
        ],
    ];

    public function run(): void
    {
        $this->command?->info('Bootstrapping Sub-Admin identities...');

        foreach (self::VERTICALS as $v) {
            $this->seedSubAdmin($v['code'], $v['name'], $v['email'], $v['phone']);
        }

        $count = DB::table('global_identities')->where('identity_type', 'sub_admin')->count();
        $this->command?->info("Sub-Admin bootstrap complete. {$count} identities seeded.");
    }

    private function seedSubAdmin(string $verticalCode, string $name, string $email, string $phone): void
    {
        // 1. Create or find GlobalIdentity
        $identity = GlobalIdentity::where('identity_type', 'sub_admin')
            ->where('display_name', $name)
            ->first();

        if (!$identity) {
            $identity = GlobalIdentity::create([
                'identity_token' => GlobalIdentity::generateToken('sub_admin'),
                'display_name'   => $name,
                'password'       => self::DEFAULT_PASSWORD,
                'identity_type'  => 'sub_admin',
                'kyc_status'     => 'verified',
                'kyc_tier'       => 2,
                'status'         => 'active',
                'primary_locale' => 'en-PK',
            ]);
            $this->command?->info("  Created {$name}: {$identity->identity_token}");
        } else {
            $this->command?->info("  {$name} already exists: {$identity->identity_token}");
        }

        // 2. Seed identity claims (email + phone)
        $this->seedClaim($identity, 'email', $email, true);
        $this->seedClaim($identity, 'phone', $phone, false);

        // 3. Create sub-admin assignment
        $vertical = DB::table('sub_admin_verticals')->where('code', $verticalCode)->first();
        if ($vertical) {
            $assignmentExists = DB::table('sub_admin_assignments')
                ->where('global_identity_id', $identity->id)
                ->where('vertical_id', $vertical->id)
                ->whereNull('revoked_at')
                ->exists();

            if (!$assignmentExists) {
                // Find master admin to record as appointer
                $masterId = DB::table('global_identities')
                    ->where('identity_type', 'admin')
                    ->value('id');

                DB::table('sub_admin_assignments')->insert([
                    'id'                              => (string) Str::orderedUuid(),
                    'global_identity_id'              => $identity->id,
                    'vertical_id'                     => $vertical->id,
                    'appointed_by_master_admin_id'    => $masterId ?? $identity->id,
                    'appointed_at'                    => now(),
                    'created_at'                      => now(),
                    'updated_at'                      => now(),
                ]);
                $this->command?->info("    → Assigned to vertical: {$vertical->code}");
            }
        }

        // 4. Create TenantAccount bridge (needed for Sanctum token login)
        $tenantExists = DB::table('tenant_accounts')
            ->where('email', $email)
            ->exists();

        if (!$tenantExists) {
            DB::table('tenant_accounts')->insert([
                'id'                  => (string) Str::orderedUuid(),
                'global_identity_id'  => $identity->id,
                'account_name'        => $name,
                'email'               => $email,
                'password'            => $identity->password_hash,
                'phone_number'        => $phone,
                'is_independent'      => true,
                'account_type'        => 'sub_admin',
                'status'              => 'active',
                'created_at'          => now(),
                'updated_at'          => now(),
            ]);
            $this->command?->info("    → TenantAccount bridge created");
        }
    }

    private function seedClaim(GlobalIdentity $identity, string $type, string $value, bool $primary): void
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
}
