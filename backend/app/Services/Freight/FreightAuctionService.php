<?php

namespace App\Services\Freight;

use App\Events\AuctionBidPlaced;
use App\Models\FreightBid;
use App\Models\FreightLoad;
use App\Services\Redis\RedisCacheService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — FREIGHT AUCTION MATCHING ENGINE
 * =============================================
 *
 * Automated background engine for freight load matching,
 * price bidding calculations, and automated truck assignment.
 *
 * TARGET MODULES:
 *   - Module 9D  (Goods Company Spot-Freight Auction)
 *   - Module 10D (Truck Owner Freight Auction Brokerage)
 *   - Module 11D (Truck Driver Location-Based Freight Bidding)
 *
 * MATCHING ALGORITHM (weighted scoring):
 *   score = (price_ratio × 0.45) + (rating × 0.30) + (proximity × 0.15) + (speed × 0.10)
 *
 *   - price_ratio:  How competitive the bid is vs. expected price (lower is better)
 *   - rating:       Bidder's historical rating (0.0–5.0, normalized to 0–1)
 *   - proximity:    Distance from vehicle to pickup (closer is better)
 *   - speed:        Estimated delivery speed (faster is better)
 *
 * SAFETY:
 *   - Entirely NEW service in App\Services\Freight namespace.
 *   - Uses only FreightLoad + FreightBid models.
 *   - Zero interaction with existing Factory/Driver/StoreKeeper code.
 *   - All matching operations in database transactions with row locking.
 */

class FreightAuctionService
{
    // Scoring weights (must sum to 1.0)
    private const W_PRICE = 0.45;
    private const W_RATING = 0.30;
    private const W_PROXIMITY = 0.15;
    private const W_SPEED = 0.10;

    public function __construct(
        private RedisCacheService $cache
    ) {}

    /**
     * Place a bid on a freight load.
     *
     * @throws \RuntimeException
     */
    public function placeBid(
        string $loadId,
        string $bidderId,
        string $bidderType,
        float $bidAmount,
        ?string $vehicleId = null,
        ?string $vehicleType = null,
        ?string $vehiclePlate = null,
        ?float $estimatedHours = null,
        ?float $bidderRating = null,
        ?float $proximityKm = null,
        ?string $notes = null,
    ): FreightBid {
        return DB::transaction(function () use (
            $loadId, $bidderId, $bidderType, $bidAmount,
            $vehicleId, $vehicleType, $vehiclePlate,
            $estimatedHours, $bidderRating, $proximityKm, $notes
        ) {
            $load = FreightLoad::lockForUpdate()->findOrFail($loadId);

            if (! $load->isBiddable()) {
                throw new \RuntimeException('This load is no longer accepting bids.');
            }

            // Transition to bidding if still open
            if ($load->status === FreightLoad::STATUS_OPEN) {
                $load->update(['status' => FreightLoad::STATUS_BIDDING]);
            }

            $bid = FreightBid::create([
                'id' => (string) \Illuminate\Support\Str::uuid(),
                'load_id' => $loadId,
                'bidder_id' => $bidderId,
                'bidder_type' => $bidderType,
                'bid_amount' => $bidAmount,
                'currency' => $load->currency,
                'vehicle_id' => $vehicleId,
                'vehicle_type' => $vehicleType,
                'vehicle_plate' => $vehiclePlate,
                'estimated_delivery_hours' => $estimatedHours,
                'bidder_rating' => $bidderRating ?? 0,
                'bidder_proximity_km' => $proximityKm,
                'notes' => $notes,
                'status' => FreightBid::STATUS_PENDING,
            ]);

            $load->increment('bid_count');

            Log::info('FreightAuctionService: bid placed', [
                'load_id' => $loadId,
                'bidder_id' => $bidderId,
                'bidder_type' => $bidderType,
                'amount' => $bidAmount,
                'total_bids' => $load->bid_count,
            ]);

            // Broadcast real-time bid notification
            AuctionBidPlaced::dispatch(
                loadId: $loadId,
                bidId: $bid->id,
                bidderId: $bidderId,
                bidderType: $bidderType,
                amount: $bidAmount,
                meta: [
                    'vehicle_id' => $vehicleId,
                    'vehicle_type' => $vehicleType,
                    'estimated_hours' => $estimatedHours,
                    'proximity_km' => $proximityKm,
                ]
            );

            // Cache active bid count
            $this->cache->set("freight:load:{$loadId}:bid_count", $load->bid_count, 3600);

            return $bid;
        });
    }

