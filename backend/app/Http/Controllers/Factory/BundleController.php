<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Bundle;
use App\Models\BundleItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BundleController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $query = Bundle::query()
            ->where('company_id', $companyId)
            ->withCount(['items as cartons_count' => fn($q) => $q->whereNotNull('carton_code_id')])
            ->withCount(['items as packets_count' => fn($q) => $q->whereNotNull('packet_code_id')]);

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $page = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 50)));

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        $items = $paginator->map(fn(Bundle $b) => [
            'id' => $b->id,
            'bundleCode' => $b->bundle_code,
            'orderReference' => $b->order_reference,
            'totalCartons' => (int) ($b->cartons_count ?? $b->total_cartons),
            'totalPackets' => (int) ($b->packets_count ?? $b->total_packets),
            'locationStore' => $b->location_store,
            'locationShelf' => $b->location_shelf,
            'status' => $b->status,
            'packedAt' => $b->packed_at?->toISOString(),
            'createdAt' => $b->created_at->toISOString(),
        ])->values();

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

        $bundle = DB::transaction(function () use ($companyId, $user, $data, $cartonIds, $packetIds) {
            $bundle = Bundle::create([
                'id' => (string) Str::uuid(),
                'bundle_code' => 'BUN-' . now()->format('Ymd') . '-' . strtoupper(Str::random(6)),
                'order_reference' => $data['order_reference'],
                'company_id' => $companyId,
                'status' => 'draft',
                'packed_by' => $user->id,
                'packed_at' => now(),
                'location_store' => $data['location_store'] ?? null,
                'location_shelf' => $data['location_shelf'] ?? null,
                'notes' => $data['notes'] ?? null,
            ]);

            $items = [];
            foreach ($cartonIds as $cid) {
                $items[] = ['id' => (string) Str::uuid(), 'bundle_id' => $bundle->id, 'carton_code_id' => $cid, 'created_at' => now(), 'updated_at' => now()];
            }
            foreach ($packetIds as $pid) {
                $items[] = ['id' => (string) Str::uuid(), 'bundle_id' => $bundle->id, 'packet_code_id' => $pid, 'created_at' => now(), 'updated_at' => now()];
            }
            BundleItem::insert($items);

            $bundle->recalculateTotals();
            return $bundle->fresh()->load('items');
        });

        return response()->json([
            'success' => true,
            'data' => $this->formatBundle($bundle),
        ], 201);
    }

    public function show(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $bundle = Bundle::where('company_id', $companyId)->with('items.cartonCode', 'items.packetCode')->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $this->formatBundle($bundle, true),
        ]);
    }

    public function update(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $bundle = Bundle::where('company_id', $companyId)->findOrFail($id);

        $data = $request->validate([
            'status' => ['nullable', 'string', 'in:draft,packed,shipped,delivered'],
            'location_store' => ['nullable', 'string', 'max:200'],
            'location_shelf' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $bundle->update(array_filter($data, fn($v) => $v !== null));

        return response()->json([
            'success' => true,
            'data' => $this->formatBundle($bundle->fresh()),
        ]);
    }

    public function destroy(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $bundle = Bundle::where('company_id', $companyId)->findOrFail($id);
        $bundle->delete(); // Items cascade, carton/packet codes survive via ON DELETE SET NULL

        return response()->json([
            'success' => true,
            'data' => ['deleted' => true],
        ]);
    }

    public function scan(Request $request, string $id)
    {
        $bundle = Bundle::with([
            'items.cartonCode',
            'items.packetCode',
        ])->findOrFail($id);

        $cartonItems = $bundle->items->whereNotNull('carton_code_id')->map(function ($item) {
            $c = $item->cartonCode;
            return [
                'id' => $c?->id,
                'codeFormat' => $c?->code_format,
                'sequenceNumber' => $c?->sequence_number,
                'packetCount' => $c?->packet_count,
                'totalUnits' => $c?->total_units,
                'isSealed' => (bool) ($c?->is_sealed ?? false),
            ];
        })->values();

        $packetItems = $bundle->items->whereNotNull('packet_code_id')->map(function ($item) {
            $p = $item->packetCode;
            return [
                'id' => $p?->id,
                'codeFormat' => $p?->code_format,
                'sequenceNumber' => $p?->sequence_number,
                'unitCount' => $p?->unit_count,
                'isSealed' => (bool) ($p?->is_sealed ?? false),
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'bundleCode' => $bundle->bundle_code,
                'orderReference' => $bundle->order_reference,
                'totalCartons' => $cartonItems->count(),
                'totalPackets' => $packetItems->count(),
                'totalItems' => $bundle->items->count(),
                'locationStore' => $bundle->location_store,
                'locationShelf' => $bundle->location_shelf,
                'status' => $bundle->status,
                'cartons' => $cartonItems,
                'packets' => $packetItems,
            ],
        ]);
    }

    // ─── Helpers ──────────────────────────────────────────────────

    private function formatBundle(Bundle $bundle, bool $withItems = false): array
    {
        $result = [
            'id' => $bundle->id,
            'bundleCode' => $bundle->bundle_code,
            'orderReference' => $bundle->order_reference,
            'totalCartons' => $bundle->total_cartons,
            'totalPackets' => $bundle->total_packets,
            'locationStore' => $bundle->location_store,
            'locationShelf' => $bundle->location_shelf,
            'status' => $bundle->status,
            'packedAt' => $bundle->packed_at?->toISOString(),
            'notes' => $bundle->notes,
            'createdAt' => $bundle->created_at->toISOString(),
        ];

        if ($withItems && $bundle->relationLoaded('items')) {
            $result['items'] = $bundle->items->map(fn(BundleItem $i) => [
                'id' => $i->id,
                'type' => $i->carton_code_id ? 'carton' : 'packet',
                'cartonCodeId' => $i->carton_code_id,
                'packetCodeId' => $i->packet_code_id,
            ])->values();
        }

        return $result;
    }
}
