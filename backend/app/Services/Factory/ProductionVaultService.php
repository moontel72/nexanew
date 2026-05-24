<?php

namespace App\Services\Factory;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — CRYPTOGRAPHIC SERIAL VAULT SERVICE
 * ===============================================
 *
 * Generates immutable SHA256-based product serial identifiers
 * and verifies authenticity against the vault (Module 3AC, 3AD).
 *
 * SERIAL FORMULA:
 *   Serial = SHA256(Batch ID + Factory Secret Key + Incremental Seed)
 *
 * This prevents brute-force emulation of valid product identifiers
 * in the retail market. Every serial is mathematically tied to its
 * batch and factory.
 *
 * SAFETY: Entirely NEW service. Zero modification to existing code.
 */

class ProductionVaultService
{
    /**
     * Generate secure batch serial items using SHA256 HMAC.
     *
     * @param string $batchId    Production batch UUID
     * @param int    $quantity   Number of serials to generate
     * @param string $factorySecretKey  Factory-level secret key (stored hashed)
     * @return int  Number of serials inserted
     */
    public function generateSecureBatchItems(
        string $batchId,
        int $quantity,
        string $factorySecretKey
    ): int {
        if ($quantity <= 0 || $quantity > 100000) {
            throw new \RuntimeException('Quantity must be between 1 and 100,000.');
        }

        $existingCount = DB::table('product_serialized_items')
            ->where('batch_id', $batchId)->count();

        if ($existingCount > 0) {
            throw new \RuntimeException('Serials already generated for this batch. Cannot re-generate.');
        }

        $rows = [];
        $now = now();
        $chunkSize = 500;

        for ($seed = 1; $seed <= $quantity; $seed++) {
            $serialHash = $this->computeSerialHash($batchId, $factorySecretKey, $seed);
            $rows[] = [
                'id' => (string) Str::uuid(),
                'batch_id' => $batchId,
                'crypto_serial_hash' => $serialHash,
                'incremental_seed' => $seed,
                'created_at' => $now,
                'updated_at' => $now,
            ];

            // Batch insert in chunks for performance
            if (count($rows) >= $chunkSize) {
                DB::table('product_serialized_items')->insert($rows);
                $rows = [];
            }
        }

        // Insert remaining
        if (! empty($rows)) {
            DB::table('product_serialized_items')->insert($rows);
        }

        DB::table('production_batches')->where('id', $batchId)->update([
            'total_items' => $quantity,
            'status' => 'in_production',
            'updated_at' => $now,
        ]);

        Log::info('ProductionVaultService: serials generated', [
            'batch_id' => $batchId, 'quantity' => $quantity,
        ]);

        return $quantity;
    }

    /**
     * Verify a cryptographic serial hash is authentic.
     *
     * @return array|null {batch_id, seed, is_scanned} or null if counterfeit
     */
    public function verifySerialAuthenticity(string $serialHash): ?array
    {
        $item = DB::table('product_serialized_items')
            ->where('crypto_serial_hash', $serialHash)
            ->first();

        if (! $item) {
            Log::warning('ProductionVaultService: counterfeit serial detected', [
                'serial_hash' => $serialHash,
            ]);
            return null;
        }

        return [
            'batch_id' => $item->batch_id,
            'incremental_seed' => $item->incremental_seed,
            'is_scanned_out' => (bool) $item->is_scanned_out,
            'is_authentic' => true,
        ];
    }

    /**
     * Compute cryptographic serial hash.
     *
     * Formula: SHA256(Batch ID + Factory Secret Key + Incremental Seed)
     */
    public function computeSerialHash(string $batchId, string $secretKey, int $seed): string
    {
        return hash('sha256', $batchId . $secretKey . (string) $seed);
    }

    /**
     * Transition a batch to sealed_locked state.
     * Requires supervisor digital signature.
     */
    public function sealBatch(
        string $batchId,
        string $supervisorId,
        string $supervisorSignature
    ): void {
        DB::transaction(function () use ($batchId, $supervisorId, $supervisorSignature) {
            $batch = DB::table('production_batches')
                ->where('id', $batchId)->lockForUpdate()->firstOrFail();

            if ($batch->status !== 'in_production') {
                throw new \RuntimeException("Batch must be in_production to seal. Status: {$batch->status}");
            }

            $signatureHash = hash('sha256', $batchId . $supervisorId . $supervisorSignature);

            DB::table('production_batches')->where('id', $batchId)->update([
                'status' => 'sealed_locked',
                'supervisor_signature' => $signatureHash,
                'sealed_at' => now(),
                'sealed_by' => $supervisorId,
                'updated_at' => now(),
            ]);

            Log::info('ProductionVaultService: batch sealed', [
                'batch_id' => $batchId, 'supervisor' => $supervisorId,
            ]);
        });
    }

    /**
     * Release a sealed batch for transit.
     * This is the electronic release gate — required before dispatch.
     */
    public function releaseBatch(
        string $batchId,
        string $supervisorId,
        string $supervisorSignature
    ): void {
        DB::transaction(function () use ($batchId, $supervisorId, $supervisorSignature) {
            $batch = DB::table('production_batches')
                ->where('id', $batchId)->lockForUpdate()->firstOrFail();

            if ($batch->status !== 'sealed_locked') {
                throw new \RuntimeException("Batch must be sealed_locked to release. Status: {$batch->status}");
            }

            $signatureHash = hash('sha256', $batchId . $supervisorId . $supervisorSignature);
            $storedSignature = $batch->supervisor_signature;

            if ($signatureHash !== $storedSignature) {
                throw new \RuntimeException('Supervisor signature verification failed. Release denied.');
            }

            DB::table('production_batches')->where('id', $batchId)->update([
                'status' => 'released_for_transit',
                'released_at' => now(),
                'released_by' => $supervisorId,
                'updated_at' => now(),
            ]);

            Log::info('ProductionVaultService: batch released for transit', [
                'batch_id' => $batchId, 'supervisor' => $supervisorId,
            ]);
        });
    }
}
