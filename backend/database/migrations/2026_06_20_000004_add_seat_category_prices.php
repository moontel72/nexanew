<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ADD SEAT CATEGORY PRICE COLUMNS TO route_segment_prices
 * =====================================================================
 *
 * Supports fully dynamic pricing per seat type:
 *   - Standard (baseline, existing `price` column)
 *   - Sleeper Upper Berth
 *   - Sleeper Lower Berth
 *   - Business Class
 *   - Folding Seats
 *
 * Each category accepts any user-defined value (no hardcoded caps).
 * The Standard price is the baseline; other categories can be
 * percentages, fixed markups, or absolute prices at admin discretion.
 */

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('route_segment_prices', function (Blueprint $table) {
            $table->decimal('price_sleeper_upper', 10, 2)->nullable()->after('price');
            $table->decimal('price_sleeper_lower', 10, 2)->nullable()->after('price_sleeper_upper');
            $table->decimal('price_business', 10, 2)->nullable()->after('price_sleeper_lower');
            $table->decimal('price_folding', 10, 2)->nullable()->after('price_business');
        });
    }

    public function down(): void
    {
        Schema::table('route_segment_prices', function (Blueprint $table) {
            $table->dropColumn([
                'price_sleeper_upper',
                'price_sleeper_lower',
                'price_business',
                'price_folding',
            ]);
        });
    }
};
