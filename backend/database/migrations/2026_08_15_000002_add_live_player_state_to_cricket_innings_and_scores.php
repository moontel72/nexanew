<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Phase 0 — Live player state columns.
 *
 * cricket_innings: who is currently on strike, at the non-striker's end,
 * and who is bowling. Persisted so the scoring engine can resume the
 * match state after reconnects / restarts and undo operations.
 *
 * cricket_live_scores: player ID columns to complement the existing
 * name/stat columns — enables player-linking in the public portal.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cricket_innings', function (Blueprint $table) {
            if (!Schema::hasColumn('cricket_innings', 'current_striker_id')) {
                $table->uuid('current_striker_id')->nullable()->after('status')
                    ->comment('Batter on strike for the next delivery');
            }
            if (!Schema::hasColumn('cricket_innings', 'current_non_striker_id')) {
                $table->uuid('current_non_striker_id')->nullable()->after('current_striker_id')
                    ->comment('Batter at the non-striker end');
            }
            if (!Schema::hasColumn('cricket_innings', 'current_bowler_id')) {
                $table->uuid('current_bowler_id')->nullable()->after('current_non_striker_id')
                    ->comment('Bowler for the current over');
            }
        });

        Schema::table('cricket_live_scores', function (Blueprint $table) {
            if (!Schema::hasColumn('cricket_live_scores', 'striker_id')) {
                $table->uuid('striker_id')->nullable()->after('striker_name');
            }
            if (!Schema::hasColumn('cricket_live_scores', 'non_striker_id')) {
                $table->uuid('non_striker_id')->nullable()->after('striker_id');
            }
            if (!Schema::hasColumn('cricket_live_scores', 'bowler_id')) {
                $table->uuid('bowler_id')->nullable()->after('bowler_name');
            }
        });
    }

    public function down(): void
    {
        Schema::table('cricket_innings', function (Blueprint $table) {
            $table->dropColumn([
                'current_striker_id',
                'current_non_striker_id',
                'current_bowler_id',
            ]);
        });

        Schema::table('cricket_live_scores', function (Blueprint $table) {
            $table->dropColumn(['striker_id', 'non_striker_id', 'bowler_id']);
        });
    }
};
