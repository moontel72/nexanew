<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('factory_dispatches', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('batch_id');
            $table->uuid('driver_id');
            $table->uuid('storekeeper_id')->nullable();
            $table->string('dispatch_gate_pass_code', 50)->unique();
            $table->string('status', 20)->default('in_transit');
            // in_transit → arrived → handshake_verified → delivered → completed | disputed
            $table->decimal('origin_lat', 10, 7)->nullable();
            $table->decimal('origin_lng', 10, 7)->nullable();
            $table->decimal('dest_lat', 10, 7)->nullable();
            $table->decimal('dest_lng', 10, 7)->nullable();
            $table->timestamp('handshake_initiated_at')->nullable();
            $table->timestamp('handshake_verified_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['driver_id', 'status']);
            $table->index('batch_id');
        });

        Schema::create('inventory_transfers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('dispatch_id');
            $table->uuid('from_factory_id');
            $table->uuid('to_storekeeper_id');
            $table->unsignedInteger('scanned_items_count')->default(0);
            $table->timestamp('verified_at')->nullable();
            $table->uuid('verified_by')->nullable();
            $table->json('transferred_batch_serials')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->foreign('dispatch_id')->references('id')->on('factory_dispatches')->cascadeOnDelete();
            $table->unique('dispatch_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inventory_transfers');
        Schema::dropIfExists('factory_dispatches');
    }
};
