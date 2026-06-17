<?php

use Illuminate\Support\Facades\Route;

// ═══════════════════════════════════════════════════════════════
// PUBLIC — Customer App (Module 8V) — no auth required
// ═══════════════════════════════════════════════════════════════
// MUST be registered BEFORE the auth group so literal routes
// like /public are not shadowed by /{id} in the auth group.
Route::prefix('api/v1/bus-fleet')->group(function (): void {
    Route::get('absolute-layouts/public', [\App\Http\Controllers\AbsoluteLayoutController::class, 'listPublic']);
    Route::get('absolute-layouts/{id}/public', [\App\Http\Controllers\AbsoluteLayoutController::class, 'showPublic']);
});

Route::prefix('api/v1/bus-fleet')
    ->middleware(['auth:sanctum', 'bus.fleet'])
    ->group(function (): void {

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
            if (!$carrierId && !$isMasterAdmin) {
                return response()->json(['message' => 'No company found for this account'], 404);
            }

            $fleetSize = \Illuminate\Support\Facades\DB::table('absolute_bus_layouts')
                ->where('layout_status', '!=', 'archived')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
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

            $activeRoutes = \Illuminate\Support\Facades\DB::table('transport_bus_routes')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('transport_bus_routes', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('status', 'published')
                ->count();

            $totalTrips = \Illuminate\Support\Facades\DB::table('transport_bus_trips')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('transport_bus_trips', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->count();

            $activeTrips = \Illuminate\Support\Facades\DB::table('transport_bus_trips')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('transport_bus_trips', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('status', 'active')
                ->count();

            return response()->json(['success' => true, 'data' => [
                'company' => ['id' => $carrierId ?? 'admin', 'name' => $companyName, 'email' => $user->email ?? '', 'phone' => $user->phone_number ?? '', 'status' => 'active', 'city' => null, 'country' => null],
                'fleet_size' => $fleetSize, 'active_routes' => $activeRoutes, 'owner_name' => $companyName, 'is_bus_fleet' => true, 'active_buses' => $fleetSize, 'staff_count' => $staffCount,
            ]]);
        });

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

            $fleetSize = \Illuminate\Support\Facades\DB::table('absolute_bus_layouts')
                ->where('layout_status', '!=', 'archived')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->count();

            $companyName = 'NexaTrace Fleet';
            if ($carrierId) {
                $company = \Illuminate\Support\Facades\DB::table('tenant_accounts')->where('id', $carrierId)->first();
                $companyName = $company->account_name ?? 'Bus Company';
            }

            $activeRoutes = \Illuminate\Support\Facades\DB::table('transport_bus_routes')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('transport_bus_routes', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('status', 'published')
                ->count();

            $totalTrips = \Illuminate\Support\Facades\DB::table('transport_bus_trips')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('transport_bus_trips', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->count();

            $activeTrips = \Illuminate\Support\Facades\DB::table('transport_bus_trips')
                ->when($carrierId && \Illuminate\Support\Facades\Schema::hasColumn('transport_bus_trips', 'carrier_company_id'),
                    fn($q) => $q->where('carrier_company_id', $carrierId))
                ->where('status', 'active')
                ->count();

            return response()->json(['success' => true, 'data' => [
                'company_id' => $carrierId ?? 'admin', 'company_name' => $companyName, 'status' => 'active',
                'fleet_size' => $fleetSize, 'active_routes' => $activeRoutes, 'owner_name' => $companyName,
                'total_trips' => $totalTrips, 'active_trips' => $activeTrips,
            ]]);
        });

        // Trips
        Route::post('trips', [\App\Http\Controllers\BusDispatchController::class, 'createTrip']);
        Route::get('trips/active', [\App\Http\Controllers\BusDispatchController::class, 'activeTrips']);

        // Routes (13B — Route Scheduler)
        Route::get('routes', [\App\Http\Controllers\BusRouteController::class, 'index']);
        Route::post('routes', [\App\Http\Controllers\BusRouteController::class, 'store']);
        Route::get('routes/{id}', [\App\Http\Controllers\BusRouteController::class, 'show']);
        Route::put('routes/{id}', [\App\Http\Controllers\BusRouteController::class, 'update']);
        Route::delete('routes/{id}', [\App\Http\Controllers\BusRouteController::class, 'destroy']);
        Route::post('routes/{id}/publish', [\App\Http\Controllers\BusRouteController::class, 'publish']);
        Route::post('routes/{id}/waypoints', [\App\Http\Controllers\BusRouteController::class, 'saveWaypoints']);

        // Driver Dispatch (15A, 15B)
        Route::prefix('driver')->group(function (): void {
            Route::post('start-trip/{id}', [\App\Http\Controllers\BusDispatchController::class, 'startTrip']);
            Route::post('update-location/{id}', [\App\Http\Controllers\BusDispatchController::class, 'updateLocation']);
            Route::post('complete-trip/{id}', [\App\Http\Controllers\BusDispatchController::class, 'completeTrip']);
        });

        // Absolute Layouts
        Route::prefix('absolute-layouts')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\AbsoluteLayoutController::class, 'index']);
            Route::post('/', [\App\Http\Controllers\AbsoluteLayoutController::class, 'store']);
            Route::delete('/purge/all', [\App\Http\Controllers\AbsoluteLayoutController::class, 'purgeAll']);
            Route::get('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'show']);
            Route::put('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'update']);
            Route::post('/{id}/publish', [\App\Http\Controllers\AbsoluteLayoutController::class, 'publish']);
            Route::delete('/{id}', [\App\Http\Controllers\AbsoluteLayoutController::class, 'destroy']);
        });

        // QR, Bookings, Vouchers, Staff, Owners, Drivers, Conductors, Shifts, Links
        Route::post('qr/register', [\App\Http\Controllers\BusTransitController::class, 'registerQr']);
        Route::get('qr/scan/{uuid}', [\App\Http\Controllers\BusTransitController::class, 'scanQr']);
        Route::post('bookings', [\App\Http\Controllers\BusTransitController::class, 'bookSeat']);
        Route::post('vouchers/create', [\App\Http\Controllers\BusTransitController::class, 'createVoucher']);

        Route::prefix('staff')->group(function (): void {
            Route::get('profile', function (\Illuminate\Http\Request $request) {
                $user = $request->user();
                $identityId = $user->global_identity_id ?? null;

                if (!$identityId) {
                    return response()->json(['message' => 'No identity found for this account'], 404);
                }

                $assignment = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                    ->where('global_identity_id', $identityId)
                    ->where('fleet_type', 'bus')
                    ->whereIn('role', ['driver', 'conductor'])
                    ->whereIn('status', ['active', 'pending_acceptance'])
                    ->first();

                if (!$assignment) {
                    return response()->json(['message' => 'No active staff assignment found'], 404);
                }

                $identity = \Illuminate\Support\Facades\DB::table('global_identities')
                    ->where('id', $identityId)
                    ->first();

                $meta = is_string($assignment->assignment_meta ?? null)
                    ? json_decode($assignment->assignment_meta, true)
                    : ($assignment->assignment_meta ?? []);

                $plate = $meta['plate_number'] ?? $meta['plate'] ?? ($assignment->plate_number ?? null);
                $busId = $meta['bus_id'] ?? ($assignment->bus_id ?? null);

                // Resolve active trip for this staff member
                $activeTrip = \Illuminate\Support\Facades\DB::table('transport_bus_trips')
                    ->where(function ($q) use ($identityId, $busId) {
                        $q->where('driver_id', $identityId)
                          ->orWhere('bus_id', $busId);
                    })
                    ->where('status', 'active')
                    ->orderByDesc('started_at')
                    ->first();

                $routeName = null;
                $nextStop = null;
                $totalSeats = 0;
                $bookedSeats = 0;
                $scheduleStatus = 'Off Duty';

                if ($activeTrip) {
                    $scheduleStatus = 'On Route';
                    $route = \Illuminate\Support\Facades\DB::table('transport_bus_routes')
                        ->where('id', $activeTrip->route_id)
                        ->first();
                    $routeName = $route->display_name ?? $route->route_code ?? null;

                    $waypoints = is_string($activeTrip->waypoints ?? null)
                        ? json_decode($activeTrip->waypoints, true)
                        : ($activeTrip->waypoints ?? []);

                    $currentIdx = (int) ($activeTrip->current_waypoint_index ?? 0);
                    if (!empty($waypoints) && isset($waypoints[$currentIdx])) {
                        $nextStop = $waypoints[$currentIdx]['station'] ?? "Stop {$currentIdx}";
                    }

                    $totalSeats = \Illuminate\Support\Facades\DB::table('transport_seat_bookings')
                        ->where('trip_id', $activeTrip->id)
                        ->count();

                    $bookedSeats = \Illuminate\Support\Facades\DB::table('transport_seat_bookings')
                        ->where('trip_id', $activeTrip->id)
                        ->whereIn('status', ['confirmed', 'boarded'])
                        ->count();
                }

                return response()->json([
                    'success' => true,
                    'data' => [
                        'account_name'    => $identity->display_name ?? $identity->full_name ?? $user->account_name ?? 'Staff',
                        'full_name'       => $identity->display_name ?? $identity->full_name ?? null,
                        'role'            => $assignment->role,
                        'vehicle_plate'   => $plate,
                        'bus_id'          => $busId,
                        'carrier_company_id' => $assignment->carrier_company_id ?? null,
                        'active_route'     => $routeName ?? 'No active route',
                        'active_trip_id'  => $activeTrip->id ?? null,
                        'total_seats'     => $totalSeats,
                        'booked_seats'    => $bookedSeats,
                        'next_stop'       => $nextStop ?? '--',
                        'schedule_status' => $scheduleStatus,
                    ],
                ]);
            });

            Route::get('drivers', [\App\Http\Controllers\FleetStaffController::class, 'getDriversList']);
            Route::get('conductors', [\App\Http\Controllers\FleetStaffController::class, 'getConductorsList']);
            Route::get('plates', [\App\Http\Controllers\FleetStaffController::class, 'getBusPlates']);
        });

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

        Route::prefix('shifts')->group(function (): void {
            Route::post('save', [\App\Http\Controllers\BusShiftController::class, 'saveShiftRoster']);
            Route::get('{plate}', [\App\Http\Controllers\BusShiftController::class, 'getShiftRoster']);
        });

        Route::prefix('link-requests')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\FleetManagementController::class, 'listLinkRequests']);
            Route::post('{id}/accept', [\App\Http\Controllers\FleetManagementController::class, 'acceptLinkRequest']);
            Route::post('{id}/reject', [\App\Http\Controllers\FleetManagementController::class, 'rejectLinkRequest']);
            Route::post('{id}/hold', [\App\Http\Controllers\FleetManagementController::class, 'holdLinkRequest']);
        });

        Route::prefix('link-messages')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\FleetManagementController::class, 'listAllConversations']);
            Route::get('{assignmentId}', [\App\Http\Controllers\FleetManagementController::class, 'listMessages']);
            Route::post('{assignmentId}', [\App\Http\Controllers\FleetManagementController::class, 'sendMessage']);
        });
    });
