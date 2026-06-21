<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — PURGE CORRUPTED ROUTE SEGMENT PRICES
 * ===================================================
 *
 * Removes two classes of bad data from route_segment_prices:
 *
 * 1. Self-referencing loops (station → same station)
 *    Example: Naushahra Purana Adda → Naushahra Purana Adda
 *
 * 2. Duplicate station-name pairs within the same route
 *    Example: Peer Wadhai Adda → Naushahra Purana Adda (×2)
 *    Keeps the row with the shortest stop-order span.
 *
 * SAFETY: Total KM uses only consecutive segments
 * (to_stop_order = from_stop_order + 1), so deleting
 * non-consecutive duplicates and self-loops leaves the
 * aggregate kilometer count on the route overview intact.
 */

return new class extends Migration
{
    public function up(): void
    {
        // ── Step 1: Delete self-referencing rows ──────────────
        DB::table('route_segment_prices')
            ->whereColumn('from_station', '=', 'to_station')
            ->delete();

        // ── Step 2: Delete duplicate station-name pairs ───────
        // For each (route_id, from_station, to_station) group,
        // keep the row with the smallest stop-order span and
        // delete all others.

        $duplicates = DB::table('route_segment_prices')
            ->select(
                'route_id',
                'from_station',
                'to_station',
                DB::raw('COUNT(*) as cnt'),
            )
            ->groupBy('route_id', 'from_station', 'to_station')
            ->having('cnt', '>', 1)
            ->get();

        foreach ($duplicates as $dup) {
            // Find the row with the smallest stop-order span
            $keeper = DB::table('route_segment_prices')
                ->where('route_id', $dup->route_id)
                ->where('from_station', $dup->from_station)
                ->where('to_station', $dup->to_station)
                ->orderByRaw('(to_stop_order - from_stop_order) ASC')
                ->orderBy('id', 'asc')
                ->first();

            if (! $keeper) {
                continue;
            }

            // Delete all other rows in this group
            DB::table('route_segment_prices')
                ->where('route_id', $dup->route_id)
                ->where('from_station', $dup->from_station)
                ->where('to_station', $dup->to_station)
                ->where('id', '!=', $keeper->id)
                ->delete();
        }

        // ── Step 3: Rebuild the pricing_matrix JSON cache ────
        // For any route that had rows deleted, refresh the
        // denormalized JSON cache on transport_bus_routes.

        $affectedRouteIds = DB::table('route_segment_prices')
            ->distinct()
            ->pluck('route_id');

        foreach ($affectedRouteIds as $routeId) {
            $prices = DB::table('route_segment_prices')
                ->where('route_id', $routeId)
                ->orderBy('from_stop_order')
                ->orderBy('to_stop_order')
                ->get()
                ->toArray();

            DB::table('transport_bus_routes')
                ->where('id', $routeId)
                ->update([
                    'pricing_matrix' => json_encode($prices),
                    'updated_at'      => now(),
                ]);
        }
    }

    public function down(): void
    {
        // This migration is destructive by design — no rollback.
    }
};
