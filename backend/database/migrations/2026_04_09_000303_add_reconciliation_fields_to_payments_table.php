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
        Schema::table('payments', function (Blueprint $table) {
            // Add reconciliation fields
            $table->string('gateway_name', 50)->nullable()->after('method');
            $table->string('gateway_transaction_id', 255)->nullable()->after('gateway_name');
            $table->string('reconciliation_status', 20)->default('pending')->after('gateway_transaction_id');
            $table->decimal('expected_amount', 10, 2)->nullable()->after('reconciliation_status');
            $table->decimal('discrepancy_amount', 10, 2)->nullable()->after('expected_amount');
            $table->text('reconciliation_notes')->nullable()->after('discrepancy_amount');
            
            // FIX: Changed from uuid() to foreignId() to match users.id (BigInt)
            $table->foreignId('reconciled_by')
                ->nullable()
                ->after('reconciliation_notes')
                ->constrained('users')
                ->onDelete('set null');

            $table->timestamp('reconciled_at')->nullable()->after('reconciled_by');

            // Add indexes for reconciliation
            $table->index('gateway_name');
            $table->index('gateway_transaction_id');
            $table->index('reconciliation_status');
            $table->index('reconciled_at');
            // Index for reconciled_by is automatically handled by foreignId() in some versions, 
            // but keeping explicit index as per your original code.
            $table->index('reconciled_by');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            // Drop foreign key
            $table->dropForeign(['reconciled_by']);

            // Drop indexes
            $table->dropIndex(['gateway_name']);
            $table->dropIndex(['gateway_transaction_id']);
            $table->dropIndex(['reconciliation_status']);
            $table->dropIndex(['reconciled_at']);
            $table->dropIndex(['reconciled_by']);

            // Drop columns
            $table->dropColumn([
                'gateway_name',
                'gateway_transaction_id',
                'reconciliation_status',
                'expected_amount',
                'discrepancy_amount',
                'reconciliation_notes',
                'reconciled_by',
                'reconciled_at',
            ]);
        });
    }
};