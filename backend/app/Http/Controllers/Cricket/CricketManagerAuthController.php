<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\CricketManager;
use App\Models\Cricket\ManagerSessionLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * CricketManagerAuthController — Login/Logout for Cricket Managers.
 *
 * Completely isolated auth flow using hashed bearer tokens.
 * No dependency on Sanctum or the main GlobalIdentity system.
 */
class CricketManagerAuthController extends Controller
{
    public function login(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $manager = CricketManager::where('email', $request->email)->first();

        if (!$manager || !$manager->verifyPassword($request->password)) {
            return response()->json(['message' => 'Invalid credentials.'], 401);
        }

        if (!$manager->isActive()) {
            return response()->json(['message' => 'Account is suspended. Contact your account administrator.'], 403);
        }

        // Generate token
        $token = $manager->generateAuthToken();
        $manager->last_login_at = now();
        $manager->last_login_ip = $request->ip();
        $manager->save();

        // Log session
        ManagerSessionLog::create([
            'cricket_manager_id' => $manager->id,
            'action' => 'login',
            'metadata' => ['email' => $manager->email],
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return response()->json([
            'message' => 'Login successful.',
            'token' => $token,
            'expires_at' => $manager->token_expires_at->toIso8601String(),
            'manager' => [
                'id' => $manager->id,
                'name' => $manager->name,
                'email' => $manager->email,
                'permissions' => $manager->permissions,
            ],
        ]);
    }

    public function logout(Request $request): \Illuminate\Http\JsonResponse
    {
        $manager = \App\Http\Middleware\Cricket\CricketManagerAuth::manager($request);

        if ($manager instanceof CricketManager) {
            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'action' => 'logout',
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);

            $manager->revokeAuthToken();
        }

        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function me(Request $request): \Illuminate\Http\JsonResponse
    {
        $manager = \App\Http\Middleware\Cricket\CricketManagerAuth::manager($request);

        if (!$manager instanceof CricketManager) {
            return response()->json(['message' => 'Not authenticated.'], 401);
        }

        return response()->json([
            'manager' => [
                'id' => $manager->id,
                'name' => $manager->name,
                'email' => $manager->email,
                'phone' => $manager->phone,
                'status' => $manager->status,
                'permissions' => $manager->permissions,
                'last_login_at' => $manager->last_login_at,
            ],
        ]);
    }
}
