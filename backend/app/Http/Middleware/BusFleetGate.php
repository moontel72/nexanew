<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

/**
 * NEXATRACE — BUS FLEET GATE MIDDLEWARE (v2)
 * ===========================================
 *
 * Ensures the authenticated user has a valid bus fleet context
 * before allowing access to bus-fleet panel routes.
 *
 * - Master admins pass through unconditionally.
 * - Bus company tenants pass through with carrier_company_id = own id.
 * - Owner/driver/conductor users must have active fleet_assignments.
 * - Attaches _carrier_company_id to the request for downstream controllers.
 *
 * Per §10.1 / §10.4 of NEXATRACE_SUPREME_MASTER_SPEC.md
 */
class BusFleetGate
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        // Master admin passes through (sees all)
        if (($user->account_type ?? null) === 'master_admin') {
            return $next($request);
        }

        // The user IS a bus/truck company — carrier_company_id = own id
        if (in_array($user->account_type ?? null, ['bus_company', 'truck_company'], true)) {
            $request->merge(['_carrier_company_id' => $user->id]);
            return $next($request);
        }

        // Independent bus owners (not linked to a carrier) pass through
        // for self-contained operations like layout creation.
        // carrier_company_id is set to the user's own tenant id.
        if (($user->account_type ?? null) === 'global_identity' ||
            ($user->is_independent ?? false)) {
            $request->merge(['_carrier_company_id' => $user->id]);
            return $next($request);
        }

        // Otherwise must hold an owner/driver/conductor/store_keeper assignment in bus fleet
        $assignment = DB::table('fleet_assignments')
            ->where('global_identity_id', $user->global_identity_id)
            ->where('fleet_type', 'bus')
            ->whereIn('role', ['owner', 'driver', 'conductor', 'store_keeper'])
            ->whereIn('status', ['active', 'pending_acceptance'])
            ->first();

        if (!$assignment) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden: No active bus fleet assignment.',
            ], 403);
        }

        $request->merge([
            '_carrier_company_id' => $assignment->carrier_company_id,
            '_fleet_role'         => $assignment->role,
        ]);
        return $next($request);
    }
}
