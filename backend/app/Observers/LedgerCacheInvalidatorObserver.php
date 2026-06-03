<?php

namespace App\Observers;

use App\Models\TenantFinancialLedger;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

/**
 * Wave 5 — Ledger Cache Invalidator Observer
 *
 * F-4 Fix: Replaces O(N) Redis::keys() wildcard scans with targeted
 * explicit key deletions. Uses deterministic key naming to avoid
 * synchronous blocking under large dataset cardinality.
 *
 * Hooks into tenant_financial_ledgers lifecycle events.
 *
 * On any create/update/delete:
 *   1. Flushes specific tenant/carrier allowance resolution keys
 *   2. Clears targeted financial summary cache slots on DB::afterCommit
 */
class LedgerCacheInvalidatorObserver
{
    /**
     * Well-known permission keys registered in the allowance system.
     * These correspond to keys in tenant_allowance_matrix.permissions_blob.
     */
    private const ALLOWANCE_PERMISSION_KEYS = [
        'seat_layout',
        'driver_salaries',
        'vehicle_location',
        'financials',
        'trip_history',
        'revenue_report',
    ];

    public function created(TenantFinancialLedger $ledger): void
    {
        $this->invalidateCache($ledger);
    }

    public function updated(TenantFinancialLedger $ledger): void
    {
        $this->invalidateCache($ledger);
    }

    public function deleted(TenantFinancialLedger $ledger): void
    {
        $this->invalidateCache($ledger);
    }

    /**
     * F-4 Fix: All cache invalidation deferred to DB::afterCommit
     * and uses targeted explicit key deletion instead of wildcard scans.
     */
    private function invalidateCache(TenantFinancialLedger $ledger): void
    {
        DB::afterCommit(function () use ($ledger) {
            $this->flushAllowanceKeys($ledger);
            $this->flushFinancialSummaryKeys($ledger);
        });
    }

    /**
     * F-4 Fix: Targeted allowance key deletion.
     *
     * Instead of Redis::keys('allowance:resolve:*') which blocks the
     * event loop under high key cardinality, we delete only the specific
     * keys that could reference this tenant's carrier relationship.
     *
     * Key format: allowance:resolve:{ownerId}:{carrierId}:{permissionKey}
     */
    private function flushAllowanceKeys(TenantFinancialLedger $ledger): void
    {
        try {
            $tenantId  = $ledger->tenant_account_id;
            $carrierId = $ledger->carrier_company_id;

            if (!$carrierId) {
                return;
            }

            // Resolve the owner identity from the tenant account
            $ownerId = DB::table('tenant_accounts')
                ->where('id', $tenantId)
                ->value('global_identity_id');

            if (!$ownerId) {
                return;
            }

            // Delete only the specific allowance resolution keys
            // that could have cached this (owner, carrier) pair
            $keys = [];
            foreach (self::ALLOWANCE_PERMISSION_KEYS as $perm) {
                $keys[] = "allowance:resolve:{$ownerId}:{$carrierId}:{$perm}";
            }

            Redis::del($keys);
        } catch (\Exception $e) {
            report($e);
        }
    }

    /**
     * F-4 Fix: Targeted financial summary deletion.
     *
     * Deletes explicit, predictable keys rather than scanning.
     */
    private function flushFinancialSummaryKeys(TenantFinancialLedger $ledger): void
    {
        try {
            $tenantId  = $ledger->tenant_account_id;
            $carrierId = $ledger->carrier_company_id;

            // Targeted explicit keys — no wildcard scans
            $keys = [
                "ledger:tenant:{$tenantId}:summary",
                "ledger:tenant:{$tenantId}:balance",
                'ledger:summary:global',
            ];

            if ($carrierId) {
                $keys[] = "ledger:carrier:{$carrierId}:summary";
                $keys[] = "ledger:carrier:{$carrierId}:balance";
            }

            Redis::del($keys);
        } catch (\Exception $e) {
            report($e);
        }
    }
}
