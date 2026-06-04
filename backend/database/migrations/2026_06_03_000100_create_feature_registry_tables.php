<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 1 — Step 1.1: Feature Registry & Quad Sub-Admin Verticals
     *
     * Per Section 10.2.2 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
     *
     * Creates:
     *   - feature_registry         — unified module catalog (code PK, dotted paths)
     *   - sub_admin_verticals      — 4 immutable vertical codes
     *   - master_admin_assignments — Master Admin role bindings (10.2.4)
     *   - sub_admin_assignments    — Sub-Admin role bindings (10.2.2)
     *   - sub_admin_feature_grants — dynamic feature grant matrix (10.2.2)
     *
     * Key constraints (partial unique indexes WHERE revoked_at IS NULL):
     *   - One active Sub-Admin assignment per (identity, vertical)
     *   - One active feature grant per (assignment, feature_code)
     */
    public function up(): void
    {
        if (!Schema::hasTable('feature_registry')) {
            Schema::create('feature_registry', function (Blueprint $table) {
                $table->string('code')->primary();
                $table->uuid('vertical_default_id')->nullable();
                $table->string('module_name', 160);
                $table->text('description')->nullable();
                $table->string('severity', 20)->default('normal');
                $table->boolean('is_destructive')->default(false);
                $table->boolean('is_active')->default(true);
                $table->smallInteger('introduced_in_version')->default(1);
                $table->smallInteger('deprecated_in_version')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('sub_admin_verticals')) {
            Schema::create('sub_admin_verticals', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('code', 50)->unique();
                $table->string('display_name', 160);
                $table->jsonb('default_feature_bundle_codes')->nullable();
                $table->timestamps();
            });
            DB::statement("ALTER TABLE sub_admin_verticals ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        if (!Schema::hasTable('master_admin_assignments')) {
            Schema::create('master_admin_assignments', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('global_identity_id');
                $table->uuid('appointed_by_global_identity_id')->nullable();
                $table->timestampTz('appointed_at')->useCurrent();
                $table->timestampTz('revoked_at')->nullable();
                $table->timestamps();
            });
            DB::statement("ALTER TABLE master_admin_assignments ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        if (!Schema::hasTable('sub_admin_assignments')) {
            Schema::create('sub_admin_assignments', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('global_identity_id');
                $table->uuid('vertical_id');
                $table->uuid('appointed_by_master_admin_id');
                $table->timestampTz('appointed_at')->useCurrent();
                $table->timestampTz('revoked_at')->nullable();
                $table->timestamps();

                $table->foreign('vertical_id')
                    ->references('id')->on('sub_admin_verticals')
                    ->onDelete('restrict');
            });
            DB::statement("ALTER TABLE sub_admin_assignments ALTER COLUMN id SET DEFAULT gen_random_uuid()");

            DB::statement("CREATE UNIQUE INDEX IF NOT EXISTS uq_active_sub_admin_assignment
                ON sub_admin_assignments (global_identity_id, vertical_id)
                WHERE revoked_at IS NULL");
        }

        if (!Schema::hasTable('sub_admin_feature_grants')) {
            Schema::create('sub_admin_feature_grants', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('sub_admin_assignment_id');
                $table->string('feature_code');
                $table->uuid('granted_by_master_admin_id');
                $table->timestampTz('granted_at')->useCurrent();
                $table->timestampTz('revoked_at')->nullable();
                $table->jsonb('scope_filter')->nullable();
                $table->timestamps();

                $table->foreign('sub_admin_assignment_id')
                    ->references('id')->on('sub_admin_assignments')
                    ->onDelete('cascade');
                $table->foreign('feature_code')
                    ->references('code')->on('feature_registry')
                    ->onDelete('restrict');
            });
            DB::statement("ALTER TABLE sub_admin_feature_grants ALTER COLUMN id SET DEFAULT gen_random_uuid()");

            DB::statement("CREATE UNIQUE INDEX IF NOT EXISTS uq_active_feature_grant
                ON sub_admin_feature_grants (sub_admin_assignment_id, feature_code)
                WHERE revoked_at IS NULL");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sub_admin_feature_grants');
        Schema::dropIfExists('sub_admin_assignments');
        Schema::dropIfExists('master_admin_assignments');
        Schema::dropIfExists('sub_admin_verticals');
        Schema::dropIfExists('feature_registry');
    }
};
