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

/**
 * Sub-Admin Bus Company Management Controller
 *
 * Allows Sub-Admins (bus_transit vertical) to onboard and manage
 * bus company tenant accounts under their jurisdiction.
 */
class SubAdminBusCompanyController extends Controller
{
    /**
     * List all bus companies created by the authenticated sub-admin.
     */
    public function index(Request $request): JsonResponse
    {
        $subAdmin = $request->user();
        $subAdminId = $subAdmin->global_identity_id;

        $companies = TenantAccount::where('account_type', 'bus_company')
            ->where('parent_account_id', $subAdmin->id)
            ->orWhere(function ($q) use ($subAdminId) {
                // Fallback: companies linked to this sub-admin via metadata
                $q->where('account_type', 'bus_company')
                  ->whereJsonContains('metadata->created_by_sub_admin_id', $subAdminId);
            })
            ->orderBy('created_at', 'desc')
            ->get([
                'id', 'account_name', 'email', 'phone_number',
                'status', 'created_at', 'metadata'
            ]);

        return response()->json([
            'success' => true,
            'data'    => $companies,
        ]);
    }

    /**
     * Create a new bus company under this sub-admin's jurisdiction.
     */
    public function store(Request $request): JsonResponse
    {
        $subAdmin = $request->user();

        $validated = $request->validate([
            'company_name'      => ['required', 'string', 'max:160'],
            'email'             => ['required', 'email', 'max:255'],
            'password'          => ['required', 'string', 'min:8'],
            'phone'             => ['nullable', 'string', 'max:30'],
            'registration_code' => ['nullable', 'string', 'max:50'],
            'fleet_size'        => ['nullable', 'integer', 'min:0'],
            'transit_license'   => ['nullable', 'string', 'max:100'],
        ]);

        // 1. Create GlobalIdentity for the bus company owner
        $identity = GlobalIdentity::create([
            'identity_token' => GlobalIdentity::generateToken('owner'),
            'display_name'   => $validated['company_name'],
            'password'       => $validated['password'],
            'identity_type'  => 'owner',
            'kyc_status'     => 'pending',
            'kyc_tier'       => 1,
            'status'         => 'pending',
            'primary_locale' => 'en-PK',
        ]);

        // 2. Create email claim
        IdentityClaim::create([
            'global_identity_id' => $identity->id,
            'claim_type'         => 'email',
            'claim_value'        => IdentityClaim::normalize('email', $validated['email']),
            'is_primary'         => true,
            'verified_via'       => 'sub_admin_provisioned',
            'verified_at'        => now(),
        ]);

        // 3. Create phone claim if provided
        if (!empty($validated['phone'])) {
            IdentityClaim::create([
                'global_identity_id' => $identity->id,
                'claim_type'         => 'phone',
                'claim_value'        => IdentityClaim::normalize('phone', $validated['phone']),
                'is_primary'         => false,
                'verified_via'       => 'sub_admin_provisioned',
                'verified_at'        => now(),
            ]);
        }

        // 4. Create TenantAccount as bus_company, child of sub-admin
        $company = TenantAccount::create([
            'account_name'       => $validated['company_name'],
            'email'              => $validated['email'],
            'password'           => $identity->password_hash,
            'phone_number'       => $validated['phone'] ?? null,
            'global_identity_id' => $identity->id,
            'parent_account_id'  => $subAdmin->id,
            'is_independent'     => false,
            'account_type'       => 'bus_company',
            'status'             => 'pending',
            'metadata'           => json_encode([
                'registration_code'    => $validated['registration_code'] ?? null,
                'fleet_size'           => $validated['fleet_size'] ?? 0,
                'transit_license'      => $validated['transit_license'] ?? null,
                'created_by_sub_admin_id' => $subAdmin->global_identity_id,
                'created_by_sub_admin_name' => $subAdmin->account_name,
            ]),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Bus company created successfully',
            'data'    => [
                'id'              => $company->id,
                'company_name'    => $company->account_name,
                'email'           => $company->email,
                'status'          => $company->status,
                'fleet_size'      => $validated['fleet_size'] ?? 0,
                'identity_token'  => $identity->identity_token,
            ],
        ], 201);
    }

