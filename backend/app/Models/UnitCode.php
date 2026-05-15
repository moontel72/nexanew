<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class UnitCode extends Model
{
    use HasFactory;

    protected $table = 'unit_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    // unit_codes table has no created_at / updated_at columns
    public $timestamps = false;

    protected $fillable = [
        'code_format',
        'unit_code',
        'company_id',
        'factory_id',
        'packet_code_id',
        'status',
    ];

    // ─── Relationships ──────────────────────────────────────────

    /** Inverse of BaseCode.unitCode() — same PK (class-table inheritance). */
    public function baseCode(): BelongsTo
    {
        return $this->belongsTo(BaseCode::class, 'id', 'id');
    }

    // ─── Boot ───────────────────────────────────────────────────

    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
        });
    }
}
