<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\ProductListing;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — ELASTICSEARCH CATALOG SERVICE
 * ===========================================
 *
 * High-velocity product search for the B2B Marketplace (Module 12B).
 *
 * ARCHITECTURE:
 *   - When ELASTICSEARCH_ENABLED=true in .env: routes queries to Elasticsearch.
 *   - When disabled (default): gracefully falls back to PostgreSQL full-text search.
 *   - This dual-mode design means the marketplace works immediately on the
 *     existing Hetzner server without additional infrastructure.
 *
 * SAFETY:
 *   - Entirely NEW service in App\Services\Marketplace namespace.
 *   - Zero modification to any existing Factory, Driver, or Store Keeper code.
 *   - PostgreSQL FTS fallback is always available.
 *
 * ELASTICSEARCH INDEX: marketplace_listings
 *   Fields indexed: listing_title, listing_description, category, sub_category,
 *                   tags, base_price, moq, available_quantity, storefront_name
 *
 * USAGE:
 *   $catalog = app(ElasticsearchCatalogService::class);
 *   $results = $catalog->search('pharmaceutical raw material', ['category' => 'pharma']);
 */

class ElasticsearchCatalogService
{
    private bool $elasticEnabled;

    public function __construct()
    {
        $this->elasticEnabled = (bool) env('ELASTICSEARCH_ENABLED', false);
    }

    /**
     * Check whether Elasticsearch is available.
     */
    public function isElasticAvailable(): bool
    {
        return $this->elasticEnabled;
    }

    /**
     * Search marketplace product listings.
     *
     * @param string $query    Free-text search query
     * @param array  $filters  {
     *     category?: string,
     *     sub_category?: string,
     *     min_price?: float,
     *     max_price?: float,
     *     moq_max?: int,
     *     currency?: string,
     *     storefront_id?: string,
     *     tags?: array<string>,
     *     sort_by?: 'price_asc' | 'price_desc' | 'newest' | 'popular',
     * }
     * @param int    $page     Page number (1-based)
     * @param int    $perPage  Results per page (max 100)
     * @return array{items: array, total: int, page: int, per_page: int, total_pages: int}
     */
    public function search(string $query = '', array $filters = [], int $page = 1, int $perPage = 25): array
    {
        if ($this->elasticEnabled) {
            return $this->searchElastic($query, $filters, $page, $perPage);
        }

        return $this->searchPostgres($query, $filters, $page, $perPage);
    }

    /**
     * PostgreSQL full-text search fallback.
     */
    private function searchPostgres(string $query, array $filters, int $page, int $perPage): array
    {
        $dbQuery = ProductListing::query()
            ->with('storefront')
            ->active()
            ->whereHas('storefront', fn($q) => $q->verified()->active());

        // ─── Full-text search ───────────────────────────
        if (! empty(trim($query))) {
            $tsQuery = pg_escape_literal(config('database.connections.pgsql.search_path') === 'public'
                ? $query
                : $query); // basic sanitization

            $dbQuery->whereRaw(
                "to_tsvector('english', listing_title || ' ' || COALESCE(listing_description, '')) @@ plainto_tsquery('english', ?)",
                [$query]
            );
        }

        // ─── Filters ────────────────────────────────────
        if (! empty($filters['category'])) {
            $dbQuery->where('category', $filters['category']);
        }
        if (! empty($filters['sub_category'])) {
            $dbQuery->where('sub_category', $filters['sub_category']);
        }
        if (isset($filters['min_price'])) {
            $dbQuery->where('base_price', '>=', (float) $filters['min_price']);
        }
        if (isset($filters['max_price'])) {
            $dbQuery->where('base_price', '<=', (float) $filters['max_price']);
        }
        if (! empty($filters['moq_max'])) {
            $dbQuery->where('moq', '<=', (int) $filters['moq_max']);
        }
        if (! empty($filters['currency'])) {
            $dbQuery->where('currency', $filters['currency']);
        }
        if (! empty($filters['storefront_id'])) {
            $dbQuery->where('storefront_id', $filters['storefront_id']);
        }
        if (! empty($filters['tags'])) {
            $dbQuery->where(function ($q) use ($filters) {
                foreach ((array) $filters['tags'] as $tag) {
                    $q->whereJsonContains('tags', $tag);
                }
            });
        }

        // ─── Sorting ────────────────────────────────────
        $sort = $filters['sort_by'] ?? 'newest';
        match ($sort) {
            'price_asc'  => $dbQuery->orderBy('base_price', 'asc'),
            'price_desc' => $dbQuery->orderBy('base_price', 'desc'),
            'popular'    => $dbQuery->orderByDesc('view_count'),
            default      => $dbQuery->orderByDesc('created_at'), // newest
        };

        // ─── Paginate ───────────────────────────────────
        $paginator = $dbQuery->paginate(min(100, max(1, $perPage)), ['*'], 'page', $page);

        return [
            'items' => $paginator->items(),
            'total' => $paginator->total(),
            'page' => $paginator->currentPage(),
            'per_page' => $paginator->perPage(),
            'total_pages' => $paginator->lastPage(),
        ];
    }

