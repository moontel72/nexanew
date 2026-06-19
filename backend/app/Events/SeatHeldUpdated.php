<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — SEAT HOLD UPDATED EVENT
 * ====================================
 *
 * Fires whenever a seat transitions between hold states:
 *   - held       (seat reserved for checkout)
 *   - released   (user cancelled, or cron expired the hold)
 *   - confirmed  (hold graduated to permanent booking)
 *
 * Broacast to all passengers viewing the same trip so they
 * see real-time seat availability changes without polling.
 *
 * CHANNEL: bus.{tripId}.seats
 *
 * TARGET MODULES: 8V, 14E
 */
class SeatHeldUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $tripId;
    public string $event;           // 'held' | 'released' | 'confirmed'
    public array $seatNumbers;      // affected seat numbers
    public array $heldSeats;        // full snapshot: all currently held seat numbers
    public array $bookedSeats;      // full snapshot: all finalized booked seat numbers
    public int   $totalSeats;
    public int   $availableSeats;

    public function __construct(
        string $tripId,
        string $event,
        array  $seatNumbers,
        array  $heldSeats = [],
        array  $bookedSeats = [],
        int    $totalSeats = 0,
        int    $availableSeats = 0,
    ) {
        $this->tripId        = $tripId;
        $this->event         = $event;
        $this->seatNumbers   = $seatNumbers;
        $this->heldSeats     = $heldSeats;
        $this->bookedSeats   = $bookedSeats;
        $this->totalSeats    = $totalSeats;
        $this->availableSeats = $availableSeats;
    }

    public function broadcastOn(): array
    {
        return [new Channel("bus.{$this->tripId}.seats")];
    }

    public function broadcastAs(): string
    {
        return 'SeatHeldUpdated';
    }

    public function broadcastWith(): array
    {
        return [
            'trip_id'         => $this->tripId,
            'event'           => $this->event,
            'seat_numbers'    => $this->seatNumbers,
            'held_seats'      => $this->heldSeats,
            'booked_seats'    => $this->bookedSeats,
            'total_seats'     => $this->totalSeats,
            'available_seats' => $this->availableSeats,
            'timestamp'       => now()->toIso8601String(),
        ];
    }

    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('SeatHeldUpdated (log-only mode)', [
                'trip_id'    => $this->tripId,
                'event'      => $this->event,
                'seats'      => $this->seatNumbers,
                'held_count' => count($this->heldSeats),
            ]);
        }
        return true;
    }
}
