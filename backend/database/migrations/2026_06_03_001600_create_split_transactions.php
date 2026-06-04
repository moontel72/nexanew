<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 5 — Part 2: Split Transaction Engine + Recipients
     *
     * Per Section 10.5.1 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
     *
     * split_transactions:
     *   Splits customer payments between Platform, Carrier Company,
     *   and Third-Party Owner at the moment of booking settlement.
     *   Uses SHA-256 idempotency keys for exactly-once semantics.
     *
     * split_transaction_recipients:
     *   Individual recipient splits with state-machine lifecycle.
     *   Each recipient credit produces a balanced debit/credit pair.
     *
     * Partial unique index on trip_booking_id WHERE status NOT IN ('refunded')
     * prevents double-split computations on the same booking.
     */
    public function up(): void
    {
        // ── split_transactions ───────────────────────────────
        if (!Schema::hasTable('split_transactions')) {
            Schema::create('split_transactions', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->char('idempotency_key', 64)->unique();
                $table->string('source_event_type', 64);           // e.g. 'ticket.booking.paid'
                $table->uuid('trip_booking_id')->nullable();       // FK to booking record
                $table->string('source_event_id')->nullable();     // external payment gateway ref
                $table->decimal('source_amount', 18, 4);
                $table->decimal('carrier_cut_amount', 18, 4)->default(0);
                $table->decimal('owner_cut_amount', 18, 4)->default(0);
                $table->decimal('tax_deduction', 18, 4)->default(0);
                $table->decimal('platform_cut_amount', 18, 4)->default(0);
                $table->char('currency', 3)->default('PKR');
                $table->string('settlement_status', 20)->default('pending');
                    // pending | splitting | settled | partial_failed | escrow_held | reversed | refunded
                $table->jsonb('split_rule_snapshot')->nullable();  // frozen rule at execution
                $table->jsonb('recipients_snapshot')->nullable();  // frozen recipient breakdown
                $table->timestampTz('settled_at')->nullable();
                $table->timestampTz('reversed_at')->nullable();
                $table->text('reversal_reason')->nullable();
                $table->timestamps();

                $table->index('trip_booking_id');
                $table->index('settlement_status');
                $table->index('source_event_type');
                $table->index('created_at');
            });

            DB::statement("ALTER TABLE split_transactions ALTER COLUMN id SET DEFAULT gen_random_uuid()");

            // Prevent double-split: one active split per booking (MUST run AFTER Schema::create)
            DB::statement("CREATE UNIQUE INDEX idx_one_active_split_per_booking
                ON split_transactions (trip_booking_id)
                WHERE settlement_status NOT IN ('refunded', 'reversed')");
        }

        // ── split_transaction_recipients ─────────────────────
        if (!Schema::hasTable('split_transaction_recipients')) {
            Schema::create('split_transaction_recipients', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('split_transaction_id');
                $table->uuid('recipient_global_identity_id')->nullable();
                $table->string('recipient_role', 30);              // platform | owner | driver | conductor | tax_authority
                $table->decimal('amount', 18, 4);
                $table->string('state', 20)->default('queued');
                    // queued | transferring | credited | failed | reversed
                $table->uuid('ledger_entry_id')->nullable();       // FK to ledger_entries once credited
                $table->smallInteger('attempt_count')->default(0);
                $table->text('last_error')->nullable();
                $table->timestampTz('credited_at')->nullable();
                $table->timestampTz('failed_at')->nullable();
                $table->timestamps();

                $table->foreign('split_transaction_id')
                    ->references('id')->on('split_transactions')
                    ->onDelete('cascade');

                $table->index('split_transaction_id');
                $table->index('recipient_global_identity_id');
                $table->index('state');
            });

            DB::statement("ALTER TABLE split_transaction_recipients ALTER COLUMN id SET DEFAULT gen_random_uuid()");

            DB::statement("CREATE UNIQUE INDEX idx_recipient_one_credit_per_split
                ON split_transaction_recipients (split_transaction_id, recipient_role)
                WHERE state NOT IN ('reversed', 'failed')");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('split_transaction_recipients');
        Schema::dropIfExists('split_transactions');
    }
};
