<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withProviders([
        \App\Providers\PanelRouteServiceProvider::class,
    ])
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api',
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->append(\App\Http\Middleware\CorsMiddleware::class);

        /**
         * Middleware aliases in authoritative Section 10.10 order.
         *
         * The numeric order reflects the exact pipeline sequence:
         *   Step 1-3:  Built-in (ForceHttps, RateLimiter, SanctumAuthenticate)
         *   Step 4:    token.version    — TokenVersionGuard
         *   Step 5:    identity.status  — IdentityStatusGate
         *   Step 6:    (kyc.tier — optional, registered below)
         *   Step 7:    tenant.context   — TenantContextResolver
         *   Step 8:    (feature.grant — registered below)
         *   Step 9:    allowance.shield — VendorAllowanceShield
         *   Step 10:   (rls.binder — Wave 4)
         *   Step 11:   (audit.capture — Wave 4)
         *   Step 12:   response.mask    — ResponseMaskSerializer
         */
        $middleware->alias([
            // Built-in guards
            'auth'         => \App\Http\Middleware\Authenticate::class,
            'admin'        => \App\Http\Middleware\AdminMiddleware::class,
            'sub.admin'    => \App\Http\Middleware\SubAdminMiddleware::class,
            'driver.type'  => \App\Http\Middleware\EnsureDriverType::class,
            'chat.filter'  => \App\Http\Middleware\AIChatLeakFilter::class,

            // Wave 2 — Section 10.10 Steps 4-5
            'token.version'   => \App\Http\Middleware\TokenVersionGuard::class,
            'identity.status' => \App\Http\Middleware\IdentityStatusGate::class,

            // Wave 3 — Section 10.10 Step 7: Tenant Context Resolution (Defect F-8 fix)
            'tenant.context' => \App\Http\Middleware\TenantContextResolver::class,

            // Wave 3 — Section 10.10 Step 9: Vendor Allowance Shield
            'allowance.shield' => \App\Http\Middleware\VendorAllowanceShield::class,

            // Wave 3 — Section 10.10 Step 12: Response Mask Serializer (Defect F-4 fix)
            'response.mask' => \App\Http\Middleware\ResponseMaskSerializer::class,

            // Wave 3 — Bus Fleet Panel Gate (Defect #1 fix)
            'bus.fleet' => \App\Http\Middleware\BusFleetGate::class,

            // Cricket Module — Cricket Manager Auth (isolated Bearer token guard)
            'cricket.manager' => \App\Http\Middleware\Cricket\CricketManagerAuth::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
