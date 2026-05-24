<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FreightBid extends Model
{
    protected $table = 'freight_bids';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_PENDING = 'pending';
    public const STATUS_ACCEPTED = 'accepted';
    public const STATUS_REJECTED = 'rejected';
    public const STATUS_EXPIRED = 'expired';
    public const STATUS_WITHDRAWN = 'withdrawn';

    protected $fillable = [
        'id', 'load_id', 'bidder_id', 'bidder_type',
        'bid_amount', 'currency', 'vehicle_id', 'vehicle_type', 'vehicle_plate',
        'estimated_delivery_hours', 'bidder_rating', 'bidder_proximity_km',
        'match_score', 'notes', 'status',
        'accepted_at', 'rejected_at', 'rejection_reason', 'metadata',
    ];

    protected $casts = [
        'bid_amount' => 'float', 'estimated_delivery_hours' => 'float',
        'bidder_rating' => 'float', 'bidder_proximity_km' => 'float',
        'match_score' => 'float', 'metadata' => 'array',
        'accepted_at' => 'datetime', 'rejected_at' => 'datetime',
    ];

    public function load(): BelongsTo
    {
        return $this->belongsTo(FreightLoad::class, 'load_id');
    }
}
