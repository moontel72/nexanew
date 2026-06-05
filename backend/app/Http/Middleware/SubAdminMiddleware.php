<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

/**
 * Sub-Admin Authorization Middleware
 *
 * Validates that the authenticated user (via Sanctum token on TenantAccount)
 * has an active Sub-Admin assignment in one of the four verticals.
 */
class SubAdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $globalIdentityId = $user->global_identity_id ?? null;

        if (!$globalIdentityId) {
            return response()->json(['message' => 'Forbidden — no identity spine link'], 403);
        }

        // Check for active sub-admin assignment
        $isSubAdmin = DB::table('sub_admin_assignments')
            ->where('global_identity_id', $globalIdentityId)
            ->whereNull('revoked_at')
            ->exists();

        if (!$isSubAdmin) {
            return response()->json(['message' => 'Forbidden — not a system administrator'], 403);
        }

        return $next($request);
    }
}
