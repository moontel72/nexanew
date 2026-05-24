<?php

namespace App\Http\Controllers;

use App\Services\Factory\SupplyChainHandshakeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * NEXATRACE — FACTORY DISPATCH CONTROLLER
 * ========================================
 *
 * Dispatch creation, geofence handshake, and inventory transfer endpoints.
 * Wired in routes/panels/factory.php.
 *
 * TARGET MODULES: 3, 4, 5
 */

class FactoryDispatchController extends Controller
{
    public function __construct(
        private SupplyChainHandshakeService $handshake
    ) {}

    /**
     * POST /api/v1/factory/dispatch/create
     */
    public function createDispatch(Request $request): JsonResponse
    {
        $data = $request->validate([
            'batch_id' => ['required', 'string', 'max:100'],
            'driver_id' => ['required', 'string', 'max:100'],
            'storekeeper_id' => ['nullable', 'string', 'max:100'],
            'dest_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'dest_lng' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $code = 'DSP-' . strtoupper(Str::random(8));

        \Illuminate\Support\Facades\DB::table('factory_dispatches')->insert([
            'id' => (string) Str::uuid(),
            'batch_id' => $data['batch_id'],
            'driver_id' => $data['driver_id'],
            'storekeeper_id' => $data['storekeeper_id'] ?? null,
            'dispatch_gate_pass_code' => $code,
            'dest_lat' => $data['dest_lat'] ?? null,
            'dest_lng' => $data['dest_lng'] ?? null,
            'status' => 'in_transit',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'data' => ['gate_pass_code' => $code, 'status' => 'in_transit'],
        ], 201);
    }

    /**
     * POST /api/v1/factory/dispatch/handshake
     */
    public function initiateHandshake(Request $request): JsonResponse
    {
        $data = $request->validate([
            'dispatch_id' => ['required', 'string', 'max:100'],
            'driver_id' => ['required', 'string', 'max:100'],
            'storekeeper_id' => ['required', 'string', 'max:100'],
            'lat' => ['required', 'numeric'],
            'lng' => ['required', 'numeric'],
        ]);

        try {
            $result = $this->handshake->initiateHandshake(
                driverId: $data['driver_id'],
                dispatchId: $data['dispatch_id'],
                storekeeperId: $data['storekeeper_id'],
                clientLat: (float) $data['lat'],
                clientLng: (float) $data['lng'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/factory/dispatch/complete-transfer
     */
    public function completeTransfer(Request $request): JsonResponse
    {
        $data = $request->validate([
            'dispatch_id' => ['required', 'string', 'max:100'],
            'from_factory_id' => ['required', 'string', 'max:100'],
            'to_storekeeper_id' => ['required', 'string', 'max:100'],
            'scanned_items_count' => ['required', 'integer', 'min:1'],
            'batch_serials' => ['nullable', 'array'],
            'verified_by' => ['nullable', 'string', 'max:100'],
        ]);

        try {
            $result = $this->handshake->completeInventoryTransfer(
                dispatchId: $data['dispatch_id'],
                fromFactoryId: $data['from_factory_id'],
                toStorekeeperId: $data['to_storekeeper_id'],
                scannedItemsCount: (int) $data['scanned_items_count'],
                batchSerials: $data['batch_serials'] ?? [],
                verifiedBy: $data['verified_by'] ?? (string) $request->user()->id,
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }
}
