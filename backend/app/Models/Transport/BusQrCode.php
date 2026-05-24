<?php

namespace App\Models\Transport;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BusQrCode extends Model
{
    protected $table = 'transport_bus_qr_codes';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'bus_id', 'qr_payload_uuid', 'active_trip_id', 'is_active',
    ];

    protected $casts = ['is_active' => 'boolean'];

    public function busLayout(): BelongsTo
    {
        return $this->belongsTo(BusLayout::class, 'bus_id');
    }
}
