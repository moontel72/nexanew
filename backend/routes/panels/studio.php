<?php

use App\Http\Controllers\Studio\StudioAuthController;
use Illuminate\Support\Facades\Route;

/*
|═══════════════════════════════════════════════════════════
| NEXATRACE — STUDIO MODULE ROUTES (Todd Studio / Media Engine)
|═══════════════════════════════════════════════════════════
|
| Phase-1 SSO: the React studio POSTs Cricket Manager credentials
| here and receives an HS256 JWT verified by the Rust media engine.
|
| No auth middleware — the login gate itself is the auth boundary
| (mirrors the cricket manager login, which exempts its own guard).
*/

Route::prefix('api/v1/studio')->group(function (): void {
    // Brute-force gate: 10 attempts/min per email+IP.
    Route::post('login', [StudioAuthController::class, 'login'])
        ->middleware('throttle:studio-login');
    // Phase 1 unified SSO: manager bearer token → media-engine JWT.
    // Endpoint flood gate: 60 requests/min per IP.
    Route::post('exchange', [StudioAuthController::class, 'exchange'])
        ->middleware('throttle:studio-exchange');
});
