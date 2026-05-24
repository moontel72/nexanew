<?php

namespace App\Http\Controllers;

use App\Services\Transit\ConsumerSuperAppService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — CONSUMER SUPER-APP CONTROLLER
 * ===========================================
 *
 * Transit search, fleet auction, and chat endpoints.
 * Wired in routes/panels/consumer.php.
 */

class ConsumerSuperAppController extends Controller
{
    public function __construct(
        private ConsumerSuperAppService $superApp
    ) {}

    /**
     * GET /api/v1/consumer/transit/search?q=Lahore
     */
    public function searchTransit(Request $request): JsonResponse
    {
        $q = (string) $request->query('q', '');
        $results = $this->superApp->searchTransitRoutes($q);
        return response()->json(['success' => true, 'data' => $results]);
    }

    /**
     * POST /api/v1/consumer/fleet/auction
     */
    public function createAuction(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'vehicle_type' => ['required', 'string', 'in:truck,special_bus'],
            'origin' => ['required', 'string', 'max:150'],
            'destination' => ['required', 'string', 'max:150'],
        ]);

        $result = $this->superApp->createFleetAuction(
            $userId, $data['vehicle_type'], $data['origin'], $data['destination']
        );

        return response()->json(['success' => true, 'data' => $result], 201);
    }

    /**
     * POST /api/v1/consumer/fleet/bid
     */
    public function placeBid(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'auction_id' => ['required', 'string', 'max:100'],
            'bid_amount' => ['required', 'numeric', 'min:0'],
        ]);

        try {
            $result = $this->superApp->processFleetBidAndPenalize(
                $userId, $data['auction_id'], (float) $data['bid_amount']
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/consumer/chat/send
     * Protected by chat.filter middleware.
     */
    public function sendChat(Request $request): JsonResponse
    {
        $senderId = (string) $request->user()->id;

        $data = $request->validate([
            'receiver_id' => ['required', 'string', 'max:100'],
            'message' => ['required', 'string', 'max:2000'],
        ]);

        // Message passed AI filter — log it
        \Illuminate\Support\Facades\DB::table('secure_chat_logs')->insert([
            'id' => (string) \Illuminate\Support\Str::uuid(),
            'sender_id' => $senderId,
            'receiver_id' => $data['receiver_id'],
            'message_body' => $data['message'],
            'is_blocked' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'message' => 'Message sent.']);
    }
}
