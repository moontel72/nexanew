<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — Add created_by_sub_admin_id to companies
 * ===================================================
 *
 * Group-Incharge C2 fix. The first version of SubAdminFactoryCompanyController scoped the Factory
 * Sub-Admin's list through the JSON path `metadata->>'created_by_sub_admin_id'`. That filter returned
 * an empty list **in Laravel** even though the identical predicate returns the row in psql — the Super
 * Admin's own (unfiltered) list showed the same company fine. Rather than fight a JSON-path filter,
 * this uses the boring, proven pattern: a real indexed column, exactly like `resellers`.
 *
 * Nullable on purpose: every company that already exists was created by the Super Admin, so NULL means
 * "platform-created". The one row the sub-admin created through the metadata path is backfilled.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            if (!Schema::hasColumn('companies', 'created_by_sub_admin_id')) {
                $table->uuid('created_by_sub_admin_id')->nullable()->index();
            }
        });

        // Backfill from the metadata key the first version wrote. The regex guard stops a malformed
        // value from aborting the migration with an invalid uuid cast.
        DB::statement("
            UPDATE companies
            SET created_by_sub_admin_id = (metadata->>'created_by_sub_admin_id')::uuid
            WHERE created_by_sub_admin_id IS NULL
              AND metadata->>'created_by_sub_admin_id' ~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
        ");
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            if (Schema::hasColumn('companies', 'created_by_sub_admin_id')) {
                $table->dropColumn('created_by_sub_admin_id');
            }
        });
    }
};
