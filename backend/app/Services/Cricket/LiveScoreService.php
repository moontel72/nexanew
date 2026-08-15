<?php

namespace App\Services\Cricket;

use App\Events\Cricket\CricketScoreUpdated;
use App\Models\Cricket\Commentary;
use App\Models\Cricket\Innings;
use App\Models\Cricket\LiveScore;
use App\Models\Cricket\MatchModel;
use App\Models\Cricket\MatchSquad;
use App\Models\Cricket\Player;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Str;

/**
 * LiveScoreService — Core scoring engine for cricket matches.
 *
 * Phase 0 foundation:
 *   - Every delivery carries a unique ball ID plus over/ball sequence numbers
 *   - Batter (striker), non-striker, and bowler attribution per delivery
 *   - Automatic strike rotation (odd runs, over completion, wickets)
 *   - Per-batter & per-bowler scorecards (the previously dormant
 *     `batting_scorecard` / `bowling_scorecard` columns)
 *   - Current player state persisted on the innings
 *   - Partnership tracking (runs & balls since the last wicket)
 *   - Bowler rules: max overs per bowler + no consecutive overs
 *
 * ALL aggregates are rebuilt from the delivery log on every write, so
 * append, undo, and (in Phase 2) edit/delete share one source of truth
 * and can never drift apart.
 *
 * Backward compatible: when player attribution is absent (legacy scorers
 * that only send runs/extras/wicket), every feature degrades gracefully
 * and existing production matches keep working unchanged.
 */
class LiveScoreService
{
    private const CACHE_TTL = 5;
    private const CACHE_PREFIX = 'cricket:score:';
    private const BALLS_PER_OVER = 6;

    /**
     * Process a single ball update.
     */
    public function processBall(
        string $matchId,
        array $ballData,
        string $managerId
    ): LiveScore {
        return DB::transaction(function () use ($matchId, $ballData, $managerId) {
            $match = MatchModel::with([
                'innings',
                'innings.battingTeam',
                'innings.bowlingTeam',
                'liveScore',
            ])->findOrFail($matchId);

            if ($match->status !== 'in_progress') {
                throw new \RuntimeException('Match is not in progress.');
            }

            $innings = $match->innings
                ->where('status', 'in_progress')
                ->first();

            if (!$innings) {
                throw new \RuntimeException('No active innings found.');
            }

            $players = $this->loadPlayers($innings);
            $squads = $this->loadSquads($matchId);

            // Resolve the players for this ball: explicit scorer selection
            // wins, otherwise fall back to the persisted innings state.
            $striker = $ballData['batsman_id'] ?? $innings->current_striker_id;
            $nonStriker = $ballData['non_striker_id'] ?? $innings->current_non_striker_id;
            $bowler = $ballData['bowler_id'] ?? $innings->current_bowler_id;

            $this->assertPlayerOnTeam($striker, $innings->batting_team_id, $players, 'Striker');
            $this->assertPlayerOnTeam($nonStriker, $innings->batting_team_id, $players, 'Non-striker');
            $this->assertPlayerOnTeam($bowler, $innings->bowling_team_id, $players, 'Bowler');
            $this->assertPlayerOnTeam(
                $ballData['next_batter_id'] ?? null,
                $innings->batting_team_id,
                $players,
                'Next batter'
            );

            if ($striker && $nonStriker && $striker === $nonStriker) {
                throw new \RuntimeException('Striker and non-striker must be different players.');
            }

            // Over-boundary rules apply when a new over begins.
            if ($bowler && ($innings->total_balls % self::BALLS_PER_OVER) === 0) {
                $this->assertBowlerEligible($match, $innings, $bowler);
            }

            $delivery = $this->buildDelivery($innings, $ballData, $striker, $nonStriker, $bowler);
            $innings->appendDelivery($delivery);

            $this->rebuildInningsAggregates($innings, $players, $squads);
            $innings->save();

            $liveScore = $this->updateLiveScore($match, $innings, $delivery, $managerId, $players);

            $this->generateCommentary($matchId, $innings, $delivery, $managerId, $players);
            $this->cacheScore($matchId, $liveScore);
            $this->broadcastScore($matchId, $liveScore);

            return $liveScore;
        });
    }

