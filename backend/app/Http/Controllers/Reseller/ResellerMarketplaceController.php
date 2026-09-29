<?php

namespace App\Http\Controllers\Reseller;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ResellerMarketplaceController extends Controller
{
    /**
     * List factories (Companies) available on the marketplace.
     * Only returns active, verified companies.
     */
    public function factories(Request $request): JsonResponse
    {
        Log::info('Reseller marketplace: factories() called');

        $tenantId = $request->query('tenant_id', 'default');

        $factories = Company::query()
            // The storefront carries the rating the marketplace already shows on a
            // public page, so the "best first" order the owner asked for is real
            // data, not a guess. The soft-delete filter belongs IN the join — put it
            // in a WHERE and a company whose only storefront was deleted would vanish.
            ->leftJoin('marketplace_storefronts as sf', function ($join) {
                $join->on('sf.company_id', '=', 'companies.id')
                    ->whereNull('sf.deleted_at');
            })
            ->where('companies.status', 'active')
            ->where('companies.is_deleted', false)
            ->whereHas('products', function ($q) {
                $q->where('marketplace_enabled', true)->where('status', 'active');
            })
            ->select([
                'companies.id',
                'companies.name',
                'companies.city',
                'companies.address as location',
                'companies.status',
                'companies.logo_url',
                'sf.rating as rating',
                'sf.total_reviews as total_reviews',
            ])
            ->withCount(['products as product_count' => function ($query) {
                $query->where('status', 'active')->where('marketplace_enabled', true);
            }])
            // Best first: highest rating, then the factory with the most live
            // products, then alphabetical so the order is stable.
            ->orderByDesc('sf.rating')
            ->orderByDesc('product_count')
            ->orderBy('companies.name')
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
            'category' => 'nullable|string|max:100',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
            // Ordering the storefront offers: most viewed first (default), newest,
            // and the two price directions. 'most sold' needs an order aggregate and
            // is tracked in MASTER-TASK-LIST (MUSTAQBIL) — popularity is the honest
            // proxy today.
            'sort_by' => 'nullable|string|in:popular,newest,price_asc,price_desc,name',
        ]);

        $factoryId = $request->query('factory_id');
        $search = $request->query('search');
        $limit = (int) $request->query('limit', 20);

        Log::info('Reseller marketplace: products() called', ['factory_id' => $factoryId, 'search' => $search]);

        $query = Product::where('status', 'active')
            ->where('marketplace_enabled', true)
            ->select([
                'id', 'company_id', 'name', 'sku', 'description', 'category', 'product_type',
                'image_urls', 'metadata', 'status',
                'unit_price', 'carton_price', 'wholesale_price', 'currency',
                'discount_type', 'discount_value', 'moq', 'marketplace_enabled',
                'bonus_quantity', 'bonus_threshold', 'wallet_credit',
                'promo_code', 'promo_discount', 'tags', 'volume_discounts',
            ])
            // Popularity = the storefront counters that already exist on the listing
            // (views + inquiries). A correlated sub-select, so a product is never
            // duplicated by its listing row.
            ->addSelect([
                'popularity' => \Illuminate\Support\Facades\DB::table('marketplace_product_listings')
                    ->selectRaw('coalesce(sum(view_count + inquiry_count), 0)')
                    ->whereColumn('marketplace_product_listings.product_id', 'products.id')
                    ->where('marketplace_product_listings.is_active', true)
                    ->whereNull('marketplace_product_listings.deleted_at'),
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

        // Category filter — the storefront's category chips used to filter only the
        // handful of products already on screen, which was quietly wrong once the
        // grid became paged.
        if ($category = $request->query('category')) {
            $query->where('category', $category);
        }

        // Eager-load company for factory info
        $query->with('company:id,name,city,logo_url,status');

        // ─── Ordering ───────────────────────────────────────
        $sortBy = (string) $request->query('sort_by', 'popular');
        match ($sortBy) {
            'newest' => $query->orderByDesc('created_at'),
            'price_asc' => $query->orderByRaw('coalesce(wholesale_price, unit_price, carton_price, 0) asc'),
            'price_desc' => $query->orderByRaw('coalesce(wholesale_price, unit_price, carton_price, 0) desc'),
            'name' => $query->orderBy('name'),
            default => $query->orderByDesc('popularity')->orderBy('name'),
        };

        $products = $query->paginate($limit);

        // Map factory info into each product using snake_case keys for Flutter (matches generated .g.dart)
        $data = collect($products->items())->map(function ($product) {
            // Ensure metadata is always an object or null, never an empty array
            $metadata = $product->metadata;
            if (is_array($metadata) && empty($metadata)) {
                $metadata = null;
            }
            // Inject image_url into metadata so Flutter model can read it
            $imageUrl = $product->metadata['image_url'] ?? ($product->image_urls[0] ?? null);
            if ($imageUrl && is_array($metadata)) {
                $metadata['image_url'] = $imageUrl;
            } elseif ($imageUrl) {
                $metadata = ['image_url' => $imageUrl];
            }

            return [
                'id' => $product->id,
                'tenant_id' => 'default',
                'factory_id' => $product->company_id,
                'name' => $product->name,
                'sku' => $product->sku ?? '',
                'category' => $product->category ?? '',
                'product_type' => $product->product_type ?? '',
                'status' => $product->status,
                'price' => (float) ($product->unit_price ?? 0),
                'currency' => $product->currency ?? 'PKR',
                'factory_name' => $product->company->name ?? null,
                'factory_city' => $product->company->city ?? null,
                'factory_logo' => $product->company->logo_url ?? null,
                'factory_status' => $product->company->status ?? null,
                'carton_price' => $product->carton_price ? (float) $product->carton_price : null,
                'wholesale_price' => $product->wholesale_price ? (float) $product->wholesale_price : null,
                'moq' => $product->moq,
                'bonus_quantity' => $product->bonus_quantity,
                'bonus_threshold' => $product->bonus_threshold,
                'promo_discount' => $product->promo_discount ? (float) $product->promo_discount : null,
                'volume_discounts' => $product->volume_discounts,
                'popularity' => (int) ($product->popularity ?? 0),
                'image_url' => $product->metadata['image_url'] ?? ($product->image_urls[0] ?? null),
                'metadata' => $metadata,
            ];
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
