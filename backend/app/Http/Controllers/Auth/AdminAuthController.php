<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Resources\AdminUserResource;
use App\Models\AdminUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AdminAuthController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = AdminUser::query()->where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['email' => 'Invalid credentials.'])->status(401);
        }

        if (($user->status ?? 'active') !== 'active') {
            return response()->json(['message' => 'Account is not active.'], 403);
        }

        $user->forceFill([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
            'last_login_user_agent' => substr((string) $request->userAgent(), 0, 1000),
            'login_attempts' => 0,
        ])->save();

        $token = $user->createToken('admin')->plainTextToken;
        $tokenExpiry = now()->addDays(30);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => new AdminUserResource($user),
                'token' => $token,
                'token_expiry' => $tokenExpiry->toISOString(),
                'needs_password_change' => (bool) ($user->force_password_change ?? false),
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json(['success' => true]);
    }

    public function refresh(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $request->user()->currentAccessToken()?->delete();

        $token = $user->createToken('admin')->plainTextToken;
        $tokenExpiry = now()->addDays(30);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => new AdminUserResource($user),
                'token' => $token,
                'token_expiry' => $tokenExpiry->toISOString(),
                'needs_password_change' => (bool) ($user->force_password_change ?? false),
            ],
        ]);
    }

    public function changePassword(Request $request)
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:8'],
            'new_password_confirmation' => ['required', 'same:new_password'],
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        if (!Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages(['current_password' => 'Current password is incorrect.'])->status(401);
        }

        $user->forceFill([
            'password' => $data['new_password'],
            'force_password_change' => false,
            'password_changed_at' => now(),
        ])->save();

        return response()->json(['success' => true]);
    }

    public function validateToken(Request $request)
    {
        return response()->json(['success' => true]);
    }

    public function profile(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        return response()->json(['success' => true, 'data' => new AdminUserResource($user)]);
    }
}

