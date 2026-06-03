<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 3 — Step 3.2: Tenant Allowance Matrix
     *
     * Per Section 10.4.2 — Canonical layer for cross-tenant data sharing.
     *
     * Bus/Truck owners define which transport companies can see what.
     * The permissions_blob JSONB hosts semantic flags like:
     *   {"seat_layout": "view", "driver_salaries": "hidden", "vehicle_location": "aggregate"}
     *
     * Materialized via observer into tenant_allowance_grants flat projection
     * for O(log n) B-tree lookups in the VendorAllowanceShield middleware.
     */
    public function up(): void
    {
        if (Schema::hasTable('tenant_allowance_matrix')) {
            return;
        }

        Schema::create('tenant_allowance_matrix', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('owner_identity_id');
            $table->uuid('carrier_company_id');
            $table->jsonb('permissions_blob');                     // semantic flags
            $table->string('status', 20)->default('active');      // active, revoked, expired
            $table->timestampTz('expires_at')->nullable();
            $table->timestamps();

            $table->foreign('owner_identity_id')
                ->references('id')->on('global_identities')
                ->onDelete('cascade');

            $table->unique(['owner_identity_id', 'carrier_company_id']);

            $table->index('owner_identity_id');
            $table->index('carrier_company_id');
            $table->index('status');
        });

        DB::statement("ALTER TABLE tenant_allowance_matrix ALTER COLUMN id SET DEFAULT uuid_generate_v4()");
    }

    public function down(): void
    {
        Schema::dropIfExists('tenant_allowance_matrix');
    }
};
