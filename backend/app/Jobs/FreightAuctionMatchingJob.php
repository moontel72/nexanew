<?php

namespace App\Jobs;

use App\Services\Freight\FreightAuctionService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — FREIGHT AUCTION MATCHING JOB
 * ==========================================
 *
 * Async background job that executes the freight auction matching
 * engine when a load's bidding deadline expires.
 *
 * TARGET MODULES: 9D, 10D, 11D
 *
 * DISPATCH:
 *   // When a load's bidding deadline is set:
 *   FreightAuctionMatchingJob::dispatch($loadId)
 *       ->delay($load->bidding_deadline);
 *
 *   // Or for immediate matching:
 *   FreightAuctionMatchingJob::dispatch($loadId);
 *
 *   // Or for batch expiry processing (scheduled):
 *   FreightAuctionMatchingJob::dispatch(); // no args = match all expired
 *
 * QUEUE: auctions (Redis)
 * TIMEOUT: 120 seconds
 * RETRIES: 2
 *
 * SAFETY:
 *   - Entirely NEW job. Uses only FreightAuctionService + FreightLoad/FreightBid.
 *   - Zero interaction with existing Factory/Driver/StoreKeeper code.
 */

class FreightAuctionMatchingJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $timeout = 120;
    public int $tries = 2;
    public int $maxExceptions = 2;

    private ?string $loadId;

    /**
     * @param string|null $loadId  Specific load to match, or null to match all expired
     */
    public function __construct(?string $loadId = null)
    {
        $this->loadId = $loadId;
        $this->queue = 'auctions';
        $this->connection = 'redis';
    }

    public function handle(FreightAuctionService $auction): void
    {
        if ($this->loadId) {
            // ─── Match a single load ───────────────────
            Log::info('FreightAuctionMatchingJob: matching single load', [
                'load_id' => $this->loadId,
            ]);

            $winner = $auction->matchLoad($this->loadId);

            if ($winner) {
                Log::info('FreightAuctionMatchingJob: winner selected', [
                    'load_id' => $this->loadId,
                    'winning_bid_id' => $winner->id,
                    'winning_bidder' => $winner->bidder_id,
                    'amount' => $winner->bid_amount,
                    'score' => $winner->match_score,
                ]);
            } else {
                Log::info('FreightAuctionMatchingJob: no winner found', [
                    'load_id' => $this->loadId,
                ]);
            }
        } else {
            // ─── Batch match all expired loads ──────────
            Log::info('FreightAuctionMatchingJob: batch matching all expired loads');

            $matched = $auction->matchAllExpiredLoads();

            Log::info('FreightAuctionMatchingJob: batch complete', [
                'matched_count' => $matched,
            ]);
        }
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('FreightAuctionMatchingJob: FAILED', [
            'load_id' => $this->loadId,
            'error' => $exception->getMessage(),
            'trace' => $exception->getTraceAsString(),
        ]);
    }
}
