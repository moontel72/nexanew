<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * NEXATRACE — BUS SHIFT CONTROLLER
 * =================================
 *
 * Processes the dynamic multi-staff shift allocation form submissions
 * from the Flutter Admin Panel (Setup 14).
 *
 * saveShiftRoster(): validates bus plate + shift, performs UPSERT on
 * driver_ids and conductor_ids JSONB arrays.  The roster remains fixed
 * for that bus plate until an admin explicitly overrides it.
 *
 * Routes: /api/v1/bus-fleet/shifts/*
 */

class BusShiftController extends Controller
{
    /**
     * POST /api/v1/bus-fleet/shifts/save
     *
     * Body: {
     *   "bus_number_plate": "LES-26-4592",
     *   "shift_type": "morning",
     *   "driver_ids": ["uuid-1", "uuid-2"],
     *   "conductor_ids": ["uuid-3"]
     * }
     */
    public function saveShiftRoster(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'bus_number_plate' => ['required', 'string', 'max:32'],
            'shift_type' => ['required', Rule::in(['morning', 'evening', 'night'])],
            'driver_ids' => ['required', 'array'],
            'driver_ids.*' => ['string', 'uuid'],
            'conductor_ids' => ['sometimes', 'array'],
            'conductor_ids.*' => ['string', 'uuid'],
        ]);

        $plate = $validated['bus_number_plate'];
        $shift = $validated['shift_type'];
        $driverIds = json_encode($validated['driver_ids']);
        $conductorIds = json_encode($validated['conductor_ids'] ?? []);

        $companyId = $request->user()->company_id
            ?? $request->user()->id;

        // ── Upsert: update if exists, insert if new ──────────────
        DB::table('bus_shift_allocations')->updateOrInsert(
            [
                'bus_number_plate' => $plate,
                'shift_type' => $shift,
            ],
            [
                'id' => (string) Str::uuid(),
                'driver_ids' => DB::raw("'{$driverIds}'::jsonb"),
                'conductor_ids' => DB::raw("'{$conductorIds}'::jsonb"),
                'company_id' => $companyId,
                'updated_at' => now(),
                'created_at' => DB::raw('COALESCE(created_at, NOW())'),
            ]
        );

        return response()->json([
            'status' => 'success',
            'message' => "Shift roster saved for {$plate} ({$shift})",
            'data' => [
                'bus_number_plate' => $plate,
                'shift_type' => $shift,
                'driver_ids' => $validated['driver_ids'],
                'conductor_ids' => $validated['conductor_ids'] ?? [],
            ],
        ], 200);
    }

    /**
     * GET /api/v1/bus-fleet/shifts/{plate}
     *
     * Returns the currently assigned roster for a given bus plate.
     */
    public function getShiftRoster(string $plate): JsonResponse
    {
        $rosters = DB::table('bus_shift_allocations')
            ->where('bus_number_plate', $plate)
            ->get();

        if ($rosters->isEmpty()) {
            return response()->json([
                'status' => 'success',
                'data' => [],
                'message' => 'No shift roster found for this plate.',
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data' => $rosters->map(fn ($r) => [
                'id' => $r->id,
                'bus_number_plate' => $r->bus_number_plate,
                'shift_type' => $r->shift_type,
                'driver_ids' => json_decode($r->driver_ids, true),
                'conductor_ids' => json_decode($r->conductor_ids, true),
                'last_updated' => $r->updated_at,
            ]),
        ]);
    }
}
