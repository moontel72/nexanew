<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class ProductListing extends Model
{
    use SoftDeletes;

    protected $table = 'marketplace_product_listings';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'storefront_id', 'product_id', 'listing_title', 'listing_description',
        'category', 'sub_category', 'base_price', 'currency', 'moq',
        'available_quantity', 'unit', 'volume_tiers', 'images', 'specifications',
        'tags', 'view_count', 'inquiry_count', 'is_active',
        'elasticsearch_synced_at', 'metadata',
    ];

    protected $casts = [
        'volume_tiers' => 'array',
        'images' => 'array',
        'specifications' => 'array',
        'tags' => 'array',
        'metadata' => 'array',
        'base_price' => 'float',
        'moq' => 'integer',
        'available_quantity' => 'integer',
        'view_count' => 'integer',
        'inquiry_count' => 'integer',
        'is_active' => 'boolean',
        'elasticsearch_synced_at' => 'datetime',
    ];

    // ─── Relationships ──────────────────────────────────

    public function storefront(): BelongsTo
    {
        return $this->belongsTo(Storefront::class);
    }

    public function groupBuyPools(): HasMany
    {
        return $this->hasMany(GroupBuyPool::class);
    }

    // ─── Scopes ─────────────────────────────────────────

    /**
     * A listing is "active" when the product is published to the marketplace.
     *
     * Stock is deliberately NOT part of this predicate: a factory product has no
     * stock column, so gating visibility on `available_quantity > 0` hid every
     * fresh listing (the listing is created with quantity 0) and made the whole
     * marketplace look empty. Use {@see scopeInStock} where real stock matters.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Only listings that actually report stock (reseller inventory views etc.).
     */
    public function scopeInStock($query)
    {
        return $query->where('available_quantity', '>', 0);
    }

    // ─── Accessors ──────────────────────────────────────

    /**
     * Get the effective price for a given quantity, considering volume tiers.
     */
    public function getPriceForQuantity(int $quantity): float
    {
        $tiers = $this->volume_tiers ?? [];

        if (empty($tiers)) {
            return $this->base_price;
        }

        // Sort tiers descending by min_qty to find the best applicable tier
        usort($tiers, fn($a, $b) => ($b['min_qty'] ?? 0) <=> ($a['min_qty'] ?? 0));

        foreach ($tiers as $tier) {
            if ($quantity >= ($tier['min_qty'] ?? 0)) {
                return (float) ($tier['price'] ?? $this->base_price);
            }
        }

        return $this->base_price;
    }
}
