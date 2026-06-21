<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ADD voucher_id TO transport_bus_routes
 * ====================================================
 *
 * Links active vouchers/promos to specific routes.
 * The universal customer app uses this to apply
 * discounts at checkout for that route.
 */

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('transport_bus_routes', 'voucher_id')) {
            return;
        }

        Schema::table('transport_bus_routes', function (Blueprint $table) {
            $table->uuid('voucher_id')->nullable()->after('pricing_matrix');
            $table->index('voucher_id');
        });
    }

    public function down(): void
    {
        Schema::table('transport_bus_routes', function (Blueprint $table) {
            $table->dropIndex(['voucher_id']);
            $table->dropColumn('voucher_id');
        });
    }
};
