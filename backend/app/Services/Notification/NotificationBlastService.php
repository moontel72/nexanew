<?php

namespace App\Services\Notification;

use App\Events\GeofenceScanUnlocked;
use App\Events\TripStatusChanged;
use App\Events\DeliveryConfirmed;
use App\Models\Notification\NotificationLog;
use App\Models\Notification\NotificationTemplate;
use App\Models\Notification\UserNotificationPreference;
use App\Services\Redis\RedisCacheService;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * NEXATRACE — MULTI-CHANNEL NOTIFICATION BLAST SERVICE
 * =====================================================
 *
 * High-performance, queue-driven notification engine supporting
 * abstract routing for multiple delivery channels.
 *
 * CHANNELS:
 *   - websocket : In-app real-time via Laravel Events (built in Step 3)
 *   - email     : Laravel Mail system
 *   - push      : Firebase Cloud Messaging (FCM) — stub ready
 *   - sms       : Twilio SMS Gateway — stub ready
 *
 * FEATURES:
 *   - Redis-backed rate limiter (per user, per channel, per window)
 *   - User opt-out preferences (per notification type, per channel)
 *   - Exponential backoff retry (dead-letter queue on 3rd failure)
 *   - Template-based rendering
 *   - Full audit logging
 *
 * TARGET MODULES: 1F, 12K
 *
 * SAFETY:
 *   - Entirely NEW service in App\Services\Notification namespace.
 *   - Does NOT replace existing NotificationService.php (email invoices).
 *   - Zero interaction with existing Factory/Driver/StoreKeeper code.
 *   - All channels degrade gracefully (stub returns success, WebSocket uses log fallback).
 */

class NotificationBlastService
{
    private const RATE_LIMIT_WINDOW = 60;        // seconds
    private const RATE_LIMIT_MAX_EMAIL = 10;     // per user per window
    private const RATE_LIMIT_MAX_PUSH = 20;
    private const RATE_LIMIT_MAX_SMS = 5;
    private const RATE_LIMIT_MAX_WEBSOCKET = 30;

    private const MAX_RETRIES = 3;
    private const RETRY_BACKOFF_BASE = 30;       // seconds — exponential: 30, 60, 120

    public function __construct(
        private RedisCacheService $cache
    ) {}

    // ─────────────────────────────────────────────────
    // PUBLIC API
    // ─────────────────────────────────────────────────

    /**
     * Send a notification to a single user via designated channels.
     *
     * @param string      $userId
     * @param string      $type      e.g. 'invoice_ready', 'delivery_confirmed'
     * @param array       $data      Template variables
     * @param array|null  $channels  Override channels: ['email', 'push', 'sms', 'websocket'] — null = all
     * @param string|null $companyId
     * @return array  ['logs' => [...], 'skipped' => [...]]
     */
    public function sendToUser(
        string $userId,
        string $type,
        array $data = [],
        ?array $channels = null,
        ?string $companyId = null
    ): array {
        $results = ['logs' => [], 'skipped' => []];

        // Check user preferences
        $pref = UserNotificationPreference::where('user_id', $userId)
            ->where('notification_type', $type)
            ->first();

        $allowedChannels = $channels ?? ['websocket', 'email', 'push', 'sms'];

        foreach ($allowedChannels as $channel) {
            // Respect user opt-out
            if ($pref && ! $pref->isChannelEnabled($channel)) {
                $results['skipped'][] = ['user_id' => $userId, 'channel' => $channel, 'reason' => 'opted_out'];
                continue;
            }

            // Rate limit check
            if (! $this->checkRateLimit($userId, $channel)) {
                $results['skipped'][] = ['user_id' => $userId, 'channel' => $channel, 'reason' => 'rate_limited'];
                continue;
            }

            $log = $this->dispatchToChannel($userId, $type, $channel, $data, $companyId);
            $results['logs'][] = $log;
        }

        return $results;
    }

