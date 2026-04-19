<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            // Humne default(0) add kar diya hai taake calculation fail na ho
            $table->decimal('credit_limit', 12, 2)->default(0)->after('status');
            $table->decimal('credit_used', 12, 2)->default(0)->after('credit_limit');
            
            // COALESCE ka istemal kiya hai taake agar value null ho to use 0 mana jaye
            $table->decimal('credit_available', 12, 2)
                ->storedAs('COALESCE(credit_limit, 0) - COALESCE(credit_used, 0)')
                ->after('credit_used');

            $table->decimal('credit_utilization_percentage', 5, 2)
                ->storedAs('CASE WHEN COALESCE(credit_limit, 0) > 0 THEN (COALESCE(credit_used, 0) / credit_limit) * 100 ELSE 0 END')
                ->after('credit_available');

            $table->string('credit_status', 20)->default('good')->after('credit_utilization_percentage');
            $table->date('credit_limit_set_at')->nullable()->after('credit_status');

            $table->foreignId('credit_limit_set_by')
                ->nullable()
                ->after('credit_limit_set_at')
                ->constrained('users')
                ->onDelete('set null');

            $table->date('credit_review_date')->nullable()->after('credit_limit_set_by');
            $table->text('credit_limit_notes')->nullable()->after('credit_review_date');
            $table->jsonb('credit_metadata')->nullable()->after('credit_limit_notes');

            $table->index('credit_status');
            $table->index('credit_limit');
            $table->index('credit_used');
            $table->index('credit_utilization_percentage');
            $table->index('credit_review_date');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->dropForeign(['credit_limit_set_by']);
            $table->dropColumn([
                'credit_limit', 'credit_used', 'credit_available', 
                'credit_utilization_percentage', 'credit_status', 
                'credit_limit_set_at', 'credit_limit_set_by', 
                'credit_review_date', 'credit_limit_notes', 'credit_metadata',
            ]);
        });
    }
};