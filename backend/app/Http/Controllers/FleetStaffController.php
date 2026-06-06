<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — FLEET STAFF CONTROLLER (v2 — Identity Spine)
 * =========================================================
 *
 * Serves dropdown lists for the Admin Panel's dynamic shift allocation form.
 * Queries fleet_assignments JOIN global_identities instead of the
 * deprecated legacy Driver model/drivers table.
 *
 * Routes: /api/v1/bus-fleet/staff/*
 */

class FleetStaffController extends Controller
{
    /**
     * GET /api/v1/bus-fleet/staff/drivers
     * Returns JSON array of all active bus drivers.
     */
    public function getDriversList(Request $request): JsonResponse
    {
        $drivers = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'driver')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active')
            ->select(
                'fa.id',
                'gi.display_name AS name',
                'fa.assignment_meta',
            )
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
     * Returns JSON array of all active bus conductors.
     */
    public function getConductorsList(Request $request): JsonResponse
    {
        $conductors = DB::table('fleet_assignments AS fa')
            ->join('global_identities AS gi', 'fa.global_identity_id', '=', 'gi.id')
            ->where('fa.role', 'conductor')
            ->where('fa.fleet_type', 'bus')
            ->where('fa.status', 'active')
            ->select(
                'fa.id',
                'gi.display_name AS name',
                'fa.assignment_meta',
            )
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
        $plates = DB::table('transport_bus_layouts')
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
