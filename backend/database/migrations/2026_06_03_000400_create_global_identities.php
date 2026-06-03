<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 1 — Identity Spine: global_identities
     *
     * Per Section 10.1.2 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
     *
     * Immutable profile core. One row per real human/legal entity.
     * The displayed identity_token uses semantic prefixes:
     *   TRC-DR-XXXXX  (driver)
     *   TRC-OW-XXXXX  (owner)
     *   TRC-CO-XXXXX  (conductor)
     *   TRC-MX-XXXXX  (mixed)
     *   TRC-CU-XXXXX  (customer)
     *
     * Status transitions (active → suspended → frozen → deleted) are all logged.
     * The row itself is never removed — deleted is a logical status.
     */
    public function up(): void
    {
        if (Schema::hasTable('global_identities')) {
            return;
        }

        Schema::create('global_identities', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('identity_token', 30)->unique();
            $table->string('display_name', 160);
            $table->text('password_hash')->nullable();

            // KYC
            $table->string('kyc_status', 20)->default('unverified');
            $table->smallInteger('kyc_tier')->default(0);

            // Lifecycle
            $table->string('status', 20)->default('active');
            $table->string('identity_type', 20)->nullable();

            // Risk engine
            $table->decimal('risk_score', 5, 2)->default(0.00);
            $table->string('primary_locale', 8)->nullable();

            $table->timestamps();

            $table->index('identity_token');
            $table->index('status');
            $table->index('kyc_status');
            $table->index('identity_type');
        });

        DB::statement("ALTER TABLE global_identities ALTER COLUMN id SET DEFAULT uuid_generate_v4()");
    }

    public function down(): void
    {
        Schema::dropIfExists('global_identities');
    }
};
