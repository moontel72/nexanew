<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CateringItem extends Model
{
    protected $table = 'catering_items';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'category_id',
        'name',
        'sku',
        'unit',
        'stock_on_hand',
        'low_stock_threshold',
        'unit_price_paisa',
        'image_url',
        'status',
    ];

    protected $casts = [
        'stock_on_hand'       => 'integer',
        'low_stock_threshold' => 'integer',
        'unit_price_paisa'    => 'integer',
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

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function category()
    {
        return $this->belongsTo(CateringCategory::class, 'category_id');
    }

    public function issuanceItems()
    {
        return $this->hasMany(CateringIssuanceItem::class, 'item_id');
    }

    public function scopeForCompany($query, string $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeLowStock($query)
    {
        return $query->whereColumn('stock_on_hand', '<=', 'low_stock_threshold');
    }

    public function isLowStock(): bool
    {
        return $this->stock_on_hand <= $this->low_stock_threshold;
    }

    /**
     * Decrement stock safely (no negatives).
     */
    public function decrementStock(int $quantity): void
    {
        $this->stock_on_hand = max(0, $this->stock_on_hand - $quantity);
        $this->save();
    }

    /**
     * Increment stock (e.g. returns).
     */
    public function incrementStock(int $quantity): void
    {
        $this->stock_on_hand += $quantity;
        $this->save();
    }
}
