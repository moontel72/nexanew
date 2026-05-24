<?php

namespace App\Providers;

use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // ─── NEXATRACE: Register WebSocket broadcast auth routes ───
        // This is ADDITIVE only — registers /broadcasting/auth endpoint
        // for private/presence channel authentication.
        // Public channels (used by all current NexaTrace events) require
        // no auth, so this registration is optional but future-proof.
        Broadcast::routes(['middleware' => ['auth:sanctum']]);
    }
}
