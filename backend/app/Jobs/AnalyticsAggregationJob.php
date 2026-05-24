<?php

namespace App\Jobs;

use App\Models\Analytics\AnalyticsSnapshot;
use App\Services\Analytics\AnalyticsService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — ANALYTICS AGGREGATION JOB
 * =======================================
 *
 * Scheduled background job that collects metrics from all
 * production modules and stores time-series snapshots.
 *
 * SCHEDULE (app/Console/Kernel.php):
 *   $schedule->job(new AnalyticsAggregationJob(AnalyticsSnapshot::TYPE_REALTIME))->everyMinute();
 *   $schedule->job(new AnalyticsAggregationJob(AnalyticsSnapshot::TYPE_HOURLY))->hourly();
 *   $schedule->job(new AnalyticsAggregationJob(AnalyticsSnapshot::TYPE_DAILY))->dailyAt('00:05');
 *
 * QUEUE: analytics (Redis)
 * TIMEOUT: 60 seconds
 * RETRIES: 1
 *
 * TARGET MODULE: 1D
 *
 * SAFETY:
 *   - READ-ONLY on production tables.
 *   - Writes only to analytics_snapshots + Redis cache.
 *   - Entirely NEW job. Zero interaction with existing code.
 */

class AnalyticsAggregationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $timeout = 60;
    public int $tries = 1;

    private string $snapshotType;

    public function __construct(string $snapshotType = AnalyticsSnapshot::TYPE_HOURLY)
    {
        $this->snapshotType = $snapshotType;
        $this->queue = 'analytics';
        $this->connection = 'redis';
    }

    public function handle(AnalyticsService $service): void
    {
        Log::info('AnalyticsAggregationJob: started', ['type' => $this->snapshotType]);

        $count = $service->collectAll($this->snapshotType);

        Log::info('AnalyticsAggregationJob: completed', [
            'type' => $this->snapshotType,
            'snapshots_created' => $count,
        ]);
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('AnalyticsAggregationJob: FAILED', [
            'type' => $this->snapshotType,
            'error' => $exception->getMessage(),
        ]);
    }
}
