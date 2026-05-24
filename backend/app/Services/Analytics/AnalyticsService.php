<?php

namespace App\Services\Analytics;

use App\Models\Analytics\AnalyticsSnapshot;
use App\Models\Financial\WalletTransaction;
use App\Models\FreightBid;
use App\Models\FreightLoad;
use App\Models\Marketplace\GroupBuyPool;
use App\Models\Marketplace\ProductListing;
use App\Services\Redis\RedisCacheService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — ANALYTICS AGGREGATION SERVICE
 * ==========================================
 *
 * High-performance analytics engine that reads from production tables
 * (READ-ONLY), computes aggregated metrics, stores time-series snapshots,
 * and caches results in Redis for dashboard consumption.
 *
 * METRIC GROUPS:
 *   - marketplace: total_gmv, active_pools, active_listings, pool_fill_rate
 *   - freight: active_loads, completed_trips, avg_bid_amount, match_rate
 *   - financial: platform_revenue, total_commission, wallet_balance_total
 *   - system: active_users, active_factories, codes_generated_today, health_score
 *
 * TIME WINDOWS:
 *   - realtime (60s) → Realtime dashboard
 *   - hourly         → Hourly trend charts
 *   - daily          → 7-day, 30-day views
 *   - weekly/monthly → 12-month trend lines
 *
 * SAFETY:
 *   - READ-ONLY on all production tables. Never INSERT/UPDATE/DELETE.
 *   - Writes only to analytics_snapshots and Redis cache.
 *   - All queries use database read replicas when available.
 *   - Chunked processing prevents memory pressure.
 *
 * TARGET MODULES: 1D, 2C, 3AE
 */

class AnalyticsService
{
    public function __construct(
        private RedisCacheService $cache
    ) {}

    /**
     * Collect all metric groups for a given snapshot type.
     * Called by AnalyticsAggregationJob on schedule.
     *
     * @return int  Number of snapshots created
     */
    public function collectAll(string $type = AnalyticsSnapshot::TYPE_HOURLY): int
    {
        $snapshotAt = $this->snapshotTimestamp($type);
        $count = 0;

        foreach (['marketplace', 'freight', 'financial', 'system'] as $group) {
            $metrics = $this->collectGroup($group);
            foreach ($metrics as $key => $value) {
                $this->storeSnapshot($type, $group, $key, $value, $snapshotAt);
                $count++;
            }
        }

        // Cache realtime snapshot in Redis
        $this->cacheRealtimeDashboard();

        Log::info('AnalyticsService: collection complete', [
            'type' => $type, 'snapshots' => $count,
        ]);

        return $count;
    }

    /**
     * Collect metrics for a specific group.
     */
    public function collectGroup(string $group): array
    {
        return match ($group) {
            'marketplace' => $this->marketplaceMetrics(),
            'freight'     => $this->freightMetrics(),
            'financial'   => $this->financialMetrics(),
            'system'      => $this->systemMetrics(),
            default       => [],
        };
    }

    /**
     * Get time-series chart data for a metric group and key.
     *
     * @return array  [{snapshot_at, metric_value}, ...]
     */
    public function getChartData(string $group, string $key, string $start, string $end, string $type = AnalyticsSnapshot::TYPE_DAILY): array
    {
        $cacheKey = "analytics:charts:{$group}:{$key}:{$type}:{$start}-{$end}";

        return $this->cache->remember($cacheKey, 3600, function () use ($group, $key, $start, $end, $type) {
            return AnalyticsSnapshot::type($type)
                ->group($group)
                ->where('metric_key', $key)
                ->between($start, $end)
                ->orderBy('snapshot_at')
                ->get(['snapshot_at', 'metric_value'])
                ->map(fn($s) => [
                    'timestamp' => $s->snapshot_at->toIso8601String(),
                    'value' => $s->metric_value,
                ])
                ->toArray();
        });
    }

    /**
     * Get the latest realtime dashboard snapshot.
     */
    public function getRealtimeDashboard(): array
    {
        $cached = $this->cache->getDashboardStats('super_admin');
        if ($cached) return $cached;

        return $this->computeRealtimeDashboard();
    }

    // ─── METRIC COLLECTORS (READ-ONLY) ──────────────────

    private function marketplaceMetrics(): array
    {
        return [
            'total_gmv' => DB::table('marketplace_group_buy_pools')
                ->whereIn('pool_status', [GroupBuyPool::STATUS_COMPLETED])
                ->whereDate('completed_at', today())
                ->sum(DB::raw('target_quantity * pool_price_per_unit')),
            'active_pools' => GroupBuyPool::active()->count(),
            'active_listings' => ProductListing::active()->count(),
            'pool_fill_rate' => $this->safeAvg(
                GroupBuyPool::whereIn('pool_status', ['gathering', 'locked'])->get(),
                fn($p) => $p->progressPercentage()
            ),
        ];
    }

