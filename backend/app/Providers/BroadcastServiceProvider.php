<?php

namespace App\Providers;

use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\ServiceProvider;

/**
 * NEXATRACE — BROADCAST SERVICE PROVIDER
 * =======================================
 *
 * Registers WebSocket broadcasting routes (channels.php)
 * and bootstraps the broadcast facade for the entire
 * NexaTrace real-time event ecosystem.
 *
 * REGISTERED IN: bootstrap/providers.php
 * ROUTES LOADED: routes/channels.php
 *
 * TARGET MODULES:
 *   - 8V  (Customer App — Bus Transit Terminal)
 *   - 13C (Bus Admin — Live Multi-Asset Telemetry)
 *   - 14D (Bus Owner — Real-Time Coach Diagnostics)
 *   - 15B (Bus Driver — High-Frequency Spatial Telemetry)
 *   - 9H  (Goods Company Fleet Telemetry)
 *   - 10J (Truck Owner GPS Tracking)
 *   - 11G (Truck Driver Real-Time Location)
 *   - 4T  (Driver Trip State Machine)
 *   - 4C  (Geofenced Delivery Scanning)
 *   - 5A  (Store Keeper Security Enclosure)
 *   - 9D  (Spot-Freight Auction)
 *   - 12  (B2B Marketplace)
 */

class BroadcastServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        require base_path('routes/channels.php');

        /*
         * Register the authentication routes for broadcasting.
         * This exposes:
         *   POST /broadcasting/auth  — Reverb WebSocket auth handshake
         *
         * The Flutter client calls this endpoint with the
         * socket_id + channel_name to receive an auth signature
         * before subscribing to private/presence channels.
         */
        Broadcast::routes([
            'middleware' => ['auth:sanctum'],
        ]);
    }
}
