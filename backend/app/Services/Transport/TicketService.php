<?php

namespace App\Services\Transport;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — TICKET ISSUANCE & VERIFICATION SERVICE
 * ===================================================
 *
 * Generates tamper-proof ticket credentials on booking confirmation.
 * Handles ticket lifecycle: issued → boarded → completed.
 *
 * TICKET HASH: SHA-256(booking_id + app_key + seat_number + timestamp)
 *   — Tamper-proof seal binding the booking to a unique credential.
 *   — Stored in transport_seat_bookings.ticket_hash (unique index).
 *
 * QR PAYLOAD: JSON bundle for gate-scan verification via BusInventoryService.
 *   — Contains: booking_id, bus_id, trip_id, seat_number, ticket_hash.
 *   — Encoded as base64 for compact QR encoding.
 *
 * TARGET MODULES: 8V, 15C, 15E
 */
class TicketService
{
    /**
     * Issue a ticket after successful booking confirmation.
     * Called from SeatHoldService::confirmHold() or BusInventoryService::bookSeat().
     *
     * @param string $bookingId  transport_seat_bookings.id
     * @return array {ticket_hash, qr_payload, qr_base64}
     */
    public function issueTicket(string $bookingId): array
    {
        $booking = DB::table('transport_seat_bookings')
            ->where('id', $bookingId)
            ->first();

        if (! $booking) {
            throw new \RuntimeException('Booking not found.');
        }

        if (! empty($booking->ticket_hash)) {
            // Ticket already issued — return existing credentials
            return [
                'ticket_hash' => $booking->ticket_hash,
                'qr_payload'  => json_decode($booking->qr_payload ?? '{}', true),
                'qr_base64'   => $this->encodeQrPayload($booking->qr_payload ?? '{}'),
            ];
        }

        // ─── Generate tamper-proof hash ─────────────────
        $ticketHash = $this->computeTicketHash(
            bookingId: $bookingId,
            seatNumber: $booking->seat_number,
            timestamp: (string) ($booking->booked_at ?? now()),
        );

        // ─── Build QR verification payload ──────────────
        $qrPayload = [
            'v'  => 1,                          // schema version
            'bid'=> $bookingId,
            'bus'=> $booking->bus_layout_id,
            'trip'=> $booking->trip_id,
            'seat'=> $booking->seat_number,
            'hash'=> $ticketHash,
            'ts' => now()->toIso8601String(),
        ];

        $qrJson = json_encode($qrPayload, JSON_UNESCAPED_SLASHES);

        // ─── Persist ticket credentials ────────────────
        DB::table('transport_seat_bookings')
            ->where('id', $bookingId)
            ->update([
                'ticket_hash'      => $ticketHash,
                'qr_payload'       => $qrJson,
                'ticket_status'    => 'issued',
                'ticket_issued_at' => now(),
                'updated_at'       => now(),
            ]);

        Log::info('TicketService: ticket issued', [
            'booking_id'  => $bookingId,
            'seat_number' => $booking->seat_number,
            'trip_id'     => $booking->trip_id,
        ]);

        return [
            'ticket_hash' => $ticketHash,
            'qr_payload'  => $qrPayload,
            'qr_base64'   => $this->encodeQrPayload($qrJson),
        ];
    }

    /**
     * Verify a ticket hash against the stored value.
     * Returns the booking row if valid, null otherwise.
     */
    public function verifyTicket(string $bookingId, string $providedHash): ?object
    {
        $booking = DB::table('transport_seat_bookings')
            ->where('id', $bookingId)
            ->where('ticket_hash', $providedHash)
            ->first();

        return $booking ?: null;
    }

    /**
     * Mark a ticket as boarded (conductor gate scan).
     */
    public function markBoarded(string $bookingId): array
    {
        $booking = DB::table('transport_seat_bookings')
            ->where('id', $bookingId)
            ->first();

        if (! $booking) {
            throw new \RuntimeException('Booking not found.');
        }

        if ($booking->ticket_status === 'boarded') {
            return ['status' => 'already_boarded', 'message' => 'Passenger already boarded.'];
        }

        if ($booking->ticket_status === 'cancelled') {
            throw new \RuntimeException('Ticket has been cancelled.');
        }

        DB::table('transport_seat_bookings')
            ->where('id', $bookingId)
            ->update([
                'ticket_status'    => 'boarded',
                'ticket_boarded_at'=> now(),
                'status'           => 'boarded',
                'updated_at'       => now(),
            ]);

        Log::info('TicketService: passenger boarded', [
            'booking_id'  => $bookingId,
            'seat_number' => $booking->seat_number,
            'trip_id'     => $booking->trip_id,
        ]);

        return [
            'status'   => 'boarded',
            'message'  => 'Passenger boarded successfully.',
            'boarded_at' => now()->toIso8601String(),
        ];
    }

