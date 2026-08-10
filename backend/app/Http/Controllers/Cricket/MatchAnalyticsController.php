<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Services\Cricket\MatchAnalyticsService;
use Illuminate\Http\Request;

class MatchAnalyticsController extends Controller
{
    private MatchAnalyticsService $analyticsService;

    public function __construct(MatchAnalyticsService $analyticsService)
    {
        $this->analyticsService = $analyticsService;
    }

    /**
     * Get wagon wheel data for a match (public).
     * Optional: ?batsman_id=UUID to filter by batsman.
     * Optional: ?innings=1 or innings=2 to filter by innings.
     */
    public function wagonWheel(string $matchId, Request $request): \Illuminate\Http\JsonResponse
    {
        $batsmanId = $request->query('batsman_id');

        $shots = $this->analyticsService->getWagonWheel($matchId, $batsmanId);

        return response()->json([
            'match_id' => $matchId,
            'batsman_id' => $batsmanId,
            'total_shots' => count($shots),
            'shots' => $shots,
        ]);
    }

    /**
     * Get run distribution breakdown for a match (public).
     */
    public function runDistribution(string $matchId): \Illuminate\Http\JsonResponse
    {
        $distribution = $this->analyticsService->getRunDistribution($matchId);

        $total = $distribution['total_runs'];
        $dotPercent = $distribution['total_balls'] > 0
            ? round(($distribution['dot_balls'] / $distribution['total_balls']) * 100, 1)
            : 0;

        return response()->json([
            'match_id' => $matchId,
            'distribution' => $distribution,
            'dot_ball_percentage' => $dotPercent,
        ]);
    }

    /**
     * Get off-side vs leg-side split (public).
     */
    public function sideSplit(string $matchId): \Illuminate\Http\JsonResponse
    {
        $split = $this->analyticsService->getSideSplit($matchId);

        return response()->json([
            'match_id' => $matchId,
            'side_split' => $split,
        ]);
    }

    /**
     * Get conceded runs breakdown for a match/bowler (public).
     * Optional: ?bowler_id=UUID to filter by bowler.
     */
    public function concededRuns(string $matchId, Request $request): \Illuminate\Http\JsonResponse
    {
        $bowlerId = $request->query('bowler_id');

        $breakdown = $this->analyticsService->getConcededRunsBreakdown($matchId, $bowlerId);

        return response()->json([
            'match_id' => $matchId,
            'bowler_id' => $bowlerId,
            ...$breakdown,
        ]);
    }

    /**
     * Get partnership data for a match (public).
     */
    public function partnerships(string $matchId): \Illuminate\Http\JsonResponse
    {
        $partnerships = $this->analyticsService->getPartnerships($matchId);

        return response()->json([
            'match_id' => $matchId,
            'partnerships' => $partnerships,
        ]);
    }
}
