<?php

namespace App\Models\Financial;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class FinancialSettlement extends Model
{
    use SoftDeletes;

    protected $table = 'financial_settlements';

    public const STATUS_PENDING = 'pending';
    public const STATUS_PROCESSED = 'processed';
    public const STATUS_FAILED = 'failed';
    public const STATUS_REJECTED = 'rejected';

    public const TYPE_VOUCHER_SETTLEMENT = 'voucher_settlement';
    public const TYPE_WALLET_WITHDRAWAL = 'wallet_withdrawal';

    protected $fillable = [
        'user_id', 'company_id', 'type', 'amount', 'currency',
        'status', 'reference_id', 'voucher_id', 'wallet_transaction_id',
        'bank_name', 'bank_account_last4', 'admin_notes',
        'processed_by', 'processed_at', 'metadata',
    ];

    protected $casts = [
        'amount' => 'float',
        'metadata' => 'array',
        'processed_at' => 'datetime',
    ];

    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopeType($query, string $type)
    {
        return $query->where('type', $type);
    }

    public function wallet(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Wallet::class, 'wallet_transaction_id');
    }
}
