<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 4 — Bus Transit Seat Layout System
     *
     * Part 1: transport_bus_layouts — Living layout state
     *
     * Section 10.6: Decentralized Seat Layout Sovereignty.
     *
     * Each layout is owned by a global identity (bus owner). The
     * is_locked_sovereign flag prevents cross-tenant mutation.
     * version_number increments on every published revision.
     */
    public function up(): void
    {
        if (Schema::hasTable('transport_bus_layouts')) {
            return;
        }

        Schema::create('transport_bus_layouts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('owner_identity_id');
            $table->uuid('carrier_company_id')->nullable();
            $table->string('vehicle_class', 30);                   // coach_54, coaster_34, sleeper, hiace, etc.
            $table->string('display_name', 160)->nullable();
            $table->boolean('is_locked_sovereign')->default(true);
            $table->integer('version_number')->default(1);
            $table->string('status', 20)->default('draft');        // draft, published, archived
            $table->jsonb('current_snapshot')->nullable();         // live 2D grid (denormalized for reads)
            $table->timestamps();

            $table->foreign('owner_identity_id')
                ->references('id')->on('global_identities')
                ->onDelete('restrict');

            $table->index('owner_identity_id');
            $table->index('vehicle_class');
            $table->index('status');
        });

        DB::statement("ALTER TABLE transport_bus_layouts ALTER COLUMN id SET DEFAULT gen_random_uuid()");
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_bus_layouts');
    }
};
