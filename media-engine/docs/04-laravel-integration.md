# 04 — Laravel Integration

Everything Laravel needs to drive the Rust media engine. The contract is
tiny: one URL + one shared secret. No composer packages beyond
`firebase/php-jwt`.

## 1. Composer + env

```bash
composer require firebase/php-jwt
```

```env
# .env (Phase 1 — same server)
MEDIA_ENGINE_URL=http://127.0.0.1:8080
MEDIA_ENGINE_JWT_SECRET=<same 64-char secret as the Rust .env>
MEDIA_ENGINE_JWT_ISSUER=traceodd
```

```php
// config/services.php
'media_engine' => [
    'url'     => env('MEDIA_ENGINE_URL', 'http://127.0.0.1:8080'),
    'secret'  => env('MEDIA_ENGINE_JWT_SECRET'),
    'issuer'  => env('MEDIA_ENGINE_JWT_ISSUER', 'traceodd'),
    'timeout' => 5,
],
```

## 2. Token minting service

Must match `todd-common/src/auth.rs` claim-for-claim
(iss/aud/sub/room_id/camera_id/role/perms/iat/exp/jti, HS256).

```php
<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Illuminate\Support\Str;

class MediaEngineTokenService
{
    public const AUDIENCE = 'todd-media-engine';

    public function mint(
        string $role,          // admin | publisher | viewer
        ?string $roomId = null,
        ?string $cameraId = null,
        ?string $subject = null,
        int $ttlSeconds = 300,
        array $perms = [],     // e.g. ['studio_director']
    ): string {
        $now = time();

        return JWT::encode([
            'iss'       => config('services.media_engine.issuer'),
            'aud'       => self::AUDIENCE,
            'sub'       => $subject ?? 'laravel',
            'room_id'   => $roomId,
            'camera_id' => $cameraId,
            'role'      => $role,
            'perms'     => $perms ?? [],
            'iat'       => $now,
            'exp'       => $now + $ttlSeconds,
            'jti'       => (string) Str::uuid(),
        ], config('services.media_engine.secret'), 'HS256');
    }
}
```

### Permissions

Phase-1 SSO enforcement: every director-control route in the Studio
(room create/list/delete, camera CRUD, forwarding, program
transition/get/overlay, audio mix, replay trigger/list/close/export and
the control-plane WebSocket) requires the `studio_director` permission
in the token's `perms` array. Legacy compatibility rule: an admin token
with an empty (or missing) `perms` claim — i.e. any token minted before
the field existed — still passes, so existing server-to-server Laravel
admin tokens keep working unchanged. Tokens minted with an explicit
`perms` list must include `studio_director` explicitly.

## 3. HTTP client

```php
<?php

namespace App\Services;

use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;

class MediaEngineClient
{
    public function __construct(private readonly MediaEngineTokenService $tokens) {}

    private function http(): PendingRequest
    {
        return Http::baseUrl(config('services.media_engine.url'))
            ->timeout(config('services.media_engine.timeout'))
            ->acceptJson()
            ->withToken($this->tokens->mint('admin', ttlSeconds: 3600));
    }

    /** @return array{room: array, ingest_tokens: array<string,string>, viewer_token: string, whip_base_url: string} */
    public function createRoom(string $name, array $cameraIds, int $ttlSeconds = 3600): array
    {
        return $this->http()
            ->post('/api/v1/room/create', [
                'name'       => $name,
                'camera_ids' => $cameraIds,
                'ttl_secs'   => $ttlSeconds,
            ])
            ->throw()
            ->json();
    }

    public function deleteRoom(string $roomId): void
    {
        $this->http()->delete("/api/v1/room/{$roomId}")->throw();
    }

    /** @return array{camera_id: string, kind: string, url: string} */
    public function forwardCamera(string $roomId, string $cameraId, string $kind, string $url): void
    {
        $this->http()
            ->post("/api/v1/room/{$roomId}/forward", [
                'camera_id' => $cameraId,
                'kind'      => $kind, // rtmp | srt | file
                'url'       => $url,
            ])
            ->throw();
    }
}
```

## 4. Example controller

```php
<?php

namespace App\Http\Controllers;

use App\Services\MediaEngineClient;

class BroadcastRoomController extends Controller
{
    public function start(MediaEngineClient $media): \Illuminate\Http\JsonResponse
    {
        $room = $media->createRoom(
            name: 'match-' . request('match_id'),
            cameraIds: ['main', 'angle-2'],
        );

        // Hand the per-camera ingest tokens to the camera apps:
        //   $room['ingest_tokens']['main']  -> camera "main"
        //   $room['whip_base_url'] . '/main' -> WHIP POST URL
        return response()->json($room, 201);
    }
}
```

## 5. Optional: opaque (Sanctum) token introspection

Only needed if browser sessions with Sanctum tokens must call the engine
directly (Phase 2). The Rust side then needs
`LARAVEL_INTROSPECTION_URL` set to this route.

```php
// routes/api.php
Route::post('/auth/introspect', function (Request $request) {
    $user = auth('sanctum')->user(); // your Sanctum guard
    if (! $user) {
        return response()->json(['active' => false], 401);
    }
    return response()->json([
        'active'    => true,
        'sub'       => (string) $user->id,
        'role'      => $request->input('role_hint', 'viewer'),
        'room_id'   => $request->input('room_id'),
        'camera_id' => $request->input('camera_id'),
    ]);
});
```

Prefer JWTs for the ingest path; introspection adds a network hop per
validation.

## 6. Phase 2 migration (from Laravel's side)

```env
# .env — that's it
MEDIA_ENGINE_URL=https://media.traceodd.com
```

```bash
php artisan config:clear && php artisan config:cache
```

Everything else (client code, tokens, client URLs) is unchanged — see
`docs/03-phase2-migration.md` for the server-side runbook.
