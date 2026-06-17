<?php

/**
 * NEXATRACE — LARAVEL REVERB CONFIGURATION
 * =========================================
 *
 * WebSocket server for real-time event broadcasting across
 * the entire NexaTrace ecosystem.
 *
 * KEY CHANNELS:
 *   - bus.{trip_id}       → Live bus GPS tracking (Module 8V, 13C)
 *   - fleet.{company_id}  → Fleet-wide vehicle telemetry (Module 9H, 13C)
 *   - driver.{driver_id}  → Per-driver location (Module 10J, 11G)
 *   - trip.{trip_id}      → Trip status transitions (Module 4T, 9H)
 *   - auction.{load_id}   → Real-time bidding (Module 9D, 10D)
 *   - delivery.{id}       → Proof-of-delivery confirmations (Module 4E)
 *   - store_keeper.{id}   → Geofence scan alerts (Module 5A)
 *
 * SERVER COMMAND:
 *   php artisan reverb:start --debug
 *
 * PRODUCTION (systemd):
 *   See docs for systemd unit file configuration.
 */

return [

    'default' => 'production',

    'servers' => [

        'production' => [
            'host' => env('REVERB_SERVER_HOST', '0.0.0.0'),
            'port' => env('REVERB_SERVER_PORT', 8080),
            'hostname' => env('REVERB_HOST', '127.0.0.1'),
            'options' => [
                'tls' => [],
            ],
            'max_request_size' => 10_000,
            'scaling' => [
                'enabled' => env('REVERB_SCALING_ENABLED', false),
                'channel' => env('REVERB_SCALING_CHANNEL', 'reverb'),
                'server' => [
                    'host' => env('REVERB_SERVER_HOST', '0.0.0.0'),
                    'port' => env('REVERB_SERVER_PORT', 8080),
                ],
            ],
            'pulse_ingest_interval' => env('REVERB_PULSE_INGEST_INTERVAL', 15),
            'telescope_ingest_interval' => env('REVERB_TELESCOPE_INGEST_INTERVAL', 15),
        ],

    ],

    'apps' => [

        'provider' => 'config',

        'apps' => [
            [
                'key' => env('REVERB_APP_KEY'),
                'secret' => env('REVERB_APP_SECRET'),
                'app_id' => env('REVERB_APP_ID'),
                'options' => [
                    'host' => env('REVERB_HOST', '127.0.0.1'),
                    'port' => env('REVERB_PORT', 8080),
                    'scheme' => env('REVERB_SCHEME', 'http'),
                    'encrypted' => true,
                    'useTls' => env('REVERB_SCHEME', 'http') === 'https',
                ],
                'allowed_origins' => ['*'],
                'ping_interval' => env('REVERB_PING_INTERVAL', 10),
                'activity_timeout' => env('REVERB_ACTIVITY_TIMEOUT', 30),
                'max_message_size' => env('REVERB_MAX_MESSAGE_SIZE', 10_000),
            ],
        ],

    ],

];
