<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\LiveScore;
use App\Models\Cricket\ManagerSessionLog;
use App\Services\Cricket\LiveScoreService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LiveScoreController extends Controller
{
    private LiveScoreService $scoreService;

    public function __construct(LiveScoreService $scoreService)
    {
        $this->scoreService = $scoreService;
    }

    /**
     * Get current score for a match (REST fallback).
     * Uses Redis cache with DB fallback. No auth required (public endpoint).
     */
    public function show(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        // Try Redis cache first
        $cached = LiveScoreService::getCachedScore($matchId);
        if ($cached) {
            return response()->json(['score' => $cached, 'source' => 'cache']);
        }

        // Fallback to DB
        $liveScore = LiveScore::where('match_id', $matchId)->first();
        if (!$liveScore) {
            return response()->json(['message' => 'No live score available for this match.'], 404);
        }

        return response()->json(['score' => $liveScore->full_snapshot, 'source' => 'database']);
    }

    /**
     * Get full scorecard (innings + batting/bowling scorecards + live
     * score). Shared assembly lives in LiveScoreService.
     */
    public function fullScorecard(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        return response()->json($this->scoreService->fullScorecard($matchId));
    }

    /**
     * Update the score — called by Cricket Manager.
     * This is the core scoring endpoint.
     */
    public function update(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $validator = Validator::make($request->all(), [
            'runs' => 'required|integer|min:0|max:7',
            'is_wicket' => 'boolean',
            'wicket_type' => 'nullable|string|in:bowled,caught,lbw,run_out,stumped,hit_wicket',
            'dismissed_player_id' => 'nullable|uuid|exists:cricket_players,id',
            'fielder_id' => 'nullable|uuid|exists:cricket_players,id',
            'extras_type' => 'nullable|string|in:wide,no_ball,bye,leg_bye',
            'bowler_id' => 'nullable|uuid|exists:cricket_players,id',
            'batsman_id' => 'nullable|uuid|exists:cricket_players,id',
            'non_striker_id' => 'nullable|uuid|exists:cricket_players,id',
            'next_batter_id' => 'nullable|uuid|exists:cricket_players,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $ballData = $validator->validated();

        try {
            $liveScore = $this->scoreService->processBall($matchId, $ballData, $manager->id);

            // Log action
            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'match_id' => $matchId,
                'action' => 'update_score',
                'metadata' => ['ball' => $ballData],
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);

            return response()->json([
                'message' => 'Score updated.',
                'score' => $liveScore->full_snapshot,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    /**
     * Undo the last ball.
     */
    public function undoLastBall(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        try {
            $liveScore = $this->scoreService->undoLastBall($matchId, $manager->id);

            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'match_id' => $matchId,
                'action' => 'update_score',
                'metadata' => ['action' => 'undo_last_ball'],
                'ip_address' => $request->ip(),
            ]);

            return response()->json([
                'message' => 'Last ball undone.',
                'score' => $liveScore->full_snapshot,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    /**
     * Phase 2 — recent deliveries of the current innings (newest first),
     * each carrying its unique ball_id for the correction interface.
     */
    public function deliveries(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        CricketManagerAuth::manager($request);

        $limit = max(1, min(100, (int) $request->query('limit', 50)));

        return response()->json([
            'deliveries' => $this->scoreService->listDeliveries($matchId, $limit),
        ]);
    }

    /**
     * Phase 2 — edit a past delivery by ball_id and recompute everything
     * forward from the delivery log.
     */
    public function editDelivery(Request $request, string $matchId, string $ballId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $validator = Validator::make($request->all(), [
            'runs' => 'nullable|integer|min:0|max:7',
            'is_wicket' => 'nullable|boolean',
            'wicket_type' => 'nullable|string|in:bowled,caught,lbw,run_out,stumped,hit_wicket',
            'dismissed_player_id' => 'nullable|uuid|exists:cricket_players,id',
            'fielder_id' => 'nullable|uuid|exists:cricket_players,id',
            'extras_type' => 'nullable|string|in:wide,no_ball,bye,leg_bye',
            'bowler_id' => 'nullable|uuid|exists:cricket_players,id',
            'batsman_id' => 'nullable|uuid|exists:cricket_players,id',
            'non_striker_id' => 'nullable|uuid|exists:cricket_players,id',
            'next_batter_id' => 'nullable|uuid|exists:cricket_players,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $liveScore = $this->scoreService->editDelivery(
                $matchId,
                $ballId,
                $validator->validated(),
                $manager->id
            );

            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'match_id' => $matchId,
                'action' => 'update_score',
                'metadata' => [
                    'action' => 'edit_ball',
                    'ball_id' => $ballId,
                    'changes' => $validator->validated(),
                ],
                'ip_address' => $request->ip(),
            ]);

            return response()->json([
                'message' => 'Ball updated and score recomputed.',
                'score' => $liveScore->full_snapshot,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    /**
     * Phase 2 — delete a past delivery by ball_id and recompute everything
     * forward from the remaining delivery log.
     */
    public function deleteDelivery(Request $request, string $matchId, string $ballId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        try {
            $liveScore = $this->scoreService->deleteDelivery($matchId, $ballId, $manager->id);

            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'match_id' => $matchId,
                'action' => 'update_score',
                'metadata' => [
                    'action' => 'delete_ball',
                    'ball_id' => $ballId,
                ],
                'ip_address' => $request->ip(),
            ]);

            return response()->json([
                'message' => 'Ball deleted and score recomputed.',
                'score' => $liveScore->full_snapshot,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}
