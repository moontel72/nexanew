<?php

namespace App\Http\Middleware;

use App\Models\GlobalIdentity;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Wave 2 — IdentityStatusGate Middleware
 *
 * Per Section 10.10 (step 5).
 *
 * Rejects requests if the authenticated identity's status is not 'active'.
 * Uses dedicated global_identity_id column (Defect #4 fix).
 */
class IdentityStatusGate
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return $next($request);
        }

        // Defect #4 fix: use dedicated global_identity_id column
        $identityId = $user->global_identity_id ?? null;

        if (!$identityId) {
            return $next($request);
        }

        $identity = GlobalIdentity::find($identityId);

        if (!$identity) {
            return response()->json(['status' => 'error', 'message' => 'Identity not found.'], 401);
        }

        if (!$identity->isActive()) {
            $request->user()->currentAccessToken()?->delete();

            $message = match ($identity->status) {
                'suspended' => 'Your account has been suspended. Contact your administrator.',
                'frozen'    => 'Your account has been frozen pending review.',
                'deleted'   => 'This account has been deactivated.',
                default     => 'Account is not active.',
            };

            return response()->json([
                'status'          => 'error',
                'message'         => $message,
                'reason'          => 'identity_inactive',
                'identity_status' => $identity->status,
            ], 403);
        }

        return $next($request);
    }
}
