<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('offline_sync_payloads', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->string('device_id', 100)->nullable();
            $table->string('app_module', 50); // store_keeper, factory_driver, truck_driver
            $table->string('payload_type', 50); // scan_code, update_trip_status, submit_expense, link_code, rack_allocate
            $table->json('payload_data'); // raw JSON batch from mobile
            $table->string('client_uuid', 100); // client-generated UUID per action batch (idempotency key)
            $table->timestamp('client_timestamp'); // when the action happened on device
            $table->string('status', 20)->default('pending'); // pending → processing → processed | failed | duplicate
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->text('processing_notes')->nullable();
            $table->json('resolved_conflicts')->nullable();
            $table->timestamp('processed_at')->nullable();
            $table->timestamps();

            $table->unique('client_uuid'); // idempotency enforcement
            $table->index(['user_id', 'status']);
            $table->index(['app_module', 'status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('offline_sync_payloads');
    }
};
