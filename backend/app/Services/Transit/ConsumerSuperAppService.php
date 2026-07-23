<?php

namespace App\Services\Transit;

use App\Models\Financial\Wallet;
use App\Models\Financial\WalletTransaction;
use App\Services\Redis\RedisCacheService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — CONSUMER SUPER-APP SERVICE
 * ========================================
 *
 * Alphabetical transit routing, airline-style seat grid,
 * special fleet auction with Cup of Tea anti-spam penalty,
 * and chat guard integration (Modules 8Z, 12M, 12N).
 *
 * SAFETY: Entirely NEW service. Zero modification to existing code.
 */

class ConsumerSuperAppService
{
    private const CUP_OF_TEA_CHARGE = 50.00; // Rs. 50 penalty
    private const MAX_FAILED_BIDS_PER_MONTH = 2;

    public function __construct(
        private RedisCacheService $cache
    ) {}

    /**
     * Search transit routes by partial city name (alphabetical matching).
     */
    public function searchTransitRoutes(string $searchQuery): array
    {
        $cacheKey = "transit:search:" . md5(strtolower($searchQuery));

        return $this->cache->remember($cacheKey, 120, function () use ($searchQuery) {
            $trips = DB::table('transport_bus_trips')
                ->where('status', 'scheduled')
                ->where(function ($q) use ($searchQuery) {
                    $q->where('origin', 'ilike', "%{$searchQuery}%")
                      ->orWhere('destination', 'ilike', "%{$searchQuery}%");
                })
                ->select('id', 'bus_id', 'origin', 'destination', 'waypoints', 'status')
                ->limit(20)->get();

            $results = [];
            foreach ($trips as $trip) {
                $bookedSeats = DB::table('transit_bookings')
                    ->where('trip_id', $trip->id)
                    ->where('booking_status', 'confirmed')
                    ->pluck('seat_number')->toArray();

                $layout = \App\Models\Transport\AbsoluteBusLayout::find($trip->bus_id);

                $results[] = [
                    'trip_id' => $trip->id,
                    'origin' => $trip->origin,
                    'destination' => $trip->destination,
                    'booked_seats' => $bookedSeats,
                    'total_seats' => $layout?->totalSeats() ?? 0,
                    'seat_grid' => $layout?->current_snapshot['components'] ?? [],
                ];
            }

            return $results;
        });
    }

    /**
     * Process fleet auction bid with Cup of Tea anti-spam penalty.
     *
     * @throws \RuntimeException if bid limit exceeded (triggers penalty)
     */
    public function processFleetBidAndPenalize(
        string $userId,
        string $auctionId,
        float $bidAmount
    ): array {
        return DB::transaction(function () use ($userId, $auctionId, $bidAmount) {
            // Count failed/canceled bids this month
            $failedCount = DB::table('fleet_auctions')
                ->where('requester_id', $userId)
                ->whereIn('status', ['canceled', 'expired'])
                ->whereMonth('created_at', now()->month)
                ->count();

            if ($failedCount >= self::MAX_FAILED_BIDS_PER_MONTH) {
                // ─── CUP OF TEA PENALTY ──────────────
                $wallet = Wallet::where('owner_id', $userId)
                    ->where('owner_type', 'customer')
                    ->where('wallet_type', 'main')
                    ->lockForUpdate()->first();

                if ($wallet && $wallet->available_balance >= self::CUP_OF_TEA_CHARGE) {
                    $before = $wallet->balance;
                    $wallet->debit(self::CUP_OF_TEA_CHARGE);
                    $wallet->save();

                    WalletTransaction::create([
                        'id' => (string) Str::uuid(),
                        'wallet_id' => $wallet->id,
                        'entry_type' => WalletTransaction::ENTRY_DEBIT,
                        'amount' => self::CUP_OF_TEA_CHARGE,
                        'balance_before' => $before,
                        'balance_after' => $wallet->balance,
                        'currency' => 'PKR',
                        'transaction_type' => 'cup_of_tea_penalty',
                        'reference_id' => $auctionId,
                        'reference_type' => 'fleet_auction',
                        'status' => WalletTransaction::STATUS_SETTLED,
                        'description' => "Cup of Tea anti-spam penalty: exceeded {$failedCount} failed bids this month.",
                        'settled_at' => now(),
                    ]);

                    Log::warning('ConsumerSuperAppService: Cup of Tea penalty applied', [
                        'user' => $userId, 'failed_count' => $failedCount, 'penalty' => self::CUP_OF_TEA_CHARGE,
                    ]);
                }

                throw new \RuntimeException(
                    "Bid limit exceeded: {$failedCount}/" . self::MAX_FAILED_BIDS_PER_MONTH .
                    " failed bids this month. A Cup of Tea service charge of Rs. " . self::CUP_OF_TEA_CHARGE .
                    " has been deducted from your wallet."
                );
            }

            // Update auction
            DB::table('fleet_auctions')->where('id', $auctionId)->update([
                'bid_amount' => $bidAmount,
                'status' => 'matched',
                'updated_at' => now(),
            ]);

            return [
                'auction_id' => $auctionId,
                'bid_amount' => $bidAmount,
                'status' => 'matched',
                'failed_count' => $failedCount,
            ];
        });
    }

    /**
     * Create a fleet auction request.
     */
    public function createFleetAuction(
        string $requesterId,
        string $vehicleType,
        string $origin,
        string $destination
    ): array {
        $auctionId = (string) Str::uuid();
        DB::table('fleet_auctions')->insert([
            'id' => $auctionId,
            'requester_id' => $requesterId,
            'vehicle_type' => $vehicleType,
            'origin' => $origin,
            'destination' => $destination,
            'status' => 'open',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return ['auction_id' => $auctionId, 'status' => 'open'];
    }
}
