<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── Catering Bundles (parent container for grouped packets) ──
        if (!Schema::hasTable('catering_bundles')) {
            Schema::create('catering_bundles', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('company_id');
                $table->string('name', 200);
                $table->text('description')->nullable();
                $table->string('status', 30)->default('draft'); // draft | active | archived
                $table->timestamps();

                $table->index('company_id');
            });

            DB::statement('ALTER TABLE catering_bundles ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }

        // ── Catering Packets (child items inside a bundle, each gets a smart code) ──
        if (!Schema::hasTable('catering_packets')) {
            Schema::create('catering_packets', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('bundle_id');
                $table->uuid('company_id');
                $table->uuid('item_id')->nullable(); // FK to catering_items if linked
                $table->string('name', 200);
                $table->string('smart_code', 7)->unique(); // e.g. #59875
                $table->unsignedInteger('total_units')->default(0);
                $table->unsignedInteger('units_issued')->default(0);
                $table->unsignedInteger('units_remaining')->default(0);
                $table->string('photo_url')->nullable(); // camera override upload
                $table->string('status', 30)->default('active');
                $table->timestamps();

                $table->index('bundle_id');
                $table->index('company_id');
                $table->index('smart_code');
            });

            DB::statement('ALTER TABLE catering_packets ALTER COLUMN id SET DEFAULT uuid_generate_v4()');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('catering_packets');
        Schema::dropIfExists('catering_bundles');
    }
};
