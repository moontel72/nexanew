<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('financial_settlements', function (Blueprint $table) {
            $table->id();
            $table->uuid('user_id')->nullable()->comment('Customer requesting wallet withdrawal');
            $table->uuid('company_id')->nullable()->comment('Bus owner / goods company for voucher settlement');
            $table->string('type', 30); // voucher_settlement, wallet_withdrawal
            $table->decimal('amount', 15, 2);
            $table->string('currency', 10)->default('PKR');
            $table->string('status', 20)->default('pending'); // pending, processed, failed, rejected
            $table->uuid('reference_id')->nullable()->comment('External bank transfer trace ID');
            $table->uuid('voucher_id')->nullable()->comment('Linked nexatrace_voucher for settlement');
            $table->uuid('wallet_transaction_id')->nullable()->comment('Linked financial_wallet_transaction');
            $table->string('bank_name', 100)->nullable();
            $table->string('bank_account_last4', 4)->nullable();
            $table->text('admin_notes')->nullable();
            $table->uuid('processed_by')->nullable()->comment('Super Admin who processed');
            $table->timestamp('processed_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['type', 'status']);
            $table->index(['user_id', 'type']);
            $table->index(['company_id', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('financial_settlements');
    }
};
