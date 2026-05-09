<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Delete all legacy unit codes to prepare for the new format-based system.
     * Products table is NOT touched.
     */
    public function up(): void
    {
        // Get all unit code IDs from unit_codes table
        $unitIds = DB::table('unit_codes')->pluck('id')->toArray();

        if (!empty($unitIds)) {
            // Delete from unit_codes (cascade from base_codes)
            DB::table('unit_codes')->whereIn('id', $unitIds)->delete();
            // Delete from base_codes by code_type = 'unit'
            DB::table('base_codes')->where('code_type', 'unit')->delete();
        }
    }

    public function down(): void
    {
        // Cannot restore purged data
    }
};
