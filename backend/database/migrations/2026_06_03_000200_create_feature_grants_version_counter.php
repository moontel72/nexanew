<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 1 — Step 1.2: Feature Grants Version Counter
     *
     * Single-row system table. Section 10.3.1 — L3 Postgres Counter.
     * id is permanently fixed to 1. version is monotonic BIGINT.
     *
     * This counter is incremented atomically inside the same DB transaction
     * as any sub_admin_feature_grants mutation (Section 10.3.3 Write Path).
     */
    public function up(): void
    {
        if (Schema::hasTable('feature_grants_version_counter')) {
            return;
        }

        Schema::create('feature_grants_version_counter', function (Blueprint $table) {
            $table->integer('id')->primary()->default(1);
            $table->bigInteger('version')->default(1);
            $table->timestampTz('updated_at')->useCurrent();
        });

        DB::table('feature_grants_version_counter')->insert([
            'id'         => 1,
            'version'    => 1,
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('feature_grants_version_counter');
    }
};
