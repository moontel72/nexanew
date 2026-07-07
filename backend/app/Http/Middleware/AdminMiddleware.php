<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * Admin Authorization Middleware
 *
 * Validates that the authenticated user has administrative privileges.
 *
 * Three-tier verification (any ONE passing grants access):
 *  1. master_admin_assignments — explicit Master Admin role (Section 10.2.4)
 *  2. TenantAccount->isAdmin() — account_type === 'master_admin' (seeded)
 *  3. sub_admin_assignments — delegated Sub-Admin role (Section 10.2.2)
 *
 * The Sanctum token is issued on TenantAccount (via GlobalAuthController).
 * $request->user() returns TenantAccount, which has global_identity_id.
 */
class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        // ── Tier 1: TenantAccount.isAdmin() (account_type === 'master_admin') ──
        if (method_exists($user, 'isAdmin') && $user->isAdmin()) {
            return $next($request);
        }

        // ── Tier 2: GlobalIdentity.identity_type === 'admin' ──
        if (method_exists($user, 'getAttribute')) {
            $identityType = $user->getAttribute('identity_type');
            if ($identityType === 'admin' && $user->getAttribute('status') === 'active') {
                return $next($request);
            }
        }

        // ── Tier 3: Resolve global_identity_id and check assignment tables ──
        $globalIdentityId = $user->global_identity_id
            ?? $user->id
            ?? null;

        if (!$globalIdentityId) {
            Log::warning('AdminMiddleware: no global_identity_id resolvable', [
                'user_class' => get_class($user),
                'user_id'    => $user->id ?? 'unknown',
            ]);
            return response()->json(['message' => 'Forbidden — no identity spine link'], 403);
        }

        // Check master_admin_assignments (Section 10.2.4)
        $isMasterAdmin = DB::table('master_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        // Check sub_admin_assignments (Section 10.2.2)
        $isSubAdmin = DB::table('sub_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        if (!$isMasterAdmin && !$isSubAdmin) {
            Log::warning('AdminMiddleware: identity not authorized', [
                'global_identity_id' => $globalIdentityId,
                'user_class'         => get_class($user),
            ]);
            return response()->json(['message' => 'Forbidden — not a system administrator'], 403);
        }

        return $next($request);
    }
}
