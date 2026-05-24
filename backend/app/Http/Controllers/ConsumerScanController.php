<?php

namespace App\Http\Controllers;

use App\Services\Consumer\ConsumerScanRewardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — CONSUMER SCAN CONTROLLER
 * ======================================
 *
 * Consumer product verification scan, one-time cashback,
 * and velocity check endpoint. Wired in routes/panels/marketplace.php.
 */

class ConsumerScanController extends Controller
{
    public function __construct(
        private ConsumerScanRewardService $reward
    ) {}

    /**
     * POST /api/v1/marketplace/consumer/verify
     */
    public function verify(Request $request): JsonResponse
    {
        $consumerId = (string) $request->user()->id;

        $data = $request->validate([
            'serial_hash' => ['required', 'string', 'max:64'],
            'lat' => ['required', 'numeric'],
            'lng' => ['required', 'numeric'],
        ]);

        $result = $this->reward->verifyAndRewardConsumer(
            consumerId: $consumerId,
            serialHash: $data['serial_hash'],
            lat: (float) $data['lat'],
            lng: (float) $data['lng'],
        );

        return response()->json(['success' => $result['is_authentic'], 'data' => $result]);
    }
}
