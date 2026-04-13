<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Company;
use App\Models\Subscription;
use App\Models\Payment;
use App\Services\RevenueService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class AdminRevenueController extends Controller
{
    protected $revenueService;

    public function __construct(RevenueService $revenueService)
    {
        $this->revenueService = $revenueService;
    }

    /**
     * Get platform revenue summary
     */
    public function getPlatformRevenueSummary(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'group_by' => 'nullable|string|in:day,week,month,quarter,year',
            'company_type' => 'nullable|string|max:50',
            'plan_type' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 422);
        }

        try {
            $startDate = $request->start_date ?? Carbon::now()->subDays(30)->toDateString();
            $endDate = $request->end_date ?? Carbon::now()->toDateString();
            $groupBy = $request->get('group_by', 'month');

            // Get revenue data
            $revenueData = $this->revenueService->getRevenueSummary(
                $startDate,
                $endDate,
                $groupBy,
                $request->company_type,
                $request->plan_type
            );

            return response()->json([
                'success' => true,
                'data' => [
                    'period' => [
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                        'group_by' => $groupBy,
                    ],
                    'summary' => $revenueData['summary'],
                    'trend' => $revenueData['trend'],
                    'breakdown' => $revenueData['breakdown'],
                ],
                'message' => 'Platform revenue summary retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve revenue summary',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Get revenue by company
     */
    public function getRevenueByCompany(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'company_type' => 'nullable|string|max:50',
            'plan_type' => 'nullable|string|max:50',
            'sort_by' => 'nullable|string|in:revenue,invoice_count,average_amount',
            'sort_order' => 'nullable|string|in:asc,desc',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 422);
        }

        try {
            $startDate = $request->start_date ?? Carbon::now()->subDays(30)->toDateString();
            $endDate = $request->end_date ?? Carbon::now()->toDateString();
            $sortBy = $request->get('sort_by', 'revenue');
            $sortOrder = $request->get('sort_order', 'desc');
            $limit = $request->get('limit', 20);

            // Get revenue by company
            $revenueByCompany = $this->revenueService->getRevenueByCompany(
                $startDate,
                $endDate,
                $request->company_type,
                $request->plan_type,
                $sortBy,
                $sortOrder,
                $limit
            );

            // Calculate totals
            $totalRevenue = array_sum(array_column($revenueByCompany, 'total_revenue'));
            $totalInvoices = array_sum(array_column($revenueByCompany, 'invoice_count'));
            $averageRevenue = count($revenueByCompany) > 0 ? $totalRevenue / count($revenueByCompany) : 0;

            return response()->json([
                'success' => true,
                'data' => [
                    'period' => [
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                    ],
                    'companies' => $revenueByCompany,
                    'summary' => [
                        'total_companies' => count($revenueByCompany),
                        'total_revenue' => (float) $totalRevenue,
                        'total_invoices' => $totalInvoices,
                        'average_revenue_per_company' => (float) $averageRevenue,
                        'top_company_revenue' => count($revenueByCompany) > 0
                            ? (float) $revenueByCompany[0]['total_revenue']
                            : 0,
                    ],
                ],
                'message' => 'Revenue by company retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve revenue by company',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Generate financial report
     */
    public function generateFinancialReport(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'report_type' => 'required|string|in:profit_loss,revenue_summary,tax_summary,cash_flow,balance_sheet',
            'include_details' => 'nullable|boolean',
            'format' => 'nullable|string|in:json,pdf,csv',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 422);
        }

        try {
            $startDate = $request->start_date;
            $endDate = $request->end_date;
            $reportType = $request->report_type;
            $includeDetails = $request->get('include_details', true);
            $format = $request->get('format', 'json');

            // Generate report based on type
            $reportData = $this->revenueService->generateFinancialReport(
                $startDate,
                $endDate,
                $reportType,
                $includeDetails
            );

            // Add report metadata
            $reportData['metadata'] = [
                'report_type' => $reportType,
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ],
                'generated_at' => now()->toISOString(),
                'generated_by' => auth()->id(),
                'format' => $format,
            ];

            // Handle different formats
            if ($format === 'pdf') {
                // TODO: Implement PDF generation
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'FEATURE_NOT_IMPLEMENTED',
                        'message' => 'PDF export not yet implemented',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => $request->header('X-Request-ID'),
                ], 501);
            } elseif ($format === 'csv') {
                // TODO: Implement CSV generation
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'FEATURE_NOT_IMPLEMENTED',
                        'message' => 'CSV export not yet implemented',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => $request->header('X-Request-ID'),
                ], 501);
            }

            return response()->json([
                'success' => true,
                'data' => $reportData,
                'message' => 'Financial report generated successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'REPORT_GENERATION_FAILED',
                    'message' => 'Failed to generate financial report',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Get MRR/ARR metrics
     */
    public function getRecurringRevenueMetrics(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'metric_type' => 'nullable|string|in:mrr,arr,churn,growth',
            'plan_type' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 422);
        }

        try {
            $startDate = $request->start_date ?? Carbon::now()->subMonths(12)->toDateString();
            $endDate = $request->end_date ?? Carbon::now()->toDateString();
            $metricType = $request->get('metric_type', 'mrr');

            // Get recurring revenue metrics
            $metrics = $this->revenueService->getRecurringRevenueMetrics(
                $startDate,
                $endDate,
                $metricType,
                $request->plan_type
            );

            return response()->json([
                'success' => true,
                'data' => [
                    'period' => [
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                    ],
                    'metric_type' => $metricType,
                    'metrics' => $metrics,
                ],
                'message' => 'Recurring revenue metrics retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve recurring revenue metrics',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Get revenue forecast
     */
    public function getRevenueForecast(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'forecast_period' => 'nullable|string|in:month,quarter,year',
            'periods_ahead' => 'nullable|integer|min:1|max:12',
            'confidence_level' => 'nullable|numeric|min:0.5|max:0.99',
            'include_scenarios' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 422);
        }

        try {
            $forecastPeriod = $request->get('forecast_period', 'month');
            $periodsAhead = $request->get('periods_ahead', 3);
            $confidenceLevel = $request->get('confidence_level', 0.95);
            $includeScenarios = $request->get('include_scenarios', false);

            // Get revenue forecast
            $forecast = $this->revenueService->getRevenueForecast(
                $forecastPeriod,
                $periodsAhead,
                $confidenceLevel,
                $includeScenarios
            );

            return response()->json([
                'success' => true,
                'data' => [
                    'forecast_period' => $forecastPeriod,
                    'periods_ahead' => $periodsAhead,
                    'confidence_level' => $confidenceLevel,
                    'forecast' => $forecast,
                ],
                'message' => 'Revenue forecast generated successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'FORECAST_FAILED',
                    'message' => 'Failed to generate revenue forecast',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Get tax summary
     */
    public function getTaxSummary(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'tax_type' => 'nullable|string|max:50',
            'company_id' => 'nullable|uuid|exists:companies,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 422);
        }

        try {
            $startDate = $request->start_date ?? Carbon::now()->subMonths(3)->toDateString();
            $endDate = $request->end_date ?? Carbon::now()->toDateString();

            // Get tax summary
            $taxSummary = $this->revenueService->getTaxSummary(
                $startDate,
                $endDate,
                $request->tax_type,
                $request->company_id
            );

            return response()->json([
                'success' => true,
                'data' => [
                    'period' => [
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                    ],
                    'tax_summary' => $taxSummary,
                ],
                'message' => 'Tax summary retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve tax summary',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Export revenue data
     */
    public function exportRevenueData(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'export_type' => 'required|string|in:invoices,payments,revenue,tax',
            'format' => 'required|string|in:csv,excel,pdf',
            'include_columns' => 'nullable|array',
            'filters' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Validation failed',
                    'details' => $validator->errors(),
                ],
                '
