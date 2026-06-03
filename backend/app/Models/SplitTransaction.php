<?php

namespace App\Models;

use App\Exceptions\FinancialMismatchException;
use App\Services\AuditService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Wave 5 — Split Transaction Engine (Section 10.5)
 *
 * F-3 Fix: All monetary columns use 'decimal:4' cast. All arithmetic
 * uses bcmath for exact arbitrary-precision comparisons.
 *
 * F-2 Fix: findOrCreateByIdempotency() uses raw INSERT ... ON CONFLICT
 * DO NOTHING to guarantee exactly-once semantics inside active
 * transaction boundaries.
 */
class SplitTransaction extends Model
{
    protected $table = 'split_transactions';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'idempotency_key',
        'source_event_type',
        'trip_booking_id',
        'source_event_id',
        'source_amount',
        'carrier_cut_amount',
        'owner_cut_amount',
        'tax_deduction',
        'platform_cut_amount',
        'currency',
        'settlement_status',
        'split_rule_snapshot',
        'recipients_snapshot',
        'settled_at',
        'reversed_at',
        'reversal_reason',
    ];

    /**
     * F-3 Fix: decimal:4 casts preserve NUMERIC precision.
     * All monetary values are returned as strings. Use bcmath.
     */
    protected $casts = [
        'source_amount'        => 'decimal:4',
        'carrier_cut_amount'   => 'decimal:4',
        'owner_cut_amount'     => 'decimal:4',
        'tax_deduction'        => 'decimal:4',
        'platform_cut_amount'  => 'decimal:4',
        'split_rule_snapshot'  => 'array',
        'recipients_snapshot'  => 'array',
        'settled_at'           => 'datetime',
        'reversed_at'          => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = (string) Str::orderedUuid();
            }
            if (empty($model->idempotency_key)) {
                $model->idempotency_key = self::computeIdempotencyKey(
                    $model->source_event_type,
                    $model->source_event_id ?? (string) $model->trip_booking_id,
                    1
                );
            }
        });
    }

    // ─── Relationships ───────────────────────────────────────

    public function recipients()
    {
        return $this->hasMany(SplitTransactionRecipient::class, 'split_transaction_id');
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopePending($query)
    {
        return $query->whereIn('settlement_status', ['pending', 'splitting']);
    }

    public function scopeSettled($query)
    {
        return $query->where('settlement_status', 'settled');
    }

    // ─── Idempotency (F-2 Fix) ───────────────────────────────

    /**
     * Compute deterministic idempotency key per Section 10.5.2.
     */
    public static function computeIdempotencyKey(string $eventType, string $eventId, int $ruleVersion): string
    {
        return hash('sha256', "{$eventType}:{$eventId}:{$ruleVersion}");
    }

    /**
     * F-2 Fix: Atomic idempotency via native PostgreSQL UPSERT.
     *
     * Replaces firstOrCreate() which has a race-condition window
     * under concurrent duplicate webhooks inside DB::transaction().
     *
     * The raw INSERT ... ON CONFLICT DO NOTHING ensures exactly-one
     * row creation regardless of how many concurrent threads attempt
     * the same idempotency key.
     *
     * After the atomic insert-or-skip, fetches the existing row
     * under a deterministic read scope.
     *
     * @param string $key        SHA-256 idempotency key
     * @param array  $attributes Full row attributes
     * @return self The existing or newly-inserted split transaction
     */
    public static function findOrCreateByIdempotency(string $key, array $attributes): self
    {
        return DB::transaction(function () use ($key, $attributes) {
            // Atomic insert — no-op if key already exists
            DB::statement("
                INSERT INTO split_transactions (
                    id, idempotency_key, source_event_type, trip_booking_id,
                    source_event_id, source_amount, carrier_cut_amount,
                    owner_cut_amount, tax_deduction, platform_cut_amount,
                    currency, settlement_status, split_rule_snapshot,
                    created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::jsonb, NOW(), NOW())
                ON CONFLICT (idempotency_key) DO NOTHING
            ", [
                $attributes['id'] ?? (string) Str::orderedUuid(),
                $key,
                $attributes['source_event_type'] ?? 'unknown',
                $attributes['trip_booking_id'],
                $attributes['source_event_id'] ?? null,
                $attributes['source_amount'] ?? '0',
                $attributes['carrier_cut_amount'] ?? '0',
                $attributes['owner_cut_amount'] ?? '0',
                $attributes['tax_deduction'] ?? '0',
                $attributes['platform_cut_amount'] ?? '0',
                $attributes['currency'] ?? 'PKR',
                $attributes['settlement_status'] ?? 'pending',
                json_encode($attributes['split_rule_snapshot'] ?? []),
            ]);

            // Fetch the definitive row (either newly inserted or pre-existing)
            return static::where('idempotency_key', $key)->firstOrFail();
        });
    }

    // ─── Double-Entry Validation (bcmath — F-3 Fix) ─────────

    /**
     * Validate that recipient amounts sum to the source amount.
     * Uses bcmath for exact arbitrary-precision comparison.
     *
     * @throws FinancialMismatchException
     */
    public function validateSplitAmounts(): void
    {
        $recipientTotal = '0';
        $recipientTotal = bcadd($recipientTotal, (string) $this->carrier_cut_amount, 4);
        $recipientTotal = bcadd($recipientTotal, (string) $this->owner_cut_amount, 4);
        $recipientTotal = bcadd($recipientTotal, (string) $this->tax_deduction, 4);
        $recipientTotal = bcadd($recipientTotal, (string) $this->platform_cut_amount, 4);

        $sourceTotal = (string) $this->source_amount;

        if (bccomp($recipientTotal, $sourceTotal, 4) !== 0) {
            throw new FinancialMismatchException(
                sprintf(
                    'Split amount mismatch: Source %s ≠ Recipient Total %s (Carrier: %s + Owner: %s + Tax: %s + Platform: %s)',
                    $sourceTotal, $recipientTotal,
                    (string) $this->carrier_cut_amount,
                    (string) $this->owner_cut_amount,
                    (string) $this->tax_deduction,
                    (string) $this->platform_cut_amount
                ),
                $this->id,
                (float) $sourceTotal,
                (float) $recipientTotal
            );
        }
    }

    // ─── State Transitions ──────────────────────────────────

    public function settle(AuditService $audit, array $recipientBreakdown = []): void
    {
        if (!in_array($this->settlement_status, ['pending', 'splitting'], true)) {
            throw new \RuntimeException("Cannot settle split in '{$this->settlement_status}' status.");
        }

        $this->validateSplitAmounts();

        $this->update([
            'settlement_status'   => 'settled',
            'recipients_snapshot' => !empty($recipientBreakdown) ? $recipientBreakdown : null,
            'settled_at'          => now(),
        ]);

        $audit->emit('financial', [
            'event_type'               => 'split.settled',
            'actor_global_identity_id' => '00000000-0000-0000-0000-000000000000',
            'reference_type'           => 'split_transaction',
            'reference_id'             => $this->id,
            'amount'                   => (float) (string) $this->source_amount,
            'currency'                 => $this->currency,
            'payload'                  => [
                'carrier_cut'  => (string) $this->carrier_cut_amount,
                'owner_cut'    => (string) $this->owner_cut_amount,
                'tax'          => (string) $this->tax_deduction,
                'platform_cut' => (string) $this->platform_cut_amount,
                'booking_id'   => $this->trip_booking_id,
            ],
            'event_time' => now()->toIso8601String(),
        ]);
    }

    public function reverse(string $reason, AuditService $audit): void
    {
        if (!in_array($this->settlement_status, ['settled', 'escrow_held'], true)) {
            throw new \RuntimeException("Cannot reverse split in '{$this->settlement_status}' status.");
        }

        $this->update([
            'settlement_status' => 'reversed',
            'reversed_at'       => now(),
            'reversal_reason'   => $reason,
        ]);

        $audit->emit('financial', [
            'event_type'               => 'split.reversed',
            'actor_global_identity_id' => '00000000-0000-0000-0000-000000000000',
            'reference_type'           => 'split_transaction',
            'reference_id'             => $this->id,
            'amount'                   => (float) (string) $this->source_amount,
            'currency'                 => $this->currency,
            'payload'                  => ['reason' => $reason],
            'event_time'               => now()->toIso8601String(),
        ]);
    }
}
