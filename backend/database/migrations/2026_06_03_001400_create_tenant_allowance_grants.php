<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 3 — Step 3.3: Tenant Allowance Grants (Hot-Path Flat Projection)
     *
     * Per Section 10.4.3 — B-tree index projection for O(log n) lookups.
     *
     * Converts complex JSONB from tenant_allowance_matrix into flat rows.
     * Each permission key in the blob becomes one row here, keyed on
     * (owner_identity_id, carrier_company_id, permission_key).
     *
     * The UNIQUE constraint on (matrix_id, permission_key) enables idempotent
     * DELETE-then-INSERT sync from the TenantAllowanceMatrix observer.
     */
    public function up(): void
    {
        if (Schema::hasTable('tenant_allowance_grants')) {
            return;
        }

        Schema::create('tenant_allowance_grants', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('matrix_id');
            $table->uuid('owner_identity_id');
            $table->uuid('carrier_company_id');
            $table->string('permission_key', 64);                  // e.g. 'seat_layout', 'driver_salaries'
            $table->string('permission_level', 20)->default('hidden');
                // full | view | aggregate | redacted | hidden
            $table->boolean('is_active')->default(true);
            $table->timestampTz('expires_at')->nullable();
            $table->timestamps();

            $table->foreign('matrix_id')
                ->references('id')->on('tenant_allowance_matrix')
                ->onDelete('cascade');

            $table->unique(['matrix_id', 'permission_key']);
            $table->index('owner_identity_id');
            $table->index('carrier_company_id');
        });

        DB::statement("ALTER TABLE tenant_allowance_grants ALTER COLUMN id SET DEFAULT gen_random_uuid()");

        // Active-lookup acceleration indexes (Section 10.4.3)
        DB::statement("CREATE INDEX idx_grants_owner_resource
            ON tenant_allowance_grants (owner_identity_id, permission_key)
            WHERE is_active = TRUE");

        DB::statement("CREATE INDEX idx_grants_carrier
            ON tenant_allowance_grants (carrier_company_id)
            WHERE is_active = TRUE");
    }

    public function down(): void
    {
        Schema::dropIfExists('tenant_allowance_grants');
    }
};
