<?php

namespace App\Services\Cricket;

use App\Events\Cricket\CricketScoreUpdated;
use App\Models\Cricket\Commentary;
use App\Models\Cricket\Innings;
use App\Models\Cricket\LiveScore;
use App\Models\Cricket\MatchModel;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;

/**
 * LiveScoreService — Core scoring engine for cricket matches.
 *
 * Handles:
 *   - Ball-by-ball score updates
 *   - Automatic CRR/RRR calculation
 *   - Redis cache synchronization (REST fallback)
 *   - WebSocket broadcast (Laravel Reverb)
 *   - Commentary auto-generation
 *
 * Isolated to cricket_* tables only.
 */
class LiveScoreService
{
    private const CACHE_TTL = 5; // seconds
    private const CACHE_PREFIX = 'cricket:score:';

    /**
     * Process a single ball update.
     */
    public function processBall(
        string $matchId,
        array $ballData,
        string $managerId
    ): LiveScore {
        return DB::transaction(function () use ($matchId, $ballData, $managerId) {
            $match = MatchModel::with(['innings', 'liveScore'])->findOrFail($matchId);

            if ($match->status !== 'in_progress') {
                throw new \RuntimeException('Match is not in progress.');
            }

            $innings = $match->innings
                ->where('status', 'in_progress')
                ->first();

            if (!$innings) {
                throw new \RuntimeException('No active innings found.');
            }

            // Append delivery to innings
            $ballData['timestamp'] = now()->toIso8601String();
            $innings->appendDelivery($ballData);

            // Update innings aggregate stats
            $this->updateInningsStats($innings, $ballData);
            $innings->save();

            // Update live score snapshot
            $liveScore = $this->updateLiveScore($match, $innings, $ballData, $managerId);

            // Auto-generate commentary
            $this->generateCommentary($matchId, $innings, $ballData, $managerId);

            // Publish to Redis cache (for REST polling fallback)
            $this->cacheScore($matchId, $liveScore);

            // Broadcast via WebSocket
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
            $match = MatchModel::with(['innings', 'liveScore'])->findOrFail($matchId);
            $innings = $match->innings->where('status', 'in_progress')->first();

            if (!$innings || empty($innings->deliveries)) {
                throw new \RuntimeException('No deliveries to undo.');
            }

            $deliveries = $innings->deliveries;
            $removedBall = array_pop($deliveries);
            $innings->deliveries = $deliveries;

            // Recalculate stats (reverse the ball)
            $this->reverseInningsStats($innings, $removedBall);
            $innings->save();

            // Remove last commentary entry
            Commentary::where('match_id', $matchId)
                ->latest('ball_number')
                ->first()?->delete();

            // Rebuild live score from current state
            $liveScore = $this->updateLiveScore($match, $innings, null, $managerId);
            $this->cacheScore($matchId, $liveScore);
            $this->broadcastScore($matchId, $liveScore);

            return $liveScore;
        });
    }

    private function updateInningsStats(Innings $innings, array $ballData): void
    {
        $runs = $ballData['runs'] ?? 0;
        $extrasType = $ballData['extras_type'] ?? null;

        $innings->total_runs += $runs;

        if (!empty($ballData['is_wicket']) && $extrasType !== 'no_ball') {
            $innings->total_wickets += 1;
        }

        // Only count legal deliveries toward the over count
        $isLegal = !in_array($extrasType, ['wide', 'no_ball'], true);
        if ($isLegal) {
            $innings->total_balls += 1;
        }

        // Calculate overs (6 balls per over)
        $innings->total_overs = floor($innings->total_balls / 6) + (($innings->total_balls % 6) / 10);

        // Add extras
        switch ($extrasType) {
            case 'wide':
                $innings->extras_wides += 1;
                break;
            case 'no_ball':
                $innings->extras_no_balls += 1;
                break;
            case 'bye':
                $innings->extras_byes += $runs;
                break;
            case 'leg_bye':
                $innings->extras_leg_byes += $runs;
                break;
        }

        // Track fall of wicket
        if (!empty($ballData['is_wicket']) && $extrasType !== 'no_ball') {
            $fow = $innings->fall_of_wickets ?? [];
            $fow[] = [
                'wicket_number' => $innings->total_wickets,
                'runs' => $innings->total_runs,
                'overs' => $innings->total_overs,
                'player_out_id' => $ballData['dismissed_player_id'] ?? null,
            ];
            $innings->fall_of_wickets = $fow;
        }
    }

    private function reverseInningsStats(Innings $innings, array $ballData): void
    {
        $runs = $ballData['runs'] ?? 0;
        $extrasType = $ballData['extras_type'] ?? null;

        $innings->total_runs -= $runs;

        if (!empty($ballData['is_wicket']) && $extrasType !== 'no_ball') {
            $innings->total_wickets -= 1;
            // Remove last fall of wicket
            $fow = $innings->fall_of_wickets ?? [];
            array_pop($fow);
            $innings->fall_of_wickets = $fow;
        }

        $isLegal = !in_array($extrasType, ['wide', 'no_ball'], true);
        if ($isLegal) {
            $innings->total_balls -= 1;
        }

        $innings->total_overs = $innings->total_balls > 0
            ? floor($innings->total_balls / 6) + (($innings->total_balls % 6) / 10)
            : 0.0;

        // Reverse extras
        switch ($extrasType) {
            case 'wide':
                $innings->extras_wides -= 1;
                break;
            case 'no_ball':
                $innings->extras_no_balls -= 1;
                break;
            case 'bye':
                $innings->extras_byes -= $runs;
                break;
            case 'leg_bye':
                $innings->extras_leg_byes -= $runs;
                break;
        }
    }

