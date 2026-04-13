<?php

namespace Database\Seeders;

use App\Models\AdminUser;
use App\Models\Company;
use App\Models\CompanySubscription;
use App\Models\FactoryUser;
use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class NexaBootstrapSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $nowIso = now()->toISOString();

            $feature = function (string $id, string $name, string $description, string $type, bool $included = true, string $icon = 'check_circle', int $sortOrder = 0, bool $highlight = false, array $metadata = []) use ($nowIso) {
                return [
                    'id' => $id,
                    'name' => $name,
                    'description' => $description,
                    'type' => $type,
                    'is_included' => $included,
                    'icon' => $icon,
                    'sort_order' => $sortOrder,
                    'is_highlight' => $highlight,
                    'metadata' => $metadata,
                    'created_at' => $nowIso,
                    'updated_at' => $nowIso,
                ];
            };

            $plans = [
                [
                    'name' => 'Free Plan',
                    'type' => 'free',
                    'description' => 'Basic access for small factories and trials.',
                    'monthly_price' => 0,
                    'yearly_price' => 0,
                    'currency' => 'USD',
                    'monthly_unit_codes' => 5000,
                    'monthly_packet_codes' => 500,
                    'monthly_carton_codes' => 90,
                    'monthly_bundle_codes' => 30,
                    'max_users' => 1,
                    'max_stores' => 1,
                    'max_drivers' => 1,
                    'is_custom' => false,
                    'is_recommended' => false,
                    'status' => 'active',
                    'features' => [
                        $feature('feature_basic_qr', 'Basic QR Code Scanning', 'Basic QR code scanning functionality', 'core', true, 'qr_code_scanner', 1),
                        $feature('feature_email_support', 'Email Support', 'Email support', 'core', true, 'email', 2),
                        $feature('feature_basic_reports', 'Standard Reports', 'Standard reporting functionality', 'core', true, 'assessment', 3),
                        $feature('feature_mobile_app', 'Mobile App Access', 'Access to mobile app', 'core', true, 'phone_iphone', 4),
                    ],
                    'metadata' => [
                        'sort_order' => 1,
                        'storage_gb' => 1,
                        'daily_api_calls' => 0,
                        'active_products' => 1,
                        'is_featured' => false,
                        'is_popular' => false,
                        'transport' => [
                            'enabled' => false,
                            'connections_per_month' => 0,
                            'loads_posting_per_month' => 0,
                        ],
                    ],
                ],
                [
                    'name' => 'Basic Plan',
                    'type' => 'basic',
                    'description' => 'Suitable for growing factories with batch generation and limited API access.',
                    'monthly_price' => 49,
                    'yearly_price' => 490,
                    'currency' => 'USD',
                    'monthly_unit_codes' => 50000,
                    'monthly_packet_codes' => 5000,
                    'monthly_carton_codes' => 900,
                    'monthly_bundle_codes' => 300,
                    'max_users' => 5,
                    'max_stores' => 5,
                    'max_drivers' => 3,
                    'is_custom' => false,
                    'is_recommended' => true,
                    'status' => 'active',
                    'features' => [
                        $feature('feature_basic_qr', 'Basic QR Code Scanning', 'Basic QR code scanning functionality', 'core', true, 'qr_code_scanner', 1),
                        $feature('feature_batch_generation', 'Batch Code Generation', 'Batch code generation functionality', 'advanced', true, 'batch_prediction', 10, true, ['available_from' => 'basic']),
                        $feature('feature_basic_api', 'API Access (Limited)', 'Limited API access', 'advanced', true, 'api', 11, true, ['daily_limit' => 1000]),
                        $feature('feature_custom_branding', 'Custom Branding', 'Custom branding', 'advanced', true, 'palette', 12),
                        $feature('feature_priority_email', 'Priority Email Support', 'Priority email support', 'advanced', true, 'support_agent', 13),
                    ],
                    'metadata' => [
                        'sort_order' => 2,
                        'storage_gb' => 5,
                        'daily_api_calls' => 1000,
                        'active_products' => 25,
                        'is_featured' => true,
                        'is_popular' => true,
                        'transport' => [
                            'enabled' => true,
                            'level' => 'limited',
                            'connections_per_month' => 10,
                            'loads_posting_per_month' => 5,
                            'can_contact_drivers_directly' => true,
                        ],
                    ],
                ],
                [
                    'name' => 'Standard Plan',
                    'type' => 'standard',
                    'description' => 'Advanced analytics and full transport marketplace access.',
                    'monthly_price' => 149,
                    'yearly_price' => 1490,
                    'currency' => 'USD',
                    'monthly_unit_codes' => 200000,
                    'monthly_packet_codes' => 20000,
                    'monthly_carton_codes' => 3600,
                    'monthly_bundle_codes' => 1200,
                    'max_users' => 50,
                    'max_stores' => 20,
                    'max_drivers' => 0,
                    'is_custom' => false,
                    'is_recommended' => false,
                    'status' => 'active',
                    'features' => [
                        $feature('feature_advanced_analytics', 'Advanced Analytics', 'Advanced analytics and reporting', 'advanced', true, 'analytics', 20, true),
                        $feature('feature_zoho_books', 'Zoho Books Integration', 'Zoho Books integration', 'advanced', true, 'account_balance', 21),
                        $feature('feature_phone_support', 'Phone Support', 'Phone support', 'advanced', true, 'phone', 22),
                        $feature('feature_live_tracking', 'Live Truck Tracking', 'Live truck tracking', 'advanced', true, 'location_on', 23),
                        $feature('feature_transport_full', 'Transport Marketplace Access', 'Full transport marketplace access', 'advanced', true, 'local_shipping', 24, true),
                    ],
                    'metadata' => [
                        'sort_order' => 3,
                        'storage_gb' => 20,
                        'daily_api_calls' => 5000,
                        'active_products' => 200,
                        'is_featured' => false,
                        'is_popular' => false,
                        'transport' => [
                            'enabled' => true,
                            'level' => 'full',
                            'connections_per_month' => 50,
                            'loads_posting_per_month' => 20,
                            'live_truck_tracking' => true,
                        ],
                    ],
                ],
                [
                    'name' => 'Premium Plan',
                    'type' => 'premium',
                    'description' => 'High-volume factories with premium transport features and priority support.',
                    'monthly_price' => 499,
                    'yearly_price' => 4990,
                    'currency' => 'USD',
                    'monthly_unit_codes' => 1000000,
                    'monthly_packet_codes' => 100000,
                    'monthly_carton_codes' => 18000,
                    'monthly_bundle_codes' => 6000,
                    'max_users' => 0,
                    'max_stores' => 0,
                    'max_drivers' => 0,
                    'is_custom' => false,
                    'is_recommended' => false,
                    'status' => 'active',
                    'features' => [
                        $feature('feature_dedicated_manager', 'Dedicated Account Manager', 'Dedicated account manager', 'enterprise', true, 'person', 30, true),
                        $feature('feature_sla', 'SLA Guarantee', 'SLA guarantee', 'enterprise', true, 'verified_user', 31),
                        $feature('feature_247_support', '24/7 Support', '24/7 support', 'enterprise', true, 'support', 32),
                        $feature('feature_route_optimization', 'Route Optimization', 'Advanced route optimization', 'enterprise', true, 'route', 33),
                        $feature('feature_transport_premium', 'Premium Transport Features', 'Premium transport features', 'enterprise', true, 'local_shipping', 34, true, ['unlimited_connections' => true]),
                    ],
                    'metadata' => [
                        'sort_order' => 4,
                        'storage_gb' => 100,
                        'daily_api_calls' => 20000,
                        'active_products' => 1000,
                        'is_featured' => true,
                        'is_popular' => false,
                        'transport' => [
                            'enabled' => true,
                            'level' => 'premium',
                            'connections_per_month' => 0,
                            'loads_posting_per_month' => 0,
                            'advanced_route_optimization' => true,
                            'escrow_payment_system' => true,
                        ],
                    ],
                ],
                [
                    'name' => 'Custom Plan',
                    'type' => 'custom',
                    'description' => 'Negotiated plan with custom limits and enterprise integrations.',
                    'monthly_price' => 0,
                    'yearly_price' => 0,
                    'currency' => 'USD',
                    'monthly_unit_codes' => 0,
                    'monthly_packet_codes' => 0,
                    'monthly_carton_codes' => 0,
                    'monthly_bundle_codes' => 0,
                    'max_users' => 0,
                    'max_stores' => 0,
                    'max_drivers' => 0,
                    'is_custom' => true,
                    'is_recommended' => false,
                    'status' => 'active',
                    'features' => [
                        $feature('feature_white_label', 'White-label', 'White-label solution', 'custom', true, 'branding_watermark', 40, true),
                        $feature('feature_sap', 'SAP Integration', 'SAP integration', 'custom', true, 'integration_instructions', 41),
                        $feature('feature_dedicated_infra', 'Dedicated Infrastructure', 'Dedicated infrastructure', 'custom', true, 'dns', 42),
                    ],
                    'metadata' => [
                        'sort_order' => 5,
                        'storage_gb' => 0,
                        'daily_api_calls' => 0,
                        'active_products' => 0,
                        'is_featured' => false,
                        'is_popular' => false,
                        'transport' => [
                            'enabled' => true,
                            'level' => 'enterprise',
                        ],
                    ],
                ],
            ];

            foreach ($plans as $p) {
                SubscriptionPlan::query()->updateOrCreate(
                    ['type' => $p['type']],
                    [
                        'name' => $p['name'],
                        'description' => $p['description'],
                        'monthly_price' => $p['monthly_price'],
                        'yearly_price' => $p['yearly_price'],
                        'currency' => $p['currency'],
                        'monthly_unit_codes' => $p['monthly_unit_codes'],
                        'monthly_packet_codes' => $p['monthly_packet_codes'],
                        'monthly_carton_codes' => $p['monthly_carton_codes'],
                        'monthly_bundle_codes' => $p['monthly_bundle_codes'],
                        'max_users' => $p['max_users'],
                        'max_stores' => $p['max_stores'],
                        'max_drivers' => $p['max_drivers'],
                        'features' => $p['features'],
                        'is_custom' => $p['is_custom'],
                        'is_recommended' => $p['is_recommended'],
                        'status' => $p['status'],
                        'metadata' => $p['metadata'],
                    ]
                );
            }

            $plan = SubscriptionPlan::query()->where('type', 'basic')->first() ?? SubscriptionPlan::query()->first();

            $admin = AdminUser::query()->where('email', 'admin@nexatrace.local')->first();
            if (!$admin) {
                AdminUser::query()->create([
                    'id' => (string) Str::uuid(),
                    'name' => 'Super Admin',
                    'email' => 'admin@nexatrace.local',
                    'password' => 'admin12345',
                    'role' => 'super_admin',
                    'status' => 'active',
                    'metadata' => [],
                ]);
            }

            $company = Company::query()->where('email', 'factory@nexatrace.local')->first();
            if (!$company) {
                $company = Company::query()->create([
                    'id' => (string) Str::uuid(),
                    'name' => 'Demo Factory',
                    'business_registration_number' => 'DEMO-REG-001',
                    'tax_id' => null,
                    'company_type' => 'manufacturing',
                    'industry_type' => 'other',
                    'email' => 'factory@nexatrace.local',
                    'phone' => '0000000000',
                    'website' => null,
                    'country' => 'PK',
                    'city' => 'Demo City',
                    'address' => 'Demo Address',
                    'postal_code' => null,
                    'contact_person_name' => 'Factory Admin',
                    'contact_person_email' => 'factory-admin@nexatrace.local',
                    'contact_person_phone' => '0000000000',
                    'contact_person_position' => 'Admin',
                    'status' => 'active',
                    'verification_status' => 'verified',
                    'verified_at' => now(),
                    'timezone' => 'UTC',
                    'language' => 'en',
                    'currency' => 'USD',
                    'metadata' => [],
                ]);
            }

            $sub = CompanySubscription::query()->where('company_id', $company->id)->where('status', 'active')->first();
            if (!$sub) {
                CompanySubscription::query()->where('company_id', $company->id)->update(['status' => 'inactive']);
                CompanySubscription::query()->create([
                    'id' => (string) Str::uuid(),
                    'company_id' => $company->id,
                    'plan_id' => $plan->id,
                    'billing_cycle' => 'monthly',
                    'start_date' => now()->toDateString(),
                    'end_date' => null,
                    'auto_renew' => true,
                    'payment_status' => 'paid',
                    'status' => 'active',
                    'metadata' => [],
                ]);
            }

            $factoryUser = FactoryUser::query()->where('email', 'factory-admin@nexatrace.local')->first();
            if (!$factoryUser) {
                $factoryUser = new FactoryUser([
                    'id' => (string) Str::uuid(),
                    'company_id' => $company->id,
                    'email' => 'factory-admin@nexatrace.local',
                    'phone' => '0000000000',
                    'full_name' => 'Factory Admin',
                    'position' => 'admin',
                    'email_verified' => true,
                    'phone_verified' => true,
                    'permissions' => [],
                    'is_active' => true,
                    'metadata' => [],
                ]);
                $factoryUser->setPassword('admin12345');
                $factoryUser->save();
            }
        });
    }
}
