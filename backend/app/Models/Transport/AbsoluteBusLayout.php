<?php

namespace App\Models\Transport;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * NEXATRACE — ABSOLUTE BUS LAYOUT MODEL
 * ======================================
 *
 * Eloquent model for the `absolute_bus_layouts` table.
 * 100% isolated from the legacy `BusLayout` grid-based model.
 *
 * Components use pixel coordinates (x, y, width, height, rotation)
 * instead of grid row/column integers.
 */
class AbsoluteBusLayout extends Model
{
    use SoftDeletes;

    protected $table = 'absolute_bus_layouts';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'owner_identity_id',
        'display_name',
        'deck_level',
        'canvas_width',
        'canvas_height',
        'current_snapshot',
        'layout_status',
        'version_number',
        'is_active',
    ];

    protected $casts = [
        'canvas_width' => 'integer',
        'canvas_height' => 'integer',
        'current_snapshot' => 'array',
        'version_number' => 'integer',
        'is_active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Scope: only active (non-archived) layouts.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where('layout_status', '!=', 'archived');
    }

    /**
     * Total components in the snapshot.
     */
    public function totalComponents(): int
    {
        $snap = $this->current_snapshot;
        if (!$snap) return 0;
        return count($snap['components'] ?? []);
    }

    /**
     * Count of bookable seats in the snapshot.
     */
    public function totalSeats(): int
    {
        $snap = $this->current_snapshot;
        if (!$snap) return 0;
        return ($snap['metadata']['total_bookable_seats'] ?? 0);
    }
}
