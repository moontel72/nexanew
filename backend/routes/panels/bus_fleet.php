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
            $carrierId = $request->get('_carrier_company_id')
                ?? \Illuminate\Support\Facades\DB::table('fleet_assignments')
                    ->where('global_identity_id', $user->global_identity_id ?? null)
                    ->where('role', 'owner')
                    ->where('fleet_type', 'bus')
                    ->whereIn('status', ['active', 'pending_acceptance'])
                    ->value('carrier_company_id');

            $isMasterAdmin = ($user->account_type ?? null) === 'master_admin';

            // For master admin or when no specific carrier: show aggregated stats
            if (!$carrierId && !$isMasterAdmin) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $fleetSize = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->when($carrierId, fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('layout_status', '!=', 'archived')
                ->count();

            $staffCount = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->when($carrierId, fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('fleet_type', 'bus')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->count();

            $companyName = 'NexaTrace Fleet';
            if ($carrierId) {
                $company = \Illuminate\Support\Facades\DB::table('tenant_accounts')->where('id', $carrierId)->first();
                $companyName = $company->account_name ?? 'Bus Company';
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'company' => [
                        'id'    => $carrierId ?? 'admin',
                        'name'  => $companyName,
                        'email' => $user->email ?? '',
                        'phone' => $user->phone_number ?? '',
                        'status'=> 'active',
                        'city'  => null,
                        'country' => null,
                    ],
                    'fleet_size'    => $fleetSize,
                    'active_routes' => 0,
                    'owner_name'    => $companyName,
                    'is_bus_fleet'  => true,
                    'active_buses'  => $fleetSize,
                    'staff_count'   => $staffCount,
                ],
            ]);
        });

        // Fleet Dashboard Stats
        Route::get('dashboard', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $carrierId = $request->get('_carrier_company_id')
                ?? \Illuminate\Support\Facades\DB::table('fleet_assignments')
                    ->where('global_identity_id', $user->global_identity_id ?? null)
                    ->where('role', 'owner')
                    ->where('fleet_type', 'bus')
                    ->whereIn('status', ['active', 'pending_acceptance'])
                    ->value('carrier_company_id');

            $isMasterAdmin = ($user->account_type ?? null) === 'master_admin';

            if (!$carrierId && !$isMasterAdmin) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $fleetSize = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->when($carrierId, fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('layout_status', '!=', 'archived')
                ->count();

            $companyName = 'NexaTrace Fleet';
            if ($carrierId) {
                $company = \Illuminate\Support\Facades\DB::table('tenant_accounts')->where('id', $carrierId)->first();
                $companyName = $company->account_name ?? 'Bus Company';
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'company_id'   => $carrierId ?? 'admin',
                    'company_name' => $companyName,
                    'status'       => 'active',
                    'fleet_size'   => $fleetSize,
                    'active_routes'=> 0,
                    'owner_name'   => $companyName,
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

        // ─── Absolute Layouts (Freeform Canvas) — sole layout engine ──
        Route::prefix('absolute-layouts')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\AbsoluteLayoutController::class, 'index']);
            Route::post('/', [\App\Http\Controllers\AbsoluteLayoutController::class, 'store']);
            Route::delete('/purge/all', [\App\Http\Controllers\AbsoluteLayoutController::class, 'purgeAll']);
            Route::get('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'show']);
            Route::put('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'update']);
            Route::post('/{id}/publish', [\App\Http\Controllers\AbsoluteLayoutController::class, 'publish']);
            Route::delete('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'destroy']);
        });

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

        // Identity Portability — Link Request Management (§10.11.2)
        Route::prefix('link-requests')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\FleetManagementController::class, 'listLinkRequests']);
            Route::post('{id}/accept', [\App\Http\Controllers\FleetManagementController::class, 'acceptLinkRequest']);
            Route::post('{id}/reject', [\App\Http\Controllers\FleetManagementController::class, 'rejectLinkRequest']);
            Route::post('{id}/hold', [\App\Http\Controllers\FleetManagementController::class, 'holdLinkRequest']);
        });

        // Link Messages — Persistent B2B Chat
        Route::prefix('link-messages')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\FleetManagementController::class, 'listAllConversations']);
            Route::get('{assignmentId}', [\App\Http\Controllers\FleetManagementController::class, 'listMessages']);
            Route::post('{assignmentId}', [\App\Http\Controllers\FleetManagementController::class, 'sendMessage']);
        });
    });
