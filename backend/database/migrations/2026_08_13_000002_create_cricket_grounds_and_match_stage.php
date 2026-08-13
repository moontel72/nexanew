<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * NEXATRACE — CRICKET: GROUNDS + MATCH STAGE (Fixture Scheduler)
     *
     * Adds:
     *   1. cricket_grounds — venue registry (ground name, stadium location,
     *      optional capacity) so fixtures can reference a real venue.
     *   2. cricket_matches.stage — bracket tagging:
     *      group_stage | quarter_final | semi_final | final | friendly_test
     *   3. cricket_matches.ground_id — optional FK to cricket_grounds
     *      (the free-text venue column is kept for backward compatibility).
     *   4. Index on (tournament_id, scheduled_at) for schedule listings.
     *
     * Existing rows backfill to stage = group_stage via the column default.
     */
    public function up(): void
    {
        // ── 1. Grounds / venues registry ───────────────────────────────
        if (!Schema::hasTable('cricket_grounds')) {
            Schema::create('cricket_grounds', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('name', 200);
                $table->string('location', 200)->nullable()
                    ->comment('Stadium location / city');
                $table->integer('capacity')->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_grounds ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }

        // ── 2. Match stage + ground reference ──────────────────────────
        Schema::table('cricket_matches', function (Blueprint $table) {
            if (!Schema::hasColumn('cricket_matches', 'stage')) {
                $table->string('stage', 30)->default('group_stage')
                    ->comment('group_stage | quarter_final | semi_final | final | friendly_test');
            }
            if (!Schema::hasColumn('cricket_matches', 'ground_id')) {
                $table->uuid('ground_id')->nullable()
                    ->comment('FK to cricket_grounds.id');
            }
            $table->index(
                ['tournament_id', 'scheduled_at'],
                'cricket_matches_schedule_idx'
            );
        });
    }

    public function down(): void
    {
        Schema::table('cricket_matches', function (Blueprint $table) {
            $table->dropIndex('cricket_matches_schedule_idx');
            if (Schema::hasColumn('cricket_matches', 'ground_id')) {
                $table->dropColumn('ground_id');
            }
            if (Schema::hasColumn('cricket_matches', 'stage')) {
                $table->dropColumn('stage');
            }
        });

        Schema::dropIfExists('cricket_grounds');
    }
};
