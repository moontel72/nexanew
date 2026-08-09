<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\CricketManager;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * CricketManagerController — Sub-Admin provisions & manages
 * Cricket Manager accounts dynamically.
 *
 * ONLY accessible to Super Admin / Sub-Admin.
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
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $manager = CricketManager::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => $request->password,
            'permissions' => $request->permissions ?? [
                'can_manage_scores' => true,
                'can_manage_streams' => false,
                'can_manage_sponsors' => false,
            ],
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
            'phone' => 'nullable|string|max:50',
            'password' => 'sometimes|string|min:8',
            'status' => 'sometimes|in:active,suspended,inactive',
            'permissions' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $manager->update($validator->validated());

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
}