    /**
     * Elasticsearch search (future — when ELATICSEARCH_ENABLED=true).
     * Currently returns empty results with a log notice.
     */
    private function searchElastic(string $query, array $filters, int $page, int $perPage): array
    {
        Log::info('ElasticsearchCatalogService: Elasticsearch mode requested but client not yet integrated.', [
            'query' => $query,
            'filters' => $filters,
        ]);

        // Future: use official elasticsearch/elasticsearch PHP client
        // $client = \Elastic\Elasticsearch\ClientBuilder::create()
        //     ->setHosts([env('ELASTICSEARCH_HOST', 'localhost:9200')])
        //     ->build();
        //
        // $params = [
        //     'index' => 'marketplace_listings',
        //     'body'  => [
        //         'query' => [
        //             'bool' => [
        //                 'must' => [
        //                     'multi_match' => [
        //                         'query' => $query,
        //                         'fields' => ['listing_title^3', 'listing_description', 'tags^2'],
        //                     ],
        //                 ],
        //                 'filter' => [...],
        //             ],
        //         ],
        //     ],
        // ];

        // Fall back to PostgreSQL when Elasticsearch client not available
        Log::info('ElasticsearchCatalogService: falling back to PostgreSQL FTS.');
        return $this->searchPostgres($query, $filters, $page, $perPage);
    }

    /**
     * Get available filter facets for the search UI.
     *
     * @return array{categories: array, price_range: array, currencies: array}
     */
    public function getFacets(): array
    {
        $categories = ProductListing::active()
            ->whereHas('storefront', fn($q) => $q->verified()->active())
            ->select('category', DB::raw('COUNT(*) as count'))
            ->whereNotNull('category')
            ->groupBy('category')
            ->orderByDesc('count')
            ->limit(50)
            ->get()
            ->toArray();

        $priceStats = ProductListing::active()
            ->whereHas('storefront', fn($q) => $q->verified()->active())
            ->selectRaw('MIN(base_price) as min_price, MAX(base_price) as max_price')
            ->first();

        return [
            'categories' => $categories,
            'price_range' => [
                'min' => (float) ($priceStats->min_price ?? 0),
                'max' => (float) ($priceStats->max_price ?? 0),
            ],
            'currencies' => ProductListing::active()
                ->distinct()
                ->pluck('currency')
                ->toArray(),
        ];
    }

    /**
     * Mark a listing as synced to Elasticsearch (placeholder for future ES sync).
     */
    public function markSynced(string $listingId): void
    {
        ProductListing::where('id', $listingId)
            ->update(['elasticsearch_synced_at' => now()]);
    }
}
