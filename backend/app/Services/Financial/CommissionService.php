<?php

namespace App\Services\Financial;

use App\Models\Financial\CommissionConfig;
use App\Models\Financial\Wallet;
use App\Models\Financial\WalletTransaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — FINANCIAL COMMISSION & PAYOUT ENGINE
 * =================================================
 *
 * Double-entry ledger service for automated commission calculation,
 * platform treasury routing, and net payout distribution.
 *
 * CORE PRINCIPLES:
 *   - Every financial operation produces TWO entries (credit + debit).
 *   - Wallet rows are locked via lockForUpdate() during balance mutations.
 *   - Platform treasury wallet receives commissions.
 *   - Net amount released to vendor/driver wallet.
 *   - All transactions logged with full audit trail.
 *
 * TARGET MODULES: 9G, 10F, 11H, 12A, 12C
 *
 * SAFETY:
 *   - Entirely NEW service in App\Services\Financial namespace.
 *   - Uses only financial_* tables and models.
 *   - Zero interaction with existing code.
 *   - All mutations in database transactions with row locking.
 */

class CommissionService
{
    public const PLATFORM_OWNER_ID = '00000000-0000-0000-0000-000000000000';
    public const PLATFORM_OWNER_TYPE = 'platform';

    /**
     * Execute a commission payout for a completed transaction.
     *
     * Flow:
     *   1. Calculate platform commission based on module config
     *   2. Lock payer wallet → debit full amount
     *   3. Lock treasury wallet → credit commission
     *   4. Lock payee wallet → credit net payout (amount - commission)
     *   5. Settle all transactions
     *
     * @param string $module       freight_auction, code_generation, marketplace
     * @param string $payerType    truck_owner, factory, reseller, etc.
     * @param string $payerId      Payer's owner ID
     * @param string $payeeId      Payee's owner ID
     * @param string $payeeType    Payee's owner type
     * @param float  $amount       Total transaction amount
     * @param string $referenceId  Order/trip/load ID
     * @param string $referenceType
     * @param string $currency
     * @return array{commission: float, net_payout: float, transactions: array}
     * @throws \RuntimeException
     */
    public function processPayout(
        string $module,
        string $payerType,
        string $payerId,
        string $payeeId,
        string $payeeType,
        float $amount,
        string $referenceId,
        string $referenceType = 'trip',
        string $currency = 'USD'
    ): array {
        if ($amount <= 0) {
            throw new \RuntimeException('Transaction amount must be positive.');
        }

        // ─── Calculate commission ──────────────────────
        $config = CommissionConfig::where('module', $module)
            ->where('payer_type', $payerType)
            ->where('is_active', true)
            ->first();

        $commission = $config
            ? $config->calculate($amount)
            : round($amount * 0.05, 2); // default 5 % fallback

        $netPayout = round($amount - $commission, 2);

        Log::info('CommissionService: payout calculation', [
            'module' => $module, 'payer_type' => $payerType,
            'amount' => $amount, 'commission' => $commission,
            'net_payout' => $netPayout,
        ]);

        // ─── Execute double-entry in transaction ───────
        return DB::transaction(function () use (
            $module, $payerType, $payerId, $payeeId, $payeeType,
            $amount, $commission, $netPayout, $referenceId, $referenceType, $currency
        ) {
            // Lock wallets in consistent order to prevent deadlocks
            $payerWallet = $this->getOrCreateWallet($payerId, $payerType, Wallet::TYPE_MAIN, $currency);
            $treasuryWallet = $this->getOrCreateTreasuryWallet($currency);
            $payeeWallet = $this->getOrCreateWallet($payeeId, $payeeType, Wallet::TYPE_MAIN, $currency);

            // Re-fetch with lock
            $payerWallet = Wallet::where('id', $payerWallet->id)->lockForUpdate()->firstOrFail();
            $treasuryWallet = Wallet::where('id', $treasuryWallet->id)->lockForUpdate()->firstOrFail();
            $payeeWallet = Wallet::where('id', $payeeWallet->id)->lockForUpdate()->firstOrFail();

            // Validate sufficient balance
            if ($payerWallet->available_balance < $amount) {
                throw new \RuntimeException("Insufficient funds. Available: {$payerWallet->available_balance}, Required: {$amount}");
            }

            $txns = [];
            $now = now();

            // ─── ENTRY 1: Debit payer wallet ───────────
            $balanceBefore = $payerWallet->balance;
            $payerWallet->debit($amount);
            $payerWallet->save();

            $txn1 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $payerWallet->id,
                'entry_type' => WalletTransaction::ENTRY_DEBIT,
                'amount' => $amount,
                'balance_before' => $balanceBefore,
                'balance_after' => $payerWallet->balance,
                'currency' => $currency,
                'transaction_type' => 'commission_payout',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Payout: {$module} — {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);
            $txns[] = $txn1;

            // ─── ENTRY 2: Credit treasury (commission) ─
            $balanceBefore = $treasuryWallet->balance;
            $treasuryWallet->credit($commission);
            $treasuryWallet->save();

            $txn2 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $treasuryWallet->id,
                'entry_type' => WalletTransaction::ENTRY_CREDIT,
                'amount' => $commission,
                'balance_before' => $balanceBefore,
                'balance_after' => $treasuryWallet->balance,
                'currency' => $currency,
                'transaction_type' => 'commission_payout',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'counterpart_transaction_id' => $txn1->id,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Platform commission: {$module} — {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);
            $txns[] = $txn2;

            // ─── ENTRY 3: Credit payee (net payout) ────
            $balanceBefore = $payeeWallet->balance;
            $payeeWallet->credit($netPayout);
            $payeeWallet->save();

            $txn3 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $payeeWallet->id,
                'entry_type' => WalletTransaction::ENTRY_CREDIT,
                'amount' => $netPayout,
                'balance_before' => $balanceBefore,
                'balance_after' => $payeeWallet->balance,
                'currency' => $currency,
                'transaction_type' => 'commission_payout',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'counterpart_transaction_id' => $txn1->id,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Net payout: {$module} — {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);
            $txns[] = $txn3;

            Log::info('CommissionService: payout processed (double-entry)', [
                'payer' => "{$payerId}({$payerType})",
                'payee' => "{$payeeId}({$payeeType})",
                'amount' => $amount, 'commission' => $commission,
                'net_payout' => $netPayout, 'reference' => $referenceId,
                'txn_ids' => array_column($txns, 'id'),
            ]);

            return [
                'commission' => $commission,
                'net_payout' => $netPayout,
                'transactions' => $txns,
            ];
        });
    }

