<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Reseller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class AdminResellerController extends Controller
{
    // GET /api/v1/admin/resellers
    public function index(Request $request): JsonResponse
    {
        $query = Reseller::query();

        // Search by name, email, or city
        $search = (string) $request->query('search', '');
        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('business_name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%")
                  ->orWhere('city', 'ilike', "%{$search}%");
            });
        }

        // Filter by status
        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        // Filter by city
        if ($city = $request->query('city')) {
            $query->where('city', $city);
        }

        // Sort
        $sortBy = (string) $request->query('sort_by', 'created_at');
        $allowed = ['created_at', 'updated_at', 'name', 'status', 'city'];
        if (!in_array($sortBy, $allowed, true)) {
            $sortBy = 'created_at';
        }
        $sortOrder = strtolower((string) $request->query('sort_order', 'desc')) === 'asc' ? 'asc' : 'desc';
        $query->orderBy($sortBy, $sortOrder);

        // Paginate
        $perPage = max(1, min(100, (int) $request->query('per_page', 20)));
        $paginator = $query->paginate($perPage);

        return response()->json([
            'data' => $paginator->items(),
            'total' => $paginator->total(),
            'page' => $paginator->currentPage(),
            'per_page' => $paginator->perPage(),
            'total_pages' => $paginator->lastPage(),
        ]);
    }

    // POST /api/v1/admin/resellers
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'business_name' => 'required|string|max:255',
            'registration_no' => 'required|string|max:100',
            'email' => 'required|email|unique:resellers,email',
            'phone' => 'required|string|max:30|unique:resellers,phone',
            'password' => 'required|string|min:8',
            'city' => 'required|string|max:100',
            'address' => 'nullable|string|max:500',
            'plan_id' => 'nullable|string|max:36',
        ]);

        $validated['password'] = bcrypt($validated['password']);
        $validated['purchase_approved'] = true; // Admin-vouched, no proof needed
        $reseller = Reseller::create($validated);

        // Remove password from response
        unset($reseller->password);
        return response()->json(['data' => $reseller], 201);
    }

    // GET /api/v1/admin/resellers/{id}
    public function show(string $id): JsonResponse
    {
        $reseller = Reseller::findOrFail($id);
        return response()->json(['data' => $reseller]);
    }

    // PUT /api/v1/admin/resellers/{id}
    public function update(Request $request, string $id): JsonResponse
    {
        $reseller = Reseller::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'business_name' => 'sometimes|string|max:255',
            'registration_no' => 'sometimes|string|max:100',
            'email' => ['sometimes', 'email', Rule::unique('resellers', 'email')->ignore($id)],
            'phone' => ['sometimes', 'string', 'max:30', Rule::unique('resellers', 'phone')->ignore($id)],
            'password' => 'nullable|string|min:8',
            'city' => 'sometimes|string|max:100',
            'address' => 'nullable|string|max:500',
            'plan_id' => 'nullable|string|max:36',
            'purchase_approved' => 'sometimes|boolean',
        ]);

        if (!empty($validated['password'])) {
            $validated['password'] = bcrypt($validated['password']);
        } else {
            unset($validated['password']);
        }
        $reseller->update($validated);

        unset($reseller->password);
        return response()->json(['data' => $reseller]);
    }

    // DELETE /api/v1/admin/resellers/{id}  (soft delete)
    public function destroy(string $id): JsonResponse
    {
        $reseller = Reseller::findOrFail($id);
        $reseller->delete();

        return response()->json(['message' => 'Reseller deleted']);
    }

    // PATCH /api/v1/admin/resellers/{id}/status
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:active,inactive',
            'reason' => 'nullable|string|max:255',
        ]);

        $reseller = Reseller::findOrFail($id);
        $reseller->update(['status' => $validated['status']]);

        return response()->json(['data' => $reseller]);
    }

    // PATCH /api/v1/admin/resellers/{id}/suspend
    public function toggleSuspend(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'suspend' => 'required|boolean',
            'reason' => 'nullable|string|max:255',
        ]);

        $reseller = Reseller::findOrFail($id);
        $reseller->update([
            'status' => $validated['suspend'] ? 'suspended' : 'active',
            'suspended_at' => $validated['suspend'] ? now() : null,
            'suspended_reason' => $validated['suspend'] ? ($validated['reason'] ?? null) : null,
        ]);

        return response()->json(['data' => $reseller]);
    }

    /**
     * Approve a reseller's purchase/business proof.
     * PATCH /api/v1/admin/resellers/{id}/approve-purchase
     */
    public function approvePurchase(string $id): JsonResponse
    {
        $reseller = Reseller::findOrFail($id);

        if (!$reseller->business_proof_url) {
            return response()->json([
                'success' => false,
                'message' => 'No business proof document has been uploaded by this reseller yet.',
            ], 422);
        }

        $reseller->update([
            'purchase_approved' => true,
        ]);

        \Illuminate\Support\Facades\Log::info('AdminResellerController: Purchase approved for reseller.', [
            'reseller_id' => $reseller->id,
            'admin_id' => request()->user()?->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Reseller purchase has been approved.',
            'data' => $reseller->fresh(),
        ]);
    }

    /**
     * Reject/reset a reseller's purchase approval.
     * PATCH /api/v1/admin/resellers/{id}/reject-purchase
     */
    public function rejectPurchase(string $id): JsonResponse
    {
        $reseller = Reseller::findOrFail($id);

        $reseller->update([
            'purchase_approved' => false,
        ]);

        \Illuminate\Support\Facades\Log::info('AdminResellerController: Purchase rejected for reseller.', [
            'reseller_id' => $reseller->id,
            'admin_id' => request()->user()?->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Reseller purchase approval has been revoked.',
            'data' => $reseller->fresh(),
        ]);
    }

    /**
     * View a reseller's business proof document.
     * GET /api/v1/admin/resellers/{id}/proof
     */
    public function viewProof(string $id): JsonResponse
    {
        $reseller = Reseller::findOrFail($id);

        if (!$reseller->business_proof_url) {
            return response()->json([
                'success' => false,
                'message' => 'No proof document has been uploaded by this reseller.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'business_proof_url' => $reseller->business_proof_url,
                'business_proof_title' => $reseller->business_proof_title,
                'business_proof_uploaded_at' => $reseller->business_proof_uploaded_at?->toISOString(),
                'purchase_approved' => (bool) $reseller->purchase_approved,
            ],
        ]);
    }
}
