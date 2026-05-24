<?php

namespace App\Http\Controllers\Logistics;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SmartCodeController extends Controller
{
    /**
     * POST /api/v1/logistics/generate-manifest
     * Accepts parent + child packets, generates 1 parent + N child smart codes.
     * Computes delivery sequence (LIFO: farthest destination = front of truck).
     */
    public function generateSmartManifest(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'parent' => ['required', 'array'],
            'parent.province' => ['required', 'string'], 'parent.district' => ['required', 'string'],
            'parent.town' => ['required', 'string'], 'parent.zone_tag' => ['nullable', 'string'],
            'children' => ['required', 'array', 'min:1', 'max:20'],
            'children.*.province' => ['required', 'string'], 'children.*.district' => ['required', 'string'],
            'children.*.town' => ['required', 'string'], 'children.*.zone_tag' => ['nullable', 'string'],
            'truck_plate_id' => ['nullable', 'string', 'uuid'],
        ]);

        // Generate parent code
        $parentCode = $this->generateCode();
        $parentId = (string) Str::uuid();
        DB::table('smart_tracking_payloads')->insert([
            'id' => $parentId, 'smart_code_string' => $parentCode,
            'destination_province' => $validated['parent']['province'],
            'destination_district' => $validated['parent']['district'],
            'destination_town' => $validated['parent']['town'],
            'geofence_zone_tag' => $validated['parent']['zone_tag'] ?? null,
            'truck_placement_index' => 0, 'truck_plate_id' => $validated['truck_plate_id'] ?? null,
            'child_count' => count($validated['children']), 'status' => 'manifested',
            'created_at' => now(), 'updated_at' => now(),
        ]);

        // Generate child codes with LIFO placement index
        $children = [];
        $totalChildren = count($validated['children']);
        foreach ($validated['children'] as $i => $child) {
            $code = $this->generateCode();
            $childId = (string) Str::uuid();
            // LIFO: last destination (highest index) = front of truck (lowest placement)
            $placementIndex = $totalChildren - $i;
            DB::table('smart_tracking_payloads')->insert([
                'id' => $childId, 'parent_code_id' => $parentId, 'smart_code_string' => $code,
                'destination_province' => $child['province'],
                'destination_district' => $child['district'],
                'destination_town' => $child['town'],
                'geofence_zone_tag' => $child['zone_tag'] ?? null,
                'truck_placement_index' => $placementIndex,
                'truck_plate_id' => $validated['truck_plate_id'] ?? null,
                'status' => 'pending', 'created_at' => now(), 'updated_at' => now(),
            ]);
            $children[] = ['id' => $childId, 'code' => $code, 'placement_index' => $placementIndex,
                'destination' => "{$child['town']}, {$child['district']}"];
        }

        return response()->json(['status' => 'success', 'data' => [
            'parent' => ['id' => $parentId, 'code' => $parentCode, 'child_count' => $totalChildren],
            'children' => $children,
        ]], 201);
    }

    /**
     * GET /api/v1/logistics/truck-sequence/{truckPlate}
     * Returns loading sequence sorted by placement index (LIFO).
     */
    public function getTruckLoadingSequence(string $truckPlate): JsonResponse
    {
        $payloads = DB::table('smart_tracking_payloads')
            ->where('truck_plate_id', $truckPlate)->where('status', '!=', 'delivered')
            ->orderBy('truck_placement_index', 'asc')
            ->get()->map(fn ($p) => [
                'code' => $p->smart_code_string, 'town' => $p->destination_town,
                'district' => $p->destination_district, 'zone' => $p->geofence_zone_tag,
                'placement_index' => $p->truck_placement_index,
                'section' => $this->truckSection($p->truck_placement_index),
                'is_parent' => is_null($p->parent_code_id) && $p->child_count > 0,
            ]);

        return response()->json(['status' => 'success', 'data' => ['truck_plate' => $truckPlate, 'sequence' => $payloads]]);
    }

    private function generateCode(): string
    {
        return strtoupper(Str::random(2)) . random_int(10000, 99999);
    }

    private function truckSection(int $index): string
    {
        return match(true) {
            $index <= 2 => 'Rear Edge (First Drop)',
            $index <= 5 => 'Middle Section',
            default => 'Front Tray (Last Drop - LIFO)',
        };
    }

    /** POST /api/v1/truck-fleet/logistics/warehouse-config */
    public function registerWarehouseSlot(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'store_name' => ['required', 'string', 'max:100'],
            'store_room' => ['nullable', 'string', 'max:50'],
            'rack_identifier' => ['required', 'string', 'max:30'],
            'shelf_number' => ['required', 'string', 'max:20'],
        ]);
        DB::table('warehouse_inventories')->insert([
            'id' => (string) Str::uuid(),
            'tenant_account_id' => $request->user()->tenant_account_id ?? $request->user()->id,
            'store_name' => $validated['store_name'],
            'store_room' => $validated['store_room'],
            'rack_identifier' => $validated['rack_identifier'],
            'shelf_number' => $validated['shelf_number'],
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['status' => 'success', 'message' => 'Warehouse slot registered.'], 201);
    }
}