    /**
     * Undo the last ball in the current innings.
     */
    public function undoLastBall(string $matchId, string $managerId): LiveScore
    {
        return DB::transaction(function () use ($matchId, $managerId) {
            $match = MatchModel::with([
                'innings',
                'innings.battingTeam',
                'innings.bowlingTeam',
                'liveScore',
            ])->findOrFail($matchId);

            $innings = $match->innings->where('status', 'in_progress')->first();

            if (!$innings || empty($innings->deliveries)) {
                throw new \RuntimeException('No deliveries to undo.');
            }

            $deliveries = $innings->deliveries;
            array_pop($deliveries);
            $innings->deliveries = $deliveries;

            $players = $this->loadPlayers($innings);
            $squads = $this->loadSquads($matchId);

            // Full rebuild — the remaining deliveries are the only source of
            // truth, so every aggregate, scorecard, and the current player
            // state is restored exactly.
            $this->rebuildInningsAggregates($innings, $players, $squads);
            $innings->save();

            // Remove the commentary row for the undone ball. Multiple balls
            // can share a ball_number (e.g. a wide and the next legal ball),
            // so created_at is the tiebreaker for the most recent row.
            Commentary::where('match_id', $matchId)
                ->orderByDesc('ball_number')
                ->orderByDesc('created_at')
                ->first()?->delete();

            $lastDelivery = !empty($deliveries) ? end($deliveries) : null;

            $liveScore = $this->updateLiveScore($match, $innings, $lastDelivery, $managerId, $players);
            $this->cacheScore($matchId, $liveScore);
            $this->broadcastScore($matchId, $liveScore);

            return $liveScore;
        });
    }

    // ────────────────────────────────────────────────────────────
    // Ball construction & rules
    // ────────────────────────────────────────────────────────────

    private function buildDelivery(
        Innings $innings,
        array $ballData,
        ?string $striker,
        ?string $nonStriker,
        ?string $bowler
    ): array {
        $runs = (int) ($ballData['runs'] ?? 0);
        $extras = $ballData['extras_type'] ?? null;

        return [
            'ball_id' => (string) Str::orderedUuid(),
            'over_number' => intdiv($innings->total_balls, self::BALLS_PER_OVER),
            'ball_number' => ($innings->total_balls % self::BALLS_PER_OVER) + 1,
            'is_legal' => !in_array($extras, ['wide', 'no_ball'], true),
            'batter_id' => $striker,
            'non_striker_id' => $nonStriker,
            'bowler_id' => $bowler,
            'runs' => $runs,
            'batter_runs' => $this->batterRunsForBall(['runs' => $runs, 'extras_type' => $extras]),
            'extras_type' => $extras,
            'is_wicket' => !empty($ballData['is_wicket']),
            'wicket_type' => $ballData['wicket_type'] ?? null,
            'dismissed_player_id' => $ballData['dismissed_player_id'] ?? null,
            'fielder_id' => $ballData['fielder_id'] ?? null,
            'next_batter_id' => $ballData['next_batter_id'] ?? null,
            'timestamp' => now()->toIso8601String(),
        ];
    }

    /**
     * Wide / bye / leg-bye runs are not credited to the striker; the run(s)
     * beyond the no-ball penalty are.
     */
    private function batterRunsForBall(array $ball): int
    {
        $runs = (int) ($ball['runs'] ?? 0);

        return match ($ball['extras_type'] ?? null) {
            'wide', 'bye', 'leg_bye' => 0,
            'no_ball' => max(0, $runs - 1),
            default => $runs,
        };
    }

    private function extrasIncrements(array $ball): array
    {
        $runs = (int) ($ball['runs'] ?? 0);

        return match ($ball['extras_type'] ?? null) {
            'wide' => [
                'wides' => 1,
                'no_balls' => 0,
                'byes' => max(0, $runs - 1),
                'leg_byes' => 0,
            ],
            'no_ball' => [
                'wides' => 0,
                'no_balls' => 1,
                'byes' => 0,
                'leg_byes' => 0,
            ],
            'bye' => [
                'wides' => 0,
                'no_balls' => 0,
                'byes' => $runs,
                'leg_byes' => 0,
            ],
            'leg_bye' => [
                'wides' => 0,
                'no_balls' => 0,
                'byes' => 0,
                'leg_byes' => $runs,
            ],
            default => [
                'wides' => 0,
                'no_balls' => 0,
                'byes' => 0,
                'leg_byes' => 0,
            ],
        };
    }

