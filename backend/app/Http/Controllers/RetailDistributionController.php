<?php

namespace App\Http\Controllers;

use App\Services\Marketplace\RetailDistributionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — RETAIL DISTRIBUTION CONTROLLER
 * ============================================
 *
 * B2B order logistics dispatch, driver QR pickup verification,
 * and shopkeeper retail stock-in endpoints.
 *
 * Wired in routes/panels/marketplace.php and truck_fleet.php.
 */

class RetailDistributionController extends Controller
{
    public function __construct(
        private RetailDistributionService $retail
    ) {}

    /**
     * POST /api/v1/marketplace/retail/dispatch
     */
    public function dispatchShipment(Request $request): JsonResponse
    {
        $data = $request->validate([
            'order_id' => ['required', 'string', 'max:100'],
            'driver_id' => ['required', 'string', 'max:100'],
            'warehouse_id' => ['required', 'string', 'max:100'],
            'invoice_items' => ['required', 'array', 'min:1'],
            'warehouse_lat' => ['nullable', 'numeric'],
            'warehouse_lng' => ['nullable', 'numeric'],
            'shop_lat' => ['nullable', 'numeric'],
            'shop_lng' => ['nullable', 'numeric'],
        ]);

        $result = $this->retail->dispatchRetailShipment(
            orderId: $data['order_id'],
            driverId: $data['driver_id'],
            warehouseId: $data['warehouse_id'],
            invoiceItems: $data['invoice_items'],
            warehouseLat: isset($data['warehouse_lat']) ? (float) $data['warehouse_lat'] : null,
            warehouseLng: isset($data['warehouse_lng']) ? (float) $data['warehouse_lng'] : null,
            shopLat: isset($data['shop_lat']) ? (float) $data['shop_lat'] : null,
            shopLng: isset($data['shop_lng']) ? (float) $data['shop_lng'] : null,
        );

        return response()->json(['success' => true, 'data' => $result], 201);
    }

    /**
     * POST /api/v1/truck-fleet/retail/verify-pickup
     */
    public function verifyPickup(Request $request): JsonResponse
    {
        $data = $request->validate([
            'delivery_id' => ['required', 'string', 'max:100'],
            'secure_token' => ['required', 'string', 'max:100'],
            'scanned_items' => ['required', 'array', 'min:1'],
            'driver_id' => ['required', 'string', 'max:100'],
        ]);

        try {
            $result = $this->retail->verifyDriverPickupScan(
                deliveryId: $data['delivery_id'],
                secureToken: $data['secure_token'],
                scannedItems: $data['scanned_items'],
                driverId: $data['driver_id'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/marketplace/retail/stock-in
     */
    public function stockIn(Request $request): JsonResponse
    {
        $data = $request->validate([
            'delivery_id' => ['required', 'string', 'max:100'],
            'secure_token' => ['required', 'string', 'max:100'],
            'shopkeeper_id' => ['required', 'string', 'max:100'],
            'truck_owner_id' => ['required', 'string', 'max:100'],
            'freight_amount' => ['required', 'numeric', 'min:0'],
        ]);

        try {
            $result = $this->retail->executeShopkeeperStockIn(
                deliveryId: $data['delivery_id'],
                secureToken: $data['secure_token'],
                shopkeeperId: $data['shopkeeper_id'],
                truckOwnerId: $data['truck_owner_id'],
                freightAmount: (float) $data['freight_amount'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }
}
