<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    /**
     * R-3 DEFECT FIX — Backfill carrier_company_id on fleet_assignments.
     *
     * Per Section 10.1 / 10.11.2: every fleet_assignments row MUST have
     * a valid carrier_company_id pointing to the tenant_accounts.id of the
     * carrier or owner-tenant that the identity serves under.
     *
     * Strategy (multi-pass, idempotent):
     *   Pass 1: Owners → use their own tenant_accounts.id
     *   Pass 2: Drivers/Conductors → find an active owner assignment in
     *           the same fleet_type and adopt that owner's carrier_company_id
     *   Pass 3: Any remaining NULL → use the identity's own tenant_accounts.id
     *           as a safe fallback
     *
     * Idempotent — rows that already have a valid carrier_company_id
     * are left unchanged.
     */
    public function up(): void
    {
        $nullCount = DB::table('fleet_assignments')
            ->whereNull('carrier_company_id')
            ->count();

        if ($nullCount === 0) {
            Log::info('R-3 Backfill: No NULL carrier_company_id rows found. Skipping.');
            return;
        }

        Log::info("R-3 Backfill: Found {$nullCount} fleet_assignments rows with NULL carrier_company_id.");

        DB::transaction(function () use ($nullCount) {
            $updatedTotal = 0;

            // ─── Pass 1: Owners → use own tenant_accounts.id ───
            $ownerNulls = DB::table('fleet_assignments AS fa')
                ->join('tenant_accounts AS ta', 'fa.global_identity_id', '=', 'ta.global_identity_id')
                ->whereNull('fa.carrier_company_id')
                ->where('fa.role', 'owner')
                ->select('fa.id', 'ta.id AS tenant_id')
                ->get();

            foreach ($ownerNulls as $row) {
                DB::table('fleet_assignments')
                    ->where('id', $row->id)
                    ->update([
                        'carrier_company_id' => $row->tenant_id,
                        'updated_at'         => now(),
                    ]);
                $updatedTotal++;
            }

            Log::info("R-3 Backfill Pass 1 (owners): {$updatedTotal} rows updated.");

            // ─── Pass 2: Drivers/Conductors → resolve via any owner assignment ───
            $staffNulls = DB::table('fleet_assignments AS fa')
                ->leftJoin('tenant_accounts AS ta', 'fa.global_identity_id', '=', 'ta.global_identity_id')
                ->whereNull('fa.carrier_company_id')
                ->whereIn('fa.role', ['driver', 'conductor'])
                ->select(
                    'fa.id',
                    'fa.global_identity_id',
                    'fa.fleet_type',
                    'ta.id AS own_tenant_id',
                )
                ->get();

            $pass2Count = 0;
            foreach ($staffNulls as $staff) {
                // Try to find an active owner assignment in the same fleet_type
                $ownerCarrier = DB::table('fleet_assignments')
                    ->where('role', 'owner')
                    ->where('fleet_type', $staff->fleet_type)
                    ->whereIn('status', ['active', 'pending_acceptance'])
                    ->whereNotNull('carrier_company_id')
                    ->value('carrier_company_id');

                // If an owner exists in this fleet_type, use their carrier
                // Otherwise fall back to the staff's own tenant_id
                $resolvedCid = $ownerCarrier ?? $staff->own_tenant_id;

                if ($resolvedCid) {
                    DB::table('fleet_assignments')
                        ->where('id', $staff->id)
                        ->update([
                            'carrier_company_id' => $resolvedCid,
                            'updated_at'         => now(),
                        ]);
                    $pass2Count++;
                }
            }

            Log::info("R-3 Backfill Pass 2 (drivers/conductors): {$pass2Count} rows updated.");
            $updatedTotal += $pass2Count;

            // ─── Pass 3: Any remaining NULL → identity's own tenant_accounts.id ───
            $remaining = DB::table('fleet_assignments AS fa')
                ->leftJoin('tenant_accounts AS ta', 'fa.global_identity_id', '=', 'ta.global_identity_id')
                ->whereNull('fa.carrier_company_id')
                ->select('fa.id', 'ta.id AS tenant_id')
                ->get();

            $pass3Count = 0;
            foreach ($remaining as $row) {
                if ($row->tenant_id) {
                    DB::table('fleet_assignments')
                        ->where('id', $row->id)
                        ->update([
                            'carrier_company_id' => $row->tenant_id,
                            'updated_at'         => now(),
                        ]);
                    $pass3Count++;
                }
            }

            Log::info("R-3 Backfill Pass 3 (fallback): {$pass3Count} rows updated.");
            $updatedTotal += $pass3Count;

            // Validation: assert no remaining NULLs
            $stillNull = DB::table('fleet_assignments')
                ->whereNull('carrier_company_id')
                ->count();

            if ($stillNull > 0) {
                Log::warning("R-3 Backfill: {$stillNull} rows STILL have NULL carrier_company_id after all passes. Manual review required.");
            }

            Log::info("R-3 Backfill complete: {$updatedTotal} total rows updated. {$stillNull} remaining NULLs.");
        });
    }

    /**
     * Rollback is intentionally a no-op — this is a data-fix migration
     * that should not be reversed. Rolling back would re-introduce
     * the integrity gap.
     */
    public function down(): void
    {
        // No-op: data integrity fix should not be reversed.
        // NULL values were a defect, not a state we want to restore.
    }
};
