<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Tournament;
use App\Services\Cricket\PointsTableService;

class PointsTableController extends Controller
{
    private PointsTableService $pointsService;

    public function __construct(PointsTableService $pointsService)
    {
        $this->pointsService = $pointsService;
    }

    /**
     * Get standings for a tournament (public).
     */
    public function standings(string $tournamentId): \Illuminate\Http\JsonResponse
    {
        $standings = $this->pointsService->getStandings($tournamentId);

        if (empty($standings)) {
            return response()->json([
                'message' => 'No standings computed yet.',
                'standings' => [],
            ]);
        }

        return response()->json(['standings' => $standings]);
    }

    /**
     * Recompute standings (admin trigger).
     */
    public function recompute(string $tournamentId): \Illuminate\Http\JsonResponse
    {
        $standings = $this->pointsService->recomputeForTournament($tournamentId);

        return response()->json([
            'message' => 'Points table recomputed.',
            'standings' => $standings,
        ]);
    }

    /**
     * Get top performers for a tournament (public).
     * Returns most runs and most wickets across all matches.
     *
     * Uses PostgreSQL jsonb_array_elements for O(deliveries) single-query
     * aggregation instead of loading all deliveries into PHP memory.
     * Results cached in Redis for 60 seconds.
     */
    public function topPerformers(string $tournamentId): \Illuminate\Http\JsonResponse
    {
        $cacheKey = "cricket:tournament:{$tournamentId}:top_performers";

        try {
            $cached = \Illuminate\Support\Facades\Redis::get($cacheKey);
            if ($cached) {
                return response()->json(json_decode($cached, true));
            }
        } catch (\Throwable) {
            // Redis unavailable — compute live
        }

        // Single efficient query: unnest JSONB deliveries, aggregate in DB
        $topBatsmen = DB::table('cricket_innings as i')
            ->join('cricket_matches as m', 'm.id', '=', 'i.match_id')
            ->crossJoin(DB::raw("jsonb_array_elements(i.deliveries) as d"))
            ->leftJoin('cricket_players as p', 'p.id', '=', DB::raw("(d->>'batsman_id')::uuid"))
            ->leftJoin('cricket_teams as t', 't.id', '=', 'p.team_id')
            ->where('m.tournament_id', $tournamentId)
            ->whereNotNull(DB::raw("d->>'batsman_id'"))
            ->selectRaw("
                (d->>'batsman_id') as player_id,
                p.name as name,
                t.short_code as team,
                SUM(COALESCE((d->>'runs')::int, 0)) as runs
            ")
            ->groupBy(DB::raw("d->>'batsman_id', p.name, t.short_code"))
            ->orderByDesc('runs')
            ->limit(5)
            ->get()
            ->map(fn($r) => [
                'player_id' => $r->player_id,
                'name' => $r->name ?? '',
                'team' => $r->team ?? '',
                'runs' => (int) $r->runs,
            ]);

        // Same pattern for bowlers — aggregate wickets from jsonb
        $topBowlers = DB::table('cricket_innings as i')
            ->join('cricket_matches as m', 'm.id', '=', 'i.match_id')
            ->crossJoin(DB::raw("jsonb_array_elements(i.deliveries) as d"))
            ->leftJoin('cricket_players as p', 'p.id', '=', DB::raw("(d->>'bowler_id')::uuid"))
            ->leftJoin('cricket_teams as t', 't.id', '=', 'p.team_id')
            ->where('m.tournament_id', $tournamentId)
            ->whereNotNull(DB::raw("d->>'bowler_id'"))
            ->where(DB::raw("(d->>'is_wicket')::boolean"), true)
            ->whereNull(DB::raw("d->>'extras_type'"))
            ->selectRaw("
                (d->>'bowler_id') as player_id,
                p.name as name,
                t.short_code as team,
                COUNT(*) as wickets
            ")
            ->groupBy(DB::raw("d->>'bowler_id', p.name, t.short_code"))
            ->orderByDesc('wickets')
            ->limit(5)
            ->get()
            ->map(fn($r) => [
                'player_id' => $r->player_id,
                'name' => $r->name ?? '',
                'team' => $r->team ?? '',
                'wickets' => (int) $r->wickets,
            ]);

        $result = [
            'most_runs' => $topBatsmen,
            'most_wickets' => $topBowlers,
        ];

        // Cache for 60s
        try {
            \Illuminate\Support\Facades\Redis::setex($cacheKey, 60, json_encode($result));
        } catch (\Throwable) {
        }

        return response()->json($result);
    }
}
