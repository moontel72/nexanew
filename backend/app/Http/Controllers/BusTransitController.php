<?php

namespace App\Http\Controllers;

use App\Models\Transport\BusLayout;
use App\Models\Transport\BusQrCode;
use App\Models\Transport\NexatraceVoucher;
use App\Services\Transport\BusInventoryService;
use App\Services\Transport\LayoutService;
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
        private LayoutService $layouts,
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

    // ─── WAVE 4: SEAT LAYOUT DESIGNER (14E) ─────────────

    /**
     * GET /api/v1/bus-fleet/layouts
     *
     * List all layouts for the authenticated user's company.
     */
    public function listLayouts(Request $request): JsonResponse
    {
        try {
            $companyId = $this->resolveCompanyId($request);
            $vehicleClass = $request->query('vehicle_class');
            $perPage = (int) $request->query('per_page', 20);

            $result = $this->layouts->listLayouts($companyId, $vehicleClass, $perPage);

            return response()->json(['success' => true, ...$result]);
        } catch (\Exception $e) {
            Log::error('BusTransit - listLayouts Error: ' . $e->getMessage(), [
                'user_id' => $request->user()?->id,
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * GET /api/v1/bus-fleet/layouts/{id}
     *
     * Get a single layout with current snapshot and revision info.
     */
    public function getLayout(string $id): JsonResponse
    {
        try {
            $result = $this->layouts->getLayout($id);
            return response()->json(['success' => true, ...$result]);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 404);
        } catch (\Exception $e) {
            Log::error('BusTransit - getLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-fleet/layouts
     *
     * Create a new layout from a vehicle-class preset.
     */
    public function createLayoutFull(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'vehicle_class'   => ['required', 'string', 'in:coach_54,standard_45,coaster_34,hiace_13,sleeper_custom'],
                'display_name'    => ['required', 'string', 'max:160'],
                'deck_level'      => ['nullable', 'integer', 'in:0,1'],
                'owner_identity_id' => ['nullable', 'string', 'max:100'],
                'company_id'      => ['nullable', 'string', 'max:100'],
            ]);

            $ownerIdentityId = $data['owner_identity_id'] ?? $this->resolveOwnerIdentityId($request);
            $companyId = $data['company_id'] ?? $this->resolveCompanyId($request);

            $result = $this->layouts->createLayout(
                ownerIdentityId: $ownerIdentityId,
                companyId: $companyId,
                vehicleClass: $data['vehicle_class'],
                displayName: $data['display_name'],
                deckLevel: (int) ($data['deck_level'] ?? 0),
            );

            return response()->json(['success' => true, 'data' => $result], 201);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        } catch (\Exception $e) {
            Log::error('BusTransit - createLayoutFull Error: ' . $e->getMessage(), [
                'user_id' => $request->user()?->id,
            ]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-fleet/layouts/{id}/acquire-lock
     *
     * Acquire a 5-minute edit lock on a layout.
     */
    public function acquireLock(string $id, Request $request): JsonResponse
    {
        try {
            $identityId = $this->resolveOwnerIdentityId($request);

            $acquired = $this->layouts->acquireEditLock($id, $identityId);

            if ($acquired) {
                return response()->json([
                    'success' => true,
                    'message' => 'Edit lock acquired.',
                    'data'    => ['layout_id' => $id, 'expires_in_minutes' => 5],
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Edit lock is currently held by another user.',
            ], 409);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 404);
        } catch (\Exception $e) {
            Log::error('BusTransit - acquireLock Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-fleet/layouts/{id}/release-lock
     *
     * Release the edit lock on a layout.
     */
    public function releaseLock(string $id): JsonResponse
    {
        try {
            $this->layouts->releaseEditLock($id);

            return response()->json([
                'success' => true,
                'message' => 'Edit lock released.',
            ]);
        } catch (\Exception $e) {
            Log::error('BusTransit - releaseLock Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * POST /api/v1/bus-fleet/layouts/{id}/publish
     *
     * Publish a layout revision with optimistic concurrency.
     */
    public function publishLayout(string $id, Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'grid_snapshot'      => ['required', 'array'],
                'expected_version'   => ['required', 'integer', 'min:1'],
                'change_description' => ['nullable', 'string', 'max:1000'],
            ]);

            $identityId = $this->resolveOwnerIdentityId($request);

            $result = $this->layouts->publishLayout(
                layoutId: $id,
                identityId: $identityId,
                gridSnapshot: $data['grid_snapshot'],
                expectedVersion: (int) $data['expected_version'],
                changeDescription: $data['change_description'] ?? null,
            );

            return response()->json(['success' => true, 'data' => $result]);
        } catch (\RuntimeException $e) {
            $code = str_contains($e->getMessage(), 'Version conflict') ? 409 : 422;
            return response()->json(['success' => false, 'message' => $e->getMessage()], $code);
        } catch (\Exception $e) {
            Log::error('BusTransit - publishLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * GET /api/v1/bus-fleet/layouts/{id}/revisions
     *
     * Get revision history for a layout, newest first.
     */
    public function listRevisions(string $id): JsonResponse
    {
        try {
            $result = $this->layouts->listRevisions($id);
            return response()->json(['success' => true, ...$result]);
        } catch (\Exception $e) {
            Log::error('BusTransit - listRevisions Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * GET /api/v1/bus-fleet/layout-presets
     *
     * Return the static vehicle-class preset definitions.
     */
    public function listPresets(): JsonResponse
    {
        try {
            $presets = $this->layouts->getPresets();
            return response()->json(['success' => true, 'presets' => $presets]);
        } catch (\Exception $e) {
            Log::error('BusTransit - listPresets Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * DELETE /api/v1/bus-fleet/layouts/{id}
     *
     * Soft-delete (archive) a layout.
     */
    public function archiveLayout(string $id): JsonResponse
    {
        try {
            $this->layouts->archiveLayout($id);

            return response()->json([
                'success' => true,
                'message' => 'Layout archived.',
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 404);
        } catch (\Exception $e) {
            Log::error('BusTransit - archiveLayout Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
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
