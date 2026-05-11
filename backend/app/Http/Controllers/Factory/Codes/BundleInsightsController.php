<?php

namespace App\Http\Controllers\Factory\Codes;

use App\Http\Controllers\Controller;
use App\Models\Bundle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BundleInsightsController extends Controller
{
    /**
     * Comprehensive hierarchy report for a bundle.
     *
     * GET /codes/bundles/{id}/insights
     *
     * Returns nested: Bundle → Cartons → Packets → Units
     * with product and batch metadata at each level.
     */
    public function show(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $bundle = Bundle::with(['items.cartonCode.baseCode', 'items.packetCode.baseCode'])
            ->where('id', $id)
            ->where('company_id', $companyId)
            ->first();

        if (!$bundle) {
            return response()->json(['message' => 'Bundle not found'], 404);
        }

        // Gather all carton IDs and packet IDs from bundle_items
        $cartonIds = $bundle->items
            ->where('carton_code_id', '!=', null)
            ->pluck('carton_code_id')
            ->unique()
            ->values()
            ->all();

        $packetIds = $bundle->items
            ->where('packet_code_id', '!=', null)
            ->pluck('packet_code_id')
            ->unique()
            ->values()
            ->all();

        // ─── Load hierarchy ──────────────────────────────────────

        // Cartons with their packets and units
        $cartons = [];
        if (!empty($cartonIds)) {
            $cartonRows = DB::table('carton_codes')
                ->join('base_codes', 'carton_codes.id', '=', 'base_codes.id')
                ->whereIn('carton_codes.id', $cartonIds)
                ->select('carton_codes.*', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                ->get();

            foreach ($cartonRows as $carton) {
                // Packets in this carton
                $cartonPacketIds = [];
                if (!empty($carton->packet_codes) && is_array($carton->packet_codes)) {
                    $cartonPacketIds = $carton->packet_codes;
                }

                $packets = [];
                if (!empty($cartonPacketIds)) {
                    $packetRows = DB::table('packet_codes')
                        ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                        ->whereIn('packet_codes.id', $cartonPacketIds)
                        ->select('packet_codes.*', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                        ->get();

                    foreach ($packetRows as $packet) {
                        // Units in this packet
                        $units = DB::table('unit_codes')
                            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
                            ->where('unit_codes.packet_code_id', $packet->id)
                            ->select(
                                'unit_codes.id', 'unit_codes.serial_number',
                                'unit_codes.authentication_code', 'unit_codes.sequence_number',
                                'unit_codes.code_format', 'unit_codes.model',
                                'base_codes.code', 'base_codes.status', 'base_codes.batch_id',
                                'base_codes.product_id'
                            )
                            ->orderBy('unit_codes.sequence_number')
                            ->get()
                            ->map(fn ($u) => [
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

                        $packets[] = [
                            'id' => (string) $packet->id,
                            'code' => (string) $packet->code,
                            'status' => (string) $packet->status,
                            'batchId' => (string) ($packet->batch_id ?? ''),
                            'productId' => (string) ($packet->product_id ?? ''),
                            'unitCount' => (int) ($packet->unit_count ?? 0),
                            'units' => $units,
                        ];
                    }
                }

                $cartons[] = [
                    'id' => (string) $carton->id,
                    'code' => (string) $carton->code,
                    'status' => (string) $carton->status,
                    'batchId' => (string) ($carton->batch_id ?? ''),
                    'productId' => (string) ($carton->product_id ?? ''),
                    'packetCount' => (int) ($carton->packet_count ?? 0),
                    'totalUnits' => (int) ($carton->total_units ?? 0),
                    'packets' => $packets,
                ];
            }
        }

        // Standalone packets (not in any carton)
        $standalonePackets = [];
        foreach ($packetIds as $pid) {
            $alreadyInCarton = false;
            foreach ($cartons as $c) {
                foreach ($c['packets'] as $p) {
                    if ($p['id'] === $pid) {
                        $alreadyInCarton = true;
                        break 2;
                    }
                }
            }
            if (!$alreadyInCarton) {
                $pRow = DB::table('packet_codes')
                    ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                    ->where('packet_codes.id', $pid)
                    ->select('packet_codes.*', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                    ->first();

                if ($pRow) {
                    $units = DB::table('unit_codes')
                        ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
                        ->where('unit_codes.packet_code_id', $pRow->id)
                        ->select('unit_codes.id', 'unit_codes.serial_number', 'unit_codes.authentication_code', 'unit_codes.sequence_number', 'base_codes.code', 'base_codes.status', 'base_codes.batch_id', 'base_codes.product_id')
                        ->orderBy('unit_codes.sequence_number')
                        ->get()
                        ->map(fn ($u) => [
                            'id' => (string) $u->id,
                            'code' => (string) $u->code,
                            'serialNumber' => (string) ($u->serial_number ?? ''),
                            'authenticationCode' => (string) ($u->authentication_code ?? ''),
                            'sequenceNumber' => (int) ($u->sequence_number ?? 0),
                            'status' => (string) $u->status,
                            'batchId' => (string) ($u->batch_id ?? ''),
                            'productId' => (string) ($u->product_id ?? ''),
                        ])
                        ->all();

                    $standalonePackets[] = [
                        'id' => (string) $pRow->id,
                        'code' => (string) $pRow->code,
                        'status' => (string) $pRow->status,
                        'batchId' => (string) ($pRow->batch_id ?? ''),
                        'productId' => (string) ($pRow->product_id ?? ''),
                        'unitCount' => (int) ($pRow->unit_count ?? 0),
                        'units' => $units,
                    ];
                }
            }
        }

        // ─── Product breakdown ────────────────────────────────────
        $allProductIds = collect($cartons)->pluck('productId')
            ->merge(collect($standalonePackets)->pluck('productId'))
            ->unique()
            ->filter()
            ->values()
            ->all();

        $products = [];
        if (!empty($allProductIds)) {
            $products = DB::table('products')
                ->whereIn('id', $allProductIds)
                ->get()
                ->map(fn ($p) => [
                    'id' => (string) $p->id,
                    'name' => $p->name ?? '',
                ])
                ->keyBy('id')
                ->all();
        }

        // ─── Totals ───────────────────────────────────────────────
        $totalCartons = count($cartons);
        $totalPackets = count($standalonePackets) + collect($cartons)->sum(fn ($c) => count($c['packets']));
        $totalUnits = collect($standalonePackets)->sum('unitCount')
            + collect($cartons)->sum(fn ($c) => collect($c['packets'])->sum('unitCount'));

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
                'products' => array_values($products),
            ],
        ]);
    }
}
