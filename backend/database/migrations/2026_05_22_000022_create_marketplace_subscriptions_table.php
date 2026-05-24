<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('marketplace_subscriptions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->string('tier', 20)->default('basic'); // basic, standard_reseller
            $table->unsignedInteger('max_allowed_items')->default(5);
            $table->timestamp('expires_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique('user_id');
        });

        Schema::table('marketplace_product_listings', function (Blueprint $table) {
            if (! Schema::hasColumn('marketplace_product_listings', 'is_homemade')) {
                $table->boolean('is_homemade')->default(false)->after('is_msrp_enforced');
            }
            if (! Schema::hasColumn('marketplace_product_listings', 'is_brand_verified')) {
                $table->boolean('is_brand_verified')->default(false)->after('is_homemade');
            }
            if (! Schema::hasColumn('marketplace_product_listings', 'reseller_otp_locked')) {
                $table->boolean('reseller_otp_locked')->default(false)->after('is_brand_verified');
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('marketplace_subscriptions');
        Schema::table('marketplace_product_listings', function (Blueprint $table) {
            $table->dropColumn(['is_homemade', 'is_brand_verified', 'reseller_otp_locked']);
        });
    }
};
