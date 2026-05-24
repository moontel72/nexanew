<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — AUCTION BID PLACED EVENT
 * =====================================
 *
 * Real-time bidding notification for:
 *   - Module 9D  (Goods Company Spot-Freight Auction)
 *   - Module 10D (Truck Owner Freight Auction Brokerage)
 *   - Module 11D (Truck Driver Location-Based Bidding)
 *   - Module 12  (B2B Marketplace RFQ)
 *
 * SAFETY: Default driver = 'log'. Independent of any existing controller.
 *
 * CHANNEL: auction.{load_id}
 *
 * USAGE:
 *   event(new AuctionBidPlaced($loadId, $bidId, $bidderId, $bidderType, $amount));
 */

class AuctionBidPlaced implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $loadId;
    public string $bidId;
    public string $bidderId;
    public string $bidderType;
    public float $amount;
    public array $meta;

    /**
     * @param string $loadId      The freight load being bid on
     * @param string $bidId       Unique bid identifier
     * @param string $bidderId    Truck owner or driver ID who placed the bid
     * @param string $bidderType  'truck_owner' | 'truck_driver' | 'goods_company'
     * @param float  $amount      Bid amount in base currency
     * @param array  $meta        { bidder_name, vehicle_id, estimated_delivery, ... }
     */
    public function __construct(
        string $loadId,
        string $bidId,
        string $bidderId,
        string $bidderType,
        float $amount,
        array $meta = []
    ) {
        $this->loadId = $loadId;
        $this->bidId = $bidId;
        $this->bidderId = $bidderId;
        $this->bidderType = $bidderType;
        $this->amount = $amount;
        $this->meta = $meta;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel("auction.{$this->loadId}"),
        ];
    }

    public function broadcastAs(): string
    {
        return 'AuctionBidPlaced';
    }

    public function broadcastWith(): array
    {
        $payload = [
            'load_id' => $this->loadId,
            'bid_id' => $this->bidId,
            'bidder_id' => $this->bidderId,
            'bidder_type' => $this->bidderType,
            'amount' => $this->amount,
            'timestamp' => now()->toIso8601String(),
        ];

        $safeMeta = array_filter($this->meta, fn($v) => is_scalar($v) || is_array($v));
        return array_merge($payload, $safeMeta);
    }

    public function broadcastWhen(): bool
    {
        if (config('broadcasting.default') === 'log') {
            Log::info('AuctionBidPlaced (log-only mode)', [
                'load_id' => $this->loadId,
                'bidder_id' => $this->bidderId,
                'amount' => $this->amount,
            ]);
        }
        return true;
    }
}
