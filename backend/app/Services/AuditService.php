<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * Wave 1 — Step 1.3: Cryptographic Audit Logging Service
 *
 * Centralized helper for emitting tamper-evident, append-only
 * audit log entries into the 4 partitioned streams.
 *
 * Cryptographic Chain Formula (Section 10.8.3):
 *
 *   For every row n:
 *     payload_hash_n = SHA-256(canonicalized_JSON(mutable_columns))
 *     chain_hash_n   = SHA-256(prev_chain_hash_{n-1}
 *                            ∥ payload_hash_n
 *                            ∥ event_time_n
 *                            ∥ actor_global_identity_id_n)
 *
 * Where:
 *   - ∥ = byte-string concatenation
 *   - canonicalized_JSON = JSON with alphabetically-sorted keys
 *   - Genesis hash = SHA-256('TRACE_ODD_AUDIT_GENESIS_v2.0')
 *
 * Append-Only Enforcement (10.8.4):
 *   Application role has INSERT, SELECT only.
 *   UPDATE, DELETE, TRUNCATE revoked at DB permission level.
 */
class AuditService
{
    private const GENESIS_SALT = 'TRACE_ODD_AUDIT_GENESIS_v2.0';

    private const STREAMS = [
        'security'    => 'audit_log_security',
        'financial'   => 'audit_log_financial',
        'operational' => 'audit_log_operational',
        'compliance'  => 'audit_log_compliance',
    ];

    private const EXCLUDED_FIELDS = [
        'id', 'event_time', 'created_at',
        'payload_hash', 'prev_chain_hash', 'chain_hash',
    ];

    /**
     * Emit a single tamper-evident audit log entry.
     *
     * @param string $stream One of: security, financial, operational, compliance
     * @param array  $data   Associative row data (excludes chain fields)
     * @return string The computed chain_hash for this entry
     */
    public function emit(string $stream, array $data): string
    {
        $table = $this->resolveTable($stream);

        $payloadHash   = $this->computePayloadHash($data);
        $prevChainHash = $this->getPreviousChainHash($table);
        $eventTime     = $data['event_time'] ?? now()->toIso8601String();
        $actorId       = (string) ($data['actor_global_identity_id'] ?? '00000000-0000-0000-0000-000000000000');
        $chainHash     = $this->computeChainHash($prevChainHash, $payloadHash, $eventTime, $actorId);

        $row = $data;
        $row['id']              = $data['id'] ?? (string) Str::uuid();
        $row['payload_hash']    = $payloadHash;
        $row['prev_chain_hash'] = $prevChainHash;
        $row['chain_hash']      = $chainHash;
        $row['event_time']      = $eventTime;
        $row['created_at']      = $data['created_at'] ?? now()->toIso8601String();

        DB::table($table)->insert($row);

        return $chainHash;
    }

    /**
     * Emit multiple entries in a single DB transaction.
     * Chain continuity is preserved across the batch.
     *
     * @param string $stream Audit stream
     * @param array  $batch  Array of associative row arrays
     * @return array Computed chain hashes in input order
     */
    public function emitBatch(string $stream, array $batch): array
    {
        $table  = $this->resolveTable($stream);
        $hashes = [];

        DB::transaction(function () use ($table, $batch, &$hashes) {
            $prevChainHash = $this->getPreviousChainHash($table);

            foreach ($batch as $data) {
                $payloadHash = $this->computePayloadHash($data);
                $eventTime   = $data['event_time'] ?? now()->toIso8601String();
                $actorId     = (string) ($data['actor_global_identity_id'] ?? '00000000-0000-0000-0000-000000000000');
                $chainHash   = $this->computeChainHash($prevChainHash, $payloadHash, $eventTime, $actorId);

                $row = $data;
                $row['id']              = $data['id'] ?? (string) Str::uuid();
                $row['payload_hash']    = $payloadHash;
                $row['prev_chain_hash'] = $prevChainHash;
                $row['chain_hash']      = $chainHash;
                $row['event_time']      = $eventTime;
                $row['created_at']      = $data['created_at'] ?? now()->toIso8601String();

                DB::table($table)->insert($row);
                $hashes[] = $chainHash;

                $prevChainHash = $chainHash;
            }
        });

        return $hashes;
    }

