<?php

use Illuminate\Support\Facades\Route;

/**
 * NEXATRACE — PASSENGER TICKET ROUTES
 * ====================================
 *
 * Route prefix: /api/v1/passenger
 * Middleware:   auth:sanctum
 *
 * Secure ticket viewing, download, and gate-scan verification.
 *
 * TARGET MODULES: 8V, 15C, 15E
 */

Route::prefix('api/v1/passenger')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        // Ticket data (JSON)
        Route::get('tickets/{bookingId}', [\App\Http\Controllers\PassengerTicketController::class, 'show']);

        // Download printable ticket (HTML)
        Route::get('tickets/{bookingId}/download', [\App\Http\Controllers\PassengerTicketController::class, 'download']);

        // Gate-scan verification (conductor app)
        Route::post('tickets/verify', [\App\Http\Controllers\PassengerTicketController::class, 'verify']);
    });
