<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BundleItem extends Model
{
    protected $table = 'bundle_items';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'bundle_id', 'carton_code_id', 'packet_code_id',
    ];

    public function bundle(): BelongsTo
    {
        return $this->belongsTo(Bundle::class);
    }

    public function cartonCode(): BelongsTo
    {
        return $this->belongsTo(CartonCode::class, 'carton_code_id');
    }

    public function packetCode(): BelongsTo
    {
        return $this->belongsTo(PacketCode::class, 'packet_code_id');
    }
}
