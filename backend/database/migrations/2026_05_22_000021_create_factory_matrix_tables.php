<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Add factory_type to companies (or factory-specific table)
        if (! Schema::hasColumn('companies', 'factory_type')) {
            Schema::table('companies', function (Blueprint $table) {
                $table->string('factory_type', 20)->default('open')->after('status');
                // open, wholesale_only, zone_locked, stealth_locked
            });
        }

        // 2. Reseller-to-factory zone bindings (Type 3)
        Schema::create('reseller_factory_zones', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('reseller_id');
            $table->uuid('factory_id');
            $table->uuid('zone_id');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['reseller_id', 'factory_id', 'zone_id']);
        });

        // 3. Stealth product unlock records (Type 4)
        Schema::create('stealth_product_unlocks', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('reseller_id');
            $table->uuid('product_id');
            $table->string('otp_method', 10); // phone, email
            $table->string('otp_token_hash', 64);
            $table->timestamp('otp_verified_at')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();

            $table->index(['reseller_id', 'product_id']);
        });

        // 4. MSRP and margin fields
        Schema::table('marketplace_product_listings', function (Blueprint $table) {
            if (! Schema::hasColumn('marketplace_product_listings', 'is_msrp_enforced')) {
                $table->boolean('is_msrp_enforced')->default(false)->after('base_price');
            }
            if (! Schema::hasColumn('marketplace_product_listings', 'factory_buy_price')) {
                $table->decimal('factory_buy_price', 15, 2)->nullable()->after('is_msrp_enforced');
            }
            if (! Schema::hasColumn('marketplace_product_listings', 'reseller_sell_price')) {
                $table->decimal('reseller_sell_price', 15, 2)->nullable()->after('factory_buy_price');
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stealth_product_unlocks');
        Schema::dropIfExists('reseller_factory_zones');
        Schema::table('marketplace_product_listings', function (Blueprint $table) {
            $table->dropColumn(['is_msrp_enforced', 'factory_buy_price', 'reseller_sell_price']);
        });
        Schema::table('companies', function (Blueprint $table) {
            $table->dropColumn('factory_type');
        });
    }
};
