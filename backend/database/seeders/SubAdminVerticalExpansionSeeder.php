<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Group-Incharge expansion (C1) — the verticals for groups that had no incharge, plus
 * `financial_auditor`'s plans/** + billing/** ownership.
 *
 * ADDITIVE ONLY — the same contract as CricketFeatureRegistrySeeder: it inserts/updates rows in
 *   - sub_admin_verticals
 *   - feature_registry
 * and never deletes anything.
 *
 * IDEMPOTENT and ORDER-INDEPENDENT:
 *   * verticals and features are upserted on their unique `code`;
 *   * financial_auditor's bundle is UNIONED, never replaced — so re-running this, or running it before
 *     or after FeatureRegistrySeeder, cannot lose a code.
 *
 * Design + rationale: docs/handoff/MASTER-TASK-LIST.md section 2b (C0).
 */
class SubAdminVerticalExpansionSeeder extends Seeder
{
    /**
     * Verticals for the groups that had no incharge (C0 section 2b.1).
     *
     * `factory` is a real vertical — Group 3's admin panel already exists; only its incharge was missing.
     * `vehicle_security` / `trust_safety` are deliberate STUBS: Group 7 (#24) and Group 8 (#25) have no
     * panel yet, so the vertical exists (the incharge is created with the rest) but it grants nothing.
     */
    private const NEW_VERTICALS = [
        [
            'code'         => 'factory',
            'display_name' => 'Sub-Admin 6 — Factory',
            'bundle'       => ['factory.admin.*', 'factory.registry.*'],
        ],
        [
            'code'         => 'vehicle_security',
            'display_name' => 'Sub-Admin 7 — Vehicle Security (IoT)',
            'bundle'       => [],
        ],
        [
            'code'         => 'trust_safety',
            'display_name' => 'Sub-Admin 8 — Trust & Safety',
            'bundle'       => [],
        ],
    ];

    /**
     * Codes added to `financial_auditor`'s bundle — its plans/** + billing/** ownership (C0 section 2b.3).
     * Plan *CRUD* is already covered by the existing `subscription.manage` code, so this adds the
     * pricing + billing areas only, without duplicating it.
     */
    private const FINANCIAL_BUNDLE_ADDITIONS = [
        'plans.*',
        'billing.*',
    ];

    public function run(): void
    {
        $this->seedNewVerticals();
        $this->expandFinancialAuditorBundle();
        $this->seedFeatures();
    }

    private function seedNewVerticals(): void
    {
        foreach (self::NEW_VERTICALS as $vertical) {
            DB::table('sub_admin_verticals')->upsert(
                [
                    'id'                           => (string) Str::uuid(),
                    'code'                         => $vertical['code'],
                    'display_name'                 => $vertical['display_name'],
                    'default_feature_bundle_codes' => json_encode($vertical['bundle']),
                    'created_at'                   => now(),
                    'updated_at'                   => now(),
                ],
                ['code'],
                ['display_name', 'default_feature_bundle_codes', 'updated_at']
            );

            $this->command?->info("  Vertical registered: {$vertical['code']}");
        }
    }

    /**
     * Union the plans/billing codes into financial_auditor's bundle.
     *
     * A union — not a replace — because FeatureRegistrySeeder also writes this column; if a bare
     * FeatureRegistrySeeder run ever follows this one, that run would otherwise drop the additions.
     */
    private function expandFinancialAuditorBundle(): void
    {
        $exists = DB::table('sub_admin_verticals')->where('code', 'financial_auditor')->exists();

        if (!$exists) {
            $this->command?->warn(
                '  financial_auditor vertical not found — run FeatureRegistrySeeder first. Skipped.'
            );
            return;
        }

        $current = DB::table('sub_admin_verticals')
            ->where('code', 'financial_auditor')
            ->value('default_feature_bundle_codes');

        $existing = is_string($current) ? json_decode($current, true) : $current;
        $existing = is_array($existing) ? $existing : [];

        $merged = array_values(array_unique(array_merge($existing, self::FINANCIAL_BUNDLE_ADDITIONS)));

        if ($merged === $existing) {
            $this->command?->info('  financial_auditor bundle already carries plans.* + billing.*');
            return;
        }

        DB::table('sub_admin_verticals')
            ->where('code', 'financial_auditor')
            ->update([
                'default_feature_bundle_codes' => json_encode($merged),
                'updated_at'                   => now(),
            ]);

        $this->command?->info('  financial_auditor bundle extended with plans.* + billing.*');
    }

    private function seedFeatures(): void
    {
        $factoryId = DB::table('sub_admin_verticals')->where('code', 'factory')->value('id');
        $finId     = DB::table('sub_admin_verticals')->where('code', 'financial_auditor')->value('id');
        $now       = now();

        $features = [
            // ═══ Sub-Admin 6 — Factory (Group 3) ═══════════════════════════════
            [
                'code'                => 'factory.admin.provision',
                'module_name'         => 'Factory Admin Provisioning',
                'vertical_default_id' => $factoryId,
                'description'         => "Create, approve and suspend a factory's admin account (Group-Incharge model)",
                'severity'            => 'elevated',
                'is_active'           => true,
            ],
            [
                'code'                => 'factory.registry.view',
                'module_name'         => 'Factory Registry (read-only)',
                'vertical_default_id' => $factoryId,
                'description'         => 'Read the factory registry and company profiles for the group',
                'is_active'           => true,
            ],

            // ═══ Sub-Admin 4 — Financial & Subscription Auditor: plans + billing (C0 section 2b.3) ═══
            [
                'code'                => 'plans.pricing.manage',
                'module_name'         => 'Plan Pricing Manager',
                'vertical_default_id' => $finId,
                'description'         => 'Set and change subscription plan pricing for every group',
                'severity'            => 'critical',
                'is_destructive'      => true,
                'is_active'           => true,
            ],
            [
                'code'                => 'billing.invoices.manage',
                'module_name'         => 'Invoice Manager (all groups)',
                'vertical_default_id' => $finId,
                'description'         => "Create, issue and update invoices for every group's users",
                'severity'            => 'elevated',
                'is_active'           => true,
            ],
            [
                'code'                => 'billing.payments.manage',
                'module_name'         => 'Billing Payment Manager',
                'vertical_default_id' => $finId,
                'description'         => 'Record and reconcile payments against invoices',
                'severity'            => 'elevated',
                'is_active'           => true,
            ],
            [
                'code'                => 'billing.refunds.manage',
                'module_name'         => 'Refund Manager',
                'vertical_default_id' => $finId,
                'description'         => 'Approve and process refunds across every group',
                'severity'            => 'critical',
                'is_destructive'      => true,
                'is_active'           => true,
            ],
        ];

        foreach ($features as $feature) {
            DB::table('feature_registry')->upsert(
                array_merge($feature, ['created_at' => $now, 'updated_at' => $now]),
                ['code'],
                ['module_name', 'description', 'severity', 'is_destructive', 'vertical_default_id', 'is_active', 'updated_at']
            );
        }

        $registered = DB::table('feature_registry')
            ->whereIn('code', array_column($features, 'code'))
            ->count();

        $this->command?->info("  Expansion features registered: {$registered} feature codes.");
    }
}
