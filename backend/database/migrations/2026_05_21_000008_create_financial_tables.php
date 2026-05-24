<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Wallets — double-entry ledger accounts
        Schema::create('financial_wallets', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('owner_id');
            $table->string('owner_type', 40); // user, company, factory, truck_owner, truck_driver, goods_company, platform
            $table->string('wallet_type', 20)->default('main'); // main, escrow, subsidiary, treasury
            $table->string('currency', 10)->default('USD');
            $table->decimal('balance', 15, 2)->default(0);
            $table->decimal('held_balance', 15, 2)->default(0); // escrow/reserved funds
            $table->decimal('available_balance', 15, 2)->default(0); // balance - held
            $table->string('status', 20)->default('active'); // active, frozen, closed
            $table->boolean('is_treasury')->default(false);
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['owner_id', 'owner_type', 'wallet_type', 'currency']);
        });

        // 2. Wallet Transactions — immutable double-entry records
        Schema::create('financial_wallet_transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('wallet_id');
            $table->string('entry_type', 10); // credit, debit
            $table->decimal('amount', 15, 2);
            $table->decimal('balance_before', 15, 2);
            $table->decimal('balance_after', 15, 2);
            $table->string('currency', 10)->default('USD');
            $table->string('transaction_type', 50); // commission_payout, freight_payment, code_purchase, refund, escrow_hold, escrow_release, penalty
            $table->uuid('reference_id')->nullable(); // order_id, trip_id, invoice_id, bid_id
            $table->string('reference_type', 50)->nullable();
            $table->uuid('counterpart_transaction_id')->nullable(); // links to the paired credit/debit entry
            $table->string('status', 20)->default('pending'); // pending → settled → cleared | reversed
            $table->text('description')->nullable();
            $table->uuid('performed_by')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamp('settled_at')->nullable();
            $table->timestamp('cleared_at')->nullable();
            $table->timestamps();

            $table->foreign('wallet_id')->references('id')->on('financial_wallets')->cascadeOnDelete();
            $table->index(['wallet_id', 'entry_type', 'status']);
            $table->index(['reference_type', 'reference_id']);
        });

        // 3. Commission Configs — tier-based or flat commission rules
        Schema::create('financial_commission_configs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('module', 50); // freight_auction, code_generation, marketplace, bus_ticket, p2p_ride
            $table->string('payer_type', 40); // truck_owner, truck_driver, goods_company, factory, reseller
            $table->string('calculation_method', 20)->default('percentage'); // percentage, flat, tiered
            $table->decimal('rate', 8, 4)->default(0); // percentage (e.g., 0.05 = 5%) or flat amount
            $table->json('tiers')->nullable(); // [{"min_amount": 0, "max_amount": 1000, "rate": 0.10}, ...]
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->unique(['module', 'payer_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('financial_commission_configs');
        Schema::dropIfExists('financial_wallet_transactions');
        Schema::dropIfExists('financial_wallets');
    }
};
