<?php

namespace App\Services\Handshake;

use App\Events\GeofenceScanUnlocked;
use App\Events\TripStatusChanged;
use App\Services\Redis\RedisCacheService;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — DRIVER ↔ STORE KEEPER HANDSHAKE SERVICE
 * =====================================================
 *
 * Coordinates the inbound cargo handshake between the Factory Driver
 * and the Store Keeper when the driver enters the 100 m delivery
 * geofence.
 *
 * FLOW:
 *   1. Flutter Driver App detects scanUnlocked = true (within 100 m)
 *   2. Driver app calls POST /api/v1/factory/driver/handshake/arrived
 *   3. DriverHandshakeController → HandshakeService::onDriverArrived()
 *   4. Service stores handshake state in Redis cache
 *   5. Service dispatches GeofenceScanUnlocked event → WebSocket
 *   6. Store Keeper app receives real-time alert on channel
 *   7. Store Keeper prepares for physical validation scan
 *
 * SAFETY:
 *   - Entirely NEW service. No existing controller or endpoint modified.
 *   - Uses RedisCacheService (also new) for state persistence.
 *   - Uses WebSocket events (also new) for real-time broadcast.
 *   - All Redis/WebSocket operations degrade gracefully when unavailable.
 *
 * TARGET MODULES: 4A, 4C, 4D, 5A, 5N
 */

class HandshakeService
{
    private const HANDSHAKE_TTL = 300; // 5 minutes — ephemeral geofence state
    private const CACHE_PREFIX = 'handshake';

    public function __construct(
        private RedisCacheService $cache
    ) {}

    /**
     * Called when the driver enters the 100 m delivery geofence.
     *
     * Stores the handshake state and broadcasts to the Store Keeper.
     *
     * @param string $tripId          Associated trip
     * @param string $driverId        Driver identifier
     * @param string $storeKeeperId   Store Keeper to notify
     * @param string $companyId       Factory company
     * @param float  $lat             Driver GPS latitude
     * @param float  $lng             Driver GPS longitude
     * @param float  $distanceMeters  Computed distance to delivery point
     * @param array  $meta            { driver_name, delivery_address, product_ids, ... }
     * @return array                  Handshake state payload
     */
    public function onDriverArrived(
        string $tripId,
        string $driverId,
        string $storeKeeperId,
        string $companyId,
        float $lat,
        float $lng,
        float $distanceMeters,
        array $meta = []
    ): array {
        // ─── Build handshake state ────────────────────
        $handshake = [
            'handshake_id' => 'hs-' . $tripId,
            'trip_id' => $tripId,
            'driver_id' => $driverId,
            'store_keeper_id' => $storeKeeperId,
            'company_id' => $companyId,
            'status' => 'driver_arrived',
            'lat' => $lat,
            'lng' => $lng,
            'distance_meters' => $distanceMeters,
            'scan_unlocked' => true,
            'meta' => $meta,
            'created_at' => now()->toIso8601String(),
            'expires_at' => now()->addSeconds(self::HANDSHAKE_TTL)->toIso8601String(),
        ];

        // ─── Persist in Redis cache ───────────────────
        $this->cache->set(
            self::CACHE_PREFIX . ":{$tripId}",
            $handshake,
            self::HANDSHAKE_TTL
        );

        Log::info('HandshakeService: driver arrived at geofence', [
            'trip_id' => $tripId,
            'driver_id' => $driverId,
            'store_keeper_id' => $storeKeeperId,
            'distance_meters' => $distanceMeters,
        ]);

        // ─── Broadcast WebSocket event ────────────────
        GeofenceScanUnlocked::dispatch(
            $tripId,
            $driverId,
            $storeKeeperId,
            $companyId,
            $lat,
            $lng,
            $distanceMeters,
            $meta
        );

        // Also broadcast trip status change for dashboards
        TripStatusChanged::dispatch(
            $tripId,
            'in_transit',  // previous status
            'arrived',     // new status
            $companyId,
            $lat,
            $lng,
            array_merge($meta, ['trigger' => 'geofence_handshake'])
        );

        return $handshake;
    }

    /**
     * Called when the driver successfully scans the delivery code.
     * Closes the handshake and notifies the Store Keeper.
     *
     * @return array|null  Updated handshake state, or null if not found
     */
    public function onDriverScanned(
        string $tripId,
        string $driverId,
        string $storeKeeperId,
        string $companyId,
        float $lat,
        float $lng,
        array $meta = []
    ): ?array {
        $existing = $this->getHandshakeState($tripId);

        if (! $existing) {
            Log::warning('HandshakeService: scan without prior handshake', [
                'trip_id' => $tripId,
            ]);
        }

        $handshake = array_merge($existing ?? [], [
            'status' => 'driver_scanned',
            'lat' => $lat,
            'lng' => $lng,
            'scanned_at' => now()->toIso8601String(),
            'meta' => array_merge($existing['meta'] ?? [], $meta),
        ]);

        $this->cache->set(
            self::CACHE_PREFIX . ":{$tripId}",
            $handshake,
            self::HANDSHAKE_TTL
        );

        Log::info('HandshakeService: driver scanned at delivery point', [
            'trip_id' => $tripId,
            'driver_id' => $driverId,
        ]);

        return $handshake;
    }

    /**
     * Called when the Store Keeper acknowledges the handshake.
     * Confirms the Store Keeper is ready for the delivery.
     */
    public function onStoreKeeperAcknowledged(
        string $tripId,
        string $storeKeeperId,
        array $meta = []
    ): ?array {
        $existing = $this->getHandshakeState($tripId);

        if (! $existing) {
            Log::warning('HandshakeService: acknowledgement without handshake', [
                'trip_id' => $tripId,
            ]);
            return null;
        }

        $handshake = array_merge($existing, [
            'status' => 'store_keeper_acknowledged',
            'acknowledged_at' => now()->toIso8601String(),
            'meta' => array_merge($existing['meta'] ?? [], $meta),
        ]);

        $this->cache->set(
            self::CACHE_PREFIX . ":{$tripId}",
            $handshake,
            self::HANDSHAKE_TTL
        );

        Log::info('HandshakeService: store keeper acknowledged', [
            'trip_id' => $tripId,
            'store_keeper_id' => $storeKeeperId,
        ]);

        return $handshake;
    }

    /**
     * Retrieve the current handshake state for a trip.
     */
    public function getHandshakeState(string $tripId): ?array
    {
        return $this->cache->get(self::CACHE_PREFIX . ":{$tripId}");
    }

    /**
     * Check if a handshake is currently active (driver within geofence).
     */
    public function isHandshakeActive(string $tripId): bool
    {
        $state = $this->getHandshakeState($tripId);
        return $state !== null
            && ($state['status'] ?? '') === 'driver_arrived';
    }

    /**
     * Expire a handshake (e.g., driver left geofence, trip cancelled).
     */
    public function expireHandshake(string $tripId): void
    {
        $this->cache->forget(self::CACHE_PREFIX . ":{$tripId}");

        Log::info('HandshakeService: handshake expired', [
            'trip_id' => $tripId,
        ]);
    }
}
