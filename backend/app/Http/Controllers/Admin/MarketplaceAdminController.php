<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ResellerOrder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * MARKETPLACE OVERSIGHT — READ-ONLY
 * =================================
 *
 * MASTER-TASK-LIST item #11: the Marketplace section the panels show.
 *
 * WHY THERE IS NO WRITE PATH HERE
 * -------------------------------
 * The owner settled the authority model (2026-09-28): the Super Admin, and each
 * group's Sub-Admin, have **no factory and no product of their own**. They only
 * oversee the marketplace — resolve disputes, look after reseller / shop-keeper
 * account issues (approve, suspend), and change marketplace content. So this
 * controller exposes reads only. Creating or editing an order belongs to the
 * factory (its own orders) and the reseller (its own cart), never to oversight.
 *
 * WHY THE SCOPE IS PLATFORM-WIDE
 * ------------------------------
 * Oversight cannot be scoped to "its own factories": an oversight role owns no
 * factories, so that scope would return nothing and a dispute could never be
 * resolved. Both roles therefore read the whole marketplace. Narrowing this per
 * vertical (so a bus-fleet Sub-Admin sees nothing here) is Phase 6 — the same
 * pending work as every other `admin/*` route today (see `SubAdminResellerController`
 * header and `GROUP-INCHARGE-MODEL.md` §2b.3).
 */
class MarketplaceAdminController extends Controller
{
    /**
     * GET /api/v1/admin/marketplace/orders
     *
     * Read-only, paginated view of every reseller order placed on the marketplace.
     */
    public function orders(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status'      => ['nullable', 'string', 'max:50'],
            'factory_id'  => ['nullable', 'uuid'],
            'reseller_id' => ['nullable', 'uuid'],
            'search'      => ['nullable', 'string', 'max:100'],
            'page'        => ['nullable', 'integer', 'min:1'],
            'limit'       => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $query = ResellerOrder::query()->with([
            'reseller:id,name,business_name,email,phone,city',
            'factory:id,name,city',
        ]);

        if (! empty($filters['status'])) {
            $query->where('order_status', $filters['status']);
        }

        if (! empty($filters['factory_id'])) {
            $query->where('factory_id', $filters['factory_id']);
        }

        if (! empty($filters['reseller_id'])) {
            $query->where('reseller_id', $filters['reseller_id']);
        }

        if (! empty($filters['search'])) {
            $operator = $this->likeOperator();
            $search = $filters['search'];

            $query->whereHas('reseller', function ($q) use ($operator, $search) {
                $q->where('name', $operator, "%{$search}%")
                    ->orWhere('business_name', $operator, "%{$search}%");
            });
        }

        $limit = (int) ($filters['limit'] ?? 25);
        $page = (int) ($filters['page'] ?? 1);

        $paginator = $query->orderByDesc('created_at')->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data'    => $paginator->items(),
            'meta'    => [
                'total'       => $paginator->total(),
                'page'        => $paginator->currentPage(),
                'limit'       => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }

    /**
     * GET /api/v1/admin/marketplace/summary
     *
     * Counts and value per order status, for the marketplace section's tiles.
     */
    public function summary(): JsonResponse
    {
        $byStatus = ResellerOrder::query()
            ->select(
                'order_status',
                DB::raw('COUNT(*) as order_count'),
                DB::raw('COALESCE(SUM(grand_total), 0) as order_value'),
            )
            ->groupBy('order_status')
            ->orderBy('order_status')
            ->get()
            ->map(fn ($row) => [
                'status' => (string) $row->order_status,
                'count'  => (int) $row->order_count,
                'value'  => (float) $row->order_value,
            ])
            ->values();

        return response()->json([
            'success' => true,
            'data'    => [
                'total_orders' => (int) $byStatus->sum('count'),
                'total_value'  => (float) $byStatus->sum('value'),
                'by_status'    => $byStatus,
            ],
        ]);
    }

    /**
     * `ILIKE` is a PostgreSQL feature; sqlite (the test database) only has `LIKE`.
     */
    private function likeOperator(): string
    {
        return DB::connection()->getDriverName() === 'pgsql' ? 'ilike' : 'like';
    }
}
