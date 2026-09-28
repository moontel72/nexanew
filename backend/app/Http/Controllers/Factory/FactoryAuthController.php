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

        // The factory's own name (as written on the registration form). The client needs it to show
        // WHICH factory this account belongs to - it was never sent before, so the panel header could
        // only ever display the platform brand.
        $companyName = \App\Models\Company::query()->where('id', $user->company_id)->value('name');

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
                    'company_name' => $companyName,
                ],
                'token' => $token,
            ],
        ]);
    }


    public function refresh(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Revoke current token and issue a new one
        $request->user()->currentAccessToken()->delete();
        $token = $user->createToken('factory')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => (string) $user->id,
                    'company_id' => (string) $user->company_id,
                    'email' => (string) $user->email,
                    'full_name' => (string) $user->full_name,
                    'position' => (string) $user->position,
                    'permissions' => $user->permissions ?? [],
                ],
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
                // Same reason as login(): the panel header shows the factory's own name.
                'company_name' => \App\Models\Company::query()->where('id', $user->company_id)->value('name'),
            ],
        ]);
    }
}
