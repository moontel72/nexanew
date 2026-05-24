<?php

namespace App\Http\Controllers;

use App\Models\Driver;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — FLEET STAFF CONTROLLER
 * ====================================
 *
 * Serves dropdown lists for the Admin Panel's dynamic shift allocation form
 * (Setup 14).  Returns separate pools for Bus Drivers and Bus Conductors
 * filtered by staff_type.
 *
 * Routes: /api/v1/bus-fleet/staff/*
 */

class FleetStaffController extends Controller
{
    /**
     * GET /api/v1/bus-fleet/staff/drivers
     * Returns JSON array of all bus drivers.
     */
    public function getDriversList(Request $request): JsonResponse
    {
        $drivers = Driver::where('driver_type', 'bus')
            ->where('staff_type', 'driver')
            ->where('status', 'active')
            ->select('id', 'name', 'phone', 'license_number')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $drivers->map(fn ($d) => [
                'id' => (string) $d->id,
                'name' => $d->name,
                'phone' => $d->phone,
                'license' => $d->license_number,
            ]),
        ]);
    }

    /**
     * GET /api/v1/bus-fleet/staff/conductors
     * Returns JSON array of all bus conductors.
     */
    public function getConductorsList(Request $request): JsonResponse
    {
        $conductors = Driver::where('driver_type', 'bus')
            ->where('staff_type', 'conductor')
            ->where('status', 'active')
            ->select('id', 'name', 'phone')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $conductors->map(fn ($c) => [
                'id' => (string) $c->id,
                'name' => $c->name,
                'phone' => $c->phone,
            ]),
        ]);
    }

    /**
     * GET /api/v1/bus-fleet/staff/plates
     * Returns all registered bus number plates for the dropdown.
     */
    public function getBusPlates(Request $request): JsonResponse
    {
        $plates = \App\Models\Transport\BusLayout::select('bus_id')
            ->distinct()
            ->pluck('bus_id');

        return response()->json([
            'status' => 'success',
            'data' => $plates,
        ]);
    }
}
