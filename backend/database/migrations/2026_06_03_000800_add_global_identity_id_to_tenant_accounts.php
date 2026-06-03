<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Defect #4 Fix — Add dedicated global_identity_id column
     *
     * Separates the tenant_accounts. parent_account_id collision:
     *   - global_identity_id (NEW)  -> FK to global_identities.id (identity spine link)
     *   - parent_account_id (legacy) -> self-referential organizational hierarchy ONLY
     *
     * This eliminates the semantic collision where parent_account_id
     * was used both as a GlobalIdentity FK and a tenant hierarchy parent.
     */
    public function up(): void
    {
        Schema::table('tenant_accounts', function (Blueprint $table) {
            if (!Schema::hasColumn('tenant_accounts', 'global_identity_id')) {
                $table->uuid('global_identity_id')->nullable()->after('id');
                $table->foreign('global_identity_id')
                    ->references('id')->on('global_identities')
                    ->onDelete('set null');
                $table->index('global_identity_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('tenant_accounts', function (Blueprint $table) {
            $table->dropForeign(['global_identity_id']);
            $table->dropColumn('global_identity_id');
        });
    }
};
