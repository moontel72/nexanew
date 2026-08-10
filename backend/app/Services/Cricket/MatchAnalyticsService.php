<?php

namespace App\Services\Cricket;

use App\Models\Cricket\Innings;
use App\Models\Cricket\MatchModel;
use Illuminate\Support\Facades\DB;

/**
 * MatchAnalyticsService — Computes Wagon Wheel, run distribution,
 * conceded runs analysis, and partnership data for a match/innings.
 */
class MatchAnalyticsService
{
    /**
     * Get wagon wheel data for a batsman in a match.
     * Returns array of {runs, direction_degrees, x, y, is_boundary}
     *
     * Shot direction mapping (0-360 degrees, 0 = straight down pitch V):
     *   - Off-side: 180°–360° (cover, point, third man)
     *   - Leg-side: 0°–180° (mid-wicket, square leg, fine leg)
     */
    public function getWagonWheel(string $matchId, ?string $batsmanId = null): array
    {
        $innings = Innings::where('match_id', $matchId)
            ->where('status', '!=', 'yet_to_bat')
            ->get();

        $shots = [];

        foreach ($innings as $inn) {
            $deliveries = $inn->deliveries ?? [];
            foreach ($deliveries as $ball) {
                if ($batsmanId && ($ball['batsman_id'] ?? null) !== $batsmanId) {
                    continue;
                }

                $runs = $ball['runs'] ?? 0;
                $direction = $ball['shot_direction'] ?? null;

                $shots[] = [
                    'runs' => $runs,
                    'direction' => $direction ?? $this->estimateDirection($runs),
                    'x' => $ball['shot_x'] ?? null,
                    'y' => $ball['shot_y'] ?? null,
                    'is_boundary' => $runs >= 4,
                    'is_wicket' => !empty($ball['is_wicket']),
                    'extras_type' => $ball['extras_type'] ?? null,
                    'over' => $ball['over_number'] ?? ($inn->total_overs),
                ];
            }
        }

        return $shots;
    }

    /**
     * Get run distribution for a match.
     * Returns: {total_runs, dot_balls, singles, twos, threes, fours, sixes, extras}
     */
    public function getRunDistribution(string $matchId): array
    {
        $innings = Innings::where('match_id', $matchId)->get();

        $distribution = [
            'dot_balls' => 0,
            'singles' => 0,
            'twos' => 0,
            'threes' => 0,
            'fours' => 0,
            'sixes' => 0,
            'extras_wides' => 0,
            'extras_no_balls' => 0,
            'extras_byes' => 0,
            'extras_leg_byes' => 0,
            'total_runs' => 0,
            'total_balls' => 0,
        ];

        foreach ($innings as $inn) {
            $deliveries = $inn->deliveries ?? [];
            foreach ($deliveries as $ball) {
                $runs = $ball['runs'] ?? 0;
                $extras = $ball['extras_type'] ?? null;

                $distribution['total_runs'] += $runs;
                $distribution['total_balls']++;

                if ($extras) {
                    match ($extras) {
                        'wide' => $distribution['extras_wides']++,
                        'no_ball' => $distribution['extras_no_balls']++,
                        'bye' => $distribution['extras_byes'] += $runs,
                        'leg_bye' => $distribution['extras_leg_byes'] += $runs,
                        default => null,
                    };
                    continue;
                }

                match ((int)$runs) {
                    0 => $distribution['dot_balls']++,
                    1 => $distribution['singles']++,
                    2 => $distribution['twos']++,
                    3 => $distribution['threes']++,
                    4 => $distribution['fours']++,
                    6 => $distribution['sixes']++,
                    default => null,
                };
            }
        }

        return $distribution;
    }

    /**
     * Get off-side vs leg-side split.
     */
    public function getSideSplit(string $matchId): array
    {
        $shots = $this->getWagonWheel($matchId);

        $offSideRuns = 0;
        $legSideRuns = 0;
        $offSideCount = 0;
        $legSideCount = 0;

        foreach ($shots as $shot) {
            $dir = $shot['direction'] ?? 0;
            $runs = $shot['runs'] ?? 0;

            if ($dir >= 180 && $dir <= 360) {
                $offSideRuns += $runs;
                $offSideCount++;
            } else {
                $legSideRuns += $runs;
                $legSideCount++;
            }
        }

        return [
            'off_side' => ['runs' => $offSideRuns, 'count' => $offSideCount],
            'leg_side' => ['runs' => $legSideRuns, 'count' => $legSideCount],
        ];
    }

