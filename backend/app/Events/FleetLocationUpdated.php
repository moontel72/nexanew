<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — FLEET LOCATION UPDATED EVENT
 * ==========================================
 *
 * Broadcasts real-time vehicle position updates for:
 *   - Module 9H  (Goods Company Fleet Telemetry)
 *   - Module 13C (Bus Admin Multi-Asset Telemetry)
 *   - Module 6E  (Reseller Transport Tracker)
 *   - Module 16B (Bus Passenger Live Tracking)
 *
 * SAFETY:
 *   - Default driver is 'log' — dispatches without crashing.
 *   - When BROADCAST_DRIVER=redis in .env, streams via Redis pub/sub.
 *   - Consumers: Goods Company panel, Factory dashboard, Reseller app,
 *     Bus Admin, Bus Passenger app.
 *
 * CHANNEL: fleet.{company_id}
 *   Company-scoped so each tenant only receives its own fleet.
 *
 * USAGE:
 *   event(new FleetLocationUpdated($truckId, $companyId, $lat, $lng, $meta));
 */

class FleetLocationUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $vehicleId;
    public string $companyId;
    public float $lat;
    public float $lng;
    public array $meta;

    /**
     * @param string $vehicleId  Unique vehicle identifier (truck_id or bus_id)
     * @param string $companyId  Owning company / goods company ID
     * @param float  $lat        Latitude
     * @param float  $lng        Longitude
     * @param array  $meta       { speed, heading, driver_name, trip_id, vehicle_type, ... }
     */
    public function __construct(
        string $vehicleId,
        string $companyId,
        float $lat,
        float $lng,
        array $meta = []
    ) {
        $this->vehicleId = $vehicleId;
        $this->companyId = $companyId;
        $this->lat = $lat;
        $this->lng = $lng;
        $this->meta = $meta;
    }

    /**
     * The channel this event broadcasts on.
     */
    public function broadcastOn(): array
    {
        return [
            new Channel("fleet.{$this->companyId}"),
        ];
    }

    /**
     * Event name sent to the client.
     */
    public function broadcastAs(): string
    {
        return 'FleetLocationUpdated';
    }

    /**
     * Payload delivered to WebSocket subscribers.
     */
    public function broadcastWith(): array
    {
        $payload = [
            'vehicle_id' => $this->vehicleId,
            'lat' => $this->lat,
            'lng' => $this->lng,
            'timestamp' => now()->toIso8601String(),
        ];

        // Merge metadata but exclude large/non-serializable fields
        $safeMeta = array_filter($this->meta, fn($v) => is_scalar($v) || is_array($v));
        return array_merge($payload, $safeMeta);
    }

    /**
     * Fallback: when driver is 'log', event payload is written to laravel.log.
     * No crash, no side-effects on existing endpoints.
     */
    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('FleetLocationUpdated (log-only mode)', [
                'vehicle_id' => $this->vehicleId,
                'lat' => $this->lat,
                'lng' => $this->lng,
                'meta' => $this->meta,
            ]);
        }
        return true;
    }
}
