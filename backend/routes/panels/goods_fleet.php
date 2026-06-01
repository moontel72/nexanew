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

// PUBLIC: Goods Fleet Staff Login gates (no auth) independent apps
Route::prefix('api/v1/goods-fleet')->group(function (): void {

    Route::post('login',           [\App\Http\Controllers\Admin\GoodsFleetController::class, 'login']);
    Route::post('owner-login',     [\App\Http\Controllers\Tenant\AccountEngineController::class, 'truckOwnerLogin']);
    Route::post('driver-login',    [\App\Http\Controllers\Tenant\AccountEngineController::class, 'truckDriverLogin']);
    Route::post('conductor-login', [\App\Http\Controllers\Tenant\AccountEngineController::class, 'truckConductorLogin']);
});

// AUTH: Super Admin Company Management + Owner Profile
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

        // Goods Fleet Staff CRUD (A-E Hierarchy)
        // Reuses FleetManagementController — detects 'truck' via request path
        Route::get('owners', [\App\Http\Controllers\FleetManagementController::class, 'listOwners']);
        Route::post('owners', [\App\Http\Controllers\FleetManagementController::class, 'storeOwner']);
        Route::get('owners/{id}', [\App\Http\Controllers\FleetManagementController::class, 'showOwner']);
        Route::put('owners/{id}', [\App\Http\Controllers\FleetManagementController::class, 'updateOwner']);
        Route::delete('owners/{id}', [\App\Http\Controllers\FleetManagementController::class, 'destroyOwner']);

        Route::prefix('drivers/manage')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\FleetManagementController::class, 'listDrivers']);
            Route::post('/', [\App\Http\Controllers\FleetManagementController::class, 'storeDriver']);
            Route::get('/{id}', [\App\Http\Controllers\FleetManagementController::class, 'showDriver']);
            Route::put('/{id}', [\App\Http\Controllers\FleetManagementController::class, 'updateDriver']);
            Route::delete('/{id}', [\App\Http\Controllers\FleetManagementController::class, 'destroyDriver']);
        });

        Route::get('conductors', [\App\Http\Controllers\FleetManagementController::class, 'listConductors']);
        Route::post('conductors', [\App\Http\Controllers\FleetManagementController::class, 'storeConductor']);
        Route::get('conductors/{id}', [\App\Http\Controllers\FleetManagementController::class, 'showConductor']);
        Route::put('conductors/{id}', [\App\Http\Controllers\FleetManagementController::class, 'updateConductor']);
        Route::delete('conductors/{id}', [\App\Http\Controllers\FleetManagementController::class, 'destroyConductor']);
    });
