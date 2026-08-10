<?php

namespace App\Services\Cricket;

use App\Models\Cricket\Innings;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\PointsTable;
use App\Models\Cricket\Tournament;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * PointsTableService — Compute tournament standings and NRR.
 *
 * NRR Formula:
 *   (Total Runs Scored / Total Overs Faced) - (Total Runs Conceded / Total Overs Bowled)
 *
 * Recomputes the entire points table for a given tournament on each call.
 * Should be triggered after every match completion within that tournament.
 */
class PointsTableService
{
    /**
     * Full recompute of standings for a tournament.
     * Deletes existing rows and rebuilds from match data.
     */
    public function recomputeForTournament(string $tournamentId): array
    {
        return DB::transaction(function () use ($tournamentId) {
            $tournament = Tournament::findOrFail($tournamentId);
            $matches = MatchModel::where('tournament_id', $tournamentId)
                ->whereIn('status', ['completed', 'in_progress', 'innings_break'])
                ->with('innings')
                ->get();

            // Build team stats map
            $teamStats = [];

            foreach ($matches as $match) {
                $teamA = $match->team_a_id;
                $teamB = $match->team_b_id;

                // Initialize both teams if not present
                foreach ([$teamA, $teamB] as $tid) {
                    if (!isset($teamStats[$tid])) {
                        $teamStats[$tid] = $this->emptyStats();
                    }
                }

                $isCompleted = $match->status === 'completed';

                // Determine result
                $result = $match->match_result ?? [];
                $winnerId = $result['winner_team_id'] ?? null;
                $isTied = ($result['win_type'] ?? null) === 'tie';
                $isNoResult = ($result['win_type'] ?? null) === 'no_result';

                if ($isCompleted) {
                    $teamStats[$teamA]['matches_played']++;
                    $teamStats[$teamB]['matches_played']++;

                    if ($isNoResult) {
                        $teamStats[$teamA]['no_result']++;
                        $teamStats[$teamB]['no_result']++;
                        $teamStats[$teamA]['points'] += 1;
                        $teamStats[$teamB]['points'] += 1;
                    } elseif ($isTied) {
                        $teamStats[$teamA]['tied']++;
                        $teamStats[$teamB]['tied']++;
                        $teamStats[$teamA]['points'] += 1;
                        $teamStats[$teamB]['points'] += 1;
                    } elseif ($winnerId === $teamA) {
                        $teamStats[$teamA]['won']++;
                        $teamStats[$teamA]['points'] += 2;
                        $teamStats[$teamB]['lost']++;
                    } elseif ($winnerId === $teamB) {
                        $teamStats[$teamB]['won']++;
                        $teamStats[$teamB]['points'] += 2;
                        $teamStats[$teamA]['lost']++;
                    }
                }

                // Accumulate runs/overs from innings
                foreach ($match->innings as $innings) {
                    $batTeam = $innings->batting_team_id;
                    $bowlTeam = $innings->bowling_team_id;

                    if (!isset($teamStats[$batTeam])) $teamStats[$batTeam] = $this->emptyStats();
                    if (!isset($teamStats[$bowlTeam])) $teamStats[$bowlTeam] = $this->emptyStats();

                    $teamStats[$batTeam]['runs_for'] += $innings->total_runs;
                    $teamStats[$batTeam]['overs_faced'] += $innings->total_overs;

                    $teamStats[$bowlTeam]['runs_against'] += $innings->total_runs;
                    $teamStats[$bowlTeam]['overs_bowled'] += $innings->total_overs;
                }
            }

            // Compute NRR for each team
            foreach ($teamStats as $tid => &$stats) {
                $rrFor = $stats['overs_faced'] > 0
                    ? $stats['runs_for'] / $stats['overs_faced']
                    : 0;
                $rrAgainst = $stats['overs_bowled'] > 0
                    ? $stats['runs_against'] / $stats['overs_bowled']
                    : 0;
                $stats['nrr'] = round($rrFor - $rrAgainst, 3);
            }

            // Sort: Points DESC → NRR DESC → Most Wins
            uasort($teamStats, function ($a, $b) {
                if ($b['points'] !== $a['points']) return $b['points'] <=> $a['points'];
                if ($b['nrr'] !== $a['nrr']) return $b['nrr'] <=> $a['nrr'];
                return $b['won'] <=> $a['won'];
            });

            // Delete existing and rebuild
            PointsTable::where('tournament_id', $tournamentId)->delete();

            $rank = 0;
            $results = [];

            foreach ($teamStats as $tid => $stats) {
                $rank++;
                $pt = PointsTable::create([
                    'tournament_id' => $tournamentId,
                    'team_id' => $tid,
                    'matches_played' => $stats['matches_played'],
                    'won' => $stats['won'],
                    'lost' => $stats['lost'],
                    'tied' => $stats['tied'],
                    'no_result' => $stats['no_result'],
                    'points' => $stats['points'],
                    'net_run_rate' => $stats['nrr'],
                    'runs_for' => $stats['runs_for'],
                    'overs_faced' => $stats['overs_faced'],
                    'runs_against' => $stats['runs_against'],
                    'overs_bowled' => $stats['overs_bowled'],
                    'rank_position' => $rank,
                ]);
                $results[] = $pt;
            }

            Log::info('Cricket: Points table recomputed', [
                'tournament_id' => $tournamentId,
                'teams' => count($results),
            ]);

            return $results;
        });
    }

    /**
     * Get standings for a tournament (reads materialized table).
     */
    public function getStandings(string $tournamentId): array
    {
        return PointsTable::with('team:id,name,short_code,logo_url')
            ->where('tournament_id', $tournamentId)
            ->orderBy('rank_position')
            ->get()
            ->toArray();
    }

    private function emptyStats(): array
    {
        return [
            'matches_played' => 0,
            'won' => 0,
            'lost' => 0,
            'tied' => 0,
            'no_result' => 0,
            'points' => 0,
            'nrr' => 0.0,
            'runs_for' => 0,
            'overs_faced' => 0.0,
            'runs_against' => 0,
            'overs_bowled' => 0.0,
        ];
    }
}
