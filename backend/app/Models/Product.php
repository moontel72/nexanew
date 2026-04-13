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
    ];

    protected $casts = [
        'requires_manufacturing_date' => 'boolean',
        'requires_expiry_date' => 'boolean',
        'requires_warranty' => 'boolean',
        'image_urls' => 'array',
        'metadata' => 'array',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }
}

