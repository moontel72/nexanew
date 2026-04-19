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
        Schema::create('credit_notes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('company_id');
            $table->uuid('invoice_id')->nullable();
            $table->string('credit_note_number', 100)->unique();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->string('reason', 500);
            $table->string('status', 20)->default('pending'); // pending, approved, applied, cancelled
            $table->date('issue_date');

            // --- TYPE FIX START ---
            // Agar aapki users table ki ID UUID nahi balki number hai, 
            // to niche wali line ko $table->unsignedBigInteger('approved_by')->nullable(); se badal den.
            // Lekin error ke mutabiq aapne yahan UUID rakha tha jo mismatch ho raha tha.
            // Hum ise default Laravel ID type se match karne ke liye change kar rahe hain:
            $table->foreignId('approved_by')
                ->nullable()
                ->constrained('users')
                ->onDelete('set null');
            // --- TYPE FIX END ---

            $table->timestamp('approved_at')->nullable();
            $table->boolean('applied_to_invoice')->default(false);
            $table->timestamp('applied_at')->nullable();
            $table->text('notes')->nullable();
            $table->jsonb('metadata')->nullable();
            $table->timestamps();

            // Foreign key constraints for UUIDs
            $table->foreign('company_id')
                ->references('id')
                ->on('companies')
                ->onDelete('cascade');

            $table->foreign('invoice_id')
                ->references('id')
                ->on('invoices')
                ->onDelete('set null');

            // Indexes
            $table->index('company_id');
            $table->index('invoice_id');
            $table->index('credit_note_number');
            $table->index('status');
            $table->index('issue_date');
            $table->index('approved_at');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('credit_notes');
    }
};