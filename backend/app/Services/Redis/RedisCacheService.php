<?php

namespace App\Services\Redis;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — STANDALONE REDIS CACHE SERVICE
 * ============================================
 *
 * SAFETY RULES (per Supreme Master Spec):
 *  - This service is an INDEPENDENT, OPT-IN class.
 *  - It does NOT modify any existing controller, model, or endpoint.
 *  - It is designed for NEW modules only: B2B Marketplace (12), Bus Tracking (13-16),
 *    Fleet Telemetry (9H), and Super Admin analytics (1D).
 *  - If Redis is unavailable, ALL methods degrade gracefully — returning null
 *    or empty defaults without throwing exceptions.
 *  - Feature-flag gated: callers should check `isAvailable()` before use.
 *
 * USAGE (caller side):
 *   $cache = app(RedisCacheService::class);
 *   if ($cache->isAvailable()) {
 *       $cache->setDashboardStats('super_admin', $data);
 *   }
 */

class RedisCacheService
{
    /**
     * Cache store name. Uses the 'redis' store from config/cache.php.
     * Falls back to 'array' in testing/CI environments.
     */
    private string $store;

    /**
     * Default TTL in seconds.
     */
    private int $defaultTtl;

    public function __construct()
    {
        $this->store = config('cache.stores.redis') ? 'redis' : 'array';
        $this->defaultTtl = (int) config('nexatrace.cache.default_ttl', 300);
    }

    // ─────────────────────────────────────────────────
    // 1. HEALTH & AVAILABILITY
    // ─────────────────────────────────────────────────

    /**
     * Check whether the Redis cache backend is reachable.
     * Callers SHOULD gate all cache operations behind this check.
     */
    public function isAvailable(): bool
    {
        try {
            Cache::store($this->store)->put('nexatrace:health:ping', 1, 10);
            return Cache::store($this->store)->get('nexatrace:health:ping') === 1;
        } catch (\Throwable $e) {
            Log::warning('RedisCacheService: Redis unavailable — degraded to no-op mode.', [
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Returns the active cache store name (for logging / debugging).
     */
    public function getStoreName(): string
    {
        return $this->store;
    }

    // ─────────────────────────────────────────────────
    // 2. DASHBOARD ANALYTICS CACHE (Module 1D)
    // ─────────────────────────────────────────────────

    /**
     * Cache Super Admin dashboard aggregate stats.
     *
     * @param array<string, mixed> $stats  e.g. ['active_factories' => 42, 'scans_today' => 15823, ...]
     * @param int|null             $ttl    TTL in seconds (default: 60 s for real-time dashboards)
     */
    public function setDashboardStats(string $scope, array $stats, ?int $ttl = null): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        $key = "dashboard:{$scope}:stats";
        Cache::store($this->store)->put($key, $stats, $ttl ?? 60);
    }

    /**
     * Retrieve cached dashboard stats. Returns null if uncached or unavailable.
     *
     * @return array<string, mixed>|null
     */
    public function getDashboardStats(string $scope): ?array
    {
        if (! $this->isAvailable()) {
            return null;
        }
        $key = "dashboard:{$scope}:stats";
        return Cache::store($this->store)->get($key);
    }

    /**
     * Invalidate dashboard cache for a given scope.
     */
    public function forgetDashboardStats(string $scope): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Cache::store($this->store)->forget("dashboard:{$scope}:stats");
    }

    /**
     * Cache per-factory analytics (code throughput, product counts, etc.).
     * TTL defaults to 300 s (5 min).
     */
    public function setFactoryStats(string $factoryId, array $stats, ?int $ttl = null): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        $key = "dashboard:factory:{$factoryId}:stats";
        Cache::store($this->store)->put($key, $stats, $ttl ?? 300);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getFactoryStats(string $factoryId): ?array
    {
        if (! $this->isAvailable()) {
            return null;
        }
        return Cache::store($this->store)->get("dashboard:factory:{$factoryId}:stats");
    }

    // ─────────────────────────────────────────────────
    // 3. FLEET TELEMETRY CACHE (Modules 9H, 13C, 6E)
    // ─────────────────────────────────────────────────

    /**
     * Store a single vehicle position in the active fleet.
     *
     * @param string $vehicleId  Unique vehicle identifier
     * @param float  $lat        Latitude
     * @param float  $lng        Longitude
     * @param array  $meta       Extra metadata (speed, heading, driver_name, etc.)
     */
    public function updateVehiclePosition(string $vehicleId, float $lat, float $lng, array $meta = []): void
    {
        if (! $this->isAvailable()) {
            return;
        }

        $payload = array_merge($meta, [
            'vehicle_id' => $vehicleId,
            'lat' => $lat,
            'lng' => $lng,
            'updated_at' => now()->toIso8601String(),
        ]);

        // Store individual position as a hash
        Cache::store($this->store)->put(
            "fleet:vehicle:{$vehicleId}",
            $payload,
            120 // 2-minute TTL — positions are ephemeral
        );

        // Maintain a set of active vehicle IDs (for iteration)
        $this->addToActiveFleet($vehicleId);
    }

    /**
     * Get the last known position of a specific vehicle.
     *
     * @return array<string, mixed>|null
     */
    public function getVehiclePosition(string $vehicleId): ?array
    {
        if (! $this->isAvailable()) {
            return null;
        }
        return Cache::store($this->store)->get("fleet:vehicle:{$vehicleId}");
    }

    /**
     * Retrieve all currently active vehicle positions.
     *
     * @return array<int, array<string, mixed>>
     */
    public function getAllActivePositions(): array
    {
        if (! $this->isAvailable()) {
            return [];
        }

        $activeIds = $this->getActiveFleet();
        $positions = [];

        foreach ($activeIds as $vehicleId) {
            $pos = Cache::store($this->store)->get("fleet:vehicle:{$vehicleId}");
            if ($pos !== null) {
                $positions[] = $pos;
            }
        }

        return $positions;
    }

    /**
     * Remove a vehicle from the active fleet (e.g., trip ended, offline).
     */
    public function removeVehicleFromFleet(string $vehicleId): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Cache::store($this->store)->forget("fleet:vehicle:{$vehicleId}");
        $this->removeFromActiveFleet($vehicleId);
    }

    // ─────────────────────────────────────────────────
    // 4. ANALYTICS CHART CACHE (Modules 1D, 2C, 3AE)
    // ─────────────────────────────────────────────────

    /**
     * Store pre-computed chart data for dashboards.
     * TTL defaults to 3600 s (1 hour).
     *
     * @param string $chartType  e.g. 'scans_per_day', 'revenue_growth', 'fleet_utilization'
     * @param string $period     e.g. '7d', '30d', '90d'
     * @param array  $data       Pre-computed chart series
     */
    public function setChartData(string $chartType, string $period, array $data, ?int $ttl = null): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        $key = "analytics:charts:{$chartType}:{$period}";
        Cache::store($this->store)->put($key, $data, $ttl ?? 3600);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getChartData(string $chartType, string $period): ?array
    {
        if (! $this->isAvailable()) {
            return null;
        }
        return Cache::store($this->store)->get("analytics:charts:{$chartType}:{$period}");
    }

    /**
     * Invalidate all chart caches for a given type.
     */
    public function invalidateChartCache(string $chartType): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Log::info("RedisCacheService: chart cache invalidated for type={$chartType}");
    }

