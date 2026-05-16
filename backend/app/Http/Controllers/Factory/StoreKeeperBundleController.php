<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Bundle;
use App\Models\BundleItem;
use App\Models\CartonCode;
use App\Models\PacketCode;
use App\Models\UnitCode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class StoreKeeperBundleController extends Controller
{
    // ─── Pending Orders ──────────────────────────────────────────

    /**
     * No carton/packet codes required.
     * Create a dummy/placeholder order for testing.
     * No carton/packet codes required.
     */
    public function createDummyOrder(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;
            $data = $request->validate([
                'order_reference' => ['required', 'string', 'max:200'],
                'notes' => ['nullable', 'string', 'max:2000'],
            ]);
            $bundleId = (string) Str::uuid();
            $now = now();
            $bundleCode = 'BUN-' . $now->format('Ymd') . '-' . strtoupper(Str::random(6));
            DB::table('bundles')->insert([
                'id' => $bundleId,
                'bundle_code' => $bundleCode,
                'order_reference' => $data['order_reference'],
                'company_id' => $companyId,
                'status' => 'draft',
                'linking_status' => 'admin_linked',
                'total_cartons' => 0,
                'total_packets' => 0,
                'notes' => $data['notes'] ?? null,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $bundleId,
                    'bundleCode' => $bundleCode,
                    'orderReference' => $data['order_reference'],
                    'status' => 'draft',
                    'createdAt' => $now->toISOString(),
                ],
            ], 201);
        } catch (\Exception $e) {
            Log::error('createDummyOrder failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * List orders with linking_status = 'pending_store_linking' for the
     * authenticated user's company.
     */
    public function pendingOrders(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundles = DB::table('bundles')
                ->where('company_id', $companyId)
                ->where('linking_status', 'pending_store_linking')
                ->orderByDesc('created_at')
                ->get()
                ->map(function ($b) {
                    return [
                        'id' => $b->id,
                        'bundleCode' => $b->bundle_code,
                        'orderReference' => $b->order_reference,
                        'totalCartons' => (int) $b->total_cartons,
                        'totalPackets' => (int) $b->total_packets,
                        'status' => $b->status,
                        'linkingStatus' => $b->linking_status,
                        'createdAt' => $b->created_at,
                    ];
                })
                ->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'orders' => $bundles,
                    'total' => $bundles->count(),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle pendingOrders failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Generate Bundle QR ─────────────────────────────────────

    /**
     * Generate a unique bundle QR code and store the payload.
     */
    public function generateBundleQR(Request $request, string $bundleId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            if ($bundle->linking_status !== 'pending_store_linking') {
                return response()->json([
                    'success' => false,
                    'message' => 'Bundle must be in pending_store_linking status to generate QR. Current status: ' . $bundle->linking_status,
                ], 422);
            }

            $timestamp = now()->timestamp;
            $orderRef = $bundle->order_reference ?? 'NO-REF';
            $bundleQrCode = 'BQR-' . strtoupper(Str::slug($orderRef, '-')) . '-' . $timestamp;

            $qrPayload = [
                'bundle_id' => $bundleId,
                'order_reference' => $bundle->order_reference,
                'total_cartons' => (int) $bundle->total_cartons,
                'total_packets' => (int) $bundle->total_packets,
                'generated_at' => now()->toISOString(),
                'store_keeper_id' => (string) $user->id,
            ];

            DB::table('bundles')
                ->where('id', $bundleId)
                ->update([
                    'bundle_qr_data' => json_encode($qrPayload),
                    // Keep as pending_store_linking — only mark store_linked
                    // when ALL cartons/packets/units have been scanned and linked.
                    'linking_status' => 'pending_store_linking',
                    'store_keeper_id' => $user->id,
                    'updated_at' => now(),
                ]);

            Log::info('Bundle QR generated', [
                'bundle_id' => $bundleId,
                'bundle_qr_code' => $bundleQrCode,
                'store_keeper_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'bundleId' => $bundleId,
                    'bundleQrCode' => $bundleQrCode,
                    'qrData' => $qrPayload,
                    'linkingStatus' => 'store_linked',
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle generateBundleQR failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Link Carton to Bundle ──────────────────────────────────

    /**
     * Link an existing carton code to a bundle.
     */
    public function linkCartonToBundle(Request $request, string $bundleId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            $data = $request->validate([
                'carton_code_id' => ['required', 'uuid', 'exists:carton_codes,id'],
            ]);

            $cartonCodeId = (string) $data['carton_code_id'];

            // Verify the carton is not already linked to this bundle
            $existing = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->where('carton_code_id', $cartonCodeId)
                ->first();

            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'This carton is already linked to this bundle',
                ], 422);
            }

            DB::transaction(function () use ($bundleId, $cartonCodeId) {
                DB::table('bundle_items')->insert([
                    'id' => (string) Str::uuid(),
                    'bundle_id' => $bundleId,
                    'carton_code_id' => $cartonCodeId,
                    'packet_code_id' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                $this->recalculateBundleTotals($bundleId);
            });

            Log::info('Carton linked to bundle', [
                'bundle_id' => $bundleId,
                'carton_code_id' => $cartonCodeId,
                'store_keeper_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'bundleId' => $bundleId,
                    'cartonCodeId' => $cartonCodeId,
                    'linked' => true,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle linkCartonToBundle failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Link Packet to Bundle ──────────────────────────────────

    /**
     * Link a packet code (optionally with its parent carton) to a bundle.
     */
    public function linkPacketToBundle(Request $request, string $bundleId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            $data = $request->validate([
                'packet_code_id' => ['required', 'uuid', 'exists:packet_codes,id'],
                'carton_code_id' => ['nullable', 'uuid', 'exists:carton_codes,id'],
            ]);

            $packetCodeId = (string) $data['packet_code_id'];
            $cartonCodeId = isset($data['carton_code_id']) ? (string) $data['carton_code_id'] : null;

            // Verify the packet is not already linked to this bundle
            $existing = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->where('packet_code_id', $packetCodeId)
                ->first();

            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'This packet is already linked to this bundle',
                ], 422);
            }

            DB::transaction(function () use ($bundleId, $packetCodeId, $cartonCodeId) {
                DB::table('bundle_items')->insert([
                    'id' => (string) Str::uuid(),
                    'bundle_id' => $bundleId,
                    'carton_code_id' => $cartonCodeId,
                    'packet_code_id' => $packetCodeId,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                $this->recalculateBundleTotals($bundleId);
            });

            Log::info('Packet linked to bundle', [
                'bundle_id' => $bundleId,
                'packet_code_id' => $packetCodeId,
                'carton_code_id' => $cartonCodeId,
                'store_keeper_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'bundleId' => $bundleId,
                    'packetCodeId' => $packetCodeId,
                    'cartonCodeId' => $cartonCodeId,
                    'linked' => true,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle linkPacketToBundle failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Link Unit to Bundle ────────────────────────────────────

    /**
     * Link a unit to a packet within a bundle, following the existing
     * AggregationController pattern. The packet must already be part
     * of the bundle.
     */
    public function linkUnitToBundle(Request $request, string $bundleId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            $data = $request->validate([
                'unit_code_id' => ['required', 'uuid', 'exists:unit_codes,id'],
                'packet_code_id' => ['required', 'uuid', 'exists:packet_codes,id'],
                'product_id' => ['nullable', 'uuid', 'exists:products,id'],
            ]);

            $unitCodeId = (string) $data['unit_code_id'];
            $packetCodeId = (string) $data['packet_code_id'];
            // product_id is optional — if omitted we auto-detect from the unit
            $productId = isset($data['product_id'])
                ? (string) $data['product_id']
                : null;

            // Verify the packet is actually part of this bundle
            $packetInBundle = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->where('packet_code_id', $packetCodeId)
                ->exists();

            if (!$packetInBundle) {
                return response()->json([
                    'success' => false,
                    'message' => 'The specified packet is not part of this bundle. Link the packet to the bundle first.',
                ], 422);
            }

            // Verify the unit exists and is available (unlinked)
            $unit = UnitCode::with('baseCode')->where('id', $unitCodeId)->first();

            if (!$unit || !$unit->baseCode) {
                return response()->json(['success' => false, 'message' => 'Unit not found'], 404);
            }

            if ($unit->packet_code_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'This unit is already linked to a packet',
                ], 422);
            }

            // Auto-detect product_id from the unit if not provided by client
            if ($productId === null) {
                $productId = $unit->baseCode->product_id;
            }

            // Verify product match
            if ($unit->baseCode->product_id !== $productId) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unit product does not match the specified product_id',
                ], 422);
            }

            DB::transaction(function () use ($unitCodeId, $packetCodeId) {
                // Link unit to packet (same pattern as AggregationController)
                UnitCode::where('id', $unitCodeId)->update([
                    'packet_code_id' => $packetCodeId,
                ]);

                // Update packet's unit_count
                $currentCount = UnitCode::where('packet_code_id', $packetCodeId)->count();

                // Update unit_codes array (PostgreSQL UUID[])
                $existingRaw = DB::table('packet_codes')
                    ->where('id', $packetCodeId)
                    ->value('unit_codes');

                $existing = [];
                if ($existingRaw && $existingRaw !== '{}') {
                    $inner = trim($existingRaw, '{}');
                    if ($inner !== '') {
                        $existing = array_map('trim', explode(',', $inner));
                    }
                }

                $merged = array_merge($existing, [$unitCodeId]);
                $merged = array_unique($merged);
                $pgArray = '{' . implode(',', $merged) . '}';

                DB::table('packet_codes')
                    ->where('id', $packetCodeId)
                    ->update([
                        'unit_count' => $currentCount,
                        'unit_codes' => $pgArray,
                    ]);
            });

            Log::info('Unit linked to bundle via packet', [
                'bundle_id' => $bundleId,
                'unit_code_id' => $unitCodeId,
                'packet_code_id' => $packetCodeId,
                'store_keeper_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'bundleId' => $bundleId,
                    'unitCodeId' => $unitCodeId,
                    'packetCodeId' => $packetCodeId,
                    'linked' => true,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle linkUnitToBundle failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Bundle Summary ─────────────────────────────────────────

    /**
     * Return a summary of the bundle with linked item counts.
     */
    public function bundleSummary(Request $request, string $bundleId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->leftJoin('store_keepers', 'bundles.store_keeper_id', '=', 'store_keepers.id')
                ->where('bundles.id', $bundleId)
                ->where('bundles.company_id', $companyId)
                ->select('bundles.*', 'store_keepers.name as store_keeper_name')
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            $linkedCartonsCount = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->whereNotNull('carton_code_id')
                ->count();

            $linkedPacketsCount = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->whereNotNull('packet_code_id')
                ->count();

            // Count units linked to packets that belong to this bundle
            $packetIdsInBundle = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->whereNotNull('packet_code_id')
                ->pluck('packet_code_id')
                ->toArray();

            $linkedUnitsCount = !empty($packetIdsInBundle)
                ? UnitCode::whereIn('packet_code_id', $packetIdsInBundle)->count()
                : 0;

            $qrData = null;
            if ($bundle->bundle_qr_data) {
                $qrData = json_decode($bundle->bundle_qr_data, true);
            }

            $totalCartons = (int) $bundle->total_cartons;
            $totalPackets = (int) $bundle->total_packets;

            $missing = [
                'cartons' => max(0, $totalCartons - $linkedCartonsCount),
                'packets' => max(0, $totalPackets - $linkedPacketsCount),
            ];

            // Also collect linked IDs for the Flutter packet-selector UI
            $linkedCartonIds = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->whereNotNull('carton_code_id')
                ->pluck('carton_code_id')->toArray();
            $linkedPacketIds = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->whereNotNull('packet_code_id')
                ->pluck('packet_code_id')->toArray();

            // Resolve linked units with product names
            $linkedUnits = [];
            if (!empty($packetIdsInBundle)) {
                $unitRows = DB::table('unit_codes')
                    ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
                    ->leftJoin('products', 'base_codes.product_id', '=', 'products.id')
                    ->whereIn('unit_codes.packet_code_id', $packetIdsInBundle)
                    ->select('unit_codes.id', 'unit_codes.packet_code_id', 'base_codes.code as unit_code', 'products.name as product_name')
                    ->get();
                foreach ($unitRows as $u) {
                    $linkedUnits[] = [
                        'id' => $u->id,
                        'packetCodeId' => $u->packet_code_id,
                        'unitCode' => $u->unit_code ?? null,
                        'productName' => $u->product_name,
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'bundleCode' => $bundle->bundle_code,
                    'orderReference' => $bundle->order_reference,
                    'linkedCartonsCount' => $linkedCartonsCount,
                    'linkedPacketsCount' => $linkedPacketsCount,
                    'linkedUnitsCount' => $linkedUnitsCount,
                    'linkedCartonIds' => $linkedCartonIds,
                    'linkedPacketIds' => $linkedPacketIds,
                    'linkedUnits' => $linkedUnits,
                    'totalCartons' => $totalCartons,
                    'totalPackets' => $totalPackets,
                    'bundleQrData' => $qrData,
                    'missingItems' => $missing,
                    'linkingStatus' => $bundle->linking_status,
                    'status' => $bundle->status,
                    'storeKeeperId' => $bundle->store_keeper_id,
                    'storeKeeperName' => $bundle->store_keeper_name ?? null,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle bundleSummary failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Update Linking Status ──────────────────────────────────

    /**
     * Update the linking_status of a bundle.
     */
    public function updateLinkingStatus(Request $request, string $bundleId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            $data = $request->validate([
                'linking_status' => ['required', 'string', 'in:admin_linked,pending_store_linking,store_linked'],
            ]);

            $updates = [
                'linking_status' => $data['linking_status'],
                // Also sync the 'status' column so Admin Panel tab filtering works correctly.
                // This ensures orders move from "Draft" → "Pending" → "Linked" tabs.
                'status' => $data['linking_status'],
                'updated_at' => now(),
            ];

            // If moving to store_linked, record the store keeper
            if ($data['linking_status'] === 'store_linked') {
                $updates['store_keeper_id'] = $user->id;
            }

            DB::table('bundles')->where('id', $bundleId)->update($updates);

            $updated = DB::table('bundles')->where('id', $bundleId)->first();

            Log::info('Bundle linking status updated', [
                'bundle_id' => $bundleId,
                'linking_status' => $data['linking_status'],
                'store_keeper_id' => $user->id,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $updated->id,
                    'bundleCode' => $updated->bundle_code,
                    'linkingStatus' => $updated->linking_status,
                    'storeKeeperId' => $updated->store_keeper_id,
                    'updatedAt' => $updated->updated_at,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle updateLinkingStatus failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Unlink Carton from Bundle ─────────────────────────────

    public function unlinkCartonFromBundle(Request $request, string $bundleId, string $cartonId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            $deleted = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->where('carton_code_id', $cartonId)
                ->delete();

            if ($deleted === 0) {
                return response()->json(['success' => false, 'message' => 'Carton not found in this bundle'], 404);
            }

            $this->recalculateBundleTotals($bundleId);

            return response()->json([
                'success' => true,
                'data' => ['bundleId' => $bundleId, 'cartonCodeId' => $cartonId, 'unlinked' => true],
            ]);
        } catch (\Exception $e) {
            Log::error('unlinkCarton failed: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Unlink Packet from Bundle ─────────────────────────────

    public function unlinkPacketFromBundle(Request $request, string $bundleId, string $packetId)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;

            $bundle = DB::table('bundles')
                ->where('id', $bundleId)
                ->where('company_id', $companyId)
                ->first();

            if (!$bundle) {
                return response()->json(['success' => false, 'message' => 'Bundle not found'], 404);
            }

            UnitCode::where('packet_code_id', $packetId)->update(['packet_code_id' => null]);

            $deleted = DB::table('bundle_items')
                ->where('bundle_id', $bundleId)
                ->where('packet_code_id', $packetId)
                ->delete();

            if ($deleted === 0) {
                return response()->json(['success' => false, 'message' => 'Packet not found in this bundle'], 404);
            }

            $this->recalculateBundleTotals($bundleId);

            return response()->json([
                'success' => true,
                'data' => ['bundleId' => $bundleId, 'packetCodeId' => $packetId, 'unlinked' => true],
            ]);
        } catch (\Exception $e) {
            Log::error('unlinkPacket failed: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // ─── Store Keeper History ──────────────────────────────────

    /**
     * Return orders processed by the current store keeper.
     * GET /factory/store-keeper-bundles/history?period=today|yesterday|earlier
     */
    public function history(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;
            $period = $request->query('period', 'today');

            $query = DB::table('bundles')
                ->where('company_id', $companyId)
                ->where('linking_status', 'store_linked')
                ->where('store_keeper_id', $user->id);

            $todayStart = now()->startOfDay();
            $yesterdayStart = now()->subDay()->startOfDay();

            switch ($period) {
                case 'today':
                    $query->where('updated_at', '>=', $todayStart);
                    break;
                case 'yesterday':
                    $query->whereBetween('updated_at', [$yesterdayStart, $todayStart]);
                    break;
                case 'earlier':
                    $query->where('updated_at', '<', $yesterdayStart);
                    break;
                default:
                    // all — no date filter
            }

            $orders = $query->orderByDesc('updated_at')
                ->get()
                ->map(function ($b) {
                    return [
                        'id' => $b->id,
                        'bundleCode' => $b->bundle_code,
                        'orderReference' => $b->order_reference,
                        'totalCartons' => (int) $b->total_cartons,
                        'totalPackets' => (int) $b->total_packets,
                        'linkingStatus' => $b->linking_status,
                        'status' => $b->status,
                        'finalizedAt' => $b->updated_at,
                    ];
                })
                ->values();

            // Also count units per bundle
            $orders = $orders->map(function ($order) {
                $packetIds = DB::table('bundle_items')
                    ->where('bundle_id', $order['id'])
                    ->whereNotNull('packet_code_id')
                    ->pluck('packet_code_id')->toArray();
                $order['totalUnits'] = !empty($packetIds)
                    ? UnitCode::whereIn('packet_code_id', $packetIds)->count()
                    : 0;
                return $order;
            });

            return response()->json([
                'success' => true,
                'data' => [
                    'orders' => $orders,
                    'total' => $orders->count(),
                    'period' => $period,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle history failed: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }

    // --- Test QR Codes -------------------------------------------------

    /**
     * Return available carton / packet / unit codes for QR test panel.
     */
    public function testCodes(Request $request)
    {
        try {
            $user = $request->user();
            $companyId = (string) $user->company_id;
            $type = $request->query('type', 'all');

            $cartons = [];
            $packets = [];
            $units = [];

            if ($type === 'all' || $type === 'carton') {
                $cartons = DB::table('carton_codes')

                    ->orderByDesc('created_at')
                    ->limit(20)
                    ->get()
                    ->map(fn($c) => [
                        'id' => $c->id,
                        'code' => $c->carton_code ?? $c->id,
                        'label' => $c->carton_code ?? ('Carton-' . substr($c->id, 0, 8)),
                        'type' => 'carton',
                    ])
                    ->values();
            }

            if ($type === 'all' || $type === 'packet') {
                $packets = DB::table('packet_codes')

                    ->orderByDesc('created_at')
                    ->limit(20)
                    ->get()
                    ->map(fn($p) => [
                        'id' => $p->id,
                        'code' => $p->packet_code ?? $p->id,
                        'label' => $p->packet_code ?? ('Packet-' . substr($p->id, 0, 8)),
                        'type' => 'packet',
                    ])
                    ->values();
            }

            if ($type === 'all' || $type === 'unit') {
                $units = DB::table('unit_codes')

                    ->orderByDesc('created_at')
                    ->limit(20)
                    ->get()
                    ->map(fn($u) => [
                        'id' => $u->id,
                        'code' => $u->unit_code ?? $u->id,
                        'label' => $u->unit_code ?? ('Unit-' . substr($u->id, 0, 8)),
                        'type' => 'unit',
                    ])
                    ->values();
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'cartons' => $cartons,
                    'packets' => $packets,
                    'units' => $units,
                    'total' => count($cartons) + count($packets) + count($units),
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('StoreKeeperBundle testCodes failed: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['success' => false, 'message' => 'Server error: ' . $e->getMessage()], 500);
        }
    }
    // ─── Helpers ─────────────────────────────────────────────────

    /**
     * Recalculate total_cartons and total_packets for a bundle.
     */
    private function recalculateBundleTotals(string $bundleId): void
    {
        $totalCartons = DB::table('bundle_items')
            ->where('bundle_id', $bundleId)
            ->whereNotNull('carton_code_id')
            ->count();

        $totalPackets = DB::table('bundle_items')
            ->where('bundle_id', $bundleId)
            ->whereNotNull('packet_code_id')
            ->count();

        DB::table('bundles')
            ->where('id', $bundleId)
            ->update([
                'total_cartons' => $totalCartons,
                'total_packets' => $totalPackets,
                'updated_at' => now(),
            ]);
    }
}
