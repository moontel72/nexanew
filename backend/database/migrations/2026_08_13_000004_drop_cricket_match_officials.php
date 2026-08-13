<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * NEXATRACE — CRICKET: Drop the orphan match-officials table.
     *
     * cricket_match_officials was never referenced by any controller,
     * page, or API endpoint (its model was only reachable through an
     * unused Tournament::officials() relation). The Sub-Admin cleanup
     * removed the last traces, so the table is dropped.
     *
     * Reversible: down() recreates the original schema.
     */
    public function up(): void
    {
        Schema::dropIfExists('cricket_match_officials');
    }

    public function down(): void
    {
        if (!Schema::hasTable('cricket_match_officials')) {
            Schema::create('cricket_match_officials', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('tournament_id');
                $table->string('name', 200);
                $table->enum('role', ['umpire', 'third_umpire', 'referee', 'scorer'])
                    ->default('umpire');
                $table->string('photo_url', 500)->nullable();
                $table->timestamps();
                $table->softDeletes();
            });
            DB::statement("ALTER TABLE cricket_match_officials ALTER COLUMN id SET DEFAULT gen_random_uuid()");
        }
    }
};
