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
                    ->findOrFail($itemInput['item_id']);

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
                $item = CateringItem::findOrFail($issuanceItem->item_id);
                $item->decrementStock($issuanceItem->quantity_issued);
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
                $issuanceItem = $issuance->items()->where('item_id', $input['item_id'])->firstOrFail();

                $returned = (int) ($input['quantity_returned'] ?? 0);
                $sold     = (int) ($input['quantity_sold'] ?? 0);

                $issuanceItem->update([
                    'quantity_returned' => $returned,
                    'quantity_sold'     => $sold,
                ]);

                // Return unsold items to stock
                if ($returned > 0) {
                    $cateringItem = CateringItem::findOrFail($issuanceItem->item_id);
                    $cateringItem->incrementStock($returned);
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
}
