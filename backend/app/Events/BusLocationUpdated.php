<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — BUS LOCATION UPDATED EVENT
 * ========================================
 *
 * Fires when a bus driver's GPS coordinates update during
 * an active trip. Broadcasts to Customer App (8V) and
 * Bus Admin Panel (13C) in real time.
 *
 * CHANNEL: bus.{trip_id}
 *
 * SAFETY: Default driver = 'log'. Dispatches from BusLiveTrackingService.
 */

class BusLocationUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $busId;
    public string $tripId;
    public float $lat;
    public float $lng;
    public float $speed;
    public array $etaJson;
    public string $tripStatus;
    public string $eventType;

    public function __construct(
        string $busId,
        string $tripId,
        float $lat,
        float $lng,
        float $speed,
        array $etaJson = [],
        string $status = 'active',
        string $eventType = 'location_update'
    ) {
        $this->busId = $busId;
        $this->tripId = $tripId;
        $this->lat = $lat;
        $this->lng = $lng;
        $this->speed = $speed;
        $this->etaJson = $etaJson;
        $this->tripStatus = $status;
        $this->eventType = $eventType;
    }

    public function broadcastOn(): array
    {
        return [new Channel("bus.{$this->tripId}")];
    }

    public function broadcastAs(): string
    {
        return 'BusLocationUpdated';
    }

    public function broadcastWith(): array
    {
        return [
            'bus_id' => $this->busId,
            'trip_id' => $this->tripId,
            'lat' => $this->lat,
            'lng' => $this->lng,
            'speed' => $this->speed,
            'eta_json' => $this->etaJson,
            'trip_status' => $this->tripStatus,
            'event_type' => $this->eventType,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('BusLocationUpdated (log-only mode)', [
                'bus_id' => $this->busId,
                'trip_id' => $this->tripId,
                'lat' => $this->lat,
                'lng' => $this->lng,
                'speed' => $this->speed,
                'event' => $this->eventType,
            ]);
        }
        return true;
    }
}
