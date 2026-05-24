<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('retail_deliveries', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('order_id');
            $table->uuid('driver_id')->nullable();
            $table->uuid('shopkeeper_id')->nullable();
            $table->uuid('warehouse_id')->nullable();
            $table->string('delivery_secure_token', 100)->unique();
            $table->string('status', 20)->default('pending_pickup');
            // pending_pickup → verified_pickup → in_transit → arrived → completed | disputed
            $table->json('invoice_items')->nullable();
            $table->json('scanned_items')->nullable();
            $table->decimal('warehouse_lat', 10, 7)->nullable();
            $table->decimal('warehouse_lng', 10, 7)->nullable();
            $table->decimal('shop_lat', 10, 7)->nullable();
            $table->decimal('shop_lng', 10, 7)->nullable();
            $table->timestamp('pickup_scanned_at')->nullable();
            $table->timestamp('delivery_scanned_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->uuid('freight_payout_txn_id')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['driver_id', 'status']);
            $table->index('order_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('retail_deliveries');
    }
};
