<?php

namespace App\Services\Cricket;

use App\Models\Cricket\Innings;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\Player;
use App\Models\Cricket\PlayerCareerStats;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * PlayerCareerService — Aggregates career stats across all matches.
 *
 * Called after every match completion. Reads all innings deliveries
 * for the player and recomputes batting + bowling + fielding metrics.
 */
class PlayerCareerService
{
    /**
     * Rebuild career stats for a single player.
     */
    public function rebuildForPlayer(string $playerId): ?PlayerCareerStats
    {
        $player = Player::with('team')->find($playerId);
        if (!$player) return null;

        return DB::transaction(function () use ($player, $playerId) {
            // Find all innings this player participated in (as batsman)
            $allInnings = Innings::whereNotNull('deliveries')->get();

            $battingStats = $this->computeBattingStats($playerId, $allInnings);
            $bowlingStats = $this->computeBowlingStats($playerId, $allInnings);
            $fieldingStats = $this->computeFieldingStats($playerId, $allInnings);
            $recentScores = $this->computeRecentForm($playerId, $allInnings);

            $career = PlayerCareerStats::updateOrCreate(
                ['player_id' => $playerId],
                array_merge(
                    $battingStats,
                    $bowlingStats,
                    $fieldingStats,
                    ['recent_scores' => $recentScores],
                )
            );

            Log::info('Cricket: Player career stats rebuilt', [
                'player_id' => $playerId,
                'player_name' => $player->name,
            ]);

            return $career;
        });
    }

