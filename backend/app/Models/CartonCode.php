<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/**
 * Thin Eloquent model for the carton_codes table.
 * Used only for relationship bindings — core logic stays in CartonCodesController.
 */
class CartonCode extends Model
{
    protected $table = 'carton_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'code_format', 'bundle_code_id', 'packet_count',
        'packet_codes', 'sequence_number', 'total_units',
    ];

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
}
