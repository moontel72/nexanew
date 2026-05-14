<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class UnitCode extends Model
{
    use HasFactory;

    protected $table = 'unit_codes';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'code_format',
        'unit_code',
        'company_id',
        'factory_id',
        'packet_code_id',
        'status',
    ];

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
