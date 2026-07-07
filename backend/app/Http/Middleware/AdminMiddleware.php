<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

/**
 * Admin Authorization Middleware
 *
 * Validates that the authenticated user (via Sanctum token on TenantAccount)
 * has an active Master Admin assignment in the Global Identity Spine.
 *
 * Flow:
 *  1. Extract authenticated user from request (TenantAccount via auth:sanctum)
 *  2. Read global_identity_id from TenantAccount
 *  3. Verify an unrevoked row exists in master_admin_assignments
 *  4. Pass or 403
 *
 * This replaces the legacy $user->isAdmin() pattern which relied on
 * model-specific methods that don't exist on TenantAccount.
 */
class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        // Resolve the global_identity_id from the authenticated model.
        // TenantAccount has a dedicated global_identity_id column.
        // GlobalIdentity (unified auth) uses its own `id` as the identity.
        $globalIdentityId = $user->global_identity_id
            ?? $user->id
            ?? null;

        if (!$globalIdentityId) {
            return response()->json(['message' => 'Forbidden — no identity spine link'], 403);
        }

        // Verify an active Master Admin OR Sub-Admin assignment exists
        $isMasterAdmin = DB::table('master_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        $isSubAdmin = DB::table('sub_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        if (!$isMasterAdmin && !$isSubAdmin) {
            return response()->json(['message' => 'Forbidden — not a system administrator'], 403);
        }

        return $next($request);
    }
}