    private function updateLiveScore(
        MatchModel $match,
        Innings $innings,
        ?array $ballData,
        string $managerId
    ): LiveScore {
        $liveScore = $match->liveScore ?? new LiveScore(['match_id' => $match->id]);

        $liveScore->fill([
            'current_innings_id' => $innings->id,
            'batting_team_name' => $innings->battingTeam->name ?? null,
            'bowling_team_name' => $innings->bowlingTeam->name ?? null,
            'runs' => $innings->total_runs,
            'wickets' => $innings->total_wickets,
            'overs' => $innings->total_overs,
            'current_run_rate' => $innings->total_overs > 0
                ? round($innings->total_runs / $innings->total_overs, 2)
                : 0,
            'last_ball_result' => $ballData ? $this->describeBall($ballData) : null,
            'updated_by_cricket_manager_id' => $managerId,
            'full_snapshot' => $this->buildFullSnapshot($match, $innings),
        ]);

        // Calculate target and RRR for 2nd innings
        if ($match->current_innings_number > 1) {
            $firstInnings = $match->innings->where('innings_number', 1)->first();
            if ($firstInnings) {
                $target = $firstInnings->total_runs + 1;
                $liveScore->target = $target;
                $remainingOvers = ($match->overs_per_side * 6 - $innings->total_balls) / 6;
                $liveScore->required_run_rate = $remainingOvers > 0
                    ? round(($target - $innings->total_runs) / $remainingOvers, 2)
                    : null;
            }
        }

        $liveScore->save();
        return $liveScore->fresh();
    }

    private function buildFullSnapshot(MatchModel $match, Innings $innings): array
    {
        $latestDeliveries = collect($innings->deliveries ?? [])->take(-30)->values()->toArray();

        return [
            'match_id' => $match->id,
            'innings_number' => $innings->innings_number,
            'batting_team' => $innings->batting_team_id,
            'batting_team_name' => $innings->battingTeam->name ?? '',
            'bowling_team_name' => $innings->bowlingTeam->name ?? '',
            'score' => "{$innings->total_runs}/{$innings->total_wickets}",
            'overs' => $innings->total_overs,
            'target' => $match->liveScore?->target,
            'crr' => $match->liveScore?->current_run_rate,
            'rrr' => $match->liveScore?->required_run_rate,
            'extras' => [
                'wides' => $innings->extras_wides,
                'no_balls' => $innings->extras_no_balls,
                'byes' => $innings->extras_byes,
                'leg_byes' => $innings->extras_leg_byes,
                'total' => $innings->extras_wides + $innings->extras_no_balls
                    + $innings->extras_byes + $innings->extras_leg_byes,
            ],
            'fall_of_wickets' => $innings->fall_of_wickets,
            'recent_balls' => $latestDeliveries,
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

    private function generateCommentary(
        string $matchId,
        Innings $innings,
        array $ballData,
        string $managerId
    ): void {
        $overNumber = $innings->total_overs;
        $ballInOver = $innings->total_balls % 6;
        $ballCount = ($innings->total_balls % 6) + 1;

        $text = $this->buildCommentaryText($innings, $ballData, $overNumber, $ballCount);

        $eventType = 'ball';
        if (!empty($ballData['is_wicket'])) $eventType = 'wicket';
        elseif (($ballData['runs'] ?? 0) >= 6 && empty($ballData['extras_type'])) $eventType = 'boundary_six';
        elseif (($ballData['runs'] ?? 0) >= 4 && empty($ballData['extras_type'])) $eventType = 'boundary_four';
        elseif (in_array($ballData['extras_type'] ?? null, ['wide', 'no_ball'])) $eventType = $ballData['extras_type'];

        Commentary::create([
            'match_id' => $matchId,
            'ball_number' => $innings->total_balls,
            'over_number' => $overNumber,
            'commentary_text' => $text,
            'event_type' => $eventType,
            'cricket_manager_id' => $managerId,
        ]);
    }

    private function buildCommentaryText(Innings $innings, array $ballData, float $over, int $ballInOver): string
    {
        $runs = $ballData['runs'] ?? 0;
        $extras = $ballData['extras_type'] ?? null;
        $score = "{$innings->total_runs}/{$innings->total_wickets}";

        if (!empty($ballData['is_wicket'])) {
            $type = $ballData['wicket_type'] ?? 'OUT';
            return "Over {$over}.{$ballInOver}: {$type}! {$score} in {$innings->total_overs} overs.";
        }

        return match ($extras) {
            'wide' => "Over {$over}.{$ballInOver}: Wide ball. {$runs} run(s). {$score} in {$innings->total_overs} overs.",
            'no_ball' => "Over {$over}.{$ballInOver}: No ball! {$runs} run(s). {$score} in {$innings->total_overs} overs.",
            'bye' => "Over {$over}.{$ballInOver}: {$runs} bye(s). {$score} in {$innings->total_overs} overs.",
            'leg_bye' => "Over {$over}.{$ballInOver}: {$runs} leg bye(s). {$score} in {$innings->total_overs} overs.",
            default => match ((int) $runs) {
                0 => "Over {$over}.{$ballInOver}: Dot ball. {$score} in {$innings->total_overs} overs.",
                4 => "Over {$over}.{$ballInOver}: FOUR! {$score} in {$innings->total_overs} overs.",
                6 => "Over {$over}.{$ballInOver}: SIX! {$score} in {$innings->total_overs} overs.",
                default => "Over {$over}.{$ballInOver}: {$runs} run(s). {$score} in {$innings->total_overs} overs.",
            },
        };
    }

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
