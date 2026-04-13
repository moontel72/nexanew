<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Payment;
use App\Models\Company;
use App\Models\SubscriptionPlan;
use App\Models\CreditNote;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class RevenueService
{
    /**
     * Get platform revenue summary
     */
    public function getPlatformRevenueSummary(array $filters = []): array
    {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        // Total revenue (paid invoices)
        $totalRevenue = Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Recurring revenue (subscription invoices)
        $recurringRevenue = Invoice::where('status', 'paid')
            ->where('type', 'subscription')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Usage-based revenue
        $usageRevenue = Invoice::where('status', 'paid')
            ->where('type', 'usage')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Commission revenue
        $commissionRevenue = Invoice::where('status', 'paid')
            ->where('type', 'commission')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Manual invoice revenue
        $manualRevenue = Invoice::where('status', 'paid')
            ->where('type', 'manual')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Pending revenue (unpaid invoices)
        $pendingRevenue = Invoice::where('status', 'pending')
            ->whereBetween('issue_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Overdue revenue
        $overdueRevenue = Invoice::where('status', 'pending')
            ->where('due_date', '<', Carbon::now())
            ->whereBetween('issue_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Refunds and credits
        $refundsAmount = CreditNote::where('status', 'applied')
            ->whereBetween('applied_at', [$startDate, $endDate])
            ->sum('amount');

        // Net revenue (total - refunds)
        $netRevenue = $totalRevenue - $refundsAmount;

        // Revenue by plan tier
        $revenueByPlan = $this->getRevenueByPlanTier($startDate, $endDate);

        // Revenue growth
        $previousPeriod = $this->getPreviousPeriodRevenue($startDate, $endDate);
        $revenueGrowth = $previousPeriod > 0 ? (($totalRevenue - $previousPeriod) / $previousPeriod) * 100 : 0;

        // Average Revenue Per Account (ARPA)
        $activeCompanies = Company::whereHas('invoices', function ($query) use ($startDate, $endDate) {
            $query->where('status', 'paid')
                  ->whereBetween('payment_date', [$startDate, $endDate]);
        })->count();

        $arpa = $activeCompanies > 0 ? $totalRevenue / $activeCompanies : 0;

        // Monthly Recurring Revenue (MRR)
        $mrr = $this->calculateMRR();

        // Annual Recurring Revenue (ARR)
        $arr = $mrr * 12;

        // Churn rate
        $churnRate = $this->calculateChurnRate($startDate, $endDate);

        // Customer Lifetime Value (LTV)
        $ltv = $this->calculateLTV();

        return [
            'period' => [
                'start' => $startDate->toDateString(),
                'end' => $endDate->toDateString(),
                'label' => $this->getPeriodLabel($filters)
            ],
            'revenue_metrics' => [
                'total_revenue' => (float) $totalRevenue,
                'recurring_revenue' => (float) $recurringRevenue,
                'usage_revenue' => (float) $usageRevenue,
                'commission_revenue' => (float) $commissionRevenue,
                'manual_revenue' => (float) $manualRevenue,
                'pending_revenue' => (float) $pendingRevenue,
                'overdue_revenue' => (float) $overdueRevenue,
                'refunds_amount' => (float) $refundsAmount,
                'net_revenue' => (float) $netRevenue,
                'revenue_growth_percentage' => round($revenueGrowth, 2),
                'arpa' => round($arpa, 2),
                'mrr' => round($mrr, 2),
                'arr' => round($arr, 2),
                'churn_rate_percentage' => round($churnRate, 2),
                'ltv' => round($ltv, 2)
            ],
            'revenue_by_plan' => $revenueByPlan,
            'top_performing_companies' => $this->getTopPerformingCompanies($startDate, $endDate, 10),
            'revenue_trend' => $this->getRevenueTrend($startDate, $endDate)
        ];
    }

    /**
     * Get revenue by company
     */
    public function getRevenueByCompany(array $filters = []): array
    {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        $query = Company::with(['invoices' => function ($query) use ($startDate, $endDate) {
            $query->where('status', 'paid')
                  ->whereBetween('payment_date', [$startDate, $endDate]);
        }, 'activeSubscription.plan']);

        // Apply filters
        if (!empty($filters['plan_id'])) {
            $query->whereHas('activeSubscription', function ($q) use ($filters) {
                $q->where('plan_id', $filters['plan_id']);
            });
        }

        if (!empty($filters['region'])) {
            $query->where('region', $filters['region']);
        }

        $companies = $query->get();

        $result = [];
        foreach ($companies as $company) {
            $paidInvoices = $company->invoices;
            $totalRevenue = $paidInvoices->sum('total_amount');

            if ($totalRevenue > 0) {
                $result[] = [
                    'company' => [
                        'id' => $company->id,
                        'name' => $company->name,
                        'email' => $company->billing_email,
                        'plan' => $company->activeSubscription?->plan?->name ?? 'No active plan',
                        'region' => $company->region,
                        'status' => $company->status
                    ],
                    'revenue_metrics' => [
                        'total_revenue' => (float) $totalRevenue,
                        'invoice_count' => $paidInvoices->count(),
                        'average_invoice_amount' => $paidInvoices->count() > 0 ?
                            $totalRevenue / $paidInvoices->count() : 0,
                        'last_payment_date' => $paidInvoices->max('payment_date')?->toDateString(),
                        'payment_methods' => $paidInvoices->pluck('method')->unique()->values()
                    ],
                    'revenue_breakdown' => [
                        'subscription' => (float) $paidInvoices->where('type', 'subscription')->sum('total_amount'),
                        'usage' => (float) $paidInvoices->where('type', 'usage')->sum('total_amount'),
                        'commission' => (float) $paidInvoices->where('type', 'commission')->sum('total_amount'),
                        'manual' => (float) $paidInvoices->where('type', 'manual')->sum('total_amount')
                    ]
                ];
            }
        }

        // Sort by total revenue (descending)
        usort($result, function ($a, $b) {
            return $b['revenue_metrics']['total_revenue'] <=> $a['revenue_metrics']['total_revenue'];
        });

        // Apply pagination if needed
        $limit = $filters['limit'] ?? 50;
        $page = $filters['page'] ?? 1;
        $offset = ($page - 1) * $limit;

        return [
            'companies' => array_slice($result, $offset, $limit),
            'pagination' => [
                'total' => count($result),
                'per_page' => $limit,
                'current_page' => $page,
                'total_pages' => ceil(count($result) / $limit)
            ],
            'summary' => [
                'total_companies' => count($result),
                'total_revenue' => array_sum(array_column($result, 'revenue_metrics.total_revenue')),
                'average_revenue_per_company' => count($result) > 0 ?
                    array_sum(array_column($result, 'revenue_metrics.total_revenue')) / count($result) : 0
            ]
        ];
    }

    /**
     * Get recurring revenue metrics
     */
    public function getRecurringRevenueMetrics(): array
    {
        $currentMonth = Carbon::now()->startOfMonth();
        $previousMonth = Carbon::now()->subMonth()->startOfMonth();

        // Current MRR
        $currentMRR = $this->calculateMRR($currentMonth);

        // Previous MRR
        $previousMRR = $this->calculateMRR($previousMonth);

        // MRR Growth
        $mrrGrowth = $previousMRR > 0 ? (($currentMRR - $previousMRR) / $previousMRR) * 100 : 0;

        // New MRR (from new subscriptions)
        $newMRR = $this->calculateNewMRR($currentMonth);

        // Expansion MRR (from upgrades)
        $expansionMRR = $this->calculateExpansionMRR($currentMonth);

        // Churned MRR
        $churnedMRR = $this->calculateChurnedMRR($currentMonth);

        // Net MRR Change
        $netMRRChange = $newMRR + $expansionMRR - $churnedMRR;

        // MRR by plan
        $mrrByPlan = $this->getMRRByPlan($currentMonth);

        // Customer count by plan
        $customerCountByPlan = $this->getCustomerCountByPlan();

        // ARR
        $arr = $currentMRR * 12;

        return [
            'mrr_metrics' => [
                'current_mrr' => round($currentMRR, 2),
                'previous_mrr' => round($previousMRR, 2),
                'mrr_growth_percentage' => round($mrrGrowth, 2),
                'new_mrr' => round($newMRR, 2),
                'expansion_mrr' => round($expansionMRR, 2),
                'churned_mrr' => round($churnedMRR, 2),
                'net_mrr_change' => round($netMRRChange, 2),
                'arr' => round($arr, 2)
            ],
            'mrr_by_plan' => $mrrByPlan,
            'customer_count_by_plan' => $customerCountByPlan,
            'mrr_trend' => $this->getMRRTrend(12), // Last 12 months
            'churn_analysis' => $this->getChurnAnalysis($currentMonth)
        ];
    }

    /**
     * Get revenue forecast
     */
    public function getRevenueForecast(int $months = 12): array
    {
        $forecast = [];
        $currentDate = Carbon::now()->startOfMonth();

        // Get historical data for last 6 months
        $historicalData = $this->getHistoricalRevenueData(6);

        // Calculate average growth rate
        $growthRate = $this->calculateAverageGrowthRate($historicalData);

        // Get current MRR
        $currentMRR = $this->calculateMRR($currentDate);

        // Forecast future months
        for ($i = 1; $i <= $months; $i++) {
            $forecastDate = $currentDate->copy()->addMonths($i);

            // Apply growth rate
            $forecastMRR = $currentMRR * pow(1 + ($growthRate / 100), $i);
            $forecastARR = $forecastMRR * 12;

            // Factor in seasonality (simplified)
            $seasonalityFactor = $this->getSeasonalityFactor($forecastDate->month);
            $adjustedMRR = $forecastMRR * $seasonalityFactor;

            $forecast[] = [
                'month' => $forecastDate->format('Y-m'),
                'month_name' => $forecastDate->format('F Y'),
                'forecast_mrr' => round($adjustedMRR, 2),
                'forecast_arr' => round($adjustedMRR * 12, 2),
                'growth_rate_percentage' => round($growthRate, 2),
                'seasonality_factor' => round($seasonalityFactor, 2),
                'confidence_level' => $this->calculateConfidenceLevel($i) // Lower confidence for farther months
            ];
        }

        // Calculate total forecast
        $totalForecastMRR = array_sum(array_column($forecast, 'forecast_mrr'));
        $totalForecastARR = array_sum(array_column($forecast, 'forecast_arr'));

        return [
            'forecast_period' => $months . ' months',
            'current_mrr' => round($currentMRR, 2),
            'current_arr' => round($currentMRR * 12, 2),
            'average_growth_rate_percentage' => round($growthRate, 2),
            'forecast_data' => $forecast,
            'summary' => [
                'total_forecast_mrr' => round($totalForecastMRR, 2),
                'total_forecast_arr' => round($totalForecastARR, 2),
                'average_monthly_forecast' => round($totalForecastMRR / $months, 2)
            ],
            'assumptions' => [
                'based_on_historical_months' => 6,
                'includes_seasonality' => true,
                'confidence_decreases_with_time' => true
            ]
        ];
    }

    /**
     * Generate financial report
     */
    public function generateFinancialReport(array $options = []): array
    {
        $reportType = $options['type'] ?? 'profit_loss';
        $dateRange = $this->parseDateRange($options);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        switch ($reportType) {
            case 'profit_loss':
                return $this->generateProfitLossReport($startDate, $endDate);

            case 'balance_sheet':
                return $this->generateBalanceSheetReport($startDate, $endDate);

            case 'cash_flow':
                return $this->generateCashFlowReport($startDate, $endDate);

            case 'revenue_analysis':
                return $this->generateRevenueAnalysisReport($startDate, $endDate);

            default:
                throw new \Exception("Unsupported report type: {$reportType}");
        }
    }

    /**
     * Get tax summary
     */
    public function getTaxSummary(array $filters = []): array
    {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        // Get invoices with tax
        $invoices = Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->where('tax_amount', '>', 0)
            ->with('company')
            ->get();

        // Group by tax rate
        $taxByRate = [];
        $totalTax = 0;
        $totalTaxableAmount = 0;

        foreach ($invoices as $invoice) {
            $taxRate = $invoice->tax_rate * 100; // Convert to percentage
            $taxRateKey = "{$taxRate}%";

            if (!isset($taxByRate[$taxRateKey])) {
                $taxByRate[$taxRateKey] = [
                    'tax_rate' => $taxRate,
                    'tax_amount' => 0,
                    'taxable_amount' => 0,
                    'invoice_count' => 0,
                    'companies' => []
                ];
            }

            $taxByRate[$taxRateKey]['tax_amount'] += $invoice->tax_amount;
            $taxByRate[$taxRateKey]['taxable_amount'] += $invoice->subtotal;
            $taxByRate[$taxRateKey]['invoice_count']++;

            $companyId = $invoice->company_id;
            if (!in_array($companyId, $taxByRate[$taxRateKey]['companies'])) {
                $taxByRate[$taxRateKey]['companies'][] = $companyId;
            }

            $totalTax += $invoice->tax_amount;
            $totalTaxableAmount += $invoice->subtotal;
        }

        // Sort by tax amount (descending)
        uasort($taxByRate, function ($a, $b) {
            return $b['tax_amount'] <=> $a['tax_amount'];
        });

        // Tax by region
        $taxByRegion = $this->getTaxByRegion($startDate, $endDate);

        // Tax liability by due date
        $taxLiability = $this->getTaxLiability($startDate, $endDate);

        return [
            'period' => [
                'start' => $startDate->toDateString(),
                'end' => $endDate->toDateString()
            ],
            'summary' => [
                'total_tax_collected' => round($totalTax, 2),
                'total_taxable_amount' => round($totalTaxableAmount, 2),
                'average_tax_rate_percentage' => $totalTaxableAmount > 0 ?
                    round(($totalTax / $totalTaxableAmount) * 100, 2) : 0,
                'total_invoices_with_tax' => $invoices->count()
            ],
            'tax_by_rate' => $taxByRate,
            'tax_by_region' => $taxByRegion,
            'tax_liability' => $taxLiability
        ];
    }

    /**
     * Get tax by region
     */
    private function getTaxByRegion(Carbon $startDate, Carbon $endDate): array
    {
        $invoices = Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->where('tax_amount', '>', 0)
            ->with('company')
            ->get();

        $taxByRegion = [];
        foreach ($invoices as $invoice) {
            $region = $invoice->company->region ?? 'Unknown';

            if (!isset($taxByRegion[$region])) {
                $taxByRegion[$region] = [
                    'tax_amount' => 0,
                    'taxable_amount' => 0,
                    'invoice_count' => 0
                ];
            }

            $taxByRegion[$region]['tax_amount'] += $invoice->tax_amount;
            $taxByRegion[$region]['taxable_amount'] += $invoice->subtotal;
            $taxByRegion[$region]['invoice_count']++;
        }

        // Sort by tax amount (descending)
        uasort($taxByRegion, function ($a, $b) {
            return $b['tax_amount'] <=> $a['tax_amount'];
        });

        return $taxByRegion;
    }

    /**
     * Get tax liability
     */
    private function getTaxLiability(Carbon $startDate, Carbon $endDate): array
    {
        // This would typically calculate tax liability by due date
        // For now, return a simple structure
        return [
            'current_quarter' => [
                'tax_collected' => 0,
                'tax_due_date' => Carbon::now()->endOfQuarter()->toDateString(),
                'status' => 'not_calculated'
            ],
            'next_quarter' => [
                'estimated_tax' => 0,
                'due_date' => Carbon::now()->addQuarter()->endOfQuarter()->toDateString(),
                'status' => 'estimated'
            ]
        ];
    }

    /**
     * Parse date range from filters
     */
    private function parseDateRange(array $filters): array
    {
        $defaultStart = Carbon::now()->subDays(30)->startOfDay();
        $defaultEnd = Carbon::now()->endOfDay();

        $startDate = !empty($filters['date_from'])
            ? Carbon::parse($filters['date_from'])->startOfDay()
            : $defaultStart;

        $endDate = !empty($filters['date_to'])
            ? Carbon::parse($filters['date_to'])->endOfDay()
            : $defaultEnd;

        return [
            'start' => $startDate,
            'end' => $endDate
        ];
    }

    /**
     * Get period label
     */
    private function getPeriodLabel(array $filters): string
    {
        if (!empty($filters['date_from']) && !empty($filters['date_to'])) {
            $start = Carbon::parse($filters['date_from'])->format('M d, Y');
            $end = Carbon::parse($filters['date_to'])->format('M d, Y');
            return "{$start} - {$end}";
        }

        return 'Last 30 Days';
    }

    /**
     * Get revenue by plan tier
     */
    private function getRevenueByPlanTier(Carbon $startDate, Carbon $endDate): array
    {
        $revenueByPlan = [];

        // Get all subscription plans
        $plans = SubscriptionPlan::all();

        foreach ($plans as $plan) {
            $revenue = Invoice::where('status', 'paid')
                ->where('type', 'subscription')
                ->whereBetween('payment_date', [$startDate, $endDate])
                ->whereHas('company.activeSubscription', function ($query) use ($plan) {
                    $query->where('plan_id', $plan->id);
                })
                ->sum('total_amount');

            if ($revenue > 0) {
                $revenueByPlan[] = [
                    'plan_id' => $plan->id,
                    'plan_name' => $plan->name,
                    'revenue' => (float) $revenue,
                    'customer_count' => $plan->activeSubscriptions()->count()
                ];
            }
        }

        // Sort by revenue (descending)
        usort($revenueByPlan, function ($a, $b) {
            return $b['revenue'] <=> $a['revenue'];
        });

        return $revenueByPlan;
    }

    /**
     * Get previous period revenue
     */
    private function getPreviousPeriodRevenue(Carbon $startDate, Carbon $endDate): float
    {
        $days = $startDate->diffInDays($endDate);
        $previousStartDate = $startDate->copy()->subDays($days);
        $previousEndDate = $startDate->copy()->subDay();

        return (float) Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$previousStartDate, $previousEndDate])
            ->sum('total_amount');
    }

    /**
     * Calculate MRR
     */
    private function calculateMRR(Carbon $date = null): float
    {
        if (!$date) {
            $date = Carbon::now();
        }

        $startOfMonth = $date->copy()->startOfMonth();
        $endOfMonth = $date->copy()->endOfMonth();

        $mrr = Invoice::where('status', 'paid')
            ->where('type', 'subscription')
            ->whereBetween('payment_date', [$startOfMonth, $endOfMonth])
            ->sum('total_amount');

        return (float) $mrr;
    }

    /**
     * Calculate churn rate
     */
    private function calculateChurnRate(Carbon $startDate, Carbon $endDate): float
    {
        // This is a simplified churn calculation
        // In production, you'd want more sophisticated logic

        $periodDays = $startDate->diffInDays($endDate);
        $churnedCompanies = 0;
        $totalCompanies = Company::count();

        if ($totalCompanies === 0) {
            return 0;
        }

        // Simplified: companies with no payments in the period
        $activeCompanies = Company::whereHas('invoices', function ($query) use ($startDate, $endDate) {
            $query->where('status', 'paid')
                  ->whereBetween('payment_date', [$startDate, $endDate]);
        })->count();

        $churnedCompanies = $totalCompanies - $activeCompanies;

        return $churnedCompanies > 0 ? ($churnedCompanies / $totalCompanies) * 100 : 0;
    }

    /**
     * Calculate LTV
     */
    private function calculateLTV(): float
    {
        // Simplified LTV calculation
        $arpa = $this->calculateARPA();
        $churnRate = $this->calculateChurnRate(
            Carbon::now()->subMonths(3),
            Carbon::now()
        );

        if ($churnRate === 0) {
            return 0;
        }

        return $arpa / ($churnRate / 100);
    }

    /**
     * Calculate ARPA
     */
    private function calculateARPA(): float
    {
        $startDate = Carbon::now()->subMonths(3);
        $endDate = Carbon::now();

        $totalRevenue = Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        $activeCompanies = Company::whereHas('invoices', function ($query) use ($startDate, $endDate) {
            $query->where('status', 'paid')
                  ->whereBetween('payment_date', [$startDate, $endDate]);
        })->count();

        return $activeCompanies > 0 ? $totalRevenue / $activeCompanies : 0;
    }

    /**
     * Get top performing companies
     */
    private function getTopPerformingCompanies(Carbon $startDate, Carbon $endDate, int $limit = 10): array
    {
        $companies = Company::with(['invoices' => function ($query) use ($startDate, $endDate) {
            $query->where('status', 'paid')
                  ->whereBetween('payment_date', [$startDate, $endDate]);
        }])->get();

        $performanceData = [];
        foreach ($companies as $company) {
            $revenue = $company->invoices->sum('total_amount');
            if ($revenue > 0) {
                $performanceData[] = [
                    'company_id' => $company->id,
                    'company_name' => $company->name,
                    'revenue' => $revenue,
                    'invoice_count' => $company->invoices->count(),
                    'plan' => $company->activeSubscription?->plan?->name ?? 'No active plan'
                ];
            }
        }

        // Sort by revenue (descending)
        usort($performanceData, function ($a, $b) {
            return $b['revenue'] <=> $a['revenue'];
        });

        return array_slice($performanceData, 0, $limit);
    }

    /**
     * Get revenue trend
     */
    private function getRevenueTrend(Carbon $startDate, Carbon $endDate): array
    {
        $trend = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= $endDate) {
            $periodEnd = $currentDate->copy()->addDays(6)->endOfDay();
            if ($periodEnd > $endDate) {
                $periodEnd = $endDate;
            }

            $revenue = Invoice::where('status', 'paid')
                ->whereBetween('payment_date', [$currentDate, $periodEnd])
                ->sum('total_amount');

            $trend[] = [
                'period' => $currentDate->format('Y-m-d'),
                'revenue' => (float) $revenue,
                'period_label' => $currentDate->format('M d') . ' - ' . $periodEnd->format('M d')
            ];

            $currentDate = $periodEnd->copy()->addDay()->startOfDay();
        }

        return $trend;
    }

    /**
     * Get historical revenue data
     */
    private function getHistoricalRevenueData(int $months): array
    {
        $data = [];
        $currentDate = Carbon::now()->startOfMonth();

        for ($i = 0; $i < $months; $i++) {
            $monthStart = $currentDate->copy()->subMonths($i)->startOfMonth();
            $monthEnd = $monthStart->copy()->endOfMonth();

            $revenue = Invoice::where('status', 'paid')
                ->whereBetween('payment_date', [$monthStart, $monthEnd])
                ->sum('total_amount');

            $data[] = [
                'month' => $monthStart->format('Y-m'),
                'revenue' => (float) $revenue,
                'month_name' => $monthStart->format('F Y')
            ];
        }

        return array_reverse($data);
    }

    /**
     * Calculate average growth rate
     */
    private function calculateAverageGrowthRate(array $historicalData): float
    {
        if (count($historicalData) < 2) {
            return 0;
        }

        $growthRates = [];
        for ($i = 1; $i < count($historicalData); $i++) {
            $current = $historicalData[$i]['revenue'];
            $previous = $historicalData[$i - 1]['revenue'];

            if ($previous > 0) {
                $growthRate = (($current - $previous) / $previous) * 100;
                $growthRates[] = $growthRate;
            }
        }

        return count($growthRates) > 0 ? array_sum($growthRates) / count($growthRates) : 0;
    }

    /**
     * Get seasonality factor
     */
    private function getSeasonalityFactor(int $month): float
    {
        // Simplified seasonality factors
        // In production, you'd want to calculate this based on historical data
        $factors = [
            1 => 0.9,   // January
            2 => 0.95,  // February
            3 => 1.0,   // March
            4 => 1.05,  // April
            5 => 1.1,   // May
            6 => 1.05,  // June
            7 => 1.0,   // July
            8 => 1.05,  // August
            9 => 1.1,   // September
            10 => 1.15, // October
            11 => 1.1,  // November
            12 => 0.95  // December
        ];

        return $factors[$month] ?? 1.0;
    }

    /**
     * Calculate confidence level
     */
    private function calculateConfidenceLevel(int $monthsAhead): float
    {
        // Confidence decreases the further we forecast
        $baseConfidence = 0.9; // 90% confidence for current month
        $decayRate = 0.05; // 5% decay per month

        $confidence = $baseConfidence - ($monthsAhead * $decayRate);
        return max(0.1, $confidence); // Minimum 10% confidence
    }

    /**
     * Generate profit loss report
     */
    private function generateProfitLossReport(Carbon $startDate, Carbon $endDate): array
    {
        // This is a simplified P&L report
        // In production, you'd want more detailed accounting

        $revenue = Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        $refunds = CreditNote::where('status', 'applied')
            ->whereBetween('applied_at', [$startDate, $endDate])
            ->sum('amount');

        $netRevenue = $revenue - $refunds;

        // Simplified expense calculation
        // In production, you'd have actual expense data
        $estimatedExpenses = $netRevenue * 0.3; // Assume 30% expenses

        $netProfit = $netRevenue - $estimatedExpenses;

        return [
            'period' => [
                'start' => $startDate->toDateString(),
                'end' => $endDate->toDateString()
            ],
            'revenue' => [
                'gross_revenue' => round($revenue, 2),
                'refunds' => round($refunds, 2),
                'net_revenue' => round($netRevenue, 2)
            ],
            'expenses' => [
                'estimated_expenses' => round($estimatedExpenses, 2),
                'expense_ratio' => $netRevenue > 0 ? round(($estimatedExpenses / $netRevenue) * 100, 2) : 0
            ],
            'profit' => [
                'net_profit' => round($netProfit, 2),
                'profit_margin' => $netRevenue > 0 ? round(($netProfit / $netRevenue) * 100, 2) : 0
            ]
        ];
    }

    /**
     * Generate balance sheet report
     */
    private function generateBalanceSheetReport(Carbon $startDate, Carbon $endDate): array
    {
        // Simplified balance sheet
        // In production, you'd have actual asset/liability data

        $assets = [
            'cash' => 100000, // Example
            'accounts_receivable' => Invoice::where('status', 'pending')->sum('total_amount'),
            'total_assets' => 0
        ];
        $assets['total_assets'] = array_sum($assets);

        $liabilities = [
            'accounts_payable' => 50000, // Example
            'total_liabilities' => 0
        ];
        $liabilities['total_liabilities'] = array_sum($liabilities);

        $equity = $assets['total_assets'] - $liabilities['total_liabilities'];

        return [
            'as_of_date' => $endDate->toDateString(),
            'assets' => $assets,
            'liabilities' => $liabilities,
            'equity' => round($equity, 2),
            'balance_check' => $assets['total_assets'] === ($liabilities['total_liabilities'] + $equity)
        ];
    }

    /**
     * Generate cash flow report
     */
    private function generateCashFlowReport(Carbon $startDate, Carbon $endDate): array
    {
        // Simplified cash flow
        $cashInflows = Invoice::where('status', 'paid')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount');

        // Simplified outflows
        $estimatedOutflows = $cashInflows * 0.3; // Assume 30% outflows

        $netCashFlow = $cashInflows - $estimatedOutflows;

        return [
            'period' => [
                'start' => $startDate->toDateString(),
                'end' => $endDate->toDateString()
            ],
            'cash_flows' => [
                'inflows' => round($cashInflows, 2),
                'outflows' => round($estimatedOutflows, 2),
                'net_cash_flow' => round($netCashFlow, 2)
            ],
            'cash_flow_margin' => $cashInflows > 0 ? round(($netCashFlow / $cashInflows) * 100, 2) : 0
        ]
    ];
}

