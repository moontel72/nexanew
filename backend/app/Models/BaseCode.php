<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasOne;

/**
 * Base Code Model — Common parent for all code types.
 *
 * Class-table inheritance: bundle_codes, carton_codes, packet_codes,
 * and unit_codes all reference base_codes.id as their primary key.
 */
class BaseCode extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';
    protected $table = 'base_codes';

    protected $fillable = [
        'id',
        'company_id',
        'subscription_plan_id',
        'code',
        'code_type',
        'status',
        'store_keeper_code',
        'store_keeper_prefix',
        'international_code',
        'batch_id',
        'generated_at',
        'linked_at',
        'published_at',
        'deactivated_at',
        'product_id',
        'product_batch_number',
        'manufacturing_date',
        'expiry_date',
        'warranty_months',
        'qr_code_data',
        'barcode_data',
        'metadata',
        'version',
        'is_deleted',
    ];

    protected $casts = [
        'generated_at' => 'datetime',
        'linked_at' => 'datetime',
        'published_at' => 'datetime',
        'deactivated_at' => 'datetime',
        'manufacturing_date' => 'date',
        'expiry_date' => 'date',
        'warranty_months' => 'integer',
        'version' => 'integer',
        'is_deleted' => 'boolean',
        'metadata' => 'array',
    ];

    // ─── Relationships ──────────────────────────────────────────

    public function product(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function unitCode(): HasOne
    {
        return $this->hasOne(UnitCode::class, 'id', 'id');
    }

    public function packetCode(): HasOne
    {
        return $this->hasOne(PacketCode::class, 'id', 'id');
    }

    public function cartonCode(): HasOne
    {
        return $this->hasOne(CartonCode::class, 'id', 'id');
    }
}
