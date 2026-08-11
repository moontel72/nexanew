<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add status to cricket_teams
        if (!Schema::hasColumn('cricket_teams', 'status')) {
            Schema::table('cricket_teams', function (Blueprint $table) {
                $table->enum('status', ['active', 'inactive', 'suspended'])
                    ->default('active')
                    ->after('details');
            });
        }

        // Add status to cricket_players
        if (!Schema::hasColumn('cricket_players', 'status')) {
            Schema::table('cricket_players', function (Blueprint $table) {
                $table->enum('status', ['active', 'inactive', 'suspended'])
                    ->default('active')
                    ->after('is_wicket_keeper');
            });
        }
    }

    public function down(): void
    {
        Schema::table('cricket_teams', function (Blueprint $table) {
            $table->dropColumn('status');
        });
        Schema::table('cricket_players', function (Blueprint $table) {
            $table->dropColumn('status');
        });
    }
};
