<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cricket_teams', function (Blueprint $table) {
            $table->string('team_code', 3)->nullable()->unique()->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('cricket_teams', function (Blueprint $table) {
            $table->dropColumn('team_code');
        });
    }
};
