<?php

namespace App\Http\Controllers\Transport;

use App\Http\Controllers\Controller;
use App\Models\CateringCategory;
use App\Models\CateringIssuance;
use App\Models\CateringIssuanceItem;
use App\Models\CateringItem;
use App\Models\CateringReconciliation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * StoreKeeper Inventory Controller
 *
 * Handles the full inventory lifecycle for the Bus Fleet storekeeper role:
 *   - Category & Item management
 *   - Issuance workflow (create → issue → reconcile)
 *   - Reconciliation with variance tracking
 *
 * All operations are scoped to the authenticated storekeeper's company_id.
 * RBAC: Only users with a fleet_assignment role of 'store_keeper' should access these routes.
 */
class StoreKeeperInventoryController extends Controller
{
    // ═══════════════════════════════════════════════════════════
    // CATEGORIES
    // ═══════════════════════════════════════════════════════════

    public function listCategories(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);
        $categories = CateringCategory::forCompany($companyId)
            ->ordered()
            ->withCount('items')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $categories,
        ]);
    }

    public function storeCategory(Request $request)
    {
        $data = $request->validate([
            'name'      => ['required', 'string', 'max:150'],
            'icon'      => ['nullable', 'string', 'max:100'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);

        $category = CateringCategory::create([
            'company_id' => $this->resolveCompanyId($request),
            ...$data,
        ]);

        return response()->json(['success' => true, 'data' => $category], 201);
    }

    public function updateCategory(Request $request, string $id)
    {
        $category = $this->findCategoryForCompany($request, $id);

        $data = $request->validate([
            'name'      => ['sometimes', 'string', 'max:150'],
            'icon'      => ['nullable', 'string', 'max:100'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);

        $category->update($data);

        return response()->json(['success' => true, 'data' => $category]);
    }

    public function destroyCategory(Request $request, string $id)
    {
        $category = $this->findCategoryForCompany($request, $id);

        $itemCount = $category->items()->count();
        if ($itemCount > 0) {
            return response()->json([
                'success' => false,
                'message' => "Cannot delete category with {$itemCount} items. Move or delete items first.",
            ], 422);
        }

        $category->delete();

        return response()->json(['success' => true, 'message' => 'Category deleted.']);
    }

    // ═══════════════════════════════════════════════════════════
    // ITEMS
    // ═══════════════════════════════════════════════════════════

    public function listItems(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);
        $query = CateringItem::forCompany($companyId)->with('category');

        if ($categoryId = $request->query('category_id')) {
            $query->where('category_id', $categoryId);
        }
        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }
        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ILIKE', "%{$search}%")
                  ->orWhere('sku', 'ILIKE', "%{$search}%");
            });
        }
        if ($request->boolean('low_stock')) {
            $query->lowStock();
        }

        $page  = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 50)));

        $paginator = $query->orderBy('name')->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data'    => $paginator->items(),
            'meta'    => [
                'current_page' => $paginator->currentPage(),
                'last_page'    => $paginator->lastPage(),
                'total'        => $paginator->total(),
            ],
        ]);
    }

    public function showItem(Request $request, string $id)
    {
        $item = $this->findItemForCompany($request, $id);
        $item->load('category');

        return response()->json(['success' => true, 'data' => $item]);
    }

    public function storeItem(Request $request)
    {
        $data = $request->validate([
            'category_id'        => ['nullable', 'uuid'],
            'name'               => ['required', 'string', 'max:200'],
            'sku'                => ['nullable', 'string', 'max:80'],
            'unit'               => ['nullable', 'string', 'max:50'],
            'stock_on_hand'      => ['nullable', 'integer', 'min:0'],
            'low_stock_threshold' => ['nullable', 'integer', 'min:0'],
            'unit_price_paisa'   => ['nullable', 'integer', 'min:0'],
            'image_url'          => ['nullable', 'string'],
            'status'             => ['nullable', 'in:active,discontinued'],
        ]);

        $item = CateringItem::create([
            'company_id' => $this->resolveCompanyId($request),
            ...$data,
        ]);

        $item->load('category');

        return response()->json(['success' => true, 'data' => $item], 201);
    }

    public function updateItem(Request $request, string $id)
    {
        $item = $this->findItemForCompany($request, $id);

        $data = $request->validate([
            'category_id'        => ['nullable', 'uuid'],
            'name'               => ['sometimes', 'string', 'max:200'],
            'sku'                => ['nullable', 'string', 'max:80'],
            'unit'               => ['nullable', 'string', 'max:50'],
            'stock_on_hand'      => ['nullable', 'integer', 'min:0'],
            'low_stock_threshold' => ['nullable', 'integer', 'min:0'],
            'unit_price_paisa'   => ['nullable', 'integer', 'min:0'],
            'image_url'          => ['nullable', 'string'],
            'status'             => ['nullable', 'in:active,discontinued'],
        ]);

        $item->update($data);
        $item->load('category');

        return response()->json(['success' => true, 'data' => $item]);
    }

    public function destroyItem(Request $request, string $id)
    {
        $item = $this->findItemForCompany($request, $id);
        $item->delete();

        return response()->json(['success' => true, 'message' => 'Item deleted.']);
    }

    /**
     * Adjust stock for an item (add or remove).
     */
    public function adjustStock(Request $request, string $id)
    {
        $item = $this->findItemForCompany($request, $id);

        $data = $request->validate([
            'adjustment' => ['required', 'integer'],
            'reason'     => ['nullable', 'string', 'max:255'],
        ]);

        $newStock = max(0, $item->stock_on_hand + $data['adjustment']);
        $item->update(['stock_on_hand' => $newStock]);

        Log::info('Catering stock adjusted', [
            'item_id'    => $item->id,
            'item_name'  => $item->name,
            'adjustment' => $data['adjustment'],
            'new_stock'  => $newStock,
            'reason'     => $data['reason'] ?? 'manual',
            'user_id'    => $request->user()?->id,
        ]);

        return response()->json([
            'success' => true,
            'data'    => ['stock_on_hand' => $newStock],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // ISSUANCES
    // ═══════════════════════════════════════════════════════════

    public function listIssuances(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);
        $query = CateringIssuance::forCompany($companyId)->with(['items.item', 'reconciliation']);

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }
        if ($tripId = $request->query('trip_id')) {
            $query->where('trip_id', $tripId);
        }

        $page  = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 20)));

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data'    => $paginator->items(),
            'meta'    => [
                'current_page' => $paginator->currentPage(),
                'last_page'    => $paginator->lastPage(),
                'total'        => $paginator->total(),
            ],
        ]);
    }

    public function showIssuance(Request $request, string $id)
    {
        $issuance = $this->findIssuanceForCompany($request, $id);
        $issuance->load(['items.item.category', 'reconciliation']);

        return response()->json(['success' => true, 'data' => $issuance]);
    }

    public function createIssuance(Request $request)
    {
        $data = $request->validate([
            'trip_id'        => ['nullable', 'uuid'],
            'route_id'       => ['nullable', 'uuid'],
            'bus_reg_number' => ['nullable', 'string', 'max:50'],
            'conductor_name'  => ['nullable', 'string', 'max:200'],
            'notes'          => ['nullable', 'string'],
            'items'          => ['required', 'array', 'min:1'],
            'items.*.item_id'         => ['required', 'uuid'],
            'items.*.quantity_issued' => ['required', 'integer', 'min:1'],
        ]);

        $companyId = $this->resolveCompanyId($request);
        $storekeeperId = $request->user()?->id;

        $issuance = DB::transaction(function () use ($data, $companyId, $storekeeperId) {
            $issuance = CateringIssuance::create([
                'company_id'     => $companyId,
                'storekeeper_id' => $storekeeperId,
                'trip_id'        => $data['trip_id'] ?? null,
                'route_id'       => $data['route_id'] ?? null,
                'bus_reg_number' => $data['bus_reg_number'] ?? null,
                'conductor_name'  => $data['conductor_name'] ?? null,
                'status'         => 'pending',
                'notes'          => $data['notes'] ?? null,
            ]);

            foreach ($data['items'] as $itemInput) {
                $cateringItem = CateringItem::forCompany($companyId)
                    ->find($itemInput['item_id']);

                if (!$cateringItem) {
                    continue;
                }

                $unitPrice = $cateringItem->unit_price_paisa;

                CateringIssuanceItem::create([
                    'issuance_id'     => $issuance->id,
                    'item_id'         => $cateringItem->id,
                    'quantity_issued' => $itemInput['quantity_issued'],
                    'unit_price_paisa' => $unitPrice,
                ]);
            }

            return $issuance;
        });

        $issuance->load(['items.item.category']);

        return response()->json(['success' => true, 'data' => $issuance], 201);
    }

    /**
     * Issue the items (deduct from stock).
     */
    public function issueItems(Request $request, string $id)
    {
        $issuance = $this->findIssuanceForCompany($request, $id);

        if ($issuance->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => "Cannot issue — current status is '{$issuance->status}'.",
            ], 422);
        }

        DB::transaction(function () use ($issuance) {
            foreach ($issuance->items as $issuanceItem) {
                $item = CateringItem::find($issuanceItem->item_id);
                if ($item) {
                    $item->decrementStock($issuanceItem->quantity_issued);
                }
            }
            $issuance->markIssued();
        });

        $issuance->load(['items.item.category']);

        return response()->json(['success' => true, 'data' => $issuance]);
    }

    // ═══════════════════════════════════════════════════════════
    // RECONCILIATION
    // ═══════════════════════════════════════════════════════════

    public function listReconciliations(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);
        $query = CateringReconciliation::forCompany($companyId)
            ->with(['issuance.items.item', 'storekeeper']);

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $page  = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 20)));

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data'    => $paginator->items(),
            'meta'    => [
                'current_page' => $paginator->currentPage(),
                'last_page'    => $paginator->lastPage(),
                'total'        => $paginator->total(),
            ],
        ]);
    }

    public function reconcile(Request $request, string $issuanceId)
    {
        $issuance = $this->findIssuanceForCompany($request, $issuanceId);

        if (!in_array($issuance->status, ['issued', 'partially_returned'])) {
            return response()->json([
                'success' => false,
                'message' => "Cannot reconcile — issuance status is '{$issuance->status}'.",
            ], 422);
        }

        $data = $request->validate([
            'items'   => ['required', 'array'],
            'items.*.item_id'            => ['required', 'uuid'],
            'items.*.quantity_returned'  => ['nullable', 'integer', 'min:0'],
            'items.*.quantity_sold'      => ['nullable', 'integer', 'min:0'],
            'notes'  => ['nullable', 'string'],
        ]);

        $companyId = $this->resolveCompanyId($request);
        $storekeeperId = $request->user()?->id;

        $reconciliation = DB::transaction(function () use ($issuance, $data, $companyId, $storekeeperId) {
            $totalIssued   = 0;
            $totalReturned = 0;
            $totalSold     = 0;

            foreach ($data['items'] as $input) {
                $issuanceItem = $issuance->items()->where('item_id', $input['item_id'])->first();
                if (!$issuanceItem) {
                    continue; // Skip items not in this issuance
                }

                $returned = (int) ($input['quantity_returned'] ?? 0);
                $sold     = (int) ($input['quantity_sold'] ?? 0);

                $issuanceItem->update([
                    'quantity_returned' => $returned,
                    'quantity_sold'     => $sold,
                ]);

                // Return unsold items to stock
                if ($returned > 0) {
                    $cateringItem = CateringItem::find($issuanceItem->item_id);
                    if ($cateringItem) {
                        $cateringItem->incrementStock($returned);
                    }
                }

                $totalIssued   += $issuanceItem->issued_value_paisa;
                $totalReturned += $issuanceItem->returned_value_paisa;
                $totalSold     += $issuanceItem->sold_value_paisa;
            }

            $variance = ($totalReturned + $totalSold) - $totalIssued;

            // Check for existing reconciliation (update or create)
            $reconciliation = CateringReconciliation::updateOrCreate(
                ['issuance_id' => $issuance->id],
                [
                    'company_id'                => $companyId,
                    'storekeeper_id'            => $storekeeperId,
                    'total_issued_value_paisa'   => $totalIssued,
                    'total_returned_value_paisa' => $totalReturned,
                    'total_sold_value_paisa'     => $totalSold,
                    'variance_paisa'             => $variance,
                    'status'                     => 'draft',
                    'notes'                      => $data['notes'] ?? null,
                ]
            );

            $issuance->markReconciled();

            return $reconciliation;
        });

        $reconciliation->load(['issuance.items.item']);

        return response()->json(['success' => true, 'data' => $reconciliation]);
    }

    public function confirmReconciliation(Request $request, string $reconciliationId)
    {
        $reconciliation = CateringReconciliation::forCompany($this->resolveCompanyId($request))
            ->findOrFail($reconciliationId);

        if ($reconciliation->status !== 'draft') {
            return response()->json([
                'success' => false,
                'message' => "Reconciliation is already '{$reconciliation->status}'.",
            ], 422);
        }

        $reconciliation->confirm();

        return response()->json(['success' => true, 'data' => $reconciliation]);
    }

    // ═══════════════════════════════════════════════════════════
    // DASHBOARD / SUMMARY
    // ═══════════════════════════════════════════════════════════

    public function dashboard(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);

        $totalItems      = CateringItem::forCompany($companyId)->count();
        $activeItems     = CateringItem::forCompany($companyId)->active()->count();
        $lowStockItems   = CateringItem::forCompany($companyId)->lowStock()->count();
        $pendingIssuances = CateringIssuance::forCompany($companyId)->pending()->count();
        $activeIssuances = CateringIssuance::forCompany($companyId)->active()->count();
        $draftReconciliations = CateringReconciliation::forCompany($companyId)->draft()->count();

        // Total value of outstanding items
        $outstandingValue = DB::table('catering_issuance_items as ii')
            ->join('catering_issuances as i', 'i.id', '=', 'ii.issuance_id')
            ->where('i.company_id', $companyId)
            ->whereIn('i.status', ['issued', 'partially_returned'])
            ->sum(DB::raw('(ii.quantity_issued - ii.quantity_returned - ii.quantity_sold) * ii.unit_price_paisa'));

        return response()->json([
            'success' => true,
            'data'    => [
                'total_items'           => $totalItems,
                'active_items'          => $activeItems,
                'low_stock_items'       => $lowStockItems,
                'pending_issuances'     => $pendingIssuances,
                'active_issuances'      => $activeIssuances,
                'draft_reconciliations' => $draftReconciliations,
                'outstanding_value_paisa' => (int) ($outstandingValue ?? 0),
            ],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // AUDIT TRAIL & SETTLEMENT REPORTS
    // ═══════════════════════════════════════════════════════════

    /**
     * Issuance Audit Trail — which storekeeper issued what to which bus, when.
     */
    public function auditTrail(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);

        $query = DB::table('catering_issuances AS ci')
            ->leftJoin('store_keepers AS sk', 'ci.storekeeper_id', '=', 'sk.id')
            ->select(
                'ci.id',
                'ci.bus_reg_number',
                'ci.conductor_name',
                'ci.status',
                'ci.issued_at',
                'ci.created_at',
                'sk.name AS storekeeper_name',
                'sk.employee_id AS storekeeper_employee_id',
            )
            ->where('ci.company_id', $companyId)
            ->orderByDesc('ci.created_at');

        if ($storekeeperId = $request->query('storekeeper_id')) {
            $query->where('ci.storekeeper_id', $storekeeperId);
        }
        if ($status = $request->query('status')) {
            $query->where('ci.status', $status);
        }

        $page  = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 30)));

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        // Enrich each row with item count
        $items = collect($paginator->items())->map(function ($row) {
            $row->item_count = DB::table('catering_issuance_items')
                ->where('issuance_id', $row->id)
                ->count();
            $row->total_quantity = DB::table('catering_issuance_items')
                ->where('issuance_id', $row->id)
                ->sum('quantity_issued');
            return $row;
        });

        return response()->json([
            'success' => true,
            'data'    => $items,
            'meta'    => [
                'current_page' => $paginator->currentPage(),
                'last_page'    => $paginator->lastPage(),
                'total'        => $paginator->total(),
            ],
        ]);
    }

    /**
     * Financial Settlement Report — per-trip reconciliation ledger.
     * Tracks total cash collected vs inventory variance (shortages/losses).
     */
    public function settlementReport(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);

        $query = DB::table('catering_reconciliations AS cr')
            ->join('catering_issuances AS ci', 'cr.issuance_id', '=', 'ci.id')
            ->leftJoin('store_keepers AS sk', 'cr.storekeeper_id', '=', 'sk.id')
            ->select(
                'cr.id AS reconciliation_id',
                'ci.id AS issuance_id',
                'ci.bus_reg_number',
                'ci.conductor_name',
                'ci.issued_at',
                'cr.total_issued_value_paisa',
                'cr.total_returned_value_paisa',
                'cr.total_sold_value_paisa',
                'cr.variance_paisa',
                'cr.status AS reconciliation_status',
                'cr.reconciled_at',
                'cr.notes',
                'sk.name AS storekeeper_name',
            )
            ->where('cr.company_id', $companyId)
            ->orderByDesc('cr.created_at');

        if ($storekeeperId = $request->query('storekeeper_id')) {
            $query->where('cr.storekeeper_id', $storekeeperId);
        }
        if ($status = $request->query('status')) {
            $query->where('cr.status', $status);
        }

        $page  = (int) $request->query('page', 1);
        $limit = min(100, max(1, (int) $request->query('limit', 30)));

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        // Compute totals
        $totals = DB::table('catering_reconciliations AS cr')
            ->where('cr.company_id', $companyId)
            ->when($storekeeperId, fn($q) => $q->where('cr.storekeeper_id', $storekeeperId))
            ->when($status, fn($q) => $q->where('cr.status', $status))
            ->selectRaw('SUM(cr.total_sold_value_paisa) AS total_cash_collected, SUM(cr.variance_paisa) AS total_variance')
            ->first();

        return response()->json([
            'success' => true,
            'data'    => $paginator->items(),
            'meta'    => [
                'current_page'         => $paginator->currentPage(),
                'last_page'            => $paginator->lastPage(),
                'total'                => $paginator->total(),
                'total_cash_collected' => (int) ($totals->total_cash_collected ?? 0),
                'total_variance'       => (int) ($totals->total_variance ?? 0),
            ],
        ]);
    }

    // ═══════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════

    private function resolveCompanyId(Request $request): string
    {
        // Use _carrier_company_id set by BusFleetGate middleware if available,
        // otherwise fall back to the user's own company_id.
        return (string) ($request->get('_carrier_company_id')
            ?? $request->user()?->company_id
            ?? '');
    }

    private function findCategoryForCompany(Request $request, string $id): CateringCategory
    {
        return CateringCategory::forCompany($this->resolveCompanyId($request))
            ->findOrFail($id);
    }

    private function findItemForCompany(Request $request, string $id): CateringItem
    {
        return CateringItem::forCompany($this->resolveCompanyId($request))
            ->findOrFail($id);
    }

    private function findIssuanceForCompany(Request $request, string $id): CateringIssuance
    {
        return CateringIssuance::forCompany($this->resolveCompanyId($request))
            ->findOrFail($id);
    }

    // ═══════════════════════════════════════════════════════════
    // BUNDLE & SMART CODE MANAGEMENT
    // ═══════════════════════════════════════════════════════════

    public function listBundles(Request $request)
    {
        $companyId = $this->resolveCompanyId($request);
        $bundles = DB::table('catering_bundles')
            ->where('company_id', $companyId)
            ->orderByDesc('created_at')
            ->get()
            ->map(function ($b) use ($companyId) {
                $b->packets = DB::table('catering_packets')
                    ->where('bundle_id', $b->id)
                    ->get();
                return $b;
            });

        return response()->json(['success' => true, 'data' => $bundles]);
    }

    public function storeBundle(Request $request)
    {
        $data = $request->validate([
            'name'        => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string'],
            'packets'     => ['required', 'array', 'min:1'],
            'packets.*.name'         => ['required', 'string', 'max:200'],
            'packets.*.item_id'      => ['nullable', 'uuid'],
            'packets.*.total_units'  => ['required', 'integer', 'min:1'],
        ]);

        $companyId = $this->resolveCompanyId($request);

        return DB::transaction(function () use ($data, $companyId) {
            $bundleId = (string) \Illuminate\Support\Str::orderedUuid();

            DB::table('catering_bundles')->insert([
                'id'          => $bundleId,
                'company_id'  => $companyId,
                'name'        => $data['name'],
                'description' => $data['description'] ?? null,
                'status'      => 'active',
                'created_at'  => now(),
                'updated_at'  => now(),
            ]);

            $packets = [];
            foreach ($data['packets'] as $pkt) {
                $smartCode = '#' . $this->generateSmartCode();
                $totalUnits = (int) $pkt['total_units'];
                $packetId = (string) \Illuminate\Support\Str::orderedUuid();

                DB::table('catering_packets')->insert([
                    'id'              => $packetId,
                    'bundle_id'       => $bundleId,
                    'company_id'      => $companyId,
                    'item_id'         => $pkt['item_id'] ?? null,
                    'name'            => $pkt['name'],
                    'smart_code'      => $smartCode,
                    'total_units'     => $totalUnits,
                    'units_remaining' => $totalUnits,
                    'status'          => 'active',
                    'created_at'      => now(),
                    'updated_at'      => now(),
                ]);

                $packets[] = [
                    'id'              => $packetId,
                    'name'            => $pkt['name'],
                    'smart_code'      => $smartCode,
                    'total_units'     => $totalUnits,
                    'units_remaining' => $totalUnits,
                ];
            }

            return response()->json([
                'success' => true,
                'data'    => [
                    'id'          => $bundleId,
                    'name'        => $data['name'],
                    'description' => $data['description'] ?? null,
                    'status'      => 'active',
                    'packets'     => $packets,
                ],
            ], 201);
        });
    }

    public function showBundle(Request $request, string $id)
    {
        $companyId = $this->resolveCompanyId($request);
        $bundle = DB::table('catering_bundles')
            ->where('company_id', $companyId)
            ->where('id', $id)
            ->first();

        if (!$bundle) {
            return response()->json(['success' => false, 'message' => 'Bundle not found.'], 404);
        }

        $bundle->packets = DB::table('catering_packets')
            ->where('bundle_id', $id)
            ->get();

        return response()->json(['success' => true, 'data' => $bundle]);
    }

    public function updateBundle(Request $request, string $id)
    {
        $companyId = $this->resolveCompanyId($request);
        $bundle = DB::table('catering_bundles')
            ->where('company_id', $companyId)->where('id', $id)->first();

        if (!$bundle) {
            return response()->json(['success' => false, 'message' => 'Bundle not found.'], 404);
        }

        $data = $request->validate([
            'name'        => ['sometimes', 'string', 'max:200'],
            'description' => ['nullable', 'string'],
            'status'      => ['sometimes', 'in:draft,active,archived'],
        ]);

        DB::table('catering_bundles')->where('id', $id)->update([
            'name'        => $data['name'] ?? $bundle->name,
            'description' => $data['description'] ?? $bundle->description,
            'status'      => $data['status'] ?? $bundle->status,
            'updated_at'  => now(),
        ]);

        return response()->json(['success' => true, 'message' => 'Bundle updated.']);
    }

    public function destroyBundle(Request $request, string $id)
    {
        $companyId = $this->resolveCompanyId($request);
        DB::table('catering_packets')->where('bundle_id', $id)->delete();
        DB::table('catering_bundles')->where('company_id', $companyId)->where('id', $id)->delete();

        return response()->json(['success' => true, 'message' => 'Bundle deleted.']);
    }

    public function findPacketByCode(Request $request, string $code)
    {
        $packet = DB::table('catering_packets')->where('smart_code', '#' . $code)->first();

        if (!$packet) {
            return response()->json(['success' => false, 'message' => 'Smart code not found.'], 404);
        }

        return response()->json(['success' => true, 'data' => $packet]);
    }

    public function uploadPacketPhoto(Request $request, string $id)
    {
        $request->validate(['photo' => ['required', 'image', 'max:10240']]);

        $path = $request->file('photo')->store('catering/packets', 'public');

        DB::table('catering_packets')->where('id', $id)->update([
            'photo_url' => '/storage/' . $path,
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'data' => ['photo_url' => '/storage/' . $path]]);
    }

    private function generateSmartCode(int $attempts = 0): string
    {
        if ($attempts > 10) {
            throw new \RuntimeException('Unable to generate unique smart code.');
        }
        $code = str_pad((string) random_int(0, 99999), 5, '0', STR_PAD_LEFT);
        $exists = DB::table('catering_packets')->where('smart_code', '#' . $code)->exists();
        return $exists ? $this->generateSmartCode($attempts + 1) : $code;
    }
}
