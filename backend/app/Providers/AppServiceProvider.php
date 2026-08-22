<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\RateLimiter;
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

        // ─── NEXATRACE: Studio SSO rate limits ───
        // Login is keyed by IP + email so a distributed brute-force
        // attempt against one account is throttled without one director
        // locking out others behind the same nginx proxy IP.
        RateLimiter::for('studio-login', function (Request $request) {
            $identifier = strtolower(trim((string) $request->input('email')));

            return Limit::perMinute(10)->by($request->ip().'|'.$identifier);
        });

        // Exchange swaps an authenticated high-entropy manager token for
        // a media-engine JWT — cap endpoint flooding per IP.
        RateLimiter::for('studio-exchange', function (Request $request) {
            return Limit::perMinute(60)->by($request->ip());
        });
    }
}
