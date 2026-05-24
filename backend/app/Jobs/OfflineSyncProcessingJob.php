<?php

namespace App\Jobs;

use App\Services\Sync\OfflineSyncService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — OFFLINE SYNC PROCESSING JOB
 * ========================================
 *
 * Async background job that processes queued offline mutations
 * from Store Keeper (Module 5B) and Factory Driver (Module 4Z) apps.
 *
 * DISPATCH MODES:
 *   1. Per-user sync:   OfflineSyncProcessingJob::dispatch(userId: $userId)
 *   2. Bulk processing:  OfflineSyncProcessingJob::dispatch()
 *      (processes all pending payloads across all users)
 *
 * SCHEDULE (app/Console/Kernel.php):
 *   $schedule->job(new OfflineSyncProcessingJob())->everyFiveMinutes();
 *
 * QUEUE: sync (Redis)
 * TIMEOUT: 180 seconds
 * RETRIES: 2
 *
 * TARGET MODULES: 4Z, 5B, 5K, 5S, 12F
 *
 * SAFETY:
 *   - Entirely NEW job. Uses only OfflineSyncService + sync models.
 *   - Zero interaction with existing code.
 *   - Idempotent — safe to re-run.
 */

class OfflineSyncProcessingJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $timeout = 180;
    public int $tries = 2;
    public int $maxExceptions = 3;

    private ?string $userId;

    public function __construct(?string $userId = null)
    {
        $this->userId = $userId;
        $this->queue = 'sync';
        $this->connection = 'redis';
    }

    public function handle(OfflineSyncService $service): void
    {
        if ($this->userId) {
            Log::info('OfflineSyncProcessingJob: per-user sync', ['user_id' => $this->userId]);
            $result = $service->processUserPayloads($this->userId);
        } else {
            Log::info('OfflineSyncProcessingJob: bulk sync started');
            $result = $service->processAllPending();
        }

        Log::info('OfflineSyncProcessingJob: completed', $result);
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('OfflineSyncProcessingJob: FAILED', [
            'user_id' => $this->userId,
            'error' => $exception->getMessage(),
        ]);
    }
}
