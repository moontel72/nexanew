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
        Schema::table('companies', function (Blueprint $table) {
            // Add credit limit fields
            $table->decimal('credit_limit', 12, 2)->nullable()->after('status');
            $table->decimal('credit_used', 12, 2)->default(0)->after('credit_limit');
            
            // PostgreSQL does not support "virtual" generated columns, only "stored".
            // Also, we use standard decimal for calculation safety.
            $table->decimal('credit_available', 12, 2)
                ->storedAs('credit_limit - credit_used')
                ->after('credit_used');

            $table->decimal('credit_utilization_percentage', 5, 2)
                ->storedAs('CASE WHEN credit_limit > 0 THEN (credit_used / credit_limit) * 100 ELSE 0 END')
                ->after('credit_available');

            $table->string('credit_status', 20)->default('good')->after('credit_utilization_percentage');
            $table->date('credit_limit_set_at')->nullable()->after('credit_status');

            // FIX: Changed from uuid to foreignId to match users.id (BigInt)
            $table->foreignId('credit_limit_set_by')
                ->nullable()
                ->after('credit_limit_set_at')
                ->constrained('users')
                ->onDelete('set null');

            $table->date('credit_review_date')->nullable()->after('credit_limit_set_by');
            $table->text('credit_limit_notes')->nullable()->after('credit_review_date');
            $table->jsonb('credit_metadata')->nullable()->after('credit_limit_notes');

            // Add indexes for credit fields
            $table->index('credit_status');
            $table->index('credit_limit');
            $table->index('credit_used');
            $table->index('credit_utilization_percentage');
            $table->index('credit_review_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            // Drop foreign key
            $table->dropForeign(['credit_limit_set_by']);

            // Drop indexes
            $table->dropIndex(['credit_status']);
            $table->dropIndex(['credit_limit']);
            $table->dropIndex(['credit_used']);
            $table->dropIndex(['credit_utilization_percentage']);
            $table->dropIndex(['credit_review_date']);

            // Drop columns
            $table->dropColumn([
                'credit_limit',
                'credit_used',
                'credit_available',
                'credit_utilization_percentage',
                'credit_status',
                'credit_limit_set_at',
                'credit_limit_set_by',
                'credit_review_date',
                'credit_limit_notes',
                'credit_metadata',
            ]);
        });
    }
};