    /**
     * Get full ticket data for rendering/download.
     */
    public function getTicketData(string $bookingId): array
    {
        $booking = DB::table('transport_seat_bookings AS tsb')
            ->leftJoin('absolute_bus_layouts AS abl', 'tsb.bus_layout_id', '=', 'abl.id')
            ->leftJoin('transport_bus_trips AS tbt', 'tsb.trip_id', '=', 'tbt.id')
            ->leftJoin('transport_bus_routes AS tbr', 'tbt.route_id', '=', 'tbr.id')
            ->where('tsb.id', $bookingId)
            ->select(
                'tsb.id AS booking_id',
                'tsb.bus_layout_id AS bus_id',
                'tsb.trip_id',
                'tsb.user_id',
                'tsb.seat_number',
                'tsb.payment_method',
                'tsb.ticket_price',
                'tsb.ticket_hash',
                'tsb.qr_payload',
                'tsb.ticket_status',
                'tsb.ticket_issued_at',
                'tsb.ticket_boarded_at',
                'tsb.booked_at',
                'tsb.status AS booking_status',
                'abl.display_name AS bus_name',
                'abl.current_snapshot',
                'tbt.origin',
                'tbt.destination',
                'tbt.scheduled_departure_at',
                'tbt.status AS trip_status',
                'tbr.display_name AS route_name',
                'tbr.route_code',
            )
            ->first();

        if (! $booking) {
            throw new \RuntimeException('Ticket not found.');
        }

        // Resolve seat label from layout snapshot
        $seatLabel = (string) $booking->seat_number;
        $snapshot = is_string($booking->current_snapshot ?? null)
            ? json_decode($booking->current_snapshot, true)
            : ($booking->current_snapshot ?? []);
        $components = $snapshot['components'] ?? [];
        foreach ($components as $c) {
            $num = $c['seat_number'] ?? $c['seatId'] ?? null;
            if ($num !== null && (int) $num === (int) $booking->seat_number) {
                $seatLabel = $c['custom_label']
                    ?? $c['seat_label']
                    ?? $c['seat_id']
                    ?? (string) $booking->seat_number;
                break;
            }
        }

        // Resolve driver/conductor from shift allocations
        $driverName = null;
        $conductorName = null;
        $plate = null;

        // Find the bus plate from layout
        $layoutBus = DB::table('transport_bus_trips')
            ->where('id', $booking->trip_id)
            ->value('bus_id');

        if ($layoutBus) {
            // Try shift allocations
            $shift = DB::table('bus_shift_allocations')
                ->where('bus_number_plate', $layoutBus)
                ->first();

            if ($shift) {
                $plate = $shift->bus_number_plate;
                $driverIds = json_decode($shift->driver_ids ?? '[]', true);
                $conductorIds = json_decode($shift->conductor_ids ?? '[]', true);

                if (! empty($driverIds)) {
                    $driverName = DB::table('global_identities')
                        ->whereIn('id', $driverIds)
                        ->value('display_name');
                }
                if (! empty($conductorIds)) {
                    $conductorName = DB::table('global_identities')
                        ->whereIn('id', $conductorIds)
                        ->value('display_name');
                }
            }
        }

        return [
            'booking_id'       => $booking->booking_id,
            'bus_name'         => $booking->bus_name ?? 'NexaTrace Bus',
            'route_name'       => $booking->route_name ?? "{$booking->origin} → {$booking->destination}",
            'route_code'       => $booking->route_code,
            'origin'           => $booking->origin,
            'destination'      => $booking->destination,
            'trip_id'          => $booking->trip_id,
            'seat_number'      => $booking->seat_number,
            'seat_label'       => $seatLabel,
            'ticket_price'     => $booking->ticket_price,
            'payment_method'   => $booking->payment_method,
            'ticket_hash'      => $booking->ticket_hash,
            'qr_payload'       => $booking->qr_payload,
            'ticket_status'    => $booking->ticket_status,
            'ticket_issued_at' => $booking->ticket_issued_at,
            'ticket_boarded_at'=> $booking->ticket_boarded_at,
            'booked_at'        => $booking->booked_at,
            'scheduled_departure_at' => $booking->scheduled_departure_at,
            'trip_status'      => $booking->trip_status,
            'driver_name'      => $driverName,
            'conductor_name'   => $conductorName,
            'bus_plate'        => $plate ?? $layoutBus,
        ];
    }

    // ═══════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════

    /**
     * Compute tamper-proof SHA-256 hash.
     */
    public function computeTicketHash(
        string $bookingId,
        int $seatNumber,
        string $timestamp,
    ): string {
        $secret = config('app.key') ?? 'nexatrace-secret';
        $payload = "{$bookingId}|{$seatNumber}|{$timestamp}|{$secret}";
        return hash('sha256', $payload);
    }

    /**
     * Encode QR payload as compact base64 for QR code embedding.
     */
    private function encodeQrPayload(string $qrJson): string
    {
        return base64_encode($qrJson);
    }
}
