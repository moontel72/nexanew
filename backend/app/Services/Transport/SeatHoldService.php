<?php

namespace App\Services\Transport;

use App\Events\SeatHeldUpdated;
use App\Models\Transport\AbsoluteBusLayout;
use App\Services\Financial\CommissionService;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — SEAT HOLD SERVICE
 * ==============================
 *
 * Race-safe ephemeral seat reservation layer.
 *
 * LIFECYCLE:
 *   hold (8 min TTL) → confirm (pay & finalize) → booking
 *                    → release (user cancel)
 *                    → expire  (cron cleanup)
 *
 * 48-HOUR DEPARTURE LOCKOUT:
 *   If the trip departs within 48 hours, holds are rejected.
 *   Passengers must purchase instantly (direct bookSeat).
 *
 * RACE SAFETY:
 *   Layer 1 — DB UNIQUE(trip_id, seat_number) on transport_seat_holds
 *   Layer 2 — DB UNIQUE(trip_id, seat_number) on transport_seat_bookings
 *   Layer 3 — Atomic DB::transaction() for hold→confirm migration
 *
 * TARGET MODULES: 8V, 8W
 */
class SeatHoldService
{
    /** Default hold TTL in minutes (overridable per layout). */
    public const DEFAULT_HOLD_TTL_MINUTES = 8;

    /** Departure lockout window in hours. */
    public const DEPARTURE_LOCKOUT_HOURS = 48;

    public function __construct(
        private CommissionService $ledger,
    ) {}

    // ═════════════════════════════════════════════════════════
    // HOLD
    // ═════════════════════════════════════════════════════════

