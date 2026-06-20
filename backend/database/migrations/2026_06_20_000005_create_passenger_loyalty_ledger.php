<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — CENTRALIZED LOYALTY LEDGER
 * ========================================
 *
 * Many-to-Many mapping: passenger_id ↔ bus_company_id
 * Tracks trips, points, and tier per company in the central
 * Trace Odd database. The universal Customer App fetches
 * company-specific points/vouchers dynamically at checkout.
 *
 * TABLE: passenger_loyalty_ledger
 *
 * Keeps data isolated per company while hosted on a single
 * universal client app (Trace Odd architecture).
 */

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('passenger_loyalty_ledger', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('passenger_id');          // FK → users.id
            $table->string('bus_company_id');       // FK → transport_bus_routes.carrier_company_id or owner_identity_id
            $table->integer('total_trips')->default(0);
            $table->decimal('total_spent', 12, 2)->default(0);
            $table->integer('loyalty_points')->default(0);
            $table->string('tier')->default('bronze'); // bronze, silver, gold, platinum
            $table->timestamp('last_trip_at')->nullable();
            $table->timestamps();

            $table->unique(['passenger_id', 'bus_company_id']);
            $table->index('passenger_id');
            $table->index('bus_company_id');
            $table->index('tier');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('passenger_loyalty_ledger');
    }
};
