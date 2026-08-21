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
    Route::post('login', [StudioAuthController::class, 'login']);
    // Phase 1 unified SSO: manager bearer token → media-engine JWT.
    Route::post('exchange', [StudioAuthController::class, 'exchange']);
});
