<?php

namespace App\Http\Controllers;

use App\Models\Transport\BusRoute;
use App\Models\Transport\BusRouteWaypoint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS ROUTE CONTROLLER
 * ==================================
 *
 * Full CRUD for transit routes and their ordered waypoints.
 * Supports Module 13B (Route Scheduler), 15A (Driver Manifest),
 * and 8V (Customer Tracking).
 *
 * ROUTES (registered in routes/panels/bus_fleet.php):
 *   GET    /api/v1/bus-fleet/routes
 *   POST   /api/v1/bus-fleet/routes
 *   GET    /api/v1/bus-fleet/routes/{id}
 *   PUT    /api/v1/bus-fleet/routes/{id}
 *   DELETE /api/v1/bus-fleet/routes/{id}
 *   POST   /api/v1/bus-fleet/routes/{id}/publish
 *   POST   /api/v1/bus-fleet/routes/{id}/waypoints
 *   GET    /api/v1/bus-fleet/routes/{id}/waypoints
 */

class BusRouteController extends Controller
{
    // ── ROUTE CRUD ──────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $carrierId = $request->get('_carrier_company_id');
        $query = BusRoute::with('waypoints');

        if ($carrierId) {
            $query->forCarrier($carrierId);
        }

        $routes = $query->latest()->get();

