<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CartonCode extends Model
{
    protected $table = 'carton_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'code_format', 'bundle_code_id', 'packet_count',
        'packet_codes', 'sequence_number', 'total_units',
    ];

    // ─── Relationships ──────────────────────────────────────────

    public function bundles(): BelongsToMany
    {
        return $this->belongsToMany(
            Bundle::class,
            'bundle_items',
            'carton_code_id',
            'bundle_id',
            'id',
            'id'
        );
    }

    public function baseCode(): BelongsTo
    {
        return $this->belongsTo(BaseCode::class, 'id', 'id');
    }

    public function packets(): HasMany
    {
        return $this->hasMany(PacketCode::class, 'carton_code_id');
    }
}
