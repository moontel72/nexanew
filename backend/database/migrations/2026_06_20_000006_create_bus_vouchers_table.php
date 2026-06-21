<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — BUS VOUCHERS TABLE
 * ===============================
 *
 * Bus Fleets and Owners create/manage their own vouchers.
 * Vouchers are company-scoped and can be:
 *   - Percentage discounts (e.g. 15% off)
 *   - Fixed amount (e.g. Rs. 200 off)
 *   - Loyalty multiplier (e.g. 2x points)
 *
 * TABLE: bus_vouchers
 */

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('bus_vouchers')) {
            return;
        }

        Schema::create('bus_vouchers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('bus_company_id');        // owning fleet/owner
            $table->string('code', 30)->unique();    // e.g. "RADHNAL50"
            $table->string('title');
            $table->enum('type', ['percentage', 'fixed', 'multiplier']);
            $table->decimal('value', 10, 2);          // e.g. 15.00 (% or Rs.)
            $table->decimal('min_order', 10, 2)->default(0);
            $table->decimal('max_discount', 10, 2)->nullable();
            $table->integer('usage_limit')->nullable();
            $table->integer('used_count')->default(0);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('bus_company_id');
            $table->index('code');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bus_vouchers');
    }
};
