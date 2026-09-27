<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reseller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Sub-Admin Reseller Account Management Controller — Group-Incharge C2b.
 *
 * Lets the `commercial_marketplace` Sub-Admin (the B2B / Reseller / Shop Keeper group) onboard and
 * manage the reseller accounts of its own group.
 *
 * Mirrors the shape of SubAdminBusCompanyController / SubAdminFactoryCompanyController
 * (index / store / show / update / updateStatus / destroy / restore) on the RESELLER domain object.
 *
 * Differences from the Super Admin path (AdminResellerController), each deliberate:
 *   1. Every row records `created_by_sub_admin_id` — the scoping key this migration adds to `resellers`,
 *      which has no metadata column to hide it in the way `companies` does.
 *   2. Every read/write is scoped to the caller's own resellers, and a foreign id is a 404.
 *   3. No proof/view-proof or approve/reject-purchase endpoints: a Sub-Admin **creates and approves its
 *      own group's accounts outright** (C0 §2b.4 answer (a)), so `purchase_approved` is true at creation —
 *      exactly what AdminResellerController@store does for the Super Admin.
 *
 * NOT here (Phase 6, by design — C0 §2b.3): vertical enforcement. These routes sit behind the `admin`
 * middleware, which admits any active sub-admin, as with bus-companies and factory-companies today.
 */
class SubAdminResellerController extends Controller
{
    /**
     * List the resellers this sub-admin created.
     */
    public function index(Request $request): JsonResponse
    {
        $resellers = $this->ownedQuery($request->user()->global_identity_id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $resellers,
        ]);
    }

    /**
     * Create a reseller account under this sub-admin's jurisdiction.
     */
    public function store(Request $request): JsonResponse
    {
        $subAdmin = $request->user();

        $validated = $request->validate([
            'name'            => ['required', 'string', 'max:255'],
            'business_name'   => ['required', 'string', 'max:255'],
            'registration_no' => ['required', 'string', 'max:100'],
            'email'           => ['required', 'email', 'max:255', 'unique:resellers,email'],
            'phone'           => ['required', 'string', 'max:30', 'unique:resellers,phone'],
            'password'        => ['required', 'string', 'min:8'],
            'city'            => ['required', 'string', 'max:100'],
            'address'         => ['nullable', 'string', 'max:500'],
        ]);

        $reseller = Reseller::create(array_merge($validated, [
            'created_by_sub_admin_id' => $subAdmin->global_identity_id,
            // The sub-admin vouches for its own group's accounts (C0 §2b.4 answer (a)) — the same
            // value AdminResellerController@store sets for the Super Admin.
            'purchase_approved'       => true,
            'status'                  => 'active',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Reseller created successfully',
            'data'    => $reseller,
        ], 201);
    }

    /**
     * Show one reseller owned by this sub-admin.
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $reseller = $this->findOwned($request, $id);

        if (!$reseller) {
            return response()->json(['message' => 'Reseller not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $reseller]);
    }

    /**
     * Update a reseller's details.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $reseller = $this->findOwned($request, $id);

        if (!$reseller) {
            return response()->json(['message' => 'Reseller not found'], 404);
        }

        $validated = $request->validate([
            'name'            => ['sometimes', 'string', 'max:255'],
            'business_name'   => ['sometimes', 'string', 'max:255'],
            'registration_no' => ['sometimes', 'string', 'max:100'],
            'email'           => ['sometimes', 'email', 'max:255', Rule::unique('resellers', 'email')->ignore($reseller->id)],
            'phone'           => ['sometimes', 'string', 'max:30', Rule::unique('resellers', 'phone')->ignore($reseller->id)],
            'password'        => ['nullable', 'string', 'min:8'],
            'city'            => ['sometimes', 'string', 'max:100'],
            'address'         => ['nullable', 'string', 'max:500'],
        ]);

        // The Reseller model's mutator hashes a non-empty password; an absent/null one must not blank it.
        if (empty($validated['password'])) {
            unset($validated['password']);
        }

        $reseller->update($validated);

        return response()->json(['success' => true, 'message' => 'Reseller updated']);
    }

    /**
     * Set a reseller's status.
     * Accepts: active, inactive, suspended.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:active,inactive,suspended'],
            'reason' => ['nullable', 'string', 'max:255'],
        ]);

        $reseller = $this->findOwned($request, $id);

        if (!$reseller) {
            return response()->json(['message' => 'Reseller not found'], 404);
        }

        $isSuspended = $validated['status'] === 'suspended';

        $reseller->update([
            'status'            => $validated['status'],
            // Same semantics as AdminResellerController@toggleSuspend: only a suspension carries a
            // timestamp and a reason; any other status clears them.
            'suspended_at'      => $isSuspended ? now() : null,
            'suspended_reason'  => $isSuspended ? ($validated['reason'] ?? null) : null,
        ]);

        return response()->json([
            'success' => true,
            'message' => "Reseller status updated to {$validated['status']}",
            'data'    => ['status' => $validated['status']],
        ]);
    }

    /**
     * Soft-delete a reseller (restorable). `Reseller` uses SoftDeletes, so this is a real soft delete.
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $reseller = $this->findOwned($request, $id);

        if (!$reseller) {
            return response()->json(['message' => 'Reseller not found'], 404);
        }

        $reseller->delete();

        return response()->json([
            'success' => true,
            'message' => 'Reseller deleted (restorable for 30 days)',
        ]);
    }

    /**
     * Restore a soft-deleted reseller.
     */
    public function restore(Request $request, string $id): JsonResponse
    {
        $reseller = $this->ownedQuery($request->user()->global_identity_id)
            ->onlyTrashed()
            ->where('id', $id)
            ->first();

        if (!$reseller) {
            return response()->json(['message' => 'Reseller not found or not deleted'], 404);
        }

        $reseller->restore();

        return response()->json(['success' => true, 'message' => 'Reseller restored']);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Scoping — the isolation rule. `resellers` has no metadata column, so the creator lives in
    // `created_by_sub_admin_id` (added by 2026_09_27_000001_add_created_by_sub_admin_id_to_resellers).
    // NULL means platform-created, which is why old rows belong to no sub-admin.
    // ─────────────────────────────────────────────────────────────────────────

    private function ownedQuery(?string $subAdminId)
    {
        return Reseller::query()->where('created_by_sub_admin_id', $subAdminId);
    }

    private function findOwned(Request $request, string $id): ?Reseller
    {
        return $this->ownedQuery($request->user()->global_identity_id)
            ->where('id', $id)
            ->first();
    }
}
