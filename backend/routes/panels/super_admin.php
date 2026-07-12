<?php

use Illuminate\Support\Facades\Route;

Route::prefix('api/v1/super-admin')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        // ─── Absolute Layout Presets (Sub-Admin Template Management) ──
        Route::prefix('absolute-layouts')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\AbsoluteLayoutController::class, 'index']);
            Route::post('/', [\App\Http\Controllers\AbsoluteLayoutController::class, 'store']);
            Route::get('/presets', [\App\Http\Controllers\AbsoluteLayoutController::class, 'listPresets']);
            Route::get('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'show']);
            Route::put('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'update']);
            Route::post('/{id}/publish', [\App\Http\Controllers\AbsoluteLayoutController::class, 'publish']);
            Route::delete('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'destroy']);
        });

        Route::prefix('financial')->group(function (): void {
            Route::get('vouchers/pending', [\App\Http\Controllers\SuperAdminFinancialController::class, 'pendingVouchers']);
            Route::post('vouchers/settle/{id}', [\App\Http\Controllers\SuperAdminFinancialController::class, 'settleVoucher']);
            Route::get('withdrawals/pending', [\App\Http\Controllers\SuperAdminFinancialController::class, 'pendingWithdrawals']);
            Route::post('withdrawals/process/{id}', [\App\Http\Controllers\SuperAdminFinancialController::class, 'processWithdrawal']);
            Route::get('settlements/history', [\App\Http\Controllers\SuperAdminFinancialController::class, 'history']);
        });

        // ─── Security Monitor (Step 26 — FINAL) ──────────
        Route::prefix('security')->group(function (): void {
            Route::get('infractions', [\App\Http\Controllers\SecurityMonitorController::class, 'infractions']);
            Route::get('audit-ledger', [\App\Http\Controllers\SecurityMonitorController::class, 'auditLedger']);
        });

        // ─── Tenant Account Management (Setup 17) ────────
        Route::prefix('tenants')->group(function (): void {
            Route::post('register-sub-owner', [\App\Http\Controllers\Tenant\AccountEngineController::class, 'registerSubOwner']);
            Route::get('fleet-data', [\App\Http\Controllers\Tenant\AccountEngineController::class, 'getLinkedFleetData']);
            Route::post('login', [\App\Http\Controllers\Tenant\AccountEngineController::class, 'tenantLogin'])->withoutMiddleware('auth:sanctum');
            Route::get('directory', [\App\Http\Controllers\Tenant\AccountEngineController::class, 'tenantDirectory']);
        });

        // ─── Billing Invoice (Setup 18) ────────────────────
        Route::get('billing-invoice', [\App\Http\Controllers\Telemetry\TrackingRouterController::class, 'getSuperAdminBillingInvoice']);
    });

// ─── Public Family Tracking (Setup 18) — no auth ──────────
Route::prefix('api/v1/tracking')->group(function (): void {
    Route::post('generate-family-token', [\App\Http\Controllers\Telemetry\TrackingRouterController::class, 'generateFamilyShareToken'])->middleware('auth:sanctum');
    Route::get('family-stream/{token}', [\App\Http\Controllers\Telemetry\TrackingRouterController::class, 'getPublicFamilyStream']);
});

// ─── Polymorphic Bidding Exchange (Setup 20) ──────────────
Route::prefix('api/v1/exchange')->group(function (): void {
    Route::post('broadcast-trip', [\App\Http\Controllers\Exchange\BiddingMeshController::class, 'broadcastTripRequest'])->middleware('auth:sanctum');
    Route::post('submit-bid', [\App\Http\Controllers\Exchange\BiddingMeshController::class, 'submitCounterBid'])->middleware('auth:sanctum');
    Route::post('accept-bid/{proposalId}', [\App\Http\Controllers\Exchange\BiddingMeshController::class, 'acceptWinningBid'])->middleware('auth:sanctum');
    Route::get('trip-bids/{tripId}', [\App\Http\Controllers\Exchange\BiddingMeshController::class, 'getTripBids'])->middleware('auth:sanctum');
});
