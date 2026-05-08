<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/**
 * Thin Eloquent model for the packet_codes table.
 * Used only for relationship bindings — core logic stays in PacketCodesController.
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
}
