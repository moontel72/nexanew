<?php

namespace App\Services\Marketplace;

use App\Jobs\CommissionPayoutJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — RETAIL DISTRIBUTION SERVICE
 * =========================================
 *
 * Handles B2B order logistics, driver QR pickup verification,
 * and shopkeeper retail stock-in with atomic ownership transfer.
 *
 * FLOW:
 *   1. Shopkeeper places bulk order (Module 12 Marketplace)
 *   2. dispatchRetailShipment() → creates delivery + secure_token
 *   3. Driver scans warehouse QR → verifyDriverPickupScan() validates items
 *   4. Driver delivers → Shopkeeper scans receipt QR
 *   5. executeShopkeeperStockIn() → atomic: complete delivery + release
 *      freight payout to Truck Owner + credit shopkeeper retail inventory
 *
 * SAFETY:
 *   - DB::transaction() with lockForUpdate() on delivery + order.
 *   - QR scan mismatch triggers fraud alert.
 *   - Payout via existing CommissionPayoutJob (Step 8).
 *   - Entirely NEW service. Zero modification to existing code.
 *
 * TARGET MODULES: 6, 7, 10, 11, 12
 */

class RetailDistributionService
{
    /**
     * Dispatch a retail shipment after marketplace order is locked.
     */
    public function dispatchRetailShipment(
        string $orderId,
        string $driverId,
        string $warehouseId,
        array $invoiceItems,
        ?float $warehouseLat = null,
        ?float $warehouseLng = null,
        ?float $shopLat = null,
        ?float $shopLng = null,
    ): array {
        $deliveryId = (string) Str::uuid();
        $token = 'RTD-' . strtoupper(Str::random(12));

        DB::table('retail_deliveries')->insert([
            'id' => $deliveryId,
            'order_id' => $orderId,
            'driver_id' => $driverId,
            'warehouse_id' => $warehouseId,
            'delivery_secure_token' => $token,
            'status' => 'pending_pickup',
            'invoice_items' => json_encode($invoiceItems),
            'warehouse_lat' => $warehouseLat,
            'warehouse_lng' => $warehouseLng,
            'shop_lat' => $shopLat,
            'shop_lng' => $shopLng,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Log::info('RetailDistributionService: shipment dispatched', [
            'delivery_id' => $deliveryId, 'order_id' => $orderId,
            'secure_token' => $token, 'driver_id' => $driverId,
        ]);

        return [
            'delivery_id' => $deliveryId,
            'secure_token' => $token,
            'status' => 'pending_pickup',
        ];
    }

    /**
     * Driver scans warehouse QR → verify items match invoice.
     */
    public function verifyDriverPickupScan(
        string $deliveryId,
        string $secureToken,
        array $scannedItems,
        string $driverId
    ): array {
        return DB::transaction(function () use ($deliveryId, $secureToken, $scannedItems, $driverId) {
            $delivery = DB::table('retail_deliveries')
                ->where('id', $deliveryId)->lockForUpdate()->firstOrFail();

            if ($delivery->delivery_secure_token !== $secureToken) {
                throw new \RuntimeException('Secure token mismatch. Pickup verification failed.');
            }

            if ($delivery->status !== 'pending_pickup') {
                throw new \RuntimeException("Invalid state for pickup. Status: {$delivery->status}");
            }

            // Verify scanned items match invoice
            $invoiceItems = json_decode($delivery->invoice_items ?? '[]', true);
            if (! $this->itemsMatch($invoiceItems, $scannedItems)) {
                Log::warning('RetailDistributionService: QR scan mismatch — possible fraud', [
                    'delivery_id' => $deliveryId, 'driver_id' => $driverId,
                    'invoice' => $invoiceItems, 'scanned' => $scannedItems,
                ]);
                throw new \RuntimeException('Scanned items do not match invoice. Dispatch blocked. Fraud alert triggered.');
            }

            DB::table('retail_deliveries')->where('id', $deliveryId)->update([
                'status' => 'in_transit',
                'scanned_items' => json_encode($scannedItems),
                'pickup_scanned_at' => now(),
                'updated_at' => now(),
            ]);

            Log::info('RetailDistributionService: driver pickup verified — in transit', [
                'delivery_id' => $deliveryId, 'driver_id' => $driverId,
            ]);

            return ['delivery_id' => $deliveryId, 'status' => 'in_transit'];
        });
    }

    /**
     * Shopkeeper scans driver receipt QR → atomic stock-in + payout release.
     */
    public function executeShopkeeperStockIn(
        string $deliveryId,
        string $secureToken,
        string $shopkeeperId,
        string $truckOwnerId,
        float $freightAmount
    ): array {
        return DB::transaction(function () use (
            $deliveryId, $secureToken, $shopkeeperId, $truckOwnerId, $freightAmount
        ) {
            $delivery = DB::table('retail_deliveries')
                ->where('id', $deliveryId)->lockForUpdate()->firstOrFail();

            if ($delivery->delivery_secure_token !== $secureToken) {
                throw new \RuntimeException('Secure token mismatch. Stock-in verification failed.');
            }

            if ($delivery->status !== 'in_transit' && $delivery->status !== 'arrived') {
                throw new \RuntimeException("Invalid state for stock-in. Status: {$delivery->status}");
            }

            $now = now();

            // Mark delivery completed
            DB::table('retail_deliveries')->where('id', $deliveryId)->update([
                'status' => 'completed',
                'shopkeeper_id' => $shopkeeperId,
                'delivery_scanned_at' => $now,
                'completed_at' => $now,
                'updated_at' => $now,
            ]);

            // Transfer ownership: credit shopkeeper retail inventory ledger
            $scannedItems = json_decode($delivery->scanned_items ?? '[]', true);
            $this->creditShopkeeperInventory($shopkeeperId, $scannedItems, $now);

            // Release freight payout to Truck Owner via Step 8
            CommissionPayoutJob::dispatch(
                module: 'retail_delivery',
                payerType: 'shop_keeper',
                payerId: $shopkeeperId,
                payeeId: $truckOwnerId,
                payeeType: 'truck_owner',
                amount: $freightAmount,
                referenceId: $deliveryId,
                referenceType: 'retail_delivery',
            );

            Log::info('RetailDistributionService: stock-in completed — payout dispatched', [
                'delivery_id' => $deliveryId, 'shopkeeper_id' => $shopkeeperId,
                'truck_owner_id' => $truckOwnerId, 'freight_amount' => $freightAmount,
            ]);

            return [
                'delivery_id' => $deliveryId,
                'status' => 'completed',
                'items_credited' => count($scannedItems),
                'freight_payout_dispatched' => true,
            ];
        });
    }

    // ─── HELPERS ────────────────────────────────────────

    private function itemsMatch(array $invoice, array $scanned): bool
    {
        if (empty($invoice) && empty($scanned)) return true;
        if (count($invoice) !== count($scanned)) return false;

        $invoiceIds = array_column($invoice, 'product_id');
        $scannedIds = array_column($scanned, 'product_id');
        sort($invoiceIds);
        sort($scannedIds);
        return $invoiceIds === $scannedIds;
    }

    private function creditShopkeeperInventory(string $shopkeeperId, array $items, $timestamp): void
    {
        foreach ($items as $item) {
            DB::table('retail_inventory_ledger')->insert([
                'id' => (string) Str::uuid(),
                'shopkeeper_id' => $shopkeeperId,
                'product_id' => $item['product_id'] ?? null,
                'batch_serial' => $item['batch_serial'] ?? null,
                'quantity' => $item['quantity'] ?? 1,
                'source' => 'retail_delivery',
                'credited_at' => $timestamp,
                'created_at' => $timestamp,
                'updated_at' => $timestamp,
            ]);
        }
    }
}
