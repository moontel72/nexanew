<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('retail_inventory_ledger', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('shopkeeper_id');
            $table->uuid('product_id')->nullable();
            $table->string('batch_serial', 100)->nullable();
            $table->unsignedInteger('quantity')->default(1);
            $table->string('source', 50)->default('retail_delivery');
            $table->timestamp('credited_at')->nullable();
            $table->timestamps();

            $table->index(['shopkeeper_id', 'product_id']);
            $table->index('batch_serial');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('retail_inventory_ledger');
    }
};
