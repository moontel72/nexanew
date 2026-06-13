<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ABSOLUTE BUS LAYOUTS TABLE
 * =======================================
 *
 * Creates the `absolute_bus_layouts` table for the Absolute
 * (Freeform) Canvas Engine. This table is 100% independent
 * from the legacy `transport_bus_layouts` grid-based table.
 *
 * Components are stored as JSON with X, Y, Width, Height, Rotation
 * — no grid row/column coordinates.
 *
 * API routes: /api/bus-owner/absolute-layouts/*
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('absolute_bus_layouts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('owner_identity_id')->nullable()->index();
            $table->string('display_name')->default('Untitled Layout');
            $table->string('deck_level')->default('lower');
            $table->unsignedInteger('canvas_width')->default(280);
            $table->unsignedInteger('canvas_height')->default(896);
            $table->json('current_snapshot')->nullable();
            $table->string('layout_status')->default('draft'); // draft | published | archived
            $table->unsignedInteger('version_number')->default(1);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            // Foreign key
            $table->foreign('owner_identity_id')
                ->references('id')
                ->on('global_identities')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absolute_bus_layouts');
    }
};