/**
 * Generate revenue analysis report
 */
private function generateRevenueAnalysisReport(Carbon $startDate, Carbon $endDate): array
{
    $revenueByType = [
        'subscription' => Invoice::where('status', 'paid')
            ->where('type', 'subscription')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount'),
        'usage' => Invoice::where('status', 'paid')
            ->where('type', 'usage')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount'),
        'commission' => Invoice::where('status', 'paid')
            ->where('type', 'commission')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount'),
        'manual' => Invoice::where('status', 'paid')
            ->where('type', 'manual')
            ->whereBetween('payment_date', [$startDate, $endDate])
            ->sum('total_amount')
    ];

    $revenueByPlan = $this->getRevenueByPlanTier($startDate, $endDate);
    $revenueByCompany = $this->getTopPerformingCompanies($startDate, $endDate, 20);
    $revenueTrend = $this->getRevenueTrend($startDate, $endDate);

    return [
        'period' => [
            'start' => $startDate->toDateString(),
            'end' => $endDate->toDateString()
        ],
        'revenue_by_type' => $revenueByType,
        'revenue_by_plan' => $revenueByPlan,
        'top_companies' => $revenueByCompany,
        'revenue_trend' => $revenueTrend,
        'summary' => [
            'total_revenue' => round(array_sum($revenueByType), 2),
            'average_daily_revenue' => round(array_sum($revenueByType) / max(1, $startDate->diffInDays($endDate)), 2),
            'revenue_growth' => $this->calculateRevenueGrowth($startDate, $endDate)
        ]
    ];
}

