<?php

namespace App\Http\Middleware\Cricket;

use App\Models\Cricket\CricketManager;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * CricketManagerAuth — Authenticates Cricket Manager accounts.
 *
 * Looks for Bearer token in Authorization header. Validates against
 * the hashed auth_token stored in cricket_managers table.
 *
 * Completely independent from the main Sanctum auth system.
 * Zero impact on existing auth middleware.
 */
class CricketManagerAuth
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'message' => 'Authentication required. Provide Bearer token.',
            ], 401);
        }

        $hashedToken = hash('sha256', $token);

        $manager = CricketManager::where('auth_token', $hashedToken)
            ->where('status', 'active')
            ->first();

        if (!$manager) {
            return response()->json([
                'message' => 'Invalid or expired token.',
            ], 401);
        }

        // Check token expiration
        if ($manager->token_expires_at && $manager->token_expires_at->isPast()) {
            $manager->revokeAuthToken();
            return response()->json([
                'message' => 'Token expired. Please log in again.',
            ], 401);
        }

        // Extend token expiry by 1 hour on activity
        if ($manager->token_expires_at) {
            $manager->token_expires_at = now()->addHours(12);
            $manager->save();
        }

        // Attach manager to request for downstream use
        $request->merge(['_cricket_manager' => $manager->id]);
        $request->setUserResolver(fn () => $manager);

        return $next($request);
    }

    /**
     * Get the authenticated Cricket Manager from the request.
     */
    public static function manager(Request $request): ?CricketManager
    {
        return $request->userResolver()();
    }
}
