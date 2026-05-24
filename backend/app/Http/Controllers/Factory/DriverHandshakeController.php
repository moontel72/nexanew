<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Services\Handshake\HandshakeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — DRIVER HANDSHAKE CONTROLLER
 * ========================================
 *
 * REST API for the Factory Driver ↔ Store Keeper inbound handshake.
 *
 * SAFETY:
 *   - ENTIRELY NEW controller. Does NOT modify DriverController,
 *     StoreKeeperController, or any existing endpoint.
 *   - Uses HandshakeService (new) → RedisCacheService (new) →
 *     WebSocket Events (new). All independently built.
 *   - Existing trip/delivery logic in DriverController continues
 *     to operate synchronously without change.
 *
 * ENDPOINTS:
 *   POST /api/v1/factory/driver/handshake/arrived
 *   GET  /api/v1/factory/driver/handshake/{tripId}
 *   POST /api/v1/factory/driver/handshake/{tripId}/acknowledge
 *
 * TARGET MODULES: 4A, 4C, 4D, 5A, 5N
 */

class DriverHandshakeController extends Controller
{
    public function __construct(
        private HandshakeService $handshake
    ) {}

    /**
     * POST /api/v1/factory/driver/handshake/arrived
     *
     * Called by the Flutter Driver App when FactoryDriverGeofenceBloc
     * detects scanUnlocked = true (driver within 100 m of delivery point).
     *
     * Request body:
     * {
     *   "trip_id": "uuid",
     *   "driver_id": "uuid",
     *   "store_keeper_id": "uuid",
     *   "lat": 31.5204,
     *   "lng": 74.3587,
     *   "distance_meters": 45.2,
     *   "driver_name": "Ali",
     *   "delivery_address": "123 Main St, Lahore",
     *   "product_summary": "Bundle #B-0042"
     * }
     */
    public function arrived(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'trip_id'         => ['required', 'string', 'max:100'],
            'driver_id'       => ['required', 'string', 'max:100'],
            'store_keeper_id' => ['required', 'string', 'max:100'],
            'lat'             => ['required', 'numeric', 'between:-90,90'],
            'lng'             => ['required', 'numeric', 'between:-180,180'],
            'distance_meters' => ['required', 'numeric', 'min:0', 'max:500'],
            'driver_name'     => ['nullable', 'string', 'max:200'],
            'delivery_address' => ['nullable', 'string', 'max:500'],
            'product_summary'  => ['nullable', 'string', 'max:500'],
        ]);

        $meta = array_filter([
            'driver_name' => $data['driver_name'] ?? null,
            'delivery_address' => $data['delivery_address'] ?? null,
            'product_summary' => $data['product_summary'] ?? null,
        ]);

        $handshake = $this->handshake->onDriverArrived(
            tripId: (string) $data['trip_id'],
            driverId: (string) $data['driver_id'],
            storeKeeperId: (string) $data['store_keeper_id'],
            companyId: $companyId,
            lat: (float) $data['lat'],
            lng: (float) $data['lng'],
            distanceMeters: (float) $data['distance_meters'],
            meta: $meta,
        );

        Log::info('DriverHandshakeController: driver arrived', [
            'trip_id' => $data['trip_id'],
            'company_id' => $companyId,
            'distance_meters' => $data['distance_meters'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Store Keeper has been alerted. Handshake active.',
            'data' => [
                'handshake_id' => $handshake['handshake_id'],
                'status' => $handshake['status'],
                'scan_unlocked' => $handshake['scan_unlocked'],
                'store_keeper_alerted' => true,
            ],
        ], 200);
    }

    /**
     * GET /api/v1/factory/driver/handshake/{tripId}
     *
     * Poll the current handshake state. Used by both Driver and Store Keeper
     * apps to check whether the counterparty has acknowledged.
     */
    public function status(string $tripId): JsonResponse
    {
        $state = $this->handshake->getHandshakeState($tripId);

        if (! $state) {
            return response()->json([
                'success' => true,
                'data' => [
                    'trip_id' => $tripId,
                    'handshake_active' => false,
                    'status' => 'no_handshake',
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $state,
        ]);
    }

    /**
     * POST /api/v1/factory/driver/handshake/{tripId}/acknowledge
     *
     * Called by the Store Keeper App when they acknowledge the
     * incoming driver handshake. Confirms the Store Keeper is
     * ready for the physical validation scan.
     *
     * Request body:
     * {
     *   "store_keeper_id": "uuid",
     *   "store_keeper_name": "Ahmed"
     * }
     */
    public function acknowledge(string $tripId, Request $request): JsonResponse
    {
        $data = $request->validate([
            'store_keeper_id' => ['required', 'string', 'max:100'],
            'store_keeper_name' => ['nullable', 'string', 'max:200'],
        ]);

        $meta = array_filter([
            'store_keeper_name' => $data['store_keeper_name'] ?? null,
        ]);

        $state = $this->handshake->onStoreKeeperAcknowledged(
            tripId: $tripId,
            storeKeeperId: (string) $data['store_keeper_id'],
            meta: $meta,
        );

        if (! $state) {
            return response()->json([
                'success' => false,
                'message' => 'No active handshake found for this trip.',
            ], 404);
        }

        Log::info('DriverHandshakeController: store keeper acknowledged', [
            'trip_id' => $tripId,
            'store_keeper_id' => $data['store_keeper_id'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Handshake acknowledged. Ready for scan.',
            'data' => $state,
        ]);
    }
}
