<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('freight_loads', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('poster_company_id');
            $table->string('poster_type', 30); // factory, reseller, goods_company, customer
            $table->string('origin_city', 150);
            $table->string('destination_city', 150);
            $table->decimal('origin_lat', 10, 7)->nullable();
            $table->decimal('origin_lng', 10, 7)->nullable();
            $table->decimal('dest_lat', 10, 7)->nullable();
            $table->decimal('dest_lng', 10, 7)->nullable();
            $table->string('cargo_type', 100); // general, perishable, fragile, hazmat, oversized
            $table->decimal('weight_tons', 8, 2);
            $table->string('required_truck_type', 50)->nullable(); // flatbed, reefer, container, tanker, any
            $table->decimal('expected_price', 15, 2);
            $table->string('currency', 10)->default('USD');
            $table->text('description')->nullable();
            $table->string('pickup_address', 500)->nullable();
            $table->string('delivery_address', 500)->nullable();
            $table->timestamp('pickup_window_start')->nullable();
            $table->timestamp('pickup_window_end')->nullable();
            $table->timestamp('delivery_window_start')->nullable();
            $table->timestamp('delivery_window_end')->nullable();
            $table->string('status', 30)->default('open');
            // open → bidding → matched → in_transit → delivered → completed | cancelled | expired
            $table->timestamp('bidding_deadline')->nullable();
            $table->timestamp('matched_at')->nullable();
            $table->uuid('winning_bid_id')->nullable();
            $table->unsignedInteger('bid_count')->default(0);
            $table->unsignedInteger('view_count')->default(0);
            $table->json('requirements')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('poster_company_id')->references('id')->on('companies')->cascadeOnDelete();

            $table->index(['status', 'bidding_deadline']);
            $table->index(['origin_city', 'destination_city']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('freight_loads');
    }
};
