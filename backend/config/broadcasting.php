<?php

/**
 * NEXATRACE — BROADCASTING CONFIGURATION
 * =======================================
 *
 * SAFETY: Default driver is 'log' — events are logged but never crash.
 * When Redis + Reverb/Soketi are deployed, switch to 'redis' driver.
 * This config is entirely NEW — no existing file modified.
 */

return [

    'default' => env('BROADCAST_DRIVER', 'log'),

    'connections' => [

        'log' => [
            'driver' => 'log',
        ],

        'redis' => [
            'driver' => 'redis',
            'connection' => env('BROADCAST_REDIS_CONNECTION', 'default'),
        ],

        'reverb' => [
            'driver' => 'reverb',
            'key' => env('REVERB_APP_KEY'),
            'secret' => env('REVERB_APP_SECRET'),
            'app_id' => env('REVERB_APP_ID'),
            'options' => [
                'host' => env('REVERB_HOST', '127.0.0.1'),
                'port' => env('REVERB_PORT', 8080),
                'scheme' => env('REVERB_SCHEME', 'http'),
                'useTLS' => env('REVERB_SCHEME', 'http') === 'https',
            ],
        ],

    ],

];
