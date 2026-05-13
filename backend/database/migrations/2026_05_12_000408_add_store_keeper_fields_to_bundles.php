<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('bundles')) {
            return;
        }

        Schema::table('bundles', function (Blueprint $table) {
            if (!Schema::hasColumn('bundles', 'linking_status')) {
                $table->string('linking_status', 50)->default('admin_linked');
            }

            if (!Schema::hasColumn('bundles', 'store_keeper_id')) {
                $table->uuid('store_keeper_id')->nullable();
            }

            if (!Schema::hasColumn('bundles', 'bundle_qr_data')) {
                $table->json('bundle_qr_data')->nullable();
            }
        });

        if (Schema::hasColumn('bundles', 'store_keeper_id')) {
            DB::statement('ALTER TABLE bundles ALTER COLUMN store_keeper_id DROP NOT NULL');
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('bundles')) {
            return;
        }

        if (Schema::hasColumn('bundles', 'linking_status')) {
            Schema::table('bundles', function (Blueprint $table) {
                $table->dropColumn('linking_status');
            });
        }

        if (Schema::hasColumn('bundles', 'store_keeper_id')) {
            Schema::table('bundles', function (Blueprint $table) {
                $table->dropColumn('store_keeper_id');
            });
        }

        if (Schema::hasColumn('bundles', 'bundle_qr_data')) {
            Schema::table('bundles', function (Blueprint $table) {
                $table->dropColumn('bundle_qr_data');
            });
        }
    }
};
