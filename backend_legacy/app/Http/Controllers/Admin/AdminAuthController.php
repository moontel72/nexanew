<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AdminAuthController extends Controller
{
    /**
     * Register a new admin user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:admin_users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|string|in:super_admin,admin,moderator',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $admin = AdminUser::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => $request->role,
                'status' => 'active',
                'email_verified_at' => now(),
                'last_login_at' => null,
                'login_attempts' => 0,
                'force_password_change' => false,
            ]);

            // Generate API token
            $token = $admin->createToken('admin-api-token', ['admin'])->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Admin user created successfully',
                'data' => [
                    'admin' => $admin->only(['id', 'name', 'email', 'role', 'status']),
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_in' => config('sanctum.expiration') ?: null,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create admin user',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login admin user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
            'remember_me' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $admin = AdminUser::where('email', $request->email)->first();

            if (!$admin || !Hash::check($request->password, $admin->password)) {
                // Increment login attempts
                if ($admin) {
                    $admin->increment('login_attempts');

                    if ($admin->login_attempts >= 5) {
                        $admin->update(['status' => 'locked']);
                        return response()->json([
                            'success' => false,
                            'message' => 'Account locked due to too many failed attempts'
                        ], 423);
                    }
                }

                return response()->json([
                    'success' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }

            // Check if account is active
            if ($admin->status !== 'active') {
                return response()->json([
                    'success' => false,
                    'message' => 'Account is ' . $admin->status
                ], 403);
            }

            // Reset login attempts on successful login
            $admin->update([
                'login_attempts' => 0,
                'last_login_at' => now(),
                'last_login_ip' => $request->ip(),
                'last_login_user_agent' => $request->userAgent(),
            ]);

            // Revoke existing tokens
            $admin->tokens()->delete();

            // Create new token with admin scope
            $token = $admin->createToken('admin-api-token', ['admin'])->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'admin' => $admin->only(['id', 'name', 'email', 'role', 'status', 'force_password_change']),
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_in' => config('sanctum.expiration') ?: null,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Login failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Logout admin user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logout failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get current admin user profile
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function profile(Request $request)
    {
        try {
            $admin = $request->user()->load('permissions');

            return response()->json([
                'success' => true,
                'data' => [
                    'admin' => $admin->only(['id', 'name', 'email', 'role', 'status', 'created_at', 'last_login_at']),
                    'permissions' => $admin->permissions->pluck('name')
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Refresh authentication token
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function refresh(Request $request)
    {
        try {
            $admin = $request->user();

            // Revoke current token
            $request->user()->currentAccessToken()->delete();

            // Create new token
            $token = $admin->createToken('admin-api-token', ['admin'])->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Token refreshed successfully',
                'data' => [
                    'token' => $token,
                    'token_type' => 'Bearer',
                    'expires_in' => config('sanctum.expiration') ?: null,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to refresh token',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Change password
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $admin = $request->user();

            // Verify current password
            if (!Hash::check($request->current_password, $admin->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Current password is incorrect'
                ], 401);
            }

            // Update password
            $admin->update([
                'password' => Hash::make($request->new_password),
                'force_password_change' => false,
                'password_changed_at' => now(),
            ]);

            // Revoke all tokens except current one
            $admin->tokens()->where('id', '!=', $admin->currentAccessToken()->id)->delete();

            return response()->json([
                'success' => true,
                'message' => 'Password changed successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to change password',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Request password reset
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email|exists:admin_users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $admin = AdminUser::where('email', $request->email)->first();

            // Generate reset token
            $token = Str::random(60);
            $admin->update([
                'reset_token' => $token,
                'reset_token_expires_at' => now()->addHours(2),
            ]);

            // TODO: Send email with reset link
            // Mail::to($admin->email)->send(new AdminPasswordReset($token));

            return response()->json([
                'success' => true,
                'message' => 'Password reset link sent to your email'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to process password reset request',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Reset password with token
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'email' => 'required|string|email|exists:admin_users,email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $admin = AdminUser::where('email', $request->email)
                ->where('reset_token', $request->token)
                ->where('reset_token_expires_at', '>', now())
                ->first();

            if (!$admin) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid or expired reset token'
                ], 400);
            }

            // Update password and clear reset token
            $admin->update([
                'password' => Hash::make($request->password),
                'reset_token' => null,
                'reset_token_expires_at' => null,
                'login_attempts' => 0,
                'status' => 'active',
                'password_changed_at' => now(),
            ]);

            // Revoke all existing tokens
            $admin->tokens()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Password reset successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to reset password',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Check if admin needs to change password
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function checkPasswordExpiry(Request $request)
    {
        try {
            $admin = $request->user();
            $passwordChangedAt = $admin->password_changed_at ?: $admin->created_at;
            $daysSinceChange = $passwordChangedAt->diffInDays(now());

            $passwordExpiryDays = config('auth.password_expire_days', 90);
            $warningDays = config('auth.password_warning_days', 7);

            $expiresIn = $passwordExpiryDays - $daysSinceChange;
            $requiresChange = $admin->force_password_change || $expiresIn <= 0;
            $showWarning = $expiresIn <= $warningDays && $expiresIn > 0;

            return response()->json([
                'success' => true,
                'data' => [
                    'requires_change' => $requiresChange,
                    'show_warning' => $showWarning,
                    'days_remaining' => max(0, $expiresIn),
                    'force_change' => $admin->force_password_change,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to check password expiry',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
