<?php

namespace App\Services\Marketplace;

use App\Events\AuctionBidPlaced;
use App\Models\Marketplace\GroupBuyPool;
use App\Models\Marketplace\PoolParticipant;
use App\Models\Marketplace\ProductListing;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — GROUP BUY POOL SERVICE
 * ====================================
 *
 * Multi-buyer order pooling engine for the B2B Marketplace (Module 12D).
 *
 * Enables individual retail shopkeepers to bundle their order requirements
 * together to unlock bulk pricing tiers from factories.
 *
 * POOL LIFECYCLE:
 *   open → gathering → locked → ordered → completed
 *                               ↓
 *                           cancelled / expired
 *
 * SAFETY:
 *   - Entirely NEW service in App\Services\Marketplace namespace.
 *   - Uses only marketplace-specific models and tables.
 *   - Zero interaction with existing Factory/Driver/StoreKeeper code.
 *   - All operations wrapped in database transactions.
 *
 * USAGE:
 *   $poolService = app(GroupBuyPoolService::class);
 *   $pool = $poolService->createPool($listingId, $initiatorId, 1000, $price, $deadline);
 *   $participant = $poolService->joinPool($pool->id, $companyId, 200);
 *   $poolService->lockPool($pool->id);
 */

class GroupBuyPoolService
{
    /**
     * Create a new group buy pool.
     *
     * @param string   $listingId    Product listing to pool
     * @param string   $initiatorId  Company initiating the pool
     * @param int      $targetQty    Total quantity needed to unlock bulk price
     * @param float    $poolPrice    Discounted price per unit when pool fills
     * @param string   $deadline     ISO datetime for gathering deadline
     * @param int      $minParts     Minimum participants (default 2)
     * @param int|null $maxParts     Maximum participants (null = unlimited)
     *
     * @return GroupBuyPool
     */
    public function createPool(
        string $listingId,
        string $initiatorId,
        int $targetQty,
        float $poolPrice,
        string $deadline,
        int $minParts = 2,
        ?int $maxParts = null
    ): GroupBuyPool {
        $listing = ProductListing::findOrFail($listingId);

        // Prevent duplicate active pools on same listing
        $existing = GroupBuyPool::where('product_listing_id', $listingId)
            ->active()
            ->exists();

        if ($existing) {
            throw new \RuntimeException('An active group buy pool already exists for this listing.');
        }

        $originalPrice = $listing->base_price;
        $discount = $originalPrice > 0
            ? round((($originalPrice - $poolPrice) / $originalPrice) * 100, 2)
            : 0;

        $pool = GroupBuyPool::create([
            'id' => (string) Str::uuid(),
            'product_listing_id' => $listingId,
            'initiator_company_id' => $initiatorId,
            'target_quantity' => $targetQty,
            'current_committed_quantity' => 0,
            'min_participants' => $minParts,
            'max_participants' => $maxParts,
            'pool_price_per_unit' => $poolPrice,
            'original_price_per_unit' => $originalPrice,
            'discount_percentage' => $discount,
            'pool_status' => GroupBuyPool::STATUS_OPEN,
            'gathering_deadline' => $deadline,
        ]);

        Log::info('GroupBuyPoolService: pool created', [
            'pool_id' => $pool->id,
            'listing_id' => $listingId,
            'target_qty' => $targetQty,
            'pool_price' => $poolPrice,
            'discount_pct' => $discount,
        ]);

        // Broadcast pool creation as auction event
        AuctionBidPlaced::dispatch(
            loadId: $listingId,
            bidId: $pool->id,
            bidderId: $initiatorId,
            bidderType: 'group_pool',
            amount: $poolPrice * $targetQty,
            meta: [
                'pool_type' => 'group_buy',
                'target_quantity' => $targetQty,
                'discount_percentage' => $discount,
                'deadline' => $deadline,
            ]
        );

        return $pool;
    }

