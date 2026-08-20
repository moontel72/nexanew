<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\CricketManager;
use App\Models\Cricket\ManagerSessionLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * CricketManagerController — the admin panel provisions and manages
 * Cricket Operations Manager accounts.
 *
 * Accessible only from the admin panel (account provisioning scope).
 */
class CricketManagerController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $managers = CricketManager::withCount('matchAssignments')
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 20);

        return response()->json($managers);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:200',
            'email' => 'required|email|unique:cricket_managers,email',
            'phone' => 'nullable|string|max:50',
            'password' => 'required|string|min:8',
            'permissions' => 'nullable|array',
            'permissions.can_manage_scores' => 'boolean',
            'permissions.can_manage_streams' => 'boolean',
            'permissions.can_manage_sponsors' => 'boolean',
            'permissions.can_access_studio' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $manager = CricketManager::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => $request->password,
            'permissions' => $this->whitelistedPermissions($request->input('permissions')),
            'provisioned_by_global_identity_id' => $request->user()?->global_identity_id,
            'status' => 'active',
        ]);

        return response()->json([
            'message' => 'Cricket Manager account created.',
            'manager' => $manager->makeHidden(['password', 'auth_token']),
        ], 201);
    }

    public function show(string $id): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManager::with(['matchAssignments.match', 'sessionLogs' => function ($q) {
            $q->latest()->limit(50);
        }])->findOrFail($id);

        return response()->json($manager->makeHidden(['password', 'auth_token']));
    }

    public function update(Request $request, string $id): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManager::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:200',
            'email' => 'sometimes|email|unique:cricket_managers,email,' . $id,
            'phone' => 'nullable|string|max:50',
            'password' => 'sometimes|string|min:8',
            'status' => 'sometimes|in:active,suspended,inactive',
            'permissions' => 'nullable|array',
            'permissions.can_access_studio' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        // Dotted validation rules can surface as flat keys in validated();
        // drop them so the model only ever receives the nested array.
        unset($data['permissions.can_access_studio']);

        // `permissions` replaces the whole set when provided — whitelist its
        // keys (incl. can_access_studio) so unknown keys never persist.
        if (array_key_exists('permissions', $data) && is_array($data['permissions'])) {
            $data['permissions'] = $this->whitelistedPermissions($data['permissions']);
        }

        $manager->update($data);

        return response()->json([
            'message' => 'Cricket Manager updated.',
            'manager' => $manager->makeHidden(['password', 'auth_token']),
        ]);
    }

    public function suspend(string $id): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManager::findOrFail($id);
        $manager->status = 'suspended';
        $manager->revokeAuthToken();
        $manager->save();

        return response()->json(['message' => 'Cricket Manager suspended. All sessions revoked.']);
    }

    public function activate(string $id): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManager::findOrFail($id);
        $manager->status = 'active';
        $manager->save();

        return response()->json(['message' => 'Cricket Manager activated.']);
    }

    public function destroy(string $id): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManager::findOrFail($id);
        $manager->revokeAuthToken();
        $manager->delete();

        return response()->json(['message' => 'Cricket Manager deleted.']);
    }

    /**
     * Whitelist the permission keys persisted on a manager account.
     * Unknown keys are dropped; `can_access_studio` defaults to false.
     */
    private function whitelistedPermissions(?array $permissions): array
    {
        $whitelist = [
            'can_manage_scores',
            'can_manage_streams',
            'can_manage_sponsors',
            'can_access_studio',
        ];

        $permissions = $permissions ?? [
            'can_manage_scores' => true,
            'can_manage_streams' => false,
            'can_manage_sponsors' => false,
        ];

        $permissions = array_intersect_key($permissions, array_flip($whitelist));

        if (!array_key_exists('can_access_studio', $permissions)) {
            $permissions['can_access_studio'] = false;
        }

        return $permissions;
    }
}
