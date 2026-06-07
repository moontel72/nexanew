<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Make legacy owner_id nullable — superseded by owner_identity_id
     * (Wave 4 identity spine). Also drop the old FK to users table.
     */
    public function up(): void
    {
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            // Drop the old foreign key if it exists
            try {
                $table->dropForeign(['owner_id']);
            } catch (\Throwable) {
                // FK may not exist in all environments
            }

            // Make owner_id nullable (now superseded by owner_identity_id)
            $table->unsignedBigInteger('owner_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            $table->unsignedBigInteger('owner_id')->nullable(false)->change();
        });
    }
};
