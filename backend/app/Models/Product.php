<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $table = 'products';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'name',
        'sku',
        'description',
        'category',
        'product_type',
        'requires_manufacturing_date',
        'requires_expiry_date',
        'requires_warranty',
        'default_warranty_months',
        'default_storage_conditions',
        'default_handling_instructions',
        'image_urls',
        'status',
        'metadata',
        'unit_price',
        'carton_price',
        'wholesale_price',
        'currency',
        'discount_type',
        'discount_value',
        'moq',
        'marketplace_enabled',
        'bonus_quantity',
        'bonus_threshold',
        'wallet_credit',
        'promo_code',
        'promo_discount',
        'tags',
        'volume_discounts',
    ];

    protected $casts = [
        'requires_manufacturing_date' => 'boolean',
        'requires_expiry_date' => 'boolean',
        'requires_warranty' => 'boolean',
        'metadata' => 'array',
        'unit_price' => 'decimal:2',
        'carton_price' => 'decimal:2',
        'wholesale_price' => 'decimal:2',
        'discount_value' => 'decimal:2',
        'moq' => 'integer',
        'marketplace_enabled' => 'boolean',
        'bonus_quantity' => 'integer',
        'bonus_threshold' => 'integer',
        'wallet_credit' => 'decimal:2',
        'promo_discount' => 'decimal:2',
        'tags' => 'array',
        'volume_discounts' => 'array',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Accessor: parse PostgreSQL text array literal into PHP array.
     */
    public function getImageUrlsAttribute($value): array
    {
        if (empty($value) || $value === '{}' || $value === '[]') {
            return [];
        }

        if (is_array($value)) {
            return $value;
        }

        $clean = trim($value, '{}');
        if (empty($clean)) {
            return [];
        }

        return array_map(function ($item) {
            return trim($item, '" ');
        }, str_getcsv($clean));
    }

    /**
     * Mutator: convert PHP array to PostgreSQL array literal.
     */
    public function setImageUrlsAttribute($value): void
    {
        if (empty($value)) {
            $this->attributes['image_urls'] = '{}';
            return;
        }

        $array = is_array($value) ? $value : [$value];

        $escaped = array_map(function ($item) {
            return '"' . str_replace('"', '\\"', $item) . '"';
        }, $array);

        $this->attributes['image_urls'] = '{' . implode(',', $escaped) . '}';
    }
}