    /**
     * Get conceded runs breakdown for a bowler.
     * Returns percentage of 1s, 2s, 3s, 4s, 6s, and extras conceded.
     */
    public function getConcededRunsBreakdown(string $matchId, ?string $bowlerId = null): array
    {
        $innings = Innings::where('match_id', $matchId)->get();

        $breakdown = ['singles' => 0, 'twos' => 0, 'threes' => 0, 'fours' => 0, 'sixes' => 0, 'extras' => 0];
        $total = 0;

        foreach ($innings as $inn) {
            $deliveries = $inn->deliveries ?? [];
            foreach ($deliveries as $ball) {
                if ($bowlerId && ($ball['bowler_id'] ?? null) !== $bowlerId) continue;

                $runs = $ball['runs'] ?? 0;
                $extras = $ball['extras_type'] ?? null;

                if ($extras) {
                    $breakdown['extras'] += $runs;
                    $total += $runs;
                    continue;
                }

                $total += $runs;
                match ((int)$runs) {
                    1 => $breakdown['singles']++,
                    2 => $breakdown['twos'] += 2,
                    3 => $breakdown['threes'] += 3,
                    4 => $breakdown['fours'] += 4,
                    6 => $breakdown['sixes'] += 6,
                    default => null,
                };
            }
        }

        // Compute percentages
        $percentages = [];
        foreach ($breakdown as $key => $value) {
            $percentages[$key] = [
                'runs' => $value,
                'percentage' => $total > 0 ? round(($value / $total) * 100, 1) : 0,
            ];
        }

        return [
            'breakdown' => $percentages,
            'total_conceded' => $total,
        ];
    }

    /**
     * Get partnership data for current innings.
     */
    public function getPartnerships(string $matchId): array
    {
        $innings = Innings::where('match_id', $matchId)
            ->where('status', '!=', 'yet_to_bat')
            ->get();

        $partnerships = [];

        foreach ($innings as $inn) {
            $deliveries = $inn->deliveries ?? [];
            $currentPartnership = ['batsman1' => null, 'batsman2' => null, 'runs' => 0, 'balls' => 0];
            $partnershipList = [];

            foreach ($deliveries as $ball) {
                $batsman = $ball['batsman_id'] ?? 'unknown';
                $isWicket = !empty($ball['is_wicket']);

                if ($currentPartnership['batsman1'] === null) {
                    $currentPartnership['batsman1'] = $batsman;
                } elseif ($currentPartnership['batsman2'] === null && $batsman !== $currentPartnership['batsman1']) {
                    $currentPartnership['batsman2'] = $batsman;
                }

                $currentPartnership['runs'] += $ball['runs'] ?? 0;
                if (empty($ball['extras_type']) || !in_array($ball['extras_type'], ['wide', 'no_ball'])) {
                    $currentPartnership['balls']++;
                }

                if ($isWicket) {
                    $partnershipList[] = $currentPartnership;
                    $currentPartnership = ['batsman1' => null, 'batsman2' => null, 'runs' => 0, 'balls' => 0];
                }
            }

            // Add last partnership if not ended by wicket
            if ($currentPartnership['batsman1'] !== null && $currentPartnership['runs'] > 0) {
                $partnershipList[] = $currentPartnership;
            }

            $partnerships["innings_{$inn->innings_number}"] = $partnershipList;
        }

        return $partnerships;
    }

    /**
     * Estimate shot direction based on runs when direction not stored.
     * This is a heuristic fallback.
     */
    private function estimateDirection(int $runs): ?int
    {
        return match ($runs) {
            0 => null, // dot ball — no direction needed
            1 => 270,  // off-side (cover-ish)
            2 => 225,  // off-side boundary
            3 => 90,   // leg-side
            4 => 315,  // off-side boundary (cover drive)
            6 => 180,  // leg-side (mid-wicket) or straight
            default => 270,
        };
    }
}
