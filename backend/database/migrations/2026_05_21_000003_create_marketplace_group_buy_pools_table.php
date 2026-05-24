<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('marketplace_group_buy_pools', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('product_listing_id');
            $table->uuid('initiator_company_id');
            $table->unsignedInteger('target_quantity');
            $table->unsignedInteger('current_committed_quantity')->default(0);
            $table->unsignedInteger('min_participants')->default(2);
            $table->unsignedInteger('max_participants')->nullable();
            $table->decimal('pool_price_per_unit', 15, 2);
            $table->decimal('original_price_per_unit', 15, 2);
            $table->decimal('discount_percentage', 5, 2);
            $table->string('pool_status', 20)->default('open');
            // open → gathering → locked → ordered → completed | cancelled | expired
            $table->timestamp('gathering_deadline')->nullable();
            $table->timestamp('locked_at')->nullable();
            $table->timestamp('ordered_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->uuid('order_id')->nullable(); // reference to ResellerOrder after pool locked
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->foreign('product_listing_id')->references('id')->on('marketplace_product_listings')->cascadeOnDelete();
            $table->foreign('initiator_company_id')->references('id')->on('companies')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('marketplace_group_buy_pools');
    }
};
