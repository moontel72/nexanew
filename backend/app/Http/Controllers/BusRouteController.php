<?php

namespace App\Http\Controllers;

use App\Models\Transport\BusRoute;
use App\Models\Transport\BusRouteWaypoint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BUS ROUTE CONTROLLER
 * ==================================
 *
 * Full CRUD for transit routes and their ordered waypoints.
 * Supports Module 13B (Route Scheduler), 15A (Driver Manifest),
 * and 8V (Customer Tracking).
 *
 * ROUTES (registered in routes/panels/bus_fleet.php):
 *   GET    /api/v1/bus-fleet/routes
 *   POST   /api/v1/bus-fleet/routes
 *   GET    /api/v1/bus-fleet/routes/{id}
 *   PUT    /api/v1/bus-fleet/routes/{id}
 *   DELETE /api/v1/bus-fleet/routes/{id}
 *   POST   /api/v1/bus-fleet/routes/{id}/publish
 *   POST   /api/v1/bus-fleet/routes/{id}/waypoints
 *   GET    /api/v1/bus-fleet/routes/{id}/waypoints
 */

class BusRouteController extends Controller
{
    // ── ROUTE CRUD ──────────────────────────────────────

    public function index(Request $request): JsonResponse
    {
        $carrierId = $request->get('_carrier_company_id');
        $query = BusRoute::with('waypoints');
        $user = $request->user();
        $panelPrefix = $request->route()->getPrefix();

        // Bus-owner panel: filter by owner_identity_id
        if (str_contains($panelPrefix, 'bus-owner')) {
            $ownerIdentityId = $user->global_identity_id ?? null;
            if ($ownerIdentityId) {
                $query->forOwner($ownerIdentityId);
            }
        } elseif ($carrierId) {
            // Bus-fleet panel: filter by carrier_company_id
            $query->forCarrier($carrierId);
        }

        $routes = $query->latest()->get();

        // Collect all route IDs for batch pivot lookups
        $routeIds = $routes->pluck('id')->toArray();

        // Batch-fetch assigned vouchers
        $assignedVouchers = collect();
        $assignedBonuses = collect();

        if (!empty($routeIds)) {
            if (Schema::hasTable('route_assigned_vouchers') && Schema::hasTable('bus_vouchers')) {
                $voucherRows = DB::table('route_assigned_vouchers')
                    ->whereIn('route_id', $routeIds)
                    ->get();
                $voucherIds = $voucherRows->pluck('voucher_id')->unique()->toArray();
                $vouchersById = !empty($voucherIds)
                    ? DB::table('bus_vouchers')->whereIn('id', $voucherIds)->get()->keyBy('id')
                    : collect();
                $assignedVouchers = $voucherRows->groupBy('route_id')->map(function ($rows) use ($vouchersById) {
                    return $rows->map(function ($r) use ($vouchersById) {
                        $v = $vouchersById->get($r->voucher_id);
                        return $v ? ['id' => $v->id, 'title' => $v->title ?? '', 'code' => $v->code ?? ''] : null;
                    })->filter()->values();
                });
            }

            if (Schema::hasTable('route_assigned_bonuses') && Schema::hasTable('staff_bonuses')) {
                $bonusRows = DB::table('route_assigned_bonuses')
                    ->whereIn('route_id', $routeIds)
                    ->get();
                $bonusIds = $bonusRows->pluck('bonus_id')->unique()->toArray();
                $bonusesById = !empty($bonusIds)
                    ? DB::table('staff_bonuses')->whereIn('id', $bonusIds)->get()->keyBy('id')
                    : collect();
                $assignedBonuses = $bonusRows->groupBy('route_id')->map(function ($rows) use ($bonusesById) {
                    return $rows->map(function ($r) use ($bonusesById) {
                        $b = $bonusesById->get($r->bonus_id);
                        return $b ? [
                            'id' => $b->id,
                            'bonus_name' => $b->bonus_name ?? '',
                            'staff_type' => $b->staff_type ?? '',
                            'bonus_category' => $b->bonus_category ?? '',
                        ] : null;
                    })->filter()->values();
                });
            }
        }

        // Compute total_km: always from consecutive segments (i → i+1)
        // Never trust the stored total_distance_km — it may be inflated
        // from an old publish() that summed all combinatorial rows.
        $routes->transform(function ($route) use ($assignedVouchers, $assignedBonuses) {
            $km = DB::table('route_segment_prices')
                ->where('route_id', $route->id)
                ->whereRaw('to_stop_order = from_stop_order + 1')
                ->sum('distance_km');
            // If no pricing data, fall back to stored value
            if (empty($km) || $km <= 0) {
                $km = $route->total_distance_km;
            }
            $route->total_km = round((float) $km, 2);
            $route->assigned_vouchers = $assignedVouchers->get($route->id, collect())->values();
            $route->assigned_bonuses = $assignedBonuses->get($route->id, collect())->values();
            return $route;
        });

        return response()->json([
            'success' => true,
            'data' => $routes,
            'count' => $routes->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $carrierId = $request->get('_carrier_company_id');
        $user = $request->user();
        $panelPrefix = $request->route()->getPrefix();
        $ownerIdentityId = null;

        // Bus-owner panel: auto-assign owner_identity_id
        if (str_contains($panelPrefix, 'bus-owner')) {
            $ownerIdentityId = $user->global_identity_id ?? null;
        }

        $data = $request->validate([
            'route_code' => ['required', 'string', 'max:50', 'unique:transport_bus_routes,route_code'],
            'display_name' => ['required', 'string', 'max:255'],
            'origin_city' => ['required', 'string', 'max:100'],
            'destination_city' => ['required', 'string', 'max:100'],
            'origin_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'origin_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'destination_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'destination_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'voucher_id' => ['nullable', 'string'],
            'voucher_ids' => ['nullable', 'array'],
            'voucher_ids.*' => ['string'],
            'driver_bonus_id' => ['nullable', 'string'],
            'conductor_bonus_id' => ['nullable', 'string'],
            'bonus_ids' => ['nullable', 'array'],
            'bonus_ids.*' => ['string'],
            'meta' => ['nullable', 'array'],
        ]);

        // Resolve voucher_ids: prefer array, fall back to single legacy FK
        $voucherIds = $data['voucher_ids'] ?? null;
        if (empty($voucherIds) && !empty($data['voucher_id'] ?? null)) {
            $voucherIds = [$data['voucher_id']];
        }

        // Resolve bonus_ids: prefer array, merge legacy single FKs
        $bonusIds = $data['bonus_ids'] ?? null;
        if (empty($bonusIds)) {
            $bonusIds = [];
            if (!empty($data['driver_bonus_id'] ?? null)) {
                $bonusIds[] = $data['driver_bonus_id'];
            }
            if (!empty($data['conductor_bonus_id'] ?? null)) {
                $bonusIds[] = $data['conductor_bonus_id'];
            }
            if (empty($bonusIds)) {
                $bonusIds = null;
            }
        }

        $routeId = (string) Str::uuid();

        $route = BusRoute::create([
            'id' => $routeId,
            'route_code' => strtoupper($data['route_code']),
            'display_name' => $data['display_name'],
            'origin_city' => $data['origin_city'],
            'destination_city' => $data['destination_city'],
            'origin_lat' => $data['origin_lat'] ?? 0,
            'origin_lng' => $data['origin_lng'] ?? 0,
            'destination_lat' => $data['destination_lat'] ?? 0,
            'destination_lng' => $data['destination_lng'] ?? 0,
            'carrier_company_id' => $carrierId,
            'owner_identity_id' => $ownerIdentityId,
            'voucher_id' => $data['voucher_id'] ?? null,
            'driver_bonus_id' => $data['driver_bonus_id'] ?? null,
            'conductor_bonus_id' => $data['conductor_bonus_id'] ?? null,
            'status' => BusRoute::STATUS_DRAFT,
        ]);

        // Sync pivot tables
        \App\Services\SchemaBootstrapService::ensureColumns();
        $now = now();

        if (!empty($voucherIds)) {
            $voucherInserts = array_map(fn($vid) => [
                'route_id' => $routeId,
                'voucher_id' => $vid,
                'created_at' => $now,
            ], $voucherIds);
            DB::table('route_assigned_vouchers')->insert($voucherInserts);
        }

        if (!empty($bonusIds)) {
            $bonusInserts = array_map(fn($bid) => [
                'route_id' => $routeId,
                'bonus_id' => $bid,
                'created_at' => $now,
            ], $bonusIds);
            DB::table('route_assigned_bonuses')->insert($bonusInserts);
        }

        // Attach pivot data to response
        $route->voucher_ids = $voucherIds ?? [];
        $route->bonus_ids = $bonusIds ?? [];
        $route->load('waypoints');

        return response()->json(['success' => true, 'data' => $route], 201);
    }

    public function show(string $id): JsonResponse
    {
        $route = BusRoute::with('waypoints')->findOrFail($id);

        // Attach voucher_ids and bonus_ids from pivot tables
        $voucherIds = DB::table('route_assigned_vouchers')
            ->where('route_id', $id)
            ->pluck('voucher_id')
            ->toArray();
        $bonusIds = DB::table('route_assigned_bonuses')
            ->where('route_id', $id)
            ->pluck('bonus_id')
            ->toArray();

        $route->voucher_ids = $voucherIds;
        $route->bonus_ids = $bonusIds;

        // Attach voucher/bonus display info
        $route->assigned_vouchers = !empty($voucherIds)
            ? DB::table('bus_vouchers')->whereIn('id', $voucherIds)
                ->get(['id', 'title', 'code'])->toArray()
            : [];

        $route->assigned_bonuses = !empty($bonusIds)
            ? DB::table('staff_bonuses')->whereIn('id', $bonusIds)
                ->get(['id', 'bonus_name', 'staff_type', 'bonus_category'])->toArray()
            : [];

        return response()->json(['success' => true, 'data' => $route]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $route = BusRoute::findOrFail($id);

        if ($route->isPublished()) {
            return response()->json([
                'success' => false,
                'message' => 'Published routes cannot be modified. Archive and clone instead.',
            ], 422);
        }

        $data = $request->validate([
            'route_code' => ['sometimes', 'string', 'max:50', "unique:transport_bus_routes,route_code,{$id}"],
            'display_name' => ['sometimes', 'string', 'max:255'],
            'origin_city' => ['sometimes', 'string', 'max:100'],
            'destination_city' => ['sometimes', 'string', 'max:100'],
            'origin_lat' => ['sometimes', 'numeric'],
            'origin_lng' => ['sometimes', 'numeric'],
            'destination_lat' => ['sometimes', 'numeric'],
            'destination_lng' => ['sometimes', 'numeric'],
            'meta' => ['nullable', 'array'],
            'voucher_id' => ['sometimes', 'nullable', 'string'],
            'voucher_ids' => ['sometimes', 'nullable', 'array'],
            'voucher_ids.*' => ['string'],
            'driver_bonus_id' => ['sometimes', 'nullable', 'string'],
            'conductor_bonus_id' => ['sometimes', 'nullable', 'string'],
            'bonus_ids' => ['sometimes', 'nullable', 'array'],
            'bonus_ids.*' => ['string'],
        ]);

        // Resolve voucher_ids: prefer array, fall back to single legacy FK
        $voucherIds = $data['voucher_ids'] ?? null;
        $hasVoucherIds = array_key_exists('voucher_ids', $data);
        if (!$hasVoucherIds && array_key_exists('voucher_id', $data)) {
            $voucherIds = !empty($data['voucher_id']) ? [$data['voucher_id']] : [];
            $hasVoucherIds = true;
        }

        // Resolve bonus_ids: prefer array, merge legacy single FKs
        $bonusIds = $data['bonus_ids'] ?? null;
        $hasBonusIds = array_key_exists('bonus_ids', $data);
        if (!$hasBonusIds && (array_key_exists('driver_bonus_id', $data) || array_key_exists('conductor_bonus_id', $data))) {
            $bonusIds = array_filter([
                $data['driver_bonus_id'] ?? null,
                $data['conductor_bonus_id'] ?? null,
            ]);
            $hasBonusIds = true;
        }

        // Ensure the FK columns exist before writing (failsafe for prod)
        \App\Services\SchemaBootstrapService::ensureColumns();

        $updateData = collect($data)
            ->except(['voucher_ids', 'bonus_ids'])
            ->toArray();

        $route->update($updateData);

        // Sync pivot tables in a transaction
        if ($hasVoucherIds || $hasBonusIds) {
            DB::transaction(function () use ($id, $voucherIds, $hasVoucherIds, $bonusIds, $hasBonusIds) {
                $now = now();

                if ($hasVoucherIds) {
                    DB::table('route_assigned_vouchers')->where('route_id', $id)->delete();
                    if (!empty($voucherIds)) {
                        $voucherInserts = array_map(fn($vid) => [
                            'route_id' => $id,
                            'voucher_id' => $vid,
                            'created_at' => $now,
                        ], $voucherIds);
                        DB::table('route_assigned_vouchers')->insert($voucherInserts);
                    }
                }

                if ($hasBonusIds) {
                    DB::table('route_assigned_bonuses')->where('route_id', $id)->delete();
                    if (!empty($bonusIds)) {
                        $bonusInserts = array_map(fn($bid) => [
                            'route_id' => $id,
                            'bonus_id' => $bid,
                            'created_at' => $now,
                        ], $bonusIds);
                        DB::table('route_assigned_bonuses')->insert($bonusInserts);
                    }
                }
            });
        }

        $route = $route->fresh('waypoints');

        return response()->json(['success' => true, 'data' => $route]);
    }

    public function destroy(string $id): JsonResponse
    {
        $route = BusRoute::findOrFail($id);
        $route->delete();

        return response()->json(['success' => true, 'message' => 'Route deleted']);
    }

    // ── PUBLISH ─────────────────────────────────────────

    public function publish(string $id): JsonResponse
    {
        $route = BusRoute::with('waypoints')->findOrFail($id);

        if ($route->waypoints->count() < 2) {
            return response()->json([
                'success' => false,
                'message' => 'Route must have at least 2 waypoints (origin + destination) to publish.',
            ], 422);
        }

        // Compute distance from Haversine (or fallback to pricing data)
        $totalKm = 0;
        $waypoints = $route->waypoints;
        for ($i = 1; $i < $waypoints->count(); $i++) {
            $totalKm += $this->haversineKm(
                $waypoints[$i - 1]->lat, $waypoints[$i - 1]->lng,
                $waypoints[$i]->lat, $waypoints[$i]->lng,
            );
        }

        // Fallback: sum distance_km from CONSECUTIVE segment prices only
        // (NOT all combinatorial rows — that would inflate the total)
        if ($totalKm <= 0) {
            $totalKm = DB::table('route_segment_prices')
                ->where('route_id', $id)
                ->whereRaw('to_stop_order = from_stop_order + 1')
                ->sum('distance_km');
        }

        $route->update([
            'status' => BusRoute::STATUS_PUBLISHED,
            'total_distance_km' => round($totalKm, 2),
            'estimated_duration_min' => (int) round(($totalKm / 60) * 60),
        ]);

        return response()->json(['success' => true, 'data' => $route->fresh('waypoints')]);
    }

    // ── UNPUBLISH ────────────────────────────────────────

    public function unpublish(string $id): JsonResponse
    {
        $route = BusRoute::findOrFail($id);

        if (! $route->isPublished()) {
            return response()->json([
                'success' => false,
                'message' => 'Route is not published.',
            ], 422);
        }

        $route->update(['status' => BusRoute::STATUS_DRAFT]);

        return response()->json([
            'success' => true,
            'message' => 'Route unpublished. You can now edit it.',
            'data' => $route->fresh('waypoints'),
        ]);
    }

    // ── WAYPOINT BATCH ──────────────────────────────────

    public function saveWaypoints(Request $request, string $routeId): JsonResponse
    {
        $route = BusRoute::findOrFail($routeId);

        if ($route->isPublished()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot modify waypoints of a published route.',
            ], 422);
        }

        $data = $request->validate([
            'waypoints' => ['required', 'array', 'min:1'],
            'waypoints.*.station_name' => ['required', 'string', 'max:255'],
            'waypoints.*.lat' => ['nullable', 'numeric', 'between:-90,90'],
            'waypoints.*.lng' => ['nullable', 'numeric', 'between:-180,180'],
            'waypoints.*.meta' => ['nullable', 'array'],
        ]);

        DB::transaction(function () use ($route, $data) {
            // Delete existing waypoints and replace
            $route->waypoints()->delete();

            $cumulativeKm = 0;
            $prevLat = $route->origin_lat;
            $prevLng = $route->origin_lng;

            foreach ($data['waypoints'] as $i => $wp) {
                $segKm = $this->haversineKm($prevLat, $prevLng, $wp['lat'], $wp['lng']);
                $cumulativeKm += $segKm;

                BusRouteWaypoint::create([
                    'id' => (string) Str::uuid(),
                    'route_id' => $route->id,
                    'stop_order' => $i,
                    'station_name' => $wp['station_name'],
                    'lat' => $wp['lat'],
                    'lng' => $wp['lng'],
                    'meta' => $wp['meta'] ?? null,
                    'distance_from_origin_km' => round($cumulativeKm, 2),
                    'estimated_min_from_origin' => (int) round(($cumulativeKm / 60) * 60),
                ]);

                $prevLat = $wp['lat'];
                $prevLng = $wp['lng'];
            }
        });

        return response()->json([
            'success' => true,
            'data' => $route->fresh('waypoints'),
            'message' => 'Waypoints saved.',
        ]);
    }

    // ── HELPERS ─────────────────────────────────────────

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadius = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }
}
