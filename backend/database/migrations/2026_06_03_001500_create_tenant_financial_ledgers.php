<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 5 — Part 1: Tenant Financial Ledgers (Wallet Spine)
     *
     * Immutable-per-row financial ledger tracking every tenant's
     * running balance. Each row is a single currency wallet for a
     * tenant under a specific carrier company.
     *
     * Pessimistic locking via SELECT ... FOR UPDATE on all debit/credit
     * operations prevents race conditions in concurrent settlement flows.
     *
     * Constraint: UNIQUE(tenant_account_id, carrier_company_id, currency)
     * ensures one wallet per (tenant, carrier, currency) tuple.
     */
    public function up(): void
    {
        if (Schema::hasTable('tenant_financial_ledgers')) {
            return;
        }

        Schema::create('tenant_financial_ledgers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('tenant_account_id');
            $table->uuid('carrier_company_id')->nullable();
            $table->decimal('balance_amount', 18, 4)->default(0);
            $table->char('currency', 3)->default('PKR');
            $table->uuid('last_transaction_id')->nullable();
            $table->integer('version_counter')->default(0);        // optimistic concurrency
            $table->string('status', 20)->default('active');
            $table->timestamps();

            $table->foreign('tenant_account_id')
                ->references('id')->on('tenant_accounts')
                ->onDelete('restrict');

            $table->unique(['tenant_account_id', 'carrier_company_id', 'currency']);

            $table->index('tenant_account_id');
            $table->index('carrier_company_id');
            $table->index('status');
        });

        DB::statement("ALTER TABLE tenant_financial_ledgers ALTER COLUMN id SET DEFAULT gen_random_uuid()");
    }

    public function down(): void
    {
        Schema::dropIfExists('tenant_financial_ledgers');
    }
};
