<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Unit Code Model — Authentication/Leaf-level codes.
 *
 * These are the lowest level in the packaging hierarchy:
 *   Bundle → Carton → Packet → Unit (this)
 *
 * FK chain:
 *   unit_codes.packet_code_id → packet_codes.id
 *   unit_codes.id → base_codes.id (class-table inheritance)
 */
class UnitCode extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';
    protected $table = 'unit_codes';

    protected $fillable = [
        'id',
        'code_format',
        'packet_code_id',
        'sequence_number',
        'authentication_code',
        'is_master_code',
        'master_code_id',
        'verification_count',
        'first_verified_at',
        'last_verified_at',
        'verification_location',
        'verified_by',
        'is_reported_fake',
        'fake_reported_at',
        'fake_reported_by',
        'fake_report_reason',
        'is_blocked',
        'blocked_at',
        'blocked_by',
        'block_reason',
        'serial_number',
        'model',
    ];

    protected $casts = [
        'is_master_code' => 'boolean',
        'is_reported_fake' => 'boolean',
        'is_blocked' => 'boolean',
        'verification_count' => 'integer',
        'sequence_number' => 'integer',
        'first_verified_at' => 'datetime',
        'last_verified_at' => 'datetime',
        'fake_reported_at' => 'datetime',
        'blocked_at' => 'datetime',
    ];

    // ─── Relationships ──────────────────────────────────────────

    /**
     * The base_code this unit inherits from (class-table inheritance).
     */
    public function baseCode(): BelongsTo
    {
        return $this->belongsTo(BaseCode::class, 'id', 'id');
    }

    /**
     * The packet this unit belongs to.
     */
    public function packet(): BelongsTo
    {
        return $this->belongsTo(PacketCode::class, 'packet_code_id');
    }

    /**
     * The master unit code (if this unit was derived from one).
     */
    public function masterCode(): BelongsTo
    {
        return $this->belongsTo(self::class, 'master_code_id');
    }

    // ─── Scopes ─────────────────────────────────────────────────

    /**
     * Only units that are NOT linked to any packet (available for linking).
     */
    public function scopeAvailable($query)
    {
        return $query->whereNull('packet_code_id');
    }

    /**
     * Filter by product via base_codes join.
     */
    public function scopeByProduct($query, string $productId)
    {
        return $query->whereHas('baseCode', function ($q) use ($productId) {
            $q->where('product_id', $productId);
        });
    }

    /**
     * Filter by batch via base_codes join.
     */
    public function scopeByBatch($query, string $batchId)
    {
        return $query->whereHas('baseCode', function ($q) use ($batchId) {
            $q->where('batch_id', $batchId);
        });
    }

    /**
     * Only published units.
     */
    public function scopePublished($query)
    {
        return $query->whereHas('baseCode', function ($q) {
            $q->where('status', 'published');
        });
    }
}
