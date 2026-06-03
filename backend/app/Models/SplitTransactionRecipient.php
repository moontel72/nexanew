<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

/**
 * Wave 5 — Split Transaction Recipient
 *
 * Individual recipient of a split transaction with state-machine lifecycle.
 *
 * State transitions:
 *   queued → transferring → credited (happy path)
 *   queued → transferring → failed (retryable)
 *   credited → reversed (compliance/dispute)
 */
class SplitTransactionRecipient extends Model
{
    protected $table = 'split_transaction_recipients';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'split_transaction_id',
        'recipient_global_identity_id',
        'recipient_role',
        'amount',
        'state',
        'ledger_entry_id',
        'attempt_count',
        'last_error',
        'credited_at',
        'failed_at',
    ];

    protected $casts = [
        'amount'        => 'decimal:4',
        'attempt_count' => 'integer',
        'credited_at'   => 'datetime',
        'failed_at'     => 'datetime',
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

    // ─── Relationships ───────────────────────────────────────

    public function splitTransaction()
    {
        return $this->belongsTo(SplitTransaction::class, 'split_transaction_id');
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopeQueued($query)
    {
        return $query->where('state', 'queued');
    }

    public function scopeFailed($query)
    {
        return $query->where('state', 'failed');
    }

    // ─── State Transitions ──────────────────────────────────

    public function markTransferring(): void
    {
        if ($this->state !== 'queued') {
            throw new \RuntimeException("Cannot transfer recipient in '{$this->state}' state.");
        }
        $this->update(['state' => 'transferring']);
    }

    public function markCredited(string $ledgerEntryId): void
    {
        if ($this->state !== 'transferring') {
            throw new \RuntimeException("Cannot credit recipient in '{$this->state}' state.");
        }
        $this->update([
            'state'           => 'credited',
            'ledger_entry_id' => $ledgerEntryId,
            'credited_at'     => now(),
            'attempt_count'   => $this->attempt_count + 1,
        ]);
    }

    public function markFailed(string $error): void
    {
        if (!in_array($this->state, ['queued', 'transferring'], true)) {
            throw new \RuntimeException("Cannot fail recipient in '{$this->state}' state.");
        }
        $this->update([
            'state'         => 'failed',
            'last_error'    => $error,
            'failed_at'     => now(),
            'attempt_count' => $this->attempt_count + 1,
        ]);
    }

    public function markReversed(): void
    {
        if ($this->state !== 'credited') {
            throw new \RuntimeException("Cannot reverse recipient in '{$this->state}' state.");
        }
        $this->update(['state' => 'reversed']);
    }
}
