<?php

namespace App\Http\Controllers;

use App\Services\Marketplace\MarketplaceSubscriptionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — MARKETPLACE SUBSCRIPTION CONTROLLER
 * =================================================
 *
 * Listing cap, brand piracy, and Reseller OTP gate endpoints.
 * Wired in routes/panels/marketplace.php.
 */

class MarketplaceSubscriptionController extends Controller
{
    public function __construct(
        private MarketplaceSubscriptionService $subService
    ) {}

    /**
     * POST /api/v1/marketplace/subscription/validate-listing
     */
    public function validateListing(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'listing_title' => ['required', 'string', 'max:300'],
            'is_homemade' => ['nullable', 'boolean'],
        ]);

        try {
            $this->subService->validateListingCapAndPiracy($userId, $data);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'message' => 'Listing validation passed.']);
    }

    /**
     * POST /api/v1/marketplace/subscription/otp-gate
     */
    public function otpGate(Request $request): JsonResponse
    {
        $shopkeeperId = (string) $request->user()->id;

        $data = $request->validate([
            'listing_id' => ['required', 'string', 'max:100'],
            'otp_token' => ['nullable', 'string', 'max:10'],
        ]);

        try {
            $result = $this->subService->processResellerOtpGate(
                $shopkeeperId, $data['listing_id'], $data['otp_token'] ?? ''
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * GET /api/v1/marketplace/subscription/tier
     */
    public function myTier(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;
        return response()->json(['success' => true, 'data' => $this->subService->getUserTier($userId)]);
    }
}
