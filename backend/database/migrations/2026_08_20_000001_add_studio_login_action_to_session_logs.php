<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Phase-1 SSO — Extend the manager session-log action "enum" with
 * `studio_login` (Todd Studio SSO login audit trail).
 *
 * Postgres gotcha: Laravel's `$table->enum()` on Postgres creates BOTH a
 * native enum type AND a CHECK constraint. `ALTER TYPE ... ADD VALUE`
 * updates only the native type — the CHECK constraint is left stale, so
 * inserts using a new value fail with SQLSTATE[23514]. The earlier
 * migrations for `update_squad` and `voice_score_apply` only ran ALTER
 * TYPE and therefore silently left a stale CHECK behind.
 *
 * This migration therefore:
 * 1. adds the value to the native enum type where one exists
 *    (fresh Laravel-created schemas), tolerating its absence on
 *    production's plain-VARCHAR column;
 * 2. drops the stale CHECK constraint; and
 * 3. re-creates it including `update_squad`, `voice_score_apply` and
 *    `studio_login`, repairing the earlier values too.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (DB::connection()->getDriverName() !== 'pgsql') {
            return;
        }

        try {
            DB::statement("ALTER TYPE cricket_manager_session_logs_action ADD VALUE IF NOT EXISTS 'studio_login'");
        } catch (\Throwable $e) {
            report($e);
        }

        DB::statement('ALTER TABLE cricket_manager_session_logs DROP CONSTRAINT IF EXISTS cricket_manager_session_logs_action_check');

        DB::statement("ALTER TABLE cricket_manager_session_logs ADD CONSTRAINT cricket_manager_session_logs_action_check CHECK (action IN ('login','logout','take_over_match','release_match','update_score','update_stream','update_sponsor','voice_score_input','session_timeout','update_squad','voice_score_apply','studio_login'))");
    }

    public function down(): void
    {
        // Postgres enum values cannot be removed safely — no-op.
    }
};