/**
 * Calculate revenue growth
 */
private function calculateRevenueGrowth(Carbon $startDate, Carbon $endDate): array
{
    $periodDays = $startDate->diffInDays($endDate);
    $previousStartDate = $startDate->copy()->subDays($periodDays);
    $previousEndDate = $startDate->copy()->subDay();

    $currentRevenue = Invoice::where('status', 'paid')
        ->whereBetween('payment_date', [$startDate, $endDate])
        ->sum('total_amount');

    $previousRevenue = Invoice::where('status', 'paid')
        ->whereBetween('payment_date', [$previousStartDate, $previousEndDate])
        ->sum('total_amount');

    $growthAmount = $currentRevenue - $previousRevenue;
    $growthPercentage = $previousRevenue > 0 ? ($growthAmount / $previousRevenue) * 100 : 0;

    return [
        'current_period_revenue' => round($currentRevenue, 2),
        'previous_period_revenue' => round($previousRevenue, 2),
        'growth_amount' => round($growthAmount, 2),
        'growth_percentage' => round($growthPercentage, 2),
        'growth_direction' => $growthAmount >= 0 ? 'positive' : 'negative'
    ];
}

/**
 * Calculate New MRR
 */
private function calculateNewMRR(Carbon $date): float
{
    $startOfMonth = $date->copy()->startOfMonth();
    $endOfMonth = $date->copy()->endOfMonth();

    // Simplified: revenue from companies with their first subscription invoice
    $newMRR = Invoice::where('status', 'paid')
        ->where('type', 'subscription')
        ->whereBetween('payment_date', [$startOfMonth, $endOfMonth])
        ->whereHas('company', function ($query) use ($startOfMonth) {
            $query->whereDoesntHave('invoices', function ($q) use ($startOfMonth) {
                $q->where('type', 'subscription')
                  ->where('status', 'paid')
                  ->where('payment_date', '<', $startOfMonth);
            });
        })
        ->sum('total_amount');

    return (float) $newMRR;
}

