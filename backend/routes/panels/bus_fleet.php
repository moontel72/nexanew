<?php

use Illuminate\Support\Facades\Route;

/**
 * NEXATRACE — BUS FLEET PANEL ROUTES
 * ====================================
 *
 * Route prefix: /api/v1/bus-fleet
 * Middleware:   auth:sanctum
 *
 * MODULES COVERED:
 *   - Module 13 (Public Transport Bus Admin Panel)
 *   - Module 14 (Bus Owners App) + 14E Seat Grid Builder
 *   - Module 15 (Bus Drivers App) + 15E Gate QR Automation
 *   - Module 8V (Customer 2-in-1 Bus Transit)
 *   - Module 8W (3-Way Payment & Voucher Logic)
 */

Route::prefix('api/v1/bus-fleet')
    ->middleware(['auth:admin'])
    ->group(function (): void {

        // Company Profile (Dashboard)
        Route::get('profile', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $email = $user->email;

            $company = \App\Models\Company::query()
                ->where('email', $email)
                ->orWhere('contact_person_email', $email)
                ->with(['documents', 'activeSubscription.plan'])
                ->first();

            if (!$company) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $meta = $company->metadata ?? [];
            $notes = $meta['notes'] ?? null;
            $busMeta = null;
            if ($notes && is_string($notes)) {
                $decoded = json_decode($notes, true);
                if (is_array($decoded) && ($decoded['company_type_tag'] ?? null) === 'bus_fleet') {
                    $busMeta = $decoded;
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'company' => (new \App\Http\Resources\CompanyResource($company))->toArray($request),
                    'fleet_size' => $busMeta['fleet_size'] ?? 0,
                    'active_routes' => $busMeta['active_routes'] ?? 0,
                    'owner_name' => $busMeta['owner_name'] ?? null,
                    'is_bus_fleet' => $busMeta !== null,
                ],
            ]);
        });

        // Fleet Dashboard Stats
        Route::get('dashboard', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $email = $user->email;

            $company = \App\Models\Company::query()
                ->where('email', $email)
                ->orWhere('contact_person_email', $email)
                ->first();

            if (!$company) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $meta = $company->metadata ?? [];
            $notes = $meta['notes'] ?? null;
            $busMeta = null;
            if ($notes && is_string($notes)) {
                $decoded = json_decode($notes, true);
                if (is_array($decoded) && ($decoded['company_type_tag'] ?? null) === 'bus_fleet') {
                    $busMeta = $decoded;
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'company_id' => $company->id,
                    'company_name' => $company->name,
                    'status' => $company->status,
                    'fleet_size' => $busMeta['fleet_size'] ?? 0,
                    'active_routes' => $busMeta['active_routes'] ?? 0,
                    'owner_name' => $busMeta['owner_name'] ?? $company->contact_person_name,
                    'total_trips' => 0,
                    'active_trips' => 0,
                ],
            ]);
        });

        // Trips (Admin / Owner)
        Route::post('trips', [\App\Http\Controllers\BusDispatchController::class, 'createTrip']);
        Route::get('trips/active', [\App\Http\Controllers\BusDispatchController::class, 'activeTrips']);

        // Driver Dispatch (15A, 15B)
        Route::prefix('driver')->group(function (): void {
            Route::post('start-trip/{id}', [\App\Http\Controllers\BusDispatchController::class, 'startTrip']);
            Route::post('update-location/{id}', [\App\Http\Controllers\BusDispatchController::class, 'updateLocation']);
            Route::post('complete-trip/{id}', [\App\Http\Controllers\BusDispatchController::class, 'completeTrip']);
        });

        // Bus Owner: Seat Layout Builder (14E)
        Route::post('owners/layouts', [\App\Http\Controllers\BusTransitController::class, 'createLayout']);

        // Bus Door QR Codes (15E)
        Route::post('qr/register', [\App\Http\Controllers\BusTransitController::class, 'registerQr']);
        Route::get('qr/scan/{uuid}', [\App\Http\Controllers\BusTransitController::class, 'scanQr']);

        // Customer Seat Booking (8V)
        Route::post('bookings', [\App\Http\Controllers\BusTransitController::class, 'bookSeat']);

        // NexaTrace Cash Vouchers (8W)
        Route::post('vouchers/create', [\App\Http\Controllers\BusTransitController::class, 'createVoucher']);

        // Fleet Staff Dropdowns (Setup 14/15)
        Route::prefix('staff')->group(function (): void {
            Route::get('drivers', [\App\Http\Controllers\FleetStaffController::class, 'getDriversList']);
            Route::get('conductors', [\App\Http\Controllers\FleetStaffController::class, 'getConductorsList']);
            Route::get('plates', [\App\Http\Controllers\FleetStaffController::class, 'getBusPlates']);
        });

        // Bus Owners CRUD
        Route::get('owners', [\App\Http\Controllers\FleetManagementController::class, 'listOwners']);
        Route::post('owners', [\App\Http\Controllers\FleetManagementController::class, 'storeOwner']);
        Route::get('owners/{id}', [\App\Http\Controllers\FleetManagementController::class, 'showOwner']);
        Route::put('owners/{id}', [\App\Http\Controllers\FleetManagementController::class, 'updateOwner']);
        Route::delete('owners/{id}', [\App\Http\Controllers\FleetManagementController::class, 'destroyOwner']);

        // Bus Drivers CRUD
        Route::prefix('drivers/manage')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\FleetManagementController::class, 'listDrivers']);
            Route::post('/', [\App\Http\Controllers\FleetManagementController::class, 'storeDriver']);
            Route::get('/{id}', [\App\Http\Controllers\FleetManagementController::class, 'showDriver']);
            Route::put('/{id}', [\App\Http\Controllers\FleetManagementController::class, 'updateDriver']);
            Route::delete('/{id}', [\App\Http\Controllers\FleetManagementController::class, 'destroyDriver']);
        });

        // Bus Conductors CRUD
        Route::get('conductors', [\App\Http\Controllers\FleetManagementController::class, 'listConductors']);
        Route::post('conductors', [\App\Http\Controllers\FleetManagementController::class, 'storeConductor']);
        Route::get('conductors/{id}', [\App\Http\Controllers\FleetManagementController::class, 'showConductor']);
        Route::put('conductors/{id}', [\App\Http\Controllers\FleetManagementController::class, 'updateConductor']);
        Route::delete('conductors/{id}', [\App\Http\Controllers\FleetManagementController::class, 'destroyConductor']);

        // Shift Allocation Roster (Setup 14/15)
        Route::prefix('shifts')->group(function (): void {
            Route::post('save', [\App\Http\Controllers\BusShiftController::class, 'saveShiftRoster']);
            Route::get('{plate}', [\App\Http\Controllers\BusShiftController::class, 'getShiftRoster']);
        });
    });

