<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — GEOFENCE SCAN UNLOCKED EVENT
 * ==========================================
 *
 * Fires when a Factory Driver enters the 100 m geofence radius
 * around a delivery point and the scan button becomes available.
 *
 * This is the INBOUND HANDSHAKE signal — it alerts the Store Keeper
 * in real time that the driver is at the delivery location and is
 * about to perform the physical code validation scan.
 *
 * TARGET MODULES:
 *   - Module 4C (Driver Geofenced Delivery Scanning Enforcer)
 *   - Module 4D (Fail-Safe Counterparty Verification Bypass)
 *   - Module 5A (Store Keeper Contextual Security Enclosure)
 *   - Module 5N (Store Keeper Buyer Link & Push Notification)
 *
 * SAFETY:
 *   - Default driver is 'log'. Fires safely without WebSocket infrastructure.
 *   - Dispatched from HandshakeService (new, independent service).
 *   - Zero modification to existing DriverController or StoreKeeperController.
 *
 * CHANNELS:
 *   - store_keeper.{factory_id}  → Store Keeper devices get real-time alert
 *   - trip.{trip_id}             → All trip stakeholders notified
 *   - fleet.{company_id}         → Factory admin dashboard updated
 *
 * USAGE:
 *   event(new GeofenceScanUnlocked($tripId, $driverId, $storeKeeperId, $companyId, $lat, $lng, $meta));
 */

class GeofenceScanUnlocked implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $tripId;
    public string $driverId;
    public string $storeKeeperId;
    public string $companyId;
    public float $lat;
    public float $lng;
    public float $distanceMeters;
    public array $meta;

    /**
     * @param string $tripId         Trip being executed
     * @param string $driverId       Driver who entered geofence
     * @param string $storeKeeperId  Store Keeper to alert
     * @param string $companyId      Owning factory company
     * @param float  $lat            Driver's current latitude
     * @param float  $lng            Driver's current longitude
     * @param float  $distanceMeters Distance to delivery point
     * @param array  $meta           { driver_name, delivery_address, product_summary, eta_seconds, ... }
     */
    public function __construct(
        string $tripId,
        string $driverId,
        string $storeKeeperId,
        string $companyId,
        float $lat,
        float $lng,
        float $distanceMeters,
        array $meta = []
    ) {
        $this->tripId = $tripId;
        $this->driverId = $driverId;
        $this->storeKeeperId = $storeKeeperId;
        $this->companyId = $companyId;
        $this->lat = $lat;
        $this->lng = $lng;
        $this->distanceMeters = $distanceMeters;
        $this->meta = $meta;
    }

    public function broadcastOn(): array
    {
        return [
            // Primary: alert the specific Store Keeper's device
            new Channel("store_keeper.{$this->storeKeeperId}"),

            // Secondary: update trip stakeholders
            new Channel("trip.{$this->tripId}"),

            // Tertiary: update factory admin dashboard
            new Channel("fleet.{$this->companyId}"),
        ];
    }

    public function broadcastAs(): string
    {
        return 'GeofenceScanUnlocked';
    }

    public function broadcastWith(): array
    {
        $payload = [
            'trip_id' => $this->tripId,
            'driver_id' => $this->driverId,
            'store_keeper_id' => $this->storeKeeperId,
            'lat' => $this->lat,
            'lng' => $this->lng,
            'distance_meters' => $this->distanceMeters,
            'scan_unlocked' => true,
            'timestamp' => now()->toIso8601String(),
        ];

        $safeMeta = array_filter($this->meta, fn($v) => is_scalar($v) || is_array($v));
        return array_merge($payload, $safeMeta);
    }

    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('GeofenceScanUnlocked (log-only mode)', [
                'trip_id' => $this->tripId,
                'driver_id' => $this->driverId,
                'store_keeper_id' => $this->storeKeeperId,
                'distance_meters' => $this->distanceMeters,
            ]);
        }
        return true;
    }
}
