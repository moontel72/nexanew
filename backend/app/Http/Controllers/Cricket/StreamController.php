<?php

namespace App\Http\Controllers\Cricket;

use App\Events\Cricket\CricketStreamUpdated;
use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\ManagerSessionLog;
use App\Models\Cricket\StreamEndpoint;
use Illuminate\Http\Request;
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
        }

        return response()->json(['message' => 'Stream deactivated.', 'stream' => $stream]);
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

    public function destroy(string $matchId, string $streamId): \Illuminate\Http\JsonResponse
    {
        StreamEndpoint::where('match_id', $matchId)->findOrFail($streamId)->delete();
        return response()->json(['message' => 'Stream deleted.']);
    }
}
