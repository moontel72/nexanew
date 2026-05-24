<?php

namespace App\Http\Controllers;

use App\Services\Marketplace\ReverseLogisticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — REVERSE LOGISTICS CONTROLLER
 * ==========================================
 *
 * Claim submission, inspection, approval/rejection endpoints.
 * Wired in routes/panels/marketplace.php and factory.php.
 */

class ReverseLogisticsController extends Controller
{
    public function __construct(
        private ReverseLogisticsService $logistics
    ) {}

    /**
     * POST /api/v1/marketplace/claims/submit
     */
    public function submitClaim(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'serial_hash' => ['required', 'string', 'max:64'],
            'type' => ['required', 'string', 'in:return,damage'],
            'lat' => ['required', 'numeric'],
            'lng' => ['required', 'numeric'],
            'photo_path' => ['required', 'string', 'max:500'],
            'claimed_amount' => ['nullable', 'numeric', 'min:0'],
        ]);

        try {
            $result = $this->logistics->submitLogisticsClaim(
                userId: $userId,
                serialHash: $data['serial_hash'],
                type: $data['type'],
                geoCoords: ['lat' => (float) $data['lat'], 'lng' => (float) $data['lng']],
                photoPath: $data['photo_path'],
                claimedAmount: (float) ($data['claimed_amount'] ?? 0),
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/factory/claims/approve/{id}
     */
    public function approveClaim(string $id, Request $request): JsonResponse
    {
        $approverId = (string) $request->user()->id;

        $data = $request->validate([
            'notes' => ['nullable', 'string', 'max:500'],
        ]);

        try {
            $result = $this->logistics->processClaimApproval($id, $approverId, $data['notes'] ?? null);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/factory/claims/reject/{id}
     */
    public function rejectClaim(string $id, Request $request): JsonResponse
    {
        $approverId = (string) $request->user()->id;

        $data = $request->validate([
            'reason' => ['required', 'string', 'max:500'],
        ]);

        $this->logistics->rejectClaim($id, $approverId, $data['reason']);

        return response()->json(['success' => true, 'message' => 'Claim rejected.']);
    }
}
