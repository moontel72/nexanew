<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('refunds', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('invoice_id');
            $table->uuid('payment_id')->nullable();
            $table->uuid('company_id');
            $table->string('refund_number', 100)->unique();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->string('reason', 500);
            $table->string('status', 20)->default('pending'); // pending, approved, partially_approved, rejected, processed, failed
            $table->decimal('approved_amount', 10, 2)->nullable();
            $table->uuid('requested_by')->nullable();
            $table->timestamp('requested_at')->nullable();
            $table->uuid('processed_by')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->string('rejection_reason', 500)->nullable();
            $table->uuid('rejected_by')->nullable();
            $table->timestamp('rejected_at')->nullable();
            $table->string('gateway_refund_id', 255)->nullable();
            $table->string('gateway_name', 50)->nullable();
            $table->text('notes')->nullable();
            $table->jsonb('metadata')->nullable();
            $table->timestamps();

            // Foreign key constraints
            $table->foreign('invoice_id')
                ->references('id')
                ->on('invoices')
                ->onDelete('cascade');

            $table->foreign('payment_id')
                ->references('id')
                ->on('payments')
                ->onDelete('set null');

            $table->foreign('company_id')
                ->references('id')
                ->on('companies')
                ->onDelete('cascade');

            $table->foreign('requested_by')
                ->references('id')
                ->on('users')
                ->onDelete('set null');

            $table->foreign('processed_by')
                ->references('id')
                ->on('users')
                ->onDelete('set null');

            $table->foreign('rejected_by')
                ->references('id')
                ->on('users')
                ->onDelete('set null');

            // Indexes
            $table->index('invoice_id');
            $table->index('payment_id');
            $table->index('company_id');
            $table->index('refund_number');
            $table->index('status');
            $table->index('requested_at');
            $table->index('processed_at');
            $table->index('rejected_at');
            $table->index('gateway_refund_id');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('refunds');
    }
};
