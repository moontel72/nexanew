<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ENSURE ALL PHASE 4.5 TABLES EXIST (FAILSAFE)
 * ===========================================================
 *
 * Some prior migrations may not have run on the production
 * server. This migration uses IF NOT EXISTS guards to safely
 * create any missing tables/columns without erroring on
 * already-applied schema.
 */

return new class extends Migration
{
    public function up(): void
    {
        // ── bus_vouchers ──────────────────────────────────
        if (! Schema::hasTable('bus_vouchers')) {
            Schema::create('bus_vouchers', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('bus_company_id');
                $table->string('code', 30)->unique();
                $table->string('title');
                $table->enum('type', ['percentage', 'fixed', 'multiplier']);
                $table->decimal('value', 10, 2);
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

        // ── passenger_loyalty_ledger ──────────────────────
        if (! Schema::hasTable('passenger_loyalty_ledger')) {
            Schema::create('passenger_loyalty_ledger', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('passenger_id');
                $table->string('bus_company_id');
                $table->integer('total_trips')->default(0);
                $table->decimal('total_spent', 12, 2)->default(0);
                $table->integer('loyalty_points')->default(0);
                $table->string('tier')->default('bronze');
                $table->timestamp('last_trip_at')->nullable();
                $table->timestamps();
                $table->unique(['passenger_id', 'bus_company_id']);
                $table->index('passenger_id');
                $table->index('bus_company_id');
                $table->index('tier');
            });
        }

        // ── voucher_redemptions ───────────────────────────
        if (! Schema::hasTable('voucher_redemptions')) {
            Schema::create('voucher_redemptions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('voucher_id');
                $table->uuid('passenger_id');
                $table->uuid('booking_id')->nullable();
                $table->decimal('discount_amount', 10, 2);
                $table->decimal('original_price', 10, 2);
                $table->decimal('final_price', 10, 2);
                $table->timestamps();
                $table->index('voucher_id');
                $table->index('passenger_id');
                $table->index('booking_id');
            });
        }

        // ── owner_identity_id on transport_bus_routes ─────
        if (! Schema::hasColumn('transport_bus_routes', 'owner_identity_id')) {
            Schema::table('transport_bus_routes', function (Blueprint $table) {
                $table->string('owner_identity_id')->nullable()->after('carrier_company_id');
                $table->index('owner_identity_id');
            });
        }

        // ── Seat category columns on route_segment_prices ─
        if (! Schema::hasColumn('route_segment_prices', 'price_business')) {
            Schema::table('route_segment_prices', function (Blueprint $table) {
                $table->decimal('price_sleeper_upper', 10, 2)->nullable()->after('price');
                $table->decimal('price_sleeper_lower', 10, 2)->nullable()->after('price_sleeper_upper');
                $table->decimal('price_business', 10, 2)->nullable()->after('price_sleeper_lower');
                $table->decimal('price_folding', 10, 2)->nullable()->after('price_business');
            });
        }
    }

    public function down(): void
    {
        // No destructive rollback — this is a failsafe up-only migration.
    }
};
