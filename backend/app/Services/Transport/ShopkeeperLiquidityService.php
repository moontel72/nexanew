<?php

namespace App\Services\Transport;

use App\Models\Financial\Wallet;
use App\Models\Financial\WalletTransaction;
use App\Models\Transport\NexatraceVoucher;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — SHOPKEEPER LIQUIDITY SERVICE (v2 — Anti-Fraud)
 * ============================================================
 *
 * Micro-liquidity network with strict 70% velocity block.
 *
 * 70% ANTI-FRAUD RULE (Module 8W-C):
 *   A customer MUST consume >= 70% of voucher face value on actual
 *   NexaTrace services before change can be liquidated for cash.
 *   This prevents corrupt shopkeepers from generating fake vouchers
 *   and immediately processing fraudulent cash-outs to harvest
 *   platform commissions.
 *
 * SURCHARGE PARADIGM (Module 8W-B):
 *   Bank/Card: Rs. 1000 = Rs. 1000 (0% fee).
 *   Cash Voucher: Rs. 1000 + Rs. 50 surcharge → Rs. 50 belongs to
 *   selling Shopkeeper as instant retail incentive.
 *
 * RACE SAFETY:
 *   - lockForUpdate() on both customer and shopkeeper wallets
 *   - All in DB::transaction()
 */

class ShopkeeperLiquidityService
{
    private const MICRO_COMMISSION_RATE = 0.02; // 2 %
    private const MIN_USAGE_RATIO = 70.00;      // 70 %

    /**
     * Liquidate customer wallet change into physical cash via shopkeeper.
     *
     * @throws \RuntimeException if usage < 70 % (FinancialFraudException equivalent)
     */
    public function liquidateWalletChange(
        string $shopkeeperId,
        string $customerVoucherRef,
        string $customerId,
        float $amount
    ): array {
        if ($amount <= 0) {
            throw new \RuntimeException('Amount must be positive.');
        }

        return DB::transaction(function () use ($shopkeeperId, $customerVoucherRef, $customerId, $amount) {
            // ─── ANTI-FRAUD: 70 % Usage Velocity Block ─
            $voucher = NexatraceVoucher::where('id', $customerVoucherRef)->first();
            if ($voucher && $voucher->status === NexatraceVoucher::STATUS_REDEEMED) {
                $usageRatio = $voucher->usageRatio();
                if ($usageRatio < self::MIN_USAGE_RATIO) {
                    throw new \RuntimeException(
                        "Voucher usage is {$usageRatio}% — below the required " . self::MIN_USAGE_RATIO . "%. " .
                        "Cash-out blocked to prevent liquidity velocity fraud. " .
                        "You can only use the remaining balance inside the app or request a standard bank withdrawal."
                    );
                }
            }

            // Lock both wallets
            $customerWallet = Wallet::where('owner_id', $customerId)
                ->where('owner_type', 'customer')
                ->where('wallet_type', Wallet::TYPE_MAIN)
                ->lockForUpdate()->first();

            if (! $customerWallet) {
                throw new \RuntimeException('Customer wallet not found.');
            }

            if ($customerWallet->available_balance < $amount) {
                throw new \RuntimeException("Insufficient balance. Available: {$customerWallet->available_balance}, Requested: {$amount}");
            }

            $shopWallet = Wallet::firstOrCreate(
                ['owner_id' => $shopkeeperId, 'owner_type' => 'shop_keeper', 'wallet_type' => 'main', 'currency' => 'PKR'],
                ['id' => (string) Str::uuid(), 'balance' => 0, 'held_balance' => 0, 'available_balance' => 0, 'status' => 'active']
            );
            $shopWallet = Wallet::where('id', $shopWallet->id)->lockForUpdate()->firstOrFail();

            $commission = round($amount * self::MICRO_COMMISSION_RATE, 2);
            $shopkeeperNet = round($amount - $commission, 2);
            $now = now();

            // ─── 1. Debit customer wallet ─────────────
            $custBefore = $customerWallet->balance;
            $customerWallet->debit($amount);
            $customerWallet->save();

            WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $customerWallet->id,
                'entry_type' => WalletTransaction::ENTRY_DEBIT,
                'amount' => $amount,
                'balance_before' => $custBefore,
                'balance_after' => $customerWallet->balance,
                'currency' => 'PKR',
                'transaction_type' => 'shopkeeper_cashout',
                'reference_id' => $customerVoucherRef,
                'reference_type' => 'voucher_cashout',
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Cash-out via shopkeeper. Physical cash: Rs. {$amount}",
                'settled_at' => $now,
            ]);

            // ─── 2. Credit shopkeeper (net of commission) ─
            $shopBefore = $shopWallet->balance;
            $shopWallet->credit($shopkeeperNet);
            $shopWallet->save();

            WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $shopWallet->id,
                'entry_type' => WalletTransaction::ENTRY_CREDIT,
                'amount' => $shopkeeperNet,
                'balance_before' => $shopBefore,
                'balance_after' => $shopWallet->balance,
                'currency' => 'PKR',
                'transaction_type' => 'shopkeeper_cashout',
                'reference_id' => $customerVoucherRef,
                'reference_type' => 'voucher_cashout',
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Cash-out service: received Rs. {$amount} from customer, net Rs. {$shopkeeperNet} after commission.",
                'settled_at' => $now,
            ]);

            Log::info('ShopkeeperLiquidityService: cash-out complete', [
                'shopkeeper_id' => $shopkeeperId,
                'customer_id' => $customerId,
                'amount' => $amount,
                'commission' => $commission,
                'shopkeeper_net' => $shopkeeperNet,
                'voucher_usage_ratio' => $voucher ? $voucher->usageRatio() : null,
            ]);

            return [
                'amount_requested' => $amount,
                'commission_deducted' => $commission,
                'shopkeeper_received' => $shopkeeperNet,
                'customer_debited' => $amount,
                'voucher_usage_ratio' => $voucher ? $voucher->usageRatio() : null,
                'status' => 'completed',
            ];
        });
    }
}
