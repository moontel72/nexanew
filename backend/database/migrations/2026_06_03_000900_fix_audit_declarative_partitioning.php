<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Defect #2 Fix — Declarative Partitioning for Audit Logs
     *
     * Replaces the fallback inheritance-based partitioning with
     * PostgreSQL 10+ native declarative PARTITION BY RANGE (event_time).
     *
     * Per Section 10.8.2: "monthly-range-partitioned on event_time TIMESTAMPTZ"
     *
     * This migration should run AFTER 2026_06_03_000300_create_audit_log_systems.php
     * which created the tables as regular (non-partitioned). We DROP and
     * RECREATE with correct PARTITION BY RANGE clause.
     */
    public function up(): void
    {
        $this->rebuildPartitioned('audit_log_security');
        $this->rebuildPartitioned('audit_log_financial');
        $this->rebuildPartitioned('audit_log_operational');
        $this->rebuildPartitioned('audit_log_compliance');
    }

    private function rebuildPartitioned(string $table): void
    {
        // 1. Rename existing table to a backup
        $backup = "{$table}_old_partitioning";
        if (Schema::hasTable($table) && !Schema::hasTable($backup)) {
            Schema::rename($table, $backup);
        }

        // 2. Create parent as declaratively partitioned
        if (!Schema::hasTable($table)) {
            switch ($table) {
                case 'audit_log_security':
                    $this->createSecurityPartitioned($table);
                    break;
                case 'audit_log_financial':
                    $this->createFinancialPartitioned($table);
                    break;
                case 'audit_log_operational':
                    $this->createOperationalPartitioned($table);
                    break;
                case 'audit_log_compliance':
                    $this->createCompliancePartitioned($table);
                    break;
            }
        }

        // 3. Create first monthly partition
        $this->createMonthlyPartition($table);

        // 4. Migrate data from backup (if any)
        if (Schema::hasTable($backup)) {
            try {
                DB::statement("INSERT INTO {$table} SELECT * FROM {$backup}");
                Schema::dropIfExists($backup);
            } catch (\Exception $e) {
                report($e);
            }
        }
    }

    private function createSecurityPartitioned(string $table): void
    {
        DB::statement("
            CREATE TABLE {$table} (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                event_type VARCHAR(80),
                actor_global_identity_id UUID,
                target_global_identity_id UUID,
                claim_type VARCHAR(40),
                claim_id UUID,
                ip_address VARCHAR(45),
                user_agent TEXT,
                payload JSONB,
                payload_hash VARCHAR(64) NOT NULL,
                prev_chain_hash VARCHAR(64) NOT NULL,
                chain_hash VARCHAR(64) NOT NULL,
                event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                created_at TIMESTAMPTZ DEFAULT NOW()
            ) PARTITION BY RANGE (event_time)
        ");
        $this->createIndexes($table, ['event_type', 'actor_global_identity_id']);
    }

    private function createFinancialPartitioned(string $table): void
    {
        DB::statement("
            CREATE TABLE {$table} (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                event_type VARCHAR(80),
                actor_global_identity_id UUID,
                target_global_identity_id UUID,
                reference_type VARCHAR(80),
                reference_id UUID,
                amount DECIMAL(18,4),
                currency VARCHAR(8),
                payload JSONB,
                payload_hash VARCHAR(64) NOT NULL,
                prev_chain_hash VARCHAR(64) NOT NULL,
                chain_hash VARCHAR(64) NOT NULL,
                event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                created_at TIMESTAMPTZ DEFAULT NOW()
            ) PARTITION BY RANGE (event_time)
        ");
        $this->createIndexes($table, ['event_type', 'actor_global_identity_id', 'reference_type']);
    }

    private function createOperationalPartitioned(string $table): void
    {
        DB::statement("
            CREATE TABLE {$table} (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                event_type VARCHAR(80),
                actor_global_identity_id UUID,
                target_global_identity_id UUID,
                entity_type VARCHAR(80),
                entity_id UUID,
                operation VARCHAR(20),
                payload JSONB,
                payload_hash VARCHAR(64) NOT NULL,
                prev_chain_hash VARCHAR(64) NOT NULL,
                chain_hash VARCHAR(64) NOT NULL,
                event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                created_at TIMESTAMPTZ DEFAULT NOW()
            ) PARTITION BY RANGE (event_time)
        ");
        $this->createIndexes($table, ['event_type', 'actor_global_identity_id', 'entity_type']);
    }

    private function createCompliancePartitioned(string $table): void
    {
        DB::statement("
            CREATE TABLE {$table} (
                id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                event_type VARCHAR(80),
                actor_global_identity_id UUID,
                target_global_identity_id UUID,
                compliance_domain VARCHAR(80),
                reference_id UUID,
                payload JSONB,
                payload_hash VARCHAR(64) NOT NULL,
                prev_chain_hash VARCHAR(64) NOT NULL,
                chain_hash VARCHAR(64) NOT NULL,
                event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                created_at TIMESTAMPTZ DEFAULT NOW()
            ) PARTITION BY RANGE (event_time)
        ");
        $this->createIndexes($table, ['event_type', 'actor_global_identity_id', 'compliance_domain']);
    }

    private function createIndexes(string $table, array $columns): void
    {
        foreach ($columns as $col) {
            DB::statement("CREATE INDEX IF NOT EXISTS idx_{$table}_{$col} ON {$table} ({$col})");
        }
        DB::statement("CREATE INDEX IF NOT EXISTS idx_{$table}_event_time ON {$table} (event_time)");
        DB::statement("CREATE INDEX IF NOT EXISTS idx_{$table}_chain_hash ON {$table} (chain_hash)");
    }

    private function createMonthlyPartition(string $table): void
    {
        $monthStart = now()->startOfMonth()->format('Y-m-d');
        $monthEnd   = now()->addMonth()->startOfMonth()->format('Y-m-d');
        $suffix     = now()->format('Y_m');
        $partition  = "{$table}_{$suffix}";

        if (!Schema::hasTable($partition)) {
            DB::statement("
                CREATE TABLE {$partition} PARTITION OF {$table}
                FOR VALUES FROM ('{$monthStart}') TO ('{$monthEnd}')
            ");
        }
    }

    public function down(): void
    {
        // No reverse — partitioning is a structural upgrade.
        // The old table backups (_old_partitioning) are removed during up().
    }
};
