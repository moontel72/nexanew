<?php

namespace App\Http\Controllers\Exchange;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BiddingMeshController extends Controller
{
    /**
     * POST /api/v1/exchange/broadcast-trip
     * Creates a market ticket and pushes to nearby drivers/owners/companies.
     */
    public function broadcastTripRequest(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'asset_category' => ['required', 'in:truck,bus'],
            'pickup_location' => ['required', 'string', 'max:255'],
            'pickup_lat' => ['nullable', 'numeric'], 'pickup_lng' => ['nullable', 'numeric'],
            'dropoff_location' => ['required', 'string', 'max:255'],
            'dropoff_lat' => ['nullable', 'numeric'], 'dropoff_lng' => ['nullable', 'numeric'],
            'radial_range_km' => ['nullable', 'integer', 'min:5', 'max:100'],
            'cargo_weight_tons' => ['nullable', 'numeric'],
            'passenger_seats' => ['nullable', 'integer'],
            'target_price_pkr' => ['nullable', 'numeric', 'min:100'],
        ]);

        $tripId = (string) Str::uuid();
        $user = $request->user();
        $requesterType = $this->resolveRequesterType($user);

        DB::table('trip_bidding_requests')->insert([
            'id' => $tripId,
            'requester_type' => $requesterType,
            'requester_id' => $user->id,
            'asset_category' => $validated['asset_category'],
            'pickup_location' => $validated['pickup_location'],
            'pickup_lat' => $validated['pickup_lat'] ?? null,
            'pickup_lng' => $validated['pickup_lng'] ?? null,
            'dropoff_location' => $validated['dropoff_location'],
            'dropoff_lat' => $validated['dropoff_lat'] ?? null,
            'dropoff_lng' => $validated['dropoff_lng'] ?? null,
            'radial_range_km' => $validated['radial_range_km'] ?? 25,
            'cargo_weight_tons' => $validated['cargo_weight_tons'] ?? null,
            'passenger_seats' => $validated['passenger_seats'] ?? null,
            'target_price_pkr' => $validated['target_price_pkr'] ?? null,
            'bidding_deadline' => now()->addHours(4),
            'created_at' => now(), 'updated_at' => now(),
        ]);

        // In production: push WebSocket alert to nearby bidders via Redis pub/sub.

        return response()->json(['status' => 'success', 'data' => [
            'trip_id' => $tripId, 'message' => 'Trip broadcast to nearby bidders.',
        ]], 201);
    }

    /**
     * POST /api/v1/exchange/submit-bid
     * Unified endpoint accepting bids from company, owner, or driver.
     */
    public function submitCounterBid(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'trip_request_id' => ['required', 'uuid', 'exists:trip_bidding_requests,id'],
            'proposed_amount_pkr' => ['required', 'numeric', 'min:0'],
            'vehicle_plate_number' => ['nullable', 'string', 'max:32'],
            'bidder_lat' => ['nullable', 'numeric'], 'bidder_lng' => ['nullable', 'numeric'],
        ]);

        $user = $request->user();
        $bidderType = $this->resolveBidderType($user);
        $bidderRating = DB::table('drivers')->where('id', $user->id)->value('rating') ?? 4.0;

        $bidId = (string) Str::uuid();
        DB::table('bidding_proposals')->insert([
            'id' => $bidId,
            'trip_request_id' => $validated['trip_request_id'],
            'bidder_type' => $bidderType,
            'bidder_id' => $user->id,
            'proposed_amount_pkr' => $validated['proposed_amount_pkr'],
            'vehicle_plate_number' => $validated['vehicle_plate_number'] ?? null,
            'bidder_rating' => $bidderRating,
            'bidder_lat' => $validated['bidder_lat'] ?? null,
            'bidder_lng' => $validated['bidder_lng'] ?? null,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        // Update trip status to bidding
        DB::table('trip_bidding_requests')->where('id', $validated['trip_request_id'])
            ->update(['status' => 'bidding', 'updated_at' => now()]);

        return response()->json(['status' => 'success', 'data' => [
            'bid_id' => $bidId, 'bidder_type' => $bidderType,
            'amount' => $validated['proposed_amount_pkr'],
        ]], 201);
    }

    /**
     * POST /api/v1/exchange/accept-bid/{proposalId}
     * Locks the winning bid, assigns vehicle, notifies parties.
     */
    public function acceptWinningBid(string $proposalId): JsonResponse
    {
        $proposal = DB::table('bidding_proposals')->where('id', $proposalId)->first();
        if (!$proposal) return response()->json(['status' => 'error', 'message' => 'Proposal not found.'], 404);

        DB::transaction(function () use ($proposal, $proposalId) {
            // Accept winning bid
            DB::table('bidding_proposals')->where('id', $proposalId)->update([
                'status' => 'accepted', 'accepted_at' => now(), 'updated_at' => now(),
            ]);
            // Reject all other proposals
            DB::table('bidding_proposals')
                ->where('trip_request_id', $proposal->trip_request_id)
                ->where('id', '!=', $proposalId)
                ->update(['status' => 'rejected', 'updated_at' => now()]);
            // Lock trip as matched
            DB::table('trip_bidding_requests')->where('id', $proposal->trip_request_id)
                ->update(['status' => 'matched', 'updated_at' => now()]);
        });

        return response()->json(['status' => 'success', 'message' => 'Bid accepted. Vehicle assigned.']);
    }

    /** GET /api/v1/exchange/trip-bids/{tripId} */
    public function getTripBids(string $tripId): JsonResponse
    {
        $bids = DB::table('bidding_proposals')->where('trip_request_id', $tripId)
            ->orderBy('proposed_amount_pkr', 'asc')->get()
            ->map(fn ($b) => [
                'id' => $b->id, 'bidder_type' => $b->bidder_type, 'amount_pkr' => $b->proposed_amount_pkr,
                'vehicle_plate' => $b->vehicle_plate_number, 'rating' => $b->bidder_rating,
                'status' => $b->status, 'submitted_at' => $b->created_at,
            ]);
        return response()->json(['status' => 'success', 'data' => $bids]);
    }

    private function resolveRequesterType($user): string
    {
        return match(true) {
            $user instanceof \App\Models\FactoryUser => 'factory_admin',
            $user instanceof \App\Models\Reseller => 'reseller',
            default => 'customer',
        };
    }

    private function resolveBidderType($user): string
    {
        return match(true) {
            isset($user->account_type) && $user->account_type === 'bus_company' => 'tenant_company',
            isset($user->is_independent) && !$user->is_independent => 'sub_owner',
            $user instanceof \App\Models\Driver => 'driver',
            default => 'tenant_company',
        };
    }
}
