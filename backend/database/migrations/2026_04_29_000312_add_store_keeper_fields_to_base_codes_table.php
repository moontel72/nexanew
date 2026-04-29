<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('base_codes')) {
            return;
        }

        Schema::table('base_codes', function (Blueprint $table) {
            if (!Schema::hasColumn('base_codes', 'store_keeper_prefix')) {
                $table->string('store_keeper_prefix', 100)->nullable();
            }

            if (!Schema::hasColumn('base_codes', 'store_keeper_code')) {
                $table->string('store_keeper_code', 100)->nullable();
            }
        });

        if (Schema::hasColumn('base_codes', 'store_keeper_code')) {
            DB::statement('ALTER TABLE base_codes ALTER COLUMN store_keeper_code DROP NOT NULL');
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('base_codes')) {
            return;
        }

        if (Schema::hasColumn('base_codes', 'store_keeper_prefix')) {
            Schema::table('base_codes', function (Blueprint $table) {
                $table->dropColumn('store_keeper_prefix');
            });
        }

        if (Schema::hasColumn('base_codes', 'store_keeper_code')) {
            Schema::table('base_codes', function (Blueprint $table) {
                $table->dropColumn('store_keeper_code');
            });
        }
    }
};
