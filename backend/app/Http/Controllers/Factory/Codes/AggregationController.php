<?php

namespace App\Http\Controllers\Factory\Codes;

use App\Http\Controllers\Controller;
use App\Models\PacketCode;
use App\Models\UnitCode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AggregationController extends Controller
{
    // ─── Link Units to Packet ────────────────────────────────────

    /**
     * Link a manually-specified number of available units to a packet.
     *
     * POST /codes/aggregation/link-units
     *
     * Body:
     *   packet_id:     UUID of the target packet
     *   product_id:    UUID of the product (to filter available units)
     *   batch_id:      string batch identifier (to filter available units)
     *   quantity:      int — how many units to link
     */
    public function linkUnitsToPacket(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'packet_id'  => ['required', 'uuid'],
            'product_id' => ['required', 'uuid'],
            'batch_id'   => ['required', 'string', 'max:100'],
            'quantity'   => ['required', 'integer', 'min:1', 'max:1000'],
        ]);

        $packetId  = (string) $data['packet_id'];
        $productId = (string) $data['product_id'];
        $batchId   = (string) $data['batch_id'];
        $quantity  = (int) $data['quantity'];

        // 1. Verify packet exists and belongs to this company
        $packet = PacketCode::with('baseCode')
            ->where('id', $packetId)
            ->first();

        if (!$packet || !$packet->baseCode || $packet->baseCode->company_id !== $companyId) {
            return response()->json(['message' => 'Packet not found'], 404);
        }

        // 2. Count currently linked units
        $currentUnitCount = UnitCode::where('packet_code_id', $packetId)->count();

        // 3. Find available (unlinked) published unit codes for this product + batch
        $availableQuery = UnitCode::available()
            ->published()
            ->byProduct($productId)
            ->byBatch($batchId);

        $availableCount = (clone $availableQuery)->count();

        if ($availableCount < $quantity) {
            return response()->json([
                'message' => "Insufficient available units. Requested: $quantity, Available: $availableCount",
                'data' => [
                    'requested' => $quantity,
                    'available' => $availableCount,
                    'shortfall' => $quantity - $availableCount,
                ],
            ], 422);
        }

        // 4. Pick the requested number of units and link them
        $unitIds = (clone $availableQuery)
            ->orderBy('sequence_number')
            ->limit($quantity)
            ->pluck('id')
            ->map(fn ($v) => (string) $v)
            ->all();

        DB::transaction(function () use ($unitIds, $packetId, $packet, $quantity, $currentUnitCount) {
            // Link units to packet
            UnitCode::whereIn('id', $unitIds)->update([
                'packet_code_id' => $packetId,
            ]);

            // Update packet's unit_count and unit_codes array
            $newCount = $currentUnitCount + $quantity;

            // Update unit_codes array (PostgreSQL UUID[])
            $existingArray = DB::table('packet_codes')
                ->where('id', $packetId)
                ->value('unit_codes');

            $merged = array_merge(
                is_array($existingArray) ? $existingArray : [],
                $unitIds
            );

            DB::table('packet_codes')
                ->where('id', $packetId)
                ->update([
                    'unit_count' => $newCount,
                    'unit_codes' => '{' . implode(',', $merged) . '}',
                ]);
        });

        // 5. Load linked units for response
        $linkedUnits = UnitCode::with('baseCode')
            ->whereIn('id', $unitIds)
            ->get()
            ->map(fn ($u) => [
                'id' => (string) $u->id,
                'code' => $u->baseCode->code ?? '',
                'serialNumber' => $u->serial_number,
                'authenticationCode' => $u->authentication_code,
                'sequenceNumber' => $u->sequence_number,
            ])
            ->all();

        Log::info('Units linked to packet', [
            'packet_id' => $packetId,
            'product_id' => $productId,
            'batch_id' => $batchId,
            'quantity' => $quantity,
            'unit_ids' => $unitIds,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'packet_id' => $packetId,
                'linked_count' => $quantity,
                'total_units_in_packet' => $currentUnitCount + $quantity,
                'linked_units' => $linkedUnits,
                'available_remaining' => $availableCount - $quantity,
            ],
        ]);
    }

    // ─── Unlink Units from Packet ────────────────────────────────

    /**
     * Unlink all units from a packet (mark them available again).
     *
     * POST /codes/aggregation/unlink-units
     */
    public function unlinkUnitsFromPacket(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'packet_id' => ['required', 'uuid'],
        ]);

        $packetId = (string) $data['packet_id'];

        $packet = PacketCode::with('baseCode')
            ->where('id', $packetId)
            ->first();

        if (!$packet || !$packet->baseCode || $packet->baseCode->company_id !== $companyId) {
            return response()->json(['message' => 'Packet not found'], 404);
        }

        $unlinkedCount = UnitCode::where('packet_code_id', $packetId)->update([
            'packet_code_id' => null,
        ]);

        // Reset packet counters
        DB::table('packet_codes')
            ->where('id', $packetId)
            ->update([
                'unit_count' => 0,
                'unit_codes' => '{}',
            ]);

        return response()->json([
            'success' => true,
            'data' => [
                'packet_id' => $packetId,
                'unlinked_count' => $unlinkedCount,
            ],
        ]);
    }

    // ─── Available Units (for dropdown) ──────────────────────────

    /**
     * List available (unlinked) units filtered by product and batch.
     *
     * GET /codes/aggregation/available-units?product_id=X&batch_id=Y
     */
    public function availableUnits(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'product_id' => ['required', 'uuid'],
            'batch_id'   => ['required', 'string', 'max:100'],
        ]);

        $productId = (string) $data['product_id'];
        $batchId   = (string) $data['batch_id'];

        $units = UnitCode::available()
            ->published()
            ->byProduct($productId)
            ->byBatch($batchId)
            ->with('baseCode')
            ->orderBy('sequence_number')
            ->limit(2000)
            ->get()
            ->map(fn ($u) => [
                'id' => (string) $u->id,
                'code' => $u->baseCode->code ?? '',
                'serialNumber' => $u->serial_number,
                'sequenceNumber' => $u->sequence_number,
                'authenticationCode' => $u->authentication_code,
                'codeFormat' => $u->code_format,
            ])
            ->all();

        $totalAvailable = UnitCode::available()
            ->published()
            ->byProduct($productId)
            ->byBatch($batchId)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_available' => $totalAvailable,
                'units' => $units,
            ],
        ]);
    }

    // ─── Available Products (for dropdown) ──────────────────────

    /**
     * List products that have available (unlinked) unit codes.
     *
     * GET /codes/aggregation/available-products
     */
    public function availableProducts(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $products = DB::table('products')
            ->where('company_id', $companyId)
            ->whereIn('id', function ($query) use ($companyId) {
                $query->select('base_codes.product_id')
                    ->from('base_codes')
                    ->join('unit_codes', 'unit_codes.id', '=', 'base_codes.id')
                    ->where('base_codes.company_id', $companyId)
                    ->where('base_codes.status', 'published')
                    ->where('base_codes.is_deleted', false)
                    ->whereNull('unit_codes.packet_code_id')
                    ->whereNotNull('base_codes.product_id')
                    ->distinct();
            })
            ->select('id', 'name')
            ->orderBy('name')
            ->get()
            ->map(fn($p) => [
                'id' => (string) $p->id,
                'name' => $p->name ?? '',
            ])
            ->values()
            ->all();

        return response()->json([
            'success' => true,
            'data' => [
                'products' => $products,
            ],
        ]);
    }

    // ─── Available Batches (for dropdown) ────────────────────────

    /**
     * List distinct batches that have available units for a product.
     *
     * GET /codes/aggregation/available-batches?product_id=X
     */
    public function availableBatches(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'product_id' => ['required', 'uuid'],
        ]);

        $productId = (string) $data['product_id'];

        $batches = DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.product_id', $productId)
            ->where('base_codes.status', 'published')
            ->where('base_codes.is_deleted', false)
            ->whereNull('unit_codes.packet_code_id')
            ->select('base_codes.batch_id')
            ->selectRaw('COUNT(*) as available_count')
            ->groupBy('base_codes.batch_id')
            ->orderBy('base_codes.batch_id')
            ->get()
            ->map(fn ($r) => [
                'batch_id' => (string) ($r->batch_id ?? ''),
                'available_count' => (int) $r->available_count,
            ])
            ->filter(fn ($b) => !empty($b['batch_id']))
            ->values()
            ->all();

        return response()->json([
            'success' => true,
            'data' => [
                'product_id' => $productId,
                'batches' => $batches,
            ],
        ]);
    }
}
