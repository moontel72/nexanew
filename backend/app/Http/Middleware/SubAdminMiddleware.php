<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * Sub-Admin Authorization Middleware
 *
 * Validates that the authenticated user has an active Sub-Admin
 * assignment in one of the four verticals (Section 10.2).
 *
 * Three-tier verification (any ONE passing grants access):
 *  1. TenantAccount->isAdmin() — Master Admins inherit all Sub-Admin access
 *  2. GlobalIdentity.identity_type === 'sub_admin' — legacy fallback
 *  3. sub_admin_assignments + master_admin_assignments tables
 */
class SubAdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        // ── Tier 1: TenantAccount.isAdmin() (Master Admins bypass all) ──
        if (method_exists($user, 'isAdmin') && $user->isAdmin()) {
            return $next($request);
        }

        // ── Tier 2: GlobalIdentity.identity_type === 'sub_admin' ──
        if (method_exists($user, 'getAttribute')) {
            $identityType = $user->getAttribute('identity_type');
            if (in_array($identityType, ['sub_admin', 'admin'], true)
                && $user->getAttribute('status') === 'active') {
                return $next($request);
            }
        }

        // ── Tier 3: Resolve global_identity_id and check assignment tables ──
        $globalIdentityId = $user->global_identity_id
            ?? $user->id
            ?? null;

        if (!$globalIdentityId) {
            Log::warning('SubAdminMiddleware: no global_identity_id resolvable', [
                'user_class' => get_class($user),
                'user_id'    => $user->id ?? 'unknown',
            ]);
            return response()->json(['message' => 'Forbidden — no identity spine link'], 403);
        }

        // Check sub_admin_assignments (Section 10.2.2)
        $isSubAdmin = DB::table('sub_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        // Also allow Master Admins via master_admin_assignments
        $isMasterAdmin = DB::table('master_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        if (!$isSubAdmin && !$isMasterAdmin) {
            Log::warning('SubAdminMiddleware: identity not authorized', [
                'global_identity_id' => $globalIdentityId,
                'user_class'         => get_class($user),
            ]);
            return response()->json(['message' => 'Forbidden — not a system administrator'], 403);
        }

        return $next($request);
    }
}
