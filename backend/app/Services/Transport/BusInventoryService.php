<?php

namespace App\Services\Transport;

use App\Models\Financial\Wallet;
use App\Models\Financial\WalletTransaction;
use App\Models\Transport\BusLayout;
use App\Models\Transport\BusQrCode;
use App\Models\Transport\NexatraceVoucher;
use App\Services\Financial\CommissionService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS INVENTORY & TICKETING SERVICE
 * ==============================================
 *
 * Race-safe seat booking, QR code gate automation,
 * and 3-way tiered payment engine with voucher split-logic.
 *
 * PAYMENT METHODS (Module 8W):
 *   1. wallet    — Direct NexaTrace wallet deduction
 *   2. card      — Standard debit/credit card gateway
 *   3. voucher   — Physical NexaTrace vouchers (Kirana shops)
 *
 * VOUCHER SPLIT LOGIC:
 *   Customer buys Rs. 1,000 voucher. Ticket costs Rs. 930.
 *   → Rs. 930 paid to Bus Owner
 *   → Rs. 70 credited to Customer's NexaTrace Wallet as instant change
 *
 * RACE SAFETY:
 *   - All seat bookings use lockForUpdate() on bus_layouts.
 *   - Voucher redemption uses lockForUpdate() on vouchers row.
 *   - All operations wrapped in DB::transaction().
 *
 * SAFETY:
 *   - Entirely NEW service in App\Services\Transport namespace.
 *   - Integrates with Step 8 CommissionService for double-entry ledger.
 *   - Zero modification to existing code.
 */

class BusInventoryService
{
    public function __construct(
        private CommissionService $ledger
    ) {}

    /**
     * Scan a bus door QR code and return live bus data.
     */
    public function scanGateQr(string $qrPayloadUuid): array
    {
        $qr = BusQrCode::where('qr_payload_uuid', $qrPayloadUuid)
            ->where('is_active', true)
            ->with('busLayout')
            ->firstOrFail();

        $layout = $qr->busLayout;
        $bookedSeats = $this->getBookedSeats($layout->id, $qr->active_trip_id);

        return [
            'bus_registration' => $layout->bus_id,
            'route_origin' => $qr->active_trip_id ? 'Active Trip' : 'No active trip',
            'route_destination' => $qr->active_trip_id ? 'Trip Destination' : 'N/A',
            'total_seats' => $layout->totalSeats(),
            'available_seats' => $layout->totalSeats() - count($bookedSeats),
            'seat_grid' => $layout->raw_grid_json,
            'booked_seat_numbers' => $bookedSeats,
            'active_trip_id' => $qr->active_trip_id,
        ];
    }

    /**
     * Book a seat with race-safe locking.
     *
     * @param string $busId       Bus layout ID
     * @param string $tripId      Active trip ID
     * @param string $userId      Customer booking
     * @param int    $seatNumber  Seat to book
     * @param string $paymentMethod  wallet | card | voucher
     * @param float  $ticketPrice Ticket price
     * @param string|null $voucherCode Plaintext voucher code (required if paymentMethod=voucher)
     * @param string $busOwnerId  Bus owner receiving payment
     * @return array
     */
    public function bookSeat(
        string $busId,
        string $tripId,
        string $userId,
        int $seatNumber,
        string $paymentMethod,
        float $ticketPrice,
        ?string $voucherCode = null,
        string $busOwnerId = '',
    ): array {
        return DB::transaction(function () use (
            $busId, $tripId, $userId, $seatNumber,
            $paymentMethod, $ticketPrice, $voucherCode, $busOwnerId
        ) {
            // ─── Lock bus layout (prevents double-booking) ──
            $layout = BusLayout::where('bus_id', $busId)
                ->lockForUpdate()->firstOrFail();

            // Check seat availability
            $bookedSeats = $this->getBookedSeats($layout->id, $tripId);
            if (in_array($seatNumber, $bookedSeats)) {
                throw new \RuntimeException("Seat {$seatNumber} is already booked.");
            }

            // Validate seat exists in grid
            $allSeats = $this->flattenSeatNumbers($layout->raw_grid_json);
            if (! in_array($seatNumber, $allSeats)) {
                throw new \RuntimeException("Seat {$seatNumber} does not exist in this bus layout.");
            }

            // ─── Process payment ────────────────────────
            $paymentResult = $this->processPayment(
                userId: $userId,
                ticketPrice: $ticketPrice,
                paymentMethod: $paymentMethod,
                voucherCode: $voucherCode,
                busOwnerId: $busOwnerId,
            );

            // ─── Record booking ─────────────────────────
            $bookingId = (string) Str::uuid();

            DB::table('transport_seat_bookings')->insert([
                'id' => $bookingId,
                'bus_layout_id' => $layout->id,
                'trip_id' => $tripId,
                'user_id' => $userId,
                'seat_number' => $seatNumber,
                'payment_method' => $paymentMethod,
                'ticket_price' => $ticketPrice,
                'status' => 'booked',
                'booked_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            Log::info('BusInventoryService: seat booked', [
                'bus_id' => $busId, 'seat' => $seatNumber,
                'payment_method' => $paymentMethod, 'price' => $ticketPrice,
            ]);

            return [
                'booking_id' => $bookingId,
                'bus_id' => $busId,
                'seat_number' => $seatNumber,
                'payment' => $paymentResult,
            ];
        });
    }

