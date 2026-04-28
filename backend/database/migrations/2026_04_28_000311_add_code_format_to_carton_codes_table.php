<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Adds code_format column to carton_codes table to distinguish
     * barcode/code format types (itf14, gs1_128, code128_industrial, qr,
     * datamatrix, code128_label). Default is 'qr' as the most common
     * existing format.
     */
    public function up(): void
    {
        Schema::table('carton_codes', function (Blueprint $table) {
            $table->string('code_format', 30)->default('qr')->after('id');
        });

        // Set existing records to 'qr' explicitly (in case DEFAULT didn't apply to existing rows)
        DB::table('carton_codes')->whereNull('code_format')->update(['code_format' => 'qr']);

        // Add index for format-based querying
        DB::statement('CREATE INDEX idx_carton_codes_code_format ON carton_codes (code_format)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS idx_carton_codes_code_format');

        Schema::table('carton_codes', function (Blueprint $table) {
            $table->dropColumn('code_format');
        });
    }
};
