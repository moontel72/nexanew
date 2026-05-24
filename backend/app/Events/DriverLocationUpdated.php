<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — DRIVER LOCATION UPDATED EVENT
 * ==========================================
 *
 * Broadcasts per-driver location for:
 *   - Module 10J (Truck Owner Fleet GPS Tracking)
 *   - Module 9H  (Goods Company Fleet Telemetry)
 *   - Module 11G (Truck Driver Real-Time Location)
 *
 * SAFETY: Default driver = 'log'. No coupling to existing driver endpoints.
 *
 * CHANNEL: driver.{driver_id}
 *
 * USAGE:
 *   event(new DriverLocationUpdated($driverId, $tripId, $lat, $lng, $meta));
 */

class DriverLocationUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $driverId;
    public ?string $tripId;
    public float $lat;
    public float $lng;
    public array $meta;

    public function __construct(
        string $driverId,
        ?string $tripId,
        float $lat,
        float $lng,
        array $meta = []
    ) {
        $this->driverId = $driverId;
        $this->tripId = $tripId;
        $this->lat = $lat;
        $this->lng = $lng;
        $this->meta = $meta;
    }

    public function broadcastOn(): array
    {
        $channels = [
            new Channel("driver.{$this->driverId}"),
        ];

        if ($this->tripId) {
            $channels[] = new Channel("trip.{$this->tripId}");
        }

        return $channels;
    }

    public function broadcastAs(): string
    {
        return 'DriverLocationUpdated';
    }

    public function broadcastWith(): array
    {
        $payload = [
            'driver_id' => $this->driverId,
            'trip_id' => $this->tripId,
            'lat' => $this->lat,
            'lng' => $this->lng,
            'timestamp' => now()->toIso8601String(),
        ];

        $safeMeta = array_filter($this->meta, fn($v) => is_scalar($v) || is_array($v));
        return array_merge($payload, $safeMeta);
    }

    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('DriverLocationUpdated (log-only mode)', [
                'driver_id' => $this->driverId,
                'trip_id' => $this->tripId,
                'lat' => $this->lat,
                'lng' => $this->lng,
            ]);
        }
        return true;
    }
}
