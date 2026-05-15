<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class PacketCode extends Model
{
    use HasFactory;

    protected $table = 'packet_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
        'code_format',
        'packet_code',
        'company_id',
        'factory_id',
        'carton_code_id',
        'status',
    ];

    public function baseCode(): BelongsTo
    {
        return $this->belongsTo(BaseCode::class, 'id', 'id');
    }

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
