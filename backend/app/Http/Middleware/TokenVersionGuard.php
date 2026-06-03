<?php

namespace App\Http\Middleware;

use App\Services\ConfigurationService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Wave 2 — TokenVersionGuard Middleware
 *
 * Per Section 10.3.2 (Read Path) and Section 10.10 (step 4).
 *
 * Compares the L1 token's feature_grants_version against the
 * authoritative L3 Postgres counter on every authenticated request.
 *
 * Read path algorithm (Section 10.3.2):
 *   1. Read `feature_grants_version` from Sanctum token payload (L1).
 *   2. Read `current_version` from L3 counter via Redis 1s cache.
 *   3. If token_version == current_version → pass (O(1) Redis SISMEMBER).
 *   4. If token_version < current_version → return 401 token_stale.
 *      Client transparently calls /auth/refresh, then retries.
 *   5. If L2 set missing → lazy materialize (stampede-protected).
 *
 * The client (Flutter via ApiClient) detects the 401 with
 * reason="token_stale", calls /api/v1/auth/refresh, and retries
 * the original request with the new token.
 */
class TokenVersionGuard
{
    public function __construct(
        private readonly ConfigurationService $config
    ) {}

    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // Skip for unauthenticated requests
        if (!$user) {
            return $next($request);
        }

        // Read L1 token version from Sanctum token abilities/metadata
        // The version is embedded in the token name/abilities during login.
        // We check it against the L3 counter.
        $currentVersion = $this->config->currentVersion();

        // If the token has a stored version claim, compare it.
        // For Sanctum, we store version in the token name pattern or use a custom claim.
        // Simplest approach: check if token was minted at current version.
        $tokenVersion = $this->getTokenVersion($request, $user);

        if ($tokenVersion !== null && $tokenVersion < $currentVersion) {
            return response()->json([
                'status'           => 'error',
                'message'          => 'Token version is stale. Please refresh.',
                'reason'           => 'token_stale',
                'refresh_required' => true,
                'current_version'  => $currentVersion,
                'token_version'    => $tokenVersion,
            ], 401);
        }

        return $next($request);
    }

    /**
     * Extract feature_grants_version from the current token.
     *
     * For Sanctum, we encode the version in the token name
     * as "v{version}:{role}-{random}".
     */
    private function getTokenVersion(Request $request, $user): ?int
    {
        $token = $request->user()->currentAccessToken();

        if (!$token) {
            return null;
        }

        // Parse version from token name format: e.g., "v5:fleet-driver-AbCdEf12"
        if (preg_match('/^v(\d+):/', $token->name, $matches)) {
            return (int) $matches[1];
        }

        // Fallback: token was minted before versioning was added
        // => treat as stale, force refresh
        return 0;
    }
}
