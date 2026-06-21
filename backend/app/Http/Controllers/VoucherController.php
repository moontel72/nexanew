<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * NEXATRACE — VOUCHER CONTROLLER
 * ================================
 *
 * CRUD for bus vouchers/promos. Scoped to the authenticated
 * user's bus_company_id so each fleet/owner manages only
 * their own vouchers.
 *
 * ROUTES:
 *   GET    /api/v1/bus-fleet/vouchers
 *   POST   /api/v1/bus-fleet/vouchers
 *   PUT    /api/v1/bus-fleet/vouchers/{id}
 *   DELETE /api/v1/bus-fleet/vouchers/{id}
 */

class VoucherController extends Controller
{
    /**
     * List all vouchers for the authenticated fleet/owner.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $carrierId = $request->get('_carrier_company_id');
        $ownerIdentityId = $user->global_identity_id ?? null;
        $panelPrefix = $request->route()->getPrefix();

        $query = DB::table('bus_vouchers');

        if (str_contains($panelPrefix, 'bus-owner') && $ownerIdentityId) {
            $query->where('bus_company_id', $ownerIdentityId);
        } elseif ($carrierId) {
            $query->where('bus_company_id', $carrierId);
        }

        $vouchers = $query->orderByDesc('created_at')->get();

        return response()->json([
            'success' => true,
            'data'    => $vouchers,
            'count'   => $vouchers->count(),
        ]);
    }

    /**
     * Create a new voucher.
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
            'code'        => ['required', 'string', 'max:30', 'unique:bus_vouchers,code'],
            'title'       => ['required', 'string', 'max:255'],
            'type'        => ['required', 'in:percentage,fixed,multiplier'],
            'value'       => ['required', 'numeric', 'min:0'],
            'min_order'   => ['nullable', 'numeric', 'min:0'],
            'max_discount'=> ['nullable', 'numeric', 'min:0'],
            'usage_limit' => ['nullable', 'integer', 'min:1'],
            'starts_at'   => ['nullable', 'date'],
            'expires_at'  => ['nullable', 'date'],
            'is_active'   => ['boolean'],
        ]);

        $voucherId = (string) Str::uuid();

        DB::table('bus_vouchers')->insert([
            'id'              => $voucherId,
            'bus_company_id'  => $busCompanyId,
            'code'            => strtoupper($data['code']),
            'title'           => $data['title'],
            'type'            => $data['type'],
            'value'           => $data['value'],
            'min_order'       => $data['min_order'] ?? 0,
            'max_discount'    => $data['max_discount'] ?? null,
            'usage_limit'     => $data['usage_limit'] ?? null,
            'starts_at'       => $data['starts_at'] ?? null,
            'expires_at'      => $data['expires_at'] ?? null,
            'is_active'       => $data['is_active'] ?? true,
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        return response()->json([
            'success' => true,
            'data'    => DB::table('bus_vouchers')->where('id', $voucherId)->first(),
            'message' => 'Voucher created.',
        ], 201);
    }

    /**
     * Update a voucher.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $voucher = DB::table('bus_vouchers')->where('id', $id)->first();
        if (! $voucher) {
            return response()->json(['success' => false, 'message' => 'Voucher not found.'], 404);
        }

        $data = $request->validate([
            'code'        => ['sometimes', 'string', 'max:30', "unique:bus_vouchers,code,{$id}"],
            'title'       => ['sometimes', 'string', 'max:255'],
            'type'        => ['sometimes', 'in:percentage,fixed,multiplier'],
            'value'       => ['sometimes', 'numeric', 'min:0'],
            'min_order'   => ['nullable', 'numeric', 'min:0'],
            'max_discount'=> ['nullable', 'numeric', 'min:0'],
            'usage_limit' => ['nullable', 'integer', 'min:1'],
            'starts_at'   => ['nullable', 'date'],
            'expires_at'  => ['nullable', 'date'],
            'is_active'   => ['boolean'],
        ]);

        $update = [];
        foreach (['code', 'title', 'type', 'value', 'min_order', 'max_discount', 'usage_limit', 'starts_at', 'expires_at'] as $f) {
            if (array_key_exists($f, $data)) {
                $update[$f] = $data[$f];
            }
        }
        if (array_key_exists('is_active', $data)) {
            $update['is_active'] = $data['is_active'];
        }
        if (! empty($update['code'])) {
            $update['code'] = strtoupper($update['code']);
        }
        $update['updated_at'] = now();

        DB::table('bus_vouchers')->where('id', $id)->update($update);

        return response()->json([
            'success' => true,
            'data'    => DB::table('bus_vouchers')->where('id', $id)->first(),
            'message' => 'Voucher updated.',
        ]);
    }

    /**
     * Delete a voucher.
     */
    public function destroy(string $id): JsonResponse
    {
        $voucher = DB::table('bus_vouchers')->where('id', $id)->first();
        if (! $voucher) {
            return response()->json(['success' => false, 'message' => 'Voucher not found.'], 404);
        }

        DB::table('bus_vouchers')->where('id', $id)->delete();

        return response()->json(['success' => true, 'message' => 'Voucher deleted.']);
    }
}
