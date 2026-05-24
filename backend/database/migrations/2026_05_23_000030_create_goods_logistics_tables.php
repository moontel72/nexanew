<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('warehouse_inventories')) {
            Schema::create('warehouse_inventories', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tenant_account_id');
                $table->string('store_name', 100);
                $table->string('store_room', 50)->nullable();
                $table->string('rack_identifier', 30);
                $table->string('shelf_number', 20);
                $table->string('qr_label', 100)->nullable();
                $table->string('status', 20)->default('available');
                $table->timestamps();
                $table->index('tenant_account_id');
                $table->index(['store_room', 'rack_identifier', 'shelf_number'], 'wh_location_idx');
            });
        }

        if (!Schema::hasTable('smart_tracking_payloads')) {
            Schema::create('smart_tracking_payloads', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('parent_code_id')->nullable();
                $table->foreign('parent_code_id')->references('id')->on('smart_tracking_payloads')->nullOnDelete();
                $table->string('smart_code_string', 20)->unique();
                $table->string('destination_province', 60)->nullable();
                $table->string('destination_district', 60)->nullable();
                $table->string('destination_town', 60)->nullable();
                $table->string('geofence_zone_tag', 10)->nullable();
                $table->integer('truck_placement_index')->default(0);
                $table->uuid('truck_plate_id')->nullable();
                $table->uuid('warehouse_shelf_id')->nullable();
                $table->string('status', 20)->default('pending');
                $table->integer('child_count')->default(0);
                $table->timestamps();
                $table->index('smart_code_string');
                $table->index('truck_plate_id');
                $table->index('parent_code_id');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('smart_tracking_payloads');
        Schema::dropIfExists('warehouse_inventories');
    }
};
