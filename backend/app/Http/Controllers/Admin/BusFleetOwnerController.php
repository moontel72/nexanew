<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\TenantAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Bus Fleet Controller — Owner Dashboard API
 *
 * Provides profile and fleet data for authenticated bus company owners.
 * Uses auth:sanctum guard — tokens issued by GlobalAuthController.
 */
class BusFleetOwnerController extends Controller
{
    /**
     * Owner profile + fleet summary.
     */
    public function profile(Request $request): JsonResponse
    {
        $owner = $request->user();

        return response()->json([
            'success' => true,
            'data'    => [
                'owner_name'       => $owner->account_name ?? 'Owner',
                'company_name'     => $owner->account_name ?? '',
                'email'            => $owner->email ?? '',
                'phone'            => $owner->phone_number ?? '',
                'account_type'     => $owner->account_type ?? 'bus_company',
                'status'           => $owner->status ?? 'active',
                'active_buses'     => $this->getActiveBuses($owner),
                'daily_revenue'    => $this->getDailyRevenue($owner),
                'global_identity_id' => $owner->global_identity_id,
            ],
        ]);
    }

    private function getActiveBuses(TenantAccount $owner): int
    {
        // Count buses from metadata or related tables
        $meta = json_decode($owner->metadata ?? '{}', true) ?: [];
        return (int) ($meta['fleet_size'] ?? 0);
    }

    private function getDailyRevenue(TenantAccount $owner): float
    {
        return 0.0;
    }

    // ─── Fleet Staff Endpoints ──────────────────────────────

    public function owners(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function createOwner(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'message' => 'Owner created'], 201);
    }

    public function drivers(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function createDriver(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'message' => 'Driver created'], 201);
    }

    public function conductors(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function createConductor(Request $request): JsonResponse
    {
        return response()->json(['success' => true, 'message' => 'Conductor created'], 201);
    }
}