// ================================================================
// PUBLIC: Bus Fleet Staff Login gates (no auth) — independent apps
// Each endpoint is its own Flutter build login gate.
// staff_type + driver_type are hardcoded by the route, not sent by the client.
// ================================================================
Route::post('api/v1/bus-fleet/owner-login',     [\App\Http\Controllers\Tenant\AccountEngineController::class, 'busOwnerLogin']);
Route::post('api/v1/bus-fleet/driver-login',    [\App\Http\Controllers\Tenant\AccountEngineController::class, 'busDriverLogin']);
Route::post('api/v1/bus-fleet/conductor-login', [\App\Http\Controllers\Tenant\AccountEngineController::class, 'busConductorLogin']);

// PUBLIC: Owner dashboard profile - validates Bearer token manually
Route::get('api/v1/bus-fleet/owner/profile', function (\Illuminate\Http\Request $request) {
    $token = $request->bearerToken();
    if (!$token) {
        return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
    }
    $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($token);
    if (!$accessToken || !$accessToken->tokenable) {
        return response()->json(['status' => 'error', 'message' => 'Invalid token.'], 401);
    }
    $owner = $accessToken->tokenable;
    return response()->json([
        'status' => 'success',
        'data' => [
            'id' => $owner->id,
            'account_name' => $owner->account_name,
            'email' => $owner->email ?? '',
            'phone' => $owner->phone_number ?? '',
            'account_type' => $owner->account_type ?? 'bus_owner',
            'status' => $owner->status ?? 'active',
            'active_buses' => 0,
            'daily_revenue' => 0,
        ],
    ]);
});
