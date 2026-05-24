<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('production_batches', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('factory_id');
            $table->string('batch_number', 100)->unique();
            $table->string('batch_name', 200)->nullable();
            $table->string('status', 30)->default('draft');
            // draft → in_production → sealed_locked → released_for_transit
            $table->uuid('product_id')->nullable();
            $table->unsignedInteger('total_items')->default(0);
            $table->string('factory_secret_key_hash', 64)->nullable();
            $table->string('supervisor_signature', 128)->nullable();
            $table->timestamp('sealed_at')->nullable();
            $table->timestamp('released_at')->nullable();
            $table->uuid('sealed_by')->nullable();
            $table->uuid('released_by')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['factory_id', 'status']);
        });

        Schema::create('product_serialized_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('batch_id');
            $table->string('crypto_serial_hash', 64)->unique();
            $table->unsignedInteger('incremental_seed');
            $table->boolean('is_scanned_out')->default(false);
            $table->timestamp('scanned_out_at')->nullable();
            $table->timestamps();

            $table->foreign('batch_id')->references('id')->on('production_batches')->cascadeOnDelete();
            $table->index(['batch_id', 'is_scanned_out']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_serialized_items');
        Schema::dropIfExists('production_batches');
    }
};
