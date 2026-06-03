<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 1 — Multi-Claim Identity Ledger: identity_claims
     *
     * Per Sections 10.1.3 and 10.1.4 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
     *
     * Revocable surface table for contact channels and credentials.
     * Native support for recycled SIM cards, dual CNIC formats,
     * and multi-phone owners via soft-revocation (never hard-delete).
     *
     * CRITICAL — Index Strategy (Section 10.1.4):
     *   NO single-column UNIQUE on phone/email/CNIC.
     *   PII uniqueness enforced EXCLUSIVELY through PARTIAL UNIQUE indexes
     *   WHERE is_revoked = FALSE.
     *
     * This allows a phone number to be revoked from identity A and
     * reclaimed by identity B without constraint violation, while
     * preventing two simultaneous active claims to the same value.
     */
    public function up(): void
    {
        if (Schema::hasTable('identity_claims')) {
            return;
        }

        Schema::create('identity_claims', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('global_identity_id');
            $table->string('claim_type', 30);
            $table->string('claim_value', 255);
            $table->binary('claim_value_hash', 32)->nullable();     // SHA-256 digest (BYTEA)
            $table->boolean('is_primary')->default(false);
            $table->boolean('is_revoked')->default(false);
            $table->timestampTz('revoked_at')->nullable();
            $table->text('revoked_reason')->nullable();
            $table->string('verified_via', 30)->nullable();
            $table->timestampTz('verified_at')->nullable();
            $table->timestamps();

            $table->foreign('global_identity_id')
                ->references('id')->on('global_identities')
                ->onDelete('restrict');
        });

        DB::statement("ALTER TABLE identity_claims ALTER COLUMN id SET DEFAULT uuid_generate_v4()");

        // ── Partial Unique Indexes (Section 10.1.4) ──────────────

        // 1. Active claim value uniqueness
        DB::statement("CREATE UNIQUE INDEX idx_claims_active_value
            ON identity_claims (claim_type, claim_value)
            WHERE is_revoked = FALSE");

        // 2. At most one primary per (identity, claim_type)
        DB::statement("CREATE UNIQUE INDEX idx_claims_primary_per_type
            ON identity_claims (global_identity_id, claim_type)
            WHERE is_primary = TRUE AND is_revoked = FALSE");

        // 3. Fast lookup by identity
        DB::statement("CREATE INDEX idx_claims_by_identity
            ON identity_claims (global_identity_id)
            WHERE is_revoked = FALSE");

        // 4. Fast hash-based lookup
        DB::statement("CREATE INDEX idx_claims_hash
            ON identity_claims (claim_type, claim_value_hash)
            WHERE is_revoked = FALSE");
    }

    public function down(): void
    {
        Schema::dropIfExists('identity_claims');
    }
};
