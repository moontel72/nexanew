<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Thin Eloquent model for the packet_codes table.
 */
class PacketCode extends Model
{
    protected $table = 'packet_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'code_format', 'carton_code_id', 'unit_count',
        'unit_codes', 'sequence_number',
    ];

    // ─── Relationships ──────────────────────────────────────────

    public function bundles(): BelongsToMany
    {
        return $this->belongsToMany(
            Bundle::class,
            'bundle_items',
            'packet_code_id',
            'bundle_id',
            'id',
            'id'
        );
    }

    public function baseCode(): BelongsTo
    {
        return $this->belongsTo(BaseCode::class, 'id', 'id');
    }

    public function carton(): BelongsTo
    {
        return $this->belongsTo(CartonCode::class, 'carton_code_id');
    }

    public function units(): HasMany
    {
        return $this->hasMany(UnitCode::class, 'packet_code_id');
    }
}
