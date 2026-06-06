<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

/**
 * NEXATRACE — BUS FLEET GATE MIDDLEWARE
 * ======================================
 *
 * Ensures the authenticated user has a valid bus fleet assignment
 * before allowing access to bus-fleet panel routes.
 *
 * - Master admins pass through unconditionally.
 * - Other users must have an active/pending fleet_assignments row
 *   with role='owner' and fleet_type='bus'.
 * - Attaches _carrier_company_id to the request for downstream controllers.
 */
class BusFleetGate
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        // Allow master admins through
        if ($user->account_type === 'master_admin') {
            return $next($request);
        }

        // Check if user has a bus fleet owner assignment
        $assignment = DB::table('fleet_assignments')
            ->where('global_identity_id', $user->global_identity_id)
            ->where('role', 'owner')
            ->where('fleet_type', 'bus')
            ->whereIn('status', ['active', 'pending_acceptance'])
            ->first();

        if (!$assignment) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden: No active bus fleet assignment.',
            ], 403);
        }

        // Attach carrier_company_id for downstream use
        $request->merge(['_carrier_company_id' => $assignment->carrier_company_id]);

        return $next($request);
    }
}
