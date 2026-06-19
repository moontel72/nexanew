<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ROUTE SEGMENT PRICING TABLE
 * ========================================
 *
 * City-to-city tiered ticket pricing per route segment.
 * Supports multi-stopover routes with independent pricing
 * for every origin→destination pair within a route.
 *
 * EXAMPLE (Lahore → Gujrat → Jhelum → Islamabad):
 *   route_id=1, from_stop=0(Lahore), to_stop=1(Gujrat) → Rs. 800
 *   route_id=1, from_stop=0(Lahore), to_stop=2(Jhelum) → Rs. 1,200
 *   route_id=1, from_stop=0(Lahore), to_stop=3(Islamabad) → Rs. 1,800
 *   route_id=1, from_stop=1(Gujrat), to_stop=2(Jhelum) → Rs. 500
 *   route_id=1, from_stop=1(Gujrat), to_stop=3(Islamabad) → Rs. 1,100
 *   route_id=1, from_stop=2(Jhelum), to_stop=3(Islamabad) → Rs. 600
 *
 * TARGET MODULES: 13B, 8V
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('route_segment_prices', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('route_id');
            $table->integer('from_stop_order');      // waypoint stop_order (0 = origin)
            $table->integer('to_stop_order');        // waypoint stop_order
            $table->string('from_station');          // display name for reference
            $table->string('to_station');
            $table->decimal('price', 10, 2);         // base ticket price PKR
            $table->string('seat_category', 30)->default('standard');
            // standard | businessClass | sleeperLower | sleeperUpper | folding
            $table->timestamps();

            $table->unique(['route_id', 'from_stop_order', 'to_stop_order', 'seat_category'], 'rsp_route_segment_cat_unique');
            $table->foreign('route_id')->references('id')->on('transport_bus_routes')->cascadeOnDelete();
            $table->index('route_id');
        });

        // Add pricing JSON to routes as a cache/dev convenience
        if (! Schema::hasColumn('transport_bus_routes', 'pricing_matrix')) {
            Schema::table('transport_bus_routes', function (Blueprint $table) {
                $table->json('pricing_matrix')->nullable()->after('meta');
            });
        }
    }

    public function down(): void
    {
        Schema::table('transport_bus_routes', function (Blueprint $table) {
            $table->dropColumn('pricing_matrix');
        });
        Schema::dropIfExists('route_segment_prices');
    }
};
