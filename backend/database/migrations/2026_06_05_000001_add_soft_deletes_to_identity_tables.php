<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Add soft-delete support to tenant_accounts and global_identities.
     *
     * Required by SubAdminController::destroy() and restore() which set
     * deleted_at timestamps for 30-day restorable soft-deletes.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('tenant_accounts', 'deleted_at')) {
            Schema::table('tenant_accounts', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        if (!Schema::hasColumn('global_identities', 'deleted_at')) {
            Schema::table('global_identities', function (Blueprint $table) {
                $table->softDeletes();
            });
        }
    }

    public function down(): void
    {
        Schema::table('tenant_accounts', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
        Schema::table('global_identities', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }
};
