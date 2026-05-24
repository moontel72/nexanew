<?php

namespace App\Http\Controllers;

use App\Models\Analytics\AnalyticsSnapshot;
use App\Services\Analytics\AnalyticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * NEXATRACE — ANALYTICS CONTROLLER
 * ==================================
 *
 * Super Admin & Sub-Admin API for dashboard metrics,
 * time-series charts, and system health.
 *
 * TARGET MODULES: 1D, 2C
 *
 * SAFETY: Entirely new controller. Reads from analytics_snapshots + cache only.
 */

class AnalyticsController extends Controller
{
    public function __construct(
        private AnalyticsService $analytics
    ) {}

    /**
     * GET /api/v1/admin/analytics/dashboard
     */
    public function dashboard(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $this->analytics->getRealtimeDashboard(),
        ]);
    }

    /**
     * GET /api/v1/admin/analytics/charts?group=freight&key=completed_trips_today&type=daily&start=...&end=...
     */
    public function charts(Request $request): JsonResponse
    {
        $data = $request->validate([
            'group' => ['required', 'string'],
            'key' => ['required', 'string'],
            'type' => ['nullable', 'string', 'in:' . implode(',', [
                AnalyticsSnapshot::TYPE_HOURLY, AnalyticsSnapshot::TYPE_DAILY,
                AnalyticsSnapshot::TYPE_WEEKLY, AnalyticsSnapshot::TYPE_MONTHLY,
            ])],
            'start' => ['required', 'date'],
            'end' => ['required', 'date'],
        ]);

        $chart = $this->analytics->getChartData(
            $data['group'], $data['key'],
            $data['start'], $data['end'],
            $data['type'] ?? AnalyticsSnapshot::TYPE_DAILY
        );

        return response()->json(['success' => true, 'data' => $chart]);
    }

    /**
     * GET /api/v1/admin/analytics/health
     */
    public function health(): JsonResponse
    {
        $snapshots = AnalyticsSnapshot::type(AnalyticsSnapshot::TYPE_REALTIME)
            ->group('system')
            ->where('metric_key', 'health_score')
            ->orderByDesc('snapshot_at')
            ->limit(30)
            ->get(['snapshot_at', 'metric_value']);

        return response()->json(['success' => true, 'data' => $snapshots]);
    }

    /**
     * GET /api/v1/admin/analytics/summary
     */
    public function summary(): JsonResponse
    {
        $today = today()->toDateString();
        $yesterday = today()->subDay()->toDateString();

        $summary = [
            'today' => AnalyticsSnapshot::type(AnalyticsSnapshot::TYPE_DAILY)
                ->whereDate('snapshot_at', $today)->get(),
            'yesterday' => AnalyticsSnapshot::type(AnalyticsSnapshot::TYPE_DAILY)
                ->whereDate('snapshot_at', $yesterday)->get(),
        ];

        return response()->json(['success' => true, 'data' => $summary]);
    }
}
