<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
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
            $table->unsignedInteger('moq')->default(1); // Minimum Order Quantity
            $table->unsignedInteger('available_quantity')->default(0);
            $table->string('unit', 50)->default('piece'); // piece, kg, liter, carton, pallet
            $table->json('volume_tiers')->nullable();
            // volume_tiers example: [{"min_qty":100,"price":9.50},{"min_qty":1000,"price":8.00}]
            $table->json('images')->nullable(); // array of image URLs
            $table->json('specifications')->nullable();
            $table->json('tags')->nullable(); // for Elasticsearch faceting
            $table->unsignedInteger('view_count')->default(0);
            $table->unsignedInteger('inquiry_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamp('elasticsearch_synced_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('storefront_id')->references('id')->on('marketplace_storefronts')->cascadeOnDelete();
        });

        // Full-text index for PostgreSQL native search fallback
        if (config('database.default') === 'pgsql') {
            DB::statement('CREATE INDEX idx_listings_fts ON marketplace_product_listings USING GIN (to_tsvector(\'english\', listing_title || \' \' || COALESCE(listing_description, \'\')))');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('marketplace_product_listings');
    }
};
