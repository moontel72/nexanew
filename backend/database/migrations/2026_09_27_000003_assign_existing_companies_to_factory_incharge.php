<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * NEXATRACE — Hand the existing companies to the Factory group's incharge
 * =====================================================================
 *
 * Owner's decision (2026-09-27): a group's Sub-Admin is the **incharge of that group**, so the accounts
 * that were created before the Group-Incharge model existed must belong to them too. C2 left
 * `created_by_sub_admin_id` NULL on every pre-existing row ("platform-created"), which made those
 * companies invisible to the Factory Sub-Admin — the owner saw exactly that: the Sub-Admin listed only
 * the one factory created there, while the older ones were still only in the Super Admin.
 *
 * This assigns every still-unowned company to the FIRST active `factory` Sub-Admin (the only factory
 * incharge today). It runs only when such an incharge exists, and only touches rows that have no owner —
 * so it can never steal a row from a Sub-Admin, and it is a no-op on a fresh database.
 *
 * IRREVERSIBLE ON PURPOSE: `down()` does not un-assign, because un-assigning would also blank rows that
 * were legitimately created by a Sub-Admin afterwards. Restore from a backup if this ever needs undoing.
 */
return new class extends Migration
{
    public function up(): void
    {
        $hasFactoryIncharge = DB::table('sub_admin_assignments')
            ->join('sub_admin_verticals', 'sub_admin_verticals.id', '=', 'sub_admin_assignments.vertical_id')
            ->where('sub_admin_verticals.code', 'factory')
            ->whereNull('sub_admin_assignments.revoked_at')
            ->exists();

        if (!$hasFactoryIncharge) {
            // No factory incharge exists yet. This migration is recorded as run either way, so it will NOT
            // retry by itself — if the incharge is appointed later, run the UPDATE below once by hand.
            return;
        }

        DB::statement("
            UPDATE companies
            SET created_by_sub_admin_id = (
                SELECT sa.global_identity_id
                FROM sub_admin_assignments sa
                JOIN sub_admin_verticals sav ON sav.id = sa.vertical_id
                WHERE sav.code = 'factory' AND sa.revoked_at IS NULL
                ORDER BY sa.appointed_at
                LIMIT 1
            )
            WHERE created_by_sub_admin_id IS NULL
        ");
    }

    public function down(): void
    {
        // Intentionally empty — see the class docblock.
    }
};
