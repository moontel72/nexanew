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
            'retired_player_id' => 'nullable|uuid|exists:cricket_players,id',
            'shot_direction' => 'nullable|integer|between:0,359',
            'shot_x' => 'nullable|numeric|between:-1,1',
            'shot_y' => 'nullable|numeric|between:-1,1',
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
                'user_agent' => $request->userAgent(),
            ]);

            return response()->json([
                'message' => 'Ball deleted and score recomputed.',
                'score' => $liveScore->full_snapshot,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    /**
     * Canonical live-state feed consumed by the Rust media engine
     * (`GET /api/v1/cricket/live/{matchId}`).
     *
     * The engine uses this as the *refresh* source: Reverb push events
     * (`score.updated` etc.) act as the change signal, and the engine
     * pulls the authoritative snapshot from here. Kept public on purpose —
     * it exposes the same broadcast-grade state as the public score feed,
     * just shaped for the engine's ball-by-ball contract.
     *
     * Returns 404 when no score exists yet (match never scored).
     */
    public function liveForEngine(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $snapshot = LiveScoreService::getCachedScore($matchId);

        if (!$snapshot) {
            $snapshot = LiveScore::where('match_id', $matchId)
                ->first()
                ?->full_snapshot;
        }

        if (!$snapshot) {
            return response()->json(
                ['message' => 'No live score available for this match.'],
                404
            );
        }

        return response()->json($this->mapToEngineFeed($matchId, $snapshot));
    }

    /**
     * Maps the full_snapshot into the media engine's `ManagerResponse`
     * shape: `{ match_id, innings: { ... } }` (see Rust `ManagerInnings`).
     */
    private function mapToEngineFeed(string $matchId, array $snapshot): array
    {
        [$runs, $wickets] = $this->splitScoreString($snapshot['score'] ?? '0/0');
        $balls = $this->ballsFromOvers((float) ($snapshot['overs'] ?? 0.0));

        $striker = $this->playerName($snapshot['current']['striker'] ?? null);
        $nonStriker = $this->playerName($snapshot['current']['non_striker'] ?? null);
        $bowler = $this->playerName($snapshot['current']['bowler'] ?? null);

        $recentBalls = collect($snapshot['recent_balls'] ?? [])
            ->map(fn ($ball) => [
                'result' => $this->describeBall((array) $ball),
                'zone' => $ball['shot_zone'] ?? null,
                'direction' => $ball['shot_direction'] ?? null,
            ])
            ->values()
            ->all();

        return [
            'match_id' => $matchId,
            'innings' => [
                'batting_team' => $snapshot['batting_team_name'] ?? null,
                'bowling_team' => $snapshot['bowling_team_name'] ?? null,
                'score' => $runs,
                'wickets' => $wickets,
                'balls' => $balls,
                'batter_on_strike' => $striker,
                'batter_non_strike' => $nonStriker,
                'bowler' => $bowler,
                'recent_balls' => $recentBalls,
                'last_shot' => $snapshot['last_shot'] ?? null,
                'milestone' => $snapshot['milestone'] ?? null,
            ],
        ];
    }

    /** "123/4" → [123, 4]. */
    private function splitScoreString(string $score): array
    {
        $parts = explode('/', $score, 2);

        return [(int) ($parts[0] ?? 0), (int) ($parts[1] ?? 0)];
    }

    /** Overs notation (12.3 = 12 overs + 3 balls) → total legal balls. */
    private function ballsFromOvers(float $overs): int
    {
        $whole = (int) floor($overs);
        $frac = (int) round(($overs - $whole) * 10);

        return ($whole * 6) + min(max($frac, 0), 5);
    }

    private function playerName(mixed $entry): ?string
    {
        if (!is_array($entry)) {
            return null;
        }

        return $entry['player_name']
            ?? $entry['name']
            ?? $entry['batter_name']
            ?? $entry['bowler_name']
            ?? null;
    }

    /** Ball → short display string, mirroring the service `describeBall`. */
    private function describeBall(array $ball): string
    {
        if (!empty($ball['is_wicket'])) {
            return 'W';
        }
        $extras = $ball['extras_type'] ?? null;
        $runs = (int) ($ball['runs'] ?? 0);

        return match ($extras) {
            'wide' => $runs > 0 ? "WD+{$runs}" : 'WD',
            'no_ball' => $runs > 0 ? "NB+{$runs}" : 'NB',
            'bye' => "{$runs}B",
            'leg_bye' => "{$runs}LB",
            default => match ($runs) {
                0 => '0',
                4 => '4',
                6 => '6',
                default => (string) $runs,
            },
        };
    }
}
