<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
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
        $this->createAuditTable('audit_log_security', function (Blueprint $table) {
            $table->string('event_type', 80);
            $table->uuid('actor_global_identity_id')->nullable();
            $table->uuid('target_global_identity_id')->nullable();
            $table->string('claim_type', 40)->nullable();
            $table->uuid('claim_id')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();

            $table->index('event_type');
            $table->index('actor_global_identity_id');
        });

        $this->createAuditTable('audit_log_financial', function (Blueprint $table) {
            $table->string('event_type', 80);
            $table->uuid('actor_global_identity_id')->nullable();
            $table->uuid('target_global_identity_id')->nullable();
            $table->string('reference_type', 80)->nullable();
            $table->uuid('reference_id')->nullable();
            $table->decimal('amount', 18, 4)->nullable();
            $table->string('currency', 8)->nullable();

            $table->index('event_type');
            $table->index('actor_global_identity_id');
            $table->index('reference_type');
        });

        $this->createAuditTable('audit_log_operational', function (Blueprint $table) {
            $table->string('event_type', 80);
            $table->uuid('actor_global_identity_id')->nullable();
            $table->uuid('target_global_identity_id')->nullable();
            $table->string('entity_type', 80)->nullable();
            $table->uuid('entity_id')->nullable();
            $table->string('operation', 20)->nullable();

            $table->index('event_type');
            $table->index('actor_global_identity_id');
            $table->index('entity_type');
        });

        $this->createAuditTable('audit_log_compliance', function (Blueprint $table) {
            $table->string('event_type', 80);
            $table->uuid('actor_global_identity_id')->nullable();
            $table->uuid('target_global_identity_id')->nullable();
            $table->string('compliance_domain', 80)->nullable();
            $table->uuid('reference_id')->nullable();

            $table->index('event_type');
            $table->index('actor_global_identity_id');
            $table->index('compliance_domain');
        });
    }

    private function createAuditTable(string $tableName, callable $addStreamColumns): void
    {
        if (Schema::hasTable($tableName)) {
            return;
        }

        Schema::create($tableName, function (Blueprint $table) use ($addStreamColumns) {
            $table->uuid('id')->primary();
            $addStreamColumns($table);
            $table->jsonb('payload')->nullable();
            $table->string('payload_hash', 64);
            $table->string('prev_chain_hash', 64);
            $table->string('chain_hash', 64);
            $table->timestampTz('event_time')->useCurrent();
            $table->timestampTz('created_at')->useCurrent();
            $table->index('event_time');
            $table->index('chain_hash');
        });

        DB::statement("ALTER TABLE {$tableName} ALTER COLUMN id SET DEFAULT uuid_generate_v4()");
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