    /**
     * Rebuild career stats for all players in a match.
     */
    public function rebuildForMatch(string $matchId): void
    {
        $match = MatchModel::with('teamA.players', 'teamB.players')->findOrFail($matchId);
        $playerIds = collect([$match->teamA, $match->teamB])
            ->flatMap(fn($t) => $t->players?->pluck('id') ?? collect())
            ->unique();

        foreach ($playerIds as $pid) {
            try {
                $this->rebuildForPlayer($pid);
            } catch (\Throwable $e) {
                Log::warning('Cricket: Failed to rebuild career for player', [
                    'player_id' => $pid,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::info('Cricket: Match career stats rebuilt', [
            'match_id' => $matchId,
            'players_processed' => $playerIds->count(),
        ]);
    }

    private function computeBattingStats(string $playerId, $allInnings): array
    {
        $totalRuns = 0;
        $totalBalls = 0;
        $inningsCount = 0;
        $notOuts = 0;
        $highestScore = 0;
        $highestNotOut = false;
        $fours = 0;
        $sixes = 0;
        $fifties = 0;
        $hundreds = 0;

        foreach ($allInnings as $innings) {
            $deliveries = $innings->deliveries ?? [];

            // Group deliveries by batsman for this innings
            $playerDeliveries = array_filter($deliveries, fn($d) =>
                ($d['batsman_id'] ?? null) === $playerId
            );

            // Also check dismissed_player_id (means the player appeared)
            $wasDismissed = false;
            foreach ($deliveries as $d) {
                if (($d['dismissed_player_id'] ?? null) === $playerId) {
                    $wasDismissed = true;
                    break;
                }
            }

            $playerRuns = array_sum(array_column($playerDeliveries, 'runs'));
            $playerBalls = count(array_filter($playerDeliveries, fn($d) =>
                empty($d['extras_type']) || !in_array($d['extras_type'], ['wide', 'no_ball'])
            ));

            if ($playerBalls > 0 || !empty($playerDeliveries) || $wasDismissed) {
                $inningsCount++;
                $totalRuns += $playerRuns;
                $totalBalls += $playerBalls;

                if (!$wasDismissed && $innings->status !== 'yet_to_bat') {
                    $notOuts++;
                }

                if ($playerRuns > $highestScore) {
                    $highestScore = $playerRuns;
                    $highestNotOut = !$wasDismissed;
                }

                if ($playerRuns >= 100) $hundreds++;
                elseif ($playerRuns >= 50) $fifties++;

                // Count boundaries from deliveries
                foreach ($playerDeliveries as $d) {
                    if (($d['runs'] ?? 0) >= 6 && empty($d['extras_type'])) $sixes++;
                    elseif (($d['runs'] ?? 0) >= 4 && empty($d['extras_type'])) $fours++;
                }
            }
        }

        $dismissals = $inningsCount - $notOuts;
        $average = $dismissals > 0 ? round($totalRuns / $dismissals, 2) : 0;
        $strikeRate = $totalBalls > 0 ? round(($totalRuns / $totalBalls) * 100, 2) : 0;

        return [
            'total_matches' => $inningsCount,
            'total_innings' => $inningsCount,
            'total_runs' => $totalRuns,
            'not_outs' => $notOuts,
            'highest_score' => $highestScore,
            'highest_score_not_out' => $highestNotOut,
            'batting_average' => $average,
            'balls_faced' => $totalBalls,
            'batting_strike_rate' => $strikeRate,
            'centuries' => $hundreds,
            'half_centuries' => $fifties,
            'fours' => $fours,
            'sixes' => $sixes,
        ];
    }

    private function computeBowlingStats(string $playerId, $allInnings): array
    {
        $totalWickets = 0;
        $runsConceded = 0;
        $totalBalls = 0;
        $maidens = 0;
        $fiveWktHauls = 0;
        $bestWickets = 0;
        $bestRuns = 0;

        foreach ($allInnings as $innings) {
            $deliveries = $innings->deliveries ?? [];
            $bowlerDeliveries = array_filter($deliveries, fn($d) =>
                ($d['bowler_id'] ?? null) === $playerId
            );

            $bowlerRuns = array_sum(array_column($bowlerDeliveries, 'runs'));
            $legalBalls = count(array_filter($bowlerDeliveries, fn($d) =>
                empty($d['extras_type']) || !in_array($d['extras_type'], ['wide', 'no_ball'])
            ));
            $wickets = count(array_filter($bowlerDeliveries, fn($d) =>
                !empty($d['is_wicket']) && empty($d['extras_type'])
            ));

            if ($legalBalls > 0 || $wickets > 0) {
                $runsConceded += $bowlerRuns;
                $totalBalls += $legalBalls;
                $totalWickets += $wickets;

                if ($wickets >= 5) $fiveWktHauls++;
                if ($wickets > $bestWickets || ($wickets === $bestWickets && $bowlerRuns < $bestRuns)) {
                    $bestWickets = $wickets;
                    $bestRuns = $bowlerRuns;
                }

                // Check maiden overs (6 balls, 0 runs in an over)
                // Simplified: just count maiden overs per inning if possible
            }
        }

        $overs = $totalBalls > 0 ? floor($totalBalls / 6) + (($totalBalls % 6) / 10) : 0.0;
        $average = $totalWickets > 0 ? round($runsConceded / $totalWickets, 2) : 0;
        $economy = $overs > 0 ? round($runsConceded / $overs, 2) : 0;
        $bestFigures = $bestWickets > 0 ? "{$bestWickets}/{$bestRuns}" : null;

        return [
            'total_wickets' => $totalWickets,
            'bowling_average' => $average,
            'best_bowling_figures' => $bestFigures,
            'economy_rate' => $economy,
            'overs_bowled_career' => $overs,
            'five_wicket_hauls' => $fiveWktHauls,
            'runs_conceded' => $runsConceded,
            'maidens' => $maidens,
        ];
    }

    private function computeFieldingStats(string $playerId, $allInnings): array
    {
        $catches = 0;
        $runOuts = 0;
        $stumpings = 0;

        foreach ($allInnings as $innings) {
            $deliveries = $innings->deliveries ?? [];
            foreach ($deliveries as $d) {
                if (($d['fielder_id'] ?? null) === $playerId) {
                    $wicketType = $d['wicket_type'] ?? '';
                    if ($wicketType === 'caught') $catches++;
                    elseif ($wicketType === 'run_out') $runOuts++;
                    elseif ($wicketType === 'stumped') $stumpings++;
                    else $catches++; // default to catch
                }
            }
        }

        return [
            'catches' => $catches,
            'run_outs' => $runOuts,
            'stumpings' => $stumpings,
        ];
    }

    private function computeRecentForm(string $playerId, $allInnings): array
    {
        $scores = [];

        foreach ($allInnings as $innings) {
            $deliveries = $innings->deliveries ?? [];
            $playerDeliveries = array_filter($deliveries, fn($d) =>
                ($d['batsman_id'] ?? null) === $playerId
            );

            $wasDismissed = false;
            foreach ($deliveries as $d) {
                if (($d['dismissed_player_id'] ?? null) === $playerId) {
                    $wasDismissed = true;
                    break;
                }
            }

            $runs = array_sum(array_column($playerDeliveries, 'runs'));
            $balls = count($playerDeliveries);

            if ($balls > 0 || $wasDismissed) {
                $scores[] = [
                    'runs' => $runs,
                    'balls' => $balls,
                    'not_out' => !$wasDismissed,
                    'match_id' => $innings->match_id,
                    'date' => $innings->created_at?->toDateString(),
                ];
            }
        }

        // Return last 5, most recent first
        return array_slice(array_reverse($scores), 0, 5);
    }
}
