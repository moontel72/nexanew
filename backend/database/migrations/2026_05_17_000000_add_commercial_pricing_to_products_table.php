<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->decimal('unit_price', 12, 2)->nullable()->default(null)->after('metadata');
            $table->decimal('carton_price', 12, 2)->nullable()->default(null)->after('unit_price');
            $table->decimal('wholesale_price', 12, 2)->nullable()->default(null)->after('carton_price');
            $table->string('currency', 10)->default('PKR')->after('wholesale_price');
            $table->string('discount_type', 20)->nullable()->after('currency');
            $table->decimal('discount_value', 12, 2)->nullable()->after('discount_type');
            $table->unsignedInteger('moq')->default(1)->after('discount_value');
            $table->boolean('marketplace_enabled')->default(false)->after('moq');
            $table->unsignedInteger('bonus_quantity')->nullable()->after('marketplace_enabled');
            $table->unsignedInteger('bonus_threshold')->nullable()->after('bonus_quantity');
            $table->decimal('wallet_credit', 12, 2)->nullable()->after('bonus_threshold');
            $table->string('promo_code', 50)->nullable()->after('wallet_credit');
            $table->decimal('promo_discount', 5, 2)->nullable()->after('promo_code');
            $table->json('tags')->nullable()->after('promo_discount');
            $table->json('volume_discounts')->nullable()->after('tags');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn([
                'unit_price',
                'carton_price',
                'wholesale_price',
                'currency',
                'discount_type',
                'discount_value',
                'moq',
                'marketplace_enabled',
                'bonus_quantity',
                'bonus_threshold',
                'wallet_credit',
                'promo_code',
                'promo_discount',
                'tags',
                'volume_discounts',
            ]);
        });
    }
};
