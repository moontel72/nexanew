<?php

namespace App\Models\Transport;

use Illuminate\Database\Eloquent\Model;

class NexatraceVoucher extends Model
{
    protected $table = 'transport_nexatrace_vouchers';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_UNUSED = 'unused';
    public const STATUS_REDEEMED = 'redeemed';
    public const STATUS_EXPIRED = 'expired';
    public const STATUS_REVOKED = 'revoked';

    public const CHANNEL_CARD = 'card';
    public const CHANNEL_CASH_VOUCHER = 'cash_voucher';

    protected $fillable = [
        'id', 'voucher_code_hash', 'amount', 'consumed_amount', 'currency',
        'purchase_channel', 'surcharge_amount', 'status',
        'created_by_shop_id', 'redeemed_by_user_id', 'redeemed_at',
        'redemption_transaction_id', 'expires_at', 'metadata',
    ];

    protected $casts = [
        'amount' => 'float', 'consumed_amount' => 'float',
        'surcharge_amount' => 'float', 'metadata' => 'array',
        'redeemed_at' => 'datetime', 'expires_at' => 'datetime',
    ];

    protected $hidden = ['voucher_code_hash'];

    public function isRedeemable(): bool
    {
        return $this->status === self::STATUS_UNUSED
            && ($this->expires_at === null || $this->expires_at->isFuture());
    }

    /**
     * Usage ratio as percentage (0-100).
     */
    public function usageRatio(): float
    {
        if ($this->amount <= 0) return 0;
        return round(($this->consumed_amount / $this->amount) * 100, 2);
    }

    /**
     * Total customer cost = face value + surcharge.
     */
    public function totalCustomerCost(): float
    {
        return $this->amount + ($this->surcharge_amount ?? 0);
    }
}
