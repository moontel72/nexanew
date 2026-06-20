<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — FIX INFLATED total_distance_km ON transport_bus_routes
 * ====================================================================
 *
 * The old publish() fallback summed ALL route_segment_prices rows
 * (including non-consecutive combinatorial pairs), inflating the
 * stored total. This migration recalculates every route using only
 * consecutive segments (to_stop_order = from_stop_order + 1).
 */

return new class extends Migration
{
    public function up(): void
    {
        $routes = DB::table('transport_bus_routes')->get();

        foreach ($routes as $route) {
            $consecutiveKm = DB::table('route_segment_prices')
                ->where('route_id', $route->id)
                ->whereRaw('to_stop_order = from_stop_order + 1')
                ->sum('distance_km');

            $consecutiveKm = round((float) $consecutiveKm, 2);

            if ($consecutiveKm > 0) {
                DB::table('transport_bus_routes')
                    ->where('id', $route->id)
                    ->update([
                        'total_distance_km' => $consecutiveKm,
                        'updated_at'        => now(),
                    ]);
            }
        }
    }

    public function down(): void
    {
        // No rollback — the old values were wrong.
    }
};
