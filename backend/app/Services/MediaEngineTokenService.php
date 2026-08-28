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

    /**
     * RFC 4648 §5 base64url decoding (padding-tolerant).
     */
    private static function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder > 0) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        $decoded = base64_decode(strtr($data, '-_', '+/'), true);
        if ($decoded === false) {
            throw new \InvalidArgumentException('Invalid base64url payload.');
        }
        return $decoded;
    }

    /**
     * Verifies an HS256 token minted by this service (or the Rust engine):
     * signature, audience and issuer. `exp` is checked with a leeway so a
     * just-expired director token can be exchanged for a fresh one without
     * forcing a re-login.
     *
     * @return array The verified claim set.
     *
     * @throws \InvalidArgumentException when the token is malformed, badly
     *                                    signed, mis-scoped or expired beyond
     *                                    the leeway.
     */
    public function verify(string $token, int $leewaySeconds = 86400): array
    {
        $secret = (string) config('services.media_engine.secret', '');
        if ($secret === '') {
            throw new \InvalidArgumentException('Media engine JWT secret is not configured.');
        }

        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new \InvalidArgumentException('Malformed token.');
        }

        $signingInput = $parts[0] . '.' . $parts[1];
        $expected = self::base64UrlEncode(hash_hmac('sha256', $signingInput, $secret, true));
        if (!hash_equals($expected, $parts[2])) {
            throw new \InvalidArgumentException('Token signature mismatch.');
        }

        $payload = json_decode(self::base64UrlDecode($parts[1]), true);
        if (!is_array($payload)) {
            throw new \InvalidArgumentException('Malformed token payload.');
        }

        if (($payload['aud'] ?? null) !== self::AUDIENCE) {
            throw new \InvalidArgumentException('Token audience mismatch.');
        }
        if (($payload['iss'] ?? null) !== (string) config('services.media_engine.issuer', 'traceodd')) {
            throw new \InvalidArgumentException('Token issuer mismatch.');
        }
        if ((int) ($payload['exp'] ?? 0) + $leewaySeconds < time()) {
            throw new \InvalidArgumentException('Token expired beyond refresh window.');
        }

        return $payload;
    }
}
