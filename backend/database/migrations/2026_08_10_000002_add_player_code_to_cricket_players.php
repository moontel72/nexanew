<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cricket_players', function (Blueprint $table) {
            $table->string('player_code', 3)->nullable()->unique()->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('cricket_players', function (Blueprint $table) {
            $table->dropColumn('player_code');
        });
    }
};