    /**
     * A company joins an existing group buy pool.
     *
     * @return PoolParticipant
     */
    public function joinPool(string $poolId, string $companyId, int $quantity): PoolParticipant
    {
        return DB::transaction(function () use ($poolId, $companyId, $quantity) {
            $pool = GroupBuyPool::lockForUpdate()->findOrFail($poolId);

            if (! $pool->canBeJoined()) {
                throw new \RuntimeException('This pool is no longer accepting participants.');
            }

            if ($pool->initiator_company_id === $companyId) {
                throw new \RuntimeException('Pool initiator cannot join their own pool as a participant.');
            }

            // Prevent duplicate participation
            $existing = PoolParticipant::where('pool_id', $poolId)
                ->where('participant_company_id', $companyId)
                ->exists();

            if ($existing) {
                throw new \RuntimeException('Company already participating in this pool.');
            }

            $remainingQty = $pool->target_quantity - $pool->current_committed_quantity;
            $effectiveQty = min($quantity, $remainingQty);
            $amount = $effectiveQty * $pool->pool_price_per_unit;

            $participant = PoolParticipant::create([
                'id' => (string) Str::uuid(),
                'pool_id' => $poolId,
                'participant_company_id' => $companyId,
                'committed_quantity' => $effectiveQty,
                'committed_amount' => $amount,
                'participation_status' => PoolParticipant::STATUS_COMMITTED,
            ]);

            // Update pool committed quantity
            $pool->increment('current_committed_quantity', $effectiveQty);

            // Transition pool to 'gathering' if still 'open'
            if ($pool->pool_status === GroupBuyPool::STATUS_OPEN) {
                $pool->update(['pool_status' => GroupBuyPool::STATUS_GATHERING]);
            }

            // Auto-lock pool if target reached
            $pool->refresh();
            if ($pool->current_committed_quantity >= $pool->target_quantity) {
                $this->lockPool($pool);
            }

            Log::info('GroupBuyPoolService: participant joined', [
                'pool_id' => $poolId,
                'company_id' => $companyId,
                'quantity' => $effectiveQty,
                'pool_progress' => $pool->progressPercentage() . '%',
            ]);

            return $participant;
        });
    }

    /**
     * Lock a pool — prevents further joins and prepares for order placement.
     */
    public function lockPool(GroupBuyPool|string $pool): GroupBuyPool
    {
        if (is_string($pool)) {
            $pool = GroupBuyPool::findOrFail($pool);
        }

        if (! $pool->isOpen()) {
            throw new \RuntimeException('Pool is not in an open state and cannot be locked.');
        }

        $participantCount = $pool->participants()->count();

        if ($participantCount < $pool->min_participants) {
            throw new \RuntimeException(
                "Pool requires at least {$pool->min_participants} participants. Currently: {$participantCount}."
            );
        }

        $pool->update([
            'pool_status' => GroupBuyPool::STATUS_LOCKED,
            'locked_at' => now(),
        ]);

        Log::info('GroupBuyPoolService: pool locked', [
            'pool_id' => $pool->id,
            'participants' => $participantCount,
            'total_committed' => $pool->current_committed_quantity,
        ]);

        return $pool;
    }

    /**
     * Cancel a pool (initiator only or expired deadline).
     */
    public function cancelPool(string $poolId, string $reason = ''): GroupBuyPool
    {
        $pool = GroupBuyPool::findOrFail($poolId);

        if (! $pool->isOpen()) {
            throw new \RuntimeException('Only open/gathering pools can be cancelled.');
        }

        $pool->update([
            'pool_status' => GroupBuyPool::STATUS_CANCELLED,
            'cancelled_at' => now(),
            'cancellation_reason' => $reason,
        ]);

        Log::info('GroupBuyPoolService: pool cancelled', [
            'pool_id' => $poolId,
            'reason' => $reason,
        ]);

        return $pool;
    }

    /**
     * Mark pool as ordered (after escrow payment confirmed).
     */
    public function markOrdered(string $poolId, string $orderId): GroupBuyPool
    {
        $pool = GroupBuyPool::findOrFail($poolId);

        $pool->update([
            'pool_status' => GroupBuyPool::STATUS_ORDERED,
            'ordered_at' => now(),
            'order_id' => $orderId,
        ]);

        // Confirm all participants
        $pool->participants()->update([
            'participation_status' => PoolParticipant::STATUS_CONFIRMED,
        ]);

        Log::info('GroupBuyPoolService: pool ordered', [
            'pool_id' => $poolId,
            'order_id' => $orderId,
        ]);

        return $pool;
    }

    /**
     * Mark pool as completed (after delivery confirmed).
     */
    public function markCompleted(string $poolId): GroupBuyPool
    {
        $pool = GroupBuyPool::findOrFail($poolId);

        $pool->update([
            'pool_status' => GroupBuyPool::STATUS_COMPLETED,
            'completed_at' => now(),
        ]);

        Log::info('GroupBuyPoolService: pool completed', ['pool_id' => $poolId]);

        return $pool;
    }

    /**
     * Auto-expire pools past their gathering deadline.
     * Intended to be called from a scheduled command.
     *
     * @return int Number of pools expired
     */
    public function expireOverduePools(): int
    {
        $expired = GroupBuyPool::active()
            ->whereNotNull('gathering_deadline')
            ->where('gathering_deadline', '<', now())
            ->update([
                'pool_status' => GroupBuyPool::STATUS_EXPIRED,
            ]);

        if ($expired > 0) {
            Log::info('GroupBuyPoolService: expired overdue pools', ['count' => $expired]);
        }

        return $expired;
    }
}
