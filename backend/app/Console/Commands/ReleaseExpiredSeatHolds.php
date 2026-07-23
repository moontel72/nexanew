<?php

namespace App\Console\Commands;

use App\Events\SeatHeldUpdated;
use App\Services\Transport\SeatHoldService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — RELEASE EXPIRED SEAT HOLDS
 * =======================================
 *
 * Scheduled command that runs every 30 seconds to prune
 * expired seat holds (hold_expires_at < NOW()) and broadcast
 * WebSocket events so passenger apps see the freed seats
 * in real time.
 *
 * SAFETY:
 *   - Only deletes rows past their TTL wallclock.
 *   - Broadcasts per-trip snapshots so all passengers
 *     watching a trip see the updated availability instantly.
 *   - Non-fatal: broadcast failures are logged but don't
 *     block cleanup.
 *
 * TARGET MODULES: 8V, 14E
 */
class ReleaseExpiredSeatHolds extends Command
{
    protected $signature   = 'bus:release-expired-holds';
    protected $description = 'Prune expired seat holds and broadcast freed seats via WebSocket';

    /**
     * Maximum batch size per execution.
     */
    private const MAX_DELETIONS = 500;

    public function handle(): int
    {
        // ─── Fetch expired holds (batched by trip for grouped broadcasts) ──
        $expired = DB::table('transport_seat_holds')
            ->where('hold_expires_at', '<', now())
            ->select('id', 'trip_id', 'layout_id', 'seat_number', 'hold_expires_at')
            ->limit(self::MAX_DELETIONS)
            ->get();

        if ($expired->isEmpty()) {
            return Command::SUCCESS;
        }

        // Group by trip_id so we broadcast one event per trip
        $byTrip = $expired->groupBy('trip_id');

        $holdIdsToDelete = $expired->pluck('id')->toArray();
        $totalReleased   = count($holdIdsToDelete);

        // ─── Delete all expired holds in one query ─────
        DB::table('transport_seat_holds')
            ->whereIn('id', $holdIdsToDelete)
            ->delete();

        // ─── Broadcast per-trip seat snapshots ──────────
        $holdService = app(SeatHoldService::class);

        foreach ($byTrip as $tripId => $rows) {
            $layoutId   = $rows->first()->layout_id;
            $seatNums   = $rows->pluck('seat_number')->map(fn($v) => (int) $v)->toArray();

            try {
                // Build fresh snapshot AFTER deletion
                $heldSeats   = $holdService->getHeldSeatNumbers($tripId);
                $bookedSeats = DB::table('transport_seat_bookings')
                    ->where('trip_id', $tripId)
                    ->whereIn('status', ['booked', 'confirmed', 'boarded'])
                    ->pluck('seat_number')
                    ->map(fn($v) => (int) $v)
                    ->toArray();

                $layout = \App\Models\Transport\AbsoluteBusLayout::find($layoutId);
                $totalCount = $layout?->totalSeats() ?? 0;

                $available = $totalCount - count($heldSeats) - count($bookedSeats);

                broadcast(new SeatHeldUpdated(
                    tripId:        $tripId,
                    event:         'released',
                    seatNumbers:   $seatNums,
                    heldSeats:     $heldSeats,
                    bookedSeats:   $bookedSeats,
                    totalSeats:    $totalCount,
                    availableSeats: max(0, $available),
                ));

            } catch (\Exception $e) {
                Log::warning('ReleaseExpiredSeatHolds: broadcast failed for trip', [
                    'trip_id' => $tripId,
                    'error'   => $e->getMessage(),
                ]);
            }
        }

        Log::info('ReleaseExpiredSeatHolds: cleaned up expired holds', [
            'released_count' => $totalReleased,
            'trips_affected' => $byTrip->count(),
        ]);

        $this->info("Released {$totalReleased} expired holds across {$byTrip->count()} trips.");

        // If we hit the batch limit, signal that more work remains
        if ($totalReleased >= self::MAX_DELETIONS) {
            $this->warn('Batch limit reached. More holds may remain.');
        }

        return Command::SUCCESS;
    }
}
