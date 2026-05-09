<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('unit_codes', function (Blueprint $table) {
            $table->string('code_format', 30)->default('qr')->after('id');
        });

        DB::table('unit_codes')->whereNull('code_format')->update(['code_format' => 'qr']);

        DB::statement('CREATE INDEX idx_unit_codes_code_format ON unit_codes (code_format)');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS idx_unit_codes_code_format');

        Schema::table('unit_codes', function (Blueprint $table) {
            $table->dropColumn('code_format');
        });
    }
};
