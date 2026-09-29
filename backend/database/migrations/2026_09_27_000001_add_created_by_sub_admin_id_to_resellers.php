<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — Add created_by_sub_admin_id to resellers
 * ===================================================
 *
 * Group-Incharge C2b. The `commercial_marketplace` Sub-Admin creates and manages
 * reseller accounts (MASTER-TASK-LIST.md §2b), and its endpoints must show only
 * its own rows.
 *
 * `resellers` has no `created_by` / metadata column — unlike `companies`, which could
 * carry the creator inside `metadata` — so the scoping key needs a real column. It is
 * nullable on purpose: every reseller that already exists was created by the Super Admin
 * and belongs to no sub-admin, so a backfill would be a lie. NULL means "platform-created".
 *
 * Additive and idempotent; the deploy runs `php artisan migrate --force`.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('resellers', function (Blueprint $table) {
            if (!Schema::hasColumn('resellers', 'created_by_sub_admin_id')) {
                $table->uuid('created_by_sub_admin_id')->nullable()->after('id')->index();
            }
        });
    }

    public function down(): void
    {
        Schema::table('resellers', function (Blueprint $table) {
            if (Schema::hasColumn('resellers', 'created_by_sub_admin_id')) {
                $table->dropColumn('created_by_sub_admin_id');
            }
        });
    }
};
