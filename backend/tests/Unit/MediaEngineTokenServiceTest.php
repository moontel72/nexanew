<?php

namespace Tests\Unit;

use App\Services\MediaEngineTokenService;
use Tests\TestCase;

class MediaEngineTokenServiceTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.media_engine.secret' => 'unit-test-secret',
            'services.media_engine.issuer' => 'traceodd',
        ]);
    }

    public function test_minted_token_is_a_valid_hs256_jwt_with_the_rust_claim_set(): void
    {
        $token = (new MediaEngineTokenService())->mint(
            role: 'admin',
            subject: 'manager-123',
            perms: ['studio_director'],
            ttlSeconds: 900,
        );

        $parts = explode('.', $token);
        $this->assertCount(3, $parts);

        // Header
        $header = json_decode($this->base64UrlDecode($parts[0]), true);
        $this->assertSame('HS256', $header['alg']);
        $this->assertSame('JWT', $header['typ']);

        // Payload — claim-for-claim with the Rust TokenClaims struct
        $payload = json_decode($this->base64UrlDecode($parts[1]), true);

        $this->assertSame('traceodd', $payload['iss']);
        $this->assertSame('todd-media-engine', $payload['aud']);
        $this->assertSame('manager-123', $payload['sub']);
        $this->assertSame('admin', $payload['role']);
        $this->assertNull($payload['room_id']);
        $this->assertNull($payload['camera_id']);
        $this->assertSame(['studio_director'], $payload['perms']);
        $this->assertSame($payload['iat'] + 900, $payload['exp']);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $payload['jti']
        );

        // Signature must re-compute with the configured secret
        $expected = $this->base64UrlEncode(
            hash_hmac('sha256', $parts[0] . '.' . $parts[1], 'unit-test-secret', true)
        );
        $this->assertSame($expected, $parts[2]);
    }

    public function test_mint_applies_defaults_for_subject_ttl_and_perms(): void
    {
        $token = (new MediaEngineTokenService())->mint('viewer');

        $parts = explode('.', $token);
        $payload = json_decode($this->base64UrlDecode($parts[1]), true);

        $this->assertSame('laravel', $payload['sub']);
        $this->assertSame([], $payload['perms']);
        $this->assertSame($payload['iat'] + 300, $payload['exp']);
        $this->assertSame('viewer', $payload['role']);
    }

    public function test_mint_throws_when_the_secret_is_not_configured(): void
    {
        config(['services.media_engine.secret' => '']);

        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Media engine JWT secret is not configured.');

        (new MediaEngineTokenService())->mint('admin');
    }

    private function base64UrlDecode(string $value): string
    {
        $remainder = strlen($value) % 4;

        if ($remainder > 0) {
            $value .= str_repeat('=', 4 - $remainder);
        }

        return base64_decode(strtr($value, '-_', '+/'));
    }

    private function base64UrlEncode(string $data): string
    {
        return strtr(rtrim(base64_encode($data), '='), '+/', '-_');
    }
}
