<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — Put the legacy companies under the RIGHT group incharge
 * ==================================================================
 *
 * Corrective migration. `2026_09_27_000003_assign_existing_companies_to_factory_incharge` handed EVERY
 * unowned company to the Factory incharge — too broad. The owner saw a bus-fleet company (`Awan Express`)
 * and a goods company (`New Malik Goods`) listed inside the Factory Sub-Admin panel: exactly the mixing
 * the Group-Incharge model exists to remove. That was a mistake in 000003; this fixes it.
 *
 * The group is derivable from the row itself (verified against the live data):
 *   company_type = 'manufacturing'                     -> Factory        (Demo Factory, Moon Medi, Maxi Electronic, Nazar Pharmo)
 *   notes contains "bus_fleet"  (company_type 'other')  -> Bus            (Awan Express)
 *   notes contains "goods_fleet"(company_type 'logistics')-> Goods         (New Malik Goods)
 *
 * SAFETY: it only ever touches rows whose current owner is the FACTORY incharge — i.e. precisely the rows
 * 000003 mis-assigned. A row owned by any other Sub-Admin is never taken. If the correct group has no
 * incharge yet (there is **no** goods_logistics Sub-Admin today), the row is set back to NULL = platform
 * owned, rather than left in the wrong panel.
 */
return new class extends Migration
{
    public function up(): void
    {
        $factory = $this->firstInchargeId('factory');

        if (!$factory) {
            return; // nothing of ours to correct
        }

        // Bus fleet -> the bus_transit incharge, or platform-owned when that incharge does not exist yet.
        $bus = $this->firstInchargeId('bus_transit');
        DB::table('companies')
            ->where('created_by_sub_admin_id', $factory)
            ->whereRaw("COALESCE(metadata->>'notes', '') LIKE '%bus_fleet%'")
            ->update(['created_by_sub_admin_id' => $bus]);

        // Goods fleet -> the goods_logistics incharge, or platform-owned when that incharge does not exist.
        $goods = $this->firstInchargeId('goods_logistics');
        DB::table('companies')
            ->where('created_by_sub_admin_id', $factory)
            ->whereRaw("COALESCE(metadata->>'notes', '') LIKE '%goods_fleet%'")
            ->update(['created_by_sub_admin_id' => $goods]);

        // Everything else keeps the factory incharge - it is `manufacturing`, i.e. genuinely Group 3.
    }

    public function down(): void
    {
        // Intentionally empty: this is a data correction, not a schema change. Re-running `up()` is safe
        // (it is guarded by "owned by the factory incharge"), so there is nothing to reverse from a dump.
    }

    /** The earliest still-active Sub-Admin for a vertical code, or null when that group has no incharge. */
    private function firstInchargeId(string $verticalCode): ?string
    {
        $id = DB::table('sub_admin_assignments')
            ->join('sub_admin_verticals', 'sub_admin_verticals.id', '=', 'sub_admin_assignments.vertical_id')
            ->where('sub_admin_verticals.code', $verticalCode)
            ->whereNull('sub_admin_assignments.revoked_at')
            ->orderBy('sub_admin_assignments.appointed_at')
            ->value('sub_admin_assignments.global_identity_id');

        return $id !== null ? (string) $id : null;
    }
};
