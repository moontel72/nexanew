<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('freight_bids', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('load_id');
            $table->uuid('bidder_id');
            $table->string('bidder_type', 30); // truck_owner, truck_driver, goods_company
            $table->decimal('bid_amount', 15, 2);
            $table->string('currency', 10)->default('USD');
            $table->string('vehicle_id', 100)->nullable();
            $table->string('vehicle_type', 50)->nullable();
            $table->string('vehicle_plate', 50)->nullable();
            $table->decimal('estimated_delivery_hours', 6, 1)->nullable();
            $table->decimal('bidder_rating', 3, 2)->default(0);
            $table->decimal('bidder_proximity_km', 8, 2)->nullable(); // distance from vehicle to pickup
            $table->decimal('match_score', 8, 4)->nullable(); // computed by matching engine
            $table->text('notes')->nullable();
            $table->string('status', 20)->default('pending');
            // pending → accepted → rejected | expired | withdrawn
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('rejected_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->foreign('load_id')->references('id')->on('freight_loads')->cascadeOnDelete();

            $table->unique(['load_id', 'bidder_id']);
            $table->index(['load_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('freight_bids');
    }
};