/**
 * Calculate Expansion MRR
 */
private function calculateExpansionMRR(Carbon $date): float
{
    $startOfMonth = $date->copy()->startOfMonth();
    $endOfMonth = $date->copy()->endOfMonth();

    // Simplified: revenue increase from existing customers upgrading
    // In production, you'd track plan upgrades
    return 0.0; // Placeholder
}

/**
 * Calculate Churned MRR
 */
private function calculateChurnedMRR(Carbon $date): float
{
    $startOfMonth = $date->copy()->startOfMonth();
    $previousMonth = $date->copy()->subMonth()->startOfMonth();

    // Simplified: revenue from customers who had subscriptions last month but not this month
    $churnedMRR = Invoice::where('status', 'paid')
        ->where('type', 'subscription')
        ->whereBetween('payment_date', [$previousMonth, $previousMonth->copy()->endOfMonth()])
        ->whereHas('company', function ($query) use ($startOfMonth, $endOfMonth) {
            $query->whereDoesntHave('invoices', function ($q) use ($startOfMonth, $endOfMonth) {
                $q->where('type', 'subscription')
                  ->where('status', 'paid')
                  ->whereBetween('payment_date', [$startOfMonth, $endOfMonth]);
            });
        })
        ->sum('total_amount');

    return (float) $churnedMRR;
}

