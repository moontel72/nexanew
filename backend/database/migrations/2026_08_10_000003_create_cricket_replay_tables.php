<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── Replay video chunks (5-minute segments) ──────────────────
        Schema::create('cricket_replay_chunks', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('gen_random_uuid()'));
            $table->uuid('match_id');
            $table->foreign('match_id')->references('id')->on('cricket_matches')->onDelete('cascade');
            $table->integer('chunk_counter')->comment('Zero-padded sequential: 000001, 000002...');
            $table->string('file_path', 1024);
            $table->timestamp('start_timestamp')->comment('Chunk start (server time)');
            $table->timestamp('end_timestamp')->comment('Chunk end (server time)');
            $table->integer('duration_seconds');
            $table->bigInteger('file_size_bytes')->nullable();
            $table->boolean('is_complete')->default(false);
            $table->timestamps();

            $table->unique(['match_id', 'chunk_counter']);
            $table->index(['match_id', 'start_timestamp']);
        });

        // ── Marked replay events (wicket, boundary, appeal, review) ──
        Schema::create('cricket_replay_events', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('gen_random_uuid()'));
            $table->uuid('match_id');
            $table->foreign('match_id')->references('id')->on('cricket_matches')->onDelete('cascade');
            $table->uuid('chunk_id')->nullable();
            $table->foreign('chunk_id')->references('id')->on('cricket_replay_chunks')->onDelete('set null');
            $table->string('event_type', 50)->comment('wicket, boundary, appeal, review, custom');
            $table->bigInteger('frame_timestamp')->comment('Milliseconds from match start time');
            $table->text('annotation')->nullable();
            $table->uuid('tagged_by_cricket_manager_id')->nullable();
            $table->foreign('tagged_by_cricket_manager_id', 'rep_ev_mgr_fk')
                ->references('id')->on('cricket_managers')->onDelete('set null');
            $table->boolean('is_published')->default(false);
            $table->timestamps();

            $table->index(['match_id', 'frame_timestamp']);
            $table->index('event_type');
        });

        // ── Trimmed replay clips (with buffer offsets) ───────────────
        Schema::create('cricket_replay_clips', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('gen_random_uuid()'));
            $table->uuid('match_id');
            $table->foreign('match_id')->references('id')->on('cricket_matches')->onDelete('cascade');
            $table->uuid('event_id');
            $table->foreign('event_id')->references('id')->on('cricket_replay_events')->onDelete('cascade');
            $table->string('clip_file_path', 1024);
            $table->integer('buffer_before_ms')->default(5000);
            $table->integer('buffer_after_ms')->default(5000);
            $table->decimal('playback_speed', 3, 2)->default(1.00);
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            $table->index('match_id');
            $table->index('is_published');
        });

        // ── Public replay viewership log ─────────────────────────────
        Schema::create('cricket_replay_public_log', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('gen_random_uuid()'));
            $table->uuid('clip_id');
            $table->foreign('clip_id')->references('id')->on('cricket_replay_clips')->onDelete('cascade');
            $table->integer('viewer_count')->default(0);
            $table->timestamp('first_viewed_at')->nullable();
            $table->timestamp('last_viewed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cricket_replay_public_log');
        Schema::dropIfExists('cricket_replay_clips');
        Schema::dropIfExists('cricket_replay_events');
        Schema::dropIfExists('cricket_replay_chunks');
    }
};
