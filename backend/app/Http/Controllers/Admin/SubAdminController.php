<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\GlobalIdentity;
use App\Models\IdentityClaim;
use App\Models\TenantAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SubAdminController extends Controller
{
    /**
     * List all sub-admins with their vertical assignments.
     */
    public function index(): JsonResponse
    {
        $subAdmins = DB::table('global_identities')
            ->where('identity_type', 'sub_admin')
            ->leftJoin('sub_admin_assignments', function ($join) {
                $join->on('global_identities.id', '=', 'sub_admin_assignments.global_identity_id')
                    ->whereNull('sub_admin_assignments.revoked_at');
            })
            ->leftJoin('sub_admin_verticals', 'sub_admin_assignments.vertical_id', '=', 'sub_admin_verticals.id')
            ->leftJoin('identity_claims', function ($join) {
                $join->on('global_identities.id', '=', 'identity_claims.global_identity_id')
                    ->where('identity_claims.claim_type', 'email')
                    ->where('identity_claims.is_revoked', false);
            })
            ->select(
                'global_identities.id',
                'global_identities.display_name as name',
                'global_identities.identity_token',
                'global_identities.status',
                'global_identities.created_at as appointed_at',
                'sub_admin_verticals.code as vertical',
                'identity_claims.claim_value as email'
            )
            ->orderBy('global_identities.created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $subAdmins,
        ]);
    }

    /**
     * Create a new sub-admin identity with vertical assignment.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'     => ['required', 'string', 'max:160'],
            'email'    => ['required', 'email', 'max:255'],
            'phone'    => ['nullable', 'string', 'max:30'],
            'cnic'     => ['nullable', 'string', 'max:30'],
            'vertical' => ['required', 'string', 'in:bus_transit,goods_logistics,commercial_marketplace,financial_auditor'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        // 1. Find the vertical
        $vertical = DB::table('sub_admin_verticals')->where('code', $validated['vertical'])->first();
        if (!$vertical) {
            return response()->json(['message' => 'Invalid vertical'], 422);
        }

        // 2. Create GlobalIdentity
        $identity = GlobalIdentity::create([
            'identity_token' => GlobalIdentity::generateToken('sub_admin'),
            'display_name'   => $validated['name'],
            'password'       => $validated['password'],
            'identity_type'  => 'sub_admin',
            'kyc_status'     => 'verified',
            'kyc_tier'       => 2,
            'status'         => 'active',
            'primary_locale' => 'en-PK',
        ]);

        // 3. Create email claim
        IdentityClaim::create([
            'global_identity_id' => $identity->id,
            'claim_type'         => 'email',
            'claim_value'        => IdentityClaim::normalize('email', $validated['email']),
            'is_primary'         => true,
            'verified_via'       => 'admin_provisioned',
            'verified_at'        => now(),
        ]);

        // 4. Create phone claim if provided
        if (!empty($validated['phone'])) {
            IdentityClaim::create([
                'global_identity_id' => $identity->id,
                'claim_type'         => 'phone',
                'claim_value'        => IdentityClaim::normalize('phone', $validated['phone']),
                'is_primary'         => false,
                'verified_via'       => 'admin_provisioned',
                'verified_at'        => now(),
            ]);
        }

        // 5. Find master admin ID for appointment record
        $masterId = DB::table('global_identities')
            ->where('identity_type', 'admin')
            ->value('id');

        // 6. Create sub-admin assignment
        DB::table('sub_admin_assignments')->insert([
            'id'                           => (string) Str::orderedUuid(),
            'global_identity_id'           => $identity->id,
            'vertical_id'                  => $vertical->id,
            'appointed_by_master_admin_id' => $masterId ?? $identity->id,
            'appointed_at'                 => now(),
            'created_at'                   => now(),
            'updated_at'                   => now(),
        ]);

        // 7. Create TenantAccount bridge for Sanctum token login
        TenantAccount::create([
            'account_name'       => $validated['name'],
            'email'              => $validated['email'],
            'password'           => $identity->password_hash,
            'phone_number'       => $validated['phone'] ?? null,
            'global_identity_id' => $identity->id,
            'is_independent'     => true,
            'account_type'       => 'sub_admin',
            'status'             => 'active',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Sub-Admin created successfully',
            'data' => [
                'id'              => $identity->id,
                'name'            => $identity->display_name,
                'email'           => $validated['email'],
                'vertical'        => $validated['vertical'],
                'identity_token'  => $identity->identity_token,
            ],
        ], 201);
    }
}
