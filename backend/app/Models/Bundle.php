<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Bundle extends Model
{
    use HasFactory;

    protected $table = 'bundles';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'bundle_code',
        'order_reference',
        'company_id',
        'total_cartons',
        'total_packets',
        'location_store',
        'location_shelf',
        'status',
        'packed_by',
        'packed_at',
        'notes',
    ];

    protected $casts = [
        'total_cartons' => 'integer',
        'total_packets' => 'integer',
        'packed_at' => 'datetime',
    ];

    // ─── Relationships ───────────────────────────────────────────

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(BundleItem::class);
    }

    /** Carton codes linked through bundle_items pivot */
    public function cartonCodes(): BelongsToMany
    {
        return $this->belongsToMany(
            CartonCode::class,
            'bundle_items',
            'bundle_id',
            'carton_code_id',
            'id',
            'id'
        )->whereNotNull('bundle_items.carton_code_id');
    }

    /** Packet codes linked through bundle_items pivot */
    public function packetCodes(): BelongsToMany
    {
        return $this->belongsToMany(
            PacketCode::class,
            'bundle_items',
            'bundle_id',
            'packet_code_id',
            'id',
            'id'
        )->whereNotNull('bundle_items.packet_code_id');
    }

    /** All carton + packet items as a merged collection */
    public function allItems()
    {
        return $this->items()->with(['cartonCode', 'packetCode'])->get();
    }

    // ─── Helpers ──────────────────────────────────────────────────

    public function isDraft(): bool
    {
        return $this->status === 'draft';
    }

    public function isPacked(): bool
    {
        return $this->status === 'packed';
    }

    public function isShipped(): bool
    {
        return $this->status === 'shipped';
    }

    public function isDelivered(): bool
    {
        return $this->status === 'delivered';
    }

    public function recalculateTotals(): void
    {
        $this->total_cartons = $this->items()->whereNotNull('carton_code_id')->count();
        $this->total_packets = $this->items()->whereNotNull('packet_code_id')->count();
        $this->save();
    }
}
