<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     *
     * Wave 1 + Wave 2 seed order:
     *   1. NexaBootstrapSeeder      — legacy bootstrap (kept for backward compat)
     *   2. FeatureRegistrySeeder    — Wave 1.1: 4 verticals + 30+ features
     *   3. MasterAdminSeeder        — Wave 2: Master Admin identity + assignments
     *   4. SubAdminSeeder           — Wave 2: 4 sub-admin vertical profiles
     *   5. SubscriptionPlansSeeder  — Baseline production tier plans
     */
    public function run(): void
    {
        $this->call([
            NexaBootstrapSeeder::class,
            FeatureRegistrySeeder::class,
            CricketFeatureRegistrySeeder::class,
            MasterAdminSeeder::class,
            SubAdminSeeder::class,
            SubscriptionPlansSeeder::class,
        ]);
    }
}
