<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CateringIssuanceItem extends Model
{
    protected $table = 'catering_issuance_items';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'issuance_id',
        'item_id',
        'quantity_issued',
        'quantity_returned',
        'quantity_sold',
        'unit_price_paisa',
    ];

    protected $casts = [
        'quantity_issued'   => 'integer',
        'quantity_returned' => 'integer',
        'quantity_sold'     => 'integer',
        'unit_price_paisa'  => 'integer',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = (string) Str::orderedUuid();
            }
        });
    }

    public function issuance()
    {
        return $this->belongsTo(CateringIssuance::class, 'issuance_id');
    }

    public function item()
    {
        return $this->belongsTo(CateringItem::class, 'item_id');
    }

    public function getOutstandingQuantityAttribute(): int
    {
        return max(0, $this->quantity_issued - $this->quantity_returned - $this->quantity_sold);
    }

    public function getIssuedValuePaisaAttribute(): int
    {
        return $this->quantity_issued * $this->unit_price_paisa;
    }

    public function getReturnedValuePaisaAttribute(): int
    {
        return $this->quantity_returned * $this->unit_price_paisa;
    }

    public function getSoldValuePaisaAttribute(): int
    {
        return $this->quantity_sold * $this->unit_price_paisa;
    }
}
