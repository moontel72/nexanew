<?php

use Illuminate\Support\Facades\Route;

/**
 * NEXATRACE — GOODS FLEET PANEL ROUTES
 * ======================================
 *
 * Route prefix: /api/v1/goods-fleet
 * Middleware:   auth:admin
 *
 * MODULES COVERED:
 *   - Goods Fleet Company Management (Super Admin)
 *   - Goods Company Owner Login & Profile
 *   - Goods Fleet Dashboard
 */

// ─── PUBLIC: Goods Company Owner Login ───────────
Route::prefix('api/v1/goods-fleet')->group(function (): void {

    Route::post('login', [\App\Http\Controllers\Admin\GoodsFleetController::class, 'login']);
});

// ─── AUTH: Super Admin Company Management + Owner Profile ────────
Route::prefix('api/v1/goods-fleet')
    ->middleware(['auth:admin'])
    ->group(function (): void {

        // Super Admin — Manage goods fleet companies
        Route::get('companies', [\App\Http\Controllers\Admin\GoodsFleetController::class, 'listCompanies']);
        Route::post('companies', [\App\Http\Controllers\Admin\GoodsFleetController::class, 'storeCompany']);
        Route::get('companies/{id}', [\App\Http\Controllers\Admin\GoodsFleetController::class, 'showCompany']);

        // Authenticated goods fleet owner — Profile & Dashboard
        Route::get('profile', [\App\Http\Controllers\Admin\GoodsFleetController::class, 'profile']);
        Route::get('dashboard', [\App\Http\Controllers\Admin\GoodsFleetController::class, 'dashboard']);
    });
