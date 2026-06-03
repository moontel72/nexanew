<?php

namespace App\Models;

use App\Exceptions\FinancialMismatchException;
use App\Services\AuditService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Wave 5 — Tenant Financial Ledger (Wallet Spine)
 *
 * F-3 Fix: All monetary columns use 'decimal:4' cast (string-safe).
 * All arithmetic uses bcmath (bcadd, bcsub, bccomp) to prevent
 * IEEE 754 floating-point precision drift over accumulated transactions.
 *
 * F-1 Fix: lockMultiple() acquires locks in deterministic UUID-sorted
 * order to prevent ABBA deadlocks under parallel settlement loads.
 *
 * Immutable currency wallet per tenant per carrier company.
 * All debit/credit operations use SELECT ... FOR UPDATE.
 *
 * Double-entry invariant: Σ Debits == Σ Credits.
 */
class TenantFinancialLedger extends Model
{
    protected $table = 'tenant_financial_ledgers';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'tenant_account_id',
        'carrier_company_id',
        'balance_amount',
        'currency',
        'last_transaction_id',
        'version_counter',
        'status',
    ];

    /**
     * F-3 Fix: decimal:4 cast preserves NUMERIC precision.
     * balance_amount is returned as a string — all math uses bcmath.
     */
    protected $casts = [
        'balance_amount'  => 'decimal:4',
        'version_counter' => 'integer',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = (string) Str::orderedUuid();
            }
        });
    }

    protected static function booted(): void
    {
        static::observe(\App\Observers\LedgerCacheInvalidatorObserver::class);
    }

    // ─── Relationships ───────────────────────────────────────

    public function tenantAccount()
    {
        return $this->belongsTo(TenantAccount::class, 'tenant_account_id');
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeByTenant($query, string $tenantAccountId)
    {
        return $query->where('tenant_account_id', $tenantAccountId);
    }

    public function scopeByCarrier($query, string $carrierCompanyId)
    {
        return $query->where('carrier_company_id', $carrierCompanyId);
    }

    // ─── Pessimistic Locking ─────────────────────────────────

    /**
     * Fetch a single ledger with pessimistic write lock.
     */
    public static function lockForTransaction(string $tenantAccountId, ?string $carrierCompanyId, string $currency = 'PKR'): ?self
    {
        return static::where('tenant_account_id', $tenantAccountId)
            ->where('carrier_company_id', $carrierCompanyId)
            ->where('currency', $currency)
            ->where('status', 'active')
            ->lockForUpdate()
            ->first();
    }

    /**
     * Find or create a locked ledger.
     */
    public static function findOrCreateLocked(string $tenantAccountId, ?string $carrierCompanyId, string $currency = 'PKR'): self
    {
        $ledger = static::lockForTransaction($tenantAccountId, $carrierCompanyId, $currency);

        if (!$ledger) {
            $ledger = static::create([
                'tenant_account_id'  => $tenantAccountId,
                'carrier_company_id' => $carrierCompanyId,
                'currency'           => $currency,
                'balance_amount'     => '0.0000',
                'status'             => 'active',
            ]);

            $ledger = static::lockForTransaction($tenantAccountId, $carrierCompanyId, $currency);
        }

        return $ledger;
    }

    /**
     * F-1 Fix: Deterministic multi-ledger lock acquisition.
     *
     * Sorts ledger keys by tenant_account_id UUID string to guarantee
     * a globally consistent lock acquisition order. This eliminates
     * ABBA deadlocks under parallel settlement (e.g., 50 concurrent
     * ticket payments crossing the same owner/carrier pair).
     *
     * @param array  $ledgerKeys Array of ['tenant_account_id' => string, 'carrier_company_id' => string|null]
     * @param string $currency
     * @return self[] Array of locked TenantFinancialLedger instances in UUID-sorted order
     */
    public static function lockMultiple(array $ledgerKeys, string $currency = 'PKR'): array
    {
        usort($ledgerKeys, function (array $a, array $b): int {
            return strcmp(
                $a['tenant_account_id'] ?? '',
                $b['tenant_account_id'] ?? ''
            );
        });

        $locked = [];
        foreach ($ledgerKeys as $key) {
            $locked[] = static::findOrCreateLocked(
                $key['tenant_account_id'],
                $key['carrier_company_id'] ?? null,
                $currency
            );
        }

        return $locked;
    }

    // ─── Transactional Operations (bcmath — F-3 Fix) ────────

    /**
     * Credit (deposit) funds using bcmath arbitrary-precision math.
     *
     * @param string $amount        Positive decimal string (e.g. '850.5000')
     * @param string $transactionId Reference to the source transaction
     * @param AuditService $audit   For logging
     * @return string New balance as decimal string
     */
    public function credit(string $amount, string $transactionId, AuditService $audit): string
    {
        if (bccomp($amount, '0', 4) <= 0) {
            throw new \InvalidArgumentException('Credit amount must be positive.');
        }

        $oldBalance = (string) $this->balance_amount;
        $newBalance = bcadd($oldBalance, $amount, 4);

        $this->update([
            'balance_amount'      => $newBalance,
            'last_transaction_id' => $transactionId,
            'version_counter'     => $this->version_counter + 1,
        ]);

        $audit->emit('financial', [
            'event_type'               => 'ledger.credit',
            'actor_global_identity_id' => $this->tenant_account_id,
            'reference_type'           => 'tenant_financial_ledger',
            'reference_id'             => $this->id,
            'amount'                   => (float) $amount,
            'currency'                 => $this->currency,
            'payload'                  => [
                'old_balance'    => $oldBalance,
                'new_balance'    => $newBalance,
                'transaction_id' => $transactionId,
            ],
            'event_time' => now()->toIso8601String(),
        ]);

        return $newBalance;
    }

    /**
     * Debit (withdraw) funds using bcmath.
     *
     * @param string $amount        Positive decimal string
     * @param string $transactionId Reference to the source transaction
     * @param AuditService $audit   For logging
     * @return string New balance as decimal string
     * @throws FinancialMismatchException If insufficient funds
     */
    public function debit(string $amount, string $transactionId, AuditService $audit): string
    {
        if (bccomp($amount, '0', 4) <= 0) {
            throw new \InvalidArgumentException('Debit amount must be positive.');
        }

        $oldBalance = (string) $this->balance_amount;

        if (bccomp($oldBalance, $amount, 4) === -1) {
            throw new FinancialMismatchException(
                "Insufficient funds: balance {$oldBalance} {$this->currency} < debit {$amount} {$this->currency}",
                $this->id,
                (float) $oldBalance,
                (float) $amount
            );
        }

        $newBalance = bcsub($oldBalance, $amount, 4);

        $this->update([
            'balance_amount'      => $newBalance,
            'last_transaction_id' => $transactionId,
            'version_counter'     => $this->version_counter + 1,
        ]);

        $audit->emit('financial', [
            'event_type'               => 'ledger.debit',
            'actor_global_identity_id' => $this->tenant_account_id,
            'reference_type'           => 'tenant_financial_ledger',
            'reference_id'             => $this->id,
            'amount'                   => (float) $amount,
            'currency'                 => $this->currency,
            'payload'                  => [
                'old_balance'    => $oldBalance,
                'new_balance'    => $newBalance,
                'transaction_id' => $transactionId,
            ],
            'event_time' => now()->toIso8601String(),
        ]);

        return $newBalance;
    }

    // ─── Double-Entry Validation (bcmath — F-3 Fix) ─────────

    /**
     * Validate double-entry invariance: Σ Debits == Σ Credits.
     *
     * Uses bccomp for exact arbitrary-precision comparison.
     * No epsilon tolerance needed — bcmath is exact.
     *
     * @param array $entries ['type' => 'credit'|'debit', 'amount' => string]
     * @throws FinancialMismatchException
     */
    public static function validateDoubleEntry(array $entries): void
    {
        $totalCredits = '0';
        $totalDebits  = '0';

        foreach ($entries as $entry) {
            $amount = (string) ($entry['amount'] ?? '0');
            if ($entry['type'] === 'credit') {
                $totalCredits = bcadd($totalCredits, $amount, 4);
            } elseif ($entry['type'] === 'debit') {
                $totalDebits = bcadd($totalDebits, $amount, 4);
            }
        }

        if (bccomp($totalDebits, $totalCredits, 4) !== 0) {
            $delta = bcsub($totalDebits, $totalCredits, 4);
            throw new FinancialMismatchException(
                sprintf(
                    'Double-entry violation: Total Debits (%s) ≠ Total Credits (%s). Delta: %s',
                    $totalDebits, $totalCredits, $delta
                ),
                null,
                (float) $totalCredits,
                (float) $totalDebits
            );
        }
    }
}
