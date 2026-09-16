<?php

namespace App\Services\Cricket;

use App\Models\Cricket\StreamEndpoint;
use App\Services\MediaEngineTokenService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * CricketStreamSyncService — the single owner of the Cricket Manager's
 * relationship with the Rust media engine.
 *
 * The public page is fed by SRS:
 *
 *   broadcaster (WHIP) → engine → RTMP → SRS → HLS → cricket.traceodd.com
 *
 * Only the middle hop is ours to manage. `startPgmForwarder` creates it and
 * `healthFor` reports whether it is alive; `resyncStream` rebuilds it. The
 * forwarder is what turns "a camera is publishing" into "an HLS playlist
 * exists", so every HLS 404 traces back to this one object.
 *
 * Extracted from StreamController so the same logic can run from the HTTP
 * request (activation) and from the `cricket:stream-watchdog` command
 * (recovery), with no chance of the two drifting apart.
 */
class CricketStreamSyncService
{
    public function __construct(
        private readonly MediaEngineTokenService $tokens,
    ) {
    }

    /** Engine base URL, or null when the engine is not configured. */
    private function engineUrl(): ?string
    {
        $url = rtrim((string) config('services.media_engine.url', ''), '/');

        return $url === '' ? null : $url;
    }

    /** Public HLS URL the browser will request for a stream row. */
    public function hlsUrlFor(StreamEndpoint $stream): string
    {
        $base = rtrim((string) config('cricket.streaming.hls_base_url'), '/');

        return $base . '/' . $stream->rtmp_stream_key . '.m3u8';
    }

    /** Full RTMP target the engine should publish to for a stream row. */
    public function rtmpUrlFor(StreamEndpoint $stream): string
    {
        $base = $stream->rtmp_ingest_url
            ?: config('cricket.streaming.rtmp_ingest_url');

        return rtrim((string) $base, '/') . '/' . $stream->rtmp_stream_key;
    }

    /**
     * Live health of one stream's forwarder.
     *
     * @return array{forwarder_state: string, forwarder_error: ?string}
     */
    public function healthFor(StreamEndpoint $stream): array
    {
        $url = $this->rtmpUrlFor($stream);

        foreach ($this->listForwarders() as $forwarder) {
            if (($forwarder['url'] ?? '') !== $url) {
                continue;
            }

            return [
                'forwarder_state' => (string) ($forwarder['state'] ?? 'unknown'),
                'forwarder_error' => $forwarder['error'] ?? null,
            ];
        }

        return ['forwarder_state' => 'missing', 'forwarder_error' => null];
    }

