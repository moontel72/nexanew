<?php

namespace App\Http\Controllers\Reseller;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ResellerMarketplaceController extends Controller
{
    /**
     * List factories (Companies) available on the marketplace.
     * Only returns active, verified companies.
     */
    public function factories(Request $request): JsonResponse
    {
        $tenantId = $request->query('tenant_id', 'default');

        $factories = Company::where('status', 'active')
            ->where('is_deleted', false)
            ->whereHas('products', function ($q) {
                $q->where('marketplace_enabled', true)->where('status', 'active');
            })
            ->select([
                'id',
                'name',
                'city',
                'address as location',
                'status',
                'logo_url',
            ])
            ->withCount(['products as product_count' => function ($query) {
                $query->where('status', 'active')->where('marketplace_enabled', true);
            }])
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $factories,
            'total' => $factories->count(),
        ]);
    }

    /**
     * Browse products. If factory_id is provided, filter by that factory.
     * Otherwise, return products from all active factories with marketplace_enabled = true.
     */
    public function products(Request $request): JsonResponse
    {
        $request->validate([
            'factory_id' => 'nullable|string',
            'tenant_id' => 'nullable|string',
            'search' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        $factoryId = $request->query('factory_id');
        $search = $request->query('search');
        $limit = (int) $request->query('limit', 20);

        $query = Product::where('status', 'active')
            ->where('marketplace_enabled', true)
            ->select([
                'id', 'company_id', 'name', 'sku', 'description', 'category', 'product_type',
                'image_urls', 'status',
                'unit_price', 'carton_price', 'wholesale_price', 'currency',
                'discount_type', 'discount_value', 'moq', 'marketplace_enabled',
                'bonus_quantity', 'bonus_threshold', 'wallet_credit',
                'promo_code', 'promo_discount', 'tags', 'volume_discounts',
            ]);

        // Filter by factory if provided, otherwise get from all active factories
        if ($factoryId) {
            $query->where('company_id', $factoryId);

            // Verify factory exists and is active
            $factory = Company::where('id', $factoryId)
                ->where('status', 'active')
                ->where('is_deleted', false)
                ->first();

            if (!$factory) {
                return response()->json([
                    'success' => false,
                    'message' => 'Factory not found or inactive.',
                ], 404);
            }
        }

        // Always filter out products from suspended/inactive factories
        $query->whereHas('company', function ($q) {
            $q->where('status', 'active')
              ->where('is_deleted', false);
        });

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('sku', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        // Eager-load company for factory info
        $query->with('company:id,name,city,logo_url,status');

        $products = $query->orderBy('name')
            ->paginate($limit);

        // Map factory info into each product
        $data = collect($products->items())->map(function ($product) {
            $arr = $product->toArray();
            $arr['factory_name'] = $product->company->name ?? null;
            $arr['factory_city'] = $product->company->city ?? null;
            $arr['factory_logo'] = $product->company->logo_url ?? null;
            $arr['factory_status'] = $product->company->status ?? null;
            return $arr;
        })->toArray();

        return response()->json([
            'success' => true,
            'data' => $data,
            'total' => $products->total(),
            'page' => $products->currentPage(),
            'per_page' => $products->perPage(),
            'total_pages' => $products->lastPage(),
        ]);
    }
}
