<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ADD owner_identity_id TO transport_bus_routes
 * ==========================================================
 *
 * Multi-tenant ownership scoping for bus-owner panel.
 * Independent bus owners manage only their own routes.
 *
 * COLUMN: owner_identity_id — FK to global_identities.id
 * Allows BusRouteController to scope queries by owner
 * when accessed via /bus-owner panel prefix.
 */

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transport_bus_routes', function (Blueprint $table) {
            $table->string('owner_identity_id')->nullable()->after('carrier_company_id');
            $table->index('owner_identity_id');
        });
    }

    public function down(): void
    {
        Schema::table('transport_bus_routes', function (Blueprint $table) {
            $table->dropIndex(['owner_identity_id']);
            $table->dropColumn('owner_identity_id');
        });
    }
};
