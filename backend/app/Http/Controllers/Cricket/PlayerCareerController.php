<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Models\Cricket\Player;
use App\Models\Cricket\PlayerCareerStats;
use App\Services\Cricket\PlayerCareerService;

class PlayerCareerController extends Controller
{
    private PlayerCareerService $careerService;

    public function __construct(PlayerCareerService $careerService)
    {
        $this->careerService = $careerService;
    }

    /**
     * Get career profile for a player (public).
     */
    public function show(string $playerId): \Illuminate\Http\JsonResponse
    {
        $player = Player::with('team')->findOrFail($playerId);
        $career = PlayerCareerStats::with('club')->where('player_id', $playerId)->first();

        if (!$career) {
            return response()->json([
                'player' => $this->formatPlayer($player),
                'career' => null,
                'message' => 'No career stats accumulated yet.',
            ]);
        }

        return response()->json([
            'player' => $this->formatPlayer($player),
            'career' => [
                'batting' => [
                    'total_matches' => $career->total_matches,
                    'total_innings' => $career->total_innings,
                    'total_runs' => $career->total_runs,
                    'not_outs' => $career->not_outs,
                    'highest_score' => $career->highest_score,
                    'highest_score_not_out' => $career->highest_score_not_out,
                    'average' => $career->getBattingAverageAttribute(),
                    'balls_faced' => $career->balls_faced,
                    'strike_rate' => $career->batting_strike_rate,
                    'centuries' => $career->centuries,
                    'half_centuries' => $career->half_centuries,
                    'fours' => $career->fours,
                    'sixes' => $career->sixes,
                ],
                'bowling' => [
                    'total_wickets' => $career->total_wickets,
                    'average' => $career->getBowlingAverageComputedAttribute(),
                    'best_figures' => $career->best_bowling_figures,
                    'economy_rate' => $career->economy_rate,
                    'overs_bowled' => $career->overs_bowled_career,
                    'maidens' => $career->maidens,
                    'five_wicket_hauls' => $career->five_wicket_hauls,
                ],
                'fielding' => [
                    'catches' => $career->catches,
                    'run_outs' => $career->run_outs,
                    'stumpings' => $career->stumpings,
                ],
                'recent_form' => $career->recent_scores,
                'club' => $career->club ? [
                    'id' => $career->club->id,
                    'name' => $career->club->name,
                    'logo_url' => $career->club->logo_url,
                ] : null,
            ],
        ]);
    }

    /**
     * Rebuild career stats for a player (admin trigger).
     */
    public function rebuild(string $playerId): \Illuminate\Http\JsonResponse
    {
        $career = $this->careerService->rebuildForPlayer($playerId);

        if (!$career) {
            return response()->json(['message' => 'Player not found.'], 404);
        }

        return response()->json([
            'message' => 'Career stats rebuilt.',
            'career' => $career,
        ]);
    }

    /**
     * Get top players by runs or wickets across all tournaments (public).
     */
    public function leaderboard(): \Illuminate\Http\JsonResponse
    {
        $topBatsmen = PlayerCareerStats::with('player.team')
            ->orderByDesc('total_runs')
            ->take(10)
            ->get()
            ->map(fn($s) => [
                'player_id' => $s->player_id,
                'name' => $s->player->name ?? '',
                'team' => $s->player->team->short_code ?? '',
                'total_runs' => $s->total_runs,
                'average' => $s->getBattingAverageAttribute(),
                'strike_rate' => $s->batting_strike_rate,
            ]);

        $topBowlers = PlayerCareerStats::with('player.team')
            ->orderByDesc('total_wickets')
            ->take(10)
            ->get()
            ->map(fn($s) => [
                'player_id' => $s->player_id,
                'name' => $s->player->name ?? '',
                'team' => $s->player->team->short_code ?? '',
                'total_wickets' => $s->total_wickets,
                'average' => $s->getBowlingAverageComputedAttribute(),
                'economy_rate' => $s->economy_rate,
            ]);

        return response()->json([
            'top_batsmen' => $topBatsmen,
            'top_bowlers' => $topBowlers,
        ]);
    }

    private function formatPlayer(Player $player): array
    {
        return [
            'id' => $player->id,
            'name' => $player->name,
            'jersey_number' => $player->jersey_number,
            'role' => $player->role,
            'batting_style' => $player->batting_style,
            'bowling_style' => $player->bowling_style,
            'photo_url' => $player->photo_url,
            'is_captain' => $player->is_captain,
            'is_wicket_keeper' => $player->is_wicket_keeper,
            'team' => $player->team ? [
                'id' => $player->team->id,
                'name' => $player->team->name,
                'short_code' => $player->team->short_code,
                'logo_url' => $player->team->logo_url,
            ] : null,
        ];
    }
}
