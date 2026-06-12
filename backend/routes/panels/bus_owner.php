<?php

use Illuminate\Support\Facades\Route;

/**
 * NEXATRACE — BUS OWNER APP ROUTES
 * ==================================
 *
 * Route prefix: /api/v1/bus-owner
 * Middleware:   auth:sanctum
 *
 * Independent bus owners manage their own drivers, conductors,
 * and seat layouts. All records are scoped to the authenticated
 * owner's global_identity_id so data stays modular and ready for
 * future multi-company linking.
 *
 * MODULES COVERED:
 *   - Module 14 (Bus Owners App) — Driver/Conductor/Seat Management
 */

Route::prefix('api/v1/bus-owner')
    ->middleware(['auth:sanctum'])
    ->group(function (): void {

        // ─── Owner Profile ──────────────────────────────────
        Route::get('profile', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;

            if (!$identityId) {
                return response()->json(['message' => 'No identity found for this account'], 404);
            }

            $tenant = \Illuminate\Support\Facades\DB::table('tenant_accounts')
                ->where('global_identity_id', $identityId)
                ->first();

            $fleetSize = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->where('layout_status', '!=', 'archived')
                ->count();

            $staffCount = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->where('carrier_company_id', $tenant->id ?? $identityId)
                ->where('fleet_type', 'bus')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'id'            => $tenant->id ?? $identityId,
                    'account_name'  => $tenant->account_name ?? $user->account_name ?? 'Bus Owner',
                    'email'         => $tenant->email ?? $user->email ?? '',
                    'phone'         => $tenant->phone_number ?? '',
                    'status'        => 'active',
                    'active_buses'  => $fleetSize,
                    'staff_count'   => $staffCount,
                ],
            ]);
        });

        // ─── Owner Dashboard Stats ──────────────────────────
        Route::get('dashboard', function (\Illuminate\Http\Request $request) {
            $user = $request->user();
            $identityId = $user->global_identity_id ?? null;
            $tenantId = \Illuminate\Support\Facades\DB::table('tenant_accounts')
                ->where('global_identity_id', $identityId)
                ->value('id') ?? $identityId;

            $fleetSize = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->where('layout_status', '!=', 'archived')
                ->count();

            $driverCount = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->where('carrier_company_id', $tenantId)
                ->where('fleet_type', 'bus')
                ->where('role', 'driver')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->count();

            $conductorCount = \Illuminate\Support\Facades\DB::table('fleet_assignments')
                ->where('carrier_company_id', $tenantId)
                ->where('fleet_type', 'bus')
                ->where('role', 'conductor')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->count();

            $layoutCount = \Illuminate\Support\Facades\DB::table('transport_bus_layouts')
                ->where('owner_identity_id', $identityId)
                ->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'company_name'    => $user->account_name ?? 'Bus Owner',
                    'fleet_size'      => $fleetSize,
                    'driver_count'    => $driverCount,
                    'conductor_count' => $conductorCount,
                    'layout_count'    => $layoutCount,
                    'active_routes'   => 0,
                    'total_trips'     => 0,
                    'active_trips'    => 0,
                ],
            ]);
        });

        // ─── Drivers CRUD ───────────────────────────────────
        Route::prefix('drivers')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\BusOwnerController::class, 'listDrivers']);
            Route::post('/', [\App\Http\Controllers\BusOwnerController::class, 'storeDriver']);
            Route::get('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'showDriver']);
            Route::put('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'updateDriver']);
            Route::delete('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'destroyDriver']);
        });

        // ─── Conductors CRUD ────────────────────────────────
        Route::prefix('conductors')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\BusOwnerController::class, 'listConductors']);
            Route::post('/', [\App\Http\Controllers\BusOwnerController::class, 'storeConductor']);
            Route::get('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'showConductor']);
            Route::put('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'updateConductor']);
            Route::delete('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'destroyConductor']);
        });

        // ─── Seat Layouts CRUD ──────────────────────────────
        Route::prefix('layouts')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\BusOwnerController::class, 'listLayouts']);
            Route::post('/', [\App\Http\Controllers\BusOwnerController::class, 'storeLayout']);
            Route::get('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'showLayout']);
            Route::put('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'updateLayout']);
            Route::post('/{id}/publish', [\App\Http\Controllers\BusOwnerController::class, 'publishLayout']);
            Route::delete('/{id}', [\App\Http\Controllers\BusOwnerController::class, 'destroyLayout']);
        });

        // ─── Layout Presets ─────────────────────────────────
        Route::get('layout-presets', [\App\Http\Controllers\BusOwnerController::class, 'layoutPresets']);

        // ─── Identity Portability — Link Request (§10.11.2) ──
        Route::get('available-companies', [\App\Http\Controllers\BusOwnerController::class, 'availableCompanies']);
        Route::prefix('link-request')->group(function (): void {
            Route::post('/', [\App\Http\Controllers\BusOwnerController::class, 'linkRequest']);
            Route::post('/{id}/cancel', [\App\Http\Controllers\BusOwnerController::class, 'cancelLinkRequest']);
            Route::post('/{id}/leave', [\App\Http\Controllers\BusOwnerController::class, 'leaveCarrier']);
        });
        Route::get('link-status', [\App\Http\Controllers\BusOwnerController::class, 'linkStatus']);

        // Link Messages — Persistent B2B Chat
        Route::prefix('link-messages')->group(function (): void {
            Route::get('/', [\App\Http\Controllers\BusOwnerController::class, 'listAllMessages']);
            Route::get('{assignmentId}', [\App\Http\Controllers\BusOwnerController::class, 'listMessages']);
            Route::post('{assignmentId}', [\App\Http\Controllers\BusOwnerController::class, 'sendMessage']);
        });
    });
