<?php

namespace App\Services\Marketplace;

use App\Services\Redis\RedisCacheService;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — RESELLER PORTAL SERVICE (v2)
 * ==========================================
 *
 * High-speed dashboard + MSRP enforcement engine.
 * TARGET MODULES: 6, 12, 12I
 */

class ResellerPortalService
{
    public function __construct(
        private RedisCacheService $cache
    ) {}

    public function getDashboardMetrics(string $resellerId): array
    {
        $cacheKey = "reseller:dashboard:{$resellerId}";
        return $this->cache->remember($cacheKey, 60, function () use ($resellerId) {
            return [
                'active_orders' => $this->activeOrders($resellerId),
                'warehouse_inventory' => $this->warehouseInventory($resellerId),
                'retail_ledger' => $this->retailLedgerSummary($resellerId),
                'delivery_tokens' => $this->deliveryTokens($resellerId),
                'wallet_balance' => $this->walletBalance($resellerId),
                'updated_at' => now()->toIso8601String(),
            ];
        });
    }

    // ─── MSRP ENFORCEMENT (Module 12I Part 1) ──────────

    /**
     * Validate MSRP pricing on checkout. Throws if violated.
     */
    public function enforceMSRP(string $listingId, float $requestedSellPrice): void
    {
        $listing = DB::table('marketplace_product_listings')
            ->where('id', $listingId)->firstOrFail();

        if (! ($listing->is_msrp_enforced ?? false)) {
            return; // Open-margin allowed
        }

        $allowedPrice = (float) ($listing->reseller_sell_price ?? $listing->base_price ?? 0);

        if (abs($requestedSellPrice - $allowedPrice) > 0.01) {
            throw new \RuntimeException(
                "MSRP Violation: Price is locked at Rs. {$allowedPrice}. " .
                "You cannot modify it by even Re. 1."
            );
        }
    }

    // ─── PRIVATE METRICS ───────────────────────────────

    private function activeOrders(string $resellerId): array
    {
        $orders = DB::table('reseller_orders')
            ->where('reseller_id', $resellerId)
            ->whereIn('status', ['pending', 'confirmed', 'processing'])
            ->select('id', 'status', 'total_amount', 'created_at')
            ->orderByDesc('created_at')->limit(10)->get();
        return ['count' => $orders->count(), 'recent' => $orders->toArray()];
    }

    private function warehouseInventory(string $resellerId): array
    {
        $items = DB::table('marketplace_product_listings as pl')
            ->join('marketplace_storefronts as sf', 'pl.storefront_id', '=', 'sf.id')
            ->where('sf.company_id', $resellerId)
            ->where('pl.is_active', true)
            ->where('pl.available_quantity', '>', 0)
            ->select('pl.id', 'pl.listing_title', 'pl.available_quantity', 'pl.base_price')
            ->orderByDesc('pl.available_quantity')->limit(20)->get();
        return [
            'total_skus' => $items->count(),
            'total_stock_value' => $items->sum(fn($i) => $i->available_quantity * $i->base_price),
            'items' => $items->toArray(),
        ];
    }

    private function retailLedgerSummary(string $resellerId): array
    {
        $ledger = DB::table('retail_inventory_ledger')
            ->where('shopkeeper_id', $resellerId)
            ->selectRaw('COUNT(*) as total_entries, SUM(quantity) as total_items, MAX(credited_at) as last_credited')
            ->first();
        return [
            'total_entries' => (int) ($ledger->total_entries ?? 0),
            'total_items' => (int) ($ledger->total_items ?? 0),
            'last_credited' => $ledger->last_credited ?? null,
        ];
    }

    private function deliveryTokens(string $resellerId): array
    {
        $deliveries = DB::table('retail_deliveries')
            ->whereIn('status', ['in_transit', 'arrived'])
            ->select('id', 'order_id', 'status', 'created_at')
            ->orderByDesc('created_at')->limit(10)->get();
        return [
            'in_transit' => $deliveries->where('status', 'in_transit')->count(),
            'arrived' => $deliveries->where('status', 'arrived')->count(),
            'recent' => $deliveries->toArray(),
        ];
    }

    private function walletBalance(string $resellerId): array
    {
        $wallet = DB::table('financial_wallets')
            ->where('owner_id', $resellerId)->where('owner_type', 'reseller')
            ->where('wallet_type', 'main')->first();
        return [
            'balance' => (float) ($wallet->balance ?? 0),
            'available' => (float) ($wallet->available_balance ?? 0),
            'held' => (float) ($wallet->held_balance ?? 0),
        ];
    }
}
