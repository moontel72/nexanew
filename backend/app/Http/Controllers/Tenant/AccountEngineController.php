<?php

namespace App\Http\Controllers\Tenant;

use App\Http\Controllers\Controller;
use App\Models\TenantAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AccountEngineController extends Controller
{
    /**
     * DEPRECATED — Greenfield purge per spec §10.1.
     * Use FleetManagementController::storeOwner instead.
     */
    public function registerSubOwner(Request $request): JsonResponse
    {
        return response()->json([
            'status'  => 'error',
            'message' => 'This endpoint has been deprecated. Use /api/v1/bus-fleet/owners to register fleet staff via the identity spine.',
        ], 410);
    }

    /** GET /api/v1/tenants/fleet-data */
    public function getLinkedFleetData(Request $request): JsonResponse
    {
        $tenantId = $request->input('tenant_id') ?? $request->user()->tenant_account_id;
        $tenant = TenantAccount::with('children')->find($tenantId);
        if (!$tenant) return response()->json(['status' => 'error'], 404);

        $allIds = $tenant->getAllTenantIds();
        $buses = DB::table('transport_bus_layouts')->whereIn('tenant_account_id', $allIds)->select('bus_id', 'total_rows', 'tenant_account_id')->get();
        $shifts = DB::table('bus_shift_allocations')->whereIn('tenant_account_id', $allIds)->get();

        return response()->json(['status' => 'success', 'data' => [
            'tenant_id' => $tenantId, 'hierarchy_ids' => $allIds,
            'buses' => $buses, 'shift_allocations' => $shifts,
        ]]);
    }

    // ================================================================
    // 6 PUBLIC STAFF LOGIN ENDPOINTS (no auth required)
    //
    // Each endpoint hardcodes staff_type + driver_type.
    // The Flutter app never sends these — the route IS the filter.
    // ================================================================

    // --- BUS COMPANY ECOSYSTEM (DEPRECATED — use /api/v1/auth/login) ---
    public function busOwnerLogin(Request $request): JsonResponse {
        return $this->_deprecatedLoginResponse('bus_owner');
    }
    public function busDriverLogin(Request $request): JsonResponse {
        return $this->_deprecatedLoginResponse('bus_driver');
    }
    public function busConductorLogin(Request $request): JsonResponse {
        return $this->_deprecatedLoginResponse('bus_conductor');
    }

    // --- GOODS COMPANY ECOSYSTEM (DEPRECATED — use /api/v1/auth/login) ---
    public function truckOwnerLogin(Request $request): JsonResponse {
        return $this->_deprecatedLoginResponse('truck_owner');
    }
    public function truckDriverLogin(Request $request): JsonResponse {
        return $this->_deprecatedLoginResponse('truck_driver');
    }
    public function truckConductorLogin(Request $request): JsonResponse {
        return $this->_deprecatedLoginResponse('truck_conductor');
    }

    /**
     * Return deprecation response pointing to unified auth endpoint.
     * Greenfield cutover: no backward compatibility for old fleet login gates.
     */
    private function _deprecatedLoginResponse(string $accountType): JsonResponse
    {
        return response()->json([
            'status'  => 'error',
            'message' => 'This login endpoint has been deprecated. Please use /api/v1/auth/login instead.',
            'deprecated_endpoint' => true,
            'new_endpoint' => '/api/v1/auth/login',
            'migration_guide' => [
                'Send identifier (phone/email/CNIC) and password.',
                'Optionally include fleet_role and fleet_type for fleet-specific login.',
                'Example: { "identifier": "033009631475", "password": "...", "fleet_role": "driver", "fleet_type": "truck" }',
            ],
        ], 410);
    }

    /**
     * Universal staff login engine.
     *
     * @param string $staffType   'owner' | 'driver' | 'conductor'
     * @param string $driverType  'bus' | 'truck'
     * @param string $accountType tenant_accounts account_type value
     */
    private function _staffLogin(
        Request $request,
        string $staffType,
        string $driverType,
        string $accountType
    ): JsonResponse {
        $validated = $request->validate([
            'email'    => ['nullable', 'email'],
            'phone'    => ['nullable', 'string', 'max:50'],
            'password' => ['required', 'string'],
        ]);

        $email = $validated['email'] ?? null;
        $phone = $validated['phone'] ?? null;

        if (!$email && !$phone) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email or phone number is required.',
            ], 422);
        }

        // 1. Try tenant_accounts table
        $tenant = null;
        if ($email) {
            $tenant = TenantAccount::where('email', $email)
                ->where('account_type', $accountType)
                ->first();
        }
        if (!$tenant && $phone) {
            $tenant = TenantAccount::where('phone_number', $phone)
                ->where('account_type', $accountType)
                ->first();
        }

        // 2. No tenant account found — reject
        if (!$tenant) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Invalid credentials.',
            ], 401);
        }

        // 3. Tenant account found — verify password against global_identities
        if (!Hash::check($validated['password'], $tenant->password)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Invalid credentials.',
            ], 401);
        }
        if ($tenant->status !== 'active') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Account suspended.',
            ], 403);
        }

        $token = $tenant->createToken('tenant-token')->plainTextToken;
        return response()->json([
            'status' => 'success',
            'token'  => $token,
            'data'   => [
                'id'                => $tenant->id,
                'account_name'      => $tenant->account_name,
                'account_type'      => $tenant->account_type,
                'is_independent'    => $tenant->is_independent,
                'parent_account_id' => $tenant->parent_account_id,
                'children_count'    => $tenant->children()->count(),
            ],
        ]);
    }

    // ================================================================
    // LEGACY — kept for super-admin panel backward compat
    // ================================================================

    /** POST /api/v1/super-admin/tenants/login */
    public function tenantLogin(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'], 'password' => ['required', 'string'],
        ]);
        $tenant = TenantAccount::where('email', $validated['email'])->first();
        if (!$tenant || !Hash::check($validated['password'], $tenant->password)) {
            return response()->json(['status' => 'error', 'message' => 'Invalid credentials.'], 401);
        }
        if ($tenant->status !== 'active') {
            return response()->json(['status' => 'error', 'message' => 'Account suspended.'], 403);
        }
        $token = $tenant->createToken('tenant-token')->plainTextToken;
        return response()->json([
            'status' => 'success', 'token' => $token,
            'data' => ['id' => $tenant->id, 'account_name' => $tenant->account_name,
                'account_type' => $tenant->account_type, 'is_independent' => $tenant->is_independent,
                'parent_account_id' => $tenant->parent_account_id, 'children_count' => $tenant->children()->count()],
        ]);
    }

    /** GET /api/v1/tenants/directory */
    public function tenantDirectory(Request $request): JsonResponse
    {
        $parentId = $request->input('parent_id');
        $query = TenantAccount::with('children:id,account_name,parent_account_id');
        if ($parentId) $query->where('parent_account_id', $parentId);
        else $query->root();

        $tenants = $query->select('id', 'parent_account_id', 'account_name', 'email', 'phone_number', 'is_independent', 'account_type', 'status', 'created_at')
            ->get()->map(fn ($t) => [
                'id' => $t->id, 'parent_id' => $t->parent_account_id, 'account_name' => $t->account_name,
                'email' => $t->email, 'phone' => $t->phone_number, 'is_independent' => $t->is_independent,
                'type' => $t->account_type, 'status' => $t->status,
                'sub_owners_count' => $t->children->count(), 'created_at' => $t->created_at,
            ]);
        return response()->json(['status' => 'success', 'data' => $tenants]);
    }
}