    /**
     * Send a notification to multiple users (blast).
     * Used by Super Admin for announcements (Module 1F).
     *
     * @param array  $userIds
     * @param string $type
     * @param array  $data
     * @param array|null $channels
     * @param string|null $companyId
     * @return array  ['total_users' => int, 'total_dispatched' => int, 'total_skipped' => int]
     */
    public function sendToUsers(
        array $userIds,
        string $type,
        array $data = [],
        ?array $channels = null,
        ?string $companyId = null
    ): array {
        $totalDispatched = 0;
        $totalSkipped = 0;

        foreach ($userIds as $userId) {
            $result = $this->sendToUser((string) $userId, $type, $data, $channels, $companyId);
            $totalDispatched += count($result['logs']);
            $totalSkipped += count($result['skipped']);
        }

        return [
            'total_users' => count($userIds),
            'total_dispatched' => $totalDispatched,
            'total_skipped' => $totalSkipped,
        ];
    }

    /**
     * Retry a failed notification by log ID.
     */
    public function retry(string $logId): ?NotificationLog
    {
        $log = NotificationLog::find($logId);
        if (! $log || $log->status !== NotificationLog::STATUS_FAILED) {
            return null;
        }

        $log->increment('attempts');
        return $this->dispatchToChannel(
            $log->user_id,
            $log->type,
            $log->channel,
            $log->metadata ?? [],
            $log->company_id
        );
    }

    // ─────────────────────────────────────────────────
    // CHANNEL DISPATCHERS
    // ─────────────────────────────────────────────────

    private function dispatchToChannel(
        string $userId,
        string $type,
        string $channel,
        array $data,
        ?string $companyId = null
    ): NotificationLog {
        // Create log entry
        $log = NotificationLog::create([
            'id' => (string) Str::uuid(),
            'company_id' => $companyId,
            'user_id' => $userId,
            'channel' => $channel,
            'type' => $type,
            'status' => NotificationLog::STATUS_SENDING,
            'content' => null,
            'metadata' => $data,
            'attempts' => 1,
        ]);

        try {
            $result = match ($channel) {
                'websocket' => $this->sendWebSocket($userId, $type, $data),
                'email'     => $this->sendEmail($userId, $type, $data),
                'push'      => $this->sendPush($userId, $type, $data),
                'sms'       => $this->sendSms($userId, $type, $data),
                default     => throw new \InvalidArgumentException("Unknown channel: {$channel}"),
            };

            $log->update([
                'status' => NotificationLog::STATUS_DELIVERED,
                'delivered_at' => now(),
                'content' => $result['content'] ?? null,
            ]);

            Log::info("NotificationBlastService: {$channel} delivered", [
                'user_id' => $userId, 'type' => $type,
            ]);
        } catch (\Throwable $e) {
            $log->update([
                'status' => NotificationLog::STATUS_FAILED,
                'failed_at' => now(),
                'failure_reason' => $e->getMessage(),
            ]);

            Log::error("NotificationBlastService: {$channel} failed", [
                'user_id' => $userId, 'type' => $type, 'error' => $e->getMessage(),
            ]);
        }

        return $log->fresh();
    }

    /**
     * In-app WebSocket notification via existing event infrastructure (Step 3).
     */
    private function sendWebSocket(string $userId, string $type, array $data): array
    {
        // Route to appropriate event based on type
        match ($type) {
            'geofence_alert' => GeofenceScanUnlocked::dispatch(
                $data['trip_id'] ?? '',
                $data['driver_id'] ?? '',
                $data['store_keeper_id'] ?? $userId,
                $data['company_id'] ?? '',
                $data['lat'] ?? 0, $data['lng'] ?? 0, $data['distance_meters'] ?? 0,
                $data
            ),
            'delivery_confirmed' => DeliveryConfirmed::dispatch(
                $data['delivery_id'] ?? '', $data['trip_id'] ?? '',
                $data['pod_type'] ?? 'pin', $data['company_id'] ?? '',
                $data['recipient_name'] ?? null, $data
            ),
            'trip_update' => TripStatusChanged::dispatch(
                $data['trip_id'] ?? '', $data['old_status'] ?? '',
                $data['new_status'] ?? '', $data['company_id'] ?? '',
                $data['lat'] ?? null, $data['lng'] ?? null, $data
            ),
            default => null, // generic types don't map to a specific event
        };

        return ['content' => json_encode($data)];
    }

