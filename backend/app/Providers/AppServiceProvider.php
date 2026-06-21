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
        // ─── NEXATRACE: Auto-create missing DB tables/columns ───
        // Failsafe for production servers where php artisan migrate
        // may have silently failed. Uses CREATE IF NOT EXISTS.
        \App\Services\SchemaBootstrapService::boot();

        // ─── NEXATRACE: Register WebSocket broadcast auth routes ───
        Broadcast::routes(['middleware' => ['auth:sanctum']]);
    }
}
