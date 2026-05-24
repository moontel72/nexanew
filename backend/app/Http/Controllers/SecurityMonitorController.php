<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — SUPER ADMIN SECURITY MONITOR (STEP 26 — FINAL)
 * ============================================================
 *
 * Aggregates cross-system infractions: QR mismatches, geo-diversions,
 * AI chat breaches, and immutable audit ledger for global variance audits.
 *
 * ENDPOINTS:
 *   GET /api/v1/super-admin/security/infractions
 *   GET /api/v1/super-admin/security/audit-ledger
 *
 * Wired in routes/panels/super_admin.php under role:super_admin guard.
 */

class SecurityMonitorController extends Controller
{
    /**
     * GET /api/v1/super-admin/security/infractions
     *
     * Aggregates all security violations across the ecosystem.
     */
    public function infractions(): JsonResponse
    {
        $qrMismatches = DB::table('retail_deliveries')
            ->whereJsonLength('scanned_items', '>', 0)
            ->count();

        $geoDiversions = DB::table('consumer_scans')
            ->where('is_velocity_diverted', true)->count();

        $aiChatBreaches = DB::table('secure_chat_logs')
            ->where('is_blocked', true)->count();

        $cupOfTeaPenalties = DB::table('financial_wallet_transactions')
            ->where('transaction_type', 'cup_of_tea_penalty')->count();

        $fraudAlerts = DB::table('reverse_logistics_claims')
            ->where('status', 'approved_refund')->count();

        $recentChatBreaches = DB::table('secure_chat_logs')
            ->where('is_blocked', true)
            ->orderByDesc('created_at')->limit(20)
            ->get(['id', 'sender_id', 'receiver_id', 'blocked_reason', 'created_at']);

        $recentDiversions = DB::table('consumer_scans')
            ->where('is_velocity_diverted', true)
            ->orderByDesc('created_at')->limit(20)
            ->get(['id', 'consumer_id', 'crypto_serial_hash', 'latitude', 'longitude', 'created_at']);

        return response()->json([
            'success' => true,
            'data' => [
                'totals' => [
                    'qr_scan_mismatches' => $qrMismatches,
                    'geo_velocity_diversions' => $geoDiversions,
                    'ai_chat_breaches' => $aiChatBreaches,
                    'cup_of_tea_penalties' => $cupOfTeaPenalties,
                    'refund_claims' => $fraudAlerts,
                ],
                'recent_chat_breaches' => $recentChatBreaches,
                'recent_geo_diversions' => $recentDiversions,
            ],
        ]);
    }

    /**
     * GET /api/v1/super-admin/security/audit-ledger
     *
     * Immutable double-entry ledger for global variance audits (Balance = 0).
     */
    public function auditLedger(): JsonResponse
    {
        $creditSum = DB::table('financial_wallet_transactions')
            ->where('entry_type', 'credit')
            ->where('status', 'settled')->sum('amount');

        $debitSum = DB::table('financial_wallet_transactions')
            ->where('entry_type', 'debit')
            ->where('status', 'settled')->sum('amount');

        $variance = round($creditSum - $debitSum, 2);

        $recentTxns = DB::table('financial_wallet_transactions')
            ->orderByDesc('settled_at')->limit(50)
            ->get(['id', 'wallet_id', 'entry_type', 'amount', 'transaction_type', 'status', 'settled_at']);

        $treasuryBalance = DB::table('financial_wallets')
            ->where('is_treasury', true)->sum('balance');

        return response()->json([
            'success' => true,
            'data' => [
                'ledger' => [
                    'total_credits' => round($creditSum, 2),
                    'total_debits' => round($debitSum, 2),
                    'variance' => $variance,
                    'balanced' => $variance === 0.0,
                    'treasury_balance' => round($treasuryBalance, 2),
                ],
                'recent_transactions' => $recentTxns,
            ],
        ]);
    }
}