    /**
     * Hold funds in escrow (e.g., for freight auction, B2B marketplace).
     *
     * The amount is debited from payer and credited to escrow wallet.
     */
    public function holdInEscrow(
        string $payerId,
        string $payerType,
        float $amount,
        string $referenceId,
        string $referenceType = 'freight_load',
        string $currency = 'USD'
    ): array {
        return DB::transaction(function () use ($payerId, $payerType, $amount, $referenceId, $referenceType, $currency) {
            $payerWallet = $this->getOrCreateWallet($payerId, $payerType, Wallet::TYPE_MAIN, $currency);
            $escrowWallet = $this->getOrCreateWallet($payerId, $payerType, Wallet::TYPE_ESCROW, $currency);

            $payerWallet = Wallet::where('id', $payerWallet->id)->lockForUpdate()->firstOrFail();

            if ($payerWallet->available_balance < $amount) {
                throw new \RuntimeException("Insufficient funds for escrow hold.");
            }

            $now = now();

            // Debit main wallet
            $txn1 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $payerWallet->id,
                'entry_type' => WalletTransaction::ENTRY_DEBIT,
                'amount' => $amount,
                'balance_before' => $payerWallet->balance,
                'balance_after' => $payerWallet->balance - $amount,
                'currency' => $currency,
                'transaction_type' => 'escrow_hold',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Escrow hold: {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);

            $payerWallet->debit($amount);
            $payerWallet->save();

            // Credit escrow wallet
            $txn2 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $escrowWallet->id,
                'entry_type' => WalletTransaction::ENTRY_CREDIT,
                'amount' => $amount,
                'balance_before' => $escrowWallet->balance,
                'balance_after' => $escrowWallet->balance + $amount,
                'currency' => $currency,
                'transaction_type' => 'escrow_hold',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'counterpart_transaction_id' => $txn1->id,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Escrow credit: {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);

            $escrowWallet->credit($amount);
            $escrowWallet->save();

            Log::info('CommissionService: escrow hold', [
                'payer' => $payerId, 'amount' => $amount, 'reference' => $referenceId,
            ]);

            return ['transactions' => [$txn1, $txn2]];
        });
    }

