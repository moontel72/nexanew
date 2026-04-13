<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\SubscriptionPlan;
use App\Models\Invoice;
use App\Models\AdminUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminDashboardController extends Controller
{
    /**
     * Get dashboard statistics
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getDashboardStats(Request $request)
    {
        try {
            $admin = $request->user();

            // Get date range from request or default to current month
            $startDate = $request->input('start_date', Carbon::now()->startOfMonth());
            $endDate = $request->input('end_date', Carbon::now()->endOfMonth());

            // Convert to Carbon instances if they're strings
            if (is_string($startDate)) {
                $startDate = Carbon::parse($startDate);
            }
            if (is_string($endDate)) {
                $endDate = Carbon::parse($endDate);
            }

            // Company Statistics
            $companyStats = [
                'total' => Company::count(),
                'active' => Company::where('status', 'active')->count(),
                'pending' => Company::where('status', 'pending')->count(),
                'suspended' => Company::where('status', 'suspended')->count(),
                'verified' => Company::where('verification_status', 'verified')->count(),
                'pending_verification' => Company::where('verification_status', 'pending')->count(),
            ];

            // Revenue Statistics
            $revenueStats = $this->getRevenueStats($startDate, $endDate);

            // Subscription Plan Statistics
            $planStats = $this->getPlanStats();

            // Usage Statistics
            $usageStats = $this->getUsageStats($startDate, $endDate);

            // Recent Activities
            $recentActivities = $this->getRecentActivities(10);

            // System Health
            $systemHealth = $this->getSystemHealth();

            // Top Performing Companies
            $topCompanies = $this->getTopPerformingCompanies(5);

            // Monthly Growth
            $monthlyGrowth = $this->getMonthlyGrowth();

            return response()->json([
                'success' => true,
                'data' => [
                    'company_stats' => $companyStats,
                    'revenue_stats' => $revenueStats,
                    'plan_stats' => $planStats,
                    'usage_stats' => $usageStats,
                    'recent_activities' => $recentActivities,
                    'system_health' => $systemHealth,
                    'top_companies' => $topCompanies,
                    'monthly_growth' => $monthlyGrowth,
                    'date_range' => [
                        'start' => $startDate->toDateString(),
                        'end' => $endDate->toDateString(),
                    ],
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch dashboard statistics',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get revenue statistics
     *
     * @param Carbon $startDate
     * @param Carbon $endDate
     * @return array
     */
    private function getRevenueStats(Carbon $startDate, Carbon $endDate): array
    {
        // Total revenue for period
        $totalRevenue = Invoice::where('status', 'paid')
            ->whereBetween('paid_at', [$startDate, $endDate])
            ->sum('amount');

        // Previous period revenue for comparison
        $previousStartDate = $startDate->copy()->subMonth();
        $previousEndDate = $endDate->copy()->subMonth();
        $previousRevenue = Invoice::where('status', 'paid')
            ->whereBetween('paid_at', [$previousStartDate, $previousEndDate])
            ->sum('amount');

        // Revenue growth percentage
        $revenueGrowth = $previousRevenue > 0
            ? (($totalRevenue - $previousRevenue) / $previousRevenue) * 100
            : ($totalRevenue > 0 ? 100 : 0);

        // Pending invoices
        $pendingInvoices = Invoice::where('status', 'pending')
            ->whereBetween('due_date', [$startDate, $endDate])
            ->sum('amount');

        // Overdue invoices
        $overdueInvoices = Invoice::where('status', 'pending')
            ->where('due_date', '<', now())
            ->sum('amount');

        // Revenue by plan type
        $revenueByPlan = DB::table('invoices')
            ->join('subscriptions', 'invoices.subscription_id', '=', 'subscriptions.id')
            ->join('subscription_plans', 'subscriptions.plan_id', '=', 'subscription_plans.id')
            ->where('invoices.status', 'paid')
            ->whereBetween('invoices.paid_at', [$startDate, $endDate])
            ->select('subscription_plans.type', DB::raw('SUM(invoices.amount) as revenue'))
            ->groupBy('subscription_plans.type')
            ->get()
            ->pluck('revenue', 'type')
            ->toArray();

        return [
            'total_revenue' => round($totalRevenue, 2),
            'previous_revenue' => round($previousRevenue, 2),
            'revenue_growth' => round($revenueGrowth, 2),
            'pending_invoices' => round($pendingInvoices, 2),
            'overdue_invoices' => round($overdueInvoices, 2),
            'revenue_by_plan' => $revenueByPlan,
            'currency' => 'USD',
        ];
    }

    /**
     * Get subscription plan statistics
     *
     * @return array
     */
    private function getPlanStats(): array
    {
        $plans = SubscriptionPlan::all();

        $planStats = [];
        $totalCompanies = Company::count();

        foreach ($plans as $plan) {
            $companyCount = Company::where('current_plan_id', $plan->id)->count();
            $percentage = $totalCompanies > 0 ? ($companyCount / $totalCompanies) * 100 : 0;

            $planStats[] = [
                'id' => $plan->id,
                'name' => $plan->name,
                'type' => $plan->type,
                'price' => $plan->price,
                'company_count' => $companyCount,
                'percentage' => round($percentage, 2),
                'revenue' => $this->getPlanRevenue($plan->id),
            ];
        }

        // Sort by company count descending
        usort($planStats, function($a, $b) {
            return $b['company_count'] <=> $a['company_count'];
        });

        return $planStats;
    }

    /**
     * Get revenue for a specific plan
     *
     * @param string $planId
     * @return float
     */
    private function getPlanRevenue(string $planId): float
    {
        return Invoice::whereHas('subscription', function($query) use ($planId) {
                $query->where('plan_id', $planId);
            })
            ->where('status', 'paid')
            ->whereBetween('paid_at', [now()->startOfMonth(), now()->endOfMonth()])
            ->sum('amount');
    }

    /**
     * Get usage statistics
     *
     * @param Carbon $startDate
     * @param Carbon $endDate
     * @return array
     */
    private function getUsageStats(Carbon $startDate, Carbon $endDate): array
    {
        // Total codes generated
        $totalCodes = DB::table('code_generation_logs')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('codes_generated');

        // Codes by type
        $codesByType = DB::table('code_generation_logs')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->select('code_type', DB::raw('SUM(codes_generated) as total'))
            ->groupBy('code_type')
            ->get()
            ->pluck('total', 'code_type')
            ->toArray();

        // Active users
        $activeUsers = DB::table('users')
            ->where('last_active_at', '>=', now()->subDays(30))
            ->count();

        // Total users
        $totalUsers = DB::table('users')->count();

        // System uptime (simplified - would be from monitoring system)
        $systemUptime = 99.8; // Percentage

        return [
            'total_codes_generated' => $totalCodes,
            'codes_by_type' => $codesByType,
            'active_users' => $activeUsers,
            'total_users' => $totalUsers,
            'user_activity_rate' => $totalUsers > 0 ? round(($activeUsers / $totalUsers) * 100, 2) : 0,
            'system_uptime' => $systemUptime,
        ];
    }

    /**
     * Get recent activities
     *
     * @param int $limit
     * @return array
     */
    private function getRecentActivities(int $limit = 10): array
    {
        $activities = DB::table('admin_audit_logs')
            ->join('admin_users', 'admin_audit_logs.admin_user_id', '=', 'admin_users.id')
            ->select(
                'admin_audit_logs.*',
                'admin_users.name as admin_name',
                'admin_users.email as admin_email'
            )
            ->orderBy('admin_audit_logs.created_at', 'desc')
            ->limit($limit)
            ->get()
            ->map(function($activity) {
                return [
                    'id' => $activity->id,
                    'action' => $activity->action,
                    'description' => $activity->description,
                    'admin_name' => $activity->admin_name,
                    'admin_email' => $activity->admin_email,
                    'ip_address' => $activity->ip_address,
                    'user_agent' => $activity->user_agent,
                    'created_at' => $activity->created_at,
                    'time_ago' => Carbon::parse($activity->created_at)->diffForHumans(),
                ];
            })
            ->toArray();

        return $activities;
    }

    /**
     * Get system health status
     *
     * @return array
     */
    private function getSystemHealth(): array
    {
        // Database connection check
        $databaseStatus = 'healthy';
        try {
            DB::connection()->getPdo();
        } catch (\Exception $e) {
            $databaseStatus = 'unhealthy';
        }

        // Storage check
        $storagePath = storage_path();
        $totalSpace = disk_total_space($storagePath);
        $freeSpace = disk_free_space($storagePath);
        $storageUsage = $totalSpace > 0 ? (($totalSpace - $freeSpace) / $totalSpace) * 100 : 0;

        // Memory usage (simplified)
        $memoryUsage = memory_get_usage(true);
        $memoryLimit = ini_get('memory_limit');
        $memoryPercentage = $this->convertToBytes($memoryLimit) > 0
            ? ($memoryUsage / $this->convertToBytes($memoryLimit)) * 100
            : 0;

        // Queue status
        $queueStatus = 'idle';
        $pendingJobs = DB::table('jobs')->count();
        if ($pendingJobs > 100) {
            $queueStatus = 'busy';
        } elseif ($pendingJobs > 1000) {
            $queueStatus = 'overloaded';
        }

        return [
            'database' => [
                'status' => $databaseStatus,
                'connection' => $databaseStatus === 'healthy' ? 'connected' : 'disconnected',
            ],
            'storage' => [
                'total_gb' => round($totalSpace / (1024 * 1024 * 1024), 2),
                'free_gb' => round($freeSpace / (1024 * 1024 * 1024), 2),
                'usage_percentage' => round($storageUsage, 2),
                'status' => $storageUsage > 90 ? 'critical' : ($storageUsage > 80 ? 'warning' : 'healthy'),
            ],
            'memory' => [
                'usage_mb' => round($memoryUsage / (1024 * 1024), 2),
                'limit_mb' => round($this->convertToBytes($memoryLimit) / (1024 * 1024), 2),
                'usage_percentage' => round($memoryPercentage, 2),
                'status' => $memoryPercentage > 90 ? 'critical' : ($memoryPercentage > 80 ? 'warning' : 'healthy'),
            ],
            'queue' => [
                'status' => $queueStatus,
                'pending_jobs' => $pendingJobs,
            ],
            'overall_status' => $this->getOverallHealthStatus([
                'database' => $databaseStatus,
                'storage' => $storageUsage > 90 ? 'critical' : ($storageUsage > 80 ? 'warning' : 'healthy'),
                'memory' => $memoryPercentage > 90 ? 'critical' : ($memoryPercentage > 80 ? 'warning' : 'healthy'),
                'queue' => $queueStatus,
            ]),
        ];
    }

    /**
     * Convert memory limit string to bytes
     *
     * @param string $memoryLimit
     * @return int
     */
    private function convertToBytes(string $memoryLimit): int
    {
        $value = (int) $memoryLimit;
        $unit = strtolower(substr($memoryLimit, -1));

        switch ($unit) {
            case 'g':
                return $value * 1024 * 1024 * 1024;
            case 'm':
                return $value * 1024 * 1024;
            case 'k':
                return $value * 1024;
            default:
                return $value;
        }
    }

    /**
     * Get overall health status
     *
     * @param array $componentStatuses
     * @return string
     */
    private function getOverallHealthStatus(array $componentStatuses): string
    {
        if (in_array('critical', $componentStatuses)) {
            return 'critical';
        }

        if (in_array('warning', $componentStatuses)) {
            return 'warning';
        }

        if (in_array('unhealthy', $componentStatuses)) {
            return 'unhealthy';
        }

        return 'healthy';
    }

    /**
     * Get top performing companies
     *
     * @param int $limit
     * @return array
     */
    private function getTopPerformingCompanies(int $limit = 5): array
    {
        $companies = Company::with(['currentPlan', 'usageStats'])
            ->where('status', 'active')
            ->orderBy('total_codes_generated', 'desc')
            ->limit($limit)
            ->get()
            ->map(function($company) {
                return [
                    'id' => $company->id,
                    'name' => $company->name,
                    'email' => $company->email,
                    'plan_name' => $company->currentPlan ? $company->currentPlan->name : 'No Plan',
                    'plan_type' => $company->currentPlan ? $company->currentPlan->type : 'free',
                    'total_codes' => $company->total_codes_generated,
                    'active_users' => $company->active_users_count,
                    'last_activity' => $company->last_activity_at ? $company->last_activity_at->diffForHumans() : 'Never',
                    'revenue_generated' => $this->getCompanyRevenue($company->id),
                ];
            })
            ->toArray();

        return $companies;
    }

    /**
     * Get revenue generated by a company
     *
     * @param string $companyId
     * @return float
     */
    private function getCompanyRevenue(string $companyId): float
    {
        return Invoice::whereHas('subscription', function($query) use ($companyId) {
                $query->where('company_id', $companyId);
            })
            ->where('status', 'paid')
            ->whereBetween('paid_at', [now()->startOfYear(), now()->endOfYear()])
            ->sum('amount');
    }

    /**
     * Get monthly growth statistics
     *
     * @return array
     */
    private function getMonthlyGrowth(): array
    {
        $months = [];
        $companyGrowth = [];
        $revenueGrowth = [];
        $userGrowth = [];

        for ($i = 5; $i >= 0; $i--) {
            $month = now()->subMonths($i);
            $monthName = $month->format('M Y');
            $monthStart = $month->copy()->startOfMonth();
            $monthEnd = $month->copy()->endOfMonth();

            // Company growth
            $companiesAtMonthStart = Company::where('created_at', '<', $monthStart)->count();
            $companiesAtMonthEnd = Company::where('created_at', '<', $monthEnd)->count();
            $companyGrowth[] = $companiesAtMonthEnd - $companiesAtMonthStart;

            // Revenue growth
            $monthRevenue = Invoice::where('status', 'paid')
                ->whereBetween('paid_at', [$monthStart, $monthEnd])
                ->sum('amount');
            $revenueGrowth[] = $monthRevenue;

            // User growth
            $usersAtMonthStart = DB::table('users')->where('created_at', '<', $monthStart)->count();
            $usersAtMonthEnd = DB::table('users')->where('created_at', '<', $monthEnd)->count();
            $userGrowth[] = $usersAtMonthEnd - $usersAtMonthStart;

            $months[] = $monthName;
        }

        return [
            'months' => $months,
            'company_growth' => $companyGrowth,
            'revenue_growth' => $revenueGrowth,
            'user_growth' => $userGrowth,
        ];
    }

    /**
     * Get dashboard filters
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getDashboardFilters(Request $request)
    {
        try {
            $filters = [
                'date_ranges' => [
                    ['value'
