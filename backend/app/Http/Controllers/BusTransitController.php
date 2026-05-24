<?php

namespace App\Http\Controllers;

use App\Models\Transport\BusLayout;
use App\Models\Transport\BusQrCode;
use App\Models\Transport\NexatraceVoucher;
use App\Services\Transport\BusInventoryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
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
        private BusInventoryService $bus
    ) {}

    // ─── BUS OWNER: Seat Layout Builder (14E) ───────────

    /**
     * POST /api/v1/bus-fleet/owners/layouts
     */
    public function createLayout(Request $request): JsonResponse
    {
        $user = $request->user();

        $data = $request->validate([
            'bus_id' => ['required', 'string', 'max:100'],
            'total_rows' => ['required', 'integer', 'min:4', 'max:20'],
            'left_columns' => ['required', 'integer', 'in:2,3'],
            'right_columns' => ['required', 'integer', 'in:1,2'],
            'driver_seats' => ['required', 'integer', 'in:1,2'],
            'raw_grid_json' => ['required', 'array'],
        ]);

        $layout = BusLayout::create([
            'id' => (string) Str::uuid(),
            'bus_id' => $data['bus_id'],
            'owner_id' => (string) $user->id,
            'total_rows' => $data['total_rows'],
            'left_columns' => $data['left_columns'],
            'right_columns' => $data['right_columns'],
            'driver_seats' => $data['driver_seats'],
            'raw_grid_json' => $data['raw_grid_json'],
        ]);

        return response()->json([
            'success' => true,
            'data' => array_merge($layout->toArray(), ['total_seats' => $layout->totalSeats()]),
        ], 201);
    }

    // ─── BUS DOOR QR (15E) ──────────────────────────────

    /**
     * POST /api/v1/bus-fleet/qr/register
     */
    public function registerQr(Request $request): JsonResponse
    {
        $data = $request->validate([
            'bus_id' => ['required', 'string', 'exists:transport_bus_layouts,bus_id'],
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

    /**
     * GET /api/v1/bus-fleet/qr/scan/{uuid}
     *
     * Customer scans bus door QR → returns live bus data.
     */
    public function scanQr(string $uuid): JsonResponse
    {
        $data = $this->bus->scanGateQr($uuid);
        return response()->json(['success' => true, 'data' => $data]);
    }

    // ─── SEAT BOOKING (8V) ──────────────────────────────

    /**
     * POST /api/v1/bus-fleet/bookings
     */
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
}
