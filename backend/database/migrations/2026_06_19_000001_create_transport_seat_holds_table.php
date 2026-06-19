<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — TRANSPORT SEAT HOLDS TABLE
 * =======================================
 *
 * Lightweight ephemeral table for the seat reservation window
 * (8-minute checkout hold). Each row is a temporary claim that
 * either graduates to transport_seat_bookings on confirm OR is
 * pruned by the bus:release-expired-holds cron job on expiry.
 *
 * DESIGN PRINCIPLES:
 *   - Separate from transport_seat_bookings (no bloat, clean lifecycle)
 *   - UNIQUE(trip_id, seat_number) = first-write-wins race safety
 *   - hold_token UUID = one-time secret for confirm/release (no user-guessable)
 *   - hold_expires_at = TTL wallclock, checked by cron + confirm flow
 *
 * 48-HOUR DEPARTURE LOCKOUT:
 *   Holds are rejected if the trip's scheduled departure is within
 *   48 hours. Enforcement lives in SeatHoldService, not at DB level.
 *
 * TARGET MODULES: 8V, 8W, 14E
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transport_seat_holds', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('layout_id');
            $table->uuid('trip_id');
            $table->uuid('user_id');
            $table->unsignedInteger('seat_number');
            $table->uuid('hold_token')->unique();
            $table->timestampTz('hold_expires_at');
            $table->timestampTz('held_at')->useCurrent();

            // ─── Race-Safety Constraint ─────────────────
            // Only one person can hold a given seat on a given trip.
            // First INSERT wins; second gets a DB-level 409.
            $table->unique(['trip_id', 'seat_number'], 'tsh_trip_seat_unique');

            // ─── Performance Indexes ────────────────────
            $table->index('trip_id');                    // GET /held/{tripId}
            $table->index('hold_expires_at');             // cron cleanup
            $table->index('user_id');                     // "my holds" dashboard

            // ─── Foreign Keys ──────────────────────────
            $table->foreign('layout_id')
                ->references('id')->on('absolute_bus_layouts')
                ->onDelete('cascade');

            $table->foreign('trip_id')
                ->references('id')->on('transport_bus_trips')
                ->onDelete('cascade');
        });

        // ─── Add scheduled_departure_at to transport_bus_trips ───
        // Required for the 48-hour departure lockout rule.
        if (! Schema::hasColumn('transport_bus_trips', 'scheduled_departure_at')) {
            Schema::table('transport_bus_trips', function (Blueprint $table) {
                $table->timestampTz('scheduled_departure_at')->nullable()->after('completed_at');
                $table->index('scheduled_departure_at');
            });
        }
    }

    public function down(): void
    {
        Schema::table('transport_bus_trips', function (Blueprint $table) {
            $table->dropIndex(['scheduled_departure_at']);
            $table->dropColumn('scheduled_departure_at');
        });

        Schema::dropIfExists('transport_seat_holds');
    }
};
