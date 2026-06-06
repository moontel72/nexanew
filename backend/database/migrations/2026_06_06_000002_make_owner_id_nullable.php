<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Make owner_id nullable — ownership now tracked via owner_identity_id
     * (FK to global_identities) per Wave 4 architecture.
     *
     * The old owner_id FK to users table is no longer canonical.
     */
    public function up(): void
    {
        // Drop the old FK constraint first
        try {
            DB::statement('ALTER TABLE transport_bus_layouts DROP CONSTRAINT IF EXISTS transport_bus_layouts_owner_id_foreign');
        } catch (\Exception $e) {
            // Constraint may not exist
        }

        // Make the column nullable
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            if (Schema::hasColumn('transport_bus_layouts', 'owner_id')) {
                $table->unsignedBigInteger('owner_id')->nullable()->change();
            }
        });
    }

    public function down(): void
    {
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            if (Schema::hasColumn('transport_bus_layouts', 'owner_id')) {
                $table->unsignedBigInteger('owner_id')->nullable(false)->change();
            }
        });

        // Re-add FK (may fail if users don't exist)
        try {
            DB::statement('ALTER TABLE transport_bus_layouts ADD CONSTRAINT transport_bus_layouts_owner_id_foreign FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE');
        } catch (\Exception $e) {
            // Ignore
        }
    }
};