    // ─────────────────────────────────────────────────
    // 5. RATE LIMITING (Module 1N)
    // ─────────────────────────────────────────────────

    /**
     * Increment a rate-limit counter for a user + endpoint combination.
     *
     * @return int  Current count after increment
     */
    public function incrementRateLimit(string $userId, string $endpoint, int $windowSeconds = 60): int
    {
        if (! $this->isAvailable()) {
            return 0; // Degrade: allow all requests when Redis is down
        }

        $key = "rate_limit:{$userId}:{$endpoint}";
        $current = (int) Cache::store($this->store)->get($key, 0);
        $next = $current + 1;

        Cache::store($this->store)->put($key, $next, $windowSeconds);

        return $next;
    }

    /**
     * Check current rate-limit count without incrementing.
     */
    public function getRateLimitCount(string $userId, string $endpoint): int
    {
        if (! $this->isAvailable()) {
            return 0;
        }
        return (int) Cache::store($this->store)->get("rate_limit:{$userId}:{$endpoint}", 0);
    }

    // ─────────────────────────────────────────────────
    // 6. SESSION / SHORT-LIVED STATE (Modules 12F, 4Z)
    // ─────────────────────────────────────────────────

    /**
     * Store a short-lived session state blob.
     */
    public function setSessionState(string $sessionId, array $data, ?int $ttl = null): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Cache::store($this->store)->put("session:{$sessionId}", $data, $ttl ?? 900);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getSessionState(string $sessionId): ?array
    {
        if (! $this->isAvailable()) {
            return null;
        }
        return Cache::store($this->store)->get("session:{$sessionId}");
    }

    /**
     * Remove session state (e.g., on logout).
     */
    public function forgetSessionState(string $sessionId): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Cache::store($this->store)->forget("session:{$sessionId}");
    }

    // ─────────────────────────────────────────────────
    // 7. GENERIC KEY-VALUE HELPERS
    // ─────────────────────────────────────────────────

    /**
     * Generic "remember" wrapper — fetch from cache or compute + store.
     *
     * @template T
     * @param string   $key
     * @param int|null $ttl
     * @param callable(): T $callback
     * @return T
     */
    public function remember(string $key, ?int $ttl, callable $callback): mixed
    {
        if (! $this->isAvailable()) {
            return $callback();
        }
        return Cache::store($this->store)->remember($key, $ttl ?? $this->defaultTtl, $callback);
    }

    /**
     * Store a value by key.
     */
    public function set(string $key, mixed $value, ?int $ttl = null): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Cache::store($this->store)->put("nexatrace:{$key}", $value, $ttl ?? $this->defaultTtl);
    }

    /**
     * Retrieve a value by key.
     */
    public function get(string $key, mixed $default = null): mixed
    {
        if (! $this->isAvailable()) {
            return $default;
        }
        return Cache::store($this->store)->get("nexatrace:{$key}", $default);
    }

    /**
     * Delete a key.
     */
    public function forget(string $key): void
    {
        if (! $this->isAvailable()) {
            return;
        }
        Cache::store($this->store)->forget("nexatrace:{$key}");
    }

    // ─────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────

    private function addToActiveFleet(string $vehicleId): void
    {
        $active = $this->getActiveFleet();
        if (! in_array($vehicleId, $active, true)) {
            $active[] = $vehicleId;
            Cache::store($this->store)->put('fleet:active_ids', $active, 300);
        }
    }

    private function removeFromActiveFleet(string $vehicleId): void
    {
        $active = $this->getActiveFleet();
        $filtered = array_values(array_filter($active, fn($id) => $id !== $vehicleId));
        Cache::store($this->store)->put('fleet:active_ids', $filtered, 300);
    }

    /**
     * @return array<int, string>
     */
    private function getActiveFleet(): array
    {
        return Cache::store($this->store)->get('fleet:active_ids', []);
    }
}
