<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * NEXATRACE — ABSOLUTE BUS LAYOUT REVISIONS TABLE
 * ================================================
 *
 * Immutable snapshot vault for the Absolute (Freeform) Canvas Engine.
 * Each publish writes a new revision row with the complete component
 * snapshot (X, Y, Width, Height, Rotation coordinates).
 * Revisions are append-only — previous revisions are never modified.
 *
 * 100% isolated from the legacy transport_bus_layout_revisions table.
 *
 * Snapshot JSONB structure:
 * {
 *   "canvas": {"canvas_width": 280, "canvas_height": 896, "deck_level": "lower"},
 *   "display_name": "54-Seat Coach",
 *   "components": [
 *     {"id": "uuid", "type": "seat", "x": 0, "y": 28, "width": 56, "height": 56, "rotation": 0, ...},
 *     ...
 *   ],
 *   "metadata": {"total_bookable_seats": 54}
 * }
 */
return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('absolute_bus_layout_revisions')) {
            return;
        }

        Schema::create('absolute_bus_layout_revisions', function (Blueprint $table) {
            $table->id();
            $table->uuid('layout_id');
            $table->unsignedInteger('version_number');
            $table->jsonb('full_snapshot');
            $table->uuid('published_by')->nullable();
            $table->text('change_description')->nullable();
            $table->timestampTz('created_at')->useCurrent();

            $table->foreign('layout_id')
                ->references('id')->on('absolute_bus_layouts')
                ->onDelete('cascade');

            $table->unique(['layout_id', 'version_number']);
            $table->index('layout_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absolute_bus_layout_revisions');
    }
};