    /**
     * Place an ephemeral hold on a seat for checkout.
     *
     * @param string $layoutId   absolute_bus_layouts.id
     * @param string $tripId     transport_bus_trips.id
     * @param string $userId     authenticated user UUID
     * @param int    $seatNumber seat number to hold
     * @param int|null $ttlMinutes override default TTL
     * @return array {hold_token, expires_at, expires_in_seconds}
     *
     * @throws \RuntimeException on conflict, lockout, or validation failure
     */
    public function holdSeat(
        string $layoutId,
        string $tripId,
        string $userId,
        int $seatNumber,
        ?int $ttlMinutes = null,
    ): array {
        // ─── Pre-check: 48-hour departure lockout ──────
        $this->enforceDepartureLockout($tripId);

        // ─── Pre-check: seat not already booked ────────
        $alreadyBooked = DB::table('transport_seat_bookings')
            ->where('trip_id', $tripId)
            ->where('seat_number', $seatNumber)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->exists();

        if ($alreadyBooked) {
            throw new \RuntimeException("Seat {$seatNumber} is already booked.");
        }

        // ─── Pre-check: seat exists in layout snapshot ─
        $layout = AbsoluteBusLayout::where('id', $layoutId)->firstOrFail();
        $allSeats = $this->flattenSeatNumbers($layout->current_snapshot['components'] ?? []);
        if (! in_array($seatNumber, $allSeats)) {
            throw new \RuntimeException("Seat {$seatNumber} does not exist in this bus layout.");
        }

        $ttl = $ttlMinutes ?? self::DEFAULT_HOLD_TTL_MINUTES;
        $holdToken = (string) Str::uuid();
        $holdId    = (string) Str::uuid();
        $expiresAt = now()->addMinutes($ttl);

        // ─── Atomic insert — first-write-wins ──────────
        try {
            DB::table('transport_seat_holds')->insert([
                'id'              => $holdId,
                'layout_id'       => $layoutId,
                'trip_id'         => $tripId,
                'user_id'         => $userId,
                'seat_number'     => $seatNumber,
                'hold_token'      => $holdToken,
                'hold_expires_at' => $expiresAt,
                'held_at'         => now(),
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            // UNIQUE constraint violation → someone else holds this seat
            if (str_contains($e->getMessage(), 'tsh_trip_seat_unique')) {
                throw new \RuntimeException("Seat {$seatNumber} was just claimed by another passenger.");
            }
            // hold_token collision (astronomically unlikely, but handle it)
            if (str_contains($e->getMessage(), 'hold_token')) {
                throw new \RuntimeException('System collision. Please try again.');
            }
            throw $e;
        }

        // ─── Broadcast seat held ───────────────────────
        $snapshot = $this->buildTripSnapshot($tripId, $layoutId);
        $this->broadcastSeatUpdate($tripId, 'held', [$seatNumber], $snapshot);

        Log::info('SeatHoldService: seat held', [
            'trip_id'     => $tripId,
            'seat_number' => $seatNumber,
            'user_id'     => $userId,
            'hold_token'  => $holdToken,
            'expires_at'  => $expiresAt->toIso8601String(),
        ]);

        return [
            'hold_token'          => $holdToken,
            'expires_at'          => $expiresAt->toIso8601String(),
            'expires_in_seconds'  => $ttl * 60,
        ];
    }

    // ═════════════════════════════════════════════════════════
    // CONFIRM (Hold → Booking)
    // ═════════════════════════════════════════════════════════

    /**
     * Confirm a held seat — process payment and finalize booking.
     *
     * @param string $holdToken     ephemeral token from holdSeat
     * @param string $userId        authenticated user (must match hold owner)
     * @param string $paymentMethod wallet | card | voucher
     * @param float  $ticketPrice   ticket price
     * @param string|null $voucherCode required if paymentMethod=voucher
     * @param string $busOwnerId    bus owner receiving payment
     * @return array {booking_id, seat_number, payment}
     *
     * @throws \RuntimeException
     */
    public function confirmHold(
        string $holdToken,
        string $userId,
        string $paymentMethod,
        float $ticketPrice,
        ?string $voucherCode = null,
        string $busOwnerId = '',
    ): array {
        return DB::transaction(function () use (
            $holdToken, $userId, $paymentMethod, $ticketPrice, $voucherCode, $busOwnerId
        ) {
            // ─── Lock & validate hold ──────────────────
            $hold = DB::table('transport_seat_holds')
                ->where('hold_token', $holdToken)
                ->lockForUpdate()
                ->first();

            if (! $hold) {
                throw new \RuntimeException('Hold not found. It may have expired.');
            }

            if ($hold->hold_expires_at < now()) {
                // Clean up the dead hold
                DB::table('transport_seat_holds')
                    ->where('hold_token', $holdToken)
                    ->delete();

                // Broadcast release
                $snapshot = $this->buildTripSnapshot($hold->trip_id, $hold->layout_id);
                $this->broadcastSeatUpdate($hold->trip_id, 'released', [$hold->seat_number], $snapshot);

                throw new \RuntimeException('Your hold has expired. Please select the seat again.');
            }

            if ($hold->user_id !== $userId) {
                throw new \RuntimeException('This hold belongs to another passenger.');
            }

            // ─── Check seat not already booked (race safety) ──
            $alreadyBooked = DB::table('transport_seat_bookings')
                ->where('trip_id', $hold->trip_id)
                ->where('seat_number', $hold->seat_number)
                ->whereIn('status', ['booked', 'confirmed', 'boarded'])
                ->exists();

            if ($alreadyBooked) {
                // Clean up the hold — seat was booked through another path
                DB::table('transport_seat_holds')
                    ->where('hold_token', $holdToken)
                    ->delete();
                throw new \RuntimeException("Seat {$hold->seat_number} is already booked.");
            }

            // ─── Process payment via BusInventoryService ──
            $busInventory = app(BusInventoryService::class);
            $paymentResult = $busInventory->processPaymentExternal(
                userId: $userId,
                ticketPrice: $ticketPrice,
                paymentMethod: $paymentMethod,
                voucherCode: $voucherCode,
                busOwnerId: $busOwnerId,
            );

            // ─── Insert finalized booking ───────────────
            $bookingId = (string) Str::uuid();

            DB::table('transport_seat_bookings')->insert([
                'id'             => $bookingId,
                'bus_layout_id'  => $hold->layout_id,
                'trip_id'        => $hold->trip_id,
                'user_id'        => $userId,
                'seat_number'    => $hold->seat_number,
                'payment_method' => $paymentMethod,
                'ticket_price'   => $ticketPrice,
                'status'         => 'booked',
                'booked_at'      => now(),
                'created_at'     => now(),
                'updated_at'     => now(),
            ]);

            // ─── Issue ticket (Phase 3) ──────────────────
            $ticketService = app(\App\Services\Transport\TicketService::class);
            $ticket = $ticketService->issueTicket($bookingId);

            // ─── Delete the hold ────────────────────────
            DB::table('transport_seat_holds')
                ->where('hold_token', $holdToken)
                ->delete();

            // ─── Broadcast confirmation ─────────────────
            $snapshot = $this->buildTripSnapshot($hold->trip_id, $hold->layout_id);
            $this->broadcastSeatUpdate($hold->trip_id, 'confirmed', [$hold->seat_number], $snapshot);

            Log::info('SeatHoldService: hold confirmed', [
                'booking_id'   => $bookingId,
                'trip_id'      => $hold->trip_id,
                'seat_number'  => $hold->seat_number,
                'user_id'      => $userId,
            ]);

            return [
                'booking_id'  => $bookingId,
                'bus_id'      => $hold->layout_id,
                'seat_number' => $hold->seat_number,
                'payment'     => $paymentResult,
                'ticket'      => $ticket,
            ];
        });
    }

    // ═════════════════════════════════════════════════════════
    // RELEASE (explicit user cancel)
    // ═════════════════════════════════════════════════════════

    /**
     * Explicitly release a hold (user cancels checkout).
     *
     * @param string $holdToken
     * @param string $userId  must match the hold owner
     * @return array {released: true, seat_number, trip_id}
     */
    public function releaseHold(string $holdToken, string $userId): array
    {
        $hold = DB::table('transport_seat_holds')
            ->where('hold_token', $holdToken)
            ->first();

        if (! $hold) {
            throw new \RuntimeException('Hold not found.');
        }

        if ($hold->user_id !== $userId) {
            throw new \RuntimeException('This hold belongs to another passenger.');
        }

        $tripId     = $hold->trip_id;
        $layoutId   = $hold->layout_id;
        $seatNumber = $hold->seat_number;

        DB::table('transport_seat_holds')
            ->where('hold_token', $holdToken)
            ->delete();

        // ─── Broadcast release ─────────────────────────
        $snapshot = $this->buildTripSnapshot($tripId, $layoutId);
        $this->broadcastSeatUpdate($tripId, 'released', [$seatNumber], $snapshot);

        Log::info('SeatHoldService: hold released by user', [
            'trip_id'     => $tripId,
            'seat_number' => $seatNumber,
            'user_id'     => $userId,
        ]);

        return [
            'released'    => true,
            'seat_number' => $seatNumber,
            'trip_id'     => $tripId,
        ];
    }

    // ═════════════════════════════════════════════════════════
    // QUERIES
    // ═════════════════════════════════════════════════════════

    /**
     * Get currently held seat numbers for a trip.
     * Only returns active (non-expired) holds.
     *
     * @return array<int> seat numbers
     */
    public function getHeldSeatNumbers(string $tripId): array
    {
        return DB::table('transport_seat_holds')
            ->where('trip_id', $tripId)
            ->where('hold_expires_at', '>', now())
            ->pluck('seat_number')
            ->map(fn($v) => (int) $v)
            ->toArray();
    }

    /**
     * Get all active holds for a trip with remaining seconds.
     *
     * @return array<{seat_number, remaining_seconds}>
     */
    public function getHeldSeatsWithTTL(string $tripId): array
    {
        return DB::table('transport_seat_holds')
            ->where('trip_id', $tripId)
            ->where('hold_expires_at', '>', now())
            ->select('seat_number', 'hold_expires_at')
            ->get()
            ->map(fn($row) => [
                'seat_number'       => (int) $row->seat_number,
                'remaining_seconds' => max(0, (int) now()->diffInSeconds($row->hold_expires_at, false)),
            ])
            ->toArray();
    }

    /**
     * Full trip snapshot for WebSocket broadcasts.
     */
    private function buildTripSnapshot(string $tripId, string $layoutId): array
    {
        $heldSeats   = $this->getHeldSeatNumbers($tripId);
        $bookedSeats = DB::table('transport_seat_bookings')
            ->where('trip_id', $tripId)
            ->whereIn('status', ['booked', 'confirmed', 'boarded'])
            ->pluck('seat_number')
            ->map(fn($v) => (int) $v)
            ->toArray();

        $layout = AbsoluteBusLayout::where('id', $layoutId)->first();
        $totalSeats = $layout?->totalSeats() ?? 0;

        $availableSeats = $totalSeats - count($heldSeats) - count($bookedSeats);

        return [
            'heldSeats'     => $heldSeats,
            'bookedSeats'   => $bookedSeats,
            'totalSeats'    => $totalSeats,
            'availableSeats'=> max(0, $availableSeats),
        ];
    }

    // ═════════════════════════════════════════════════════════
    // HELPERS
    // ═════════════════════════════════════════════════════════

    /**
     * Enforce 48-hour departure lockout.
     * If the trip departs within 48 hours, no holds allowed.
     */
    private function enforceDepartureLockout(string $tripId): void
    {
        $trip = DB::table('transport_bus_trips')->where('id', $tripId)->first();

        if (! $trip) {
            throw new \RuntimeException('Trip not found.');
        }

        $departureAt = $trip->scheduled_departure_at ?? null;

        if (! $departureAt) {
            // No scheduled departure set — allow holds (backward compat)
            return;
        }

        $departure = Carbon::parse($departureAt);
        $lockoutDeadline = (clone $departure)->subHours(self::DEPARTURE_LOCKOUT_HOURS);

        if (now()->greaterThanOrEqualTo($lockoutDeadline)) {
            $hoursUntilDeparture = max(0, (int) now()->diffInHours($departure, false));
            throw new \RuntimeException(
                "Cannot hold seats within " . self::DEPARTURE_LOCKOUT_HOURS . " hours of departure. " .
                "Departure in {$hoursUntilDeparture} hours. Please purchase instantly at the terminal."
            );
        }
    }

    /**
     * Check whether holds are allowed for a given trip.
     * (Public helper for the controller to advertise in responses.)
     */
    public function holdsAllowed(string $tripId): bool
    {
        try {
            $this->enforceDepartureLockout($tripId);
            return true;
        } catch (\RuntimeException) {
            return false;
        }
    }

    /**
     * Extract bookable seat numbers from a layout component array.
     */
    private function flattenSeatNumbers(array $components): array
    {
        $seats = [];
        foreach ($components as $comp) {
            $type = $comp['type'] ?? '';
            if (in_array($type, ['seat', 'businessClassSeat', 'foldingSeat', 'sleeperLower', 'sleeperUpper'])) {
                $num = $comp['seat_number'] ?? $comp['seatId'] ?? null;
                if ($num !== null) {
                    $seats[] = (int) $num;
                }
            }
        }
        return $seats;
    }

    /**
     * Broadcast a seat status update via WebSocket.
     */
    private function broadcastSeatUpdate(string $tripId, string $event, array $seatNumbers, array $snapshot): void
    {
        try {
            broadcast(new SeatHeldUpdated(
                tripId:        $tripId,
                event:         $event,
                seatNumbers:   $seatNumbers,
                heldSeats:     $snapshot['heldSeats'] ?? [],
                bookedSeats:   $snapshot['bookedSeats'] ?? [],
                totalSeats:    $snapshot['totalSeats'] ?? 0,
                availableSeats: $snapshot['availableSeats'] ?? 0,
            ));
        } catch (\Exception $e) {
            Log::warning('SeatHoldService: broadcast failed (non-fatal)', [
                'error' => $e->getMessage(),
                'trip_id' => $tripId,
                'event'   => $event,
            ]);
        }
    }
}
