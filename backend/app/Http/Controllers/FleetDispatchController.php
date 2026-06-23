<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * NEXATRACE — FLEET DISPATCH CONTROLLER
 * ======================================
 *
 * Centralized Live Dispatch & Duty Assignment engine.
 * Links vehicles, routes, drivers, and conductors on a daily/shift basis.
 * Resources are fully fluid — no resource is hardcoded to any route.
 *
 * Conflict Prevention:
 *   A vehicle/driver/conductor cannot be assigned to two active shifts
 *   on the same date + shift_type simultaneously.
 *
 * Routes:
 *   GET    /api/v1/bus-fleet/dispatch/assignments
 *   POST   /api/v1/bus-fleet/dispatch/assignments
 *   GET    /api/v1/bus-fleet/dispatch/assignments/{id}
 *   PUT    /api/v1/bus-fleet/dispatch/assignments/{id}
 *   DELETE /api/v1/bus-fleet/dispatch/assignments/{id}
 *   GET    /api/v1/bus-fleet/dispatch/resources
 *
 *   (mirrored under /api/v1/bus-owner/dispatch/*)
 */
class FleetDispatchController extends Controller
{
    private const VALID_SHIFTS = ['morning', 'evening', 'night', 'special'];
    private const VALID_STATUSES = ['active', 'completed', 'cancelled'];

    // ═══════════════════════════════════════════════════════════
    // LIST ASSIGNMENTS
    // ═══════════════════════════════════════════════════════════
    public function index(Request $request): JsonResponse
    {
        $date = $request->get('date', now()->toDateString());
        $shift = $request->get('shift_type');
        $status = $request->get('status', 'active');

        $query = DB::table('fleet_dispatch_assignments AS fda')
            ->leftJoin('absolute_bus_layouts AS v', 'fda.vehicle_id', '=', 'v.id')
            ->leftJoin('transport_bus_routes AS r', 'fda.route_id', '=', 'r.id')
            ->leftJoin('fleet_assignments AS fa_drv', 'fda.driver_id', '=', 'fa_drv.id')
            ->leftJoin('global_identities AS gi_drv', 'fa_drv.global_identity_id', '=', 'gi_drv.id')
            ->leftJoin('fleet_assignments AS fa_con', 'fda.conductor_id', '=', 'fa_con.id')
            ->leftJoin('global_identities AS gi_con', 'fa_con.global_identity_id', '=', 'gi_con.id')
            ->where('fda.assignment_date', $date)
            ->where('fda.status', $status)
            ->when($shift, fn($q) => $q->where('fda.shift_type', $shift))
            ->when($request->get('bus_company_id'),
                fn($q, $cid) => $q->where('fda.bus_company_id', $cid))
            ->select(
                'fda.id', 'fda.assignment_date', 'fda.shift_type', 'fda.status',
                'fda.vehicle_id', 'v.display_name AS vehicle_name',
                'fda.route_id', 'r.display_name AS route_name', 'r.origin_city', 'r.destination_city',
                'fda.driver_id', 'gi_drv.display_name AS driver_name',
                'fda.conductor_id', 'gi_con.display_name AS conductor_name',
                'fda.created_at', 'fda.updated_at'
            )
            ->orderBy('fda.shift_type')
            ->orderBy('fda.created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $query,
            'count' => $query->count(),
            'filters' => ['date' => $date, 'shift' => $shift, 'status' => $status],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // SHOW SINGLE ASSIGNMENT
    // ═══════════════════════════════════════════════════════════
    public function show(string $id): JsonResponse
    {
        $assignment = DB::table('fleet_dispatch_assignments AS fda')
            ->leftJoin('absolute_bus_layouts AS v', 'fda.vehicle_id', '=', 'v.id')
            ->leftJoin('transport_bus_routes AS r', 'fda.route_id', '=', 'r.id')
            ->leftJoin('fleet_assignments AS fa_drv', 'fda.driver_id', '=', 'fa_drv.id')
            ->leftJoin('global_identities AS gi_drv', 'fa_drv.global_identity_id', '=', 'gi_drv.id')
            ->leftJoin('fleet_assignments AS fa_con', 'fda.conductor_id', '=', 'fa_con.id')
            ->leftJoin('global_identities AS gi_con', 'fa_con.global_identity_id', '=', 'gi_con.id')
            ->where('fda.id', $id)
            ->select(
                'fda.*',
                'v.display_name AS vehicle_name',
                'r.display_name AS route_name', 'r.origin_city', 'r.destination_city',
                'gi_drv.display_name AS driver_name',
                'gi_con.display_name AS conductor_name'
            )
            ->first();

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Assignment not found'], 404);
        }

        return response()->json(['success' => true, 'data' => $assignment]);
    }

    // ═══════════════════════════════════════════════════════════
    // CREATE ASSIGNMENT (with conflict validation)
    // ═══════════════════════════════════════════════════════════
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'bus_company_id' => ['sometimes', 'string', 'uuid'],
            'vehicle_id'     => ['required', 'string', 'uuid'],
            'route_id'       => ['required', 'string', 'uuid'],
            'driver_id'      => ['required', 'string', 'uuid'],
            'conductor_id'   => ['sometimes', 'nullable', 'string', 'uuid'],
            'assignment_date'=> ['required', 'date'],
            'shift_type'     => ['required', Rule::in(self::VALID_SHIFTS)],
            'status'         => ['sometimes', Rule::in(self::VALID_STATUSES)],
        ]);

        $date = $validated['assignment_date'];
        $shift = $validated['shift_type'];

        // ── Conflict Prevention ────────────────────────────
        $conflicts = [];

        // Vehicle conflict
        $vehicleConflict = DB::table('fleet_dispatch_assignments')
            ->where('vehicle_id', $validated['vehicle_id'])
            ->where('assignment_date', $date)
            ->where('shift_type', $shift)
            ->where('status', 'active')
            ->exists();
        if ($vehicleConflict) {
            $conflicts[] = 'This vehicle is already assigned to an active route on ' . $date . ' (' . $shift . ' shift).';
        }

        // Driver conflict
        $driverConflict = DB::table('fleet_dispatch_assignments')
            ->where('driver_id', $validated['driver_id'])
            ->where('assignment_date', $date)
            ->where('shift_type', $shift)
            ->where('status', 'active')
            ->exists();
        if ($driverConflict) {
            $conflicts[] = 'This driver is already assigned to an active route on ' . $date . ' (' . $shift . ' shift).';
        }

        // Conductor conflict (if provided)
        if (!empty($validated['conductor_id'])) {
            $conductorConflict = DB::table('fleet_dispatch_assignments')
                ->where('conductor_id', $validated['conductor_id'])
                ->where('assignment_date', $date)
                ->where('shift_type', $shift)
                ->where('status', 'active')
                ->exists();
            if ($conductorConflict) {
                $conflicts[] = 'This conductor is already assigned to an active route on ' . $date . ' (' . $shift . ' shift).';
            }
        }

        if (!empty($conflicts)) {
            return response()->json([
                'success' => false,
                'message' => 'Assignment conflict detected.',
                'conflicts' => $conflicts,
            ], 409);
        }

        // ── Insert ─────────────────────────────────────────
        $id = (string) Str::uuid();
        DB::table('fleet_dispatch_assignments')->insert([
            'id'              => $id,
            'bus_company_id'  => $validated['bus_company_id'] ?? null,
            'vehicle_id'      => $validated['vehicle_id'],
            'route_id'        => $validated['route_id'],
            'driver_id'       => $validated['driver_id'],
            'conductor_id'    => $validated['conductor_id'] ?? null,
            'assignment_date' => $date,
            'shift_type'      => $shift,
            'status'          => $validated['status'] ?? 'active',
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        $assignment = $this->show($id);
        $data = $assignment->getData(true)['data'] ?? null;

        return response()->json([
            'success' => true,
            'message' => 'Dispatch assignment created.',
            'data' => $data,
        ], 201);
    }

    // ═══════════════════════════════════════════════════════════
    // UPDATE ASSIGNMENT
    // ═══════════════════════════════════════════════════════════
    public function update(Request $request, string $id): JsonResponse
    {
        $existing = DB::table('fleet_dispatch_assignments')->where('id', $id)->first();
        if (!$existing) {
            return response()->json(['success' => false, 'message' => 'Assignment not found'], 404);
        }

        $validated = $request->validate([
            'status'       => ['sometimes', Rule::in(self::VALID_STATUSES)],
            'shift_type'   => ['sometimes', Rule::in(self::VALID_SHIFTS)],
            'conductor_id' => ['sometimes', 'nullable', 'string', 'uuid'],
        ]);

        $updates = [];
        if (isset($validated['status'])) $updates['status'] = $validated['status'];
        if (isset($validated['shift_type'])) $updates['shift_type'] = $validated['shift_type'];
        if (array_key_exists('conductor_id', $validated)) $updates['conductor_id'] = $validated['conductor_id'];
        $updates['updated_at'] = now();

        DB::table('fleet_dispatch_assignments')->where('id', $id)->update($updates);

        return response()->json([
            'success' => true,
            'message' => 'Assignment updated.',
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // DELETE / CANCEL ASSIGNMENT
    // ═══════════════════════════════════════════════════════════
    public function destroy(string $id): JsonResponse
    {
        $existing = DB::table('fleet_dispatch_assignments')->where('id', $id)->first();
        if (!$existing) {
            return response()->json(['success' => false, 'message' => 'Assignment not found'], 404);
        }

        DB::table('fleet_dispatch_assignments')
            ->where('id', $id)
            ->update(['status' => 'cancelled', 'updated_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Assignment cancelled.',
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // DROPDOWN RESOURCES (for the assignment form)
    // ═══════════════════════════════════════════════════════════
    public function resources(Request $request): JsonResponse
    {
        $busCompanyId = $request->get('bus_company_id');

        // Vehicles (from absolute_bus_layouts)
        $vehicles = DB::table('absolute_bus_layouts')
            ->where('layout_status', '!=', 'archived')
            ->when($busCompanyId && Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id'),
                fn($q) => $q->where('carrier_company_id', $busCompanyId))
            ->select('id', 'display_name AS name')
            ->orderBy('display_name')
            ->get();

        // Routes
        $routes = DB::table('transport_bus_routes')
            ->where('status', 'published')
            ->select('id', 'display_name AS name', 'origin_city', 'destination_city')
            ->orderBy('display_name')
            ->get()
            ->map(fn($r) => [
                'id' => $r->id,
                'name' => $r->name,
                'description' => ($r->origin_city ?? 'Origin') . ' → ' . ($r->destination_city ?? 'Dest'),
            ]);

        // Drivers (active, bus fleet)
        $drivers = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'driver')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active')
            ->when($busCompanyId, fn($q) => $q->where('fa.carrier_company_id', $busCompanyId))
            ->select('fa.id', 'gi.display_name AS name')
            ->orderBy('gi.display_name')
            ->get();

        // Conductors (active, bus fleet)
        $conductors = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'conductor')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active')
            ->when($busCompanyId, fn($q) => $q->where('fa.carrier_company_id', $busCompanyId))
            ->select('fa.id', 'gi.display_name AS name')
            ->orderBy('gi.display_name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'vehicles'   => $vehicles,
                'routes'     => $routes,
                'drivers'    => $drivers,
                'conductors' => $conductors,
            ],
        ]);
    }
}
