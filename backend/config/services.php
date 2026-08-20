<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'deepseek' => [
        'api_key' => env('DEEPSEEK_API_KEY'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Media Engine (Rust) — Todd Studio / Broadcaster
    |--------------------------------------------------------------------------
    |
    | Shared HS256 JWT settings. The secret MUST match the Rust media
    | engine's MEDIA_ENGINE_JWT_SECRET so tokens minted by
    | MediaEngineTokenService verify locally in the engine.
    |
    */

    'media_engine' => [
        'url' => env('MEDIA_ENGINE_URL', 'http://127.0.0.1:8080'),
        'secret' => env('MEDIA_ENGINE_JWT_SECRET', ''),
        'issuer' => env('MEDIA_ENGINE_JWT_ISSUER', 'traceodd'),
    ],

];
