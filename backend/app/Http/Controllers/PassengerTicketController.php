<?php

namespace App\Http\Controllers;

use App\Services\Transport\TicketService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — PASSENGER TICKET CONTROLLER
 * ========================================
 *
 * Secure ticket viewing, download, and gate-scan verification.
 *
 * ROUTES:
 *   GET  /api/v1/passenger/tickets/{bookingId}          — View ticket data (JSON)
 *   GET  /api/v1/passenger/tickets/{bookingId}/download   — Download ticket (HTML/print)
 *   POST /api/v1/passenger/tickets/verify                  — Gate scan verification
 *
 * TARGET MODULES: 8V, 15C, 15E
 */
class PassengerTicketController extends Controller
{
    public function __construct(
        private TicketService $ticketService,
    ) {}

    /**
     * GET /api/v1/passenger/tickets/{bookingId}
     *
     * Return full ticket data as JSON. Auth required — must belong to
     * the authenticated user or be a master admin.
     */
    public function show(string $bookingId, Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Authentication required.'], 401);
        }

        try {
            $ticket = $this->ticketService->getTicketData($bookingId);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 404);
        }

        // Authorization: ticket owner or master admin
        $isOwner = (string) ($ticket['booking_id'] ?? '') === $bookingId;
        // We need to check user_id from the raw booking
        $booking = \Illuminate\Support\Facades\DB::table('transport_seat_bookings')
            ->where('id', $bookingId)
            ->first();

        if (! $booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found.'], 404);
        }

        $isMasterAdmin = ($user->account_type ?? null) === 'master_admin';
        $belongsToUser = (string) $booking->user_id === (string) $user->id;

        if (! $isMasterAdmin && ! $belongsToUser) {
            return response()->json(['success' => false, 'message' => 'This ticket belongs to another passenger.'], 403);
        }

        return response()->json(['success' => true, 'data' => $ticket]);
    }

    /**
     * GET /api/v1/passenger/tickets/{bookingId}/download
     *
     * Serve the printable HTML ticket. Auth required.
     */
    public function download(string $bookingId, Request $request): \Illuminate\Http\Response|\Illuminate\Http\JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Authentication required.'], 401);
        }

        try {
            $ticket = $this->ticketService->getTicketData($bookingId);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 404);
        }

        // Authorization check
        $booking = \Illuminate\Support\Facades\DB::table('transport_seat_bookings')
            ->where('id', $bookingId)->first();

        if (! $booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found.'], 404);
        }

        $isMasterAdmin = ($user->account_type ?? null) === 'master_admin';
        $belongsToUser = (string) $booking->user_id === (string) $user->id;

        if (! $isMasterAdmin && ! $belongsToUser) {
            return response()->json(['success' => false, 'message' => 'Forbidden.'], 403);
        }

        $html = view('tickets.bus_ticket', ['ticket' => $ticket])->render();

        return response($html, 200, [
            'Content-Type' => 'text/html; charset=utf-8',
            'Content-Disposition' => 'inline; filename="nexatrace-ticket-' . $ticket['seat_label'] . '.html"',
        ]);
    }

    /**
     * POST /api/v1/passenger/tickets/verify
     *
     * Gate-scan verification. Accepts a QR payload (base64-encoded JSON)
     * and verifies the ticket hash against the database.
     *
     * Body: {qr_payload: "base64..."}
     *
     * Used by conductor app (Module 15C) at the bus gate.
     */
    public function verify(Request $request): JsonResponse
    {
        $data = $request->validate([
            'qr_payload' => ['required', 'string'],
        ]);

        // Decode base64 QR payload
        $json = base64_decode($data['qr_payload'], true);
        if (! $json) {
            return response()->json(['success' => false, 'message' => 'Invalid QR payload.'], 422);
        }

        $payload = json_decode($json, true);
        if (! $payload || empty($payload['bid']) || empty($payload['hash'])) {
            return response()->json(['success' => false, 'message' => 'Invalid ticket data.'], 422);
        }

        $bookingId = $payload['bid'];
        $providedHash = $payload['hash'];

        // Verify against database
        $booking = $this->ticketService->verifyTicket($bookingId, $providedHash);

        if (! $booking) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid ticket. Hash verification failed.',
                'code'    => 'TICKET_INVALID',
            ], 422);
        }

        if ($booking->ticket_status === 'cancelled') {
            return response()->json([
                'success' => false,
                'message' => 'Ticket has been cancelled.',
                'code'    => 'TICKET_CANCELLED',
            ], 422);
        }

        // Verify bus + trip + seat match (anti-tamper)
        if (! empty($payload['bus']) && (string) $payload['bus'] !== (string) $booking->bus_layout_id) {
            return response()->json([
                'success' => false,
                'message' => 'Ticket does not match this bus.',
                'code'    => 'BUS_MISMATCH',
            ], 422);
        }

        if (! empty($payload['trip']) && (string) $payload['trip'] !== (string) $booking->trip_id) {
            return response()->json([
                'success' => false,
                'message' => 'Ticket does not match this trip.',
                'code'    => 'TRIP_MISMATCH',
            ], 422);
        }

        if (! empty($payload['seat']) && (int) $payload['seat'] !== (int) $booking->seat_number) {
            return response()->json([
                'success' => false,
                'message' => 'Ticket seat number does not match booking.',
                'code'    => 'SEAT_MISMATCH',
            ], 422);
        }

        // Mark as boarded if not already
        $boarded = false;
        if ($booking->ticket_status === 'issued') {
            $this->ticketService->markBoarded($bookingId);
            $boarded = true;
        }

        Log::info('PassengerTicketController: ticket verified at gate', [
            'booking_id'  => $bookingId,
            'seat_number' => $booking->seat_number,
            'boarded'     => $boarded,
        ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'booking_id'    => $bookingId,
                'seat_number'   => $booking->seat_number,
                'trip_id'       => $booking->trip_id,
                'ticket_status' => $boarded ? 'boarded' : $booking->ticket_status,
                'verified'      => true,
                'boarded'       => $boarded,
            ],
        ]);
    }
}
