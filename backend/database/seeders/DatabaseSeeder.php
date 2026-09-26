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
     *   3. CricketFeatureRegistrySeeder — 5th vertical (cricket_ops)
     *   4. SubAdminVerticalExpansionSeeder — C1: factory / vehicle_security / trust_safety
     *                                  + financial_auditor's plans/** + billing/**
     *   5. MasterAdminSeeder        — Wave 2: Master Admin identity + assignments
     *   6. SubAdminSeeder           — Wave 2: 4 sub-admin vertical profiles
     *   7. SubscriptionPlansSeeder  — Baseline production tier plans
     */
    public function run(): void
    {
        $this->call([
            NexaBootstrapSeeder::class,
            FeatureRegistrySeeder::class,
            CricketFeatureRegistrySeeder::class,
            SubAdminVerticalExpansionSeeder::class,
            MasterAdminSeeder::class,
            SubAdminSeeder::class,
            SubscriptionPlansSeeder::class,
        ]);
    }
}