    /**
     * Ensures the engine is forwarding this stream to SRS.
     *
     * Idempotent — an already-running forwarder for the same URL is left
     * alone. Returns true when a forwarder is running afterwards.
     */
    public function resyncStream(StreamEndpoint $stream): bool
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return false;
        }

        $rtmpUrl = $this->rtmpUrlFor($stream);

        // A forwarder is already healthy — nothing to do.
        if (($this->healthFor($stream)['forwarder_state']) === 'running') {
            return true;
        }

        // A previous attempt left a dead entry for this URL (failed build, or
        // the pipeline died on a bus error). Clear it so the target can be
        // registered again.
        $this->stopForwarderFor($stream);

        $token = $this->directorToken();

        $rooms = $this->fetchJson("{$engineUrl}/api/v1/room/list", $token);
        if (!is_array($rooms) || empty($rooms)) {
            Log::info('Cricket: no active Studio room — forwarder skipped.');

            return false;
        }

        $source = $this->programSource($engineUrl, $token, $rooms);
        if ($source === null) {
            Log::info('Cricket: no forwardable broadcaster camera — forwarder skipped.', [
                'stream_id' => $stream->id,
            ]);

            return false;
        }

        $res = Http::timeout(10)
            ->withToken($token)
            ->withHeaders(['Content-Type' => 'application/json'])
            ->post("{$engineUrl}/api/v1/room/{$source['room_id']}/forward", [
                'camera_id' => $source['camera_id'],
                'source' => 'camera',
                'kind' => 'rtmp',
                'url' => $rtmpUrl,
                'bitrate_kbps' => (int) config('cricket.streaming.forwarder_bitrate_kbps', 4000),
            ]);

        if ($res->successful()) {
            Log::info('Cricket: PGM forwarder started', [
                'room_id' => $source['room_id'],
                'camera_id' => $source['camera_id'],
                'url' => $rtmpUrl,
            ]);

            return true;
        }

        Log::warning('Cricket: PGM forwarder start failed', [
            'status' => $res->status(),
            'body' => $res->body(),
            'url' => $rtmpUrl,
        ]);

        return false;
    }

    /**
     * Removes every `cricket-*` ghost camera from the Studio rooms.
     *
     * An earlier release registered the on-air camera a second time under
     * `cricket-{stream_id}` with `kind: "hls"`, on top of the broadcaster's
     * own WHIP camera for the same physical feed. Two registrations meant two
     * tiles, which split the Studio player 50/50 and left one pane stuck on
     * "loading HLS stream…" whenever the SRS playlist was missing.
     *
     * Self-healing: a room poisoned by that release is cleaned the next time
     * a camera is activated, so operators do not have to recreate the room.
     * Never throws — cleanup must not block going on air.
     *
     * @return int Number of ghost cameras removed.
     */
    public function removeGhostCameras(): int
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return 0;
        }

        $removed = 0;

        try {
            $token = $this->directorToken();
            $rooms = $this->fetchJson("{$engineUrl}/api/v1/room/list", $token);

            if (!is_array($rooms)) {
                return 0;
            }

            foreach ($rooms as $room) {
                $roomId = $room['id'] ?? null;
                if (!is_string($roomId) || $roomId === '') {
                    continue;
                }

                foreach ($room['cameras'] ?? [] as $camera) {
                    $cameraId = $camera['id'] ?? null;
                    if (!is_string($cameraId) || !str_starts_with($cameraId, 'cricket-')) {
                        continue;
                    }

                    $res = Http::timeout(5)
                        ->withToken($token)
                        ->delete("{$engineUrl}/api/v1/room/{$roomId}/camera/{$cameraId}");

                    if ($res->successful()) {
                        $removed++;
                        Log::info('Cricket: removed ghost Studio camera', [
                            'room_id' => $roomId,
                            'camera_id' => $cameraId,
                        ]);
                    } else {
                        Log::warning('Cricket: ghost Studio camera removal failed', [
                            'room_id' => $roomId,
                            'camera_id' => $cameraId,
                            'status' => $res->status(),
                            'body' => $res->body(),
                        ]);
                    }
                }
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: ghost Studio camera cleanup error (non-critical)', [
                'error' => $e->getMessage(),
            ]);
        }

        return $removed;
    }

    /** Admin JWT for engine control-plane calls. */
    private function directorToken(): string
    {
        return $this->tokens->mint(
            role: 'admin',
            subject: 'laravel-stream-sync',
            perms: ['studio_director'],
            ttlSeconds: 120,
        );
    }

    /** Stops the forwarder targeting this stream's URL, if any. */
    public function stopForwarderFor(StreamEndpoint $stream): void
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return;
        }

        $rtmpUrl = $this->rtmpUrlFor($stream);
        $token = $this->directorToken();

        foreach ($this->listForwarders() as $forwarder) {
            if (($forwarder['url'] ?? '') !== $rtmpUrl) {
                continue;
            }
            $key = $forwarder['key'] ?? '';
            if (!is_string($key) || $key === '') {
                continue;
            }

            $res = Http::timeout(5)
                ->withToken($token)
                ->delete("{$engineUrl}/api/v1/forward/" . urlencode($key));

            if ($res->successful()) {
                Log::info('Cricket: stale forwarder stopped', ['key' => $key]);
            }
        }
    }

    /**
     * Resolves the room + camera that should feed SRS for the public page.
     *
     * Prefers the Studio's current PGM camera, but only when that camera is a
     * WHIP publisher. An `hls` camera is a display-only entry with no RTP
     * track in the engine, so requesting a forwarder on it fails with
     * "no video stream on camera … layer ''" and the public page stays dark
     * even though a healthy broadcaster camera is live in the same room.
     *
     * Falls back to the first active WHIP camera so a director who never
     * pressed PGM still goes on air.
     *
     * @param  array<int, array<string, mixed>>  $rooms
     * @return array{room_id: string, camera_id: string}|null
     */
    private function programSource(string $engineUrl, string $token, array $rooms): ?array
    {
        $fallback = null;

        foreach ($rooms as $room) {
            $roomId = $room['id'] ?? null;
            if (!is_string($roomId) || $roomId === '') {
                continue;
            }

            $cameras = is_array($room['cameras'] ?? null) ? $room['cameras'] : [];

            $program = $this->fetchJson("{$engineUrl}/api/v1/program/" . urlencode($roomId), $token);
            $cameraId = is_array($program) ? ($program['camera_id'] ?? null) : null;

            if (is_string($cameraId) && $cameraId !== '') {
                if ($this->isForwardableCamera($cameras, $cameraId)) {
                    return ['room_id' => $roomId, 'camera_id' => $cameraId];
                }

                Log::warning('Cricket: PGM camera is not forwardable — falling back', [
                    'room_id' => $roomId,
                    'camera_id' => $cameraId,
                ]);
            }

            if ($fallback === null) {
                $fallback = $this->firstActiveWhipCamera($roomId, $cameras);
            }
        }

        return $fallback;
    }

    /**
     * True when the engine can forward this camera to a muxer.
     *
     * `whip` is the only source kind that registers RTP tracks through the
     * publisher path; anything else has no media in the engine.
     *
     * @param  array<int, array<string, mixed>>  $cameras
     */
    private function isForwardableCamera(array $cameras, string $cameraId): bool
    {
        foreach ($cameras as $camera) {
            if (($camera['id'] ?? null) === $cameraId) {
                return ($camera['kind'] ?? '') === 'whip';
            }
        }

        return false;
    }

    /**
     * @param  array<int, array<string, mixed>>  $cameras
     * @return array{room_id: string, camera_id: string}|null
     */
    private function firstActiveWhipCamera(string $roomId, array $cameras): ?array
    {
        foreach ($cameras as $camera) {
            $cameraId = $camera['id'] ?? null;
            if (!is_string($cameraId) || $cameraId === '') {
                continue;
            }
            if (($camera['kind'] ?? '') !== 'whip') {
                continue;
            }
            if (($camera['active'] ?? false) !== true) {
                continue;
            }

            return ['room_id' => $roomId, 'camera_id' => $cameraId];
        }

        return null;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function listForwarders(): array
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return [];
        }

        $list = $this->fetchJson("{$engineUrl}/api/v1/forward/list", $this->directorToken());

        return is_array($list) ? $list : [];
    }

    /** GET a JSON document from the engine, or null. Never throws. */
    private function fetchJson(string $url, string $token): mixed
    {
        try {
            $res = Http::timeout(5)->withToken($token)->get($url);
            if (!$res->successful()) {
                return null;
            }

            return $res->json();
        } catch (\Throwable $e) {
            Log::warning('Cricket: engine probe failed', [
                'url' => $url,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }
}
