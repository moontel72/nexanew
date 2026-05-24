<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('trip_bidding_requests')) {
            Schema::create('trip_bidding_requests', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('requester_type', 30); // factory_admin | customer | reseller | shop_keeper
                $table->uuid('requester_id');
                $table->string('asset_category', 10); // truck | bus
                $table->string('pickup_location', 255);
                $table->decimal('pickup_lat', 10, 7)->nullable();
                $table->decimal('pickup_lng', 10, 7)->nullable();
                $table->string('dropoff_location', 255);
                $table->decimal('dropoff_lat', 10, 7)->nullable();
                $table->decimal('dropoff_lng', 10, 7)->nullable();
                $table->integer('radial_range_km')->default(25);
                $table->decimal('cargo_weight_tons', 8, 2)->nullable();
                $table->integer('passenger_seats')->nullable();
                $table->decimal('target_price_pkr', 12, 2)->nullable();
                $table->string('status', 20)->default('open'); // open | bidding | matched | completed | cancelled
                $table->timestamp('bidding_deadline')->nullable();
                $table->timestamps();
                $table->index('status');
                $table->index('asset_category');
            });
        }

        if (!Schema::hasTable('bidding_proposals')) {
            Schema::create('bidding_proposals', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('trip_request_id');
                $table->foreign('trip_request_id')->references('id')->on('trip_bidding_requests')->cascadeOnDelete();
                $table->string('bidder_type', 30); // tenant_company | sub_owner | driver
                $table->uuid('bidder_id');
                $table->decimal('proposed_amount_pkr', 12, 2);
                $table->string('vehicle_plate_number', 32)->nullable();
                $table->decimal('bidder_rating', 3, 2)->default(0);
                $table->decimal('bidder_lat', 10, 7)->nullable();
                $table->decimal('bidder_lng', 10, 7)->nullable();
                $table->string('status', 20)->default('pending'); // pending | accepted | rejected
                $table->timestamp('accepted_at')->nullable();
                $table->timestamps();
                $table->index('trip_request_id');
                $table->index('bidder_type');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('bidding_proposals');
        Schema::dropIfExists('trip_bidding_requests');
    }
};
