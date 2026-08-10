<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Services\Cricket\ReplayService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ReplayController extends Controller
{
    private ReplayService $replayService;

    public function __construct(ReplayService $replayService)
    {
        $this->replayService = $replayService;
    }

    // ── Internal: Record chunk from Rust sidecar ────────────────

    public function recordChunk(Request $request): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'match_id' => 'required|uuid|exists:cricket_matches,id',
            'chunk_counter' => 'required|integer|min:1',
            'file_path' => 'required|string',
            'start_timestamp' => 'required|date',
            'end_timestamp' => 'required|date',
            'duration_seconds' => 'integer|min:1|max:600',
            'file_size_bytes' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $chunk = $this->replayService->recordChunk($validator->validated());

        return response()->json([
            'message' => 'Chunk recorded.',
            'chunk' => $chunk,
        ], 201);
    }

    // ── Manager: Mark replay event ──────────────────────────────

    public function markEvent(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $validator = Validator::make($request->all(), [
            'event_type' => 'required|string|in:wicket,boundary,appeal,review,custom',
            'frame_timestamp' => 'required|integer|min:0',
            'annotation' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $event = $this->replayService->markEvent(
            $matchId,
            $validator->validated(),
            $manager->id
        );

        return response()->json([
            'message' => 'Event marked.',
            'event' => $event,
        ], 201);
    }

    // ── Manager: Annotate event ─────────────────────────────────

    public function annotate(Request $request, string $eventId): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'annotation' => 'required|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $event = $this->replayService->annotateEvent(
            $eventId,
            $validator->validated()['annotation']
        );

        return response()->json([
            'message' => 'Event annotated.',
            'event' => $event,
        ]);
    }

    // ── Manager: List events ────────────────────────────────────

    public function listEvents(string $matchId): \Illuminate\Http\JsonResponse
    {
        $events = $this->replayService->listEvents($matchId);

        return response()->json(['events' => $events]);
    }

    // ── Manager: Create trimmed clip ────────────────────────────

    public function createClip(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'event_id' => 'required|uuid|exists:cricket_replay_events,id',
            'buffer_before_ms' => 'integer|min:1000|max:30000',
            'buffer_after_ms' => 'integer|min:1000|max:30000',
            'playback_speed' => 'numeric|min:0.25|max:2.0',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $clip = $this->replayService->createClip($matchId, $validator->validated());

        return response()->json([
            'message' => 'Clip creation requested.',
            'clip' => $clip,
        ], 201);
    }

    // ── Manager: Publish clip ───────────────────────────────────

    public function publishClip(string $clipId): \Illuminate\Http\JsonResponse
    {
        $clip = $this->replayService->publishClip($clipId);

        return response()->json([
            'message' => 'Clip published for public viewing.',
            'clip' => $clip,
        ]);
    }

    // ── Manager: Delete clip ────────────────────────────────────

    public function deleteClip(string $clipId): \Illuminate\Http\JsonResponse
    {
        $this->replayService->deleteClip($clipId);

        return response()->json(['message' => 'Clip deleted.']);
    }

    // ── Public: List published replays ──────────────────────────

    public function publicReplays(string $matchId): \Illuminate\Http\JsonResponse
    {
        $replays = $this->replayService->getPublicReplays($matchId);

        return response()->json(['replays' => $replays]);
    }

    // ── Public: Get replay stream URL ───────────────────────────

    public function publicStream(string $clipId): \Illuminate\Http\JsonResponse
    {
        $url = $this->replayService->getClipStreamUrl($clipId);

        if (!$url) {
            return response()->json(['message' => 'Clip not available.'], 404);
        }

        return response()->json(['stream_url' => $url]);
    }
}
