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
        'image_urls' => 'array',
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
}
