<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\FactoryUser;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class FactoryAuthController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'company_id' => ['nullable', 'uuid'],
        ]);

        $query = FactoryUser::query()->where('email', $data['email']);
        if (!empty($data['company_id'])) {
            $query->where('company_id', $data['company_id']);
        }

        $user = $query->first();

        if (!$user || !$user->verifyPassword($data['password'])) {
            throw ValidationException::withMessages(['email' => 'Invalid credentials.'])->status(401);
        }

        if (!$user->is_active) {
            return response()->json(['message' => 'Account is not active.'], 403);
        }

        $user->forceFill(['last_login_at' => now()])->save();

        $token = $user->createToken('factory')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => (string) $user->id,
                    'company_id' => (string) $user->company_id,
                    'email' => (string) $user->email,
                    'full_name' => (string) $user->full_name,
                    'position' => (string) $user->position,
                    'permissions' => $user->permissions ?? [],
                ],
                'token' => $token,
            ],
        ]);
    }


    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();
        return response()->json(['success' => true]);
    }

    public function profile(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => (string) $user->id,
                'company_id' => (string) $user->company_id,
                'email' => (string) $user->email,
                'full_name' => (string) $user->full_name,
                'position' => (string) $user->position,
                'permissions' => $user->permissions ?? [],
            ],
        ]);
    }
}
