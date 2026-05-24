<?php

use Illuminate\Support\Facades\Route;

Route::prefix('api/v1/factory')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        Route::prefix('production')->group(function (): void {
            Route::post('batches', [\App\Http\Controllers\FactoryProductionController::class, 'createBatch']);
            Route::post('generate-serials', [\App\Http\Controllers\FactoryProductionController::class, 'generateSerials']);
            Route::post('seal', [\App\Http\Controllers\FactoryProductionController::class, 'sealBatch']);
            Route::post('release', [\App\Http\Controllers\FactoryProductionController::class, 'releaseBatch']);
            Route::post('verify-serial', [\App\Http\Controllers\FactoryProductionController::class, 'verifySerial']);
        });

        Route::prefix('dispatch')->group(function (): void {
            Route::post('create', [\App\Http\Controllers\FactoryDispatchController::class, 'createDispatch']);
            Route::post('handshake', [\App\Http\Controllers\FactoryDispatchController::class, 'initiateHandshake']);
            Route::post('complete-transfer', [\App\Http\Controllers\FactoryDispatchController::class, 'completeTransfer']);
        });

        Route::prefix('dispute')->group(function (): void {
            Route::post('nfc-checkin', [\App\Http\Controllers\TransitDisputeController::class, 'nfcCheckIn']);
            Route::post('photo-evidence', [\App\Http\Controllers\TransitDisputeController::class, 'photoEvidence']);
        });

        // ─── Reverse Logistics (3AE) ────────────────────
        Route::prefix('claims')->group(function (): void {
            Route::post('approve/{id}', [\App\Http\Controllers\ReverseLogisticsController::class, 'approveClaim']);
            Route::post('reject/{id}', [\App\Http\Controllers\ReverseLogisticsController::class, 'rejectClaim']);
        });
    });
