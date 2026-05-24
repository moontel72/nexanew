<?php

namespace App\Models\Analytics;

use Illuminate\Database\Eloquent\Model;

class AnalyticsSnapshot extends Model
{
    protected $table = 'analytics_snapshots';
    public $incrementing = false;
    protected $keyType = 'string';

    public const TYPE_REALTIME = 'realtime';
    public const TYPE_HOURLY = 'hourly';
    public const TYPE_DAILY = 'daily';
    public const TYPE_WEEKLY = 'weekly';
    public const TYPE_MONTHLY = 'monthly';

    protected $fillable = [
        'id', 'snapshot_type', 'metric_group', 'metric_key',
        'metric_value', 'unit', 'dimensions', 'snapshot_at', 'metadata',
    ];

    protected $casts = [
        'metric_value' => 'float',
        'dimensions' => 'array',
        'metadata' => 'array',
        'snapshot_at' => 'datetime',
    ];

    public function scopeType($query, string $type)
    {
        return $query->where('snapshot_type', $type);
    }

    public function scopeGroup($query, string $group)
    {
        return $query->where('metric_group', $group);
    }

    public function scopeBetween($query, string $start, string $end)
    {
        return $query->whereBetween('snapshot_at', [$start, $end]);
    }
}