    /**
     * Full chain verification for a stream.
     *
     * Walks every row from genesis, recomputing chain_hash at each step.
     * Returns first broken row if any tampering detected.
     *
     * @param string $stream Audit stream name
     * @param int    $limit  Max rows (0 = no limit)
     * @param int    $offset Skip N rows
     * @return array [valid, total_rows, first_broken_row, details]
     */
    public function verifyChain(string $stream, int $limit = 0, int $offset = 0): array
    {
        $table = $this->resolveTable($stream);

        $query = DB::table($table)
            ->orderBy('event_time', 'asc')
            ->orderBy('id', 'asc')
            ->select(['id', 'prev_chain_hash', 'payload_hash', 'chain_hash', 'event_time', 'actor_global_identity_id']);

        if ($offset > 0) {
            $query->offset($offset);
        }
        if ($limit > 0) {
            $query->limit($limit);
        }

        $rows = $query->get();

        if ($rows->isEmpty()) {
            return ['valid' => true, 'total_rows' => 0, 'first_broken_row' => null, 'details' => null];
        }

        if ($offset === 0) {
            $expectedPrev = $this->genesisHash();
        } else {
            $prevRow = DB::table($table)
                ->orderBy('event_time', 'asc')
                ->orderBy('id', 'asc')
                ->offset($offset - 1)
                ->limit(1)
                ->select('chain_hash')
                ->first();
            $expectedPrev = $prevRow ? $prevRow->chain_hash : $this->genesisHash();
        }

        foreach ($rows as $i => $row) {
            if ($row->prev_chain_hash !== $expectedPrev) {
                return [
                    'valid'            => false,
                    'total_rows'       => $rows->count(),
                    'first_broken_row' => $row->id,
                    'details'          => [
                        'row_index'     => $offset + $i,
                        'expected_prev' => $expectedPrev,
                        'got_prev'      => $row->prev_chain_hash,
                        'failure_type'  => 'chain_break',
                    ],
                ];
            }

            $actorId  = (string) ($row->actor_global_identity_id ?? '00000000-0000-0000-0000-000000000000');
            $computed = $this->computeChainHash(
                $row->prev_chain_hash,
                $row->payload_hash,
                $row->event_time,
                $actorId
            );

            if (!hash_equals($computed, $row->chain_hash)) {
                return [
                    'valid'            => false,
                    'total_rows'       => $rows->count(),
                    'first_broken_row' => $row->id,
                    'details'          => [
                        'row_index'      => $offset + $i,
                        'expected_chain' => $computed,
                        'got_chain'      => $row->chain_hash,
                        'failure_type'   => 'hash_mismatch',
                    ],
                ];
            }

            $expectedPrev = $row->chain_hash;
        }

        return ['valid' => true, 'total_rows' => $rows->count(), 'first_broken_row' => null, 'details' => null];
    }

    /**
     * Export a monthly chain summary for external notarization.
     */
    public function monthlyChainSummary(string $stream, string $yearMonth): array
    {
        $table     = $this->resolveTable($stream);
        $suffix    = str_replace('-', '_', $yearMonth);
        $partition = "{$table}_{$suffix}";

        if (!Schema::hasTable($partition)) {
            return ['partition_table' => $partition, 'latest_chain_hash' => null, 'row_count' => 0, 'error' => 'Partition missing'];
        }

        $latest = DB::table($partition)
            ->orderBy('event_time', 'desc')
            ->orderBy('id', 'desc')
            ->select('chain_hash')
            ->first();

        $count = DB::table($partition)->count();

        return [
            'partition_table'   => $partition,
            'latest_chain_hash' => $latest ? $latest->chain_hash : $this->genesisHash(),
            'row_count'         => $count,
        ];
    }

    // ═══════════════════════════════════════════════════════════
    //  PURE CRYPTOGRAPHIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════

    /**
     * SHA-256(prev_chain_hash ∥ payload_hash ∥ event_time ∥ actor)
     */
    public function computeChainHash(
        string $prevChainHash,
        string $payloadHash,
        string $eventTime,
        string $actorId
    ): string {
        return hash('sha256', $prevChainHash . $payloadHash . $eventTime . $actorId);
    }

    /**
     * SHA-256 of canonicalized JSON payload (sorted keys, unescaped).
     */
    public function computePayloadHash(array $data): string
    {
        $canonical = [];
        foreach ($data as $k => $v) {
            if (!in_array($k, self::EXCLUDED_FIELDS, true)) {
                $canonical[$k] = $v;
            }
        }
        ksort($canonical);
        return hash('sha256', json_encode($canonical, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    }

    /**
     * Deterministic genesis hash for all audit chains.
     */
    public function genesisHash(): string
    {
        return hash('sha256', self::GENESIS_SALT);
    }

    // ═══════════════════════════════════════════════════════════
    //  PRIVATE
    // ═══════════════════════════════════════════════════════════

    private function resolveTable(string $stream): string
    {
        if (!isset(self::STREAMS[$stream])) {
            throw new \InvalidArgumentException(
                "Unknown audit stream '{$stream}'. Valid: " . implode(', ', array_keys(self::STREAMS))
            );
        }
        return self::STREAMS[$stream];
    }

    private function getPreviousChainHash(string $table): string
    {
        $row = DB::table($table)
            ->orderBy('event_time', 'desc')
            ->orderBy('id', 'desc')
            ->select('chain_hash')
            ->first();

        return $row ? $row->chain_hash : $this->genesisHash();
    }
}
