<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\DB;

class SmartCode extends Model
{
    protected $table = 'smart_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'district_prefix',
        'zone_code',
        'parcel_serial',
        'full_code',
        'zone_id',
        'delivery_id',
        'status',
        'scanned_at',
        'scanned_by',
    ];

    protected $casts = [
        'scanned_at' => 'datetime',
    ];

    public function zone(): BelongsTo
    {
        return $this->belongsTo(Zone::class);
    }

    // ─── Automatic full_code generation ──────────────────────────

    protected static function booted(): void
    {
        static::creating(function (SmartCode $code) {
            if (empty($code->full_code)) {
                $code->full_code = self::buildFullCode(
                    $code->district_prefix,
                    $code->zone_code,
                    $code->parcel_serial,
                );
            }
        });
    }

    /**
     * Build the OCR-friendly full code string.
     *
     * Example: buildFullCode('KB', '067', '0002') → 'KB-067-0002'
     */
    public static function buildFullCode(string $prefix, string $zoneCode, string $serial): string
    {
        return strtoupper($prefix) . '-' . $zoneCode . '-' . $serial;
    }

    /**
     * Generate the next parcel serial for a given zone.
     * Format: 4-digit zero-padded auto-increment within the zone.
     *
     * Example: nextSerialForZone($zoneId) → '0003'
     */
    public static function nextSerialForZone(string $zoneId): string
    {
        $last = self::where('zone_id', $zoneId)
            ->orderByDesc('parcel_serial')
            ->value('parcel_serial');

        if (!$last) {
            return '0001';
        }

        $next = (int) $last + 1;
        return str_pad((string) $next, 4, '0', STR_PAD_LEFT);
    }

    // ─── Helpers ──────────────────────────────────────────────────

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isScanned(): bool
    {
        return $this->scanned_at !== null;
    }

    public function markScanned(string $scannedBy): void
    {
        $this->scanned_at = now();
        $this->scanned_by = $scannedBy;
        $this->save();
    }
}
