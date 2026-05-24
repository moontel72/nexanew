<?php

use Illuminate\Support\Facades\Route;

/**
 * NEXATRACE — CONSUMER SUPER-APP PANEL ROUTES
 * =============================================
 *
 * Route prefix: /api/v1/consumer
 * Middleware:   auth:sanctum
 *
 * MODULES COVERED: 8Z, 12M, 12N
 */

Route::prefix('api/v1/consumer')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        // ─── Transit Search (8Z) ────────────────────────
        Route::get('transit/search', [\App\Http\Controllers\ConsumerSuperAppController::class, 'searchTransit']);

        // ─── Fleet Auctions (12M) ────────────────────────
        Route::prefix('fleet')->group(function (): void {
            Route::post('auction', [\App\Http\Controllers\ConsumerSuperAppController::class, 'createAuction']);
            Route::post('bid', [\App\Http\Controllers\ConsumerSuperAppController::class, 'placeBid']);
        });

        // ─── Chat (12N) — AI Filter Protection ────────────
        Route::prefix('chat')->middleware('chat.filter')->group(function (): void {
            Route::post('send', [\App\Http\Controllers\ConsumerSuperAppController::class, 'sendChat']);
        });
    });
