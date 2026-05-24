<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('marketplace_pool_participants', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('pool_id');
            $table->uuid('participant_company_id');
            $table->unsignedInteger('committed_quantity');
            $table->decimal('committed_amount', 15, 2);
            $table->string('participation_status', 20)->default('committed');
            // committed → confirmed → paid | withdrawn
            $table->timestamp('withdrawn_at')->nullable();
            $table->text('withdrawal_reason')->nullable();
            $table->timestamps();

            $table->foreign('pool_id')->references('id')->on('marketplace_group_buy_pools')->cascadeOnDelete();
            $table->foreign('participant_company_id')->references('id')->on('companies')->cascadeOnDelete();

            $table->unique(['pool_id', 'participant_company_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('marketplace_pool_participants');
    }
};
