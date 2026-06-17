<?php

namespace App\Http\Controllers;

use App\Models\Transport\BusTrip;
use App\Services\Transport\BusLiveTrackingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS DISPATCH CONTROLLER
 * =====================================
 *
 * Driver-facing API for trip activation, GPS coordinate
 * streaming, and trip completion. Admin-facing API for
 * viewing active fleet status.
 *
 * TARGET MODULES: 13C, 15A, 15B
 *
 * SAFETY: Entirely new controller. Wired in routes/panels/bus_fleet.php.
 */

class BusDispatchController extends Controller
{
    public function __construct(
        private BusLiveTrackingService $tracking
    ) {}

    // ─── TRIP CRUD (Admin / Owner) ──────────────────────

    /**
     * POST /api/v1/bus-fleet/trips
     */
    public function createTrip(Request $request): JsonResponse
    {
        $data = $request->validate([
            'bus_id' => ['required', 'string', 'max:100'],
            'origin' => ['required', 'string', 'max:150'],
            'destination' => ['required', 'string', 'max:150'],
            'waypoints' => ['nullable', 'array'],
            'route_id' => ['nullable', 'string', 'max:100'],
        ]);

        $trip = BusTrip::create([
            'id' => (string) Str::uuid(),
            'route_id' => $data['route_id'] ?? null,
            'bus_id' => $data['bus_id'],
            'origin' => $data['origin'],
            'destination' => $data['destination'],
            'waypoints' => $data['waypoints'] ?? [],
            'status' => BusTrip::STATUS_SCHEDULED,
        ]);

        return response()->json(['success' => true, 'data' => $trip], 201);
    }

    /**
     * GET /api/v1/bus-fleet/trips/active
     */
    public function activeTrips(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => BusTrip::active()->orderByDesc('started_at')->get(),
        ]);
    }

    // ─── DRIVER ACTIONS ─────────────────────────────────

    /**
     * POST /api/v1/bus-fleet/driver/start-trip/{id}
     */
    public function startTrip(string $id, Request $request): JsonResponse
    {
        $driverId = (string) $request->user()->global_identity_id;

        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        try {
            $trip = $this->tracking->startTrip($id, $driverId, (float) $data['lat'], (float) $data['lng']);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $trip]);
    }

    /**
     * POST /api/v1/bus-fleet/driver/update-location/{id}
     */
    public function updateLocation(string $id, Request $request): JsonResponse
    {
        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
            'speed' => ['required', 'numeric', 'min:0'],
            'waypoint_index' => ['nullable', 'integer', 'min:0'],
        ]);

        try {
            $trip = $this->tracking->updateBusCoordinates(
                tripId: $id,
                lat: (float) $data['lat'],
                lng: (float) $data['lng'],
                speed: (float) $data['speed'],
                waypointIndex: isset($data['waypoint_index']) ? (int) $data['waypoint_index'] : null,
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $trip]);
    }

    /**
     * POST /api/v1/bus-fleet/driver/complete-trip/{id}
     */
    public function completeTrip(string $id, Request $request): JsonResponse
    {
        $data = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        $trip = $this->tracking->completeTrip($id, (float) $data['lat'], (float) $data['lng']);

        return response()->json(['success' => true, 'data' => $trip]);
    }
}