        return response()->json([
            'success' => true,
            'data' => $routes,
            'count' => $routes->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $carrierId = $request->get('_carrier_company_id');

        $data = $request->validate([
            'route_code' => ['required', 'string', 'max:50', 'unique:transport_bus_routes,route_code'],
            'display_name' => ['required', 'string', 'max:255'],
            'origin_city' => ['required', 'string', 'max:100'],
            'destination_city' => ['required', 'string', 'max:100'],
            'origin_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'origin_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'destination_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'destination_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'meta' => ['nullable', 'array'],
        ]);

        $route = BusRoute::create([
            'id' => (string) Str::uuid(),
            'route_code' => strtoupper($data['route_code']),
            'display_name' => $data['display_name'],
            'origin_city' => $data['origin_city'],
            'destination_city' => $data['destination_city'],
            'origin_lat' => $data['origin_lat'] ?? 0,
            'origin_lng' => $data['origin_lng'] ?? 0,
            'destination_lat' => $data['destination_lat'] ?? 0,
            'destination_lng' => $data['destination_lng'] ?? 0,
            'carrier_company_id' => $carrierId,
            'status' => BusRoute::STATUS_DRAFT,
        ]);

        return response()->json(['success' => true, 'data' => $route], 201);
    }

    public function show(string $id): JsonResponse
    {
        $route = BusRoute::with('waypoints')->findOrFail($id);

        return response()->json(['success' => true, 'data' => $route]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $route = BusRoute::findOrFail($id);

        if ($route->isPublished()) {
            return response()->json([
                'success' => false,
                'message' => 'Published routes cannot be modified. Archive and clone instead.',
            ], 422);
        }

        $data = $request->validate([
            'route_code' => ['sometimes', 'string', 'max:50', "unique:transport_bus_routes,route_code,{$id}"],
            'display_name' => ['sometimes', 'string', 'max:255'],
            'origin_city' => ['sometimes', 'string', 'max:100'],
            'destination_city' => ['sometimes', 'string', 'max:100'],
            'origin_lat' => ['sometimes', 'numeric'],
            'origin_lng' => ['sometimes', 'numeric'],
            'destination_lat' => ['sometimes', 'numeric'],
            'destination_lng' => ['sometimes', 'numeric'],
            'meta' => ['nullable', 'array'],
        ]);

        $route->update($data);

        return response()->json(['success' => true, 'data' => $route->fresh('waypoints')]);
    }

    public function destroy(string $id): JsonResponse
    {
        $route = BusRoute::findOrFail($id);
        $route->delete();

        return response()->json(['success' => true, 'message' => 'Route deleted']);
    }

    // ── PUBLISH ─────────────────────────────────────────

    public function publish(string $id): JsonResponse
    {
        $route = BusRoute::with('waypoints')->findOrFail($id);

        if ($route->waypoints->count() < 2) {
            return response()->json([
                'success' => false,
                'message' => 'Route must have at least 2 waypoints (origin + destination) to publish.',
            ], 422);
        }

        // Compute distance from Haversine (or fallback to pricing data)
        $totalKm = 0;
        $waypoints = $route->waypoints;
        for ($i = 1; $i < $waypoints->count(); $i++) {
            $totalKm += $this->haversineKm(
                $waypoints[$i - 1]->lat, $waypoints[$i - 1]->lng,
                $waypoints[$i]->lat, $waypoints[$i]->lng,
            );
        }

        // Fallback: sum distance_km from segment prices if coordinates are all zero
        if ($totalKm <= 0) {
            $totalKm = DB::table('route_segment_prices')
                ->where('route_id', $id)
                ->sum('distance_km');
        }

        $route->update([
            'status' => BusRoute::STATUS_PUBLISHED,
            'total_distance_km' => round($totalKm, 2),
            'estimated_duration_min' => (int) round(($totalKm / 60) * 60),
        ]);

        return response()->json(['success' => true, 'data' => $route->fresh('waypoints')]);
    }

    // ── UNPUBLISH ────────────────────────────────────────

    public function unpublish(string $id): JsonResponse
    {
        $route = BusRoute::findOrFail($id);

        if (! $route->isPublished()) {
            return response()->json([
                'success' => false,
                'message' => 'Route is not published.',
            ], 422);
        }

        $route->update(['status' => BusRoute::STATUS_DRAFT]);

        return response()->json([
            'success' => true,
            'message' => 'Route unpublished. You can now edit it.',
            'data' => $route->fresh('waypoints'),
        ]);
    }

    // ── WAYPOINT BATCH ──────────────────────────────────

    public function saveWaypoints(Request $request, string $routeId): JsonResponse
    {
        $route = BusRoute::findOrFail($routeId);

        if ($route->isPublished()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot modify waypoints of a published route.',
            ], 422);
        }

        $data = $request->validate([
            'waypoints' => ['required', 'array', 'min:1'],
            'waypoints.*.station_name' => ['required', 'string', 'max:255'],
            'waypoints.*.lat' => ['nullable', 'numeric', 'between:-90,90'],
            'waypoints.*.lng' => ['nullable', 'numeric', 'between:-180,180'],
            'waypoints.*.meta' => ['nullable', 'array'],
        ]);

        DB::transaction(function () use ($route, $data) {
            // Delete existing waypoints and replace
            $route->waypoints()->delete();

            $cumulativeKm = 0;
            $prevLat = $route->origin_lat;
            $prevLng = $route->origin_lng;

            foreach ($data['waypoints'] as $i => $wp) {
                $segKm = $this->haversineKm($prevLat, $prevLng, $wp['lat'], $wp['lng']);
                $cumulativeKm += $segKm;

                BusRouteWaypoint::create([
                    'id' => (string) Str::uuid(),
                    'route_id' => $route->id,
                    'stop_order' => $i,
                    'station_name' => $wp['station_name'],
                    'lat' => $wp['lat'],
                    'lng' => $wp['lng'],
                    'meta' => $wp['meta'] ?? null,
                    'distance_from_origin_km' => round($cumulativeKm, 2),
                    'estimated_min_from_origin' => (int) round(($cumulativeKm / 60) * 60),
                ]);

                $prevLat = $wp['lat'];
                $prevLng = $wp['lng'];
            }
        });

        return response()->json([
            'success' => true,
            'data' => $route->fresh('waypoints'),
            'message' => 'Waypoints saved.',
        ]);
    }

    // ── HELPERS ─────────────────────────────────────────

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadius = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }
}