    private function isLegalDelivery(array $ball): bool
    {
        if (array_key_exists('is_legal', $ball)) {
            return (bool) $ball['is_legal'];
        }

        // Legacy deliveries (pre Phase 0) advanced the ball count unless
        // they were wides or no-balls.
        return !in_array($ball['extras_type'] ?? null, ['wide', 'no_ball'], true);
    }

    private function isWicketDelivery(array $ball): bool
    {
        if (empty($ball['is_wicket'])) {
            return false;
        }

        // Off a no-ball the only possible dismissal is a run out.
        if (($ball['extras_type'] ?? null) === 'no_ball'
            && ($ball['wicket_type'] ?? null) !== 'run_out') {
            return false;
        }

        return true;
    }

    private function oversForBalls(int $balls): float
    {
        return floor($balls / self::BALLS_PER_OVER) + (($balls % self::BALLS_PER_OVER) / 10);
    }

    /**
     * Maximum overs a single bowler may bowl: 20% of the innings overs,
     * rounded up (T20 = 4, ODI = 10, T10 = 2).
     */
    private function maxOversPerBowler(MatchModel $match): int
    {
        $overs = max(1, (int) $match->overs_per_side);

        return max(1, (int) ceil($overs / 5));
    }

    private function assertBowlerEligible(MatchModel $match, Innings $innings, string $bowlerId): void
    {
        $deliveries = $innings->deliveries ?? [];

        // A bowler may not bowl two consecutive overs. The previous over's
        // bowler is the bowler of the last LEGAL delivery — wides / no-balls
        // before an over's first legal ball do not start the over.
        $previousBowler = null;
        foreach (array_reverse($deliveries) as $ball) {
            if ($this->isLegalDelivery($ball) && !empty($ball['bowler_id'])) {
                $previousBowler = $ball['bowler_id'];
                break;
            }
        }
        if ($previousBowler && $previousBowler === $bowlerId) {
            throw new \RuntimeException(
                'A bowler cannot bowl two consecutive overs. Select a different bowler.'
            );
        }

        // Over-limit check for the innings.
        $maxOvers = $this->maxOversPerBowler($match);
        $legalBallsBowled = collect($deliveries)
            ->where('bowler_id', $bowlerId)
            ->filter(fn (array $ball) => $this->isLegalDelivery($ball))
            ->count();

        if ($legalBallsBowled >= $maxOvers * self::BALLS_PER_OVER) {
            throw new \RuntimeException(
                "Bowler has already bowled the maximum of {$maxOvers} overs for this match."
            );
        }
    }

    private function assertPlayerOnTeam(
        ?string $playerId,
        ?string $teamId,
        \Illuminate\Support\Collection $players,
        string $label
    ): void {
        if ($playerId === null || $playerId === '') {
            return;
        }

        $player = $players->get($playerId);
        if (!$player) {
            throw new \RuntimeException("{$label}: unknown player.");
        }
        if ($player->team_id !== $teamId) {
            throw new \RuntimeException("{$label} does not belong to the expected team.");
        }
    }

    // ────────────────────────────────────────────────────────────
    // Aggregate rebuild (single source of truth)
    // ────────────────────────────────────────────────────────────

    private function rebuildInningsAggregates(
        Innings $innings,
        \Illuminate\Support\Collection $players,
        array $squads
    ): void {
        $deliveries = $innings->deliveries ?? [];

        $runs = 0;
        $wickets = 0;
        $balls = 0;
        $wides = 0;
        $noBalls = 0;
        $byes = 0;
        $legByes = 0;
        $fow = [];

        foreach ($deliveries as $ball) {
            $isLegal = $this->isLegalDelivery($ball);
            $isWicket = $this->isWicketDelivery($ball);

            $runs += (int) ($ball['runs'] ?? 0);
            if ($isWicket) {
                $wickets++;
            }
            if ($isLegal) {
                $balls++;
            }

            $increments = $this->extrasIncrements($ball);
            $wides += $increments['wides'];
            $noBalls += $increments['no_balls'];
            $byes += $increments['byes'];
            $legByes += $increments['leg_byes'];

            if ($isWicket) {
                $fow[] = [
                    'wicket_number' => $wickets,
                    'runs' => $runs,
                    'overs' => $this->oversForBalls($balls),
                    'player_out_id' => $ball['dismissed_player_id'] ?? null,
                ];
            }
        }

        $innings->total_runs = $runs;
        $innings->total_wickets = $wickets;
        $innings->total_balls = $balls;
        $innings->total_overs = $this->oversForBalls($balls);
        $innings->extras_wides = $wides;
        $innings->extras_no_balls = $noBalls;
        $innings->extras_byes = $byes;
        $innings->extras_leg_byes = $legByes;
        $innings->fall_of_wickets = $fow;
        $innings->batting_scorecard = $this->buildBattingScorecard($deliveries, $players, $squads);
        $innings->bowling_scorecard = $this->buildBowlingScorecard($deliveries, $players);

        [$striker, $nonStriker, $bowler] = $this->replayCurrentPlayers($deliveries);
        $innings->current_striker_id = $striker;
        $innings->current_non_striker_id = $nonStriker;
        $innings->current_bowler_id = $bowler;
    }

