<?php

use Illuminate\Support\Facades\Route;

/**
 * NEXATRACE — TRUCK FLEET PANEL ROUTES
 * ======================================
 *
 * Route prefix: /api/v1/truck-fleet
 * Middleware:   auth:sanctum
 *
 * MODULES COVERED:
 *   - Module 9  (Goods Company Admin Panel)
 *   - Module 10 (Truck Owners App)
 *   - Module 11 (Truck Drivers App)
 *   - Module 12G (Driver Dispatch Scanning Safeguard)
 */

Route::prefix('api/v1/truck-fleet')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        // ─── Retail: Driver Pickup Verification (12G) ──────
        Route::post('retail/verify-pickup', [\App\Http\Controllers\RetailDistributionController::class, 'verifyPickup']);

        // ─── Freight Loads & Auction (future) ──────────────
        // Route::get('loads', ...);
        // Route::post('loads', ...);

        // ─── Truck Owners (future) ─────────────────────────
        // Route::prefix('truck-owners')->group(...);

        // ─── Truck Drivers (future) ─────────────────────────
        // Route::prefix('truck-drivers')->group(...);

        // ─── Goods Logistics & Smart Codes (Setup 19) ──────
        Route::prefix('logistics')->group(function (): void {
            Route::post('generate-manifest', [\App\Http\Controllers\Logistics\SmartCodeController::class, 'generateSmartManifest']);
            Route::get('truck-sequence/{truckPlate}', [\App\Http\Controllers\Logistics\SmartCodeController::class, 'getTruckLoadingSequence']);
            Route::post('warehouse-config', [\App\Http\Controllers\Logistics\SmartCodeController::class, 'registerWarehouseSlot']);
        });
    });
