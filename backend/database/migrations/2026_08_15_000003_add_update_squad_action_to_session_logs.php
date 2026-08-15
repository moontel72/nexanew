<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Phase 0 — Extend the manager session-log action enum with
 * `update_squad` (lineup audit) and `voice_score_apply` (missing
 * value already used by the voice-score apply flow).
 *
 * Postgres `ALTER TYPE ... ADD VALUE IF NOT EXISTS` is idempotent.
 * Skipped silently on non-Postgres drivers (e.g. sqlite tests).
 */
return new class extends Migration
{
    public function up(): void
    {
        try {
            if (DB::connection()->getDriverName() !== 'pgsql') {
                return;
            }
            // Phase 0 actions plus a missing value used by the existing
            // voice-score apply flow (latent bug fix, same module).
            DB::statement(
                "ALTER TYPE cricket_manager_session_logs_action
                 ADD VALUE IF NOT EXISTS 'update_squad'"
            );
            DB::statement(
                "ALTER TYPE cricket_manager_session_logs_action
                 ADD VALUE IF NOT EXISTS 'voice_score_apply'"
            );
        } catch (\Throwable $e) {
            report($e);
        }
    }

    public function down(): void
    {
        // Postgres enum values cannot be removed safely — no-op.
    }
};
