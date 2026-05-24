<?php

namespace App\Models\Financial;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WalletTransaction extends Model
{
    protected $table = 'financial_wallet_transactions';
    public $incrementing = false;
    protected $keyType = 'string';

    public const ENTRY_CREDIT = 'credit';
    public const ENTRY_DEBIT = 'debit';

    public const STATUS_PENDING = 'pending';
    public const STATUS_SETTLED = 'settled';
    public const STATUS_CLEARED = 'cleared';
    public const STATUS_REVERSED = 'reversed';

    protected $fillable = [
        'id', 'wallet_id', 'entry_type', 'amount',
        'balance_before', 'balance_after', 'currency',
        'transaction_type', 'reference_id', 'reference_type',
        'counterpart_transaction_id', 'status', 'description',
        'performed_by', 'metadata', 'settled_at', 'cleared_at',
    ];

    protected $casts = [
        'amount' => 'float', 'balance_before' => 'float',
        'balance_after' => 'float', 'metadata' => 'array',
        'settled_at' => 'datetime', 'cleared_at' => 'datetime',
    ];

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'wallet_id');
    }

    public function counterpart(): BelongsTo
    {
        return $this->belongsTo(WalletTransaction::class, 'counterpart_transaction_id');
    }

    public function isCredit(): bool
    {
        return $this->entry_type === self::ENTRY_CREDIT;
    }

    public function isDebit(): bool
    {
        return $this->entry_type === self::ENTRY_DEBIT;
    }
}
