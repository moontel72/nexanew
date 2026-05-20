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
     * Handles both native PG arrays and legacy JSON-encoded strings.
     */
    public function getImageUrlsAttribute($value): array
    {
        if (empty($value) || $value === '{}') {
            return [];
        }
        // If it's already a PHP array (from previous cast), return as-is
        if (is_array($value)) {
            return $value;
        }
        // Try JSON decode (legacy data)
        if (str_starts_with($value, '[')) {
            $decoded = json_decode($value, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }
        // Parse PostgreSQL array literal: {"url1","url2"} or {url1,url2}
        $trimmed = trim($value, '{}');
        if ($trimmed === '') {
            return [];
        }
        // Split by comma, respecting quoted strings
        preg_match_all('/"((?:[^"\\]|\\.)*)"|([^,]+)/', $trimmed, $matches);
        $result = [];
        foreach ($matches[1] as $i => $q) {
            if ($q !== '') {
                $result[] = stripslashes($q);
            } elseif (isset($matches[2][$i]) && $matches[2][$i] !== '') {
                $result[] = trim($matches[2][$i]);
            }
        }
        return $result;
    }

    /**
     * Mutator: convert PHP array to PostgreSQL array literal.
     */
    public function setImageUrlsAttribute($value): void
    {
        if (is_array($value)) {
            if (empty($value)) {
                $this->attributes['image_urls'] = '{}';
                return;
            }
            $parts = [];
            foreach ($value as $url) {
                $escaped = str_replace(['\\', '"'], ['\\\\', '\\"'], (string) $url);
                $parts[] = '"' . $escaped . '"';
            }
            $this->attributes['image_urls'] = '{' . implode(',', $parts) . '}';
        } elseif (is_string($value)) {
            $this->attributes['image_urls'] = $value;
        } else {
            $this->attributes['image_urls'] = '{}';
        }
    }
}
