<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * NEXATRACE — CRICKET MODULE: COMPLETE SCHEMA
     *
     * Isolated cricket tournament management system with:
     *   - Dynamic multi-account Cricket Manager provisioning
     *   - Multi-camera stream ingest (3-5 RTMP sources per match)
     *   - Voice-to-score AI integration (DeepSeek V4 Pro)
     *   - Sponsor banner & ad management
     *   - Multi-manager HA/failover per match
     *
     * ROLE HIERARCHY:
     *   Super Admin → Sub-Admin → Cricket Manager(s) → Field Camera Crew
     *
     * ZERO SIDE-EFFECTS: All tables prefixed `cricket_*`. No FK references
     * to existing tables that would cause constraint violations on existing data.
     */
    public function up(): void
    {
        // ═══════════════════════════════════════════════════════════
        // 1. CRICKET TOURNAMENTS
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_tournaments')) {
            Schema::create('cricket_tournaments', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name', 200);
                $table->string('slug', 200)->unique();
                $table->string('location', 200)->nullable();
                $table->date('start_date');
                $table->date('end_date');
                $table->text('description')->nullable();
                $table->string('logo_url', 500)->nullable();
                $table->enum('status', ['upcoming', 'active', 'completed', 'cancelled'])
                    ->default('upcoming');
                $table->boolean('is_active')->default(true); // sleep mode toggle
                $table->uuid('created_by_global_identity_id')->nullable()
                    ->comment('Super/Sub Admin who created this tournament');
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_tournaments ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 2. CRICKET MANAGERS (Multi-Account, provisioned by Sub-Admin)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_managers')) {
            Schema::create('cricket_managers', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name', 200);
                $table->string('email', 200)->unique();
                $table->string('password');
                $table->string('phone', 50)->nullable();
                $table->string('auth_token', 128)->nullable()->unique()
                    ->comment('Hashed bearer token for API auth');
                $table->timestamp('token_expires_at')->nullable();
                $table->enum('status', ['active', 'suspended', 'inactive'])
                    ->default('active');
                $table->jsonb('permissions')->nullable()
                    ->comment('Granular permissions: {can_manage_scores, can_manage_streams, can_manage_sponsors}');
                $table->uuid('provisioned_by_global_identity_id')->nullable()
                    ->comment('Sub-Admin who created this manager');
                $table->timestamp('last_login_at')->nullable();
                $table->string('last_login_ip', 45)->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_managers ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 3. CRICKET TEAMS
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_teams')) {
            Schema::create('cricket_teams', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id');
                $table->string('name', 200);
                $table->string('short_code', 10);
                $table->string('logo_url', 500)->nullable();
                $table->string('captain_name', 200)->nullable();
                $table->string('home_city', 200)->nullable();
                $table->string('primary_color', 7)->nullable()->comment('Hex color code');
                $table->timestamps();
                $table->softDeletes();

                $table->unique(['tournament_id', 'short_code']);
            });
            DB::statement("ALTER TABLE cricket_teams ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 4. CRICKET PLAYERS
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_players')) {
            Schema::create('cricket_players', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('team_id');
                $table->string('name', 200);
                $table->string('jersey_number', 5)->nullable();
                $table->enum('role', ['batsman', 'bowler', 'all_rounder', 'wicket_keeper'])
                    ->default('batsman');
                $table->string('batting_style', 50)->nullable()->comment('Right-hand, Left-hand');
                $table->string('bowling_style', 100)->nullable()
                    ->comment('Right-arm fast, Left-arm spin, etc.');
                $table->string('photo_url', 500)->nullable();
                $table->boolean('is_captain')->default(false);
                $table->boolean('is_wicket_keeper')->default(false);
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_players ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 5. CRICKET MATCH OFFICIALS (Umpires, Referees, Scorers)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_match_officials')) {
            Schema::create('cricket_match_officials', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id');
                $table->string('name', 200);
                $table->enum('role', ['umpire', 'third_umpire', 'referee', 'scorer'])
                    ->default('umpire');
                $table->string('photo_url', 500)->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_match_officials ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 6. CRICKET MATCHES
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_matches')) {
            Schema::create('cricket_matches', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id');
                $table->uuid('team_a_id');
                $table->uuid('team_b_id');
                $table->string('venue', 300)->nullable();
                $table->timestamp('scheduled_at')->nullable();
                $table->enum('match_type', ['t20', 'odi', 'test', 't10', 'other'])
                    ->default('t20');
                $table->integer('overs_per_side')->default(20);
                $table->enum('status', [
                    'scheduled', 'toss_pending', 'toss_done',
                    'in_progress', 'innings_break', 'completed',
                    'abandoned', 'cancelled'
                ])->default('scheduled');
                $table->string('toss_winner_team_id', 36)->nullable();
                $table->enum('toss_decision', ['bat', 'bowl'])->nullable();
                $table->uuid('current_batting_team_id')->nullable();
                $table->uuid('current_bowling_team_id')->nullable();
                $table->integer('current_innings_number')->nullable()->default(1);
                $table->jsonb('match_result')->nullable()
                    ->comment('{winner_team_id, win_margin, win_type, player_of_match_id}');
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_matches ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 7. CRICKET MATCH MANAGERS (HA / Multi-Account Failover)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_match_managers')) {
            Schema::create('cricket_match_managers', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->uuid('cricket_manager_id');
                $table->enum('role', ['primary', 'backup', 'observer'])->default('primary');
                $table->boolean('is_active_session')->default(false)
                    ->comment('Currently has an active management session');
                $table->timestamp('last_heartbeat_at')->nullable();
                $table->timestamps();

                $table->unique(['match_id', 'cricket_manager_id']);
            });
            DB::statement("ALTER TABLE cricket_match_managers ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 8. CRICKET INNINGS (JSONB deliveries for performance)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_innings')) {
            Schema::create('cricket_innings', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->integer('innings_number');
                $table->uuid('batting_team_id');
                $table->uuid('bowling_team_id');
                $table->integer('total_runs')->default(0);
                $table->integer('total_wickets')->default(0);
                $table->float('total_overs', 8, 1)->default(0.0);
                $table->integer('total_balls')->default(0);
                $table->integer('extras_wides')->default(0);
                $table->integer('extras_no_balls')->default(0);
                $table->integer('extras_byes')->default(0);
                $table->integer('extras_leg_byes')->default(0);
                $table->integer('extras_penalty')->default(0);
                $table->jsonb('deliveries')->nullable()
                    ->comment('Array of ball objects: [{ball_number, over_number, bowler_id, batsman_id, runs, extras_type, wicket_type, dismissed_player_id, fielder_id, timestamp}]');
                $table->jsonb('batting_scorecard')->nullable()
                    ->comment('Per-batsman aggregates computed as materialized view cache');
                $table->jsonb('bowling_scorecard')->nullable()
                    ->comment('Per-bowler aggregates computed as materialized view cache');
                $table->enum('status', ['yet_to_bat', 'in_progress', 'completed', 'declared'])
                    ->default('yet_to_bat');
                $table->jsonb('fall_of_wickets')->nullable()
                    ->comment('[{wicket_number, runs, overs, player_out_id}]');
                $table->timestamps();

                $table->unique(['match_id', 'innings_number']);
            });
            DB::statement("ALTER TABLE cricket_innings ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 9. CRICKET LIVE SCORES (Denormalized snapshot for Redis cache)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_live_scores')) {
            Schema::create('cricket_live_scores', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id')->unique();
                $table->uuid('current_innings_id')->nullable();
                $table->string('batting_team_name', 200)->nullable();
                $table->string('bowling_team_name', 200)->nullable();
                $table->integer('runs')->default(0);
                $table->integer('wickets')->default(0);
                $table->float('overs', 8, 1)->default(0.0);
                $table->integer('target')->nullable();
                $table->float('current_run_rate', 6, 2)->nullable();
                $table->float('required_run_rate', 6, 2)->nullable();
                $table->string('striker_name', 200)->nullable();
                $table->integer('striker_runs')->nullable();
                $table->integer('striker_balls')->nullable();
                $table->string('non_striker_name', 200)->nullable();
                $table->integer('non_striker_runs')->nullable();
                $table->integer('non_striker_balls')->nullable();
                $table->string('bowler_name', 200)->nullable();
                $table->float('bowler_overs', 6, 1)->nullable();
                $table->integer('bowler_runs_conceded')->nullable();
                $table->integer('bowler_wickets')->nullable();
                $table->string('last_ball_result', 20)->nullable();
                $table->string('last_wicket_info', 300)->nullable();
                $table->integer('partnership_runs')->nullable();
                $table->integer('partnership_balls')->nullable();
                $table->string('recent_overs_summary', 500)->nullable()
                    ->comment('Compact last-30-balls representation');
                $table->jsonb('full_snapshot')->nullable()
                    ->comment('Complete score state for Redis pub/sub payload');
                $table->uuid('updated_by_cricket_manager_id')->nullable();
                $table->timestamps();
            });
            DB::statement("ALTER TABLE cricket_live_scores ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 10. CRICKET COMMENTARY
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_commentary')) {
            Schema::create('cricket_commentary', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->integer('ball_number');
                $table->float('over_number', 5, 1);
                $table->text('commentary_text');
                $table->enum('event_type', [
                    'ball', 'wicket', 'boundary_four', 'boundary_six',
                    'wide', 'no_ball', 'bye', 'leg_bye', 'over_break',
                    'innings_break', 'match_event', 'voice_input'
                ])->default('ball');
                $table->uuid('cricket_manager_id')->nullable()
                    ->comment('Who recorded this commentary');
                $table->timestamps();

                $table->index(['match_id', 'ball_number']);
            });
            DB::statement("ALTER TABLE cricket_commentary ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 11. CRICKET STREAMS (Multi-Camera RTMP/HLS endpoints)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_streams')) {
            Schema::create('cricket_streams', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->string('camera_label', 100)->comment('Main, Square Leg, Mid-Wicket, etc.');
                $table->integer('camera_number')->comment('1-5 for multi-camera setup');
                $table->string('rtmp_ingest_url', 500)->nullable()
                    ->comment('RTMP ingest endpoint for OBS/encoder');
                $table->string('rtmp_stream_key', 100)->nullable()
                    ->comment('Unique stream key per camera');
                $table->string('hls_playlist_url', 500)->nullable()
                    ->comment('CDN HLS master playlist URL');
                $table->enum('stream_status', [
                    'offline', 'connecting', 'live', 'error', 'standby'
                ])->default('offline');
                $table->boolean('is_primary')->default(false)
                    ->comment('Primary camera for auto-switched output');
                $table->integer('failover_priority')->default(0)
                    ->comment('0=primary, higher numbers for fallback order');
                $table->uuid('last_activated_by_manager_id')->nullable();
                $table->timestamp('last_live_at')->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_streams ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 12. CRICKET SPONSORS
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_sponsors')) {
            Schema::create('cricket_sponsors', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id');
                $table->string('name', 200);
                $table->string('logo_url', 500)->nullable();
                $table->string('banner_image_url', 500)->nullable();
                $table->string('website_url', 500)->nullable();
                $table->enum('tier', ['title', 'gold', 'silver', 'bronze', 'partner'])
                    ->default('silver');
                $table->boolean('is_active')->default(true);
                $table->integer('display_order')->default(0);
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_sponsors ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 13. CRICKET MATCH SPONSORS (Per-match allocation, max 10)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_match_sponsors')) {
            Schema::create('cricket_match_sponsors', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->uuid('sponsor_id');
                $table->enum('placement', [
                    'scoreboard_top', 'scoreboard_bottom', 'stream_overlay',
                    'mid_over_bumper', 'fall_of_wicket'
                ])->default('scoreboard_top');
                $table->boolean('is_active')->default(true);
                $table->integer('display_order')->default(0);
                $table->timestamps();

                $table->unique(['match_id', 'sponsor_id', 'placement']);
            });
            DB::statement("ALTER TABLE cricket_match_sponsors ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 14. CRICKET VOICE SCORE LOGS (DeepSeek V4 Pro Integration)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_voice_score_logs')) {
            Schema::create('cricket_voice_score_logs', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('match_id');
                $table->uuid('cricket_manager_id');
                $table->text('raw_transcript')->nullable()
                    ->comment('Raw voice-to-text output');
                $table->jsonb('parsed_score_data')->nullable()
                    ->comment('AI-parsed structured score: {runs, is_wicket, extras, ...}');
                $table->boolean('was_applied')->default(false)
                    ->comment('Whether this voice input was applied to the score');
                $table->text('ai_response')->nullable()
                    ->comment('Full DeepSeek API response for audit');
                $table->integer('processing_time_ms')->nullable()
                    ->comment('API latency in milliseconds');
                $table->enum('status', ['processing', 'parsed', 'applied', 'rejected', 'error'])
                    ->default('processing');
                $table->text('error_message')->nullable();
                $table->timestamps();

                $table->index(['match_id', 'created_at']);
            });
            DB::statement("ALTER TABLE cricket_voice_score_logs ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ═══════════════════════════════════════════════════════════
        // 15. CRICKET MANAGER SESSION LOGS (Audit trail)
        // ═══════════════════════════════════════════════════════════
        if (!Schema::hasTable('cricket_manager_session_logs')) {
            Schema::create('cricket_manager_session_logs', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('cricket_manager_id');
                $table->uuid('match_id')->nullable();
                $table->enum('action', [
                    'login', 'logout', 'take_over_match', 'release_match',
                    'update_score', 'update_stream', 'update_sponsor',
                    'voice_score_input', 'session_timeout'
                ]);
                $table->jsonb('metadata')->nullable();
                $table->string('ip_address', 45)->nullable();
                $table->text('user_agent')->nullable();
                $table->timestamps();

                $table->index(['cricket_manager_id', 'created_at']);
                $table->index(['match_id', 'action']);
            });
            DB::statement("ALTER TABLE cricket_manager_session_logs ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('cricket_manager_session_logs');
        Schema::dropIfExists('cricket_voice_score_logs');
        Schema::dropIfExists('cricket_match_sponsors');
        Schema::dropIfExists('cricket_sponsors');
        Schema::dropIfExists('cricket_streams');
        Schema::dropIfExists('cricket_commentary');
        Schema::dropIfExists('cricket_live_scores');
        Schema::dropIfExists('cricket_match_managers');
        Schema::dropIfExists('cricket_matches');
        Schema::dropIfExists('cricket_match_officials');
        Schema::dropIfExists('cricket_players');
        Schema::dropIfExists('cricket_teams');
        Schema::dropIfExists('cricket_managers');
        Schema::dropIfExists('cricket_tournaments');
    }
};
