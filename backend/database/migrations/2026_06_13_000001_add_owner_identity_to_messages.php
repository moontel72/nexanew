<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add owner_identity_id to decouple from volatile fleet_assignment lifecycle
        Schema::table('fleet_assignment_messages', function (Blueprint $table) {
            $table->uuid('owner_identity_id')->nullable()->after('fleet_assignment_id');
            $table->index('owner_identity_id');
            $table->index('created_at'); // for 60-day retention pruning
        });

        // Drop the cascade FK so messages survive assignment deletion
        Schema::table('fleet_assignment_messages', function (Blueprint $table) {
            $table->dropForeign(['fleet_assignment_id']);
        });

        // Make fleet_assignment_id nullable so old messages aren't orphaned
        Schema::table('fleet_assignment_messages', function (Blueprint $table) {
            $table->uuid('fleet_assignment_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('fleet_assignment_messages', function (Blueprint $table) {
            $table->dropColumn('owner_identity_id');
        });
    }
};