    private function buildBattingScorecard(
        array $deliveries,
        \Illuminate\Support\Collection $players,
        array $squads
    ): array {
        $scorecard = [];

        foreach ($deliveries as $ball) {
            $batterId = $ball['batter_id'] ?? null;
            $outId = $ball['dismissed_player_id'] ?? null;
            $isLegal = $this->isLegalDelivery($ball);
            $isWicket = $this->isWicketDelivery($ball);
            $batterRuns = $this->batterRunsForBall($ball);

            // Ensure a row exists for the striker AND the dismissed batter
            // (a run-out victim may never have faced a ball).
            foreach (array_unique(array_filter([$batterId, $outId])) as $playerId) {
                if (!isset($scorecard[$playerId])) {
                    $scorecard[$playerId] = [
                        'player_id' => $playerId,
                        'name' => $players->get($playerId)?->name ?? 'Player',
                        'batting_order' => $squads[$playerId] ?? null,
                        'runs' => 0,
                        'balls' => 0,
                        'fours' => 0,
                        'sixes' => 0,
                        'strike_rate' => 0.0,
                        'dismissed' => false,
                        'dismissal' => null,
                    ];
                }
            }

            if ($batterId && isset($scorecard[$batterId])) {
                $scorecard[$batterId]['runs'] += $batterRuns;
                if ($isLegal) {
                    $scorecard[$batterId]['balls']++;
                }
                if ($batterRuns === 4) {
                    $scorecard[$batterId]['fours']++;
                }
                if ($batterRuns === 6) {
                    $scorecard[$batterId]['sixes']++;
                }
            }

            if ($isWicket && $outId && isset($scorecard[$outId])) {
                $scorecard[$outId]['dismissed'] = true;
                $scorecard[$outId]['dismissal'] = $ball['wicket_type'] ?? 'out';
            }
        }

        foreach ($scorecard as &$entry) {
            $entry['strike_rate'] = $entry['balls'] > 0
                ? round(($entry['runs'] / $entry['balls']) * 100, 2)
                : 0.0;
        }
        unset($entry);

        $entries = array_values($scorecard);
        usort($entries, function (array $a, array $b) {
            $orderA = $a['batting_order'] ?? PHP_INT_MAX;
            $orderB = $b['batting_order'] ?? PHP_INT_MAX;

            return $orderA <=> $orderB ?: strcmp($a['name'], $b['name']);
        });

        return $entries;
    }

