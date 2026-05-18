<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\Invoice;
use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $companyAgg = DB::table('companies')
            ->selectRaw('COUNT(*) AS total')
            ->selectRaw("SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active")
            ->selectRaw("SUM(CASE WHEN verification_status = 'verified' THEN 1 ELSE 0 END) AS verified")
            ->first();

        $now = now();
        $monthlyRevenue = (float) Invoice::query()
            ->where('status', 'paid')
            ->whereYear('issue_date', $now->year)
            ->whereMonth('issue_date', $now->month)
            ->sum('total_amount');

        $pendingPayments = (float) Invoice::query()
            ->whereIn('status', ['pending', 'unpaid'])
            ->sum('total_amount');

        $totalCodesGenerated = (int) (DB::table('companies')->sum('total_codes_generated') ?? 0);

        $dbOk = true;
        $dbStart = microtime(true);
        try {
            DB::select('select 1');
        } catch (\Throwable $e) {
            $dbOk = false;
        }
        $dbResponseMs = (microtime(true) - $dbStart) * 1000.0;

        $walletTx24h = 0;
        if (Schema::hasTable('wallet_transactions')) {
            $walletTx24h = (int) DB::table('wallet_transactions')
                ->where('created_at', '>=', $now->copy()->subDay())
                ->count();
        }

        $openLoads = 0;
        if (Schema::hasTable('loads')) {
            $openLoads = (int) DB::table('loads')->whereIn('status', ['posted', 'open'])->count();
        }

        $activeTrips = 0;
        if (Schema::hasTable('trips')) {
            $activeTrips = (int) DB::table('trips')->whereIn('status', ['active', 'in_progress'])->count();
        }

        $pendingFraudReports = 0;
        if (Schema::hasTable('fraud_reports')) {
            $pendingFraudReports = (int) DB::table('fraud_reports')
                ->whereIn('status', ['pending', 'open'])
                ->count();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'statistics' => [
                    'total_companies' => (int) ($companyAgg->total ?? 0),
                    'active_companies' => (int) ($companyAgg->active ?? 0),
                    'verified_companies' => (int) ($companyAgg->verified ?? 0),
                    'monthly_revenue' => $monthlyRevenue,
                    'pending_payments' => $pendingPayments,
                    'total_codes_generated' => $totalCodesGenerated,
                    'codes_generated_this_month' => 0,
                    'open_loads' => $openLoads,
                    'active_trips' => $activeTrips,
                    'pending_fraud_reports' => $pendingFraudReports,
                    'wallet_transactions_24h' => $walletTx24h,
                ],
                'recent_activities' => [],
                'top_companies' => $this->topCompanies(request())->getData(true)['data'] ?? [],
                'system_health' => [
                    'uptime_percentage' => $dbOk ? 100.0 : 0.0,
                    'response_time' => $dbResponseMs,
                    'cpu_usage' => 0.0,
                    'memory_usage' => 0.0,
                ],
                'revenue_data' => [],
                'usage_data' => [],
            ],
        ]);
    }

    public function stats()
    {
        return $this->statistics();
    }

    public function statistics()
    {
        $companyAgg = DB::table('companies')
            ->selectRaw('COUNT(*) AS total')
            ->selectRaw("SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active")
            ->selectRaw("SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending")
            ->selectRaw("SUM(CASE WHEN status = 'suspended' THEN 1 ELSE 0 END) AS suspended")
            ->selectRaw("SUM(CASE WHEN verification_status = 'verified' THEN 1 ELSE 0 END) AS verified")
            ->first();

        $planAgg = DB::table('subscription_plans')
            ->selectRaw('COUNT(*) AS total')
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'total_companies' => (int) ($companyAgg->total ?? 0),
                'active_companies' => (int) ($companyAgg->active ?? 0),
                'pending_companies' => (int) ($companyAgg->pending ?? 0),
                'suspended_companies' => (int) ($companyAgg->suspended ?? 0),
                'verified_companies' => (int) ($companyAgg->verified ?? 0),
                'total_plans' => (int) ($planAgg->total ?? 0),
            ],
        ]);
    }

    public function filters()
    {
        $countries = Company::query()
            ->select('country')
            ->whereNotNull('country')
            ->distinct()
            ->orderBy('country')
            ->pluck('country')
            ->values()
            ->all();

        return response()->json([
            'success' => true,
            'data' => [
                'countries' => $countries,
                'company_statuses' => ['pending', 'active', 'suspended', 'rejected', 'trial', 'archived'],
                'verification_statuses' => ['notSubmitted', 'submitted', 'underReview', 'verified', 'rejected', 'requiresAdditional'],
                'plan_types' => ['free', 'basic', 'standard', 'premium', 'custom'],
            ],
        ]);
    }

    public function revenue(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function usage(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function activities(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function topCompanies(Request $request)
    {
        $limit = (int) ($request->query('limit', 10));
        $rows = Company::query()
            ->select(['id', 'name', 'total_codes_generated', 'active_users_count', 'last_activity_at'])
            ->orderByDesc('total_codes_generated')
            ->limit($limit)
            ->get()
            ->map(fn ($c) => [
                'id' => (string) $c->id,
                'name' => (string) ($c->name ?? ''),
                'total_codes_generated' => (int) ($c->total_codes_generated ?? 0),
                'active_users_count' => (int) ($c->active_users_count ?? 0),
                'last_activity_at' => optional($c->last_activity_at)->toISOString(),
            ])
            ->all();

        return response()->json(['success' => true, 'data' => $rows]);
    }

    public function systemHealth()
    {
        $dbOk = true;
        try {
            DB::select('select 1');
        } catch (\Throwable $e) {
            $dbOk = false;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'database' => ['ok' => $dbOk],
                'server_time' => now()->toISOString(),
            ],
        ]);
    }

    public function auditLogs(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => [],
            'page' => (int) $request->query('page', 1),
            'limit' => (int) $request->query('limit', 20),
            'total' => 0,
            'total_pages' => 1,
        ]);
    }

    public function subscriptionAnalytics(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function codeAnalytics(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function userGrowth(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function export(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => [
                'download_url' => null,
            ],
        ]);
    }

    public function realtimeMetrics()
    {
        return response()->json(['success' => true, 'data' => []]);
    }

    public function alerts(Request $request)
    {
        return response()->json(['success' => true, 'data' => []]);
    }
}
