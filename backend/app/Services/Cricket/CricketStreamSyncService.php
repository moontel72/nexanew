<?php

namespace App\Services\Cricket;

use App\Models\Cricket\MatchModel;
use App\Services\MediaEngineTokenService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * CricketStreamSyncService — owns the bridge that puts live video on the
 * public page.
 *
 * The path is fixed and has exactly one origin:
 *
 *   Todd Broadcaster (WHIP) → engine → RTMP → SRS → HLS → cricket.traceodd.com
 *
 * The broadcaster owns the cameras; the Cricket Manager owns nothing in that
 * chain. This service's whole job is the middle hop — creating the engine→SRS
 * forwarder, reporting whether it is alive, and re-creating it when it dies.
 *
 * Two consequences of that ownership are deliberate and load-bearing:
 *
 *   1. **No camera registry.** The engine room is the source of truth for
 *      which cameras exist. An earlier design mirrored it into a
 *      `cricket_streams` table and had the manager register a camera of its
 *      own; that split the Studio player into two panes and left the public
 *      page dark, because the manager's camera never carried any video.
 *
 *   2. **The SRS stream name is derived from the match, not stored.** It is
 *      deterministic (`cricket_match_{matchId}_cam{N}`), so the public page
 *      can build its playlist URL without reading a database row — which
 *      means there is no row to be missing.
 */
class CricketStreamSyncService
{
    /** SRS/HLS stream-name prefix for cricket match feeds. */
    private const STREAM_PREFIX = 'cricket_match_';

    public function __construct(
        private readonly MediaEngineTokenService $tokens,
    ) {
    }

    /** Engine base URL, or null when the engine is not configured. */
    private function engineUrl(): ?string
    {
        $url = rtrim((string) config('services.media_engine.url', ''), '');

        return $url === '' ? null : $url;
    }

    /**
     * Deterministic SRS stream name for a match's on-air camera.
     *
     * Derived rather than looked up: it must be computable by the public page
     * from the match id alone, so playback never depends on a database row
     * that a cleanup could remove.
     */
    public function streamNameFor(string $matchId, int $cameraNumber = 1): string
    {
        return self::STREAM_PREFIX . $matchId . '_cam' . $cameraNumber;
    }

    /** RTMP target the engine publishes the match feed to. */
    public function rtmpUrlFor(string $matchId, int $cameraNumber = 1): string
    {
        $base = rtrim((string) config('cricket.streaming.rtmp_ingest_url'), '/');

        return $base . '/' . $this->streamNameFor($matchId, $cameraNumber);
    }

    /** Public HLS playlist the browser plays for a match. */
    public function hlsUrlFor(string $matchId, int $cameraNumber = 1): string
    {
        $base = rtrim((string) config('cricket.streaming.hls_base_url'), '/');

        return $base . '/' . $this->streamNameFor($matchId, $cameraNumber) . '.m3u8';
    }

