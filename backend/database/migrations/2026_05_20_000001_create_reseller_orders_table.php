<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reseller_orders', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('reseller_id');
            $table->string('tenant_id')->default('default');
            $table->uuid('factory_id');
            $table->string('order_status')->default('pending'); // pending, confirmed, shipped, delivered, cancelled
            $table->jsonb('items')->default('[]'); // array of {product_id, quantity, unit_price, ...}
            $table->decimal('subtotal', 12, 2)->default(0);
            $table->decimal('discount_total', 12, 2)->default(0);
            $table->decimal('tax_total', 12, 2)->default(0);
            $table->decimal('grand_total', 12, 2)->default(0);
            $table->string('currency', 10)->default('PKR');
            $table->string('pricing_profile_id')->nullable();
            $table->jsonb('metadata')->default('{}');
            $table->timestamps();

            $table->foreign('reseller_id')->references('id')->on('resellers')->onDelete('cascade');
            $table->foreign('factory_id')->references('id')->on('companies')->onDelete('cascade');
            $table->index(['reseller_id', 'order_status']);
            $table->index('factory_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reseller_orders');
    }
};
