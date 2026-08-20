<?php

namespace Tests\Feature;

use Database\Factories\CricketManagerFactory;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class StudioAuthControllerTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.media_engine.secret' => 'test-secret',
            'services.media_engine.issuer' => 'traceodd',
        ]);

        $this->createCricketTables();
    }

    public function test_login_returns_422_for_missing_fields(): void
    {
        $this->postJson('/api/v1/studio/login', [])
            ->assertStatus(422)
            ->assertJsonStructure(['errors']);
    }

    public function test_login_returns_401_for_invalid_credentials(): void
    {
        CricketManagerFactory::new()->create([
            'email' => 'director@example.com',
            'password' => 'correct-password',
        ]);

        $this->postJson('/api/v1/studio/login', [
            'email' => 'director@example.com',
            'password' => 'wrong-password',
        ])->assertStatus(401)->assertJson(['message' => 'Invalid credentials.']);
    }

    public function test_login_returns_403_for_suspended_manager(): void
    {
        CricketManagerFactory::new()->suspended()->withStudioAccess()->create([
            'email' => 'suspended@example.com',
        ]);

        $this->postJson('/api/v1/studio/login', [
            'email' => 'suspended@example.com',
            'password' => 'password',
        ])->assertStatus(403)->assertJson([
            'message' => 'Account is suspended. Contact your account administrator.',
        ]);
    }

    public function test_login_returns_403_when_studio_access_is_not_enabled(): void
    {
        CricketManagerFactory::new()->create([
            'email' => 'regular@example.com',
            'password' => 'password',
        ]);

        $this->postJson('/api/v1/studio/login', [
            'email' => 'regular@example.com',
            'password' => 'password',
        ])->assertStatus(403)->assertJson([
            'message' => 'Studio Director Access is not enabled for this account.',
        ]);
    }

    public function test_login_mints_a_decodable_jwt_for_an_authorized_manager(): void
    {
        $manager = CricketManagerFactory::new()->withStudioAccess()->create([
            'email' => 'studio@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/v1/studio/login', [
            'email' => 'studio@example.com',
            'password' => 'password',
        ])->assertStatus(200);

        $response->assertJsonStructure([
            'message',
            'token',
            'expires_at',
            'manager' => ['id', 'name', 'email'],
        ]);

        $token = $response->json('token');
        $this->assertIsString($token);

        $parts = explode('.', $token);
        $this->assertCount(3, $parts);

        $payload = json_decode($this->base64UrlDecode($parts[1]), true);

        $this->assertSame('traceodd', $payload['iss']);
        $this->assertSame('todd-media-engine', $payload['aud']);
        $this->assertSame((string) $manager->id, $payload['sub']);
        $this->assertSame('admin', $payload['role']);
        $this->assertSame(['studio_director'], $payload['perms']);
        $this->assertSame($payload['iat'] + 900, $payload['exp']);

        $expected = strtr(
            rtrim(base64_encode(hash_hmac('sha256', $parts[0] . '.' . $parts[1], 'test-secret', true)), '='),
            '+/',
            '-_'
        );
        $this->assertSame($expected, $parts[2]);

        $this->assertSame(
            (string) $manager->id,
            (string) $response->json('manager.id')
        );

        $this->assertDatabaseHas('cricket_manager_session_logs', [
            'cricket_manager_id' => $manager->id,
            'action' => 'studio_login',
        ]);
    }

    public function test_login_returns_500_when_media_engine_secret_is_not_configured(): void
    {
        config(['services.media_engine.secret' => '']);

        CricketManagerFactory::new()->withStudioAccess()->create([
            'email' => 'nosecret@example.com',
            'password' => 'password',
        ]);

        $this->postJson('/api/v1/studio/login', [
            'email' => 'nosecret@example.com',
            'password' => 'password',
        ])->assertStatus(500)->assertJson([
            'message' => 'Media engine JWT secret is not configured.',
        ]);
    }

    /**
     * Create the cricket tables the auth flow touches, using a
     * sqlite-compatible schema. The production migrations are
     * Postgres-specific (enum actions, gen_random_uuid defaults) and
     * cannot run under the sqlite test database.
     */
    private function createCricketTables(): void
    {
        if (!Schema::hasTable('cricket_managers')) {
            Schema::create('cricket_managers', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name', 200);
                $table->string('email', 200)->unique();
                $table->string('password');
                $table->string('phone', 50)->nullable();
                $table->string('auth_token', 128)->nullable()->unique();
                $table->timestamp('token_expires_at')->nullable();
                $table->string('status', 20)->default('active');
                $table->jsonb('permissions')->nullable();
                $table->uuid('provisioned_by_global_identity_id')->nullable();
                $table->timestamp('last_login_at')->nullable();
                $table->string('last_login_ip', 45)->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
        }

        if (!Schema::hasTable('cricket_manager_session_logs')) {
            Schema::create('cricket_manager_session_logs', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('cricket_manager_id');
                $table->uuid('match_id')->nullable();
                $table->string('action', 50);
                $table->jsonb('metadata')->nullable();
                $table->string('ip_address', 45)->nullable();
                $table->text('user_agent')->nullable();
                $table->timestamps();
            });
        }
    }

    private function base64UrlDecode(string $value): string
    {
        $remainder = strlen($value) % 4;

        if ($remainder > 0) {
            $value .= str_repeat('=', 4 - $remainder);
        }

        return base64_decode(strtr($value, '-_', '+/'));
    }
}
