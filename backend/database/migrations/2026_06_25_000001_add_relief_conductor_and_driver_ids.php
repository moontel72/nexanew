<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 2.1 — Relief Conductor + Multi-Driver Support
     * ===================================================
     *
     * Adds:
     *   - relief_conductor_id   (handover relief conductor — mirrors relief_driver_id)
     *   - driver_ids            (JSONB array — multiple drivers per assignment,
     *                            mirrors conductor_ids for long-haul routes)
     */
    public function up(): void
    {
        if (!Schema::hasTable('fleet_dispatch_assignments')) {
            return;
        }

        Schema::table('fleet_dispatch_assignments', function (Blueprint $table) {
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'relief_conductor_id')) {
                $table->uuid('relief_conductor_id')->nullable()->after('relief_driver_id');
            }
            if (!Schema::hasColumn('fleet_dispatch_assignments', 'driver_ids')) {
                $table->jsonb('driver_ids')->nullable()->after('relief_conductor_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('fleet_dispatch_assignments', function (Blueprint $table) {
            if (Schema::hasColumn('fleet_dispatch_assignments', 'relief_conductor_id')) {
                $table->dropColumn('relief_conductor_id');
            }
            if (Schema::hasColumn('fleet_dispatch_assignments', 'driver_ids')) {
                $table->dropColumn('driver_ids');
            }
        });
    }
};
