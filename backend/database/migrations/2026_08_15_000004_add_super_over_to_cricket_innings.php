<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Phase 5 — Super-over support.
 *
 * cricket_innings gains:
 *   - is_super_over: flags a one-over eliminator innings
 *   - overs_limit:    per-innings over limit (super over = 1); when null
 *                     the engine falls back to the match's overs_per_side
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cricket_innings', function (Blueprint $table) {
            if (!Schema::hasColumn('cricket_innings', 'is_super_over')) {
                $table->boolean('is_super_over')->default(false)->after('status')
                    ->comment('One-over eliminator innings');
            }
            if (!Schema::hasColumn('cricket_innings', 'overs_limit')) {
                $table->integer('overs_limit')->nullable()->after('is_super_over')
                    ->comment('Per-innings over limit (super over = 1); null = match overs_per_side');
            }
        });
    }

    public function down(): void
    {
        Schema::table('cricket_innings', function (Blueprint $table) {
            $table->dropColumn(['is_super_over', 'overs_limit']);
        });
    }
};
