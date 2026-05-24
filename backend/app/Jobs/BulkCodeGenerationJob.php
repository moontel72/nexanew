<?php

namespace App\Jobs;

use App\Models\CompanySubscription;
use App\Models\SubscriptionPlan;
use App\Services\Codes\CodeGenerator;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — BULK CODE GENERATION JOB
 * =====================================
 *
 * SAFETY RULES:
 *  - This is a NEW, ADDITIVE queued endpoint. It does NOT modify
 *    the existing synchronous generation in BundleCodesController,
 *    CartonCodesController, PacketCodesController, or UnitCodesController.
 *  - Internally reuses the existing CodeGenerator service to avoid
 *    duplicating generation logic.
 *  - Processes codes in configurable chunks (default 500 per batch)
 *    to prevent memory exhaustion on large requests.
 *  - Reports progress via cache so the frontend can poll.
 *  - Dispatched from BulkCodeGenerationController (new, separate route).
 *
 * TARGET MODULES: 3B, 3F, 3G, 3V
 * QUEUE CONNECTION: redis (high priority)
 */

class BulkCodeGenerationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of seconds the job can run before timing out.
     * Large generations (1M+ codes) need generous timeout.
     */
    public int $timeout = 600;

    /**
     * The number of times the job may be attempted.
     */
    public int $tries = 3;

    /**
     * Maximum exceptions before marking job as failed.
     */
    public int $maxExceptions = 3;

    // ─── Payload ──────────────────────────────────────────

    private string $companyId;
    private string $planId;
    private string $codeType;
    private int $totalCount;
    private int $chunkSize;
    private array $options;
    private string $jobId;

    /**
     * @param string $codeType   One of: 'bundle', 'carton', 'packet', 'unit', 'hierarchical'
     * @param int    $totalCount Total number of codes to generate (up to 1,000,000)
     * @param array  $options    Generation options:
     *                           - prefix: string (code prefix, default: first letter of type)
     *                           - batch_id: string (custom batch identifier)
     *                           - product_id: string (required for 'unit' type)
     *                           - manufacturing_date: string (ISO date)
     *                           - expiry_date: string (ISO date)
     *                           - warranty_months: int
     *                           - chunk_size: int (override default chunk size, 100–5000)
     *                           - metadata: array (arbitrary key-value)
     */
    public function __construct(
        string $companyId,
        string $planId,
        string $codeType,
        int $totalCount,
        array $options = []
    ) {
        $this->companyId = $companyId;
        $this->planId = $planId;
        $this->codeType = $codeType;
        $this->totalCount = $totalCount;
        $this->chunkSize = min(5000, max(100, (int) ($options['chunk_size'] ?? 500)));
        $this->options = $options;
        $this->jobId = 'bulk-gen-' . Str::uuid()->toString();

        // Route to appropriate queue based on priority
        $this->queue = 'high';
        $this->connection = 'redis';
    }

    /**
     * Execute the job.
     */
    public function handle(CodeGenerator $generator): void
    {
        $startTime = microtime(true);

        Log::info('BulkCodeGenerationJob: started', [
            'job_id' => $this->jobId,
            'company_id' => $this->companyId,
            'code_type' => $this->codeType,
            'total_count' => $this->totalCount,
            'chunk_size' => $this->chunkSize,
        ]);

        // ─── Update progress: 0 % ──────────────────────
        $this->updateProgress(0, 'initializing');

        // ─── Validate ──────────────────────────────────
        $allowedTypes = ['bundle', 'carton', 'packet', 'unit', 'hierarchical'];

        if (! in_array($this->codeType, $allowedTypes, true)) {
            $this->failProgress("Unsupported code type: {$this->codeType}");
            return;
        }

        if ($this->codeType === 'unit' && empty($this->options['product_id'])) {
            $this->failProgress("product_id is required for unit code generation");
            return;
        }

        // ─── Verify subscription (non-blocking — just log) ──
        $sub = CompanySubscription::query()
            ->where('company_id', $this->companyId)
            ->where('status', 'active')
            ->first();

        if (! $sub) {
            Log::warning('BulkCodeGenerationJob: no active subscription — proceeding anyway', [
                'company_id' => $this->companyId,
            ]);
        }

        // ─── Generate in chunks ────────────────────────
        $totalGenerated = 0;
        $chunks = (int) ceil($this->totalCount / $this->chunkSize);
        $errors = [];

        for ($chunk = 0; $chunk < $chunks; $chunk++) {
            $remaining = $this->totalCount - $totalGenerated;
            $thisChunkSize = min($this->chunkSize, $remaining);

            if ($thisChunkSize <= 0) {
                break;
            }

            try {
                $baseOverrides = array_filter([
                    'batch_id' => $this->options['batch_id'] ?? null,
                    'store_keeper_prefix' => $this->options['prefix'] ?? null,
                ]);

                $rows = $generator->generateBase(
                    $this->companyId,
                    $this->planId,
                    $this->codeType,
                    $thisChunkSize,
                    $baseOverrides
                );

                // Post-process for unit codes: link to product
                if ($this->codeType === 'unit' && ! empty($this->options['product_id'])) {
                    $now = now();
                    $updates = [];
                    foreach ($rows as $r) {
                        $updates[] = [
                            'id' => $r['id'],
                            'product_id' => $this->options['product_id'],
                            'product_batch_number' => $this->options['batch_id'] ?? null,
                            'manufacturing_date' => $this->options['manufacturing_date'] ?? null,
                            'expiry_date' => $this->options['expiry_date'] ?? null,
                            'warranty_months' => $this->options['warranty_months'] ?? null,
                            'status' => 'linked',
                            'linked_at' => $now,
                            'updated_at' => $now,
                        ];
                    }

                    // Batch update for performance
                    foreach (array_chunk($updates, 500) as $updateChunk) {
                        DB::table('base_codes')
                            ->whereIn('id', array_column($updateChunk, 'id'))
                            ->update([
                                'product_id' => DB::raw("CASE " . implode(' ', array_map(
                                    fn($u) => "WHEN id = '{$u['id']}' THEN '{$u['product_id']}'",
                                    $updateChunk
                                )) . " ELSE product_id END"),
                            ]);
                    }
                }

                $totalGenerated += count($rows);

                // ─── Update progress ──────────────────
                $pct = $this->totalCount > 0
                    ? round(($totalGenerated / $this->totalCount) * 100, 1)
                    : 100;

                $this->updateProgress($pct, 'generating', [
                    'chunk' => $chunk + 1,
                    'total_chunks' => $chunks,
                    'generated' => $totalGenerated,
                ]);

            } catch (\Throwable $e) {
                Log::error('BulkCodeGenerationJob: chunk failed', [
                    'job_id' => $this->jobId,
                    'chunk' => $chunk,
                    'error' => $e->getMessage(),
                ]);

                $errors[] = "Chunk {$chunk}: {$e->getMessage()}";

                // If first chunk fails entirely, fail the job
                if ($chunk === 0 && $totalGenerated === 0) {
                    $this->failProgress("Generation failed on first chunk: {$e->getMessage()}");
                    return;
                }
            }

            // Release memory
            unset($rows);

            // Brief pause between chunks to avoid database overload
            if ($chunk < $chunks - 1) {
                usleep(100000); // 100 ms
            }
        }

        // ─── Finalize ──────────────────────────────────
        $elapsed = round(microtime(true) - $startTime, 2);

        if (count($errors) > 0) {
            $this->updateProgress(100, 'completed_with_errors', [
                'generated' => $totalGenerated,
                'requested' => $this->totalCount,
                'errors' => $errors,
                'elapsed_seconds' => $elapsed,
            ]);
        } else {
            $this->updateProgress(100, 'completed', [
                'generated' => $totalGenerated,
                'requested' => $this->totalCount,
                'elapsed_seconds' => $elapsed,
            ]);
        }

        Log::info('BulkCodeGenerationJob: completed', [
            'job_id' => $this->jobId,
            'generated' => $totalGenerated,
            'elapsed_seconds' => $elapsed,
            'errors' => count($errors),
        ]);
    }

    /**
     * Handle a job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('BulkCodeGenerationJob: FAILED', [
            'job_id' => $this->jobId,
            'company_id' => $this->companyId,
            'code_type' => $this->codeType,
            'error' => $exception->getMessage(),
        ]);

        $this->updateProgress(0, 'failed', [
            'error' => $exception->getMessage(),
        ]);
    }

    /**
     * Unique job identifier for progress tracking.
     */
    public function getJobId(): string
    {
        return $this->jobId;
    }

    // ─── Private Helpers ────────────────────────────────

    private function updateProgress(float $percentage, string $status, array $meta = []): void
    {
        $payload = array_merge($meta, [
            'job_id' => $this->jobId,
            'company_id' => $this->companyId,
            'code_type' => $this->codeType,
            'total_count' => $this->totalCount,
            'percentage' => $percentage,
            'status' => $status,
            'updated_at' => now()->toIso8601String(),
        ]);

        Cache::put(
            "bulk_gen:progress:{$this->jobId}",
            $payload,
            3600 // Keep progress for 1 hour after completion
        );
    }

    private function failProgress(string $message): void
    {
        Log::error("BulkCodeGenerationJob: {$message}", [
            'job_id' => $this->jobId,
        ]);

        $this->updateProgress(0, 'failed', [
            'error' => $message,
        ]);
    }
}
