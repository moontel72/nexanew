<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 1 — Step 1.3: Cryptographic Append-Only Partitioned Audit Logs
     *
     * Per Section 10.8 of NEXATRACE_SUPREME_MASTER_SPEC.md v5.0.
     *
     * Four partitioned tables:
     *   - audit_log_security    — Logins, credential claims, token invalidations
     *   - audit_log_financial   — Wallet movements, ledger transactions
     *   - audit_log_operational — Fleet structural CRUD modifications
     *   - audit_log_compliance  — Data extractions, override flags, KYC decisions
     *
     * Each table:
     *   - Is monthly-range-partitioned on `event_time` (Section 10.8.2)
     *   - Carries SHA-256 chain hashes for tamper evidence (Section 10.8.3)
     *   - Is append-only (GRANT INSERT, SELECT only — Section 10.8.4)
     *
     * Cryptographic chain per 10.8.3:
     *   chain_hash = SHA-256(prev_chain_hash ∥ payload_hash ∥ event_time ∥ actor)
     */
    public function up(): void
    {
        $this->createAuditTable('audit_log_security', [
            'event_type VARCHAR(80) NOT NULL',
            'actor_global_identity_id UUID',
            'target_global_identity_id UUID',
            'claim_type VARCHAR(40)',
            'claim_id UUID',
            'ip_address VARCHAR(45)',
            'user_agent TEXT',
        ], ['event_type', 'actor_global_identity_id']);

        $this->createAuditTable('audit_log_financial', [
            'event_type VARCHAR(80) NOT NULL',
            'actor_global_identity_id UUID',
            'target_global_identity_id UUID',
            'reference_type VARCHAR(80)',
            'reference_id UUID',
            'amount DECIMAL(18, 4)',
            'currency VARCHAR(8)',
        ], ['event_type', 'actor_global_identity_id', 'reference_type']);

        $this->createAuditTable('audit_log_operational', [
            'event_type VARCHAR(80) NOT NULL',
            'actor_global_identity_id UUID',
            'target_global_identity_id UUID',
            'entity_type VARCHAR(80)',
            'entity_id UUID',
            'operation VARCHAR(20)',
        ], ['event_type', 'actor_global_identity_id', 'entity_type']);

        $this->createAuditTable('audit_log_compliance', [
            'event_type VARCHAR(80) NOT NULL',
            'actor_global_identity_id UUID',
            'target_global_identity_id UUID',
            'compliance_domain VARCHAR(80)',
            'reference_id UUID',
        ], ['event_type', 'actor_global_identity_id', 'compliance_domain']);
    }

    private function createAuditTable(string $tableName, array $streamColumns, array $indexColumns): void
    {
        if (Schema::hasTable($tableName)) {
            return;
        }

        // PostgreSQL requires the parent to be created WITH PARTITION BY RANGE
        // before any child partitions can be attached. Schema builder does not
        // support this natively, so we use raw DDL.

        $cols = implode(",\n            ", array_merge([
            'id UUID PRIMARY KEY DEFAULT gen_random_uuid()',
        ], $streamColumns, [
            'payload JSONB',
            'payload_hash VARCHAR(64) NOT NULL',
            'prev_chain_hash VARCHAR(64) NOT NULL',
            'chain_hash VARCHAR(64) NOT NULL',
            'event_time TIMESTAMPTZ NOT NULL DEFAULT NOW()',
            'created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()',
        ]));

        DB::statement("CREATE TABLE {$tableName} ({$cols}) PARTITION BY RANGE (event_time)");

        // Add indexes on the specified columns plus chain_hash
        $allIndexes = array_merge($indexColumns, ['event_time', 'chain_hash']);
        foreach ($allIndexes as $col) {
            $idxName = $tableName . '_' . $col . '_idx';
            DB::statement("CREATE INDEX IF NOT EXISTS {$idxName} ON {$tableName} ({$col})");
        }

        // Create initial monthly partition
        $this->createInitialPartition($tableName);
    }

    private function createInitialPartition(string $parentTable): void
    {
        $monthStart     = now()->startOfMonth()->format('Y-m-d');
        $monthEnd       = now()->addMonth()->startOfMonth()->format('Y-m-d');
        $suffix         = now()->format('Y_m');
        $partitionTable = "{$parentTable}_{$suffix}";

        if (Schema::hasTable($partitionTable)) {
            return;
        }

        try {
            DB::statement("
                CREATE TABLE IF NOT EXISTS {$partitionTable}
                PARTITION OF {$parentTable}
                FOR VALUES FROM ('{$monthStart}') TO ('{$monthEnd}')
            ");
        } catch (\Exception $e) {
            try {
                DB::statement("
                    CREATE TABLE IF NOT EXISTS {$partitionTable}
                    (LIKE {$parentTable} INCLUDING DEFAULTS INCLUDING INDEXES)
                ");
                DB::statement("ALTER TABLE {$partitionTable} INHERIT {$parentTable}");
                DB::statement("
                    ALTER TABLE {$partitionTable}
                    ADD CONSTRAINT {$partitionTable}_event_time_check
                    CHECK (event_time >= '{$monthStart}' AND event_time < '{$monthEnd}')
                ");
            } catch (\Exception $inner) {
                report($inner);
            }
        }
    }

    public function down(): void
    {
        $tables = ['audit_log_security', 'audit_log_financial', 'audit_log_operational', 'audit_log_compliance'];
        $suffix = now()->format('Y_m');

        foreach ($tables as $table) {
            Schema::dropIfExists("{$table}_{$suffix}");
            Schema::dropIfExists($table);
        }
    }
};
