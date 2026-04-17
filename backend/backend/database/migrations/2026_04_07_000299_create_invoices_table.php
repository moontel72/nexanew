<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('invoices')) {
            return;
        }

        Schema::create('invoices', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id');
            $table->uuid('subscription_id')->nullable();
            $table->string('invoice_number', 100)->unique();

            $table->date('period_start');
            $table->date('period_end');
            $table->date('issue_date');
            $table->date('due_date');

            $table->decimal('subtotal', 10, 2);
            $table->decimal('tax_amount', 10, 2)->default(0);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('total_amount', 10, 2);
            $table->string('currency', 3)->default('USD');

            $table->json('items')->nullable();

            $table->string('status', 20)->default('pending');
            $table->date('payment_date')->nullable();
            $table->string('payment_method', 50)->nullable();
            $table->string('payment_reference', 255)->nullable();

            $table->text('notes')->nullable();
            $table->json('metadata')->nullable();

            $table->timestamps();

            $table->index('company_id');
            $table->index('subscription_id');
            $table->index('status');
            $table->index('issue_date');
            $table->index('due_date');
            $table->index('payment_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoices');
    }
};
