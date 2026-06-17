<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — TRANSPORT BUS ROUTES + WAYPOINTS
 * ==============================================
 *
 * Core route infrastructure for Module 13B — Dynamic Route
 * & Waypoint Line Scheduler. Every bus trip requires a
 * published route with origin, destination, and ordered
 * intermediate waypoint terminals.
 *
 * TABLES:
 *   transport_bus_routes          — Route master record
 *   transport_bus_route_waypoints — Ordered stops on a route
 *
 * RELATIONSHIPS:
 *   route 1──N waypoints
 *   route 1──N trips (via transport_bus_trips.route_id)
 */

return new class extends Migration
{
    public function up(): void
    {
        // ── transport_bus_routes ─────────────────────────
        Schema::create('transport_bus_routes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('route_code', 50)->unique();       // e.g. "LHR-ISB-001"
            $table->string('display_name');                    // e.g. "Lahore → Islamabad Express"
            $table->string('origin_city');
            $table->string('destination_city');
            $table->decimal('origin_lat', 10, 7);
            $table->decimal('origin_lng', 10, 7);
            $table->decimal('destination_lat', 10, 7);
            $table->decimal('destination_lng', 10, 7);
            $table->decimal('total_distance_km', 8, 2)->nullable();   // computed
            $table->integer('estimated_duration_min')->nullable();    // computed
            $table->enum('status', ['draft', 'published', 'archived'])
                  ->default('draft');
            $table->string('carrier_company_id')->nullable(); // scoped to transit brand
            $table->json('meta')->nullable();                 // schedule, pricing tiers
            $table->timestamps();

            $table->index('carrier_company_id');
            $table->index('status');
            $table->index(['carrier_company_id', 'status']);
        });

        // ── transport_bus_route_waypoints ────────────────
        Schema::create('transport_bus_route_waypoints', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('route_id')
                  ->constrained('transport_bus_routes')
                  ->cascadeOnDelete();
            $table->integer('stop_order');                     // 0 = origin, N = destination
            $table->string('station_name');                    // e.g. "Gujranwala Terminal"
            $table->decimal('lat', 10, 7);
            $table->decimal('lng', 10, 7);
            $table->decimal('distance_from_origin_km', 8, 2)->nullable();
            $table->integer('estimated_min_from_origin')->nullable();
            $table->json('meta')->nullable();                  // amenities, platform numbers
            $table->timestamps();

            $table->unique(['route_id', 'stop_order']);
            $table->index('route_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_bus_route_waypoints');
        Schema::dropIfExists('transport_bus_routes');
    }
};
