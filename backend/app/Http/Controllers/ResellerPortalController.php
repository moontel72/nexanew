<?php

namespace App\Http\Controllers;

use App\Services\Marketplace\ResellerPortalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — RESELLER PORTAL CONTROLLER
 * ========================================
 *
 * Reseller dashboard metrics, active orders, and wallet ledger.
 * Wired in routes/panels/marketplace.php.
 */

class ResellerPortalController extends Controller
{
    public function __construct(
        private ResellerPortalService $portal
    ) {}

    /**
     * GET /api/v1/marketplace/reseller/dashboard
     */
    public function dashboard(Request $request): JsonResponse
    {
        $resellerId = (string) $request->user()->company_id ?? (string) $request->user()->id;

        return response()->json([
            'success' => true,
            'data' => $this->portal->getDashboardMetrics($resellerId),
        ]);
    }
}
