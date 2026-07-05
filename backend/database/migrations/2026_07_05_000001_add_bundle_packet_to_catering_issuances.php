<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('catering_issuances', 'bundle_id')) {
            Schema::table('catering_issuances', function (Blueprint $table) {
                $table->uuid('bundle_id')->nullable()->after('conductor_name');
                $table->uuid('packet_id')->nullable()->after('bundle_id');
                $table->index('bundle_id');
                $table->index('packet_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('catering_issuances', function (Blueprint $table) {
            $table->dropIndex(['bundle_id']);
            $table->dropIndex(['packet_id']);
            $table->dropColumn(['bundle_id', 'packet_id']);
        });
    }
};
