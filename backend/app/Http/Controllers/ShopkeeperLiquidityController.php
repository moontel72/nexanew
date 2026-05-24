<?php

namespace App\Http\Controllers;

use App\Services\Transport\ShopkeeperLiquidityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — SHOPKEEPER LIQUIDITY CONTROLLER
 * =============================================
 *
 * Micro-liquidity cash-out endpoint (Module 7S).
 * Wired in routes/panels/marketplace.php.
 */

class ShopkeeperLiquidityController extends Controller
{
    public function __construct(
        private ShopkeeperLiquidityService $liquidity
    ) {}

    /**
     * POST /api/v1/marketplace/shop/cash-out
     */
    public function cashOut(Request $request): JsonResponse
    {
        $shopkeeperId = (string) $request->user()->id;

        $data = $request->validate([
            'customer_id' => ['required', 'string', 'max:100'],
            'voucher_ref' => ['required', 'string', 'max:100'],
            'amount' => ['required', 'numeric', 'min:1'],
        ]);

        try {
            $result = $this->liquidity->liquidateWalletChange(
                shopkeeperId: $shopkeeperId,
                customerVoucherRef: $data['voucher_ref'],
                customerId: $data['customer_id'],
                amount: (float) $data['amount'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }
}
