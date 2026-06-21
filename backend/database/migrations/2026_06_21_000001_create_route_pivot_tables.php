<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ROUTE PIVOT TABLES (Many-to-Many Architecture)
 * =============================================================
 *
 * Replaces single-FK columns (voucher_id, driver_bonus_id, conductor_bonus_id)
 * on transport_bus_routes with proper many-to-many junction tables so that
 * multiple vouchers and bonuses can be stacked per route.
 *
 * Tables:
 *   route_assigned_vouchers  — (route_id, voucher_id) composite PK
 *   route_assigned_bonuses   — (route_id, bonus_id)   composite PK
 */
return new class extends Migration
{
    public function up(): void
    {
        // ── Pivot: route ↔ voucher ──────────────────────
        if (!Schema::hasTable('route_assigned_vouchers')) {
            Schema::create('route_assigned_vouchers', function (Blueprint $table) {
                $table->uuid('route_id');
                $table->uuid('voucher_id');
                $table->timestamp('created_at')->nullable();
                $table->primary(['route_id', 'voucher_id']);
                $table->index('route_id');
                $table->index('voucher_id');
            });
        }

        // ── Pivot: route ↔ bonus ────────────────────────
        if (!Schema::hasTable('route_assigned_bonuses')) {
            Schema::create('route_assigned_bonuses', function (Blueprint $table) {
                $table->uuid('route_id');
                $table->uuid('bonus_id');
                $table->timestamp('created_at')->nullable();
                $table->primary(['route_id', 'bonus_id']);
                $table->index('route_id');
                $table->index('bonus_id');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('route_assigned_bonuses');
        Schema::dropIfExists('route_assigned_vouchers');
    }
};
