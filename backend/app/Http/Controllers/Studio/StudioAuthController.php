<?php

namespace App\Http\Controllers\Studio;

use App\Http\Controllers\Controller;
use App\Models\Cricket\CricketManager;
use App\Models\Cricket\ManagerSessionLog;
use App\Services\MediaEngineTokenService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

/**
 * StudioAuthController — Phase-1 SSO login for Todd Studio.
 *
 * Accepts the SAME email/password as a Cricket Manager account and, when
 * that account has the `can_access_studio` permission, mints a short-lived
 * HS256 JWT that the Rust media engine verifies locally. The token carries
 * `perms: ["studio_director"]`, which the engine requires on director routes.
 */
class StudioAuthController extends Controller
{
    private const TOKEN_TTL_SECONDS = 900;

    public function login(Request $request, MediaEngineTokenService $tokens): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $manager = CricketManager::where('email', $request->email)->first();

        if (!$manager || !$manager->verifyPassword($request->password)) {
            return response()->json(['message' => 'Invalid credentials.'], 401);
        }

        if (!$manager->isActive()) {
            return response()->json(['message' => 'Account is suspended. Contact your account administrator.'], 403);
        }

        $permissions = $manager->permissions ?? [];

        if (empty($permissions['can_access_studio'])) {
            return response()->json(['message' => 'Studio Director Access is not enabled for this account.'], 403);
        }

        // Guard against silently minting tokens signed with an empty secret,
        // which the Rust engine would reject for every request.
        if ((string) config('services.media_engine.secret', '') === '') {
            return response()->json(['message' => 'Media engine JWT secret is not configured.'], 500);
        }

        $token = $tokens->mint(
            role: 'admin',
            perms: ['studio_director'],
            subject: (string) $manager->id,
            ttlSeconds: self::TOKEN_TTL_SECONDS,
        );

        $expiresAt = now()->addSeconds(self::TOKEN_TTL_SECONDS);

        $manager->last_login_at = now();
        $manager->last_login_ip = $request->ip();
        $manager->save();

        try {
            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'action' => 'studio_login',
                'metadata' => ['email' => $manager->email],
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);
        } catch (\Throwable $e) {
            Log::warning('studio_login audit log insert failed: ' . $e->getMessage());
        }

        return response()->json([
            'message' => 'Studio login successful.',
            'token' => $token,
            'expires_at' => $expiresAt->toIso8601String(),
            'manager' => [
                'id' => $manager->id,
                'name' => $manager->name,
                'email' => $manager->email,
            ],
        ]);
    }

    /**
     * Phase 1 unified SSO: exchange an already-valid Cricket Manager
     * bearer token for a media-engine JWT.
     *
     * This is the "Open Todd Studio" fast path — the Flutter Manager panel
     * calls it with its own bearer token and receives the same HS256 JWT
     * the interactive login mints, so the director never re-enters
     * credentials (or a separate API token).
     *
     * The manager token is validated against the same hashed store the
     * `cricket.manager` middleware uses; no session is created on the
     * studio side.
     */
    public function exchange(Request $request, MediaEngineTokenService $tokens): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'manager_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $hashed = hash('sha256', (string) $validator->validated()['manager_token']);
        $manager = CricketManager::where('auth_token', $hashed)
            ->where('status', 'active')
            ->first();

        if (!$manager) {
            return response()->json(['message' => 'Manager session is not valid.'], 401);
        }

        if ($manager->token_expires_at && $manager->token_expires_at->isPast()) {
            $manager->revokeAuthToken();
            return response()->json(['message' => 'Manager session expired. Please log in again.'], 401);
        }

        $permissions = $manager->permissions ?? [];

        if (empty($permissions['can_access_studio'])) {
            return response()->json(['message' => 'Studio Director Access is not enabled for this account.'], 403);
        }

        if ((string) config('services.media_engine.secret', '') === '') {
            return response()->json(['message' => 'Media engine JWT secret is not configured.'], 500);
        }

        $token = $tokens->mint(
            role: 'admin',
            perms: ['studio_director'],
            subject: (string) $manager->id,
            ttlSeconds: self::TOKEN_TTL_SECONDS,
        );

        try {
            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'action' => 'studio_exchange',
                'metadata' => ['email' => $manager->email],
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);
        } catch (\Throwable $e) {
            Log::warning('studio_exchange audit log insert failed: ' . $e->getMessage());
        }

        return response()->json([
            'message' => 'Studio token issued.',
            'token' => $token,
            'expires_at' => now()->addSeconds(self::TOKEN_TTL_SECONDS)->toIso8601String(),
            'manager' => [
                'id' => $manager->id,
                'name' => $manager->name,
                'email' => $manager->email,
            ],
        ]);
    }

    /**
     * Silent token refresh for Todd Studio: accepts the director's
     * existing media-engine JWT (even one that expired a moment ago) and
     * mints a fresh one, so WHEP watches and the control WebSocket never
     * die with 401 mid-session. The token is verified locally (HMAC) — no
     * Laravel session is required, matching the engine's own validation.
     */
    public function refresh(Request $request, MediaEngineTokenService $tokens): JsonResponse
    {
        $header = (string) $request->header('Authorization', '');
        $token = str_starts_with($header, 'Bearer ')
            ? substr($header, 7)
            : (string) $request->input('token', '');

        if ($token === '') {
            return response()->json(['message' => 'Missing token.'], 401);
        }

        try {
            $claims = $tokens->verify($token, leewaySeconds: 86400);
        } catch (\InvalidArgumentException $e) {
            return response()->json(['message' => 'Token refresh rejected: ' . $e->getMessage()], 401);
        }

        $manager = CricketManager::find($claims['sub'] ?? null);
        if (!$manager || !$manager->isActive()) {
            return response()->json(['message' => 'Account is not available.'], 403);
        }

        $permissions = $manager->permissions ?? [];
        if (empty($permissions['can_access_studio'])) {
            return response()->json(['message' => 'Studio Director Access is not enabled for this account.'], 403);
        }

        if ((string) config('services.media_engine.secret', '') === '') {
            return response()->json(['message' => 'Media engine JWT secret is not configured.'], 500);
        }

        $fresh = $tokens->mint(
            role: 'admin',
            perms: ['studio_director'],
            subject: (string) $manager->id,
            ttlSeconds: self::TOKEN_TTL_SECONDS,
        );

        return response()->json([
            'message' => 'Studio token refreshed.',
            'token' => $fresh,
            'expires_at' => now()->addSeconds(self::TOKEN_TTL_SECONDS)->toIso8601String(),
        ]);
    }
}
