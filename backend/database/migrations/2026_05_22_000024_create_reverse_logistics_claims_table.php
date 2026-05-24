<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reverse_logistics_claims', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->uuid('factory_id')->nullable();
            $table->uuid('storekeeper_id')->nullable();
            $table->string('crypto_serial_hash', 64);
            $table->string('claim_type', 20)->default('damage'); // return, damage
            $table->string('status', 30)->default('pending_inspection');
            // pending_inspection → approved_refund | rejected
            $table->json('evidence_metadata_json')->nullable();
            $table->decimal('refunded_amount', 15, 2)->nullable();
            $table->decimal('claimed_amount', 15, 2)->nullable();
            $table->uuid('wallet_transaction_id')->nullable();
            $table->text('inspection_notes')->nullable();
            $table->uuid('inspected_by')->nullable();
            $table->timestamp('inspected_at')->nullable();
            $table->timestamps();

            $table->index(['crypto_serial_hash', 'status']);
            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reverse_logistics_claims');
    }
};
