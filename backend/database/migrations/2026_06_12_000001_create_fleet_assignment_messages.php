<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fleet_assignment_messages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('fleet_assignment_id');
            $table->uuid('sender_id');
            $table->text('message_body');
            $table->enum('context_type', ['general', 'hold_reason', 'rejection_reason', 'document_request'])
                ->default('general');
            $table->timestamps();

            $table->foreign('fleet_assignment_id')
                ->references('id')->on('fleet_assignments')
                ->cascadeOnDelete();
            $table->foreign('sender_id')
                ->references('id')->on('global_identities');

            $table->index(['fleet_assignment_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fleet_assignment_messages');
    }
};
