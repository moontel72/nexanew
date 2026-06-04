<?php

use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Defect #2 Fix — Declarative Partitioning for Audit Logs
     *
     * This is now a NO-OP because migration 000300 already creates
     * the audit tables correctly with composite PRIMARY KEY (id, event_time)
     * and declarative PARTITION BY RANGE (event_time).
     */
    public function up(): void
    {
        // Tables already created correctly by the fixed 000300 migration.
    }

    public function down(): void
    {
        // No-op
    }
};
