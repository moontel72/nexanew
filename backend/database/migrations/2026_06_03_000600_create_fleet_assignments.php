<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 2 — Fleet Assignment Lifecycle & Race-Condition Guard
     *
     * State machine locking an identity into exactly one carrier seat
     * per role. Prevents parallel multi-company claims via conditional
     * unique index.
     *
     * Status life-cycle:
     *   pending_acceptance → active → unassigned
     *                     ↘ suspended → active (reactivate)
     *
     * Race-Condition Prevention (Section 10.11.2):
     *   One identity cannot hold multiple active/pending seats for
     *   the same role across different companies simultaneously.
     *
     *   CREATE UNIQUE INDEX one_active_assignment_per_role
     *     ON fleet_assignments (global_identity_id, role)
     *     WHERE status IN ('active', 'pending_acceptance');
     */
    public function up(): void
    {
        if (Schema::hasTable('fleet_assignments')) {
            return;
        }

        Schema::create('fleet_assignments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('global_identity_id');
            $table->uuid('carrier_company_id')->nullable();
            $table->string('role', 30);
            $table->string('fleet_type', 20)->nullable();
            $table->string('status', 30)->default('pending_acceptance');
            $table->jsonb('assignment_meta')->nullable();
            $table->timestampTz('accepted_at')->nullable();
            $table->timestampTz('unassigned_at')->nullable();
            $table->text('unassign_reason')->nullable();
            $table->timestamps();

            $table->foreign('global_identity_id')
                ->references('id')->on('global_identities')
                ->onDelete('restrict');

            $table->index('status');
            $table->index('role');
            $table->index('fleet_type');
            $table->index('carrier_company_id');
        });

        DB::statement("ALTER TABLE fleet_assignments ALTER COLUMN id SET DEFAULT gen_random_uuid()");

        DB::statement("CREATE UNIQUE INDEX one_active_assignment_per_role
            ON fleet_assignments (global_identity_id, role)
            WHERE status IN ('active', 'pending_acceptance')");
    }

    public function down(): void
    {
        Schema::dropIfExists('fleet_assignments');
    }
};
