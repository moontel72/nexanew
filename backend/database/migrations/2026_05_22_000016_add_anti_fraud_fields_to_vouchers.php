<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transport_nexatrace_vouchers', function (Blueprint $table) {
            if (! Schema::hasColumn('transport_nexatrace_vouchers', 'consumed_amount')) {
                $table->decimal('consumed_amount', 15, 2)->default(0)->after('amount');
            }
            if (! Schema::hasColumn('transport_nexatrace_vouchers', 'purchase_channel')) {
                $table->string('purchase_channel', 20)->default('cash_voucher')->after('currency');
                // card, cash_voucher
            }
            if (! Schema::hasColumn('transport_nexatrace_vouchers', 'surcharge_amount')) {
                $table->decimal('surcharge_amount', 15, 2)->default(0)->after('purchase_channel');
            }
        });
    }

    public function down(): void
    {
        Schema::table('transport_nexatrace_vouchers', function (Blueprint $table) {
            $table->dropColumn(['consumed_amount', 'purchase_channel', 'surcharge_amount']);
        });
    }
};
