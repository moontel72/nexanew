<?php

/**
 * NEXATRACE — LARAVEL REVERB CONFIGURATION
 * =========================================
 *
 * WebSocket server for real-time event broadcasting across
 * the entire NexaTrace ecosystem.
 *
 * SERVER COMMAND:
 *   php artisan reverb:start --debug
 */

return [

    /*
    |--------------------------------------------------------------------------
    | Reverb Application Credentials
    |--------------------------------------------------------------------------
    */

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

    /*
    |--------------------------------------------------------------------------
    | Server Options (passed to artisan reverb:start)
    |--------------------------------------------------------------------------
    */

    'options' => [
        'host' => env('REVERB_SERVER_HOST', '0.0.0.0'),
        'port' => env('REVERB_SERVER_PORT', 8080),
        'hostname' => env('REVERB_HOST', '127.0.0.1'),
    ],

];
