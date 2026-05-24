<?php

namespace App\Models\Transport;

use Illuminate\Database\Eloquent\Model;

class BusTrip extends Model
{
    protected $table = 'transport_bus_trips';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_SCHEDULED = 'scheduled';
    public const STATUS_ACTIVE = 'active';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'id', 'route_id', 'bus_id', 'driver_id',
        'origin', 'destination', 'waypoints',
        'status', 'current_lat', 'current_lng', 'current_speed',
        'estimated_arrival_json', 'current_waypoint_index',
        'started_at', 'completed_at', 'cancelled_at', 'cancellation_reason',
        'metadata',
    ];

    protected $casts = [
        'waypoints' => 'array',
        'estimated_arrival_json' => 'array',
        'metadata' => 'array',
        'current_lat' => 'float', 'current_lng' => 'float',
        'current_speed' => 'float', 'current_waypoint_index' => 'integer',
        'started_at' => 'datetime', 'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }

    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }
}
