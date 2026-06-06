<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Wave 4 — Evolve transport_bus_layouts (additive migration).
     *
     * The Wave 4 migration 2026_06_03_001000 was skipped because the
     * table already existed (created by 2026_05_22_000011). This
     * migration adds the Wave 4 columns idempotently so existing
     * production rows are preserved.
     *
     * Section 10.6: Decentralized Seat Layout Sovereignty.
     */
    public function up(): void
    {
        // ═══════════════════════════════════════════════════════
        // Part A: transport_bus_layouts — add Wave 4 columns
        // ═══════════════════════════════════════════════════════
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            // Identity & carrier linkage
            if (! Schema::hasColumn('transport_bus_layouts', 'owner_identity_id')) {
                $table->uuid('owner_identity_id')->nullable()->after('tenant_account_id');
            }
            if (! Schema::hasColumn('transport_bus_layouts', 'carrier_company_id')) {
                $table->uuid('carrier_company_id')->nullable()->after('owner_identity_id');
            }

            // Classification
            if (! Schema::hasColumn('transport_bus_layouts', 'vehicle_class')) {
                $table->string('vehicle_class', 30)->nullable()->after('carrier_company_id');
            }
            if (! Schema::hasColumn('transport_bus_layouts', 'display_name')) {
                $table->string('display_name', 160)->nullable()->after('vehicle_class');
            }

            // Sovereignty & versioning
            if (! Schema::hasColumn('transport_bus_layouts', 'is_locked_sovereign')) {
                $table->boolean('is_locked_sovereign')->default(true)->after('display_name');
            }
            if (! Schema::hasColumn('transport_bus_layouts', 'version_number')) {
                $table->integer('version_number')->default(1)->after('is_locked_sovereign');
            }

            // NOTE: use 'layout_status' NOT 'status' to avoid conflict
            // with existing columns or reserved words.
            if (! Schema::hasColumn('transport_bus_layouts', 'layout_status')) {
                $table->string('layout_status', 20)->default('draft')->after('version_number');
            }

            // Denormalized snapshot
            if (! Schema::hasColumn('transport_bus_layouts', 'current_snapshot')) {
                $table->jsonb('current_snapshot')->nullable()->after('layout_status');
            }

            // Edit lock (5-min lease)
            if (! Schema::hasColumn('transport_bus_layouts', 'edit_lock_held_by')) {
                $table->uuid('edit_lock_held_by')->nullable()->after('current_snapshot');
            }
            if (! Schema::hasColumn('transport_bus_layouts', 'edit_lock_expires_at')) {
                $table->timestampTz('edit_lock_expires_at')->nullable()->after('edit_lock_held_by');
            }

            // Multi-deck support (sleeper coaches)
            if (! Schema::hasColumn('transport_bus_layouts', 'deck_level')) {
                $table->smallInteger('deck_level')->default(0)->after('edit_lock_expires_at');
            }
            if (! Schema::hasColumn('transport_bus_layouts', 'parent_layout_id')) {
                $table->uuid('parent_layout_id')->nullable()->after('deck_level');
            }
        });

        // ── Foreign key: owner_identity_id → global_identities ──
        $this->addForeignIfNotExists(
            'transport_bus_layouts',
            'transport_bus_layouts_owner_identity_id_foreign',
            'owner_identity_id',
            'global_identities',
            'id',
            'restrict'
        );

        // ── Indexes ────────────────────────────────────────────
        $this->addIndexIfNotExists('transport_bus_layouts', 'idx_bus_layouts_owner_identity_id', ['owner_identity_id']);
        $this->addIndexIfNotExists('transport_bus_layouts', 'idx_bus_layouts_vehicle_class', ['vehicle_class']);
        $this->addIndexIfNotExists('transport_bus_layouts', 'idx_bus_layouts_layout_status', ['layout_status']);
        $this->addIndexIfNotExists('transport_bus_layouts', 'idx_bus_layouts_carrier_company_id', ['carrier_company_id']);

        // ═══════════════════════════════════════════════════════
        // Part B: transport_bus_layout_revisions — add columns
        // ═══════════════════════════════════════════════════════
        // The original 2026_06_03_001100 migration may have already
        // created published_by and change_description. We add them
        // only if missing, plus the new deck_level column.
        if (Schema::hasTable('transport_bus_layout_revisions')) {
            Schema::table('transport_bus_layout_revisions', function (Blueprint $table) {
                if (! Schema::hasColumn('transport_bus_layout_revisions', 'published_by')) {
                    $table->uuid('published_by')->nullable()->after('full_snapshot');
                }
                if (! Schema::hasColumn('transport_bus_layout_revisions', 'change_description')) {
                    $table->text('change_description')->nullable()->after('published_by');
                }
                if (! Schema::hasColumn('transport_bus_layout_revisions', 'deck_level')) {
                    $table->smallInteger('deck_level')->default(0)->after('change_description');
                }
            });
        }
    }

    public function down(): void
    {
        // ═══════════════════════════════════════════════════════
        // Part A: Remove Wave 4 columns from layout table
        // ═══════════════════════════════════════════════════════
        Schema::table('transport_bus_layouts', function (Blueprint $table) {
            $columns = [
                'parent_layout_id',
                'deck_level',
                'edit_lock_expires_at',
                'edit_lock_held_by',
                'current_snapshot',
                'layout_status',
                'version_number',
                'is_locked_sovereign',
                'display_name',
                'vehicle_class',
                'carrier_company_id',
                'owner_identity_id',
            ];

            foreach ($columns as $col) {
                if (Schema::hasColumn('transport_bus_layouts', $col)) {
                    $table->dropColumn($col);
                }
            }
        });

        // ── Drop indexes ────────────────────────────────────
        $indexes = [
            'idx_bus_layouts_owner_identity_id',
            'idx_bus_layouts_vehicle_class',
            'idx_bus_layouts_layout_status',
            'idx_bus_layouts_carrier_company_id',
        ];
        foreach ($indexes as $idx) {
            $this->dropIndexIfExists('transport_bus_layouts', $idx);
        }

        // ═══════════════════════════════════════════════════════
        // Part B: Remove added columns from revisions table
        // ═══════════════════════════════════════════════════════
        if (Schema::hasTable('transport_bus_layout_revisions')) {
            Schema::table('transport_bus_layout_revisions', function (Blueprint $table) {
                if (Schema::hasColumn('transport_bus_layout_revisions', 'deck_level')) {
                    $table->dropColumn('deck_level');
                }
                // published_by and change_description were part of
                // the original Wave 4 migration; we keep them.
            });
        }
    }

    // ─── Helpers ──────────────────────────────────────────────

    private function addForeignIfNotExists(
        string $table,
        string $constraintName,
        string $column,
        string $referencedTable,
        string $referencedColumn,
        string $onDelete
    ): void {
        $exists = DB::selectOne(
            "SELECT 1 FROM information_schema.table_constraints
             WHERE constraint_name = ? AND table_name = ?",
            [$constraintName, $table]
        );

        if (! $exists) {
            try {
                DB::statement(
                    "ALTER TABLE {$table} ADD CONSTRAINT {$constraintName}
                     FOREIGN KEY ({$column}) REFERENCES {$referencedTable} ({$referencedColumn})
                     ON DELETE {$onDelete}"
                );
            } catch (\Throwable $e) {
                // If the referenced table doesn't exist yet or has
                // inconsistent data, the FK creation will fail. Log
                // and continue — the column still exists as nullable.
                report($e);
            }
        }
    }

    private function addIndexIfNotExists(string $table, string $indexName, array $columns): void
    {
        $exists = DB::selectOne(
            "SELECT 1 FROM pg_indexes WHERE indexname = ?",
            [$indexName]
        );

        if (! $exists) {
            $colList = implode(', ', $columns);
            DB::statement("CREATE INDEX {$indexName} ON {$table} ({$colList})");
        }
    }

    private function dropIndexIfExists(string $table, string $indexName): void
    {
        $exists = DB::selectOne(
            "SELECT 1 FROM pg_indexes WHERE indexname = ?",
            [$indexName]
        );

        if ($exists) {
            DB::statement("DROP INDEX {$indexName}");
        }
    }
};
