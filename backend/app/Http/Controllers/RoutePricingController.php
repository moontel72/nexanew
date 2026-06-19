<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * NEXATRACE — ROUTE PRICING CONTROLLER
 * =====================================
 *
 * City-to-city segment pricing CRUD for multi-stopover routes.
 *
 * ROUTES:
 *   GET    /api/v1/bus-fleet/routes/{id}/pricing
 *   PUT    /api/v1/bus-fleet/routes/{id}/pricing
 *
 * TARGET MODULES: 13B, 8V
 */
class RoutePricingController extends Controller
{
    /**
     * GET segment prices for a route.
     */
    public function index(string $routeId, Request $request): JsonResponse
    {
        $prices = DB::table('route_segment_prices')
            ->where('route_id', $routeId)
            ->orderBy('from_stop_order')
            ->orderBy('to_stop_order')
            ->get();

        $waypoints = DB::table('transport_bus_route_waypoints')
            ->where('route_id', $routeId)
            ->orderBy('stop_order')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => [
                'route_id'  => $routeId,
                'waypoints' => $waypoints,
                'prices'    => $prices,
            ],
        ]);
    }

    /**
     * PUT batch-update segment prices for a route.
     *
     * Body: { prices: [{from_stop_order, to_stop_order, from_station,
     *                    to_station, price, seat_category}] }
     */
    public function update(string $routeId, Request $request): JsonResponse
    {
        $data = $request->validate([
            'prices'                    => ['required', 'array'],
            'prices.*.from_stop_order'  => ['required', 'integer', 'min:0'],
            'prices.*.to_stop_order'    => ['required', 'integer', 'min:0'],
            'prices.*.from_station'     => ['required', 'string', 'max:255'],
            'prices.*.to_station'       => ['required', 'string', 'max:255'],
            'prices.*.price'            => ['required', 'numeric', 'min:0'],
            'prices.*.seat_category'    => ['nullable', 'string', 'max:30'],
            'prices.*.distance_km'      => ['nullable', 'numeric', 'min:0'],
        ]);

        DB::transaction(function () use ($routeId, $data) {
            // Delete existing prices for this route
            DB::table('route_segment_prices')
                ->where('route_id', $routeId)
                ->delete();

            // Insert new prices
            $inserts = [];
            foreach ($data['prices'] as $p) {
                $inserts[] = [
                    'id'              => (string) Str::uuid(),
                    'route_id'        => $routeId,
                    'from_stop_order' => $p['from_stop_order'],
                    'to_stop_order'   => $p['to_stop_order'],
                    'from_station'    => $p['from_station'],
                    'to_station'      => $p['to_station'],
                    'price'           => $p['price'],
                    'distance_km'     => $p['distance_km'] ?? null,
                    'seat_category'   => $p['seat_category'] ?? 'standard',
                    'created_at'      => now(),
                    'updated_at'      => now(),
                ];
            }
            DB::table('route_segment_prices')->insert($inserts);

            // Update the pricing_matrix JSON cache on the route
            DB::table('transport_bus_routes')
                ->where('id', $routeId)
                ->update([
                    'pricing_matrix' => json_encode($data['prices']),
                    'updated_at'     => now(),
                ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Segment prices updated.',
            'data'    => $data['prices'],
        ]);
    }

    /**
     * GET ticket statistics for a route (for reporting dashboard).
     */
    public function ticketStats(string $routeId, Request $request): JsonResponse
    {
        $tripIds = DB::table('transport_bus_trips')
            ->where('route_id', $routeId)
            ->pluck('id');

        $totalIssued = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->where('ticket_status', 'issued')
            ->count();

        $totalBoarded = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->where('ticket_status', 'boarded')
            ->count();

        $totalBooked = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->count();

        $totalRevenue = DB::table('transport_seat_bookings')
            ->whereIn('trip_id', $tripIds)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->sum('ticket_price');

        $activeHolds = DB::table('transport_seat_holds')
            ->whereIn('trip_id', $tripIds)
            ->where('hold_expires_at', '>', now())
            ->count();

        $trips = DB::table('transport_bus_trips')
            ->where('route_id', $routeId)
            ->select('id', 'status', 'origin', 'destination', 'started_at', 'completed_at', 'scheduled_departure_at')
            ->orderByDesc('created_at')
            ->limit(20)
            ->get();

        return response()->json([
            'success' => true,
            'data'    => [
                'route_id'       => $routeId,
                'total_issued'   => $totalIssued,
                'total_boarded'  => $totalBoarded,
                'total_booked'   => $totalBooked,
                'total_revenue'  => (float) $totalRevenue,
                'active_holds'   => $activeHolds,
                'recent_trips'   => $trips,
            ],
        ]);
    }
}
