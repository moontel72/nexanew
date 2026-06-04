<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

/**
 * Wave 1 — Step 1.2: System Cache Counter Service
 *
 * Governs the 3-level feature grants version cache per Section 10.3.1.
 *
 * L1: Token claim (Sanctum payload) → feature_grants_version: <int>
 * L2: Redis grant set  →  feat:v<version>:role:<role_id>
 * L3: Postgres counter →  feature_grants_version_counter (this service)
 *
 * Write path (10.3.3): incrementVersion() called inside the same DB
 * transaction as any sub_admin_feature_grants mutation. publishVersionBump()
 * called AFTER commit to refresh Redis and fan-out via Pub/Sub.
 *
 * Read path (10.3.2): currentVersion() read on every authenticated
 * request by TokenVersionGuard. Uses 24h Redis cache to prevent
 * thundering-herd on the Postgres counter row.
 */
class ConfigurationService
{
    private const COUNTER_TABLE      = 'feature_grants_version_counter';
    private const REDIS_VERSION_KEY  = 'feat:current_version';
    private const REDIS_VERSION_TTL  = 86400;
    private const REDIS_LOCK_PREFIX  = 'lock:feat:v';

    /**
     * Atomically increment the global grants version counter.
     *
     * MUST be called inside the same DB transaction as the
     * sub_admin_feature_grants / master_admin_assignments mutation.
     * Uses SELECT ... FOR UPDATE to prevent concurrent writes.
     *
     * @return int The new version after increment.
     */
    public function incrementVersion(): int
    {
        $row = DB::table(self::COUNTER_TABLE)
            ->where('id', 1)
            ->lockForUpdate()
            ->first();

        if (!$row) {
            DB::table(self::COUNTER_TABLE)->insert([
                'id'         => 1,
                'version'    => 2,
                'updated_at' => now(),
            ]);
            return 2;
        }

        $newVersion = (int) $row->version + 1;

        DB::table(self::COUNTER_TABLE)
            ->where('id', 1)
            ->update([
                'version'    => $newVersion,
                'updated_at' => now(),
            ]);

        return $newVersion;
    }

    /**
     * Read current grants version with Redis-backed cache.
     *
     * Hot path — called on every authenticated request.
     * 24h Redis cache prevents Postgres hammering.
     *
     * Graceful degradation: if Redis is unavailable, reads directly
     * from Postgres and skips the Redis cache write.
     */
    public function currentVersion(): int
    {
        try {
            $cached = Redis::get(self::REDIS_VERSION_KEY);
            if ($cached !== null) {
                return (int) $cached;
            }
        } catch (\Exception $e) {
            // Redis unavailable — fall through to database read
            report($e);
        }

        $row = DB::table(self::COUNTER_TABLE)->where('id', 1)->first();
        $version = $row ? (int) $row->version : 1;

        try {
            Redis::setex(self::REDIS_VERSION_KEY, self::REDIS_VERSION_TTL, $version);
        } catch (\Exception $e) {
            // Redis write failed — non-fatal; next request will hit DB again
        }

        return $version;
    }

    /**
     * After-commit hook: refresh Redis pointer and Pub/Sub fan-out.
     *
     * Per Section 10.3.3 AFTER COMMIT:
     *   Redis: SET feat:current_version <new_version> EX 86400
     *   Redis Pub/Sub: PUBLISH feat:version:bumped <new_version>
     *
     * Graceful: if Redis is unavailable, version bump still committed
     * in Postgres — cache will be lazily repopulated on next read.
     */
    public function publishVersionBump(int $newVersion): void
    {
        try {
            Redis::setex(self::REDIS_VERSION_KEY, self::REDIS_VERSION_TTL, $newVersion);
            Redis::publish('feat:version:bumped', (string) $newVersion);
        } catch (\Exception $e) {
            report($e);
        }
    }

    /**
     * Stampede protection lock for L2 materialization (Section 10.3.4).
     *
     * Wraps Redis SETNX with 5s expiry. Losers wait-and-poll 50ms
     * then read the warm set.
     */
    public function acquireMaterializationLock(int $version, string $roleId): bool
    {
        $key = self::REDIS_LOCK_PREFIX . "{$version}:role:{$roleId}";
        return (bool) Redis::set($key, 1, 'EX', 5, 'NX');
    }

    public function releaseMaterializationLock(int $version, string $roleId): void
    {
        $key = self::REDIS_LOCK_PREFIX . "{$version}:role:{$roleId}";
        Redis::del($key);
    }
}
