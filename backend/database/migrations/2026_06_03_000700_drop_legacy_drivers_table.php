<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 1 — Greenfield Cutover: Drop Legacy drivers Table
     *
     * Per Section 10.13 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
     *
     * ⚠️ GREENFIELD ONLY. No production data to protect.
     *
     * The global_identities + identity_claims + fleet_assignments
     * spine fully replaces the monolithic drivers table.
     *
     * All legacy login flow controllers in AccountEngineController
     * and FleetManagementController have been updated to use the
     * new global identity API (/api/v1/auth/login).
     */
    public function up(): void
    {
        Schema::dropIfExists('drivers');
    }

    public function down(): void
    {
        // No reverse migration — greenfield cutover.
        // If restoration is needed, re-run:
        //   2026_05_18_000500_create_drivers_table.php
        //   2026_05_22_000020_add_driver_type_to_drivers.php
        //   2026_05_25_000001_add_owner_id_to_drivers_table.php
    }
};
