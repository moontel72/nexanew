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
     * Part 2: transport_bus_layout_revisions — Immutable snapshot vault
     *
     * Section 10.6: Each publish writes a new revision row with
     * the complete 2D coordinate grid snapshot. Revisions are
     * append-only — previous revisions are never modified.
     *
     * Snapshot JSONB structure (per Section 14E):
     * {
     *   "rows": 14,
     *   "cols": 4,
     *   "grid": [
     *     {"row": 1, "col": 1, "type": "seat", "seat_id": "A1", "bookable": true, "gender_restriction": null},
     *     {"row": 1, "col": 2, "type": "seat", "seat_id": "A2", "bookable": true, "gender_restriction": "female"},
     *     {"row": 1, "col": 3, "type": "aisle", "seat_id": null, "bookable": false},
     *     {"row": 1, "col": 4, "type": "seat", "seat_id": "A3", "bookable": true, "gender_restriction": null}
     *   ],
     *   "metadata": {
     *     "total_seats": 54,
     *     "bookable_seats": 52,
     *     "reserved_seats": 2,
     *     "layout_version": 1
     *   }
     * }
     */
    public function up(): void
    {
        if (Schema::hasTable('transport_bus_layout_revisions')) {
            return;
        }

        Schema::create('transport_bus_layout_revisions', function (Blueprint $table) {
            $table->id();                                          // BIGINT auto-increment PK
            $table->uuid('layout_id');
            $table->integer('version_number');
            $table->jsonb('full_snapshot');                       // complete 2D coordinate grid
            $table->uuid('published_by')->nullable();              // global_identity_id of publisher
            $table->text('change_description')->nullable();
            $table->timestampTz('created_at')->useCurrent();

            $table->foreign('layout_id')
                ->references('id')->on('transport_bus_layouts')
                ->onDelete('cascade');

            $table->unique(['layout_id', 'version_number']);
            $table->index('layout_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_bus_layout_revisions');
    }
};
