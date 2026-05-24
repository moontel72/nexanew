<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class FreightLoad extends Model
{
    use SoftDeletes;

    protected $table = 'freight_loads';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_OPEN = 'open';
    public const STATUS_BIDDING = 'bidding';
    public const STATUS_MATCHED = 'matched';
    public const STATUS_IN_TRANSIT = 'in_transit';
    public const STATUS_DELIVERED = 'delivered';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';
    public const STATUS_EXPIRED = 'expired';

    protected $fillable = [
        'id', 'poster_company_id', 'poster_type',
        'origin_city', 'destination_city', 'origin_lat', 'origin_lng',
        'dest_lat', 'dest_lng', 'cargo_type', 'weight_tons',
        'required_truck_type', 'expected_price', 'currency',
        'description', 'pickup_address', 'delivery_address',
        'pickup_window_start', 'pickup_window_end',
        'delivery_window_start', 'delivery_window_end',
        'status', 'bidding_deadline', 'matched_at', 'winning_bid_id',
        'bid_count', 'view_count', 'requirements', 'metadata',
    ];

    protected $casts = [
        'origin_lat' => 'float', 'origin_lng' => 'float',
        'dest_lat' => 'float', 'dest_lng' => 'float',
        'weight_tons' => 'float', 'expected_price' => 'float',
        'bid_count' => 'integer', 'view_count' => 'integer',
        'requirements' => 'array', 'metadata' => 'array',
        'pickup_window_start' => 'datetime', 'pickup_window_end' => 'datetime',
        'delivery_window_start' => 'datetime', 'delivery_window_end' => 'datetime',
        'bidding_deadline' => 'datetime', 'matched_at' => 'datetime',
    ];

    public function bids(): HasMany
    {
        return $this->hasMany(FreightBid::class, 'load_id');
    }

    public function scopeActive($query)
    {
        return $query->whereIn('status', [self::STATUS_OPEN, self::STATUS_BIDDING]);
    }

    public function isBiddable(): bool
    {
        return in_array($this->status, [self::STATUS_OPEN, self::STATUS_BIDDING], true)
            && ($this->bidding_deadline === null || $this->bidding_deadline->isFuture());
    }
}