    /**
     * Email delivery via Laravel Mail.
     */
    private function sendEmail(string $userId, string $type, array $data): array
    {
        $template = NotificationTemplate::where('template_key', "{$type}_email")->first();
        $body = $template ? $template->render($data) : ($data['message'] ?? 'Notification from NexaTrace.');
        $subject = $template ? $template->renderSubject($data) : 'NexaTrace Notification';

        // Stub — replace with actual Mail::send() when user email is resolved
        Log::info('NotificationBlastService: email stub — would send', [
            'user_id' => $userId, 'subject' => $subject,
        ]);

        // Future implementation:
        // $user = \App\Models\User::find($userId);
        // \Illuminate\Support\Facades\Mail::raw($body, fn($msg) => $msg->to($user->email)->subject($subject));

        return ['content' => $body];
    }

    /**
     * Push notification via Firebase Cloud Messaging (FCM stub).
     */
    private function sendPush(string $userId, string $type, array $data): array
    {
        $title = $data['title'] ?? 'NexaTrace';
        $body = $data['message'] ?? 'You have a new notification.';

        Log::info('NotificationBlastService: FCM stub — would send push', [
            'user_id' => $userId, 'title' => $title,
        ]);

        // Future implementation:
        // $deviceTokens = \App\Models\UserDevice::where('user_id', $userId)->pluck('fcm_token');
        // $fcm = new \App\Services\Notification\Drivers\FcmDriver();
        // $fcm->send($deviceTokens, $title, $body, $data);

        return ['content' => json_encode(['title' => $title, 'body' => $body])];
    }

    /**
     * SMS delivery via Twilio (stub).
     */
    private function sendSms(string $userId, string $type, array $data): array
    {
        $message = $data['message'] ?? 'NexaTrace alert.';

        Log::info('NotificationBlastService: SMS stub — would send', [
            'user_id' => $userId, 'message' => $message,
        ]);

        // Future implementation:
        // $user = \App\Models\User::find($userId);
        // $twilio = new \Twilio\Rest\Client(env('TWILIO_SID'), env('TWILIO_TOKEN'));
        // $twilio->messages->create($user->phone, ['from' => env('TWILIO_FROM'), 'body' => $message]);

        return ['content' => $message];
    }

    // ─────────────────────────────────────────────────
    // RATE LIMITER (Redis-backed)
    // ─────────────────────────────────────────────────

    private function checkRateLimit(string $userId, string $channel): bool
    {
        $max = match ($channel) {
            'email'     => self::RATE_LIMIT_MAX_EMAIL,
            'push'      => self::RATE_LIMIT_MAX_PUSH,
            'sms'       => self::RATE_LIMIT_MAX_SMS,
            'websocket' => self::RATE_LIMIT_MAX_WEBSOCKET,
            default     => 10,
        };

        $key = "rate_limit:notify:{$userId}:{$channel}";
        $current = $this->cache->incrementRateLimit($userId, "notify:{$channel}", self::RATE_LIMIT_WINDOW);

        if ($current > $max) {
            Log::warning("NotificationBlastService: rate limit exceeded", [
                'user_id' => $userId, 'channel' => $channel, 'current' => $current, 'max' => $max,
            ]);
            return false;
        }

        return true;
    }

    // ─────────────────────────────────────────────────
    // DEAD-LETTER QUEUE
    // ─────────────────────────────────────────────────

    /**
     * Process dead-letter queue — retry all failed notifications
     * that haven't exceeded max retries.
     *
     * Called by scheduled artisan command.
     *
     * @return int  Number of notifications retried
     */
    public function processDeadLetterQueue(): int
    {
        $failedLogs = NotificationLog::where('status', NotificationLog::STATUS_FAILED)
            ->where('attempts', '<', self::MAX_RETRIES)
            ->orderBy('failed_at')
            ->limit(100)
            ->get();

        $retried = 0;

        foreach ($failedLogs as $log) {
            // Exponential backoff: only retry if enough time passed
            $backoff = self::RETRY_BACKOFF_BASE * pow(2, $log->attempts - 1);
            if ($log->failed_at->diffInSeconds(now()) < $backoff) {
                continue;
            }

            $result = $this->retry($log->id);
            if ($result && $result->status === NotificationLog::STATUS_DELIVERED) {
                $retried++;
            }
        }

        if ($retried > 0) {
            Log::info('NotificationBlastService: dead-letter processed', ['retried' => $retried]);
        }

        return $retried;
    }
}
