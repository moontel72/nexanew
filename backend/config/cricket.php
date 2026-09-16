<?php

/**
 * NEXATRACE — CRICKET STREAMING CONFIGURATION
 * ===========================================
 *
 * Live video originates on the Todd Broadcaster, which publishes its cameras
 * into the Studio room over WHIP. The engine forwards the on-air camera to
 * SRS, and SRS serves the HLS playlist the public page plays:
 *
 *   broadcaster (WHIP) → engine → RTMP → SRS → HLS → cricket.traceodd.com
 *
 * The values here describe the RTMP and HLS halves of that one path. The SRS
 * stream name is derived from the match id
 * (`cricket_match_{matchId}_cam1`), never stored, so a match always has a
 * predictable playlist URL as long as the broadcaster is on air.
 */

return [

    'streaming' => [

        // RTMP ingest the engine publishes the match feed to. The stream
        // name is appended per match by CricketStreamSyncService.
        //
        // IMPORTANT: This MUST point at the origin server IP, not the
        // public domain — Cloudflare does not proxy RTMP traffic on
        // port 1935. HLS delivery (below) stays on the domain.
        'rtmp_ingest_url' => env('CRICKET_RTMP_INGEST_URL', 'rtmp://135.181.46.27:1935/live'),

        // Base URL where SRS publishes HLS playlists. The stream name and
        // `.m3u8` suffix are appended by CricketStreamSyncService.
        'hls_base_url' => env('CRICKET_HLS_BASE_URL', 'https://cricket.traceodd.com/hls/live'),

        // Bitrate (kbps) used by the engine's →SRS RTMP forwarder.
        'forwarder_bitrate_kbps' => (int) env('CRICKET_FORWARDER_BITRATE_KBPS', 4000),

    ],

    /*
    |--------------------------------------------------------------------------
    | Rust recompute binary (Phase 2)
    |--------------------------------------------------------------------------
    |
    | Path to the `trace_odd_rust` binary used by the scoring engine to
    | cross-check forward recomputations after ball corrections. Set to an
    | empty string to disable the drift check.
    |
    */
    'rust_binary_path' => env('CRICKET_RUST_BINARY', '/opt/nexatrace/trace_odd_rust'),

];