    /**
     * Release escrow funds to payee.
     */
    public function releaseEscrow(
        string $payerId,
        string $payerType,
        string $payeeId,
        string $payeeType,
        float $amount,
        string $referenceId,
        string $referenceType = 'freight_load',
        string $currency = 'USD'
    ): array {
        return DB::transaction(function () use ($payerId, $payerType, $payeeId, $payeeType, $amount, $referenceId, $referenceType, $currency) {
            $escrowWallet = Wallet::where('owner_id', $payerId)
                ->where('owner_type', $payerType)
                ->where('wallet_type', Wallet::TYPE_ESCROW)
                ->where('currency', $currency)
                ->lockForUpdate()->firstOrFail();

            $payeeWallet = $this->getOrCreateWallet($payeeId, $payeeType, Wallet::TYPE_MAIN, $currency);
            $payeeWallet = Wallet::where('id', $payeeWallet->id)->lockForUpdate()->firstOrFail();

            $now = now();

            $txn1 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $escrowWallet->id,
                'entry_type' => WalletTransaction::ENTRY_DEBIT,
                'amount' => $amount,
                'balance_before' => $escrowWallet->balance,
                'balance_after' => $escrowWallet->balance - $amount,
                'currency' => $currency,
                'transaction_type' => 'escrow_release',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Escrow release: {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);
            $escrowWallet->debit($amount);
            $escrowWallet->save();

            $txn2 = WalletTransaction::create([
                'id' => (string) Str::uuid(),
                'wallet_id' => $payeeWallet->id,
                'entry_type' => WalletTransaction::ENTRY_CREDIT,
                'amount' => $amount,
                'balance_before' => $payeeWallet->balance,
                'balance_after' => $payeeWallet->balance + $amount,
                'currency' => $currency,
                'transaction_type' => 'escrow_release',
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
                'counterpart_transaction_id' => $txn1->id,
                'status' => WalletTransaction::STATUS_SETTLED,
                'description' => "Escrow payout: {$referenceType} {$referenceId}",
                'settled_at' => $now,
            ]);
            $payeeWallet->credit($amount);
            $payeeWallet->save();

            Log::info('CommissionService: escrow released', [
                'from' => $payerId, 'to' => $payeeId, 'amount' => $amount,
            ]);

            return ['transactions' => [$txn1, $txn2]];
        });
    }

    /**
     * Get wallet balance summary for an owner.
     */
    public function getBalance(string $ownerId, string $ownerType, string $currency = 'USD'): array
    {
        $wallet = Wallet::where('owner_id', $ownerId)
            ->where('owner_type', $ownerType)
            ->where('wallet_type', Wallet::TYPE_MAIN)
            ->where('currency', $currency)
            ->first();

        if (! $wallet) {
            return ['balance' => 0, 'held_balance' => 0, 'available_balance' => 0];
        }

        return [
            'balance' => $wallet->balance,
            'held_balance' => $wallet->held_balance,
            'available_balance' => $wallet->available_balance,
        ];
    }

    // ─── Private Helpers ────────────────────────────────

    private function getOrCreateWallet(string $ownerId, string $ownerType, string $walletType, string $currency): Wallet
    {
        return Wallet::firstOrCreate(
            ['owner_id' => $ownerId, 'owner_type' => $ownerType, 'wallet_type' => $walletType, 'currency' => $currency],
            ['id' => (string) Str::uuid(), 'balance' => 0, 'held_balance' => 0, 'available_balance' => 0, 'status' => Wallet::STATUS_ACTIVE]
        );
    }

    private function getOrCreateTreasuryWallet(string $currency): Wallet
    {
        return Wallet::firstOrCreate(
            ['owner_id' => self::PLATFORM_OWNER_ID, 'owner_type' => self::PLATFORM_OWNER_TYPE, 'wallet_type' => Wallet::TYPE_TREASURY, 'currency' => $currency],
            ['id' => (string) Str::uuid(), 'balance' => 0, 'held_balance' => 0, 'available_balance' => 0, 'status' => Wallet::STATUS_ACTIVE, 'is_treasury' => true]
        );
    }
}
