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
            ->where('verification_status', 'verified')
            ->where('is_deleted', false)
            ->select([
                'id',
                'name',
                'city',
                'address as location',
                'status',
                'logo_url',
            ])
            ->withCount(['products as product_count' => function ($query) {
                $query->where('status', 'active');
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
     * Browse products for a specific factory.
     */
    public function products(Request $request): JsonResponse
    {
        $request->validate([
            'factory_id' => 'required|string',
            'tenant_id' => 'nullable|string',
            'search' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        $factoryId = $request->query('factory_id');
        $search = $request->query('search');
        $limit = (int) $request->query('limit', 20);

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

        $query = Product::where('company_id', $factoryId)
            ->where('status', 'active')
            ->select([
                'id',
                'company_id',
                'name',
                'sku',
                'description',
                'category',
                'product_type',
                'image_urls',
                'status',
            ]);

        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('sku', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $products = $query->orderBy('name')
            ->paginate($limit);

        return response()->json([
            'success' => true,
            'data' => $products->items(),
            'total' => $products->total(),
            'page' => $products->currentPage(),
            'per_page' => $products->perPage(),
            'total_pages' => $products->lastPage(),
        ]);
    }
}