    /**
     * Ensures the engine is forwarding a match's on-air camera to SRS.
     *
     * Idempotent: a forwarder already running for this match's URL is left
     * alone. Returns true when a forwarder is running afterwards, false when
     * no broadcaster camera is available yet (the normal state before the
     * operator hits "Go Live" in the broadcaster — not an error).
     */
    public function resyncMatch(string $matchId, int $cameraNumber = 1): bool
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return false;
        }

        $rtmpUrl = $this->rtmpUrlFor($matchId, $cameraNumber);

        if ($this->healthForMatch($matchId, $cameraNumber)['forwarder_state'] === 'running') {
            return true;
        }

        // Clear a dead entry for this URL (previous build failure, or a
        // pipeline that died on a bus error) so the target can be registered.
        $this->stopForwarderForMatch($matchId, $cameraNumber);

        $token = $this->directorToken();

        $rooms = $this->fetchJson("{$engineUrl}/api/v1/room/list", $token);
        if (!is_array($rooms) || empty($rooms)) {
            Log::info('Cricket: no active Studio room — forwarder skipped.');

            return false;
        }

        $source = $this->broadcasterCamera($engineUrl, $token, $rooms);
        if ($source === null) {
            Log::info('Cricket: no live broadcaster camera — forwarder skipped.', [
                'match_id' => $matchId,
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
            Log::info('Cricket: match forwarder started', [
                'room_id' => $source['room_id'],
                'camera_id' => $source['camera_id'],
                'url' => $rtmpUrl,
            ]);

            return true;
        }

        Log::warning('Cricket: match forwarder start failed', [
            'status' => $res->status(),
            'body' => $res->body(),
            'url' => $rtmpUrl,
        ]);

        return false;
    }

    /**
     * Forwarder health for a match's on-air feed.
     *
     * @return array{forwarder_state: string, forwarder_error: ?string, hls_url: string}
     */
    public function healthForMatch(string $matchId, int $cameraNumber = 1): array
    {
        $url = $this->rtmpUrlFor($matchId, $cameraNumber);
        $state = 'missing';
        $error = null;

        foreach ($this->listForwarders() as $forwarder) {
            if (($forwarder['url'] ?? '') !== $url) {
                continue;
            }
            $state = (string) ($forwarder['state'] ?? 'unknown');
            $error = $forwarder['error'] ?? null;
            break;
        }

        // `running` is the engine's *intent*, not evidence: it is published as
        // soon as a pipeline object exists. Confirm it at the far end before
        // anybody acts on it, otherwise a stale `running` is self-locking —
        // `resyncMatch()` returns early, the watchdog prints `ok`, and the
        // engine's own watchdogs skip "already running", so nothing recovers.
        if ($state === 'running'
            && $this->srsIsPublishing($this->streamNameFor($matchId, $cameraNumber)) === false
        ) {
            $state = 'stale';
            $error ??= 'engine reports the forwarder running, but SRS has no active publish for this feed';
        }

        return [
            'forwarder_state' => $state,
            'forwarder_error' => $error,
            'hls_url' => $this->hlsUrlFor($matchId, $cameraNumber),
        ];
    }

    /**
     * Whether SRS is currently publishing `streamName`.
     *
     * Health has to be measured at the *far end*. The engine reports `running`
     * as soon as it has built a pipeline, and a forwarder whose publisher
     * disconnected leaves that pipeline alive but idle — no buffers reach
     * flvmux, SRS drops the feed, and the engine still says `running`. Every
     * recovery path skips such a forwarder, so the stale state self-locks and
     * the public page 404s with nothing in the logs to explain it.
     *
     * SRS's `publish.active` is the same signal the engine is trying to
     * produce, read from where the bytes actually arrive.
     *
     * @return bool|null `null` when the check cannot be made (SRS not
     *                   configured or unreachable), so callers fall back to the
     *                   engine's own state instead of guessing.
     */
    private function srsIsPublishing(string $streamName): ?bool
    {
        $base = rtrim((string) config('cricket.streaming.srs_api_url', ''), '/');
        if ($base === '') {
            return null;
        }

        try {
            $res = Http::timeout(3)->get("{$base}/api/v1/streams/");
            if (!$res->successful()) {
                return null;
            }

            $streams = $res->json('streams');
            if (!is_array($streams)) {
                return null;
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: SRS probe failed', [
                'url' => $base,
                'error' => $e->getMessage(),
            ]);

            return null;
        }

        foreach ($streams as $stream) {
            if (!is_array($stream) || ($stream['name'] ?? null) !== $streamName) {
                continue;
            }

            return ($stream['publish']['active'] ?? false) === true;
        }

        return false;
    }

    /** Stops the forwarder for a match's feed, if one exists. */
    public function stopForwarderForMatch(string $matchId, int $cameraNumber = 1): void
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return;
        }

        $rtmpUrl = $this->rtmpUrlFor($matchId, $cameraNumber);
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
                Log::info('Cricket: match forwarder stopped', ['key' => $key]);
            }
        }
    }

    /**
     * Stops every cricket forwarder on the engine.
     *
     * Used when a match ends or the tournament is torn down, so SRS stops
     * segmenting a feed nobody is watching.
     */
    public function stopAllForwarders(): void
    {
        $engineUrl = $this->engineUrl();
        if ($engineUrl === null) {
            return;
        }

        $token = $this->directorToken();

        foreach ($this->listForwarders() as $forwarder) {
            if (!str_contains((string) ($forwarder['url'] ?? ''), self::STREAM_PREFIX)) {
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
                Log::info('Cricket: forwarder stopped', ['key' => $key]);
            }
        }
    }

    /**
     * The camera the public page should receive, taken from the Studio room.
     *
     * Prefers the room's program (PGM) camera — the one the director put on
     * air — and falls back to the first live WHIP camera so a feed still
     * reaches viewers if nobody pressed PGM.
     *
     * Only `whip` cameras qualify: that is the kind the Todd Broadcaster
     * publishes, and the only kind with RTP tracks for the engine to forward.
     * A camera of any other kind has no media, and asking for a forwarder on
     * it fails with "no video stream on camera … layer ''".
     *
     * @param  array<int, array<string, mixed>>  $rooms
     * @return array{room_id: string, camera_id: string}|null
     */
    private function broadcasterCamera(string $engineUrl, string $token, array $rooms): ?array
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

            if (is_string($cameraId) && $cameraId !== '' && $this->isLiveBroadcasterCamera($cameras, $cameraId)) {
                return ['room_id' => $roomId, 'camera_id' => $cameraId];
            }

            if ($fallback === null) {
                $fallback = $this->firstLiveBroadcasterCamera($roomId, $cameras);
            }
        }

        return $fallback;
    }

    /**
     * True when this camera id is a broadcaster-published (WHIP) camera that is
     * currently live.
     *
     * `active` matters as much as `kind`. The room keeps a camera entry after
     * its publisher disconnects, so a `whip` camera can be registered while
     * carrying no media — the same ghost entry the Studio tiles retry forever
     * (409). Selecting one for the forwarder makes `add_forwarder` fail with
     * "no video stream on camera … layer ''", so the bridge never starts and
     * the public page stays dark for a match whose operator did nothing wrong.
     *
     * `room/list` computes `active` from live WHIP sessions and ingest
     * adapters, so this is the same signal `firstLiveBroadcasterCamera()`
     * already relies on.
     *
     * @param  array<int, array<string, mixed>>  $cameras
     */
    private function isLiveBroadcasterCamera(array $cameras, string $cameraId): bool
    {
        foreach ($cameras as $camera) {
            if (($camera['id'] ?? null) !== $cameraId) {
                continue;
            }

            return ($camera['kind'] ?? '') === 'whip'
                && ($camera['active'] ?? false) === true;
        }

        return false;
    }

    /**
     * @param  array<int, array<string, mixed>>  $cameras
     * @return array{room_id: string, camera_id: string}|null
     */
    private function firstLiveBroadcasterCamera(string $roomId, array $cameras): ?array
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

    /** Admin JWT for engine control-plane calls. */
    private function directorToken(): string
    {
        return $this->tokens->mint(
            role: 'admin',
            subject: 'laravel-cricket-sync',
            perms: ['studio_director'],
            ttlSeconds: 120,
        );
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
