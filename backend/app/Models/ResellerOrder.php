<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class ResellerOrder extends Model
{
    use HasFactory;

    protected $table = 'reseller_orders';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'reseller_id',
        'tenant_id',
        'factory_id',
        'order_status',
        'items',
        'subtotal',
        'discount_total',
        'tax_total',
        'grand_total',
        'currency',
        'pricing_profile_id',
        'metadata',
    ];

    protected $casts = [
        'items' => 'array',
        'subtotal' => 'decimal:2',
        'discount_total' => 'decimal:2',
        'tax_total' => 'decimal:2',
        'grand_total' => 'decimal:2',
        'metadata' => 'array',
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

    public function reseller()
    {
        return $this->belongsTo(Reseller::class);
    }

    public function factory()
    {
        return $this->belongsTo(Company::class, 'factory_id');
    }
}
