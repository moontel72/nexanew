<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — DELIVERY CONFIRMED EVENT
 * =====================================
 *
 * Broadcasts proof-of-delivery confirmation for:
 *   - Module 4E  (Factory Driver Proof of Delivery)
 *   - Module 3AE (Factory Admin Billing — triggers invoice close)
 *   - Module 6I  (Reseller Supply Chain Reception)
 *   - Module 7H  (Shop Keeper Supply Chain Reception)
 *   - Module 12E (B2B Escrow — triggers funds release)
 *
 * SAFETY: Default driver = 'log'. Dispatched after (not replacing)
 *         the existing synchronous POD submission in DriverController.
 *
 * CHANNEL: delivery.{delivery_id}
 *
 * USAGE:
 *   event(new DeliveryConfirmed($deliveryId, $tripId, $podType, $companyId, $recipientName));
 */

class DeliveryConfirmed implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $deliveryId;
    public string $tripId;
    public string $podType;
    public string $companyId;
    public ?string $recipientName;
    public array $meta;

    /**
     * @param string      $deliveryId     Unique delivery/POD identifier
     * @param string      $tripId         Associated trip
     * @param string      $podType        'pin' | 'photo' | 'signature'
     * @param string      $companyId      Factory company ID
     * @param string|null $recipientName  Name of person who confirmed receipt
     * @param array       $meta           { driver_name, delivered_at, photo_urls, ... }
     */
    public function __construct(
        string $deliveryId,
        string $tripId,
        string $podType,
        string $companyId,
        ?string $recipientName = null,
        array $meta = []
    ) {
        $this->deliveryId = $deliveryId;
        $this->tripId = $tripId;
        $this->podType = $podType;
        $this->companyId = $companyId;
        $this->recipientName = $recipientName;
        $this->meta = $meta;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel("delivery.{$this->deliveryId}"),
            new Channel("trip.{$this->tripId}"),
            new Channel("fleet.{$this->companyId}"),
        ];
    }

    public function broadcastAs(): string
    {
        return 'DeliveryConfirmed';
    }

    public function broadcastWith(): array
    {
        $payload = [
            'delivery_id' => $this->deliveryId,
            'trip_id' => $this->tripId,
            'pod_type' => $this->podType,
            'recipient_name' => $this->recipientName,
            'timestamp' => now()->toIso8601String(),
        ];

        $safeMeta = array_filter($this->meta, fn($v) => is_scalar($v) || is_array($v));
        return array_merge($payload, $safeMeta);
    }

    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('DeliveryConfirmed (log-only mode)', [
                'delivery_id' => $this->deliveryId,
                'trip_id' => $this->tripId,
                'pod_type' => $this->podType,
            ]);
        }
        return true;
    }
}
