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

        // SRS HTTP API, used to confirm that a forwarder is *actually*
        // publishing. The engine reports `running` as soon as it has built a
        // pipeline, so a forwarder whose publisher went away can keep claiming
        // to be healthy while SRS receives nothing — and because every recovery
        // path (the stream watchdog, the manager panel's "Reconnect" button and
        // the engine's own watchdogs) skips a forwarder that claims to be
        // running, that stale state blocks self-healing indefinitely and the
        // public page 404s with nothing in the logs. Health is therefore
        // confirmed at the far end. Set to an empty string to fall back to the
        // engine's own state.
        'srs_api_url' => env('CRICKET_SRS_API_URL', 'http://127.0.0.1:1985'),

        // SRS HLS output directory, used to confirm the playlist is still
        // *advancing*. A publish can stay `active` while the media stops — the
        // RTMP connection is up, nothing reaches flvmux, SRS has nothing left to
        // segment and deletes the playlist — so `publish.active` alone reports a
        // dead feed as healthy. Only meaningful when the app runs on the SRS
        // host; set to an empty string to skip the check.
        'hls_dir' => env('CRICKET_HLS_DIR', '/var/www/traceodd/cricket-hls'),

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
