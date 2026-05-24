<?php

namespace App\Jobs;

use App\Services\Notification\NotificationBlastService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — NOTIFICATION BLAST JOB
 * ====================================
 *
 * Async queue job for mass multi-channel notification dispatching.
 * Handles batching, rate-limiting, and dead-letter processing.
 *
 * DISPATCH MODES:
 *   1. Single user:    NotificationBlastJob::dispatch($userId, $type, $data, $channels)
 *   2. Multiple users: NotificationBlastJob::dispatch($userIds, $type, $data, $channels)
 *      (auto-detected: array of IDs = blast mode)
 *   3. Dead-letter:    NotificationBlastJob::dispatch() — no args = process DLQ
 *
 * QUEUE: notifications (Redis)
 * TIMEOUT: 300 seconds (for large blasts)
 * RETRIES: 2
 *
 * TARGET MODULES: 1F, 12K
 *
 * SAFETY:
 *   - Entirely NEW job. Uses only NotificationBlastService + notification models.
 *   - Zero interaction with existing code.
 */

class NotificationBlastJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $timeout = 300;
    public int $tries = 2;
    public int $maxExceptions = 2;

    private ?array $userIds;
    private ?string $type;
    private array $data;
    private ?array $channels;
    private ?string $companyId;
    private bool $isDeadLetter;

    /**
     * @param array|string|null $userIds  Single user ID, array of IDs, or null (dead-letter)
     * @param string|null       $type     Notification type
     * @param array             $data     Template variables
     * @param array|null        $channels ['email','push','sms','websocket'] or null for all
     * @param string|null       $companyId
     */
    public function __construct(
        array|string|null $userIds = null,
        ?string $type = null,
        array $data = [],
        ?array $channels = null,
        ?string $companyId = null
    ) {
        $this->isDeadLetter = ($userIds === null && $type === null);

        if (! $this->isDeadLetter) {
            $this->userIds = is_array($userIds) ? $userIds : [$userIds];
            $this->type = $type;
            $this->data = $data;
            $this->channels = $channels;
            $this->companyId = $companyId;
        }

        $this->queue = 'notifications';
        $this->connection = 'redis';
    }

    public function handle(NotificationBlastService $service): void
    {
        if ($this->isDeadLetter) {
            Log::info('NotificationBlastJob: processing dead-letter queue');
            $retried = $service->processDeadLetterQueue();
            Log::info('NotificationBlastJob: dead-letter complete', ['retried' => $retried]);
            return;
        }

        $count = count($this->userIds);

        Log::info('NotificationBlastJob: dispatching', [
            'user_count' => $count,
            'type' => $this->type,
            'channels' => $this->channels ?? ['all'],
        ]);

        $result = $service->sendToUsers(
            userIds: $this->userIds,
            type: $this->type,
            data: $this->data,
            channels: $this->channels,
            companyId: $this->companyId,
        );

        Log::info('NotificationBlastJob: completed', array_merge($result, [
            'type' => $this->type,
        ]));
    }

    public function failed(\Throwable $exception): void
    {
        Log::error('NotificationBlastJob: FAILED', [
            'type' => $this->type,
            'user_count' => $this->userIds ? count($this->userIds) : 0,
            'error' => $exception->getMessage(),
        ]);
    }
}
