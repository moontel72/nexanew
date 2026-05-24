<?php

use Illuminate\Support\Facades\Route;

Route::prefix('api/v1/marketplace')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        Route::post('shop/cash-out', [\App\Http\Controllers\ShopkeeperLiquidityController::class, 'cashOut']);
        Route::get('reseller/dashboard', [\App\Http\Controllers\ResellerPortalController::class, 'dashboard']);

        Route::prefix('matrix')->group(function (): void {
            Route::post('validate-territory', [\App\Http\Controllers\FactoryMatrixController::class, 'validateTerritory']);
            Route::post('challenge-otp', [\App\Http\Controllers\FactoryMatrixController::class, 'challengeOtp']);
            Route::post('verify-otp', [\App\Http\Controllers\FactoryMatrixController::class, 'verifyOtp']);
            Route::post('enforce-msrp', [\App\Http\Controllers\FactoryMatrixController::class, 'enforceMsrp']);
        });

        Route::prefix('retail')->group(function (): void {
            Route::post('dispatch', [\App\Http\Controllers\RetailDistributionController::class, 'dispatchShipment']);
            Route::post('stock-in', [\App\Http\Controllers\RetailDistributionController::class, 'stockIn']);
        });

        Route::prefix('subscription')->group(function (): void {
            Route::post('validate-listing', [\App\Http\Controllers\MarketplaceSubscriptionController::class, 'validateListing']);
            Route::post('otp-gate', [\App\Http\Controllers\MarketplaceSubscriptionController::class, 'otpGate']);
            Route::get('tier', [\App\Http\Controllers\MarketplaceSubscriptionController::class, 'myTier']);
        });

        Route::prefix('claims')->group(function (): void {
            Route::post('submit', [\App\Http\Controllers\ReverseLogisticsController::class, 'submitClaim']);
        });

        // ─── Consumer Verification (8Y) ──────────────────
        Route::prefix('consumer')->group(function (): void {
            Route::post('verify', [\App\Http\Controllers\ConsumerScanController::class, 'verify']);
        });
    });
