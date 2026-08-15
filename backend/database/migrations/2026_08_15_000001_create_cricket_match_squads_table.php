<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Phase 0 — Match squad / lineup registry for the Cricket module.
 *
 * Stores the playing XI (batting order) and bench selections per team
 * per match. Feeds:
 *   - Pre-match lineup builder (manager panel)
 *   - Live scorer's "next batter" suggestions after a wicket
 *   - Batting-order hints on scorecards (public portal)
 *
 * Isolation: cricket_* table only — no foreign keys to other verticals.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('cricket_match_squads')) {
            Schema::create('cricket_match_squads', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->uuid('team_id');
                $table->uuid('player_id');
                $table->integer('batting_order')->nullable()
                    ->comment('1-11 for the playing XI; null for bench');
                $table->enum('status', ['in_xi', 'on_bench', 'substituted_out'])
                    ->default('in_xi')
                    ->comment('in_xi: selected; on_bench: reserve; substituted_out: replaced during match');
                $table->timestamps();
                $table->softDeletes();

                $table->index(['match_id', 'team_id']);
            });

            DB::statement("ALTER TABLE cricket_match_squads ALTER COLUMN id SET DEFAULT gen_random_uuid()");

            // A player can only appear once per match (ignoring soft-deleted rows).
            DB::statement("CREATE UNIQUE INDEX cricket_match_squads_player_unique
                ON cricket_match_squads (match_id, player_id)
                WHERE deleted_at IS NULL");

            // Batting order is unique within a team's XI for a match.
            DB::statement("CREATE UNIQUE INDEX cricket_match_squads_order_unique
                ON cricket_match_squads (match_id, team_id, batting_order)
                WHERE deleted_at IS NULL AND batting_order IS NOT NULL");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('cricket_match_squads');
    }
};
