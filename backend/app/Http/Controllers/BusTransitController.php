<?php

namespace App\Http\Controllers;

use App\Models\Transport\BusQrCode;
use App\Models\Transport\NexatraceVoucher;
use App\Services\Transport\BusInventoryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS TRANSIT CONTROLLER
 * ====================================
 *
 * REST API for the Bus Ecosystem (Modules 13, 14, 15, 8V, 8W).
 *
 * SAFETY: Entirely new controller. Zero modification to existing code.
 * Routes wired in routes/panels/bus_fleet.php.
 */

class BusTransitController extends Controller
{
    public function __construct(
        private BusInventoryService $bus,
        private \App\Services\Transport\SeatHoldService $holdService,
    ) {}

    // ─── BUS DOOR QR (15E) ──────────────────────────────

    public function registerQr(Request $request): JsonResponse
    {
        $data = $request->validate([
            'bus_id' => ['required', 'string', 'exists:absolute_bus_layouts,id'],
            'active_trip_id' => ['nullable', 'string', 'max:100'],
        ]);

        $qr = BusQrCode::create([
            'id' => (string) Str::uuid(),
            'bus_id' => $data['bus_id'],
            'qr_payload_uuid' => 'NEXA-BUS-' . Str::uuid()->toString(),
            'active_trip_id' => $data['active_trip_id'] ?? null,
        ]);

        return response()->json(['success' => true, 'data' => $qr], 201);
    }

    public function scanQr(string $uuid): JsonResponse
    {
        $data = $this->bus->scanGateQr($uuid);
        return response()->json(['success' => true, 'data' => $data]);
    }

    // ─── SEAT BOOKING (8V) ──────────────────────────────

