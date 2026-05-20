<?php

namespace App\Http\Controllers\Reseller;

use App\Http\Controllers\Controller;
use App\Models\Reseller;
use App\Models\ResellerOrder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class ResellerOrderController extends Controller
{
    /**
     * Place a new order.
     * POST /api/v1/reseller/orders
     */
    public function store(Request $request): JsonResponse
    {
        $reseller = $this->resolveReseller($request);

        if (!$reseller) {
            return response()->json(['success' => false, 'message' => 'Unauthorized. Reseller not found.'], 403);
        }

        $validated = $request->validate([
            'tenant_id' => 'required|string|max:100',
            'factory_id' => 'required|string|max:36',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|string',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric|min:0',
        ]);

        // Calculate totals
        $subtotal = 0;
        foreach ($validated['items'] as $item) {
            $subtotal += $item['quantity'] * $item['unit_price'];
        }
        $taxTotal = round($subtotal * 0.15, 2); // 15% tax
        $grandTotal = $subtotal + $taxTotal;

        try {
            $order = ResellerOrder::create([
                'reseller_id' => $reseller->id,
                'tenant_id' => $validated['tenant_id'],
                'factory_id' => $validated['factory_id'],
                'order_status' => 'pending',
                'items' => $validated['items'],
                'subtotal' => $subtotal,
                'discount_total' => 0,
                'tax_total' => $taxTotal,
                'grand_total' => $grandTotal,
                'currency' => 'PKR',
            ]);

            Log::info('ResellerOrderController: Order placed.', [
                'order_id' => $order->id,
                'reseller_id' => $reseller->id,
                'factory_id' => $validated['factory_id'],
                'grand_total' => $grandTotal,
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $order->id,
                    'reseller_id' => $order->reseller_id,
                    'tenant_id' => $order->tenant_id,
                    'factory_id' => $order->factory_id,
                    'order_status' => $order->order_status,
                    'items' => $order->items,
                    'total_amount' => (float) $order->grand_total,
                    'subtotal' => (float) $order->subtotal,
                    'discount_total' => (float) $order->discount_total,
                    'tax_total' => (float) $order->tax_total,
                    'grand_total' => (float) $order->grand_total,
                    'currency' => $order->currency,
                    'created_at' => $order->created_at?->toISOString(),
                    'updated_at' => $order->updated_at?->toISOString(),
                ],
            ], 201);
        } catch (\Throwable $e) {
            Log::error('ResellerOrderController: Failed to place order.', [
                'error' => $e->getMessage(),
                'reseller_id' => $reseller->id,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to place order. Please try again.',
            ], 500);
        }
    }

    /**
     * List order history for the authenticated reseller.
     * GET /api/v1/reseller/orders
     */
    public function index(Request $request): JsonResponse
    {
        $reseller = $this->resolveReseller($request);
        if (!$reseller) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $factoryId = $request->query('factory_id');
        $limit = min(100, (int) $request->query('limit', 20));
        $page = (int) $request->query('page', 1);

        $query = ResellerOrder::where('reseller_id', $reseller->id)
            ->orderByDesc('created_at');

        if ($factoryId) {
            $query->where('factory_id', $factoryId);
        }

        $paginator = $query->paginate($limit, ['*'], 'page', $page);

        $data = collect($paginator->items())->map(function (ResellerOrder $order) {
            return [
                'id' => $order->id,
                'reseller_id' => $order->reseller_id,
                'tenant_id' => $order->tenant_id,
                'factory_id' => $order->factory_id,
                'order_status' => $order->order_status,
                'items' => $order->items,
                'total_amount' => (float) $order->grand_total,
                'subtotal' => (float) $order->subtotal,
                'discount_total' => (float) $order->discount_total,
                'tax_total' => (float) $order->tax_total,
                'grand_total' => (float) $order->grand_total,
                'currency' => $order->currency,
                'created_at' => $order->created_at?->toISOString(),
                'updated_at' => $order->updated_at?->toISOString(),
            ];
        })->toArray();

        return response()->json([
            'success' => true,
            'data' => $data,
            'total' => $paginator->total(),
            'page' => $paginator->currentPage(),
            'per_page' => $paginator->perPage(),
            'total_pages' => $paginator->lastPage(),
        ]);
    }

    /**
     * Get a single order's detail.
     * GET /api/v1/reseller/orders/{id}
     */
    public function show(string $id, Request $request): JsonResponse
    {
        $reseller = $this->resolveReseller($request);
        if (!$reseller) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $order = ResellerOrder::where('id', $id)
            ->where('reseller_id', $reseller->id)
            ->first();

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Order not found.'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $order->id,
                'reseller_id' => $order->reseller_id,
                'tenant_id' => $order->tenant_id,
                'factory_id' => $order->factory_id,
                'order_status' => $order->order_status,
                'items' => $order->items,
                'total_amount' => (float) $order->grand_total,
                'subtotal' => (float) $order->subtotal,
                'discount_total' => (float) $order->discount_total,
                'tax_total' => (float) $order->tax_total,
                'grand_total' => (float) $order->grand_total,
                'currency' => $order->currency,
                'created_at' => $order->created_at?->toISOString(),
                'updated_at' => $order->updated_at?->toISOString(),
            ],
        ]);
    }

    /**
     * Resolve the reseller from Sanctum auth, X-Reseller-Id header, or reseller_id body param.
     */
    private function resolveReseller(Request $request): ?Reseller
    {
        $user = $request->user();
        if ($user instanceof Reseller) {
            return $user;
        }
        // Check X-Reseller-Id header
        $resellerId = $request->header('X-Reseller-Id');
        // Also check request body (Flutter sends reseller_id in POST body)
        if (!$resellerId) {
            $resellerId = $request->input('reseller_id');
        }
        if ($resellerId) {
            return Reseller::find($resellerId);
        }
        return null;
    }
}