    /**
     * Execute the matching algorithm for a load.
     *
     * Computes scores for all pending bids, selects the winner,
     * updates statuses, and returns the winning bid.
     *
     * @return FreightBid|null  Winning bid, or null if no suitable match
     */
    public function matchLoad(FreightLoad|string $load): ?FreightBid
    {
        if (is_string($load)) {
            $load = FreightLoad::with('bids')->findOrFail($load);
        }

        return DB::transaction(function () use ($load) {
            $bids = FreightBid::where('load_id', $load->id)
                ->where('status', FreightBid::STATUS_PENDING)
                ->get();

            if ($bids->isEmpty()) {
                Log::info('FreightAuctionService: match — no bids to evaluate', [
                    'load_id' => $load->id,
                ]);
                return null;
            }

            // ─── Compute scores ────────────────────────
            $scoredBids = $bids->map(fn(FreightBid $bid) => $this->computeScore($bid, $load));

            // ─── Select winner (highest score) ─────────
            $winner = $scoredBids->sortByDesc('match_score')->first();

            // ─── Update winner ─────────────────────────
            FreightBid::where('id', $winner->id)->update([
                'match_score' => $winner->match_score,
                'status' => FreightBid::STATUS_ACCEPTED,
                'accepted_at' => now(),
            ]);

            // ─── Reject all others ─────────────────────
            FreightBid::where('load_id', $load->id)
                ->where('id', '!=', $winner->id)
                ->where('status', FreightBid::STATUS_PENDING)
                ->update([
                    'status' => FreightBid::STATUS_REJECTED,
                    'rejected_at' => now(),
                    'rejection_reason' => 'Another bidder was selected by the matching engine.',
                ]);

            // ─── Update load status ────────────────────
            $load->update([
                'status' => FreightLoad::STATUS_MATCHED,
                'matched_at' => now(),
                'winning_bid_id' => $winner->id,
            ]);

            Log::info('FreightAuctionService: match completed', [
                'load_id' => $load->id,
                'winning_bid_id' => $winner->id,
                'winning_bidder' => $winner->bidder_id,
                'winning_amount' => $winner->bid_amount,
                'winning_score' => $winner->match_score,
                'total_bids_evaluated' => $bids->count(),
            ]);

            // Cache match result
            $this->cache->set("freight:load:{$load->id}:winner", [
                'bid_id' => $winner->id,
                'bidder_id' => $winner->bidder_id,
                'amount' => $winner->bid_amount,
                'score' => $winner->match_score,
            ], 86400);

            return $winner->fresh();
        });
    }

    /**
     * Compute a weighted match score for a bid.
     */
    private function computeScore(FreightBid $bid, FreightLoad $load): FreightBid
    {
        // ─── Price score (0–1, lower bid → higher score) ──
        $priceRatio = $load->expected_price > 0
            ? max(0, 1 - ($bid->bid_amount / $load->expected_price))
            : 0.5;

        // ─── Rating score (0–1, normalized from 0–5 scale) ──
        $ratingScore = min(1.0, ($bid->bidder_rating ?? 0) / 5.0);

        // ─── Proximity score (0–1, closer → higher) ──────
        $proximityScore = 0.5; // default neutral
        if ($bid->bidder_proximity_km !== null && $bid->bidder_proximity_km > 0) {
            // Score decays: 0 km = 1.0, 500 km = 0.0
            $proximityScore = max(0, 1 - ($bid->bidder_proximity_km / 500));
        }

        // ─── Speed score (0–1, faster → higher) ───────────
        $speedScore = 0.5; // default neutral
        if ($bid->estimated_delivery_hours !== null && $bid->estimated_delivery_hours > 0) {
            // Score decays: 1 hour = 1.0, 72 hours = 0.0
            $speedScore = max(0, 1 - ($bid->estimated_delivery_hours / 72));
        }

        // ─── Weighted composite ──────────────────────────
        $score = ($priceRatio * self::W_PRICE)
               + ($ratingScore * self::W_RATING)
               + ($proximityScore * self::W_PROXIMITY)
               + ($speedScore * self::W_SPEED);

        $bid->match_score = round($score, 4);

        Log::debug('FreightAuctionService: bid scored', [
            'bid_id' => $bid->id,
            'price_ratio' => round($priceRatio, 4),
            'rating' => round($ratingScore, 4),
            'proximity' => round($proximityScore, 4),
            'speed' => round($speedScore, 4),
            'final_score' => $bid->match_score,
        ]);

        return $bid;
    }

    /**
     * Find all loads whose bidding deadline has passed and match them.
     * Called by the scheduled job or artisan command.
     *
     * @return int  Number of loads matched
     */
    public function matchAllExpiredLoads(): int
    {
        $expiredLoads = FreightLoad::whereIn('status', [
            FreightLoad::STATUS_OPEN,
            FreightLoad::STATUS_BIDDING,
        ])
            ->whereNotNull('bidding_deadline')
            ->where('bidding_deadline', '<=', now())
            ->get();

        $matched = 0;

        foreach ($expiredLoads as $load) {
            try {
                $winner = $this->matchLoad($load);
                if ($winner) {
                    $matched++;
                } else {
                    // No bids — mark as expired
                    $load->update(['status' => FreightLoad::STATUS_EXPIRED]);
                    Log::info('FreightAuctionService: load expired with no bids', [
                        'load_id' => $load->id,
                    ]);
                }
            } catch (\Throwable $e) {
                Log::error('FreightAuctionService: match failed for load', [
                    'load_id' => $load->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        if ($matched > 0) {
            Log::info('FreightAuctionService: batch matching completed', [
                'total_expired' => $expiredLoads->count(),
                'matched' => $matched,
            ]);
        }

        return $matched;
    }
}