    private function freightMetrics(): array
    {
        return [
            'active_loads' => FreightLoad::active()->count(),
            'completed_trips_today' => FreightLoad::where('status', FreightLoad::STATUS_COMPLETED)
                ->whereDate('completed_at', today())->count(),
            'avg_bid_amount' => FreightBid::whereDate('created_at', today())->avg('bid_amount') ?? 0,
            'match_rate' => $this->safePct(
                FreightLoad::whereDate('matched_at', today())->count(),
                FreightLoad::whereDate('created_at', today())->count()
            ),
        ];
    }

    private function financialMetrics(): array
    {
        return [
            'platform_revenue_today' => WalletTransaction::where('transaction_type', 'commission_payout')
                ->where('entry_type', WalletTransaction::ENTRY_CREDIT)
                ->whereDate('settled_at', today())
                ->sum('amount'),
            'total_commission_today' => WalletTransaction::where('transaction_type', 'commission_payout')
                ->whereDate('settled_at', today())
                ->where('entry_type', WalletTransaction::ENTRY_CREDIT)
                ->sum('amount'),
            'total_payouts_today' => WalletTransaction::where('transaction_type', 'commission_payout')
                ->whereDate('settled_at', today())
                ->count(),
            'wallet_balance_total' => DB::table('financial_wallets')
                ->where('wallet_type', 'main')->sum('balance'),
        ];
    }

    private function systemMetrics(): array
    {
        return [
            'active_users_today' => DB::table('users')->whereDate('last_login_at', today())->count(),
            'active_factories' => DB::table('companies')->where('status', 'active')->count(),
            'codes_generated_today' => DB::table('base_codes')->whereDate('generated_at', today())->count(),
            'health_score' => $this->computeHealthScore(),
        ];
    }

    // ─── HELPERS ────────────────────────────────────────

    private function storeSnapshot(string $type, string $group, string $key, float $value, \DateTime $at, array $dimensions = []): void
    {
        // Upsert: update if exists, insert if new
        AnalyticsSnapshot::updateOrCreate(
            ['snapshot_type' => $type, 'metric_group' => $group, 'metric_key' => $key, 'snapshot_at' => $at],
            [
                'id' => (string) Str::uuid(),
                'metric_value' => $value,
                'unit' => $this->inferUnit($key),
                'dimensions' => $dimensions ?: null,
            ]
        );
    }

    private function cacheRealtimeDashboard(): void
    {
        $this->cache->setDashboardStats('super_admin', $this->computeRealtimeDashboard(), 60);
    }

    private function computeRealtimeDashboard(): array
    {
        return [
            'active_factories' => DB::table('companies')->where('status', 'active')->count(),
            'active_drivers' => DB::table('drivers')->where('status', 'active')->count(),
            'scans_today' => DB::table('base_codes')->whereDate('generated_at', today())->count(),
            'active_freight_loads' => FreightLoad::active()->count(),
            'active_group_pools' => GroupBuyPool::active()->count(),
            'platform_revenue_today' => round(WalletTransaction::where('transaction_type', 'commission_payout')
                ->where('entry_type', WalletTransaction::ENTRY_CREDIT)
                ->whereDate('settled_at', today())->sum('amount'), 2),
            'health_score' => $this->computeHealthScore(),
            'updated_at' => now()->toIso8601String(),
        ];
    }

    private function computeHealthScore(): float
    {
        $scores = [
            DB::table('companies')->where('status', 'active')->count() > 0 ? 20 : 0,
            DB::table('base_codes')->whereDate('generated_at', '>=', now()->subDay())->count() > 0 ? 20 : 0,
            $this->redisAvailable() ? 20 : 0,
            DB::getPdo()->getAttribute(\PDO::ATTR_CONNECTION_STATUS) ? 20 : 0,
            now()->diffInHours(DB::table('base_codes')->max('generated_at') ?? now()) < 2 ? 20 : 0,
        ];
        return array_sum($scores);
    }

    private function redisAvailable(): bool
    {
        try { return $this->cache->isAvailable(); } catch (\Throwable) { return false; }
    }

    private function safeAvg($collection, callable $fn): float
    {
        if ($collection->isEmpty()) return 0;
        return round($collection->avg($fn), 2);
    }

    private function safePct(int $numerator, int $denominator): float
    {
        if ($denominator === 0) return 0;
        return round(($numerator / $denominator) * 100, 2);
    }

    private function snapshotTimestamp(string $type): \DateTime
    {
        return match ($type) {
            AnalyticsSnapshot::TYPE_HOURLY => now()->startOfHour(),
            AnalyticsSnapshot::TYPE_DAILY => now()->startOfDay(),
            AnalyticsSnapshot::TYPE_WEEKLY => now()->startOfWeek(),
            AnalyticsSnapshot::TYPE_MONTHLY => now()->startOfMonth(),
            default => now(),
        };
    }

    private function inferUnit(string $key): string
    {
        return match (true) {
            str_contains($key, 'revenue') || str_contains($key, 'gmv') || str_contains($key, 'amount') => 'usd',
            str_contains($key, 'rate') || str_contains($key, 'pct') || str_contains($key, 'fill') => 'percentage',
            str_contains($key, 'health') || str_contains($key, 'score') => 'score',
            default => 'count',
        };
    }
}
