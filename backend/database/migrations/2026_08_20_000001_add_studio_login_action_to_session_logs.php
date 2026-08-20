<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Phase-1 SSO — Extend the manager session-log action enum with
 * `studio_login` (Todd Studio SSO login audit trail).
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

            DB::statement(
                "ALTER TYPE cricket_manager_session_logs_action
                 ADD VALUE IF NOT EXISTS 'studio_login'"
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