    private function buildBowlingScorecard(
        array $deliveries,
        \Illuminate\Support\Collection $players
    ): array {
        $scorecard = [];

        foreach ($deliveries as $ball) {
            $bowlerId = $ball['bowler_id'] ?? null;
            if (!$bowlerId) {
                continue;
            }

            if (!isset($scorecard[$bowlerId])) {
                $scorecard[$bowlerId] = [
                    'player_id' => $bowlerId,
                    'name' => $players->get($bowlerId)?->name ?? 'Player',
                    'balls' => 0,
                    'overs' => 0.0,
                    'maidens' => 0,
                    'runs' => 0,
                    'wickets' => 0,
                    'economy' => 0.0,
                ];
            }

            $extras = $ball['extras_type'] ?? null;
            // Byes & leg-byes are never charged to the bowler; the wide /
            // no-ball penalty run is.
            $charged = $this->batterRunsForBall($ball)
                + (in_array($extras, ['wide', 'no_ball'], true) ? 1 : 0);

            if ($this->isLegalDelivery($ball)) {
                $scorecard[$bowlerId]['balls']++;
            }
            $scorecard[$bowlerId]['runs'] += $charged;

            // Bowlers are not credited for run outs.
            if ($this->isWicketDelivery($ball) && ($ball['wicket_type'] ?? null) !== 'run_out') {
                $scorecard[$bowlerId]['wickets']++;
            }
        }

        foreach ($scorecard as &$entry) {
            $balls = $entry['balls'];
            $entry['overs'] = $this->oversForBalls($balls);
            $entry['economy'] = $balls > 0
                ? round($entry['runs'] / ($balls / self::BALLS_PER_OVER), 2)
                : 0.0;
        }
        unset($entry);

        // Insertion order == first appearance order.
        return array_values($scorecard);
    }

    /**
     * Replay the delivery log to derive the current striker, non-striker,
     * and bowler. Each delivery records the state before its ball; rotation
     * rules are then applied:
     *   1. Wicket → the dismissed batter leaves; replacement comes from
     *      next_batter_id or the next delivery that names them.
     *   2. Over completion → ends swap, a new bowler must be selected.
     *   3. Odd runs off the bat → the batters crossed.
     *
     * Simplified: on a run-out where the batters crossed mid-run, the
     * replacement is assumed to take the striker's end.
     */
    private function replayCurrentPlayers(array $deliveries): array
    {
        $striker = null;
        $nonStriker = null;
        $bowler = null;
        $legalBalls = 0;

        foreach ($deliveries as $ball) {
            if (!empty($ball['batter_id'])) {
                $striker = $ball['batter_id'];
            }
            if (!empty($ball['non_striker_id'])) {
                $nonStriker = $ball['non_striker_id'];
            }
            if (!empty($ball['bowler_id'])) {
                $bowler = $ball['bowler_id'];
            }

            $isLegal = $this->isLegalDelivery($ball);
            $isWicket = $this->isWicketDelivery($ball);
            $batterRuns = $this->batterRunsForBall($ball);

            if ($isLegal) {
                $legalBalls++;
            }

            if ($isWicket) {
                $outId = $ball['dismissed_player_id'] ?? null;
                if ($outId && $outId === $striker) {
                    $striker = $ball['next_batter_id'] ?? null;
                } elseif ($outId && $outId === $nonStriker) {
                    $nonStriker = $ball['next_batter_id'] ?? null;
                }
            }

            if ($isLegal && ($legalBalls % self::BALLS_PER_OVER) === 0) {
                [$striker, $nonStriker] = [$nonStriker, $striker];
                $bowler = null;
            } elseif ($isLegal && !$isWicket && ($batterRuns % 2) === 1) {
                [$striker, $nonStriker] = [$nonStriker, $striker];
            }
        }

        return [$striker, $nonStriker, $bowler];
    }

    private function partnershipFromDeliveries(array $deliveries): array
    {
        $runs = 0;
        $balls = 0;
        $active = false;

        foreach ($deliveries as $ball) {
            if ($this->isWicketDelivery($ball)) {
                $active = true;
                $runs = 0;
                $balls = 0;
                continue;
            }
            if ($active) {
                $runs += (int) ($ball['runs'] ?? 0);
                if ($this->isLegalDelivery($ball)) {
                    $balls++;
                }
            }
        }

        return ['runs' => $runs, 'balls' => $balls];
    }

    // ────────────────────────────────────────────────────────────
    // Live score snapshot
    // ────────────────────────────────────────────────────────────

