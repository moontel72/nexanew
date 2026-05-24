<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            if (! Schema::hasColumn('drivers', 'driver_type')) {
                $table->string('driver_type', 20)->default('factory')->after('status');
                // factory, truck, bus
            }
            if (! Schema::hasColumn('drivers', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('driver_type');
            }
        });
    }

    public function down(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            $table->dropColumn(['driver_type', 'is_active']);
        });
    }
};
