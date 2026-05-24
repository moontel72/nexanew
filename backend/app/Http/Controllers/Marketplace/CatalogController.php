<?php

namespace App\Http\Controllers\Marketplace;

use App\Http\Controllers\Controller;
use App\Models\Marketplace\ProductListing;
use App\Models\Marketplace\Storefront;
use App\Services\Marketplace\ElasticsearchCatalogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * NEXATRACE — MARKETPLACE CATALOG CONTROLLER
 * ============================================
 *
 * Product search and discovery for the B2B Marketplace (Modules 12A, 12B).
 *
 * SAFETY: Entirely new controller in Marketplace namespace.
 *         Zero modification to existing controllers.
 */

class CatalogController extends Controller
{
    public function __construct(
        private ElasticsearchCatalogService $catalog
    ) {}

    /**
     * GET /api/v1/marketplace/catalog/search?q=...&category=...&sort_by=...
     */
    public function search(Request $request): JsonResponse
    {
        $filters = $request->only([
            'category', 'sub_category', 'min_price', 'max_price',
            'moq_max', 'currency', 'storefront_id', 'tags', 'sort_by',
        ]);

        $results = $this->catalog->search(
            query: (string) $request->query('q', ''),
            filters: $filters,
            page: (int) $request->query('page', 1),
            perPage: (int) $request->query('per_page', 25),
        );

        return response()->json([
            'success' => true,
            'data' => $results,
        ]);
    }

    /**
     * GET /api/v1/marketplace/catalog/facets
     */
    public function facets(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $this->catalog->getFacets(),
        ]);
    }

    /**
     * GET /api/v1/marketplace/catalog/{id}
     */
    public function show(string $id): JsonResponse
    {
        $listing = ProductListing::with('storefront')->findOrFail($id);

        // Increment view count
        $listing->increment('view_count');

        return response()->json([
            'success' => true,
            'data' => $listing,
        ]);
    }

    /**
     * GET /api/v1/marketplace/storefronts
     */
    public function storefronts(): JsonResponse
    {
        $storefronts = Storefront::verified()->active()
            ->withCount('productListings')
            ->orderByDesc('rating')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $storefronts,
        ]);
    }

    /**
     * GET /api/v1/marketplace/storefronts/{slug}
     */
    public function storefrontDetail(string $slug): JsonResponse
    {
        $storefront = Storefront::verified()->active()
            ->where('slug', $slug)
            ->with(['productListings' => fn($q) => $q->active()->orderByDesc('created_at')])
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $storefront,
        ]);
    }
}
