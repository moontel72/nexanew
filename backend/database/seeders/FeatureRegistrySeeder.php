<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class FeatureRegistrySeeder extends Seeder
{
    /**
     * Wave 1 — Baseline Feature Registry Seeding
     *
     * Seeds the 4 immutable verticals and 30+ feature codes
     * into feature_registry per Section 10.2.1.
     *
     * Uses upsert() for idempotent re-runs.
     */
    public function run(): void
    {
        $this->seedVerticals();
        $this->seedFeatures();
    }

    private function seedVerticals(): void
    {
        $verticals = [
            [
                'code'                         => 'bus_transit',
                'display_name'                 => 'Sub-Admin 1 — Bus Transit',
                'default_feature_bundle_codes' => json_encode(['bus.routes.*', 'bus.layouts.*', 'bus.ticketing.*', 'bus.fleet.*']),
            ],
            [
                'code'                         => 'goods_logistics',
                'display_name'                 => 'Sub-Admin 2 — Goods & Logistics',
                'default_feature_bundle_codes' => json_encode(['truck.fleet.*', 'truck.dispatch.*', 'factory.driver.*', 'freight.auction.*']),
            ],
            [
                'code'                         => 'commercial_marketplace',
                'display_name'                 => 'Sub-Admin 3 — Commercial Marketplace',
                'default_feature_bundle_codes' => json_encode(['factory.*', 'reseller.*', 'shop.*', 'customer.*', 'marketplace.*']),
            ],
            [
                'code'                         => 'financial_auditor',
                'display_name'                 => 'Sub-Admin 4 — Financial & Subscription Auditor',
                'default_feature_bundle_codes' => json_encode(['finance.*', 'subscription.*', 'commission.*', 'penalty.*', 'identity.dispute.*']),
            ],
        ];

        foreach ($verticals as $v) {
            DB::table('sub_admin_verticals')->upsert(
                [
                    'id'                           => (string) Str::uuid(),
                    'code'                         => $v['code'],
                    'display_name'                 => $v['display_name'],
                    'default_feature_bundle_codes' => $v['default_feature_bundle_codes'],
                    'created_at'                   => now(),
                    'updated_at'                   => now(),
                ],
                ['code'],
                ['display_name', 'default_feature_bundle_codes', 'updated_at']
            );
        }
    }

    private function seedFeatures(): void
    {
        $verticalIds = DB::table('sub_admin_verticals')->pluck('id', 'code');
        $now  = now();
        $bus    = $verticalIds['bus_transit'] ?? null;
        $goods  = $verticalIds['goods_logistics'] ?? null;
        $market = $verticalIds['commercial_marketplace'] ?? null;
        $fin    = $verticalIds['financial_auditor'] ?? null;

        $features = [
            // ═══ Sub-Admin 1 — Bus Transit ═══════════════════════
            ['code' => 'bus.routes.manage',    'module_name' => 'Bus Route Manager',        'vertical_default_id' => $bus,    'description' => 'CRUD bus routes and waypoint schedules',                                         'is_active' => true, 'created_at' => $now],
            ['code' => 'bus.routes.publish',   'module_name' => 'Bus Route Publisher',      'vertical_default_id' => $bus,    'description' => 'Publish routes to live schedule',         'is_destructive' => true,  'is_active' => true, 'created_at' => $now],
            ['code' => 'bus.layouts.design',   'module_name' => 'Seat Layout Designer',     'vertical_default_id' => $bus,    'description' => 'Visual seat grid builder (14E)',                                             'is_active' => true, 'created_at' => $now],
            ['code' => 'bus.layouts.publish',  'module_name' => 'Seat Layout Publisher',    'vertical_default_id' => $bus,    'description' => 'Publish layout revisions to production',  'is_destructive' => true,  'is_active' => true, 'created_at' => $now],
            ['code' => 'bus.ticketing.manage', 'module_name' => 'Ticketing Manager',        'vertical_default_id' => $bus,    'description' => 'Manage ticket pricing, sales, and validation',                                 'is_active' => true, 'created_at' => $now],
            ['code' => 'bus.fleet.manage',     'module_name' => 'Bus Fleet Manager',         'vertical_default_id' => $bus,    'description' => 'Manage bus fleet vehicles and ownership',                                      'is_active' => true, 'created_at' => $now],
            ['code' => 'bus.fleet.telemetry',  'module_name' => 'Bus Telemetry Dashboard',  'vertical_default_id' => $bus,    'description' => 'Real-time GPS bus tracking (13C WebSocket)',                                   'is_active' => true, 'created_at' => $now],

            // ═══ Sub-Admin 2 — Goods & Logistics ════════════════
            ['code' => 'truck.fleet.manage',     'module_name' => 'Truck Fleet Manager',      'vertical_default_id' => $goods,  'description' => 'Manage truck fleet ownership and registration',                                'is_active' => true, 'created_at' => $now],
            ['code' => 'truck.fleet.telemetry',  'module_name' => 'Truck Telemetry Dashboard','vertical_default_id' => $goods,  'description' => 'Real-time GPS truck tracking (9H)',                                             'is_active' => true, 'created_at' => $now],
            ['code' => 'truck.dispatch.manage',  'module_name' => 'Dispatch Manager',         'vertical_default_id' => $goods,  'description' => 'Real-time load dispatch and assignment (9O)',                                   'is_active' => true, 'created_at' => $now],
            ['code' => 'truck.dispatch.route',   'module_name' => 'Route Optimizer',          'vertical_default_id' => $goods,  'description' => 'Intelligent multi-drop route optimization (9M)',                                'is_active' => true, 'created_at' => $now],
            ['code' => 'factory.driver.manage',  'module_name' => 'Factory Driver Management','vertical_default_id' => $goods,  'description' => 'Manage factory delivery driver fleet (3O)',                                     'is_active' => true, 'created_at' => $now],
            ['code' => 'freight.auction.manage', 'module_name' => 'Freight Auction Manager',  'vertical_default_id' => $goods,  'description' => 'Manage spot-freight auctions (9D)',                                             'is_active' => true, 'created_at' => $now],
            ['code' => 'freight.auction.monitor','module_name' => 'Auction Live Monitor',     'vertical_default_id' => $goods,  'description' => 'Live auction monitoring dashboard with bid streams',                           'is_active' => true, 'created_at' => $now],

            // ═══ Sub-Admin 3 — Commercial Marketplace ═══════════
            ['code' => 'factory.manage',         'module_name' => 'Factory Enterprise Manager', 'vertical_default_id' => $market, 'description' => 'Manage factory accounts and production workflows (3A)',                        'is_active' => true, 'created_at' => $now],
            ['code' => 'factory.billing',        'module_name' => 'Factory Billing Dashboard',  'vertical_default_id' => $market, 'description' => 'Factory pay-per-publish billing and invoicing (3AE-3AH)',                      'is_active' => true, 'created_at' => $now],
            ['code' => 'factory.codes.generate', 'module_name' => 'Code Generation Engine',     'vertical_default_id' => $market, 'description' => 'Bulk bundle/carton/packet/unit code generation (3B-3H)',      'severity' => 'elevated', 'is_active' => true, 'created_at' => $now],
            ['code' => 'reseller.manage',        'module_name' => 'Reseller Manager',           'vertical_default_id' => $market, 'description' => 'Manage reseller/wholesaler accounts (6A-6B)',                                   'is_active' => true, 'created_at' => $now],
            ['code' => 'reseller.orders',        'module_name' => 'Reseller Order Management',  'vertical_default_id' => $market, 'description' => 'B2B wholesale order processing (6N)',                                           'is_active' => true, 'created_at' => $now],
            ['code' => 'shop.manage',            'module_name' => 'Shop Keeper Manager',        'vertical_default_id' => $market, 'description' => 'Manage shop keeper accounts (7A)',                                              'is_active' => true, 'created_at' => $now],
            ['code' => 'customer.manage',        'module_name' => 'Customer Manager',           'vertical_default_id' => $market, 'description' => 'Manage customer accounts and loyalty (8D-8F)',                                  'is_active' => true, 'created_at' => $now],
            ['code' => 'marketplace.listings',   'module_name' => 'Marketplace Catalog',        'vertical_default_id' => $market, 'description' => 'Manage B2B product listings and storefronts (12A-12B)',                         'is_active' => true, 'created_at' => $now],
            ['code' => 'marketplace.escrow',     'module_name' => 'Escrow Disputes (Ops)',      'vertical_default_id' => $market, 'description' => 'Operational-tier escrow dispute resolution (12E)',     'severity' => 'elevated', 'is_active' => true, 'created_at' => $now],

            // ═══ Sub-Admin 4 — Financial & Subscription Auditor ══
            ['code' => 'finance.reconciliation',    'module_name' => 'Financial Reconciliation',   'vertical_default_id' => $fin, 'description' => 'Cross-vertical financial reconciliation reports (1J)',        'severity' => 'critical',  'is_active' => true, 'created_at' => $now],
            ['code' => 'finance.ledger.view',        'module_name' => 'Double-Entry Ledger Viewer', 'vertical_default_id' => $fin, 'description' => 'View all ledger entries across verticals (Step 8)',           'severity' => 'critical',  'is_active' => true, 'created_at' => $now],
            ['code' => 'subscription.manage',        'module_name' => 'Subscription Plan Manager',  'vertical_default_id' => $fin, 'description' => 'Create and modify subscription plans (Section 5)',                              'is_active' => true, 'created_at' => $now],
            ['code' => 'subscription.enforce',       'module_name' => 'Subscription Limit Enforcer','vertical_default_id' => $fin, 'description' => 'Enforce subscription limits and overage management (1I)',  'severity' => 'elevated',  'is_destructive' => true, 'is_active' => true, 'created_at' => $now],
            ['code' => 'commission.manage',          'module_name' => 'Commission Split Manager',   'vertical_default_id' => $fin, 'description' => 'Configure commission split rules (9G, 10.5)',               'severity' => 'critical',  'is_active' => true, 'created_at' => $now],
            ['code' => 'commission.dispute.review',  'module_name' => 'Commission Dispute Review',  'vertical_default_id' => $fin, 'description' => 'Review and resolve commission disputes',                    'severity' => 'elevated',  'is_active' => true, 'created_at' => $now],
            ['code' => 'penalty.manage',             'module_name' => 'Penalty Rule Manager',       'vertical_default_id' => $fin, 'description' => 'Manage penalty rules and Cup-of-Tea events (10.7)',         'severity' => 'elevated',  'is_active' => true, 'created_at' => $now],
            ['code' => 'identity.dispute.resolve',   'module_name' => 'Identity Dispute Resolution','vertical_default_id' => $fin, 'description' => 'Resolve identity claim disputes (10.1.6)',                  'severity' => 'critical',  'is_active' => true, 'created_at' => $now],

            // ═══ Cross-Cutting — Master Admin Only ═══════════════
            ['code' => 'master.subadmin.grant.manage', 'module_name' => 'Sub-Admin Grant Management', 'vertical_default_id' => null, 'description' => 'Grant, loan, or revoke Sub-Admin feature access (10.2.3)', 'severity' => 'critical', 'is_destructive' => true, 'is_active' => true, 'created_at' => $now],
            ['code' => 'master.audit.view',            'module_name' => 'Audit Log Viewer',           'vertical_default_id' => null, 'description' => 'View all 4 partitioned audit log streams (10.8)',           'severity' => 'critical', 'is_active' => true, 'created_at' => $now],
            ['code' => 'master.system.config',         'module_name' => 'System Configuration',       'vertical_default_id' => null, 'description' => 'Modify global system configuration parameters',            'severity' => 'critical', 'is_destructive' => true, 'is_active' => true, 'created_at' => $now],
        ];

        foreach ($features as $f) {
            DB::table('feature_registry')->upsert(
                array_merge($f, ['updated_at' => $now]),
                ['code'],
                ['module_name', 'description', 'severity', 'is_destructive', 'vertical_default_id', 'is_active', 'updated_at']
            );
        }
    }
}
