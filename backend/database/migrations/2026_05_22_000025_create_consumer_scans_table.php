<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consumer_scans', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('consumer_id');
            $table->string('crypto_serial_hash', 64);
            $table->uuid('shopkeeper_id')->nullable();
            $table->decimal('cashback_awarded', 15, 2)->default(0);
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->boolean('is_velocity_diverted')->default(false);
            $table->uuid('wallet_transaction_id')->nullable();
            $table->timestamps();

            $table->index(['crypto_serial_hash']);
            $table->index(['consumer_id', 'created_at']);
        });

        Schema::table('product_serialized_items', function (Blueprint $table) {
            if (! Schema::hasColumn('product_serialized_items', 'activation_status')) {
                $table->string('activation_status', 20)->default('vaulted')->after('is_scanned_out');
                // vaulted, in_transit, retail_stock, activated_sold
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consumer_scans');
        Schema::table('product_serialized_items', function (Blueprint $table) {
            $table->dropColumn('activation_status');
        });
    }
};
