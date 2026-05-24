<?php

namespace App\Models\Marketplace;

use App\Models\Company;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Storefront extends Model
{
    use SoftDeletes;

    protected $table = 'marketplace_storefronts';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'company_id', 'company_type', 'storefront_name', 'slug',
        'description', 'logo_url', 'banner_url', 'website_url',
        'contact_email', 'contact_phone', 'business_hours', 'shipping_regions',
        'verification_status', 'verified_at', 'verified_by',
        'rating', 'total_reviews', 'is_active', 'metadata',
    ];

    protected $casts = [
        'business_hours' => 'array',
        'shipping_regions' => 'array',
        'metadata' => 'array',
        'rating' => 'float',
        'total_reviews' => 'integer',
        'is_active' => 'boolean',
        'verified_at' => 'datetime',
    ];

    // ─── Relationships ──────────────────────────────────

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function productListings(): HasMany
    {
        return $this->hasMany(ProductListing::class);
    }

    // ─── Scopes ─────────────────────────────────────────

    public function scopeVerified($query)
    {
        return $query->where('verification_status', 'verified');
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
