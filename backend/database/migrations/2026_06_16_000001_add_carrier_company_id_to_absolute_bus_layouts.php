<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — Add carrier_company_id to absolute_bus_layouts
 * ==========================================================
 *
 * The bus-fleet dashboard queries fleet_size and layout_count
 * scoped by carrier_company_id, but the absolute_bus_layouts
 * table only had owner_identity_id. This migration adds the
 * missing column and backfills it from fleet_assignments where
 * the owner's identity is linked to a carrier company.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('absolute_bus_layouts', function (Blueprint $table) {
            if (!Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id')) {
                $table->uuid('carrier_company_id')->nullable()->after('owner_identity_id')->index();
            }
        });

        // Backfill: for each layout, resolve carrier_company_id from the owner's
        // active fleet_assignment where they're an 'owner' role in 'bus' fleet.
        DB::statement("
            UPDATE absolute_bus_layouts abl
            SET carrier_company_id = fa.carrier_company_id
            FROM fleet_assignments fa
            WHERE abl.owner_identity_id = fa.global_identity_id
              AND fa.role = 'owner'
              AND fa.fleet_type = 'bus'
              AND fa.status IN ('active', 'pending_acceptance')
              AND abl.carrier_company_id IS NULL
        ");
    }

    public function down(): void
    {
        Schema::table('absolute_bus_layouts', function (Blueprint $table) {
            if (Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id')) {
                $table->dropColumn('carrier_company_id');
            }
        });
    }
};