    private function updateLiveScore(
        MatchModel $match,
        Innings $innings,
        ?array $ballData,
        string $managerId,
        \Illuminate\Support\Collection $players
    ): LiveScore {
        $liveScore = $match->liveScore ?? new LiveScore(['match_id' => $match->id]);

        $strikerEntry = $this->scorecardEntry(
            $innings->batting_scorecard ?? [],
            $innings->current_striker_id,
            $players
        );
        $nonStrikerEntry = $this->scorecardEntry(
            $innings->batting_scorecard ?? [],
            $innings->current_non_striker_id,
            $players
        );
        $bowlerEntry = $this->bowlingEntry(
            $innings->bowling_scorecard ?? [],
            $innings->current_bowler_id,
            $players
        );
        $partnership = $this->partnershipFromDeliveries($innings->deliveries ?? []);

        $crr = $innings->total_overs > 0
            ? round($innings->total_runs / $innings->total_overs, 2)
            : 0.0;

        // Target & required rate for the chasing innings.
        $target = null;
        $rrr = null;
        if ($match->current_innings_number > 1) {
            $firstInnings = $match->innings->where('innings_number', 1)->first();
            if ($firstInnings) {
                $target = $firstInnings->total_runs + 1;
                $remainingOvers = max(
                    0,
                    $match->overs_per_side * self::BALLS_PER_OVER - $innings->total_balls
                ) / self::BALLS_PER_OVER;
                $rrr = $remainingOvers > 0
                    ? round(($target - $innings->total_runs) / $remainingOvers, 2)
                    : null;
            }
        }

        $lastWicketInfo = null;
        if ($ballData && $this->isWicketDelivery($ballData)) {
            $outId = $ballData['dismissed_player_id'] ?? null;
            $outName = $outId ? ($players->get($outId)?->name ?? 'Batter') : 'Batter';
            $type = strtoupper(str_replace('_', ' ', $ballData['wicket_type'] ?? 'out'));
            $lastWicketInfo = "{$outName} — {$type}";
        }

        $liveScore->fill([
            'current_innings_id' => $innings->id,
            'batting_team_name' => $innings->battingTeam->name ?? null,
            'bowling_team_name' => $innings->bowlingTeam->name ?? null,
            'runs' => $innings->total_runs,
            'wickets' => $innings->total_wickets,
            'overs' => $innings->total_overs,
            'current_run_rate' => $crr,
            'target' => $target,
            'required_run_rate' => $rrr,
            'striker_id' => $innings->current_striker_id,
            'striker_name' => $strikerEntry['name'] ?? null,
            'striker_runs' => $strikerEntry['runs'] ?? null,
            'striker_balls' => $strikerEntry['balls'] ?? null,
            'non_striker_id' => $innings->current_non_striker_id,
            'non_striker_name' => $nonStrikerEntry['name'] ?? null,
            'non_striker_runs' => $nonStrikerEntry['runs'] ?? null,
            'non_striker_balls' => $nonStrikerEntry['balls'] ?? null,
            'bowler_id' => $innings->current_bowler_id,
            'bowler_name' => $bowlerEntry['name'] ?? null,
            'bowler_overs' => $bowlerEntry['overs'] ?? null,
            'bowler_runs_conceded' => $bowlerEntry['runs'] ?? null,
            'bowler_wickets' => $bowlerEntry['wickets'] ?? null,
            'partnership_runs' => $partnership['runs'],
            'partnership_balls' => $partnership['balls'],
            'last_ball_result' => $ballData ? $this->describeBall($ballData) : null,
            'last_wicket_info' => $lastWicketInfo,
            'updated_by_cricket_manager_id' => $managerId,
            'full_snapshot' => $this->buildFullSnapshot(
                $match,
                $innings,
                $ballData,
                $crr,
                $target,
                $rrr,
                $lastWicketInfo,
                $strikerEntry,
                $nonStrikerEntry,
                $bowlerEntry,
                $partnership
            ),
        ]);

        $liveScore->save();

        return $liveScore->fresh();
    }

    /**
     * Find a batter's scorecard row, or build a zeroed entry for a batter
     * who is at the crease but has not faced a ball yet.
     */
    private function scorecardEntry(
        array $scorecard,
        ?string $playerId,
        \Illuminate\Support\Collection $players
    ): ?array {
        if ($playerId === null) {
            return null;
        }

        foreach ($scorecard as $entry) {
            if (($entry['player_id'] ?? null) === $playerId) {
                return $entry;
            }
        }

        $player = $players->get($playerId);
        if (!$player) {
            return null;
        }

        return [
            'player_id' => $playerId,
            'name' => $player->name,
            'batting_order' => null,
            'runs' => 0,
            'balls' => 0,
            'fours' => 0,
            'sixes' => 0,
            'strike_rate' => 0.0,
            'dismissed' => false,
            'dismissal' => null,
        ];
    }

