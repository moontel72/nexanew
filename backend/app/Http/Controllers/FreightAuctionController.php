<?php

namespace App\Http\Controllers;

use App\Jobs\FreightAuctionMatchingJob;
use App\Models\FreightBid;
use App\Models\FreightLoad;
use App\Services\Freight\FreightAuctionService;
use App\Services\Redis\RedisCacheService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * NEXATRACE — FREIGHT AUCTION CONTROLLER
 * =======================================
 *
 * REST API for freight load posting, bidding, and matching.
 *
 * TARGET MODULES: 9D, 10D, 11D
 *
 * SAFETY: Entirely new controller. Zero modification to existing code.
 */

class FreightAuctionController extends Controller
{
    public function __construct(
        private FreightAuctionService $auction,
        private RedisCacheService $cache
    ) {}

    // ─── LOADS ────────────────────────────────────────────

    /**
     * GET /api/v1/freight/loads
     */
    public function indexLoads(Request $request): JsonResponse
    {
        $loads = FreightLoad::query()
            ->withCount('bids')
            ->when($request->query('status'), fn($q, $s) => $q->where('status', $s))
            ->when($request->query('active') === 'true', fn($q) => $q->active())
            ->when($request->query('origin'), fn($q, $c) => $q->where('origin_city', 'ilike', "%{$c}%"))
            ->when($request->query('destination'), fn($q, $c) => $q->where('destination_city', 'ilike', "%{$c}%"))
            ->orderByDesc('created_at')
            ->paginate(25);

        return response()->json(['success' => true, 'data' => $loads]);
    }

    /**
     * POST /api/v1/freight/loads
     */
    public function storeLoad(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'poster_type' => ['required', 'string', 'in:factory,reseller,goods_company,customer'],
            'origin_city' => ['required', 'string', 'max:150'],
            'destination_city' => ['required', 'string', 'max:150'],
            'origin_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'origin_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'dest_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'dest_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'cargo_type' => ['required', 'string', 'max:100'],
            'weight_tons' => ['required', 'numeric', 'min:0.1', 'max:500'],
            'required_truck_type' => ['nullable', 'string', 'max:50'],
            'expected_price' => ['required', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'max:10'],
            'description' => ['nullable', 'string', 'max:2000'],
            'pickup_address' => ['nullable', 'string', 'max:500'],
            'delivery_address' => ['nullable', 'string', 'max:500'],
            'bidding_deadline' => ['nullable', 'date', 'after:now'],
        ]);

        $load = FreightLoad::create([
            'id' => (string) Str::uuid(),
            'poster_company_id' => $companyId,
            'poster_type' => $data['poster_type'],
            'origin_city' => $data['origin_city'],
            'destination_city' => $data['destination_city'],
            'origin_lat' => $data['origin_lat'] ?? null,
            'origin_lng' => $data['origin_lng'] ?? null,
            'dest_lat' => $data['dest_lat'] ?? null,
            'dest_lng' => $data['dest_lng'] ?? null,
            'cargo_type' => $data['cargo_type'],
            'weight_tons' => $data['weight_tons'],
            'required_truck_type' => $data['required_truck_type'] ?? null,
            'expected_price' => $data['expected_price'],
            'currency' => $data['currency'] ?? 'USD',
            'description' => $data['description'] ?? null,
            'pickup_address' => $data['pickup_address'] ?? null,
            'delivery_address' => $data['delivery_address'] ?? null,
            'bidding_deadline' => $data['bidding_deadline'] ?? null,
            'status' => FreightLoad::STATUS_OPEN,
        ]);

        // If deadline is set, schedule the matching job
        if ($load->bidding_deadline) {
            FreightAuctionMatchingJob::dispatch($load->id)
                ->delay($load->bidding_deadline);
        }

        return response()->json([
            'success' => true,
            'message' => 'Freight load posted successfully.',
            'data' => $load,
        ], 201);
    }

    /**
     * GET /api/v1/freight/loads/{id}
     */
    public function showLoad(string $id): JsonResponse
    {
        $load = FreightLoad::with(['bids' => fn($q) => $q->orderByDesc('created_at')])->findOrFail($id);

        $load->increment('view_count');

        return response()->json(['success' => true, 'data' => $load]);
    }

    // ─── BIDS ─────────────────────────────────────────────

    /**
     * POST /api/v1/freight/loads/{id}/bids
     */
    public function placeBid(string $id, Request $request): JsonResponse
    {
        $user = $request->user();
        $bidderId = (string) $user->company_id ?? (string) $user->id;

        $data = $request->validate([
            'bidder_type' => ['required', 'string', 'in:truck_owner,truck_driver,goods_company'],
            'bid_amount' => ['required', 'numeric', 'min:0'],
            'vehicle_id' => ['nullable', 'string', 'max:100'],
            'vehicle_type' => ['nullable', 'string', 'max:50'],
            'vehicle_plate' => ['nullable', 'string', 'max:50'],
            'estimated_delivery_hours' => ['nullable', 'numeric', 'min:0.5', 'max:720'],
            'bidder_rating' => ['nullable', 'numeric', 'min:0', 'max:5'],
            'bidder_proximity_km' => ['nullable', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ]);

        try {
            $bid = $this->auction->placeBid(
                loadId: $id,
                bidderId: $bidderId,
                bidderType: $data['bidder_type'],
                bidAmount: (float) $data['bid_amount'],
                vehicleId: $data['vehicle_id'] ?? null,
                vehicleType: $data['vehicle_type'] ?? null,
                vehiclePlate: $data['vehicle_plate'] ?? null,
                estimatedHours: isset($data['estimated_delivery_hours']) ? (float) $data['estimated_delivery_hours'] : null,
                bidderRating: isset($data['bidder_rating']) ? (float) $data['bidder_rating'] : null,
                proximityKm: isset($data['bidder_proximity_km']) ? (float) $data['bidder_proximity_km'] : null,
                notes: $data['notes'] ?? null,
            );
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Bid placed successfully.',
            'data' => $bid,
        ], 201);
    }

    /**
     * GET /api/v1/freight/loads/{id}/bids
     */
    public function listBids(string $id): JsonResponse
    {
        $bids = FreightBid::where('load_id', $id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['success' => true, 'data' => $bids]);
    }

    // ─── MATCHING ─────────────────────────────────────────

    /**
     * POST /api/v1/freight/loads/{id}/match
     *
     * Manually trigger matching for a load.
     */
    public function matchLoad(string $id): JsonResponse
    {
        try {
            $winner = $this->auction->matchLoad($id);
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        if (! $winner) {
            return response()->json([
                'success' => false,
                'message' => 'No suitable bids found for matching.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Load matched successfully.',
            'data' => [
                'winning_bid_id' => $winner->id,
                'winning_bidder_id' => $winner->bidder_id,
                'winning_amount' => $winner->bid_amount,
                'match_score' => $winner->match_score,
            ],
        ]);
    }

    /**
     * GET /api/v1/freight/stats
     */
    public function stats(): JsonResponse
    {
        $stats = [
            'active_loads' => FreightLoad::active()->count(),
            'total_bids_today' => FreightBid::whereDate('created_at', today())->count(),
            'matched_today' => FreightLoad::where('status', FreightLoad::STATUS_MATCHED)
                ->whereDate('matched_at', today())->count(),
            'average_bids_per_load' => round(FreightLoad::active()->avg('bid_count') ?? 0, 1),
            'total_load_value' => FreightLoad::active()->sum('expected_price'),
        ];

        return response()->json(['success' => true, 'data' => $stats]);
    }
}
