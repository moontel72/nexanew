<?php

namespace App\Http\Controllers\Factory\Codes;

use App\Http\Controllers\Controller;
use App\Models\Bundle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BundleInsightsController extends Controller
{
    /**
     * Bundle hierarchy report.
     *
     * GET /codes/bundles/{id}/insights
     *
     * Source of truth: bundle_items table.
     * Hierarchy: Cartons → Packets (via packet_codes.carton_code_id FK) → Units (via unit_codes.packet_code_id FK)
     */
    public function show(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $bundle = Bundle::where('id', $id)
            ->where('company_id', $companyId)
            ->first();

        if (!$bundle) {
            return response()->json(['message' => 'Bundle not found'], 404);
        }

        // Get carton and packet IDs from bundle_items (the source of truth)
        $items = DB::table('bundle_items')->where('bundle_id', $id)->get();

        $cartonIds = $items->pluck('carton_code_id')->filter()->unique()->values()->all();
        $packetIds = $items->pluck('packet_code_id')->filter()->unique()->values()->all();

        // ─── Load cartons with their packets ─────────────────────

        $cartons = [];
        $allPackets = []; // track all packets we've already placed in cartons

        if (!empty($cartonIds)) {
            $cartonRows = DB::table('carton_codes')
                ->join('base_codes', 'carton_codes.id', '=', 'base_codes.id')
                ->whereIn('carton_codes.id', $cartonIds)
                ->select('carton_codes.*', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                ->get();

            foreach ($cartonRows as $carton) {
                // Find packets belonging to this carton via packet_codes.carton_code_id FK
                $packetRows = DB::table('packet_codes')
                    ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                    ->where('packet_codes.carton_code_id', $carton->id)
                    ->select('packet_codes.*', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                    ->get();

                $packets = [];
                foreach ($packetRows as $packet) {
                    $allPackets[] = $packet->id;

                    $units = $this->loadUnits($packet->id);
                    $packets[] = $this->formatPacket($packet, $units);
                }

                $cartons[] = [
                    'id' => (string) $carton->id,
                    'code' => (string) $carton->code,
                    'status' => (string) $carton->status,
                    'batchId' => (string) ($carton->batch_id ?? ''),
                    'productId' => (string) ($carton->product_id ?? ''),
                    'packetCount' => count($packets),
                    'totalUnits' => collect($packets)->sum('unitCount'),
                    'packets' => $packets,
                ];
            }
        }

        // ─── Standalone packets (not in any carton) ──────────────

        $standalonePackets = [];
        foreach ($packetIds as $pid) {
            if (in_array($pid, $allPackets)) continue; // already inside a carton

            $pRow = DB::table('packet_codes')
                ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                ->where('packet_codes.id', $pid)
                ->select('packet_codes.*', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                ->first();

            if ($pRow) {
                $units = $this->loadUnits($pRow->id);
                $standalonePackets[] = $this->formatPacket($pRow, $units);
            }
        }

        // ─── Products ────────────────────────────────────────────

        $allProductIds = collect($cartons)->pluck('productId')
            ->merge(collect($standalonePackets)->pluck('productId'))
            ->unique()->filter()->values()->all();

        $products = [];
        if (!empty($allProductIds)) {
            $products = DB::table('products')
                ->whereIn('id', $allProductIds)
                ->get()
                ->map(fn($p) => ['id' => (string) $p->id, 'name' => $p->name ?? ''])
                ->values()
                ->all();
        }

        // ─── Totals ──────────────────────────────────────────────

        $totalCartons = count($cartons);
        $totalPackets = count($standalonePackets) + collect($cartons)->sum(fn($c) => count($c['packets']));
        $totalUnits = collect($standalonePackets)->sum('unitCount')
            + collect($cartons)->sum(fn($c) => collect($c['packets'])->sum('unitCount'));

        return response()->json([
            'success' => true,
            'data' => [
                'bundle' => [
                    'id' => (string) $bundle->id,
                    'bundleCode' => $bundle->bundle_code,
                    'orderReference' => $bundle->order_reference,
                    'status' => $bundle->status,
                    'locationStore' => $bundle->location_store,
                    'locationShelf' => $bundle->location_shelf,
                    'createdAt' => $bundle->created_at?->toISOString(),
                    'updatedAt' => $bundle->updated_at?->toISOString(),
                ],
                'summary' => [
                    'totalCartons' => $totalCartons,
                    'totalPackets' => $totalPackets,
                    'totalUnits' => $totalUnits,
                ],
                'cartons' => $cartons,
                'standalonePackets' => $standalonePackets,
                'products' => $products,
            ],
        ]);
    }

    // ─── Helpers ─────────────────────────────────────────────────

    private function loadUnits(string $packetId): array
    {
        return DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('unit_codes.packet_code_id', $packetId)
            ->select(
                'unit_codes.id', 'unit_codes.serial_number',
                'unit_codes.authentication_code', 'unit_codes.sequence_number',
                'unit_codes.code_format', 'unit_codes.model',
                'base_codes.code', 'base_codes.status', 'base_codes.batch_id',
                'base_codes.product_id'
            )
            ->orderBy('unit_codes.sequence_number')
            ->get()
            ->map(fn($u) => [
                'id' => (string) $u->id,
                'code' => (string) $u->code,
                'serialNumber' => (string) ($u->serial_number ?? ''),
                'authenticationCode' => (string) ($u->authentication_code ?? ''),
                'sequenceNumber' => (int) ($u->sequence_number ?? 0),
                'codeFormat' => (string) ($u->code_format ?? ''),
                'model' => $u->model,
                'status' => (string) $u->status,
                'batchId' => (string) ($u->batch_id ?? ''),
                'productId' => (string) ($u->product_id ?? ''),
            ])
            ->all();
    }

    private function formatPacket($pRow, array $units): array
    {
        return [
            'id' => (string) $pRow->id,
            'code' => (string) $pRow->code,
            'status' => (string) $pRow->status,
            'batchId' => (string) ($pRow->batch_id ?? ''),
            'productId' => (string) ($pRow->product_id ?? ''),
            'unitCount' => count($units),
            'units' => $units,
        ];
    }
}