    private function bowlingEntry(
        array $scorecard,
        ?string $playerId,
        \Illuminate\Support\Collection $players
    ): ?array {
        if ($playerId === null) {
            return null;
        }

        foreach ($scorecard as $entry) {
            if (($entry['player_id'] ?? null) === $playerId) {
                return $entry;
            }
        }

        $player = $players->get($playerId);
        if (!$player) {
            return null;
        }

        return [
            'player_id' => $playerId,
            'name' => $player->name,
            'balls' => 0,
            'overs' => 0.0,
            'maidens' => 0,
            'runs' => 0,
            'wickets' => 0,
            'economy' => 0.0,
        ];
    }

    private function buildFullSnapshot(
        MatchModel $match,
        Innings $innings,
        ?array $ballData,
        float $crr,
        ?int $target,
        ?float $rrr,
        ?string $lastWicketInfo,
        ?array $strikerEntry,
        ?array $nonStrikerEntry,
        ?array $bowlerEntry,
        array $partnership
    ): array {
        $latestDeliveries = collect($innings->deliveries ?? [])->take(-30)->values()->toArray();

        return [
            'match_id' => $match->id,
            'innings_number' => $innings->innings_number,
            'batting_team' => $innings->batting_team_id,
            'batting_team_name' => $innings->battingTeam->name ?? '',
            'bowling_team_name' => $innings->bowlingTeam->name ?? '',
            'score' => "{$innings->total_runs}/{$innings->total_wickets}",
            'overs' => $innings->total_overs,
            'target' => $target,
            'crr' => $crr,
            'rrr' => $rrr,
            'extras' => [
                'wides' => $innings->extras_wides,
                'no_balls' => $innings->extras_no_balls,
                'byes' => $innings->extras_byes,
                'leg_byes' => $innings->extras_leg_byes,
                'total' => $innings->extras_wides
                    + $innings->extras_no_balls
                    + $innings->extras_byes
                    + $innings->extras_leg_byes,
            ],
            'fall_of_wickets' => $innings->fall_of_wickets,
            'recent_balls' => $latestDeliveries,
            'batters' => $innings->batting_scorecard ?? [],
            'bowlers' => $innings->bowling_scorecard ?? [],
            'current' => [
                'striker' => $strikerEntry,
                'non_striker' => $nonStrikerEntry,
                'bowler' => $bowlerEntry,
            ],
            'partnership_runs' => $partnership['runs'],
            'partnership_balls' => $partnership['balls'],
            'max_overs_per_bowler' => $this->maxOversPerBowler($match),
            'last_ball_result' => $ballData ? $this->describeBall($ballData) : null,
            'last_wicket_info' => $lastWicketInfo,
            'last_updated' => now()->toIso8601String(),
        ];
    }

    private function describeBall(array $ballData): string
    {
        if (!empty($ballData['is_wicket'])) {
            return strtoupper($ballData['wicket_type'] ?? 'W');
        }
        $extras = $ballData['extras_type'] ?? null;
        $runs = $ballData['runs'] ?? 0;

        return match ($extras) {
            'wide' => $runs > 0 ? "WD+{$runs}" : 'WD',
            'no_ball' => $runs > 0 ? "NB+{$runs}" : 'NB',
            'bye' => "{$runs}B",
            'leg_bye' => "{$runs}LB",
            default => match ((int) $runs) {
                0 => '0',
                4 => '4',
                6 => '6',
                default => (string) $runs,
            },
        };
    }

    // ────────────────────────────────────────────────────────────
    // Commentary
    // ────────────────────────────────────────────────────────────

    private function generateCommentary(
        string $matchId,
        Innings $innings,
        array $ballData,
        string $managerId,
        \Illuminate\Support\Collection $players
    ): void {
        $overNumber = (int) ($ballData['over_number'] ?? intdiv($innings->total_balls, self::BALLS_PER_OVER));
        $ballInOver = (int) ($ballData['ball_number'] ?? (($innings->total_balls % self::BALLS_PER_OVER) + 1));

        $text = $this->buildCommentaryText($innings, $ballData, $overNumber, $ballInOver, $players);

        $eventType = 'ball';
        if (!empty($ballData['is_wicket'])) {
            $eventType = 'wicket';
        } elseif (($ballData['runs'] ?? 0) >= 6 && empty($ballData['extras_type'])) {
            $eventType = 'boundary_six';
        } elseif (($ballData['runs'] ?? 0) >= 4 && empty($ballData['extras_type'])) {
            $eventType = 'boundary_four';
        } elseif (in_array($ballData['extras_type'] ?? null, ['wide', 'no_ball'])) {
            $eventType = $ballData['extras_type'];
        }

        Commentary::create([
            'match_id' => $matchId,
            'ball_number' => $innings->total_balls,
            'over_number' => $overNumber,
            'commentary_text' => $text,
            'event_type' => $eventType,
            'cricket_manager_id' => $managerId,
        ]);
    }

