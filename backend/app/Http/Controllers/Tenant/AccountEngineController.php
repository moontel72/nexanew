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
    /** POST /api/v1/tenants/register-sub-owner */
    public function registerSubOwner(Request $request): JsonResponse
    {
        $user = $request->user();
        $parentId = $request->input('parent_account_id') ?? $user->tenant_account_id;

        $validated = $request->validate([
            'account_name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:tenant_accounts,email'],
            'password' => ['required', 'string', 'min:8'],
            'phone_number' => ['nullable', 'string', 'max:50'],
        ]);

        $tenant = TenantAccount::create([
            'account_name' => $validated['account_name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone_number' => $validated['phone_number'] ?? null,
            'parent_account_id' => $parentId,
            'is_independent' => false,
            'account_type' => 'bus_owner',
            'status' => 'active',
        ]);

        return response()->json([
            'status' => 'success', 'message' => 'Sub-owner registered.',
            'data' => ['id' => $tenant->id, 'account_name' => $tenant->account_name],
        ], 201);
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

    /** POST /api/v1/tenants/login */
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
