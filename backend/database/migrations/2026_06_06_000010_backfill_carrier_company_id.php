<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Backfill carrier_company_id on existing fleet_assignments
     * and promote bus company tenant accounts to correct account_type.
     *
     * Per Qoder Audit R-3: carrier_company_id is NULL on rows created
     * before the middleware/controller fixes.
     */
    public function up(): void
    {
        // 1. Find bus company tenant accounts (identified by email patterns or bus_company type)
        $busCompanies = DB::table('tenant_accounts')
            ->whereIn('account_type', ['bus_company', 'admin'])
            ->orWhere('email', 'like', '%@%')
            ->get();

        // 2. Promote any tenant that has fleet assets to bus_company
        $carrierIds = DB::table('transport_bus_layouts')
            ->whereNotNull('carrier_company_id')
            ->pluck('carrier_company_id')
            ->unique()
            ->toArray();

        // Also check fleet_assignments for carrier_company_id that are already set
        $existingCarriers = DB::table('fleet_assignments')
            ->whereNotNull('carrier_company_id')
            ->pluck('carrier_company_id')
            ->unique()
            ->toArray();

        $allCarrierIds = array_unique(array_merge($carrierIds, $existingCarriers));

        foreach ($allCarrierIds as $cid) {
            if ($cid && $cid !== '00000000-0000-0000-0000-000000000000') {
                DB::table('tenant_accounts')
                    ->where('id', $cid)
                    ->whereNotIn('account_type', ['master_admin'])
                    ->update(['account_type' => 'bus_company', 'updated_at' => now()]);
            }
        }

        // 3. Backfill any fleet_assignments with NULL carrier_company_id
        //    Use the bus company's own id as carrier for orphaned rows created
        //    by the admin user. Find the most recently created bus_company.
        $primaryCarrier = DB::table('tenant_accounts')
            ->where('account_type', 'bus_company')
            ->orderBy('created_at', 'desc')
            ->first();

        if ($primaryCarrier) {
            DB::table('fleet_assignments')
                ->whereNull('carrier_company_id')
                ->where('fleet_type', 'bus')
                ->update([
                    'carrier_company_id' => $primaryCarrier->id,
                    'updated_at'         => now(),
                ]);
        }

        // 4. Also backfill transport_bus_layouts
        if ($primaryCarrier) {
            DB::table('transport_bus_layouts')
                ->whereNull('carrier_company_id')
                ->update([
                    'carrier_company_id' => $primaryCarrier->id,
                    'updated_at'         => now(),
                ]);
        }
    }

    public function down(): void
    {
        // No reverse — backfill is one-way
    }
};
