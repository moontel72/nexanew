<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\Marketplace\ProductListing;
use App\Models\Marketplace\Storefront;
use App\Models\Product;
use App\Services\Marketplace\MarketplaceListingService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

/**
 * Item #9 — the marketplace upload flow.
 *
 * Before the fix, publishing a product only set `products.marketplace_enabled`;
 * `marketplace_product_listings` and `marketplace_storefronts` stayed empty, so the
 * marketplace had nothing to show. These tests prove the missing half:
 *
 *   product -> listing, and the storefront is created on the FIRST upload.
 *
 * The production migrations are Postgres-specific, so the handful of tables this
 * flow touches are created here in a sqlite-compatible shape (same approach as
 * StudioAuthControllerTest).
 */
class MarketplaceListingServiceTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        $this->createTables();
    }

    public function test_first_publish_creates_the_storefront_and_a_listing(): void
    {
        $company = $this->makeCompany();
        $product = $this->makeProduct($company, [
            'wholesale_price' => 100,
            'moq' => 5,
            'volume_discounts' => [
                ['min_qty' => 100, 'discount_percent' => 10],
                ['min_qty' => 1000, 'discount_percent' => 20],
            ],
        ]);

        $this->assertSame(0, Storefront::count());
        $this->assertSame(0, ProductListing::count());

        $listing = app(MarketplaceListingService::class)->publishProduct($product);

        $this->assertNotNull($listing);
        $this->assertSame(1, Storefront::count());
        $this->assertSame(1, ProductListing::count());

        $storefront = Storefront::first();
        $this->assertSame($company->id, $storefront->company_id);
        $this->assertSame('factory', $storefront->company_type);
        $this->assertSame('verified', $storefront->verification_status);
        $this->assertTrue((bool) $storefront->is_active);

        $this->assertSame($storefront->id, $listing->storefront_id);
        $this->assertSame($product->id, $listing->product_id);
        $this->assertSame('Test Product', $listing->listing_title);
        $this->assertSame(100.0, (float) $listing->base_price);
        $this->assertSame(5, $listing->moq);
        $this->assertTrue((bool) $listing->is_active);

        $tiers = $listing->volume_tiers;
        $this->assertCount(2, $tiers);
        $this->assertSame(100, (int) $tiers[0]['min_qty']);
        $this->assertSame(90.0, (float) $tiers[0]['price']); // 100 - 10%
        $this->assertSame(80.0, (float) $tiers[1]['price']); // 100 - 20%
    }

    public function test_re_publishing_updates_the_listing_instead_of_duplicating_it(): void
    {
        $company = $this->makeCompany();
        $product = $this->makeProduct($company, ['wholesale_price' => 10]);

        $service = app(MarketplaceListingService::class);
        $first = $service->publishProduct($product);

        $product->wholesale_price = 25;
        $product->save();

        $second = $service->publishProduct($product->fresh());

        $this->assertSame(1, Storefront::count());
        $this->assertSame(1, ProductListing::count());
        $this->assertSame($first->id, $second->id);
        $this->assertSame(25.0, (float) $second->base_price);
    }

    public function test_sync_follows_the_products_marketplace_flag(): void
    {
        $company = $this->makeCompany();
        $product = $this->makeProduct($company, ['wholesale_price' => 10, 'marketplace_enabled' => true]);

        $service = app(MarketplaceListingService::class);

        $service->syncProduct($product);
        $this->assertSame(1, ProductListing::count());
        $this->assertTrue((bool) ProductListing::first()->is_active);

        $product->marketplace_enabled = false;
        $product->save();

        $service->syncProduct($product->fresh());

        // Deactivated, never deleted — order history must stay resolvable.
        $this->assertSame(1, ProductListing::count());
        $this->assertFalse((bool) ProductListing::first()->is_active);
    }

    public function test_publish_prefers_wholesale_then_unit_then_carton_price(): void
    {
        $company = $this->makeCompany();

        $wholesale = $this->makeProduct($company, ['wholesale_price' => 30, 'unit_price' => 20]);
        $unitOnly = $this->makeProduct($company, ['wholesale_price' => null, 'unit_price' => 15]);

        $service = app(MarketplaceListingService::class);

        $this->assertSame(30.0, (float) $service->publishProduct($wholesale)->base_price);
        $this->assertSame(15.0, (float) $service->publishProduct($unitOnly)->base_price);

        // One company, one storefront — even with two products published.
        $this->assertSame(1, Storefront::count());
        $this->assertSame(2, ProductListing::count());
    }

    public function test_storefront_slug_stays_unique_when_company_names_collide(): void
    {
        $service = app(MarketplaceListingService::class);

        foreach (['Same Name Ltd', 'Same Name Ltd', 'same name ltd'] as $name) {
            $company = $this->makeCompany($name);
            $service->publishProduct($this->makeProduct($company, ['wholesale_price' => 1]));
        }

        $slugs = Storefront::pluck('slug')->all();

        $this->assertCount(3, $slugs);
        $this->assertSame($slugs, array_values(array_unique($slugs)));
    }

    private function makeCompany(string $name = 'Test Factory'): Company
    {
        return Company::create([
            'id' => (string) Str::uuid(),
            'name' => $name,
            'company_type' => 'manufacturing',
            'industry_type' => 'other',
            'email' => Str::lower(Str::random(10)).'@example.com',
            'status' => 'active',
            'is_deleted' => false,
        ]);
    }

    private function makeProduct(Company $company, array $overrides = []): Product
    {
        return Product::create(array_merge([
            'id' => (string) Str::uuid(),
            'company_id' => $company->id,
            'name' => 'Test Product',
            'sku' => 'SKU-'.Str::upper(Str::random(8)),
            'product_type' => 'electronics',
            'status' => 'active',
            'currency' => 'PKR',
            'moq' => 1,
            'marketplace_enabled' => true,
            'unit_price' => 0,
        ], $overrides));
    }

    /**
     * The tables the upload flow touches, in a sqlite-compatible shape.
     */
    private function createTables(): void
    {
        if (! Schema::hasTable('companies')) {
            Schema::create('companies', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name');
                $table->string('company_type')->nullable();
                $table->string('industry_type')->nullable();
                $table->string('email')->nullable();
                $table->string('phone')->nullable();
                $table->string('status')->default('active');
                $table->boolean('is_deleted')->default(false);
                $table->json('metadata')->nullable();
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('products')) {
            Schema::create('products', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->string('name');
                $table->string('sku')->nullable();
                $table->text('description')->nullable();
                $table->string('category')->nullable();
                $table->string('product_type')->nullable();
                $table->string('status')->default('active');
                $table->text('image_urls')->nullable();
                $table->json('metadata')->nullable();
                $table->string('currency', 10)->default('PKR');
                $table->decimal('unit_price', 12, 2)->nullable();
                $table->decimal('carton_price', 12, 2)->nullable();
                $table->decimal('wholesale_price', 12, 2)->nullable();
                $table->unsignedInteger('moq')->default(1);
                $table->boolean('marketplace_enabled')->default(false);
                $table->json('tags')->nullable();
                $table->json('volume_discounts')->nullable();
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('marketplace_storefronts')) {
            Schema::create('marketplace_storefronts', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->string('company_type', 20);
                $table->string('storefront_name', 200);
                $table->string('slug', 200)->unique();
                $table->text('description')->nullable();
                $table->string('logo_url', 500)->nullable();
                $table->string('banner_url', 500)->nullable();
                $table->string('website_url', 500)->nullable();
                $table->string('contact_email', 200)->nullable();
                $table->string('contact_phone', 50)->nullable();
                $table->json('business_hours')->nullable();
                $table->json('shipping_regions')->nullable();
                $table->string('verification_status', 20)->default('pending');
                $table->timestamp('verified_at')->nullable();
                $table->uuid('verified_by')->nullable();
                $table->decimal('rating', 3, 2)->default(0);
                $table->unsignedInteger('total_reviews')->default(0);
                $table->boolean('is_active')->default(true);
                $table->json('metadata')->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
        }

        if (! Schema::hasTable('marketplace_product_listings')) {
            Schema::create('marketplace_product_listings', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('storefront_id');
                $table->uuid('product_id')->nullable();
                $table->string('listing_title', 300);
                $table->text('listing_description')->nullable();
                $table->string('category', 100)->nullable();
                $table->string('sub_category', 100)->nullable();
                $table->decimal('base_price', 15, 2);
                $table->string('currency', 10)->default('USD');
                $table->unsignedInteger('moq')->default(1);
                $table->unsignedInteger('available_quantity')->default(0);
                $table->string('unit', 50)->default('piece');
                $table->json('volume_tiers')->nullable();
                $table->json('images')->nullable();
                $table->json('specifications')->nullable();
                $table->json('tags')->nullable();
                $table->unsignedInteger('view_count')->default(0);
                $table->unsignedInteger('inquiry_count')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamp('elasticsearch_synced_at')->nullable();
                $table->json('metadata')->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
        }
    }
}