/**
 * Get MRR by plan
 */
private function getMRRByPlan(Carbon $date): array
{
    $startOfMonth = $date->copy()->startOfMonth();
    $endOfMonth = $date->copy()->endOfMonth();

    $mrrByPlan = [];
    $plans = SubscriptionPlan::all();

    foreach ($plans as $plan) {
        $mrr = Invoice::where('status', 'paid')
            ->where('type', 'subscription')
            ->whereBetween('payment_date', [$startOfMonth, $endOfMonth])
            ->whereHas('company.activeSubscription', function ($query) use ($plan) {
                $query->where('plan_id', $plan->id);
            })
            ->sum('total_amount');

        if ($mrr > 0) {
            $mrrByPlan[] = [
                'plan_id' => $plan->id,
                'plan_name' => $plan->name,
                'mrr' => (float) $mrr,
                'customer_count' => $plan->activeSubscriptions()->count(),
                'arpa' => $plan->activeSubscriptions()->count() > 0 ? $mrr / $plan->activeSubscriptions()->count() : 0
            ];
        }
    }

    // Sort by MRR (descending)
    usort($mrrByPlan, function ($a, $b) {
        return $b['mrr'] <=> $a['mrr'];
    });

    return $mrrByPlan;
}

/**
 * Get customer count by plan
 */
