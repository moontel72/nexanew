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
    ->middleware(['auth:sanctum', 'bus.fleet'])
    ->group(function (): void {

        // Company Profile (Dashboard) — resolved via identity spine
        Route::get('profile', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $carrierId = $request->get('_carrier_company_id');

            $company = null;
            if ($carrierId) {
                $company = \Illuminate\Support\Facades\DB::table('tenant_accounts')
                    ->where('id', $carrierId)
                    ->first();
            }

            if (!$company) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $fleetSize = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('carrier_company_id', $carrierId)
                ->where('layout_status', '!=', 'archived')
                ->count();

            $staffCount = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->where('carrier_company_id', $carrierId)
                ->where('fleet_type', 'bus')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'company' => [
                        'id'    => $company->id,
                        'name'  => $company->account_name ?? 'Bus Company',
                        'email' => $company->email ?? '',
                        'phone' => $company->phone_number ?? '',
                        'status'=> $company->status ?? 'active',
                        'city'  => null,
                        'country' => null,
                    ],
                    'fleet_size'    => $fleetSize,
                    'active_routes' => 0,
                    'owner_name'    => $company->account_name ?? null,
                    'is_bus_fleet'  => true,
                    'active_buses'  => $fleetSize,
                    'staff_count'   => $staffCount,
                ],
            ]);
        });

        // Fleet Dashboard Stats
        Route::get('dashboard', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $carrierId = $request->get('_carrier_company_id');

            $company = null;
            if ($carrierId) {
                $company = \Illuminate\Support\Facades\DB::table('tenant_accounts')
                    ->where('id', $carrierId)
                    ->first();
            }

            if (!$company) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $fleetSize = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('carrier_company_id', $carrierId)
                ->where('layout_status', '!=', 'archived')
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'company_id'   => $company->id,
                    'company_name' => $company->account_name ?? 'Bus Company',
                    'status'       => $company->status ?? 'active',
                    'fleet_size'   => $fleetSize,
                    'active_routes'=> 0,
                    'owner_name'   => $company->account_name ?? null,
                    'total_trips'  => 0,
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

        // Bus Owner: Seat Layout Builder (14E) — legacy backward compat
        Route::post('owners/layouts', [\App\Http\Controllers\BusTransitController::class, 'createLayout']);

        // Seat Layout Designer (14E) — Wave 4
        Route::prefix('layouts')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\BusTransitController::class, 'listLayouts']);
            Route::post('/', [\App\Http\Controllers\BusTransitController::class, 'createLayoutFull']);
            Route::get('/{id}', [\App\Http\Controllers\BusTransitController::class, 'getLayout']);
            Route::post('/{id}/acquire-lock', [\App\Http\Controllers\BusTransitController::class, 'acquireLock']);
            Route::post('/{id}/release-lock', [\App\Http\Controllers\BusTransitController::class, 'releaseLock']);
            Route::post('/{id}/publish', [\App\Http\Controllers\BusTransitController::class, 'publishLayout']);
            Route::get('/{id}/revisions', [\App\Http\Controllers\BusTransitController::class, 'listRevisions']);
            Route::delete('/{id}', [\App\Http\Controllers\BusTransitController::class, 'archiveLayout']);
        });
        Route::get('layout-presets', [\App\Http\Controllers\BusTransitController::class, 'listPresets']);

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

// PUBLIC: Driver/Conductor profile - validates Bearer token for any staff
Route::get('api/v1/bus-fleet/staff/profile', function (\Illuminate\Http\Request $request) {
    $token = $request->bearerToken();
    if (!$token) return response()->json(['status'=>'error','message'=>'Unauthenticated.'], 401);
    $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($token);
    if (!$accessToken || !$accessToken->tokenable) return response()->json(['status'=>'error','message'=>'Invalid token.'], 401);
    $staff = $accessToken->tokenable;
    return response()->json([
        'status'=>'success',
        'data'=>[
            'id'=>$staff->id,'account_name'=>$staff->account_name,
            'email'=>$staff->email??'','phone'=>$staff->phone_number??'',
            'account_type'=>$staff->account_type??'staff','status'=>$staff->status??'active',
        ],
    ]);
});