    private function buildCommentaryText(
        Innings $innings,
        array $ballData,
        int $over,
        int $ballInOver,
        \Illuminate\Support\Collection $players
    ): string {
        $runs = $ballData['runs'] ?? 0;
        $extras = $ballData['extras_type'] ?? null;
        $score = "{$innings->total_runs}/{$innings->total_wickets}";
        $bowlerName = !empty($ballData['bowler_id'])
            ? ($players->get($ballData['bowler_id'])?->name ?? null)
            : null;
        $batterName = !empty($ballData['batter_id'])
            ? ($players->get($ballData['batter_id'])?->name ?? null)
            : null;

        if (!empty($ballData['is_wicket'])) {
            $outId = $ballData['dismissed_player_id'] ?? null;
            $outName = $outId ? ($players->get($outId)?->name ?? null) : null;
            $type = strtoupper(str_replace('_', ' ', $ballData['wicket_type'] ?? 'out'));
            $detail = ' ' . ($outName ?? $batterName ?? 'Batter') . " {$type}"
                . ($bowlerName ? " off {$bowlerName}" : '');

            return "Over {$over}.{$ballInOver}: WICKET!{$detail}. {$score} in {$innings->total_overs} overs.";
        }

        $event = match ($extras) {
            'wide' => "Wide ball. {$runs} run(s)",
            'no_ball' => "No ball! {$runs} run(s)",
            'bye' => "{$runs} bye(s)",
            'leg_bye' => "{$runs} leg bye(s)",
            default => match ((int) $runs) {
                0 => 'Dot ball',
                4 => 'FOUR!',
                6 => 'SIX!',
                default => "{$runs} run(s)",
            },
        };

        $detail = ($batterName ? " by {$batterName}" : '')
            . ($bowlerName ? " off {$bowlerName}" : '');

        return "Over {$over}.{$ballInOver}: {$event}{$detail}. {$score} in {$innings->total_overs} overs.";
    }

    // ────────────────────────────────────────────────────────────
    // Redis cache + WebSocket broadcast
    // ────────────────────────────────────────────────────────────

    private function cacheScore(string $matchId, LiveScore $liveScore): void
    {
        try {
            Redis::setex(
                self::CACHE_PREFIX . $matchId,
                self::CACHE_TTL,
                json_encode($liveScore->full_snapshot)
            );
        } catch (\Throwable $e) {
            Log::warning('Cricket: Redis cache write failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function broadcastScore(string $matchId, LiveScore $liveScore): void
    {
        try {
            CricketScoreUpdated::dispatch($matchId, $liveScore->full_snapshot ?? []);
        } catch (\Throwable $e) {
            Log::warning('Cricket: WebSocket broadcast failed (non-critical)', [
                'match_id' => $matchId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    // ────────────────────────────────────────────────────────────
    // Player lookups
    // ────────────────────────────────────────────────────────────

    private function loadPlayers(Innings $innings): \Illuminate\Support\Collection
    {
        return Player::whereIn('team_id', [$innings->batting_team_id, $innings->bowling_team_id])
            ->get()
            ->keyBy('id');
    }

    private function loadSquads(string $matchId): array
    {
        return MatchSquad::where('match_id', $matchId)
            ->whereNotNull('batting_order')
            ->get()
            ->mapWithKeys(fn (MatchSquad $squad) => [$squad->player_id => (int) $squad->batting_order])
            ->all();
    }

    /**
     * Get current score from Redis cache (for REST fallback).
     * Returns null if cache miss — caller should fall back to DB.
     */
    public static function getCachedScore(string $matchId): ?array
    {
        try {
            $cached = Redis::get(self::CACHE_PREFIX . $matchId);

            return $cached ? json_decode($cached, true) : null;
        } catch (\Throwable) {
            return null;
        }
    }
}
