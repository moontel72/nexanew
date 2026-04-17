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
        Schema::table('invoices', function (Blueprint $table) {
            // Add indexes for better query performance
            $table->index('company_id');
            $table->index('subscription_id');
            $table->index('invoice_number');
            $table->index('status');
            $table->index('issue_date');
            $table->index('due_date');
            $table->index('payment_date');
            $table->index(['company_id', 'status']);
            $table->index(['company_id', 'issue_date']);
            $table->index(['status', 'due_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            $table->dropIndex(['company_id']);
            $table->dropIndex(['subscription_id']);
            $table->dropIndex(['invoice_number']);
            $table->dropIndex(['status']);
            $table->dropIndex(['issue_date']);
            $table->dropIndex(['due_date']);
            $table->dropIndex(['payment_date']);
            $table->dropIndex(['company_id', 'status']);
            $table->dropIndex(['company_id', 'issue_date']);
            $table->dropIndex(['status', 'due_date']);
        });
    }
};
