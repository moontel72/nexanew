<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('bundles')) {
            return;
        }

        Schema::create('bundles', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('bundle_code', 100)->unique();
            $table->string('order_reference', 200)->nullable();
            $table->uuid('company_id')->nullable();
            $table->integer('total_cartons')->default(0);
            $table->integer('total_packets')->default(0);
            $table->string('location_store', 200)->nullable();
            $table->string('location_shelf', 100)->nullable();
            $table->string('status', 50)->default('draft');
            $table->uuid('packed_by')->nullable();
            $table->timestamp('packed_at')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index('company_id');
            $table->index('status');
            $table->index('bundle_code');
            $table->foreign('company_id')->references('id')->on('companies')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bundles');
    }
};
