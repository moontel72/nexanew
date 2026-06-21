<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('transport_bus_routes', 'driver_bonus_id')) {
            Schema::table('transport_bus_routes', function (Blueprint $table) {
                $table->uuid('driver_bonus_id')->nullable()->after('voucher_id');
                $table->uuid('conductor_bonus_id')->nullable()->after('driver_bonus_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('transport_bus_routes', function (Blueprint $table) {
            $table->dropColumn(['driver_bonus_id', 'conductor_bonus_id']);
        });
    }
};
