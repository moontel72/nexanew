<?php

namespace App\Http\Controllers;

use App\Services\Marketplace\FactoryMatrixValidationService;
use App\Services\Marketplace\ResellerPortalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — FACTORY MATRIX CONTROLLER
 * =======================================
 *
 * Territorial validation, stealth OTP, and MSRP enforcement endpoints.
 * Wired in routes/panels/marketplace.php.
 */

class FactoryMatrixController extends Controller
{
    public function __construct(
        private FactoryMatrixValidationService $matrix,
        private ResellerPortalService $reseller
    ) {}

    /**
     * POST /api/v1/marketplace/matrix/validate-territory
     */
    public function validateTerritory(Request $request): JsonResponse
    {
        $resellerId = (string) $request->user()->company_id ?? (string) $request->user()->id;

        $data = $request->validate([
            'factory_id' => ['required', 'string', 'max:100'],
            'target_shopkeeper_id' => ['required', 'string', 'max:100'],
        ]);

        try {
            $this->matrix->validateTerritorialBoundaries(
                $resellerId, $data['factory_id'], $data['target_shopkeeper_id']
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 403);
        }

        return response()->json(['success' => true, 'message' => 'Territorial validation passed.']);
    }

    /**
     * POST /api/v1/marketplace/matrix/challenge-otp
     */
    public function challengeOtp(Request $request): JsonResponse
    {
        $resellerId = (string) $request->user()->company_id ?? (string) $request->user()->id;

        $data = $request->validate([
            'product_id' => ['required', 'string', 'max:100'],
            'method' => ['nullable', 'string', 'in:email,phone'],
        ]);

        try {
            $result = $this->matrix->challengeStealthOTP(
                $resellerId, $data['product_id'], $data['method'] ?? 'email'
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    /**
     * POST /api/v1/marketplace/matrix/verify-otp
     */
    public function verifyOtp(Request $request): JsonResponse
    {
        $resellerId = (string) $request->user()->company_id ?? (string) $request->user()->id;

        $data = $request->validate([
            'product_id' => ['required', 'string', 'max:100'],
            'otp_token' => ['required', 'string', 'max:10'],
        ]);

        try {
            $this->matrix->verifyStealthOTP($resellerId, $data['product_id'], $data['otp_token']);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'message' => 'Product unlocked. You may now view and purchase.']);
    }

    /**
     * POST /api/v1/marketplace/matrix/enforce-msrp
     */
    public function enforceMsrp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'listing_id' => ['required', 'string', 'max:100'],
            'requested_sell_price' => ['required', 'numeric', 'min:0'],
        ]);

        try {
            $this->reseller->enforceMSRP($data['listing_id'], (float) $data['requested_sell_price']);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'message' => 'MSRP validation passed.']);
    }
}
