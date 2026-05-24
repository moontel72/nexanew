<?php

namespace App\Models\Marketplace;

use App\Models\Company;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GroupBuyPool extends Model
{
    protected $table = 'marketplace_group_buy_pools';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_OPEN = 'open';
    public const STATUS_GATHERING = 'gathering';
    public const STATUS_LOCKED = 'locked';
    public const STATUS_ORDERED = 'ordered';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_EXPIRED = 'expired';

    protected $fillable = [
        'id', 'product_listing_id', 'initiator_company_id',
        'target_quantity', 'current_committed_quantity',
        'min_participants', 'max_participants',
        'pool_price_per_unit', 'original_price_per_unit', 'discount_percentage',
        'pool_status', 'gathering_deadline', 'locked_at', 'ordered_at',
        'completed_at', 'cancelled_at', 'cancellation_reason',
        'order_id', 'metadata',
    ];

    protected $casts = [
        'target_quantity' => 'integer',
        'current_committed_quantity' => 'integer',
        'min_participants' => 'integer',
        'max_participants' => 'integer',
        'pool_price_per_unit' => 'float',
        'original_price_per_unit' => 'float',
        'discount_percentage' => 'float',
        'metadata' => 'array',
        'gathering_deadline' => 'datetime',
        'locked_at' => 'datetime',
        'ordered_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    // ─── Relationships ──────────────────────────────────

    public function productListing(): BelongsTo
    {
        return $this->belongsTo(ProductListing::class);
    }

    public function initiator(): BelongsTo
    {
        return $this->belongsTo(Company::class, 'initiator_company_id');
    }

    public function participants(): HasMany
    {
        return $this->hasMany(PoolParticipant::class, 'pool_id');
    }

    // ─── Scopes ─────────────────────────────────────────

    public function scopeStatus($query, string $status)
    {
        return $query->where('pool_status', $status);
    }

    public function scopeActive($query)
    {
        return $query->whereIn('pool_status', [
            self::STATUS_OPEN,
            self::STATUS_GATHERING,
        ]);
    }

    // ─── Helpers ────────────────────────────────────────

    public function isOpen(): bool
    {
        return in_array($this->pool_status, [self::STATUS_OPEN, self::STATUS_GATHERING], true);
    }

    public function canBeJoined(): bool
    {
        if (! $this->isOpen()) {
            return false;
        }
        if ($this->max_participants && $this->participants()->count() >= $this->max_participants) {
            return false;
        }
        if ($this->current_committed_quantity >= $this->target_quantity) {
            return false;
        }
        return true;
    }

    public function progressPercentage(): float
    {
        if ($this->target_quantity <= 0) {
            return 0;
        }
        return round(($this->current_committed_quantity / $this->target_quantity) * 100, 1);
    }
}
