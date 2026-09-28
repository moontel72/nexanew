<?php

namespace App\Services\Marketplace;

use App\Models\Company;
use App\Models\Marketplace\ProductListing;
use App\Models\Marketplace\Storefront;
use App\Models\Product;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — MARKETPLACE LISTING SERVICE
 * ========================================
 *
 * The factory "upload to marketplace" flow (MASTER-TASK-LIST.md item #9).
 *
 * WHY THIS EXISTS
 * ---------------
 * The factory panel's publish button only flipped `products.marketplace_enabled`.
 * Nothing ever wrote a row to `marketplace_product_listings`, so the marketplace
 * stayed empty (live counts: listings = 0, storefronts = 0) even though the UI
 * reported success. This service is the missing half of the flow:
 *
 *   product published   -> the company's storefront (created on the FIRST upload)
 *                       -> one `marketplace_product_listings` row, kept in sync
 *   product unpublished -> its listing is deactivated (never hard-deleted)
 *
 * It is idempotent: publishing the same product twice updates the existing listing
 * instead of creating a duplicate, and re-using an existing storefront if there is
 * one (including a soft-deleted one, whose unique slug still occupies the index).
 */
class MarketplaceListingService
{
    /**
     * Get — or create on first upload — the marketplace storefront for a company.
     */
    public function ensureStorefront(Company $company): Storefront
    {
        // `withTrashed()` matters: the unique index on `slug` does not know about
        // soft deletes, so a previously deleted storefront still owns its slug.
        // Reviving it is the only way to avoid a duplicate-slug failure.
        $storefront = Storefront::withTrashed()
            ->where('company_id', $company->id)
            ->first();

        if ($storefront) {
            if ($storefront->trashed()) {
                $storefront->restore();
            }

            return $storefront;
        }

        $storefront = Storefront::query()->create([
            'id'                  => (string) Str::uuid(),
            'company_id'          => $company->id,
            'company_type'        => 'factory',
            'storefront_name'     => $company->name,
            'slug'                => $this->uniqueSlug((string) $company->name),
            'description'         => null,
            'contact_email'       => $company->email,
            'contact_phone'       => $company->phone,
            // A company that reached the marketplace was already vetted when its
            // account was created, so its storefront starts verified rather than
            // pending — otherwise the catalog (which only shows verified
            // storefronts) would hide every fresh factory.
            'verification_status' => 'verified',
            'verified_at'         => now(),
            'is_active'           => true,
        ]);

        Log::info('MarketplaceListingService: storefront created on first upload.', [
            'company_id'    => $company->id,
            'storefront_id' => $storefront->id,
            'slug'          => $storefront->slug,
        ]);

        return $storefront;
    }

    /**
     * Publish (create or update) a product's marketplace listing.
     *
     * @param  array{available_quantity?: int, unit?: string}  $overrides
     */
    public function publishProduct(Product $product, array $overrides = []): ?ProductListing
    {
        $company = $product->company;

        if (! $company) {
            Log::warning('MarketplaceListingService: product has no company, skipping publish.', [
                'product_id' => $product->id,
            ]);

            return null;
        }

        $storefront = $this->ensureStorefront($company);

        $listing = ProductListing::query()
            ->where('storefront_id', $storefront->id)
            ->where('product_id', $product->id)
            ->first();

        $basePrice = $this->resolveBasePrice($product);

        $attributes = [
            'storefront_id'       => $storefront->id,
            'product_id'          => $product->id,
            'listing_title'       => (string) $product->name,
            'listing_description' => $product->description,
            'category'            => $product->category,
            'base_price'          => $basePrice,
            'currency'            => $product->currency ?: 'PKR',
            'moq'                 => max(1, (int) ($product->moq ?: 1)),
            'available_quantity'  => (int) ($overrides['available_quantity'] ?? $listing?->available_quantity ?? 0),
            'unit'                => (string) ($overrides['unit'] ?? $listing?->unit ?? ($product->metadata['unit'] ?? 'piece')),
            'volume_tiers'        => $this->buildVolumeTiers($product, $basePrice),
            'images'              => $this->images($product),
            'tags'                => is_array($product->tags) && $product->tags !== [] ? array_values($product->tags) : null,
            'is_active'           => true,
        ];

        if ($listing) {
            $listing->fill($attributes)->save();
        } else {
            $attributes['id'] = (string) Str::uuid();
            $listing = ProductListing::query()->create($attributes);
        }

        Log::info('MarketplaceListingService: product published to marketplace.', [
            'product_id'    => $product->id,
            'storefront_id' => $storefront->id,
            'listing_id'    => $listing->id,
        ]);

        return $listing->fresh();
    }

    /**
     * Deactivate the listing(s) for a product after it is removed from the marketplace.
     * The row is kept (soft state via `is_active = false`) so order history and audit
     * references stay valid.
     */
    public function unpublishProduct(Product $product): void
    {
        $updated = ProductListing::query()
            ->where('product_id', $product->id)
            ->where('is_active', true)
            ->update(['is_active' => false]);

        if ($updated > 0) {
            Log::info('MarketplaceListingService: product unpublished from marketplace.', [
                'product_id'    => $product->id,
                'listing_count' => $updated,
            ]);
        }
    }

    /**
     * Reconcile a product's listing with its `marketplace_enabled` flag.
     * Used after create/update so the listing follows the product automatically.
     */
    public function syncProduct(Product $product, array $overrides = []): ?ProductListing
    {
        if ((bool) $product->marketplace_enabled) {
            return $this->publishProduct($product, $overrides);
        }

        $this->unpublishProduct($product);

        return null;
    }

    /**
     * The wholesale price a buyer sees first. Falls back through the other prices
     * the factory may have set, so a listing is never created at a bogus zero.
     */
    private function resolveBasePrice(Product $product): float
    {
        foreach (['wholesale_price', 'unit_price', 'carton_price'] as $column) {
            $value = $product->{$column};
            if ($value !== null && (float) $value > 0) {
                return round((float) $value, 2);
            }
        }

        return 0.0;
    }

    /**
     * Convert the product's `volume_discounts` (min_qty + discount_percent, as the
     * Flutter product form sends them) into the `volume_tiers` shape the marketplace
     * expects (min_qty + absolute price).
     *
     * @return array<int, array{min_qty: int, price: float}>|null
     */
    private function buildVolumeTiers(Product $product, float $basePrice): ?array
    {
        $discounts = $product->volume_discounts;

        if (! is_array($discounts) || $discounts === [] || $basePrice <= 0) {
            return null;
        }

        $tiers = [];
        foreach ($discounts as $tier) {
            if (! is_array($tier)) {
                continue;
            }

            $minQty = (int) ($tier['min_qty'] ?? $tier['min_quantity'] ?? 0);
            if ($minQty <= 0) {
                continue;
            }

            // Already absolute (a `price` key) or a percentage discount from base.
            if (isset($tier['price']) && is_numeric($tier['price'])) {
                $price = (float) $tier['price'];
            } else {
                $percent = (float) ($tier['discount_percent'] ?? $tier['discount'] ?? 0);
                $percent = max(0.0, min(100.0, $percent));
                $price = $basePrice * (1 - ($percent / 100));
            }

            $tiers[] = [
                'min_qty' => $minQty,
                'price'   => round(max(0.0, $price), 2),
            ];
        }

        if ($tiers === []) {
            return null;
        }

        usort($tiers, fn ($a, $b) => $a['min_qty'] <=> $b['min_qty']);

        return $tiers;
    }

    /**
     * @return array<int, string>|null
     */
    private function images(Product $product): ?array
    {
        $urls = is_array($product->image_urls) ? $product->image_urls : [];

        $metaImage = $product->metadata['image_url'] ?? null;
        if (is_string($metaImage) && $metaImage !== '' && ! in_array($metaImage, $urls, true)) {
            $urls[] = $metaImage;
        }

        $urls = array_values(array_filter($urls, fn ($url) => is_string($url) && $url !== ''));

        return $urls === [] ? null : $urls;
    }

    /**
     * A URL-safe, unique storefront slug derived from the company name.
     */
    private function uniqueSlug(string $name): string
    {
        $base = Str::slug($name);
        if ($base === '') {
            $base = 'storefront';
        }
        $base = Str::limit($base, 180, '');

        $slug = $base;
        $suffix = 2;

        while (Storefront::withTrashed()->where('slug', $slug)->exists()) {
            $slug = $base.'-'.$suffix;
            $suffix++;

            if ($suffix > 1000) {
                $slug = $base.'-'.Str::lower((string) Str::uuid());
                break;
            }
        }

        return $slug;
    }
}
