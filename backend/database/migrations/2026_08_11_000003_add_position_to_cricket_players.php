<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('cricket_players', 'position')) {
            Schema::table('cricket_players', function (Blueprint $table) {
                $table->enum('position', ['player', 'captain', 'vice_captain', 'coach', 'manager', 'extra'])
                    ->default('player')
                    ->after('role');
            });
        }
    }

    public function down(): void
    {
        Schema::table('cricket_players', function (Blueprint $table) {
            $table->dropColumn('position');
        });
    }
};
