<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('bundle_items')) {
            return;
        }

        Schema::create('bundle_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('bundle_id');
            $table->uuid('carton_code_id')->nullable();
            $table->uuid('packet_code_id')->nullable();
            $table->timestamps();

            $table->index('bundle_id');
            $table->index('carton_code_id');
            $table->index('packet_code_id');

            $table->foreign('bundle_id')
                ->references('id')->on('bundles')
                ->onDelete('cascade');

            $table->foreign('carton_code_id')
                ->references('id')->on('carton_codes')
                ->onDelete('set null');

            $table->foreign('packet_code_id')
                ->references('id')->on('packet_codes')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bundle_items');
    }
};
