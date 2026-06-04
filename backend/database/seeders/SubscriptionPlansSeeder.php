<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Subscription Plans Baseline Seeder
 *
 * Populates subscription_plans with production-ready tier structures.
 * Idempotent — uses upsert() to skip duplicates.
 */
class SubscriptionPlansSeeder extends Seeder
{
    public function run(): void
    {
        $this->command?->info('Seeding subscription plans...');

        $plans = [
            [
                'name'                 => 'Starter',
                'type'                 => 'factory',
                'description'          => 'For small manufacturers. Basic code generation and 1 store keeper.',
                'monthly_price'        => 4999.00,
                'yearly_price'         => 49990.00,
                'setup_fee'            => 0,
                'currency'             => 'PKR',
                'monthly_unit_codes'   => 5000,
                'monthly_packet_codes' => 1000,
                'monthly_carton_codes' => 500,
                'monthly_bundle_codes' => 200,
                'max_users'            => 2,
                'max_stores'           => 1,
                'max_drivers'          => 2,
                'features'             => json_encode(['basic_codes', 'qr_scan', 'offline_mode']),
                'is_custom'            => false,
                'is_recommended'       => false,
                'status'               => 'active',
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'Enterprise',
                'type'                 => 'factory',
                'description'          => 'For mid-size manufacturers. Full code suite, 3 store keepers, analytics.',
                'monthly_price'        => 14999.00,
                'yearly_price'         => 149990.00,
                'setup_fee'            => 5000.00,
                'currency'             => 'PKR',
                'monthly_unit_codes'   => 25000,
                'monthly_packet_codes' => 5000,
                'monthly_carton_codes' => 2500,
                'monthly_bundle_codes' => 1000,
                'max_users'            => 5,
                'max_stores'           => 3,
                'max_drivers'          => 5,
                'features'             => json_encode(['all_codes', 'qr_scan', 'offline_mode', 'analytics', 'b2b_marketplace']),
                'is_custom'            => false,
                'is_recommended'       => true,
                'status'               => 'active',
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'Premium Fleet',
                'type'                 => 'transport',
                'description'          => 'For bus/truck fleet operators. GPS tracking, seat layouts, commission splits.',
                'monthly_price'        => 24999.00,
                'yearly_price'         => 249990.00,
                'setup_fee'            => 10000.00,
                'currency'             => 'PKR',
                'monthly_unit_codes'   => 0,
                'monthly_packet_codes' => 0,
                'monthly_carton_codes' => 0,
                'monthly_bundle_codes' => 0,
                'max_users'            => 10,
                'max_stores'           => 0,
                'max_drivers'          => 50,
                'features'             => json_encode(['gps_tracking', 'seat_layouts', 'commission_splits', 'realtime_telemetry', 'route_optimization']),
                'is_custom'            => false,
                'is_recommended'       => false,
                'status'               => 'active',
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'Marketplace Tier',
                'type'                 => 'marketplace',
                'description'          => 'For B2B resellers and wholesalers. Storefront, group buying, escrow.',
                'monthly_price'        => 9999.00,
                'yearly_price'         => 99990.00,
                'setup_fee'            => 0,
                'currency'             => 'PKR',
                'monthly_unit_codes'   => 0,
                'monthly_packet_codes' => 0,
                'monthly_carton_codes' => 0,
                'monthly_bundle_codes' => 0,
                'max_users'            => 5,
                'max_stores'           => 10,
                'max_drivers'          => 10,
                'features'             => json_encode(['storefront', 'group_buying', 'escrow', 'b2b_chat', 'inventory_sync']),
                'is_custom'            => false,
                'is_recommended'       => false,
                'status'               => 'active',
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
            [
                'name'                 => 'Unlimited',
                'type'                 => 'factory',
                'description'          => 'Full platform access. Unlimited everything. Priority support.',
                'monthly_price'        => 49999.00,
                'yearly_price'         => 499990.00,
                'setup_fee'            => 25000.00,
                'currency'             => 'PKR',
                'monthly_unit_codes'   => 100000,
                'monthly_packet_codes' => 25000,
                'monthly_carton_codes' => 10000,
                'monthly_bundle_codes' => 5000,
                'max_users'            => 20,
                'max_stores'           => 20,
                'max_drivers'          => 200,
                'features'             => json_encode(['all_features', 'priority_support', 'white_label', 'api_access', 'dedicated_server']),
                'is_custom'            => false,
                'is_recommended'       => false,
                'status'               => 'active',
                'created_at'           => now(),
                'updated_at'           => now(),
            ],
        ];

        foreach ($plans as $plan) {
            $plan['id'] = (string) Str::orderedUuid();
            DB::table('subscription_plans')->upsert(
                $plan,
                ['name', 'type'],
                ['description', 'monthly_price', 'yearly_price', 'setup_fee', 'features', 'is_recommended', 'status', 'updated_at']
            );
        }

        $count = DB::table('subscription_plans')->count();
        $this->command?->info("  Seeded {$count} subscription plans.");
    }
}
