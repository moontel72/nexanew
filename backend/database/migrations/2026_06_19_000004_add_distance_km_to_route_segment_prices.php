<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('route_segment_prices', 'distance_km')) {
            Schema::table('route_segment_prices', function (Blueprint $table) {
                $table->decimal('distance_km', 8, 2)->nullable()->after('price');
            });
        }
    }

    public function down(): void
    {
        Schema::table('route_segment_prices', function (Blueprint $table) {
            $table->dropColumn('distance_km');
        });
    }
};
