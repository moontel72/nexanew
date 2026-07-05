<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add wasted/staff/complimentary columns to issuance items
        if (!Schema::hasColumn('catering_issuance_items', 'quantity_wasted')) {
            Schema::table('catering_issuance_items', function (Blueprint $table) {
                $table->unsignedInteger('quantity_wasted')->default(0)->after('quantity_sold');
                $table->unsignedInteger('quantity_staff')->default(0)->after('quantity_wasted');
                $table->unsignedInteger('quantity_complimentary')->default(0)->after('quantity_staff');
            });
        }

        // Add corresponding total-value columns to reconciliations table
        if (!Schema::hasColumn('catering_reconciliations', 'total_wasted_value_paisa')) {
            Schema::table('catering_reconciliations', function (Blueprint $table) {
                $table->unsignedInteger('total_wasted_value_paisa')->default(0)->after('total_sold_value_paisa');
                $table->unsignedInteger('total_staff_value_paisa')->default(0)->after('total_wasted_value_paisa');
                $table->unsignedInteger('total_complimentary_value_paisa')->default(0)->after('total_staff_value_paisa');
            });
        }
    }

    public function down(): void
    {
        Schema::table('catering_issuance_items', function (Blueprint $table) {
            $table->dropColumn(['quantity_wasted', 'quantity_staff', 'quantity_complimentary']);
        });
        Schema::table('catering_reconciliations', function (Blueprint $table) {
            $table->dropColumn(['total_wasted_value_paisa', 'total_staff_value_paisa', 'total_complimentary_value_paisa']);
        });
    }
};
