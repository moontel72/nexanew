<?php

namespace App\Http\Controllers;

use App\Jobs\NotificationBlastJob;
use App\Models\Notification\NotificationLog;
use App\Models\Notification\UserNotificationPreference;
use App\Services\Notification\NotificationBlastService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — NOTIFICATION CONTROLLER
 * =====================================
 *
 * Super Admin API for sending platform-wide notifications,
 * managing user preferences, and viewing delivery logs.
 *
 * TARGET MODULES: 1F, 12K
 *
 * SAFETY: Entirely new controller. Zero modification to existing code.
 */

class NotificationController extends Controller
{
    public function __construct(
        private NotificationBlastService $blast
    ) {}

    // ─── BLAST (Super Admin) ────────────────────────────

    /**
     * POST /api/v1/admin/notifications/blast
     *
     * Send a notification to filtered users.
     */
    public function blast(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', 'string', 'max:100'],
            'title' => ['nullable', 'string', 'max:200'],
            'message' => ['required', 'string', 'max:2000'],
            'channels' => ['nullable', 'array'],
            'channels.*' => ['string', 'in:websocket,email,push,sms'],
            'user_ids' => ['nullable', 'array'],
            'user_ids.*' => ['string'],
            'company_ids' => ['nullable', 'array'],
            'company_ids.*' => ['string'],
            'plan_tiers' => ['nullable', 'array'],
            'plan_tiers.*' => ['string', 'in:free,basic,standard,premium,custom'],
        ]);

        // ─── Resolve target users ──────────────────────
        $userIds = $data['user_ids'] ?? [];

        if (empty($userIds) && (! empty($data['company_ids']) || ! empty($data['plan_tiers']))) {
            $query = \App\Models\User::query();

            if (! empty($data['company_ids'])) {
                $query->whereIn('company_id', $data['company_ids']);
            }
            if (! empty($data['plan_tiers'])) {
                $query->whereHas('company.activeSubscription', function ($q) use ($data) {
                    $q->whereHas('plan', fn($p) => $p->whereIn('name', $data['plan_tiers']));
                });
            }

            $userIds = $query->pluck('id')->toArray();
        }

        if (empty($userIds)) {
            return response()->json(['success' => false, 'message' => 'No target users specified.'], 422);
        }

        // ─── Dispatch async job ────────────────────────
        $payload = ['title' => $data['title'] ?? 'NexaTrace', 'message' => $data['message']];

        NotificationBlastJob::dispatch(
            userIds: $userIds,
            type: $data['type'],
            data: $payload,
            channels: $data['channels'] ?? null,
        );

        return response()->json([
            'success' => true,
            'message' => "Notification blast queued for " . count($userIds) . " users.",
            'data' => ['target_count' => count($userIds), 'type' => $data['type']],
        ], 202);
    }

    // ─── LOGS ───────────────────────────────────────────

    /**
     * GET /api/v1/admin/notifications/logs
     */
    public function logs(Request $request): JsonResponse
    {
        $logs = NotificationLog::query()
            ->when($request->query('status'), fn($q, $s) => $q->where('status', $s))
            ->when($request->query('channel'), fn($q, $c) => $q->where('channel', $c))
            ->when($request->query('type'), fn($q, $t) => $q->where('type', $t))
            ->orderByDesc('created_at')
            ->paginate(25);

        return response()->json(['success' => true, 'data' => $logs]);
    }

    // ─── PREFERENCES ────────────────────────────────────

    /**
     * GET /api/v1/user/notifications/preferences
     */
    public function getPreferences(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $prefs = UserNotificationPreference::where('user_id', $userId)->get();

        return response()->json(['success' => true, 'data' => $prefs]);
    }

    /**
     * PUT /api/v1/user/notifications/preferences
     */
    public function updatePreferences(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $data = $request->validate([
            'notification_type' => ['required', 'string', 'max:100'],
            'channel_preferences' => ['required', 'array'],
            'channel_preferences.email' => ['boolean'],
            'channel_preferences.push' => ['boolean'],
            'channel_preferences.sms' => ['boolean'],
            'channel_preferences.websocket' => ['boolean'],
            'is_enabled' => ['boolean'],
        ]);

        $pref = UserNotificationPreference::updateOrCreate(
            ['user_id' => $userId, 'notification_type' => $data['notification_type']],
            [
                'id' => (string) \Illuminate\Support\Str::uuid(),
                'channel_preferences' => $data['channel_preferences'],
                'is_enabled' => $data['is_enabled'] ?? true,
            ]
        );

        return response()->json(['success' => true, 'data' => $pref]);
    }

    /**
     * GET /api/v1/admin/notifications/stats
     */
    public function stats(): JsonResponse
    {
        $stats = [
            'delivered_today' => NotificationLog::whereDate('delivered_at', today())->count(),
            'failed_today' => NotificationLog::whereDate('failed_at', today())->count(),
            'queued' => NotificationLog::where('status', NotificationLog::STATUS_QUEUED)->count(),
            'failed_pending_retry' => NotificationLog::where('status', NotificationLog::STATUS_FAILED)
                ->where('attempts', '<', 3)->count(),
            'by_channel' => NotificationLog::whereDate('created_at', today())
                ->selectRaw('channel, COUNT(*) as count')
                ->groupBy('channel')->get()->toArray(),
        ];

        return response()->json(['success' => true, 'data' => $stats]);
    }
}
