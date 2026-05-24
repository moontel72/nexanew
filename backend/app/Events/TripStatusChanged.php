<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — TRIP STATUS CHANGED EVENT
 * =======================================
 *
 * Broadcasts trip lifecycle transitions for:
 *   - Module 4T  (Driver Trip State Machine)
 *   - Module 9H  (Goods Company Fleet Tracking)
 *   - Module 3AC (Factory Driver Analytics)
 *   - Module 6E  (Reseller Delivery Tracking)
 *
 * SAFETY:
 *   - Default driver is 'log'. Zero impact on existing trip logic.
 *   - Dispatched alongside (not replacing) the existing synchronous
 *     trip status update in the DriverController.
 *
 * CHANNEL: trip.{trip_id}
 *   Trip-scoped — subscribers are the factory, goods company, and reseller.
 *
 * USAGE:
 *   event(new TripStatusChanged($tripId, $oldStatus, $newStatus, $companyId, $lat, $lng));
 */

class TripStatusChanged implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $tripId;
    public string $oldStatus;
    public string $newStatus;
    public string $companyId;
    public ?float $lat;
    public ?float $lng;
    public array $meta;

    /**
     * @param string      $tripId     Unique trip identifier
     * @param string      $oldStatus  Previous status (e.g., 'in_transit')
     * @param string      $newStatus  New status (e.g., 'arrived')
     * @param string      $companyId  Owning factory company ID
     * @param float|null  $lat        Current latitude
     * @param float|null  $lng        Current longitude
     * @param array       $meta       { driver_id, driver_name, vehicle_id, eta_minutes, ... }
     */
    public function __construct(
        string $tripId,
        string $oldStatus,
        string $newStatus,
        string $companyId,
        ?float $lat = null,
        ?float $lng = null,
        array $meta = []
    ) {
        $this->tripId = $tripId;
        $this->oldStatus = $oldStatus;
        $this->newStatus = $newStatus;
        $this->companyId = $companyId;
        $this->lat = $lat;
        $this->lng = $lng;
        $this->meta = $meta;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel("trip.{$this->tripId}"),
            // Also broadcast to company channel for fleet-wide dashboards
            new Channel("fleet.{$this->companyId}"),
        ];
    }

    public function broadcastAs(): string
    {
        return 'TripStatusChanged';
    }

    public function broadcastWith(): array
    {
        $payload = [
            'trip_id' => $this->tripId,
            'old_status' => $this->oldStatus,
            'new_status' => $this->newStatus,
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
            Log::info('TripStatusChanged (log-only mode)', [
                'trip_id' => $this->tripId,
                'old' => $this->oldStatus,
                'new' => $this->newStatus,
            ]);
        }
        return true;
    }
}