private function getCustomerCountByPlan(): array
{
    $plans = SubscriptionPlan::withCount('activeSubscriptions')->get();

    return $plans->map(function ($plan) {
        return [
            'plan_id' => $plan->id,
            'plan_name' => $plan->name,
            'customer_count' => $plan->active_subscriptions_count,
            'percentage' => 0 // Will be calculated below
        ];
    })->toArray();
}

/**
 * Get MRR trend
 */
private function getMRRTrend(int $months): array
{
    $trend = [];
    $currentDate = Carbon::now()->startOfMonth();

    for ($i = 0; $i < $months; $i++) {
        $monthDate = $currentDate->copy()->subMonths($i);
        $mrr = $this->calculateMRR($monthDate);

        $trend[] = [
            'month' => $monthDate->format('Y-m'),
            'month_name' => $monthDate->format('F Y'),
            'mrr' => round($mrr, 2),
            'arr' => round($mrr * 12, 2)
        ];
    }

    return array_reverse($trend);
}

/**
 * Get churn analysis
 */
private function getChurnAnalysis(Carbon $date): array
{
    $startOfMonth = $date->copy()->startOfMonth();
    $previousMonth = $date->copy()->subMonth()->startOfMonth();

    $currentCustomers = Company::whereHas('invoices', function ($query) use ($startOfMonth) {
        $query->where('type', 'subscription')
              ->where('status', 'paid')
              ->where('payment_date', '>=', $startOfMonth);
    })->count();

    $previousCustomers = Company::whereHas('invoices', function ($query) use ($previousMonth) {
        $query->where('type', 'subscription')
              ->where('status', 'paid')
              ->where('payment_date', '>=', $previousMonth)
              ->where('payment_date', '<', $startOfMonth);
    })->count();

    $churnedCustomers = $previousCustomers - $currentCustomers;
    $churnRate = $previousCustomers > 0 ? ($churnedCustomers / $previousCustomers) * 100 : 0;

    return [
        'current_customers' => $currentCustomers,
        'previous_customers' => $previousCustomers,
        'churned_customers' => $churnedCustomers,
        'churn_rate_percentage' => round($churnRate, 2),
        'retention_rate_percentage' => round(100 - $churnRate, 2)
    ];
}
}
