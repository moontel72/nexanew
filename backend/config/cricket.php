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

        // ── WHEP (WebRTC) viewing ──────────────────────────────────────────
        //
        // The public page prefers WHEP and falls back to HLS. WebRTC has no
        // segments and no playlist, so the same camera plays sub-second rather
        // than 10-20s behind, and it cannot be starved by a slow segment —
        // which is exactly what makes the HLS player stall (SRS only cuts a
        // segment on a source keyframe). The browser reaches the engine
        // through this site's nginx proxy so the SDP POST stays same-origin.
        'whep_base_path' => env('CRICKET_WHEP_BASE_PATH', '/whep'),

        // Viewer-token lifetime. The page and the feed are public; the token
        // only scopes the watch to one room and one camera, and a page left
        // open for a whole match must not die, so it is long-lived on purpose.
        'whep_token_ttl_seconds' => (int) env('CRICKET_WHEP_TOKEN_TTL', 21600),

        // ICE servers handed to the viewer's browser. STUN alone is usually
        // enough. TURN relays media when the venue blocks UDP, but the address
        // the engine uses is internal (172.17.0.1 — the docker bridge), which a
        // browser cannot reach, so the public one has to be supplied here. The
        // credentials are the coturn ones from
        // media-engine/deploy/coturn/turnserver.conf, which are already
        // committed in this repository; override with env to rotate them.
        'stun_url' => env('CRICKET_STUN_URL', 'stun:135.181.46.27:3478'),
        'turn_url' => env('CRICKET_TURN_URL', 'turn:135.181.46.27:3478'),
        'turn_username' => env('CRICKET_TURN_USERNAME', 'traceodd'),
        'turn_password' => env('CRICKET_TURN_PASSWORD', 'traceodd-turn-2026'),

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
