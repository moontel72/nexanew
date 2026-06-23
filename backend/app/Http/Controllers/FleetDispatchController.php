<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * NEXATRACE — FLEET DISPATCH CONTROLLER v2
 * =========================================
 *
 * Advanced Dispatch Engine supporting:
 *   - Multi-staff (relief driver + multi-conductor arrays)
 *   - Stop-specific shift handover (handover_stop_id)
 *   - Return trip separation (leg_type + parent_assignment_id)
 *   - Cross-vehicle multi-leg chaining (parent_assignment_id)
 *   - Staff timeline API (GET /dispatch/timeline)
 *   - Full edit capability (PUT updates any field)
 *
 * Routes:
 *   GET    /api/v1/bus-fleet/dispatch/assignments
 *   POST   /api/v1/bus-fleet/dispatch/assignments
 *   GET    /api/v1/bus-fleet/dispatch/assignments/{id}
 *   PUT    /api/v1/bus-fleet/dispatch/assignments/{id}
 *   DELETE /api/v1/bus-fleet/dispatch/assignments/{id}
 *   GET    /api/v1/bus-fleet/dispatch/resources
 *   GET    /api/v1/bus-fleet/dispatch/timeline
 *
 *   (mirrored under /api/v1/bus-owner/dispatch/*)
 */
class FleetDispatchController extends Controller
{
    private const VALID_SHIFTS = ['morning', 'evening', 'night', 'special'];
    private const VALID_STATUSES = ['active', 'completed', 'cancelled'];
    private const VALID_LEG_TYPES = ['outbound', 'inbound'];

    // ═══════════════════════════════════════════════════════════
    // LIST ASSIGNMENTS
    // ═══════════════════════════════════════════════════════════
    public function index(Request $request): JsonResponse
    {
        $date = $request->get('date', now()->toDateString());
        $shift = $request->get('shift_type');
        $status = $request->get('status', 'active');
        $driverId = $request->get('driver_id');

        $query = DB::table('fleet_dispatch_assignments AS fda')
            ->leftJoin('absolute_bus_layouts AS v', 'fda.vehicle_id', '=', 'v.id')
            ->leftJoin('transport_bus_routes AS r', 'fda.route_id', '=', 'r.id')
            ->leftJoin('fleet_assignments AS fa_drv', 'fda.driver_id', '=', 'fa_drv.id')
            ->leftJoin('global_identities AS gi_drv', 'fa_drv.global_identity_id', '=', 'gi_drv.id')
            ->leftJoin('fleet_assignments AS fa_rel', 'fda.relief_driver_id', '=', 'fa_rel.id')
            ->leftJoin('global_identities AS gi_rel', 'fa_rel.global_identity_id', '=', 'gi_rel.id')
            ->leftJoin('fleet_assignments AS fa_con', 'fda.conductor_id', '=', 'fa_con.id')
            ->leftJoin('global_identities AS gi_con', 'fa_con.global_identity_id', '=', 'gi_con.id')
            ->when($date, fn($q) => $q->where('fda.assignment_date', $date))
            ->when($status, fn($q) => $q->where('fda.status', $status))
            ->when($shift, fn($q) => $q->where('fda.shift_type', $shift))
            ->when($driverId, fn($q) => $q->where(function ($sq) use ($driverId) {
                $sq->where('fda.driver_id', $driverId)
                   ->orWhere('fda.relief_driver_id', $driverId);
            }))
            ->when($request->get('bus_company_id'),
                fn($q, $cid) => $q->where('fda.bus_company_id', $cid))
            ->select(
                'fda.id', 'fda.assignment_date', 'fda.shift_type', 'fda.status',
                'fda.leg_type', 'fda.parent_assignment_id', 'fda.departure_time',
                'fda.vehicle_id', 'v.display_name AS vehicle_name',
                'fda.route_id', 'r.display_name AS route_name', 'r.origin_city', 'r.destination_city',
                'fda.driver_id', 'gi_drv.display_name AS driver_name',
                'fda.relief_driver_id', 'gi_rel.display_name AS relief_driver_name',
                'fda.conductor_id', 'gi_con.display_name AS conductor_name',
                'fda.conductor_ids', 'fda.handover_stop_id',
                'fda.route_leg_start_stop_id', 'fda.route_leg_end_stop_id',
                'fda.created_at', 'fda.updated_at'
            )
            ->orderBy('fda.departure_time')
            ->orderBy('fda.shift_type')
            ->orderBy('fda.created_at', 'desc')
            ->get()
            ->map(function ($row) {
                // Decode JSONB conductor_ids array
                if (isset($row->conductor_ids) && is_string($row->conductor_ids)) {
                    $row->conductor_ids = json_decode($row->conductor_ids, true) ?? [];
                }
                return $row;
            });

        return response()->json([
            'success' => true,
            'data' => $query,
            'count' => $query->count(),
            'filters' => ['date' => $date, 'shift' => $shift, 'status' => $status, 'driver_id' => $driverId],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // STAFF TIMELINE (multi-leg, cross-vehicle chaining)
    // ═══════════════════════════════════════════════════════════
    public function timeline(Request $request): JsonResponse
    {
        $driverId = $request->get('driver_id');
        $date = $request->get('date', now()->toDateString());

        if (!$driverId) {
            return response()->json(['success' => false, 'message' => 'driver_id is required'], 422);
        }

        $assignments = DB::table('fleet_dispatch_assignments AS fda')
            ->leftJoin('absolute_bus_layouts AS v', 'fda.vehicle_id', '=', 'v.id')
            ->leftJoin('transport_bus_routes AS r', 'fda.route_id', '=', 'r.id')
            ->where('fda.assignment_date', $date)
            ->where('fda.status', 'active')
            ->where(function ($q) use ($driverId) {
                $q->where('fda.driver_id', $driverId)
                  ->orWhere('fda.relief_driver_id', $driverId);
            })
            ->select(
                'fda.id AS assignment_id',
                'fda.vehicle_id', 'v.display_name AS vehicle_name',
                'fda.route_id', 'r.display_name AS route_name',
                'fda.route_leg_start_stop_id', 'fda.route_leg_end_stop_id',
                'fda.departure_time', 'fda.shift_type', 'fda.leg_type',
                'fda.handover_stop_id',
                DB::raw("CASE WHEN fda.driver_id = '{$driverId}' THEN 'primary'
                             WHEN fda.relief_driver_id = '{$driverId}' THEN 'relief'
                             ELSE 'unknown' END AS staff_role"),
                'fda.status'
            )
            ->orderBy('fda.departure_time')
            ->get()
            ->map(function ($row) {
                return [
                    'assignment_id'   => $row->assignment_id,
                    'vehicle_id'      => $row->vehicle_id,
                    'vehicle_name'    => $row->vehicle_name,
                    'route_id'        => $row->route_id,
                    'route_name'      => $row->route_name,
                    'route_leg_start_stop_id' => $row->route_leg_start_stop_id,
                    'route_leg_end_stop_id'   => $row->route_leg_end_stop_id,
                    'departure_time'  => $row->departure_time,
                    'shift_type'      => $row->shift_type,
                    'leg_type'        => $row->leg_type,
                    'handover_stop_id'=> $row->handover_stop_id,
                    'staff_role'      => $row->staff_role,
                    'status'          => $row->status,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'driver_id' => $driverId,
                'date'      => $date,
                'timeline'  => $assignments,
            ],
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
            ->leftJoin('fleet_assignments AS fa_rel', 'fda.relief_driver_id', '=', 'fa_rel.id')
            ->leftJoin('global_identities AS gi_rel', 'fa_rel.global_identity_id', '=', 'gi_rel.id')
            ->leftJoin('fleet_assignments AS fa_con', 'fda.conductor_id', '=', 'fa_con.id')
            ->leftJoin('global_identities AS gi_con', 'fa_con.global_identity_id', '=', 'gi_con.id')
            ->where('fda.id', $id)
            ->select(
                'fda.*',
                'v.display_name AS vehicle_name',
                'r.display_name AS route_name', 'r.origin_city', 'r.destination_city',
                'gi_drv.display_name AS driver_name',
                'gi_rel.display_name AS relief_driver_name',
                'gi_con.display_name AS conductor_name'
            )
            ->first();

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Assignment not found'], 404);
        }

        // Decode JSONB fields
        if (isset($assignment->conductor_ids) && is_string($assignment->conductor_ids)) {
            $assignment->conductor_ids = json_decode($assignment->conductor_ids, true) ?? [];
        }

        return response()->json(['success' => true, 'data' => $assignment]);
    }

    // ═══════════════════════════════════════════════════════════
    // CREATE ASSIGNMENT (with conflict validation)
    // ═══════════════════════════════════════════════════════════
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'bus_company_id'        => ['sometimes', 'string', 'uuid'],
            'vehicle_id'            => ['required', 'string', 'uuid'],
            'route_id'              => ['required', 'string', 'uuid'],
            'driver_id'             => ['required', 'string', 'uuid'],
            'relief_driver_id'      => ['sometimes', 'nullable', 'string', 'uuid'],
            'conductor_id'          => ['sometimes', 'nullable', 'string', 'uuid'],
            'conductor_ids'         => ['sometimes', 'array'],
            'conductor_ids.*'       => ['string', 'uuid'],
            'handover_stop_id'      => ['sometimes', 'nullable', 'string', 'uuid'],
            'assignment_date'       => ['required', 'date'],
            'departure_time'        => ['sometimes', 'nullable', 'date_format:H:i'],
            'shift_type'            => ['required', Rule::in(self::VALID_SHIFTS)],
            'leg_type'              => ['sometimes', Rule::in(self::VALID_LEG_TYPES)],
            'parent_assignment_id'  => ['sometimes', 'nullable', 'string', 'uuid'],
            'route_leg_start_stop_id' => ['sometimes', 'nullable', 'string', 'uuid'],
            'route_leg_end_stop_id'   => ['sometimes', 'nullable', 'string', 'uuid'],
            'status'                => ['sometimes', Rule::in(self::VALID_STATUSES)],
            'create_return_trip'    => ['sometimes', 'boolean'],
        ]);

        $date = $validated['assignment_date'];
        $shift = $validated['shift_type'];
        $createReturn = $validated['create_return_trip'] ?? false;

        // ── Conflict Prevention ────────────────────────────
        $conflicts = $this->checkConflicts($validated, $date, $shift);
        if (!empty($conflicts)) {
            return response()->json([
                'success' => false, 'message' => 'Assignment conflict detected.', 'conflicts' => $conflicts,
            ], 409);
        }

        $conductorIds = $validated['conductor_ids'] ?? [];
        if (!empty($validated['conductor_id']) && !in_array($validated['conductor_id'], $conductorIds)) {
            $conductorIds[] = $validated['conductor_id'];
        }

        // ── Insert Outbound ─────────────────────────────────
        $outboundId = (string) Str::uuid();
        DB::table('fleet_dispatch_assignments')->insert([
            'id'                => $outboundId,
            'bus_company_id'    => $validated['bus_company_id'] ?? null,
            'vehicle_id'        => $validated['vehicle_id'],
            'route_id'          => $validated['route_id'],
            'driver_id'         => $validated['driver_id'],
            'relief_driver_id'  => $validated['relief_driver_id'] ?? null,
            'conductor_id'      => $validated['conductor_id'] ?? null,
            'conductor_ids'     => !empty($conductorIds) ? json_encode($conductorIds) : null,
            'handover_stop_id'  => $validated['handover_stop_id'] ?? null,
            'assignment_date'   => $date,
            'departure_time'    => $validated['departure_time'] ?? null,
            'shift_type'        => $shift,
            'leg_type'          => 'outbound',
            'parent_assignment_id' => $validated['parent_assignment_id'] ?? null,
            'route_leg_start_stop_id' => $validated['route_leg_start_stop_id'] ?? null,
            'route_leg_end_stop_id'   => $validated['route_leg_end_stop_id'] ?? null,
            'status'            => $validated['status'] ?? 'active',
            'created_at'        => now(),
            'updated_at'        => now(),
        ]);

        // ── Create Return Trip if requested ─────────────────
        $returnId = null;
        if ($createReturn) {
            $returnId = (string) Str::uuid();
            DB::table('fleet_dispatch_assignments')->insert([
                'id'                => $returnId,
                'bus_company_id'    => $validated['bus_company_id'] ?? null,
                'vehicle_id'        => $validated['vehicle_id'],
                'route_id'          => $validated['route_id'],
                'driver_id'         => $validated['return_driver_id'] ?? $validated['driver_id'],
                'relief_driver_id'  => $validated['return_relief_driver_id'] ?? null,
                'conductor_id'      => $validated['return_conductor_id'] ?? null,
                'conductor_ids'     => !empty($validated['return_conductor_ids']) ? json_encode($validated['return_conductor_ids']) : null,
                'handover_stop_id'  => $validated['handover_stop_id'] ?? null,
                'assignment_date'   => $date,
                'departure_time'    => $validated['return_departure_time'] ?? null,
                'shift_type'        => $shift,
                'leg_type'          => 'inbound',
                'parent_assignment_id' => $outboundId,
                'status'            => 'active',
                'created_at'        => now(),
                'updated_at'        => now(),
            ]);
        }

        $data = $this->show($outboundId)->getData(true)['data'] ?? null;

        return response()->json([
            'success' => true,
            'message' => $createReturn ? 'Outbound + return trip assignments created.' : 'Dispatch assignment created.',
            'data' => $data,
            'return_trip_id' => $returnId,
        ], 201);
    }

    // ═══════════════════════════════════════════════════════════
    // UPDATE ASSIGNMENT (full edit — Feature 1)
    // ═══════════════════════════════════════════════════════════
    public function update(Request $request, string $id): JsonResponse
    {
        $existing = DB::table('fleet_dispatch_assignments')->where('id', $id)->first();
        if (!$existing) {
            return response()->json(['success' => false, 'message' => 'Assignment not found'], 404);
        }

        $validated = $request->validate([
            'vehicle_id'            => ['sometimes', 'string', 'uuid'],
            'route_id'              => ['sometimes', 'string', 'uuid'],
            'driver_id'             => ['sometimes', 'string', 'uuid'],
            'relief_driver_id'      => ['sometimes', 'nullable', 'string', 'uuid'],
            'conductor_id'          => ['sometimes', 'nullable', 'string', 'uuid'],
            'conductor_ids'         => ['sometimes', 'array'],
            'conductor_ids.*'       => ['string', 'uuid'],
            'handover_stop_id'      => ['sometimes', 'nullable', 'string', 'uuid'],
            'departure_time'        => ['sometimes', 'nullable', 'date_format:H:i'],
            'shift_type'            => ['sometimes', Rule::in(self::VALID_SHIFTS)],
            'leg_type'              => ['sometimes', Rule::in(self::VALID_LEG_TYPES)],
            'status'                => ['sometimes', Rule::in(self::VALID_STATUSES)],
            'route_leg_start_stop_id' => ['sometimes', 'nullable', 'string', 'uuid'],
            'route_leg_end_stop_id'   => ['sometimes', 'nullable', 'string', 'uuid'],
        ]);

        $updates = [];
        foreach (['vehicle_id', 'route_id', 'driver_id', 'relief_driver_id',
                   'handover_stop_id', 'departure_time', 'shift_type', 'leg_type',
                   'status', 'route_leg_start_stop_id', 'route_leg_end_stop_id'] as $field) {
            if (array_key_exists($field, $validated)) {
                $updates[$field] = $validated[$field];
            }
        }
        if (array_key_exists('conductor_id', $validated)) {
            $updates['conductor_id'] = $validated['conductor_id'];
        }
        if (array_key_exists('conductor_ids', $validated)) {
            $updates['conductor_ids'] = !empty($validated['conductor_ids'])
                ? json_encode($validated['conductor_ids']) : null;
        }
        if (!empty($updates)) {
            $updates['updated_at'] = now();
            DB::table('fleet_dispatch_assignments')->where('id', $id)->update($updates);
        }

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
    // DROPDOWN RESOURCES (with waypoints for handover stop)
    // ═══════════════════════════════════════════════════════════
    public function resources(Request $request): JsonResponse
    {
        $busCompanyId = $request->get('bus_company_id');
        $routeId = $request->get('route_id');

        $vehicles = DB::table('absolute_bus_layouts')
            ->where('layout_status', '!=', 'archived')
            ->when($busCompanyId && Schema::hasColumn('absolute_bus_layouts', 'carrier_company_id'),
                fn($q) => $q->where('carrier_company_id', $busCompanyId))
            ->select('id', 'display_name AS name')
            ->orderBy('display_name')
            ->get();

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

        // Waypoints for selected route (handover stop dropdown)
        $waypoints = [];
        if ($routeId && Schema::hasTable('transport_bus_route_waypoints')) {
            $waypoints = DB::table('transport_bus_route_waypoints')
                ->where('route_id', $routeId)
                ->select('id', 'station_name AS name', 'stop_order')
                ->orderBy('stop_order')
                ->get();
        }

        $drivers = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'driver')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active')
            ->when($busCompanyId, fn($q) => $q->where('fa.carrier_company_id', $busCompanyId))
            ->select('fa.id', 'gi.display_name AS name')
            ->orderBy('gi.display_name')
            ->get();

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
                'waypoints'  => $waypoints,
            ],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // CONFLICT CHECK HELPER
    // ═══════════════════════════════════════════════════════════
    private function checkConflicts(array $data, string $date, string $shift): array
    {
        $conflicts = [];
        $excludeId = $data['exclude_id'] ?? null;

        $vehicleQ = DB::table('fleet_dispatch_assignments')
            ->where('vehicle_id', $data['vehicle_id'])
            ->where('assignment_date', $date)
            ->where('shift_type', $shift)
            ->where('status', 'active');
        if ($excludeId) $vehicleQ->where('id', '!=', $excludeId);
        if ($vehicleQ->exists()) {
            $conflicts[] = 'Vehicle already assigned on ' . $date . ' (' . $shift . ' shift).';
        }

        if (!empty($data['driver_id'])) {
            $driverQ = DB::table('fleet_dispatch_assignments')
                ->where('driver_id', $data['driver_id'])
                ->where('assignment_date', $date)
                ->where('shift_type', $shift)
                ->where('status', 'active');
            if ($excludeId) $driverQ->where('id', '!=', $excludeId);
            if ($driverQ->exists()) {
                $conflicts[] = 'Driver already assigned on ' . $date . ' (' . $shift . ' shift).';
            }
        }

        if (!empty($data['relief_driver_id'])) {
            $relQ = DB::table('fleet_dispatch_assignments')
                ->where(function ($q) use ($data) {
                    $q->where('driver_id', $data['relief_driver_id'])
                      ->orWhere('relief_driver_id', $data['relief_driver_id']);
                })
                ->where('assignment_date', $date)
                ->where('shift_type', $shift)
                ->where('status', 'active');
            if ($excludeId) $relQ->where('id', '!=', $excludeId);
            if ($relQ->exists()) {
                $conflicts[] = 'Relief driver already assigned on ' . $date . ' (' . $shift . ' shift).';
            }
        }

        return $conflicts;
    }
}
