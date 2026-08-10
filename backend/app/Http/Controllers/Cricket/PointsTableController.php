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
     */
    public function topPerformers(string $tournamentId): \Illuminate\Http\JsonResponse
    {
        $tournament = Tournament::with([
            'matches.innings',
            'teams.players',
        ])->findOrFail($tournamentId);

        $playerStats = [];

        foreach ($tournament->matches as $match) {
            foreach ($match->innings as $innings) {
                $deliveries = $innings->deliveries ?? [];

                foreach ($deliveries as $ball) {
                    $batsmanId = $ball['batsman_id'] ?? null;
                    $bowlerId = $ball['bowler_id'] ?? null;
                    $runs = $ball['runs'] ?? 0;
                    $isWicket = !empty($ball['is_wicket']) && empty($ball['extras_type']);

                    if ($batsmanId) {
                        if (!isset($playerStats[$batsmanId])) {
                            $playerStats[$batsmanId] = ['runs' => 0, 'wickets' => 0, 'name' => ''];
                        }
                        $playerStats[$batsmanId]['runs'] += $runs;
                    }

                    if ($bowlerId && $isWicket) {
                        if (!isset($playerStats[$bowlerId])) {
                            $playerStats[$bowlerId] = ['runs' => 0, 'wickets' => 0, 'name' => ''];
                        }
                        $playerStats[$bowlerId]['wickets']++;
                    }
                }
            }
        }

        // Resolve player names
        $allPlayers = $tournament->teams->flatMap(fn($t) => $t->players);
        foreach ($allPlayers as $p) {
            if (isset($playerStats[$p->id])) {
                $playerStats[$p->id]['name'] = $p->name;
                $playerStats[$p->id]['team'] = $p->team->short_code ?? '';
            }
        }

        // Sort for most runs
        $topBatsmen = collect($playerStats)
            ->sortByDesc('runs')
            ->take(5)
            ->map(fn($s, $id) => ['player_id' => $id, ...$s])
            ->values();

        // Sort for most wickets
        $topBowlers = collect($playerStats)
            ->sortByDesc('wickets')
            ->take(5)
            ->map(fn($s, $id) => ['player_id' => $id, ...$s])
            ->values();

        return response()->json([
            'most_runs' => $topBatsmen,
            'most_wickets' => $topBowlers,
        ]);
    }
}
