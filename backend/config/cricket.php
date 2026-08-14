<?php

/**
 * NEXATRACE — CRICKET STREAMING CONFIGURATION
 * ===========================================
 *
 * All streaming endpoints are env-driven (see .env). When a manager
 * creates a camera stream without explicit URLs, StreamController
 * fills rtmp_ingest_url and hls_playlist_url from this config so the
 * public player always receives a playable HLS URL.
 */

return [

    'streaming' => [

        // RTMP ingest endpoint pushed to by mobile camera apps
        // (Larix / Streamlabs / prism).
        'rtmp_ingest_url' => env('CRICKET_RTMP_INGEST_URL', 'rtmp://cricket.traceodd.com:1935/live'),

        // Base URL where SRS publishes HLS playlists. The stream key and
        // `.m3u8` suffix are appended by StreamController.
        'hls_base_url' => env('CRICKET_HLS_BASE_URL', 'https://cricket.traceodd.com/hls/live'),

    ],

];