    /**
     * Show a single bus company detail.
     */
    public function show(string $id): JsonResponse
    {
        $company = TenantAccount::where('id', $id)
            ->where('account_type', 'bus_company')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Bus company not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => $company,
        ]);
    }

    /**
     * Update bus company status to a specific value.
     * Accepts: verified, active, inactive, suspended, deleted.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:verified,active,inactive,suspended,deleted'],
        ]);

        $company = TenantAccount::where('id', $id)
            ->where('account_type', 'bus_company')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Bus company not found'], 404);
        }

        $newStatus = $validated['status'];

        // Handle soft-delete special case
        if ($newStatus === 'deleted') {
            $company->update(['status' => 'deleted', 'deleted_at' => now()]);
            if ($company->global_identity_id) {
                GlobalIdentity::where('id', $company->global_identity_id)
                    ->update(['status' => 'deleted', 'deleted_at' => now()]);
            }
        } else {
            $company->update(['status' => $newStatus, 'deleted_at' => null]);
            if ($company->global_identity_id) {
                GlobalIdentity::where('id', $company->global_identity_id)
                    ->update(['status' => $newStatus, 'deleted_at' => null]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => "Bus company status updated to {$newStatus}",
            'data'    => ['status' => $newStatus],
        ]);
    }

    /**
     * Toggle bus company status (active ↔ suspended) — legacy, kept for backward compat.
     */
    public function toggleStatus(string $id): JsonResponse
    {
        $company = TenantAccount::where('id', $id)
            ->where('account_type', 'bus_company')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Bus company not found'], 404);
        }

        $newStatus = $company->status === 'active' ? 'suspended' : 'active';
        $company->update(['status' => $newStatus]);

        if ($company->global_identity_id) {
            GlobalIdentity::where('id', $company->global_identity_id)
                ->update(['status' => $newStatus]);
        }

        return response()->json([
            'success' => true,
            'message' => "Bus company {$newStatus}",
            'data'    => ['status' => $newStatus],
        ]);
    }

    /**
     * Update bus company details.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $company = TenantAccount::where('id', $id)
            ->where('account_type', 'bus_company')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Bus company not found'], 404);
        }

        $validated = $request->validate([
            'company_name'      => ['sometimes', 'string', 'max:160'],
            'email'             => ['sometimes', 'email', 'max:255'],
            'password'          => ['sometimes', 'string', 'min:8'],
            'phone'             => ['nullable', 'string', 'max:30'],
            'registration_code' => ['nullable', 'string', 'max:50'],
            'fleet_size'        => ['nullable', 'integer', 'min:0'],
            'transit_license'   => ['nullable', 'string', 'max:100'],
        ]);

        // Update account name
        if (isset($validated['company_name'])) {
            $company->update(['account_name' => $validated['company_name']]);
            if ($company->global_identity_id) {
                GlobalIdentity::where('id', $company->global_identity_id)
                    ->update(['display_name' => $validated['company_name']]);
            }
        }

        // Update email
        if (isset($validated['email'])) {
            $company->update(['email' => $validated['email']]);
            if ($company->global_identity_id) {
                IdentityClaim::updateOrCreate(
                    ['global_identity_id' => $company->global_identity_id, 'claim_type' => 'email', 'is_revoked' => false],
                    ['claim_value' => IdentityClaim::normalize('email', $validated['email']), 'is_primary' => true, 'verified_via' => 'admin_updated', 'verified_at' => now()]
                );
            }
        }

        // Update password
        if (isset($validated['password'])) {
            if ($company->global_identity_id) {
                GlobalIdentity::where('id', $company->global_identity_id)
                    ->update(['password' => $validated['password']]);
            }
        }

        // Update metadata fields
        $meta = json_decode($company->metadata ?? '{}', true) ?: [];
        if (isset($validated['registration_code'])) $meta['registration_code'] = $validated['registration_code'];
        if (isset($validated['fleet_size'])) $meta['fleet_size'] = (int) $validated['fleet_size'];
        if (isset($validated['transit_license'])) $meta['transit_license'] = $validated['transit_license'];
        $company->update(['metadata' => json_encode($meta)]);

        return response()->json(['success' => true, 'message' => 'Bus company updated']);
    }

    /**
     * Soft-delete a bus company.
     */
    public function destroy(string $id): JsonResponse
    {
        $company = TenantAccount::where('id', $id)
            ->where('account_type', 'bus_company')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Bus company not found'], 404);
        }

        $company->update(['status' => 'deleted', 'deleted_at' => now()]);

        if ($company->global_identity_id) {
            GlobalIdentity::where('id', $company->global_identity_id)
                ->update(['status' => 'deleted', 'deleted_at' => now()]);
        }

        return response()->json(['success' => true, 'message' => 'Bus company deleted (restorable for 30 days)']);
    }

    /**
     * Restore a soft-deleted bus company.
     */
    public function restore(string $id): JsonResponse
    {
        $company = TenantAccount::where('id', $id)
            ->where('account_type', 'bus_company')
            ->where('status', 'deleted')
            ->first();

        if (!$company) {
            return response()->json(['message' => 'Bus company not found or not deleted'], 404);
        }

        $company->update(['status' => 'active', 'deleted_at' => null]);

        if ($company->global_identity_id) {
            GlobalIdentity::where('id', $company->global_identity_id)
                ->update(['status' => 'active', 'deleted_at' => null]);
        }

        return response()->json(['success' => true, 'message' => 'Bus company restored']);
    }
}
