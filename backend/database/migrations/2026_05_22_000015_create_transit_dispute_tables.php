<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transit_nfc_devices', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('terminal_name', 200);
            $table->string('device_hardware_uuid', 100)->unique();
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('transit_disputes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('trip_id');
            $table->uuid('user_id');
            $table->string('type', 30); // nfc_checkin, photo_proof
            $table->string('resolved_status', 20)->default('pending'); // pending, refunded, rejected, escalated
            $table->uuid('nfc_device_id')->nullable();
            $table->json('evidence_photos_json')->nullable();
            // [{"path":"...","lat":33.6,"lng":73.0,"captured_at":"2026-..."}, ...]
            $table->decimal('client_lat', 10, 7)->nullable();
            $table->decimal('client_lng', 10, 7)->nullable();
            $table->uuid('wallet_transaction_id')->nullable(); // refund transaction
            $table->text('admin_notes')->nullable();
            $table->uuid('resolved_by')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->foreign('trip_id')->references('id')->on('transport_bus_trips')->cascadeOnDelete();
            $table->index(['trip_id', 'type']);
            $table->index(['resolved_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transit_disputes');
        Schema::dropIfExists('transit_nfc_devices');
    }
};
