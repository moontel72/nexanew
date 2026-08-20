<?php

namespace App\Services;

use Illuminate\Support\Str;

/**
 * MediaEngineTokenService — dependency-free HS256 JWT minting for the
 * Rust media engine.
 *
 * This is the PHP mirror of `media-engine/crates/todd-common/src/auth.rs`
 * (see `TokenClaims` and `mint_token`): identical HS256 algorithm and the
 * exact same claim set, signed with the shared MEDIA_ENGINE_JWT_SECRET so
 * tokens minted here verify locally in the Rust engine with no network hop.
 *
 * Intentionally has NO external JWT package (no firebase/php-jwt): the
 * compact JWS is built with base64url encoding + hash_hmac only, keeping
 * composer.json/lock untouched.
 */
class MediaEngineTokenService
{
    /** Audience expected in every token — must match Rust `AUDIENCE`. */
    public const AUDIENCE = 'todd-media-engine';

    /**
     * Mint an HS256 JWT for the Rust media engine.
     *
     * Claims (claim-for-claim with the Rust `TokenClaims`):
     *   iss, aud, sub, room_id, camera_id, role, perms, iat, exp, jti
     *
     * @param string       $role      `admin`, `publisher` or `viewer` (Rust `TokenRole` serde names)
     * @param string|null  $roomId    Scope the token to a room (null = unscoped)
     * @param string|null  $cameraId  Scope the token to a camera (null = unscoped)
     * @param string|null  $subject   User/device id; defaults to "laravel" for server-to-server
     * @param string[]     $perms     Fine-grained permissions (e.g. `studio_director`)
     * @param int          $ttlSeconds Token lifetime in seconds (default 300)
     *
     * @throws \InvalidArgumentException when the media engine JWT secret is not configured
     */
    public function mint(
        string $role,
        ?string $roomId = null,
        ?string $cameraId = null,
        ?string $subject = null,
        array $perms = [],
        int $ttlSeconds = 300
    ): string {
        $secret = (string) config('services.media_engine.secret', '');

        if ($secret === '') {
            throw new \InvalidArgumentException('Media engine JWT secret is not configured.');
        }

        $now = time();

        $header = [
            'alg' => 'HS256',
            'typ' => 'JWT',
        ];

        $payload = [
            'iss' => (string) config('services.media_engine.issuer', 'traceodd'),
            'aud' => self::AUDIENCE,
            'sub' => $subject ?? 'laravel',
            'room_id' => $roomId,
            'camera_id' => $cameraId,
            'role' => $role,
            'perms' => array_values(array_map('strval', $perms)),
            'iat' => $now,
            'exp' => $now + $ttlSeconds,
            'jti' => (string) Str::uuid(),
        ];

        $encodedHeader = self::base64UrlEncode(json_encode($header));
        $encodedPayload = self::base64UrlEncode(
            json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)
        );

        $signingInput = $encodedHeader . '.' . $encodedPayload;
        $signature = self::base64UrlEncode(hash_hmac('sha256', $signingInput, $secret, true));

        return $signingInput . '.' . $signature;
    }

    /**
     * RFC 4648 §5 base64url encoding (no padding).
     */
    private static function base64UrlEncode(string $data): string
    {
        return strtr(rtrim(base64_encode($data), '='), '+/', '-_');
    }
}
