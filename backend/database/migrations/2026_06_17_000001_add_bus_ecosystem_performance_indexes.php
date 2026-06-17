<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ADD PERFORMANCE INDEXES FOR BUS ECOSYSTEM
 * ======================================================
 *
 * Adds missing database indexes on high-traffic columns
 * identified during the Module 8V architecture audit.
 *
 * TABLES INDEXED:
 *   transport_seat_bookings  — status, user_id
 *   absolute_bus_layouts     — layout_status
 *   transport_bus_qr_codes   — active_trip_id
 *   fleet_assignments        — carrier_company_id, global_identity_id (composite)
 *
 * RATIONALE:
 *   - seat_bookings.status: filtered on every booking list / refresh call
 *   - seat_bookings.user_id: "my bookings" lookups for passenger history
 *   - absolute_bus_layouts.layout_status: queried on every fleet dashboard load
 *     (WHERE layout_status != 'archived')
 *   - transport_bus_qr_codes.active_trip_id: scanned every time a passenger
 *     opens the bus door QR code
 *   - fleet_assignments: heavily queried for identity resolution,
 *     driver/owner counts, and link request lookups
 */

return new class extends Migration
{
    public function up(): void
    {
        // ── transport_seat_bookings ──────────────────────
        Schema::table('transport_seat_bookings', function (Blueprint $table) {
            $table->index('status');
            $table->index('user_id');
        });

        // ── absolute_bus_layouts ─────────────────────────
        Schema::table('absolute_bus_layouts', function (Blueprint $table) {
            $table->index('layout_status');
        });

        // ── transport_bus_qr_codes ───────────────────────
        Schema::table('transport_bus_qr_codes', function (Blueprint $table) {
            $table->index('active_trip_id');
        });

        // ── fleet_assignments (compound index for identity lookups) ──
        Schema::table('fleet_assignments', function (Blueprint $table) {
            // Already has individual indexes; add a composite for the
            // most common query pattern: WHERE carrier_company_id = ? AND fleet_type = ? AND status IN (...)
            $table->index(['carrier_company_id', 'fleet_type', 'status'], 'fa_carrier_type_status');
        });
    }

    public function down(): void
    {
        Schema::table('transport_seat_bookings', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['user_id']);
        });

        Schema::table('absolute_bus_layouts', function (Blueprint $table) {
            $table->dropIndex(['layout_status']);
        });

        Schema::table('transport_bus_qr_codes', function (Blueprint $table) {
            $table->dropIndex(['active_trip_id']);
        });

        Schema::table('fleet_assignments', function (Blueprint $table) {
            $table->dropIndex('fa_carrier_type_status');
        });
    }
};
