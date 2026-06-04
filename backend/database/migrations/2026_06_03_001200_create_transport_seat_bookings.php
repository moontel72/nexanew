<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 4 — Bus Transit Seat Layout System
     *
     * Part 3: transport_seat_bookings — Atomic hold engine
     *
     * Section 6.5: Postgres partial unique index prevents double-booking
     * race conditions. A seat can only be held or confirmed once per trip.
     *
     * Status lifecycle:
     *   held (temporary, expires via scheduled job) → confirmed (paid)
     *   held → released (timeout or user cancel)
     *   confirmed → cancelled (refund processed)
     *
     * Atomic hold constraint (Section 6.5):
     *   CREATE UNIQUE INDEX idx_atomic_seat_hold
     *     ON transport_seat_bookings (trip_id, seat_id)
     *     WHERE status IN ('held', 'confirmed');
     */
    public function up(): void
    {
        if (Schema::hasTable('transport_seat_bookings')) {
            return;
        }

        Schema::create('transport_seat_bookings', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('trip_id');                               // FK → transport_bus_trips
            $table->string('seat_id', 20);                         // e.g. "A1", "B14"
            $table->uuid('booked_by_identity_id');                 // FK → global_identities
            $table->string('status', 20)->default('held');         // held, confirmed, released, cancelled
            $table->string('passenger_name', 160)->nullable();
            $table->string('passenger_phone', 50)->nullable();
            $table->string('passenger_gender', 10)->nullable();    // male, female, other
            $table->decimal('fare_amount', 10, 2)->nullable();
            $table->string('payment_method', 30)->nullable();
            $table->string('payment_ref', 100)->nullable();
            $table->timestampTz('held_at')->useCurrent();
            $table->timestampTz('confirmed_at')->nullable();
            $table->timestampTz('released_at')->nullable();
            $table->timestampTz('expires_at')->nullable();         // held expiry (typically +15 min)
            $table->text('cancellation_reason')->nullable();
            $table->timestamps();

            $table->foreign('trip_id')
                ->references('id')->on('transport_bus_trips')
                ->onDelete('cascade');
            $table->foreign('booked_by_identity_id')
                ->references('id')->on('global_identities')
                ->onDelete('restrict');

            $table->index('trip_id');
            $table->index('status');
            $table->index('booked_by_identity_id');
            $table->index('expires_at');
        });

        DB::statement("ALTER TABLE transport_seat_bookings ALTER COLUMN id SET DEFAULT gen_random_uuid()");

        // ── Atomic seat hold guard (Section 6.5) ──────────────────
        DB::statement("CREATE UNIQUE INDEX idx_atomic_seat_hold
            ON transport_seat_bookings (trip_id, seat_id)
            WHERE status IN ('held', 'confirmed')");
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_seat_bookings');
    }
};
