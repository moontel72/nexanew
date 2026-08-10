<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * NEXATRACE — CRICKET MODULE V2: TOURNAMENT HUB + ANALYTICS + CAREER
     *
     * Adds:
     *   16. cricket_clubs            — Club / Academy profiles
     *   17. cricket_points_table     — Materialized tournament standings
     *   18. cricket_player_career_stats — Aggregated career stats per player
     *   19. cricket_best_xi          — Best XI selections with field overlay
     *
     * All tables prefixed `cricket_*`. Zero FK references to non-cricket tables.
     * This migration is purely additive — no existing tables are altered.
     */
    public function up(): void
    {
        // ═══════════════════════════════════════════════════════════
        // 16. CRICKET CLUBS / ACADEMIES
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_clubs')) {
            Schema::create('cricket_clubs', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name', 200);
                $table->string('slug', 200)->unique();
                $table->string('logo_url', 500)->nullable();
                $table->string('banner_url', 500)->nullable();
                $table->string('location', 200)->nullable();
                $table->integer('established_year')->nullable();
                $table->text('description')->nullable();
                $table->string('contact_email', 200)->nullable();
                $table->string('website_url', 500)->nullable();
                $table->integer('follower_count')->default(0);
                $table->integer('club_views')->default(0);
                $table->integer('total_matches_hosted')->default(0);
                $table->integer('total_tournaments_hosted')->default(0);
                $table->uuid('created_by_manager_id')->nullable()
                    ->comment('Cricket Manager who created this club profile');
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_clubs ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 17. CRICKET POINTS TABLE (Materialized standings)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_points_table')) {
            Schema::create('cricket_points_table', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id');
                $table->uuid('team_id');
                $table->integer('matches_played')->default(0);
                $table->integer('won')->default(0);
                $table->integer('lost')->default(0);
                $table->integer('tied')->default(0);
                $table->integer('no_result')->default(0);
                $table->integer('points')->default(0);
                $table->decimal('net_run_rate', 8, 3)->default(0.000);
                $table->integer('runs_for')->default(0);
                $table->decimal('overs_faced', 6, 1)->default(0.0);
                $table->integer('runs_against')->default(0);
                $table->decimal('overs_bowled', 6, 1)->default(0.0);
                $table->unsignedInteger('rank_position')->nullable()
                    ->comment('Computed rank 1-N within tournament');
                $table->timestamps();

                $table->unique(['tournament_id', 'team_id']);
            });
            DB::statement("ALTER TABLE cricket_points_table ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 18. CRICKET PLAYER CAREER STATS (Aggregated across matches)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_player_career_stats')) {
            Schema::create('cricket_player_career_stats', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('player_id')->unique()
                    ->comment('FK to cricket_players.id');
                $table->uuid('club_id')->nullable()
                    ->comment('FK to cricket_clubs.id (club affiliation)');

                // ── Batting Stats ──
                $table->integer('total_matches')->default(0);
                $table->integer('total_innings')->default(0);
                $table->integer('total_runs')->default(0);
                $table->integer('not_outs')->default(0);
                $table->integer('highest_score')->default(0);
                $table->boolean('highest_score_not_out')->default(false);
                $table->decimal('batting_average', 7, 2)->default(0.00);
                $table->integer('balls_faced')->default(0);
                $table->decimal('batting_strike_rate', 6, 2)->default(0.00);
                $table->integer('centuries')->default(0);
                $table->integer('half_centuries')->default(0);
                $table->integer('fours')->default(0);
                $table->integer('sixes')->default(0);

                // ── Bowling Stats ──
                $table->integer('total_wickets')->default(0);
                $table->decimal('bowling_average', 7, 2)->default(0.00);
                $table->string('best_bowling_figures', 10)->nullable()
                    ->comment('e.g. "5/23"');
                $table->decimal('economy_rate', 6, 2)->default(0.00);
                $table->integer('maidens')->default(0);
                $table->decimal('overs_bowled_career', 6, 1)->default(0.0);
                $table->integer('five_wicket_hauls')->default(0);
                $table->integer('runs_conceded')->default(0);

                // ── Fielding Stats ──
                $table->integer('catches')->default(0);
                $table->integer('run_outs')->default(0);
                $table->integer('stumpings')->default(0);

                // ── Recent Form ──
                $table->jsonb('recent_scores')->nullable()
                    ->comment('Last 5 innings: [{runs, balls, not_out, match_id, date}]');

                $table->timestamps();
            });
            DB::statement("ALTER TABLE cricket_player_career_stats ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 19. CRICKET BEST XI SELECTIONS
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_best_xi')) {
            Schema::create('cricket_best_xi', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id')->nullable();
                $table->uuid('match_id')->nullable()
                    ->comment('If match-specific XI, otherwise tournament-wide');
                $table->string('team_label', 100)
                    ->comment('"Team of the Tournament", "Match Day XI", "Super Stars"');
                $table->jsonb('selections')->nullable()
                    ->comment('Array of {player_id, position_name, x, y, rating, role}');
                $table->uuid('curated_by_identity_id')->nullable()
                    ->comment('Super/Sub Admin who curated this XI');
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_best_xi ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // INDEXES for analytics queries
        // ═══════════════════════════════════════════════════════════
        if (Schema::hasTable('cricket_points_table')) {
            Schema::table('cricket_points_table', function (Blueprint $table) {
                if (!$this->hasIndex('cricket_points_table', 'cricket_pts_tournament_idx')) {
                    $table->index('tournament_id', 'cricket_pts_tournament_idx');
                }
                if (!$this->hasIndex('cricket_points_table', 'cricket_pts_rank_idx')) {
                    $table->index('rank_position', 'cricket_pts_rank_idx');
                }
            });
        }

        if (Schema::hasTable('cricket_player_career_stats')) {
            Schema::table('cricket_player_career_stats', function (Blueprint $table) {
                if (!$this->hasIndex('cricket_player_career_stats', 'cricket_career_club_idx')) {
                    $table->index('club_id', 'cricket_career_club_idx');
                }
            });
        }
    }

    /**
     * Reverse the migration — drop all v2 tables.
     */
    public function down(): void
    {
        Schema::dropIfExists('cricket_best_xi');
        Schema::dropIfExists('cricket_player_career_stats');
        Schema::dropIfExists('cricket_points_table');
        Schema::dropIfExists('cricket_clubs');
    }

    /**
     * Check if an index exists on a table (portable helper).
     */
    private function hasIndex(string $table, string $indexName): bool
    {
        try {
            $indexes = DB::select(
                "SELECT indexname FROM pg_indexes WHERE tablename = ? AND indexname = ?",
                [$table, $indexName]
            );
            return !empty($indexes);
        } catch (\Throwable) {
            return false;
        }
    }
};
