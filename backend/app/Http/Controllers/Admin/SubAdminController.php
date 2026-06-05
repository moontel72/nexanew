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

    /**
     * Show a single sub-admin with full details.
     */
    public function show(string $id): JsonResponse
    {
        $subAdmin = DB::table('global_identities')
            ->where('global_identities.id', $id)
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
                'global_identities.*',
                'sub_admin_verticals.code as vertical',
                'identity_claims.claim_value as email'
            )
            ->first();

        if (!$subAdmin) {
            return response()->json(['message' => 'Sub-admin not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $subAdmin]);
    }

    /**
     * Update a sub-admin's details (name, email, vertical, password).
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $identity = GlobalIdentity::where('id', $id)
            ->where('identity_type', 'sub_admin')
            ->first();

        if (!$identity) {
            return response()->json(['message' => 'Sub-admin not found'], 404);
        }

        $validated = $request->validate([
            'name'     => ['sometimes', 'string', 'max:160'],
            'email'    => ['sometimes', 'email', 'max:255'],
            'phone'    => ['nullable', 'string', 'max:30'],
            'vertical' => ['sometimes', 'string', 'in:bus_transit,goods_logistics,commercial_marketplace,financial_auditor'],
            'password' => ['sometimes', 'string', 'min:8'],
        ]);

        // Update name
        if (isset($validated['name'])) {
            $identity->update(['display_name' => $validated['name']]);
            // Also update TenantAccount name
            TenantAccount::where('global_identity_id', $id)->update(['account_name' => $validated['name']]);
        }

        // Update password
        if (isset($validated['password'])) {
            $identity->update(['password' => $validated['password']]);
        }

        // Update email claim
        if (isset($validated['email'])) {
            IdentityClaim::updateOrCreate(
                [
                    'global_identity_id' => $id,
                    'claim_type'         => 'email',
                    'is_revoked'         => false,
                ],
                [
                    'claim_value'  => IdentityClaim::normalize('email', $validated['email']),
                    'is_primary'   => true,
                    'verified_via' => 'admin_updated',
                    'verified_at'  => now(),
                ]
            );
            TenantAccount::where('global_identity_id', $id)->update(['email' => $validated['email']]);
        }

        // Change vertical assignment
        if (isset($validated['vertical'])) {
            $vertical = DB::table('sub_admin_verticals')->where('code', $validated['vertical'])->first();
            if ($vertical) {
                // Revoke current assignment
                DB::table('sub_admin_assignments')
                    ->where('global_identity_id', $id)
                    ->whereNull('revoked_at')
                    ->update(['revoked_at' => now()]);

                // Create new assignment
                DB::table('sub_admin_assignments')->insert([
                    'id'                           => (string) Str::orderedUuid(),
                    'global_identity_id'           => $id,
                    'vertical_id'                  => $vertical->id,
                    'appointed_by_master_admin_id' => $identity->id,
                    'appointed_at'                 => now(),
                    'created_at'                   => now(),
                    'updated_at'                   => now(),
                ]);
            }
        }

        return response()->json(['success' => true, 'message' => 'Sub-admin updated']);
    }

    /**
     * Toggle sub-admin status (active ↔ suspended).
     */
    public function toggleStatus(string $id): JsonResponse
    {
        $identity = GlobalIdentity::where('id', $id)
            ->where('identity_type', 'sub_admin')
            ->first();

        if (!$identity) {
            return response()->json(['message' => 'Sub-admin not found'], 404);
        }

        $newStatus = $identity->status === 'active' ? 'suspended' : 'active';
        $identity->update(['status' => $newStatus]);

        // Also update TenantAccount status
        TenantAccount::where('global_identity_id', $id)->update(['status' => $newStatus]);

        return response()->json([
            'success' => true,
            'message' => "Sub-admin {$newStatus}",
            'data'    => ['status' => $newStatus],
        ]);
    }

    /**
     * Soft-delete a sub-admin.
     *
     * Does NOT hard-delete. Instead:
     *   - Revokes all vertical assignments
     *   - Revokes all identity claims (email, phone)
     *   - Sets status to 'deleted' with timestamp
     *   - Deactivates tenant account
     *   - Revokes all API tokens
     *
     * Deleted accounts remain restorable for 30 days, then a scheduled
     * command (PurgeDeletedSubAdmins) permanently removes them.
     */
    public function destroy(string $id): JsonResponse
    {
        $identity = GlobalIdentity::where('id', $id)
            ->where('identity_type', 'sub_admin')
            ->first();

        if (!$identity) {
            return response()->json(['message' => 'Sub-admin not found'], 404);
        }

        // Don't re-delete
        if ($identity->status === 'deleted') {
            return response()->json(['message' => 'Already deleted'], 409);
        }

        // Revoke all assignments
        DB::table('sub_admin_assignments')
            ->where('global_identity_id', $id)
            ->whereNull('revoked_at')
            ->update(['revoked_at' => now()]);

        // Revoke all claims
        IdentityClaim::where('global_identity_id', $id)
            ->where('is_revoked', false)
            ->update(['is_revoked' => true, 'revoked_at' => now()]);

        // Soft-delete identity
        $identity->update([
            'status'     => 'deleted',
            'deleted_at' => now(),
        ]);

        // Deactivate tenant account
        TenantAccount::where('global_identity_id', $id)->update([
            'status'     => 'deleted',
            'deleted_at' => now(),
        ]);

        // Revoke API tokens (safe — catches column-type mismatches)
        try {
            $tenantIds = TenantAccount::where('global_identity_id', $id)->pluck('id');
            if ($tenantIds->isNotEmpty()) {
                DB::table('personal_access_tokens')
                    ->where('tokenable_type', 'App\Models\TenantAccount')
                    ->whereIn('tokenable_id', $tenantIds->toArray())
                    ->delete();
            }
        } catch (\Exception $e) {
            report($e);
        }

        return response()->json(['success' => true, 'message' => 'Sub-admin deleted (restorable for 30 days)']);
    }

    /**
     * Restore a soft-deleted sub-admin.
     */
    public function restore(string $id): JsonResponse
    {
        $identity = GlobalIdentity::where('id', $id)
            ->where('identity_type', 'sub_admin')
            ->where('status', 'deleted')
            ->first();

        if (!$identity) {
            return response()->json(['message' => 'Sub-admin not found or not deleted'], 404);
        }

        // Reactivate identity
        $identity->update(['status' => 'active', 'deleted_at' => null]);

        // Reactivate tenant account
        TenantAccount::where('global_identity_id', $id)->update([
            'status'     => 'active',
            'deleted_at' => null,
        ]);

        // Re-activate the most recent claim per type
        $types = IdentityClaim::where('global_identity_id', $id)
            ->where('is_revoked', true)
            ->distinct('claim_type')
            ->pluck('claim_type');

        foreach ($types as $type) {
            IdentityClaim::where('global_identity_id', $id)
                ->where('claim_type', $type)
                ->where('is_revoked', true)
                ->orderBy('revoked_at', 'desc')
                ->take(1)
                ->update(['is_revoked' => false, 'revoked_at' => null]);
        }

        return response()->json(['success' => true, 'message' => 'Sub-admin restored']);
    }
}
