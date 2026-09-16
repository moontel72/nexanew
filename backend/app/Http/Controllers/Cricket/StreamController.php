<?php

namespace App\Http\Controllers\Cricket;

use App\Events\Cricket\CricketStreamUpdated;
use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\ManagerSessionLog;
use App\Models\Cricket\StreamEndpoint;
use App\Services\Cricket\CricketStreamSyncService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class StreamController extends Controller
{
    public function __construct(
        private readonly CricketStreamSyncService $sync,
    ) {
    }
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
        $this->sync->resyncStream($stream);

        // NOTE: the Studio camera is NOT registered here.
        //
        // `syncStudioCamera` used to add a second camera to the Studio room,
        // keyed `cricket-{stream_id}` with `kind: "hls"`. The broadcaster
        // already publishes the same physical feed under its own camera id
        // (`CAM-03`/`CAM-04`), so the room ended up with two entries for one
        // camera: the real WHIP tile and a phantom HLS tile. The multimedia
        // grid renders one pane per registered camera, so two entries split
        // the player 50/50 — and because the phantom HLS playlist only exists
        // while the PGM forwarder is healthy, its pane sat on "loading HLS
        // stream…" forever.
        //
        // Video flows broadcaster → engine → (RTMP) → SRS → HLS → public
        // page. The Studio tile reads the broadcaster's own WHIP camera, so
        // no second registration is needed. `removeGhostStudioCameras` clears
        // any that earlier runs left behind.
        $this->removeGhostStudioCameras($stream);

        return response()->json(['message' => 'Stream activated.', 'stream' => $stream]);
    }

    /**
     * Removes every ghost `cricket-*` camera from the Studio rooms.
     *
     * Delegates to the sync service so the engine credentials live in one
     * place. Never throws — Studio cleanup must not block going on air.
     */
    private function removeGhostStudioCameras(StreamEndpoint $stream): void
    {
        $this->sync->removeGhostCameras();
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
     * This is idempotent: a forwarder that is already running for the same
     * URL is left untouched.
     */
    public function resync(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $streams = StreamEndpoint::where('match_id', $matchId)
            ->where('stream_status', 'live')
            ->orderBy('camera_number')
            ->get();

        $repaired = [];
        foreach ($streams as $live) {
            if ($this->sync->resyncStream($live)) {
                $repaired[] = $live->id;
            }
        }

        return response()->json([
            'message' => 'Streams re-synced.',
            'streams' => $streams->pluck('id'),
            'forwarders_running' => $repaired,
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

        $report = $streams->map(function (StreamEndpoint $stream) {
            $health = $this->sync->healthFor($stream);

            return [
                'camera_number' => $stream->camera_number,
                'camera_label' => $stream->camera_label,
                'stream_key' => $stream->rtmp_stream_key,
                'status' => $stream->stream_status,
                'hls_playlist_url' => $stream->hls_playlist_url,
                'forwarder_state' => $health['forwarder_state'],
                'forwarder_error' => $health['forwarder_error'],
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
     * Stop every cricket forwarder on the engine. Called when the last live
     * stream for a match is deactivated, so SRS stops segmenting a feed
     * nobody is watching.
     */
    private function stopPgmForwarder(): void
    {
        $engineUrl = rtrim((string) config('services.media_engine.url', ''), '/');
        if ($engineUrl === '') {
            return;
        }

        try {
            $token = app(\App\Services\MediaEngineTokenService::class)->mint(
                role: 'admin',
                subject: 'laravel-stream-controller',
                perms: ['studio_director'],
                ttlSeconds: 120,
            );

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
                if (!is_string($key) || $key === '') {
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

    public function destroy(string $matchId, string $streamId): \Illuminate\Http\JsonResponse
    {
        StreamEndpoint::where('match_id', $matchId)->findOrFail($streamId)->delete();
        return response()->json(['message' => 'Stream deleted.']);
    }
}