    public function bookSeat(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'bus_id' => ['required', 'string', 'max:100'],
            'trip_id' => ['required', 'string', 'max:100'],
            'seat_number' => ['required', 'integer', 'min:1'],
            'payment_method' => ['required', 'string', 'in:wallet,card,voucher'],
            'ticket_price' => ['required', 'numeric', 'min:0'],
            'voucher_code' => ['nullable', 'string', 'max:64'],
            'bus_owner_id' => ['nullable', 'string', 'max:100'],
        ]);

        try {
            $result = $this->bus->bookSeat(
                busId: $data['bus_id'],
                tripId: $data['trip_id'],
                userId: (string) $user->id,
                seatNumber: (int) $data['seat_number'],
                paymentMethod: $data['payment_method'],
                ticketPrice: (float) $data['ticket_price'],
                voucherCode: $data['voucher_code'] ?? null,
                busOwnerId: $data['bus_owner_id'] ?? '',
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result], 201);
    }

    // ─── SEAT HOLD / RESERVE (Phase 2) ───────────────

    /**
     * POST /api/v1/bus-fleet/bookings/hold
     *
     * Reserve a seat for checkout (8-minute TTL).
     * Auth required. Rejects if within 48 hours of departure.
     *
     * Body: {bus_id, trip_id, seat_number, ttl_minutes?}
     */
    public function holdSeat(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Authentication required.'], 401);
        }

        $data = $request->validate([
            'bus_id'      => ['required', 'string', 'max:100'],
            'trip_id'     => ['required', 'string', 'max:100'],
            'seat_number' => ['required', 'integer', 'min:1'],
            'ttl_minutes' => ['nullable', 'integer', 'min:1', 'max:15'],
        ]);

        try {
            $result = $this->holdService->holdSeat(
                layoutId:   $data['bus_id'],
                tripId:     $data['trip_id'],
                userId:     (string) $user->id,
                seatNumber: (int) $data['seat_number'],
                ttlMinutes: $data['ttl_minutes'] ?? null,
            );
        } catch (\RuntimeException $e) {
            $msg = $e->getMessage();
            $code = 409;
            if (str_contains($msg, 'just claimed') || str_contains($msg, 'already booked')) {
                $code = 409;
            } elseif (str_contains($msg, 'within') && str_contains($msg, 'hours of departure')) {
                $code = 422;
            } elseif (str_contains($msg, 'does not exist') || str_contains($msg, 'not found')) {
                $code = 404;
            }
            return response()->json(['success' => false, 'message' => $msg], $code);
        }

        return response()->json(['success' => true, 'data' => $result], 201);
    }

    /**
     * POST /api/v1/bus-fleet/bookings/{holdToken}/confirm
     *
     * Finalize a held seat — process payment and convert to permanent booking.
     * Auth required. Holden must belong to the authenticated user.
     *
     * Body: {payment_method, ticket_price, voucher_code?, bus_owner_id?}
     */
    public function confirmHold(string $holdToken, Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Authentication required.'], 401);
        }

        $data = $request->validate([
            'payment_method' => ['required', 'string', 'in:wallet,card,voucher'],
            'ticket_price'   => ['required', 'numeric', 'min:0'],
            'voucher_code'   => ['nullable', 'string', 'max:64'],
            'bus_owner_id'   => ['nullable', 'string', 'max:100'],
        ]);

        try {
            $result = $this->holdService->confirmHold(
                holdToken:     $holdToken,
                userId:        (string) $user->id,
                paymentMethod: $data['payment_method'],
                ticketPrice:   (float) $data['ticket_price'],
                voucherCode:   $data['voucher_code'] ?? null,
                busOwnerId:    $data['bus_owner_id'] ?? '',
            );
        } catch (\RuntimeException $e) {
            $msg = $e->getMessage();
            $code = 409;
            if (str_contains($msg, 'expired')) {
                $code = 410; // Gone
            } elseif (str_contains($msg, 'not found')) {
                $code = 404;
            } elseif (str_contains($msg, 'belongs to another')) {
                $code = 403;
            }
            return response()->json(['success' => false, 'message' => $msg], $code);
        }

        return response()->json(['success' => true, 'data' => $result], 200);
    }

    /**
     * DELETE /api/v1/bus-fleet/bookings/{holdToken}/release
     *
     * Explicitly release a held seat (user cancels checkout).
     * Auth required. Hold must belong to the authenticated user.
     */
    public function releaseHold(string $holdToken, Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Authentication required.'], 401);
        }

        try {
            $result = $this->holdService->releaseHold(
                holdToken: $holdToken,
                userId:    (string) $user->id,
            );
        } catch (\RuntimeException $e) {
            $msg = $e->getMessage();
            $code = str_contains($msg, 'not found') ? 404 : 403;
            return response()->json(['success' => false, 'message' => $msg], $code);
        }

        return response()->json(['success' => true, 'data' => $result], 200);
    }

    /**
     * GET /api/v1/bus-fleet/bookings/held/{tripId}
     *
     * Return all currently held seat numbers for a trip with TTL.
     * Public — used by the passenger seat grid to show held seats.
     */
    public function listHeldSeats(string $tripId): JsonResponse
    {
        $held = $this->holdService->getHeldSeatsWithTTL($tripId);
        $holdsAllowed = $this->holdService->holdsAllowed($tripId);

        return response()->json([
            'success' => true,
            'data'    => [
                'trip_id'        => $tripId,
                'held_seats'     => $held,
                'holds_allowed'  => $holdsAllowed,
                'hold_ttl_minutes' => \App\Services\Transport\SeatHoldService::DEFAULT_HOLD_TTL_MINUTES,
            ],
        ]);
    }

    // ─── VOUCHERS ───────────────────────────────────────

    /**
     * POST /api/v1/bus-fleet/vouchers/create
     */
    public function createVoucher(Request $request): JsonResponse
    {
        $shopId = (string) $request->user()->id;

        $data = $request->validate([
            'voucher_code' => ['required', 'string', 'min:8', 'max:64'],
            'amount' => ['required', 'numeric', 'min:10'],
            'expires_at' => ['nullable', 'date', 'after:now'],
        ]);

        $voucher = NexatraceVoucher::create([
            'id' => (string) Str::uuid(),
            'voucher_code_hash' => hash('sha256', $data['voucher_code']),
            'amount' => $data['amount'],
            'currency' => 'PKR',
            'status' => NexatraceVoucher::STATUS_UNUSED,
            'created_by_shop_id' => $shopId,
            'expires_at' => $data['expires_at'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Voucher created. Give the physical code to the customer.',
            'data' => ['voucher_id' => $voucher->id, 'amount' => $voucher->amount],
        ], 201);
    }

    // ─── HELPERS ────────────────────────────────────────

    /**
     * Resolve the company_id from the authenticated user via identity spine.
     *
     * Priority chain:
     *  1. _carrier_company_id set by middleware
     *  2. fleet_assignments lookup (for fleet owners)
     *  3. User IS the company (account_type = bus_company) → own tenant id
     *  4. master_admin fallback
     */
    private function resolveCompanyId(Request $request): string
    {
        // 1. Try the carrier_company_id set by middleware
        $carrierId = $request->get('_carrier_company_id');
        if ($carrierId) {
            return (string) $carrierId;
        }

        $user = $request->user();
        if (!$user) {
            throw new \RuntimeException('Authenticated user required.');
        }

        // 2. Resolve via identity spine: fleet_assignments (for fleet owners)
        $globalId = $user->global_identity_id ?? null;
        if ($globalId) {
            $cid = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->where('global_identity_id', $globalId)
                ->where('role', 'owner')
                ->where('fleet_type', 'bus')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->value('carrier_company_id');
            if ($cid) {
                return (string) $cid;
            }
        }

        // 3. User IS the bus company → their own tenant_accounts.id is the company context
        if (in_array($user->account_type, ['bus_company', 'master_admin'], true)) {
            return (string) ($user->id ?? '');
        }

        throw new \RuntimeException('No company context found.');
    }

    /**
     * Resolve the owner_identity_id (global_identity_id) from the
     * authenticated user.
     */
    private function resolveOwnerIdentityId(Request $request): string
    {
        $user = $request->user();
        if (!$user) {
            throw new \RuntimeException('Authenticated user required.');
        }

        return (string) ($user->global_identity_id ?? $user->id);
    }
}
