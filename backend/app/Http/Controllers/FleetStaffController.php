<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — FLEET STAFF CONTROLLER (v2 — Identity Spine)
 * =========================================================
 *
 * Serves driver/conductor/plate lists for the Bus-Fleet Admin Panel.
 * Queries fleet_assignments JOIN global_identities.
 *
 * Scoped to the carrier company via _carrier_company_id injected by
 * BusFleetGate middleware.  Also includes drivers from linked owners
 * whose carrier_company_id matches a link from this fleet company.
 *
 * Routes: /api/v1/bus-fleet/staff/*
 */

class FleetStaffController extends Controller
{
    /**
     * Resolve the carrier company ID for scoping queries.
     * Set by BusFleetGate middleware, or resolved from the authenticated user.
     */
    private function carrierId(Request $request): ?string
    {
        return $request->get('_carrier_company_id')
            ?? DB::table('fleet_assignments')
                ->where('global_identity_id', $request->user()?->global_identity_id)
                ->where('fleet_type', 'bus')
                ->whereIn('status', ['active', 'pending_acceptance'])
                ->value('carrier_company_id');
    }

    /**
     * GET /api/v1/bus-fleet/staff/drivers
     * Returns active bus drivers scoped to the fleet company AND its linked owners.
     */
    public function getDriversList(Request $request): JsonResponse
    {
        $carrierId = $this->carrierId($request);

        $query = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'driver')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active');

        if ($carrierId) {
            // Include drivers belonging to this fleet company AND drivers of
            // owners linked to this fleet (via accepted fleet_assignments where
            // the linked owner's carrier_company_id is in scope).
            $linkedOwnerIds = DB::table('fleet_assignments')
                ->where('carrier_company_id', $carrierId)
                ->where('fleet_type', 'bus')
                ->where('role', 'owner')
                ->where('status', 'active')
                ->pluck('carrier_company_id')
                ->unique()
                ->values()
                ->toArray();

            // Always include the fleet company's own ID.
            $scopedIds = array_merge([$carrierId], $linkedOwnerIds);

            $query->whereIn('fa.carrier_company_id', $scopedIds);
        }

        $drivers = $query
            ->select('fa.id', 'gi.display_name AS name', 'fa.assignment_meta', 'fa.carrier_company_id')
            ->get()
            ->map(function ($d) {
                $meta = json_decode($d->assignment_meta ?? '{}', true) ?: [];
                return [
                    'id'      => (string) $d->id,
                    'name'    => $d->name ?? '—',
                    'phone'   => $meta['phone'] ?? null,
                    'license' => $meta['license_number'] ?? null,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data'   => $drivers,
        ]);
    }

    /**
     * GET /api/v1/bus-fleet/staff/conductors
     * Returns active bus conductors scoped to the fleet company.
     */
    public function getConductorsList(Request $request): JsonResponse
    {
        $carrierId = $this->carrierId($request);

        $query = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'conductor')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active');

        if ($carrierId) {
            $linkedOwnerIds = DB::table('fleet_assignments')
                ->where('carrier_company_id', $carrierId)
                ->where('fleet_type', 'bus')
                ->where('role', 'owner')
                ->where('status', 'active')
                ->pluck('carrier_company_id')
                ->unique()
                ->values()
                ->toArray();

            $scopedIds = array_merge([$carrierId], $linkedOwnerIds);
            $query->whereIn('fa.carrier_company_id', $scopedIds);
        }

        $conductors = $query
            ->select('fa.id', 'gi.display_name AS name', 'fa.assignment_meta')
            ->get()
            ->map(function ($c) {
                $meta = json_decode($c->assignment_meta ?? '{}', true) ?: [];
                return [
                    'id'    => (string) $c->id,
                    'name'  => $c->name ?? '—',
                    'phone' => $meta['phone'] ?? null,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data'   => $conductors,
        ]);
    }

    /**
     * GET /api/v1/bus-fleet/staff/plates
     * Returns all registered bus number plates from layouts.
     */
    public function getBusPlates(Request $request): JsonResponse
    {
        $plates = DB::table('absolute_bus_layouts')
            ->select('display_name', 'id')
            ->where('layout_status', '!=', 'archived')
            ->orderBy('display_name')
            ->get()
            ->map(fn ($l) => [
                'id'   => $l->id,
                'name' => $l->display_name ?? 'Unnamed Layout',
            ]);

        return response()->json([
            'status' => 'success',
            'data'   => $plates,
        ]);
    }
}