    /**
     * 3-Way Payment Processor.
     */
    private function processPayment(
        string $userId,
        float $ticketPrice,
        string $paymentMethod,
        ?string $voucherCode,
        string $busOwnerId,
    ): array {
        return match ($paymentMethod) {
            'wallet' => $this->payByWallet($userId, $ticketPrice, $busOwnerId),
            'card' => $this->payByCard($userId, $ticketPrice, $busOwnerId),
            'voucher' => $this->payByVoucher($userId, $ticketPrice, (string) $voucherCode, $busOwnerId),
            default => throw new \RuntimeException("Unknown payment method: {$paymentMethod}"),
        };
    }

    /**
     * Wallet deduction → bus owner credit (via Step 8 ledger).
     */
    private function payByWallet(string $userId, float $ticketPrice, string $busOwnerId): array
    {
        return $this->ledger->processPayout(
            module: 'bus_ticket',
            payerType: 'customer',
            payerId: $userId,
            payeeId: $busOwnerId,
            payeeType: 'bus_owner',
            amount: $ticketPrice,
            referenceId: (string) Str::uuid(),
            referenceType: 'bus_ticket',
            currency: 'PKR',
        );
    }

    /**
     * Card payment — stub (routes through payment gateway).
     */
    private function payByCard(string $userId, float $ticketPrice, string $busOwnerId): array
    {
        Log::info('BusInventoryService: card payment stub', [
            'user_id' => $userId, 'amount' => $ticketPrice,
        ]);

        // After gateway confirmation, route via ledger
        return $this->ledger->processPayout(
            module: 'bus_ticket',
            payerType: 'customer',
            payerId: $userId,
            payeeId: $busOwnerId,
            payeeType: 'bus_owner',
            amount: $ticketPrice,
            referenceId: (string) Str::uuid(),
            referenceType: 'bus_ticket_card',
            currency: 'PKR',
        );
    }

    /**
     * VOUCHER SPLIT LOGIC (Module 8W core feature).
     *
     * Customer buys Rs. 1,000 voucher. Ticket = Rs. 930.
     * → Rs. 930 → Bus Owner
     * → Rs. 70  → Customer Wallet (instant change)
     */
    private function payByVoucher(string $userId, float $ticketPrice, string $voucherCode, string $busOwnerId): array
    {
        $codeHash = hash('sha256', $voucherCode);

        $voucher = NexatraceVoucher::where('voucher_code_hash', $codeHash)
            ->lockForUpdate()->firstOrFail();

        if (! $voucher->isRedeemable()) {
            throw new \RuntimeException('Voucher is not redeemable. Status: ' . $voucher->status);
        }

        if ($voucher->amount < $ticketPrice) {
            throw new \RuntimeException("Voucher amount ({$voucher->amount}) is less than ticket price ({$ticketPrice}).");
        }

        $changeAmount = round($voucher->amount - $ticketPrice, 2);
        $results = [];

        // ─── 1. Pay Bus Owner from voucher ──────────────
        $payout = $this->ledger->processPayout(
            module: 'bus_ticket',
            payerType: 'voucher',
            payerId: $voucher->id,
            payeeId: $busOwnerId,
            payeeType: 'bus_owner',
            amount: $ticketPrice,
            referenceId: (string) Str::uuid(),
            referenceType: 'bus_ticket_voucher',
            currency: $voucher->currency,
        );
        $results['bus_owner_payout'] = $payout;

        // ─── 2. Credit leftover change to Customer Wallet ─
        if ($changeAmount > 0) {
            $customerWallet = Wallet::firstOrCreate(
                ['owner_id' => $userId, 'owner_type' => 'customer', 'wallet_type' => 'main', 'currency' => $voucher->currency],
                ['id' => (string) Str::uuid(), 'balance' => 0, 'held_balance' => 0, 'available_balance' => 0, 'status' => 'active']
            );

            $customerWallet = Wallet::where('id', $customerWallet->id)->lockForUpdate()->firstOrFail();
            $balanceBefore = $customerWallet->balance;
            $customerWallet->credit($changeAmount);
            $customerWallet->save();

            WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $customerWallet->id,
                'entry_type' => WalletTransaction::ENTRY_CREDIT,
                'amount' => $changeAmount,
                'balance_before' => $balanceBefore,
                'balance_after' => $customerWallet->balance,
                'currency' => $voucher->currency,
                'transaction_type' => 'voucher_change',
                'reference_id' => $voucher->id,
                'reference_type' => 'nexatrace_voucher',
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Voucher change: Rs. {$changeAmount} credited to wallet.",
                'settled_at' => now(),
            ]);

            $results['change_credited'] = $changeAmount;
            Log::info('BusInventoryService: voucher change credited', [
                'user_id' => $userId, 'change' => $changeAmount,
            ]);
        }

        // ─── 3. Mark voucher redeemed ───────────────────
        $voucher->update([
            'status' => NexatraceVoucher::STATUS_REDEEMED,
            'redeemed_by_user_id' => $userId,
            'redeemed_at' => now(),
        ]);

        $results['voucher_redeemed'] = true;

        return $results;
    }

    // ─── HELPERS ────────────────────────────────────────

    private function getBookedSeats(string $layoutId, ?string $tripId): array
    {
        if (! $tripId) return [];

        return DB::table('transport_seat_bookings')
            ->where('bus_layout_id', $layoutId)
            ->where('trip_id', $tripId)
            ->where('status', 'booked')
            ->pluck('seat_number')
            ->toArray();
    }

    private function flattenSeatNumbers(array $grid): array
    {
        $seats = [];
        foreach ($grid as $row) {
            foreach (['left', 'right', 'driver'] as $section) {
                if (isset($row[$section])) {
                    foreach ((array) $row[$section] as $seat) {
                        $seats[] = (int) $seat;
                    }
                }
            }
        }
        return $seats;
    }
}
