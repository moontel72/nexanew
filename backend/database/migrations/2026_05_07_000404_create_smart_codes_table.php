<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('smart_codes')) {
            return;
        }

        Schema::create('smart_codes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('district_prefix', 5);
            $table->string('zone_code', 3);
            $table->string('parcel_serial', 4);
            $table->string('full_code', 15)->unique();
            $table->uuid('zone_id')->nullable();
            $table->uuid('delivery_id')->nullable();
            $table->string('status', 50)->default('active');
            $table->timestamp('scanned_at')->nullable();
            $table->string('scanned_by', 100)->nullable();
            $table->timestamps();

            $table->index('zone_id');
            $table->index('delivery_id');
            $table->index('status');
            $table->index('full_code');

            $table->foreign('zone_id')->references('id')->on('zones')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('smart_codes');
    }
};
