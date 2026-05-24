<?php

namespace App\Http\Controllers;

use App\Models\Financial\FinancialSettlement;
use App\Services\Financial\SuperAdminFinancialService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — SUPER ADMIN FINANCIAL CONTROLLER
 * ==============================================
 *
 * Administrative gateway for processing Bus Operator voucher
 * cash settlements and Customer wallet card withdrawal refunds.
 *
 * All endpoints protected by role:super_admin middleware.
 *
 * TARGET MODULES: 1H, 8E, 8W
 *
 * SAFETY: Entirely new controller. Zero modification to existing code.
 */

class SuperAdminFinancialController extends Controller
{
    public function __construct(
        private SuperAdminFinancialService $financial
    ) {}

    // ─── VOUCHER SETTLEMENTS ──────────────────────────

    /**
     * GET /api/v1/super-admin/financial/vouchers/pending
     */
    public function pendingVouchers(): JsonResponse
    {
        $settlements = FinancialSettlement::type(FinancialSettlement::TYPE_VOUCHER_SETTLEMENT)
            ->pending()
            ->orderByDesc('created_at')
            ->paginate(25);

        return response()->json(['success' => true, 'data' => $settlements]);
    }

    /**
     * POST /api/v1/super-admin/financial/vouchers/settle/{id}
     */
    public function settleVoucher(string $id, Request $request): JsonResponse
    {
        $adminId = (string) $request->user()->id;

        try {
            $settlement = $this->financial->settleBusOwnerVoucher($id, $adminId);
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Voucher settlement processed. Funds transferred to Bus Owner wallet.',
            'data' => $settlement,
        ]);
    }

    // ─── WALLET WITHDRAWALS ───────────────────────────

    /**
     * GET /api/v1/super-admin/financial/withdrawals/pending
     */
    public function pendingWithdrawals(): JsonResponse
    {
        $withdrawals = FinancialSettlement::type(FinancialSettlement::TYPE_WALLET_WITHDRAWAL)
            ->pending()
            ->orderByDesc('created_at')
            ->paginate(25);

        return response()->json(['success' => true, 'data' => $withdrawals]);
    }

    /**
     * POST /api/v1/super-admin/financial/withdrawals/process/{id}
     */
    public function processWithdrawal(string $id, Request $request): JsonResponse
    {
        $adminId = (string) $request->user()->id;

        $data = $request->validate([
            'bank_trace_id' => ['required', 'string', 'max:100'],
        ]);

        try {
            $settlement = $this->financial->processCustomerWithdrawal(
                settlementId: $id,
                bankTraceId: $data['bank_trace_id'],
                adminId: $adminId,
            );
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Withdrawal processed. Funds routed to customer bank account.',
            'data' => $settlement,
        ]);
    }

    /**
     * GET /api/v1/super-admin/financial/settlements/history
     */
    public function history(Request $request): JsonResponse
    {
        $settlements = FinancialSettlement::query()
            ->when($request->query('type'), fn($q, $t) => $q->type($t))
            ->when($request->query('status'), fn($q, $s) => $q->where('status', $s))
            ->orderByDesc('created_at')
            ->paginate(25);

        return response()->json(['success' => true, 'data' => $settlements]);
    }
}
