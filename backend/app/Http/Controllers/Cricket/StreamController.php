<?php

namespace App\Http\Controllers\Cricket;

use App\Events\Cricket\CricketStreamUpdated;
use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\ManagerSessionLog;
use App\Models\Cricket\StreamEndpoint;
use App\Services\MediaEngineTokenService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class StreamController extends Controller
{
    public function index(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $streams = StreamEndpoint::where('match_id', $matchId)
            ->orderBy('camera_number')
            ->get();

        return response()->json($streams);
    }

    public function store(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        // Ensure match exists
        \App\Models\Cricket\MatchModel::findOrFail($matchId);

        $currentCount = StreamEndpoint::where('match_id', $matchId)->count();
        if ($currentCount >= 5) {
            return response()->json(['message' => 'Maximum 5 cameras per match.'], 422);
        }

        $validator = Validator::make($request->all(), [
            'camera_label' => 'required|string|max:100',
            'camera_number' => 'required|integer|min:1|max:5',
            'rtmp_ingest_url' => 'nullable|url|max:500',
            'rtmp_stream_key' => 'nullable|string|max:100',
            'hls_playlist_url' => 'nullable|url|max:500',
            'is_primary' => 'boolean',
            'failover_priority' => 'integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Generate stream key if not provided
        $data = $validator->validated();
        if (empty($data['rtmp_stream_key'])) {
            $data['rtmp_stream_key'] = 'cricket_match_' . $matchId . '_cam' . $data['camera_number'] . '_' . \Illuminate\Support\Str::random(12);
        }

        // Auto-derive streaming endpoints from config so the public player
        // always receives a playable HLS URL (env-driven, no hardcoding).
        $data['rtmp_ingest_url'] = $data['rtmp_ingest_url']
            ?? config('cricket.streaming.rtmp_ingest_url');
        $data['hls_playlist_url'] = $data['hls_playlist_url']
            ?? rtrim((string) config('cricket.streaming.hls_base_url'), '/')
                . '/' . $data['rtmp_stream_key'] . '.m3u8';

        // Explicit in-memory defaults — Eloquent does not hydrate DB column
        // defaults into the instance after insert, and the client parses
        // these fields as non-null strings/ints.
        $data['stream_status'] = 'offline';
        $data['failover_priority'] = $data['failover_priority'] ?? 0;

        $stream = StreamEndpoint::create(array_merge($data, ['match_id' => $matchId]));

        return response()->json($stream, 201);
    }

    public function update(Request $request, string $matchId, string $streamId): \Illuminate\Http\JsonResponse
    {
        $stream = StreamEndpoint::where('match_id', $matchId)->findOrFail($streamId);

        $validator = Validator::make($request->all(), [
            'camera_label' => 'sometimes|string|max:100',
            'rtmp_ingest_url' => 'nullable|url|max:500',
            'hls_playlist_url' => 'nullable|url|max:500',
            'stream_status' => 'sometimes|in:offline,connecting,live,error,standby',
            'is_primary' => 'boolean',
            'failover_priority' => 'integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $stream->update($validator->validated());

        if ($request->stream_status === 'live') {
            $stream->last_live_at = now();
            $stream->save();
        }

        return response()->json($stream);
    }

    public function activate(Request $request, string $matchId, string $streamId): \Illuminate\Http\JsonResponse
    {
        $stream = StreamEndpoint::where('match_id', $matchId)->findOrFail($streamId);

        $manager = CricketManagerAuth::manager($request);
        if (!$manager) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        // Director-style switching: exactly ONE live (program) stream per
        // match. Activating this camera deactivates every other camera, so
        // the public endpoint always resolves a single active feed.
        StreamEndpoint::where('match_id', $matchId)
            ->where('stream_status', 'live')
            ->where('id', '!=', $streamId)
            ->update(['stream_status' => 'offline']);

        $stream->stream_status = 'live';
        $stream->last_activated_by_manager_id = $manager->id;
        $stream->last_live_at = now();
        $stream->save();

        ManagerSessionLog::create([
            'cricket_manager_id' => $manager->id,
            'match_id' => $matchId,
            'action' => 'update_stream',
            'metadata' => ['stream_id' => $streamId, 'status' => 'live', 'camera' => $stream->camera_label],
            'ip_address' => $request->ip(),
        ]);

        $this->broadcastStreamChange($matchId, [
            'id' => $stream->id,
            'camera_label' => $stream->camera_label,
            'camera_number' => $stream->camera_number,
            'hls_playlist_url' => $stream->hls_playlist_url,
            'is_primary' => $stream->is_primary,
        ]);

        // Auto-wire the engine's PGM forwarder to SRS so the public
        // player at cricket.traceodd.com receives HLS segments.
        $this->startPgmForwarder($stream);

        // Register/refresh the on-air camera in the Studio room with its
        // HLS manifest URL. Without this the Studio tile has no source to
        // render and falls back to the WHEP path — which is empty for an
        // RTMP/SRS camera, leaving the preview black forever.
        $this->syncStudioCamera($stream);

        return response()->json(['message' => 'Stream activated.', 'stream' => $stream]);
    }

    public function deactivate(Request $request, string $matchId, string $streamId): \Illuminate\Http\JsonResponse
    {
        $stream = StreamEndpoint::where('match_id', $matchId)->findOrFail($streamId);
        $stream->stream_status = 'offline';
        $stream->save();

        // Announce only when no other camera is live — the public player
        // then switches to its offline state.
        $stillLive = StreamEndpoint::where('match_id', $matchId)
            ->where('stream_status', 'live')
            ->exists();
        if (!$stillLive) {
            $this->broadcastStreamChange($matchId, null);
            // No other camera is live — stop the PGM forwarder to SRS.
            $this->stopPgmForwarder();
        }

        return response()->json(['message' => 'Stream deactivated.', 'stream' => $stream]);
    }

    /**
     * Re-assert the engine→SRS forwarder for every stream already marked
     * live in this match.
     *
     * `activate()` wires the forwarder once, at the moment a director
     * switches a camera on air. That single shot is fragile: an engine
     * restart, a GStreamer hiccup, or a DB/state wipe leaves the stream
     * row still marked `live` while nothing is writing SRS segments — the
     * public player then sits on a permanent HLS 404 with no way to
     * recover short of deactivating and re-activating the camera.
     *
     * This is idempotent: `startPgmForwarder` skips a forwarder that is
     * already running for the same URL.
     */
    public function resync(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $streams = StreamEndpoint::where('match_id', $matchId)
            ->where('stream_status', 'live')
            ->orderBy('camera_number')
            ->get();

        foreach ($streams as $live) {
            $this->startPgmForwarder($live);
        }

        return response()->json([
            'message' => 'Streams re-synced.',
            'streams' => $streams->pluck('id'),
        ]);
    }

    /**
     * Camera stream health for a match.
     *
     * Answers the question the console cannot answer on its own: *is the
     * engine actually forwarding the on-air camera to SRS right now?*
     * The public HLS URL only exists once that forwarder is running, so a
     * 404 on `/hls/live/{key}.m3u8` is almost always a dead forwarder
     * rather than a playback problem.
     *
     * Reports, per camera:
     *   - `status`          — the DB stream row state
     *   - `forwarder_state` — running | failed | missing | unreachable
     *   - `forwarder_error` — the engine's reason when it failed
     */
    public function health(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $streams = StreamEndpoint::where('match_id', $matchId)
            ->orderBy('camera_number')
            ->get();

        $forwarders = $this->engineForwarders();

        $report = $streams->map(function (StreamEndpoint $stream) use ($forwarders) {
            $url = rtrim((string) ($stream->rtmp_ingest_url
                ?: config('cricket.streaming.rtmp_ingest_url')), '/') . '/' . $stream->rtmp_stream_key;

            $match = null;
            foreach ($forwarders as $fwd) {
                if (($fwd['url'] ?? '') === $url) {
                    $match = $fwd;
                    break;
                }
            }

            return [
                'camera_number' => $stream->camera_number,
                'camera_label' => $stream->camera_label,
                'stream_key' => $stream->rtmp_stream_key,
                'status' => $stream->stream_status,
                'hls_playlist_url' => $stream->hls_playlist_url,
                'forwarder_state' => $match === null
                    ? 'missing'
                    : ($match['state'] ?? 'unknown'),
                'forwarder_error' => $match['error'] ?? null,
            ];
        });

        $live = $streams->firstWhere('stream_status', 'live');
        $liveEntry = $live
            ? $report->firstWhere('camera_number', $live->camera_number)
            : null;

        // The public player is only actually watchable when the on-air
        // camera has a *running* forwarder writing SRS segments.
        $onAir = $liveEntry['forwarder_state'] ?? null;

        return response()->json([
            'match_id' => $matchId,
            'on_air' => $liveEntry,
            'streams' => $report->values(),
            'healthy' => $onAir === 'running',
        ]);
    }

    /**
     * Fetch the engine's forwarder list, or an empty array when the engine
     * is unreachable. Never throws — this is a diagnostic endpoint.
     *
     * @return array<int, array<string, mixed>>
     */
    private function engineForwarders(): array
    {
        try {
            $engineUrl = rtrim((string) config('services.media_engine.url', ''), '/');
            if ($engineUrl === '') {
                return [];
            }

            $list = Http::timeout(5)
                ->withToken($this->mintDirectorToken())
                ->get("{$engineUrl}/api/v1/forward/list")
                ->json();

            return is_array($list) ? $list : [];
        } catch (\Throwable $e) {
            Log::warning('Cricket: forwarder list probe failed', [
                'error' => $e->getMessage(),
            ]);

            return [];
        }
    }

    /**
     * Register (or refresh) the cricket camera inside the Studio room.
     *
     * Cricket cameras do not ingest into the engine over WHIP: OBS/RTMP
     * pushes to SRS and the engine fans the on-air camera back out to
     * SRS as HLS. The Studio multiviewer therefore plays these cameras
     * from the HLS manifest, and `hls_url` is what selects that path
     * (`MultiviewTile` uses HLS whenever `hls_url` is set).
     *
     * Cameras are addressed by a stable id derived from the DB row, so
     * re-activating a camera updates the same entry instead of piling up
     * duplicates every time a director switches source.
     */
    private function syncStudioCamera(StreamEndpoint $stream): void
    {
        try {
            $engineUrl = rtrim((string) config('services.media_engine.url', ''), '/');
            if ($engineUrl === '') {
                return;
            }

            $hlsUrl = trim((string) $stream->hls_playlist_url);
            if ($hlsUrl === '') {
                Log::info('Cricket: stream has no HLS URL — Studio camera sync skipped.', [
                    'stream_id' => $stream->id,
                ]);

                return;
            }

            $token = $this->mintDirectorToken();

            $rooms = Http::timeout(5)
                ->withToken($token)
                ->get("{$engineUrl}/api/v1/room/list")
                ->json();

            if (!is_array($rooms) || empty($rooms)) {
                Log::info('Cricket: no active Studio room — camera sync skipped.');

                return;
            }

            $cameraId = self::cameraIdFor($stream);
            $label = $stream->camera_label ?: ('Cam ' . $stream->camera_number);

            foreach ($rooms as $room) {
                $roomId = $room['id'] ?? null;
                if (!is_string($roomId) || $roomId === '') {
                    continue;
                }

                // Replace the camera entry wholesale: `hls_url` is the
                // field that decides HLS vs WHEP, so both kind and URL
                // must move together.
                $payload = [
                    'id' => $cameraId,
                    'label' => $label,
                    'kind' => 'hls',
                    'group' => 'cricket',
                    'hls_url' => $hlsUrl,
                ];

                $exists = false;
                foreach ($room['cameras'] ?? [] as $camera) {
                    if (($camera['id'] ?? null) === $cameraId) {
                        $exists = true;
                        break;
                    }
                }

                if ($exists) {
                    $res = Http::timeout(5)
                        ->withToken($token)
                        ->withHeaders(['Content-Type' => 'application/json'])
                        ->put("{$engineUrl}/api/v1/room/{$roomId}/camera/{$cameraId}", [
                            'label' => $label,
                            'kind' => 'hls',
                            'group' => 'cricket',
                            'hls_url' => $hlsUrl,
                        ]);
                } else {
                    $res = Http::timeout(5)
                        ->withToken($token)
                        ->withHeaders(['Content-Type' => 'application/json'])
                        ->post("{$engineUrl}/api/v1/room/{$roomId}/camera", $payload);
                }

                if (! $res->successful()) {
                    Log::warning('Cricket: Studio camera sync failed', [
                        'room_id' => $roomId,
                        'camera_id' => $cameraId,
                        'status' => $res->status(),
                        'body' => $res->body(),
                    ]);
                }
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: Studio camera sync error (non-critical)', [
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Stable engine camera id for a cricket stream row.
     *
     * Derived from the stream's UUID so it survives label/camera-number
     * edits and never collides with a hand-added Studio camera.
     */
    public static function cameraIdFor(StreamEndpoint $stream): string
    {
        return 'cricket-' . $stream->id;
    }

    /**
     * Push the new program-feed context to public viewers via Reverb.
     * Broadcast failures are non-critical and must never block switching.
     */
    private function broadcastStreamChange(string $matchId, ?array $activeStream): void
    {
        try {
            CricketStreamUpdated::dispatch($matchId, $activeStream);
        } catch (\Throwable $e) {
            Log::warning('Cricket: stream broadcast failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    // ─────────────────────────────────────────────────────────────
    //  Engine PGM → SRS auto-forwarder
    // ─────────────────────────────────────────────────────────────

    /**
     * Start the engine's forwarder to SRS so HLS segments appear at
     * /hls/live/{key}.m3u8 for the public player.
     *
     * Non-blocking: any failure is logged but never prevents the
     * stream activation from succeeding.
     */
    private function startPgmForwarder(StreamEndpoint $stream): void
    {
        try {
            $engineUrl = rtrim((string) config('services.media_engine.url', ''), '/');
            if ($engineUrl === '') {
                return;
            }

            $token = $this->mintDirectorToken();

            // Discover the active Studio room.
            $rooms = Http::timeout(5)
                ->withToken($token)
                ->get("{$engineUrl}/api/v1/room/list")
                ->json();

            if (!is_array($rooms) || empty($rooms)) {
                Log::info('Cricket: no active Studio room — PGM forwarder skipped.');
                return;
            }

            // Resolve the room and camera that are actually on air.
            //
            // The composite (`source: program`) is fed by the GStreamer mixer,
            // which still does not build reliably on this host, and when it is
            // missing the engine answers 409 and nothing reaches SRS — the
            // public portal then only ever shows its "Stream starting soon"
            // fallback. Fanning the on-air camera out directly puts the match
            // on air now; the composite can be switched back on once the mixer
            // is fixed.
            $source = $this->programSource($engineUrl, $token, $rooms);
            if ($source === null) {
                Log::info('Cricket: no on-air program camera — forwarder skipped.');
                return;
            }
            $roomId = $source['room_id'];
            $cameraId = $source['camera_id'];

            // Build the full RTMP URL: ingest base + /{stream_key}
            $rtmpBase = $stream->rtmp_ingest_url
                ?: config('cricket.streaming.rtmp_ingest_url');
            $rtmpUrl = rtrim((string) $rtmpBase, '/') . '/' . $stream->rtmp_stream_key;

            // Skip if a forwarder to this exact URL is already running.
            $existing = Http::timeout(5)
                ->withToken($token)
                ->get("{$engineUrl}/api/v1/forward/list")
                ->json();

            if (is_array($existing)) {
                foreach ($existing as $fwd) {
                    if (($fwd['url'] ?? '') === $rtmpUrl
                        && ($fwd['state'] ?? '') === 'running') {
                        Log::info('Cricket: PGM forwarder already running', ['url' => $rtmpUrl]);
                        return;
                    }
                }
            }

            $res = Http::timeout(10)
                ->withToken($token)
                ->withHeaders(['Content-Type' => 'application/json'])
                ->post("{$engineUrl}/api/v1/room/{$roomId}/forward", [
                    'camera_id' => $cameraId,
                    'source' => 'camera',
                    'kind' => 'rtmp',
                    'url' => $rtmpUrl,
                    'bitrate_kbps' => (int) config('cricket.streaming.forwarder_bitrate_kbps', 4000),
                ]);

            if ($res->successful()) {
                Log::info('Cricket: PGM forwarder started', [
                    'room_id' => $roomId,
                    'url' => $rtmpUrl,
                ]);
            } else {
                Log::warning('Cricket: PGM forwarder start failed', [
                    'status' => $res->status(),
                    'body' => $res->body(),
                ]);
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: PGM forwarder error (non-critical)', [
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Returns the id of the first room with a program (PGM) source set, or
     * null when no room is on air. Keeps the forwarder bound to the Studio's
     * active room instead of an arbitrary entry in the room list.
     *
     * @param  array<int, array<string, mixed>>  $rooms
     */
    private function programSource(string $engineUrl, string $token, array $rooms): ?array
    {
        foreach ($rooms as $room) {
            $id = $room['id'] ?? null;
            if (!is_string($id) || $id === '') {
                continue;
            }

            try {
                $res = Http::timeout(2)
                    ->withToken($token)
                    ->get("{$engineUrl}/api/v1/program/" . urlencode($id));

                if (!$res->successful()) {
                    continue;
                }

                $program = $res->json();
                $camera = is_array($program) ? ($program['camera_id'] ?? null) : null;

                if (!is_string($camera) || $camera === '') {
                    continue;
                }

                return ['room_id' => $id, 'camera_id' => $camera];
            } catch (\Throwable $e) {
                // Probe failures are non-critical — try the next room.
            }
        }

        return null;
    }

    /**
     * Stop any running PGM forwarder on the engine. Called when the
     * last live stream for a match is deactivated.
     */
    private function stopPgmForwarder(): void
    {
        try {
            $engineUrl = rtrim((string) config('services.media_engine.url', ''), '/');
            if ($engineUrl === '') {
                return;
            }

            $token = $this->mintDirectorToken();

            $forwarders = Http::timeout(5)
                ->withToken($token)
                ->get("{$engineUrl}/api/v1/forward/list")
                ->json();

            if (!is_array($forwarders)) {
                return;
            }

            foreach ($forwarders as $fwd) {
                // Match on the cricket stream key rather than the source: the
                // auto-forwarder may be fanned out from the program composite
                // or straight from the on-air camera.
                if (!str_contains((string) ($fwd['url'] ?? ''), 'cricket_match_')) {
                    continue;
                }
                $key = $fwd['key'] ?? '';
                if ($key === '') {
                    continue;
                }
                $res = Http::timeout(5)
                    ->withToken($token)
                    ->delete("{$engineUrl}/api/v1/forward/" . urlencode($key));

                if ($res->successful()) {
                    Log::info('Cricket: PGM forwarder stopped', ['key' => $key]);
                }
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: PGM forwarder stop error (non-critical)', [
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Mint a short-lived admin JWT with studio_director permission
     * for server-to-server calls to the Rust media engine.
     */
    private function mintDirectorToken(): string
    {
        return app(MediaEngineTokenService::class)->mint(
            role: 'admin',
            subject: 'laravel-stream-controller',
            perms: ['studio_director'],
            ttlSeconds: 120,
        );
    }

    public function destroy(string $matchId, string $streamId): \Illuminate\Http\JsonResponse
    {
        StreamEndpoint::where('match_id', $matchId)->findOrFail($streamId)->delete();
        return response()->json(['message' => 'Stream deleted.']);
    }
}
