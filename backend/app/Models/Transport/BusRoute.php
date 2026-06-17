<?php

namespace App\Models\Transport;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS ROUTE MODEL
 * =============================
 *
 * Represents a published transit route with ordered waypoints.
 * Used by Module 13B (Route Scheduler), 15A (Driver Manifest),
 * and 8V (Customer Tracking).
 */
class BusRoute extends Model
{
    protected $table = 'transport_bus_routes';

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'id', 'route_code', 'display_name',
        'origin_city', 'destination_city',
        'origin_lat', 'origin_lng',
        'destination_lat', 'destination_lng',
        'total_distance_km', 'estimated_duration_min',
        'status', 'carrier_company_id', 'meta',
    ];

    protected $casts = [
        'origin_lat' => 'float',
        'origin_lng' => 'float',
        'destination_lat' => 'float',
        'destination_lng' => 'float',
        'total_distance_km' => 'float',
        'estimated_duration_min' => 'integer',
        'meta' => 'array',
    ];

    // ── Status Constants ────────────────────────────────
    public const STATUS_DRAFT = 'draft';
    public const STATUS_PUBLISHED = 'published';
    public const STATUS_ARCHIVED = 'archived';

    // ── Boot ────────────────────────────────────────────
    protected static function booted(): void
    {
        static::creating(function (BusRoute $route) {
            if (empty($route->id)) {
                $route->id = (string) Str::uuid();
            }
        });
    }

    // ── Relations ───────────────────────────────────────
    public function waypoints(): HasMany
    {
        return $this->hasMany(BusRouteWaypoint::class, 'route_id')
                    ->orderBy('stop_order');
    }

    // ── Scopes ──────────────────────────────────────────
    public function scopePublished($query)
    {
        return $query->where('status', self::STATUS_PUBLISHED);
    }

    public function scopeForCarrier($query, string $carrierId)
    {
        return $query->where('carrier_company_id', $carrierId);
    }

    // ── Helpers ─────────────────────────────────────────
    public function isPublished(): bool
    {
        return $this->status === self::STATUS_PUBLISHED;
    }

    public function publish(): void
    {
        $this->update(['status' => self::STATUS_PUBLISHED]);
    }
}

// ── Waypoint Model ─────────────────────────────────────

class BusRouteWaypoint extends Model
{
    protected $table = 'transport_bus_route_waypoints';

    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'id', 'route_id', 'stop_order',
        'station_name', 'lat', 'lng',
        'distance_from_origin_km', 'estimated_min_from_origin',
        'meta',
    ];

    protected $casts = [
        'stop_order' => 'integer',
        'lat' => 'float',
        'lng' => 'float',
        'distance_from_origin_km' => 'float',
        'estimated_min_from_origin' => 'integer',
        'meta' => 'array',
    ];

    protected static function booted(): void
    {
        static::creating(function (BusRouteWaypoint $wp) {
            if (empty($wp->id)) {
                $wp->id = (string) Str::uuid();
            }
        });
    }

    public function route()
    {
        return $this->belongsTo(BusRoute::class, 'route_id');
    }
}
