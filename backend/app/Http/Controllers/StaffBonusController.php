<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * NEXATRACE — STAFF BONUS CONTROLLER
 * ====================================
 *
 * CRUD for staff bonuses (mountain terrain, festive, overtime,
 * target, special trip). Scoped to the authenticated user's
 * bus_company_id so each fleet/owner manages only their own
 * bonuses.
 *
 * ROUTES:
 *   GET    /api/v1/bus-fleet/bonuses
 *   POST   /api/v1/bus-fleet/bonuses
 *   PUT    /api/v1/bus-fleet/bonuses/{id}
 *   DELETE /api/v1/bus-fleet/bonuses/{id}
 */

class StaffBonusController extends Controller
{
    /**
     * List all bonuses for the authenticated fleet/owner.
     */
    public function index(Request $request): JsonResponse
    {
        if (! Schema::hasTable('staff_bonuses')) {
            return response()->json(['success' => true, 'data' => [], 'count' => 0]);
        }

        $user = $request->user();
        $carrierId = $request->get('_carrier_company_id');
        $ownerIdentityId = $user->global_identity_id ?? null;
        $panelPrefix = $request->route()->getPrefix();

        $query = DB::table('staff_bonuses');

        if (str_contains($panelPrefix, 'bus-owner') && $ownerIdentityId) {
            $query->where('bus_company_id', $ownerIdentityId);
        } elseif ($carrierId) {
            $query->where('bus_company_id', $carrierId);
        }

        $bonuses = $query->orderByDesc('created_at')->get();

        return response()->json([
            'success' => true,
            'data'    => $bonuses,
            'count'   => $bonuses->count(),
        ]);
    }

    /**
     * Create a new bonus.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $carrierId = $request->get('_carrier_company_id');
        $ownerIdentityId = $user->global_identity_id ?? null;
        $panelPrefix = $request->route()->getPrefix();

        $busCompanyId = str_contains($panelPrefix, 'bus-owner')
            ? $ownerIdentityId
            : $carrierId;

        $data = $request->validate([
            'bonus_name'     => ['required', 'string', 'max:255'],
            'staff_type'     => ['required', 'in:driver,conductor,office_staff'],
            'bonus_category' => ['required', 'in:mountain_terrain,festive,overtime,target,special_trip'],
            'amount_type'    => ['required', 'in:percentage,fixed'],
            'amount_value'   => ['required', 'numeric', 'min:0'],
            'is_active'      => ['boolean'],
        ]);

        $bonusId = (string) Str::uuid();

        DB::table('staff_bonuses')->insert([
            'id'              => $bonusId,
            'bus_company_id'  => $busCompanyId,
            'bonus_name'      => $data['bonus_name'],
            'staff_type'      => $data['staff_type'],
            'bonus_category'  => $data['bonus_category'],
            'amount_type'     => $data['amount_type'],
            'amount_value'    => $data['amount_value'],
            'is_active'       => $data['is_active'] ?? true,
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        return response()->json([
            'success' => true,
            'data'    => DB::table('staff_bonuses')->where('id', $bonusId)->first(),
            'message' => 'Bonus created.',
        ], 201);
    }

    /**
     * Update a bonus.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $bonus = DB::table('staff_bonuses')->where('id', $id)->first();
        if (! $bonus) {
            return response()->json(['success' => false, 'message' => 'Bonus not found.'], 404);
        }

        $data = $request->validate([
            'bonus_name'     => ['sometimes', 'string', 'max:255'],
            'staff_type'     => ['sometimes', 'in:driver,conductor,office_staff'],
            'bonus_category' => ['sometimes', 'in:mountain_terrain,festive,overtime,target,special_trip'],
            'amount_type'    => ['sometimes', 'in:percentage,fixed'],
            'amount_value'   => ['sometimes', 'numeric', 'min:0'],
            'is_active'      => ['boolean'],
        ]);

        $update = [];
        foreach (['bonus_name', 'staff_type', 'bonus_category', 'amount_type', 'amount_value'] as $f) {
            if (array_key_exists($f, $data)) {
                $update[$f] = $data[$f];
            }
        }
        if (array_key_exists('is_active', $data)) {
            $update['is_active'] = $data['is_active'];
        }
        $update['updated_at'] = now();

        DB::table('staff_bonuses')->where('id', $id)->update($update);

        return response()->json([
            'success' => true,
            'data'    => DB::table('staff_bonuses')->where('id', $id)->first(),
            'message' => 'Bonus updated.',
        ]);
    }

    /**
     * Delete a bonus.
     */
    public function destroy(string $id): JsonResponse
    {
        $bonus = DB::table('staff_bonuses')->where('id', $id)->first();
        if (! $bonus) {
            return response()->json(['success' => false, 'message' => 'Bonus not found.'], 404);
        }

        DB::table('staff_bonuses')->where('id', $id)->delete();

        return response()->json(['success' => true, 'message' => 'Bonus deleted.']);
    }
}
