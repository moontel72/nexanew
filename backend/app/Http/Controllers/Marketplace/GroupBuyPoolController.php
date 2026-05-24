<?php

namespace App\Http\Controllers\Marketplace;

use App\Http\Controllers\Controller;
use App\Models\Marketplace\GroupBuyPool;
use App\Services\Marketplace\GroupBuyPoolService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — GROUP BUY POOL CONTROLLER
 * =======================================
 *
 * Multi-buyer order pooling endpoints (Module 12D).
 *
 * SAFETY: Entirely new controller in Marketplace namespace.
 *         Uses only marketplace-specific models and services.
 */

class GroupBuyPoolController extends Controller
{
    public function __construct(
        private GroupBuyPoolService $poolService
    ) {}

    /**
     * GET /api/v1/marketplace/pools
     */
    public function index(Request $request): JsonResponse
    {
        $pools = GroupBuyPool::query()
            ->with(['productListing.storefront', 'initiator'])
            ->withCount('participants')
            ->when(
                $request->query('status'),
                fn($q, $status) => $q->status($status)
            )
            ->when(
                $request->query('active') === 'true',
                fn($q) => $q->active()
            )
            ->orderByDesc('created_at')
            ->paginate(25);

        return response()->json([
            'success' => true,
            'data' => $pools,
        ]);
    }

    /**
     * GET /api/v1/marketplace/pools/{id}
     */
    public function show(string $id): JsonResponse
    {
        $pool = GroupBuyPool::with([
            'productListing.storefront',
            'initiator',
            'participants.company',
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => array_merge($pool->toArray(), [
                'progress_percentage' => $pool->progressPercentage(),
                'can_be_joined' => $pool->canBeJoined(),
            ]),
        ]);
    }

    /**
     * POST /api/v1/marketplace/pools
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'product_listing_id' => ['required', 'uuid', 'exists:marketplace_product_listings,id'],
            'target_quantity' => ['required', 'integer', 'min:10'],
            'pool_price_per_unit' => ['required', 'numeric', 'min:0'],
            'gathering_deadline' => ['required', 'date', 'after:now'],
            'min_participants' => ['nullable', 'integer', 'min:2', 'max:100'],
            'max_participants' => ['nullable', 'integer', 'min:2'],
        ]);

        try {
            $pool = $this->poolService->createPool(
                listingId: $data['product_listing_id'],
                initiatorId: $companyId,
                targetQty: (int) $data['target_quantity'],
                poolPrice: (float) $data['pool_price_per_unit'],
                deadline: $data['gathering_deadline'],
                minParts: (int) ($data['min_participants'] ?? 2),
                maxParts: isset($data['max_participants']) ? (int) $data['max_participants'] : null,
            );
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Group buy pool created successfully.',
            'data' => $pool->load(['productListing.storefront', 'initiator']),
        ], 201);
    }

    /**
     * POST /api/v1/marketplace/pools/{id}/join
     */
    public function join(string $id, Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'quantity' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $participant = $this->poolService->joinPool(
                poolId: $id,
                companyId: $companyId,
                quantity: (int) $data['quantity'],
            );
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Successfully joined the group buy pool.',
            'data' => $participant->load('pool'),
        ], 201);
    }

    /**
     * POST /api/v1/marketplace/pools/{id}/lock
     */
    public function lock(string $id): JsonResponse
    {
        try {
            $pool = $this->poolService->lockPool($id);
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Pool locked. No further participants can join.',
            'data' => $pool,
        ]);
    }

    /**
     * POST /api/v1/marketplace/pools/{id}/cancel
     */
    public function cancel(string $id, Request $request): JsonResponse
    {
        $data = $request->validate([
            'reason' => ['nullable', 'string', 'max:500'],
        ]);

        try {
            $pool = $this->poolService->cancelPool($id, (string) ($data['reason'] ?? ''));
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Pool cancelled.',
            'data' => $pool,
        ]);
    }
}
