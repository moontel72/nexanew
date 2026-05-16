<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Bundle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class BundleController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $query = DB::table('bundles')
            ->where('company_id', $companyId)
            ->selectRaw('bundles.*, (SELECT COUNT(*) FROM bundle_items WHERE bundle_items.bundle_id = bundles.id AND bundle_items.carton_code_id IS NOT NULL) as cartons_count, (SELECT COUNT(*) FROM bundle_items WHERE bundle_items.bundle_id = bundles.id AND bundle_items.packet_code_id IS NOT NULL) as packets_count');

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $page = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 50)));

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        $items = $paginator->map(function ($b) {
            return [
                'id' => $b->id,
                'bundleCode' => $b->bundle_code,
                'orderReference' => $b->order_reference,
                'storeKeeperName' => $b->store_keeper_name ?? null,
                'totalCartons' => (int) ($b->cartons_count ?? $b->total_cartons),
                'totalPackets' => (int) ($b->packets_count ?? $b->total_packets),
                'locationStore' => $b->location_store,
                'locationShelf' => $b->location_shelf,
                'status' => $b->status,
                'packedAt' => $b->packed_at,
                'createdAt' => $b->created_at,
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'bundles' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'totalPages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $data = $request->validate([
                'order_reference' => ['required', 'string', 'max:200'],
                'carton_code_ids' => ['nullable', 'array'],
                'carton_code_ids.*' => ['uuid'],
                'packet_code_ids' => ['nullable', 'array'],
                'packet_code_ids.*' => ['uuid'],
                'location_store' => ['nullable', 'string', 'max:200'],
                'location_shelf' => ['nullable', 'string', 'max:100'],
                'notes' => ['nullable', 'string', 'max:2000'],
            ]);

            $cartonIds = $data['carton_code_ids'] ?? [];
            $packetIds = $data['packet_code_ids'] ?? [];

            if (empty($cartonIds) && empty($packetIds)) {
                return response()->json(['message' => 'At least one carton or packet code is required'], 422);
            }

            // Filter to only valid UUIDs that actually exist in the DB
            if (!empty($cartonIds)) {
                $existingCartonIds = DB::table('carton_codes')->whereIn('id', $cartonIds)->pluck('id')->toArray();
                $cartonIds = array_values(array_intersect($cartonIds, $existingCartonIds));
            }
            if (!empty($packetIds)) {
                $existingPacketIds = DB::table('packet_codes')->whereIn('id', $packetIds)->pluck('id')->toArray();
                $packetIds = array_values(array_intersect($packetIds, $existingPacketIds));
            }

            $bundleId = (string) Str::uuid();
            $now = now();

            DB::transaction(function () use ($bundleId, $companyId, $user, $data, $cartonIds, $packetIds, $now) {
                DB::table('bundles')->insert([
                    'id' => $bundleId,
                    'bundle_code' => 'BUN-' . $now->format('Ymd') . '-' . strtoupper(Str::random(6)),
                    'order_reference' => $data['order_reference'],
                    'company_id' => $companyId,
                    'status' => 'draft',
                    'packed_by' => $user->id,
                    'packed_at' => $now,
                    'location_store' => $data['location_store'] ?? null,
                    'location_shelf' => $data['location_shelf'] ?? null,
                    'notes' => $data['notes'] ?? null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);

                $items = [];
                foreach ($cartonIds as $cid) {
                    $items[] = ['id' => (string) Str::uuid(), 'bundle_id' => $bundleId, 'carton_code_id' => $cid, 'packet_code_id' => null, 'created_at' => $now, 'updated_at' => $now];
                }
                foreach ($packetIds as $pid) {
                    $items[] = ['id' => (string) Str::uuid(), 'bundle_id' => $bundleId, 'carton_code_id' => null, 'packet_code_id' => $pid, 'created_at' => $now, 'updated_at' => $now];
                }
                if (!empty($items)) {
                    DB::table('bundle_items')->insert($items);
                }

                // Recalculate totals
                $totalCartons = DB::table('bundle_items')->where('bundle_id', $bundleId)->whereNotNull('carton_code_id')->count();
                $totalPackets = DB::table('bundle_items')->where('bundle_id', $bundleId)->whereNotNull('packet_code_id')->count();
                DB::table('bundles')->where('id', $bundleId)->update(['total_cartons' => $totalCartons, 'total_packets' => $totalPackets, 'updated_at' => $now]);
            });

            $bundle = DB::table('bundles')->where('id', $bundleId)->first();
            $items = DB::table('bundle_items')->where('bundle_id', $bundleId)->get();

            // Batch-resolve product names, code strings, and units
            $cartonIds = $items->whereNotNull('carton_code_id')->pluck('carton_code_id')->unique()->values()->toArray();
            $packetIds = $items->whereNotNull('packet_code_id')->pluck('packet_code_id')->unique()->values()->toArray();

            $cartonData = [];
            if (!empty($cartonIds)) {
                $cartonData = DB::table('carton_codes')
                    ->join('base_codes', 'carton_codes.id', '=', 'base_codes.id')
                    ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                    ->whereIn('carton_codes.id', $cartonIds)
                    ->select('carton_codes.id', 'base_codes.code as code_display', 'products.name as product_name')
                    ->get()
                    ->keyBy('id');
            }

            $packetData = [];
            if (!empty($packetIds)) {
                $packetData = DB::table('packet_codes')
                    ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                    ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                    ->whereIn('packet_codes.id', $packetIds)
                    ->select('packet_codes.id', 'base_codes.code as code_display', 'products.name as product_name')
                    ->get()
                    ->keyBy('id');
            }

            $unitsByPacket = [];
            if (!empty($packetIds)) {
                $unitRows = DB::table('unit_codes')
                    ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
                    ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                    ->whereIn('unit_codes.packet_code_id', $packetIds)
                    ->select('unit_codes.id', 'unit_codes.packet_code_id', 'base_codes.code as unit_code', 'products.name as product_name')
                    ->get();
                foreach ($unitRows as $u) {
                    $unitsByPacket[$u->packet_code_id][] = [
                        'id' => $u->id,
                        'unitCode' => $u->unit_code ?? null,
                        'productName' => $u->product_name,
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $bundle->id,
                    'bundleCode' => $bundle->bundle_code,
                    'orderReference' => $bundle->order_reference,
                    'totalCartons' => (int) $bundle->total_cartons,
                    'totalPackets' => (int) $bundle->total_packets,
                    'locationStore' => $bundle->location_store,
                    'locationShelf' => $bundle->location_shelf,
                    'status' => $bundle->status,
                    'packedAt' => $bundle->packed_at,
                    'notes' => $bundle->notes,
                    'createdAt' => $bundle->created_at,
                    'items' => $items->map(function ($i) use ($cartonData, $packetData, $unitsByPacket) {
                        $result = [
                            'id' => $i->id,
                            'type' => $i->carton_code_id ? 'carton' : 'packet',
                            'cartonCodeId' => $i->carton_code_id,
                            'packetCodeId' => $i->packet_code_id,
                        ];
                        if ($i->carton_code_id && isset($cartonData[$i->carton_code_id])) {
                            $result['productName'] = $cartonData[$i->carton_code_id]->product_name;
                            $result['codeDisplay'] = $cartonData[$i->carton_code_id]->code_display;
                        } elseif ($i->packet_code_id && isset($packetData[$i->packet_code_id])) {
                            $result['productName'] = $packetData[$i->packet_code_id]->product_name;
                            $result['codeDisplay'] = $packetData[$i->packet_code_id]->code_display;
                            $result['units'] = $unitsByPacket[$i->packet_code_id] ?? [];
                        }
                        return $result;
                    })->values(),
                ],
            ], 201);

        } catch (\Exception $e) {
            Log::error('Bundle store failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function show(Request $request, string $id)
    {
        try {
        $bundle = DB::table('bundles')->find($id);
        if (!$bundle) { return response()->json(['message' => 'Bundle not found'], 404); }

        $items = DB::table('bundle_items')->where('bundle_id', $id)->get();

        // Batch-resolve product names, code strings, and units
        $cartonIds = $items->whereNotNull('carton_code_id')->pluck('carton_code_id')->unique()->values()->toArray();
        $packetIds = $items->whereNotNull('packet_code_id')->pluck('packet_code_id')->unique()->values()->toArray();

        $cartonData = [];
        if (!empty($cartonIds)) {
            $cartonData = DB::table('carton_codes')
                ->join('base_codes', 'carton_codes.id', '=', 'base_codes.id')
                ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                ->whereIn('carton_codes.id', $cartonIds)
                ->select('carton_codes.id', 'base_codes.code as code_display', 'products.name as product_name')
                ->get()
                ->keyBy('id');
        }

        $packetData = [];
        if (!empty($packetIds)) {
            $packetData = DB::table('packet_codes')
                ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                ->whereIn('packet_codes.id', $packetIds)
                ->select('packet_codes.id', 'base_codes.code as code_display', 'products.name as product_name')
                ->get()
                ->keyBy('id');
        }

        $unitsByPacket = [];
        if (!empty($packetIds)) {
            $unitRows = DB::table('unit_codes')
                ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
                ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                ->whereIn('unit_codes.packet_code_id', $packetIds)
                ->select('unit_codes.id', 'unit_codes.packet_code_id', 'base_codes.code as unit_code', 'products.name as product_name')
                ->get();
            foreach ($unitRows as $u) {
                $unitsByPacket[$u->packet_code_id][] = [
                    'id' => $u->id,
                    'unitCode' => $u->unit_code ?? null,
                    'productName' => $u->product_name,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $bundle->id,
                'bundleCode' => $bundle->bundle_code,
                'orderReference' => $bundle->order_reference,
                'totalCartons' => (int) $bundle->total_cartons,
                'totalPackets' => (int) $bundle->total_packets,
                'locationStore' => $bundle->location_store,
                'locationShelf' => $bundle->location_shelf,
                'status' => $bundle->status,
                'packedAt' => $bundle->packed_at,
                'notes' => $bundle->notes,
                'createdAt' => $bundle->created_at,
                'items' => $items->map(function ($i) use ($cartonData, $packetData, $unitsByPacket) {
                    $result = [
                        'id' => $i->id,
                        'type' => $i->carton_code_id ? 'carton' : 'packet',
                        'cartonCodeId' => $i->carton_code_id,
                        'packetCodeId' => $i->packet_code_id,
                    ];
                    if ($i->carton_code_id && isset($cartonData[$i->carton_code_id])) {
                        $result['productName'] = $cartonData[$i->carton_code_id]->product_name;
                        $result['codeDisplay'] = $cartonData[$i->carton_code_id]->code_display;
                    } elseif ($i->packet_code_id && isset($packetData[$i->packet_code_id])) {
                        $result['productName'] = $packetData[$i->packet_code_id]->product_name;
                        $result['codeDisplay'] = $packetData[$i->packet_code_id]->code_display;
                        $result['units'] = $unitsByPacket[$i->packet_code_id] ?? [];
                    }
                    return $result;
                })->values(),
            ],
        ]);
        } catch (\Exception $e) {
            Log::error('BundleController::show failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString(), 'id' => $id]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    public function update(Request $request, string $id)
    {
        $bundle = DB::table('bundles')->find($id);
        if (!$bundle) { return response()->json(['message' => 'Bundle not found'], 404); }

        $data = $request->validate([
            'status' => ['nullable', 'string', 'in:draft,packed,shipped,delivered'],
            'location_store' => ['nullable', 'string', 'max:200'],
            'location_shelf' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $updates = array_filter($data, fn($v) => $v !== null);
        if (!empty($updates)) {
            $updates['updated_at'] = now();
            DB::table('bundles')->where('id', $id)->update($updates);
        }

        return response()->json(['success' => true, 'data' => ['updated' => true]]);
    }

    public function destroy(Request $request, string $id)
    {
        DB::table('bundles')->where('id', $id)->delete();
        return response()->json(['success' => true, 'data' => ['deleted' => true]]);
    }

    public function scan(Request $request, string $id)
    {
        $bundle = DB::table('bundles')->find($id);
        if (!$bundle) { return response()->json(['message' => 'Bundle not found'], 404); }

        $cartonItems = DB::table('bundle_items')->where('bundle_id', $id)->whereNotNull('carton_code_id')->get();
        $packetItems = DB::table('bundle_items')->where('bundle_id', $id)->whereNotNull('packet_code_id')->get();

        $cartons = $cartonItems->map(function ($i) {
            $c = DB::table('carton_codes')->find($i->carton_code_id);
            return ['id' => $c?->id, 'codeFormat' => $c?->code_format, 'sequenceNumber' => $c?->sequence_number, 'packetCount' => $c?->packet_count, 'totalUnits' => $c?->total_units, 'isSealed' => (bool)($c?->is_sealed ?? false)];
        })->values();

        $packets = $packetItems->map(function ($i) {
            $p = DB::table('packet_codes')->find($i->packet_code_id);
            return ['id' => $p?->id, 'codeFormat' => $p?->code_format, 'sequenceNumber' => $p?->sequence_number, 'unitCount' => $p?->unit_count, 'isSealed' => (bool)($p?->is_sealed ?? false)];
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'bundleCode' => $bundle->bundle_code,
                'orderReference' => $bundle->order_reference,
                'totalCartons' => $cartons->count(),
                'totalPackets' => $packets->count(),
                'locationStore' => $bundle->location_store,
                'locationShelf' => $bundle->location_shelf,
                'status' => $bundle->status,
                'cartons' => $cartons,
                'packets' => $packets,
            ],
        ]);
    }
}
