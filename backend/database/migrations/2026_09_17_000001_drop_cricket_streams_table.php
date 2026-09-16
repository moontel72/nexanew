<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Drops `cricket_streams` — the Cricket Manager's camera registry.
 *
 * Video does not originate from the Cricket Manager. The Todd Broadcaster
 * publishes every camera into the Studio room over WHIP, the engine forwards
 * the on-air camera to SRS, and SRS serves the HLS playlist the public page
 * plays. The manager's own stream rows played no part in that path once
 * `syncStudioCamera` was removed, but they still caused two concrete problems:
 *
 *   1. The engine→SRS forwarder was created *from* a stream row, so with no
 *      rows the public page had no playlist at all — a permanent 404.
 *   2. An empty registry made the Camera Switcher look like the place to
 *      "add a camera", which registered a second, video-less camera into the
 *      Studio room and split the player into two panes.
 *
 * Removing the table removes both, and makes "video comes from the
 * broadcaster" structural rather than a convention someone can violate.
 *
 * `down()` restores the schema shape only; the rows are gone. This is
 * intentional — the table held per-camera RTMP keys that are meaningless
 * once nothing publishes to them.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::dropIfExists('cricket_streams');
    }

    public function down(): void
    {
        if (Schema::hasTable('cricket_streams')) {
            return;
        }

        Schema::create('cricket_streams', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('match_id');
            $table->string('camera_label', 100);
            $table->integer('camera_number');
            $table->string('rtmp_ingest_url', 500)->nullable();
            $table->string('rtmp_stream_key', 100)->nullable();
            $table->string('hls_playlist_url', 500)->nullable();
            $table->enum('stream_status', [
                'offline', 'connecting', 'live', 'error', 'standby',
            ])->default('offline');
            $table->boolean('is_primary')->default(false);
            $table->integer('failover_priority')->default(0);
            $table->uuid('last_activated_by_manager_id')->nullable();
            $table->timestamp('last_live_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }
};
