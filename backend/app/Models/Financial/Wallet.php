<?php

namespace App\Models\Financial;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Wallet extends Model
{
    use SoftDeletes;

    protected $table = 'financial_wallets';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_ACTIVE = 'active';
    public const STATUS_FROZEN = 'frozen';
    public const STATUS_CLOSED = 'closed';

    public const TYPE_MAIN = 'main';
    public const TYPE_ESCROW = 'escrow';
    public const TYPE_SUBSIDIARY = 'subsidiary';
    public const TYPE_TREASURY = 'treasury';

    protected $fillable = [
        'id', 'owner_id', 'owner_type', 'wallet_type', 'currency',
        'balance', 'held_balance', 'available_balance',
        'status', 'is_treasury', 'metadata',
    ];

    protected $casts = [
        'balance' => 'float', 'held_balance' => 'float',
        'available_balance' => 'float', 'is_treasury' => 'boolean',
        'metadata' => 'array',
    ];

    public function transactions(): HasMany
    {
        return $this->hasMany(WalletTransaction::class, 'wallet_id');
    }

    public function credit(float $amount): void
    {
        $this->balance += $amount;
        $this->available_balance = $this->balance - $this->held_balance;
    }

    public function debit(float $amount): void
    {
        $this->balance -= $amount;
        $this->available_balance = $this->balance - $this->held_balance;
    }

    public function hold(float $amount): void
    {
        $this->held_balance += $amount;
        $this->available_balance = $this->balance - $this->held_balance;
    }

    public function release(float $amount): void
    {
        $this->held_balance = max(0, $this->held_balance - $amount);
        $this->available_balance = $this->balance - $this->held_balance;
    }
}
