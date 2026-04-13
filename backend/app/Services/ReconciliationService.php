<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Invoice;
use App\Models\Company;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class ReconciliationService
{
    /**
     * Get payment reconciliation data
     */
    public function getPaymentReconciliation(array $filters = []): array
    {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        // Get all payments in the date range
        $payments = Payment::whereBetween('payment_date', [$startDate, $endDate])
            ->with(['invoice'])
            ->orderBy('payment_date', 'desc')
            ->get();

        // Categorize payments by reconciliation status
        $categorizedPayments = [
            'reconciled' => [],
            'pending' => [],
            'discrepancy' => [],
            'unmatched' => []
        ];

        $summary = [
            'total_payments' => 0,
            'total_amount' => 0,
            'reconciled_amount' => 0,
            'pending_amount' => 0,
            'discrepancy_amount' => 0,
            'unmatched_amount' => 0
        ];

        foreach ($payments as $payment) {
            $status = $payment->metadata['reconciliation_status'] ?? 'pending';
            $category = $this->mapReconciliationStatus($status);

            $paymentData = [
                'id' => $payment->id,
                'invoice_id' => $payment->invoice_id,
                'invoice_number' => $payment->invoice->invoice_number ?? 'N/A',
                'amount' => (float) $payment->amount,
                'currency' => $payment->currency,
                'method' => $payment->method,
                'reference' => $payment->reference,
                'payment_date' => $payment->payment_date->toDateString(),
                'reconciliation_status' => $status,
                'reconciliation_notes' => $payment->metadata['reconciliation_notes'] ?? null,
                'created_at' => $payment->created_at->toDateTimeString()
            ];

            $categorizedPayments[$category][] = $paymentData;

            // Update summary
            $summary['total_payments']++;
            $summary['total_amount'] += $payment->amount;

            switch ($category) {
                case 'reconciled':
                    $summary['reconciled_amount'] += $payment->amount;
                    break;
                case 'pending':
                    $summary['pending_amount'] += $payment->amount;
                    break;
                case 'discrepancy':
                    $summary['discrepancy_amount'] += $payment->amount;
                    break;
                case 'unmatched':
                    $summary['unmatched_amount'] += $payment->amount;
                    break;
            }
        }

        // Calculate percentages
        $summary['reconciled_percentage'] = $summary['total_amount'] > 0 ?
            round(($summary['reconciled_amount'] / $summary['total_amount']) * 100, 2) : 0;
        $summary['pending_percentage'] = $summary['total_amount'] > 0 ?
            round(($summary['pending_amount'] / $summary['total_amount']) * 100, 2) : 0;
        $summary['discrepancy_percentage'] = $summary['total_amount'] > 0 ?
            round(($summary['discrepancy_amount'] / $summary['total_amount']) * 100, 2) : 0;
        $summary['unmatched_percentage'] = $summary['total_amount'] > 0 ?
            round(($summary['unmatched_amount'] / $summary['total_amount']) * 100, 2) : 0;

        // Get gateway transactions for comparison
        $gatewayTransactions = $this->getGatewayTransactions($startDate, $endDate);

        // Identify potential matches
        $potentialMatches = $this->identifyPotentialMatches($categorizedPayments['unmatched'], $gatewayTransactions);

        // Get reconciliation statistics by payment method
        $statsByPaymentMethod = $this->getReconciliationStatsByPaymentMethod($startDate, $endDate);

        // Get aging analysis
        $agingAnalysis = $this->getAgingAnalysis($categorizedPayments['pending']);

        return [
            'period' => [
                'start' => $startDate->toDateString(),
                'end' => $endDate->toDateString(),
                'days' => $startDate->diffInDays($endDate)
            ],
            'summary' => $summary,
            'categorized_payments' => $categorizedPayments,
            'gateway_transactions' => $gatewayTransactions,
            'potential_matches' => $potentialMatches,
            'statistics_by_payment_method' => $statsByPaymentMethod,
            'aging_analysis' => $agingAnalysis,
            'reconciliation_health' => $this->calculateReconciliationHealth($summary),
            'recommended_actions' => $this->getRecommendedActions($categorizedPayments, $summary)
        ];
    }

    /**
     * Reconcile payments with gateway transactions
     */
    public function reconcilePayments(array $reconciliationData): array
    {
        DB::beginTransaction();

        try {
            $results = [
                'successful' => [],
                'failed' => [],
                'discrepancies_found' => 0,
                'total_reconciled_amount' => 0
            ];

            foreach ($reconciliationData['matches'] as $match) {
                try {
                    $payment = Payment::findOrFail($match['payment_id']);
                    $gatewayTransaction = $match['gateway_transaction'];

                    // Validate match
                    $validationResult = $this->validateReconciliationMatch($payment, $gatewayTransaction);

                    if (!$validationResult['valid']) {
                        throw new \Exception($validationResult['message']);
                    }

                    // Check for discrepancies
                    $discrepancy = $this->checkForDiscrepancies($payment, $gatewayTransaction);

                    if ($discrepancy['has_discrepancy']) {
                        $results['discrepancies_found']++;
                        $reconciliationStatus = 'discrepancy';
                        $notes = "Discrepancy found: " . implode(', ', $discrepancy['issues']);
                    } else {
                        $reconciliationStatus = 'reconciled';
                        $notes = "Successfully reconciled with gateway transaction";
                    }

                    // Update payment metadata
                    $metadata = $payment->metadata ?? [];
                    $metadata['reconciliation_status'] = $reconciliationStatus;
                    $metadata['reconciliation_date'] = Carbon::now()->toISOString();
                    $metadata['reconciliation_notes'] = $notes;
                    $metadata['gateway_transaction_id'] = $gatewayTransaction['id'];
                    $metadata['gateway_fee'] = $gatewayTransaction['fee'] ?? null;
                    $metadata['gateway_net_amount'] = $gatewayTransaction['net_amount'] ?? null;
                    $metadata['reconciled_by'] = $reconciliationData['reconciled_by'] ?? null;

                    $payment->update(['metadata' => $metadata]);

                    // If reconciled, update invoice if needed
                    if ($reconciliationStatus === 'reconciled' && $payment->invoice) {
                        $this->updateInvoiceAfterReconciliation($payment->invoice, $payment);
                    }

                    $results['successful'][] = [
                        'payment_id' => $payment->id,
                        'invoice_number' => $payment->invoice->invoice_number ?? 'N/A',
                        'amount' => $payment->amount,
                        'reconciliation_status' => $reconciliationStatus,
                        'discrepancy' => $discrepancy['has_discrepancy'],
                        'discrepancy_details' => $discrepancy['issues'] ?? []
                    ];

                    if ($reconciliationStatus === 'reconciled') {
                        $results['total_reconciled_amount'] += $payment->amount;
                    }

                    Log::info("Payment reconciled", [
                        'payment_id' => $payment->id,
                        'reconciliation_status' => $reconciliationStatus,
                        'discrepancy' => $discrepancy['has_discrepancy']
                    ]);

                } catch (\Exception $e) {
                    $results['failed'][] = [
                        'payment_id' => $match['payment_id'] ?? 'unknown',
                        'error' => $e->getMessage()
                    ];
                }
            }

            // Process unmatched transactions
            if (!empty($reconciliationData['unmatched_transactions'])) {
                $this->processUnmatchedTransactions($reconciliationData['unmatched_transactions']);
            }

            DB::commit();

            Log::info("Reconciliation completed", [
                'total_matches' => count($reconciliationData['matches']),
                'successful' => count($results['successful']),
                'failed' => count($results['failed']),
                'discrepancies_found' => $results['discrepancies_found'],
                'total_reconciled_amount' => $results['total_reconciled_amount']
            ]);

            return $results;

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Reconciliation failed: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Analyze reconciliation for discrepancies
     */
    public function analyzeReconciliation(array $filters = []): array
    {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        // Get payments with discrepancies
        $payments = Payment::whereBetween('payment_date', [$startDate, $endDate])
            ->with(['invoice'])
            ->get();

        $discrepantPayments = $payments->filter(function ($payment) {
            $status = $payment->metadata['reconciliation_status'] ?? 'pending';
            return $status === 'discrepancy';
        });

        $analysis = [
            'total_discrepancies' => $discrepantPayments->count(),
            'total_discrepant_amount' => $discrepantPayments->sum('amount'),
            'discrepancy_types' => [],
            'by_payment_method' => [],
            'trend' => []
        ];

        // Categorize discrepancies
        foreach ($discrepantPayments as $payment) {
            $notes = $payment->metadata['reconciliation_notes'] ?? '';

            // Parse discrepancy type from notes
            $type = $this->parseDiscrepancyType($notes);

            if (!isset($analysis['discrepancy_types'][$type])) {
                $analysis['discrepancy_types'][$type] = [
                    'count' => 0,
                    'total_amount' => 0,
                    'payments' => []
                ];
            }

            $analysis['discrepancy_types'][$type]['count']++;
            $analysis['discrepancy_types'][$type]['total_amount'] += $payment->amount;
            $analysis['discrepancy_types'][$type]['payments'][] = [
                'id' => $payment->id,
                'amount' => $payment->amount,
                'notes' => $notes
            ];

            // Group by payment method
            $method = $payment->method;
            if (!isset($analysis['by_payment_method'][$method])) {
                $analysis['by_payment_method'][$method] = [
                    'count' => 0,
                    'total_amount' => 0
                ];
            }
            $analysis['by_payment_method'][$method]['count']++;
            $analysis['by_payment_method'][$method]['total_amount'] += $payment->amount;
        }

        // Sort discrepancy types by count (descending)
        uasort($analysis['discrepancy_types'], function ($a, $b) {
            return $b['count'] <=> $a['count'];
        });

        // Get trend of discrepancies over time
        $analysis['trend'] = $this->getDiscrepancyTrend($startDate, $endDate);

        // Calculate impact metrics
        $totalPayments = $payments->count();
        $totalAmount = $payments->sum('amount');

        $analysis['impact_metrics'] = [
            'discrepancy_rate_percentage' => $totalPayments > 0 ?
                round(($analysis['total_discrepancies'] / $totalPayments) * 100, 2) : 0,
            'amount_at_risk_percentage' => $totalAmount > 0 ?
                round(($analysis['total_discrepant_amount'] / $totalAmount) * 100, 2) : 0,
            'average_discrepancy_amount' => $analysis['total_discrepancies'] > 0 ?
                round($analysis['total_discrepant_amount'] / $analysis['total_discrepancies'], 2) : 0
        ];

        // Get root cause analysis
        $analysis['root_causes'] = $this->analyzeRootCauses($discrepantPayments);

        // Get recommendations
        $analysis['recommendations'] = $this->generateDiscrepancyRecommendations($analysis);

        return $analysis;
    }

    /**
     * Resolve reconciliation discrepancy
     */
    public function resolveDiscrepancy(string $paymentId, array $resolutionData): Payment
    {
        DB::beginTransaction();

        try {
            $payment = Payment::with('invoice')->findOrFail($paymentId);

            $currentStatus = $payment->metadata['reconciliation_status'] ?? 'pending';
            if ($currentStatus !== 'discrepancy') {
                throw new \Exception("Payment is not in discrepancy status");
            }

            // Validate resolution
            $this->validateDiscrepancyResolution($payment, $resolutionData);

            // Apply resolution
            $metadata = $payment->metadata ?? [];
            $metadata['reconciliation_status'] = 'reconciled';
            $metadata['reconciliation_date'] = Carbon::now()->toISOString();
            $metadata['reconciliation_notes'] = $this->buildResolutionNotes($payment, $resolutionData);
            $metadata['resolved_by'] = $resolutionData['resolved_by'] ?? null;
            $metadata['resolution_method'] = $resolutionData['resolution_method'];
            $metadata['resolution_notes'] = $resolutionData['resolution_notes'] ?? null;

            // Handle amount adjustments if needed
            if ($resolutionData['resolution_method'] === 'adjust_payment_amount') {
                $adjustment = $resolutionData['adjustment_amount'] ?? 0;
                $payment->amount += $adjustment;
                $metadata['adjustment_amount'] = $adjustment;
                $metadata['adjustment_reason'] = $resolutionData['adjustment_reason'] ?? null;

                // Create adjustment record
                $this->createAdjustmentRecord($payment, $adjustment, $resolutionData);
            }

            // Update payment
            $payment->metadata = $metadata;
            $payment->save();

            // Update invoice if needed
            if ($payment->invoice && $resolutionData['resolution_method'] === 'adjust_payment_amount') {
                $this->updateInvoiceAfterAdjustment($payment->invoice, $payment);
            }

            DB::commit();

            Log::info("Discrepancy resolved for payment {$paymentId}", [
                'payment_id' => $paymentId,
                'resolution_method' => $resolutionData['resolution_method'],
                'resolved_by' => $resolutionData['resolved_by'] ?? 'system'
            ]);

            return $payment->fresh();

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to resolve discrepancy for payment {$paymentId}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get reconciliation report
     */
    public function generateReconciliationReport(array $options = []): array
    {
        $dateRange = $this->parseDateRange($options);
        $startDate = $dateRange['start'];
        $endDate = $dateRange['end'];

        $reportType = $options['type'] ?? 'detailed';

        switch ($reportType) {
            case 'summary':
                return $this->generateSummaryReport($startDate, $endDate);
            case 'detailed':
                return $this->generateDetailedReport($startDate, $endDate);
            case 'discrepancy':
                return $this->generateDiscrepancyReport($startDate, $endDate);
            case 'aging':
                return $this->generateAgingReport($startDate, $endDate);
            default:
                throw new \Exception("Unsupported report type: {$reportType}");
        }
    }

    /**
     * Map reconciliation status to category
     */
    private function mapReconciliationStatus(string $status): string
    {
        $statusMap = [
            'reconciled' => 'reconciled',
            'pending' => 'pending',
            'discrepancy' => 'discrepancy',
            'unmatched' => 'unmatched',
            'partially_reconciled' => 'discrepancy',
            'failed' => 'discrepancy'
        ];

        return $statusMap[$status] ?? 'pending';
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
     * Get gateway transactions (mock implementation)
     */
    private function getGatewayTransactions(Carbon $startDate, Carbon $endDate): array
    {
        // This would typically integrate with payment gateway API
        // For now, return empty array
        return [];
    }

    /**
     * Identify potential matches
     */
    private function identifyPotentialMatches(array $unmatchedPayments, array $gatewayTransactions): array
    {
        $potentialMatches = [];

        foreach ($unmatchedPayments as $payment) {
            foreach ($gatewayTransactions as $transaction) {
                if ($this->isPotentialMatch($payment, $transaction)) {
                    $potentialMatches[] = [
                        'payment' => $payment,
                        'transaction' => $transaction,
                        'match_score' => $this->calculateMatchScore($payment, $transaction)
                    ];
                }
            }
        }

        return $potentialMatches;
    }

    /**
     * Check if payment and transaction are potential match
     */
    private function isPotentialMatch(array $payment, array $transaction): bool
    {
        // Check amount match (within 1% tolerance)
        $amountDiff = abs($payment['amount'] - $transaction['amount']);
        $amountTolerance = $payment['amount'] * 0.01;

        if ($amountDiff > $amountTolerance) {
            return false;
        }

        // Check date match (within 2 days)
        $paymentDate = Carbon::parse($payment['payment_date']);
        $transactionDate = Carbon::parse($transaction['date']);
        $dateDiff = $paymentDate->diffInDays($transactionDate);

        if ($dateDiff > 2) {
            return false;
        }

        // Check reference match if available
        if (!empty($payment['reference']) && !empty($transaction['reference'])) {
            if (strpos($payment['reference'], $transaction['reference']) !== false ||
                strpos($transaction['reference'], $payment['reference']) !== false) {
                return true;
            }
        }

        // Default to true if amount and date are close
        return true;
    }

    /**
     * Calculate match score
     */
    private function calculateMatchScore(array $payment, array $transaction): float
    {
        $score = 0.0;

        // Amount match (40% weight)
        $amountDiff = abs($payment['amount'] - $transaction['amount']);
        $amountScore = max(0, 1 - ($amountDiff / $payment['amount']));
        $score += $amountScore * 0.4;

        // Date match (30% weight)
        $paymentDate = Carbon::parse($payment['payment_date']);
        $transactionDate = Carbon::parse($transaction['date']);
        $dateDiff = $paymentDate->diffInDays($transactionDate);
        $dateScore = max(0, 1 - ($dateDiff / 7)); // 7 days max
        $score += $dateScore * 0.3;

        // Reference match (30% weight)
        $referenceScore = 0.0;
        if (!empty($payment['reference']) && !empty($transaction['reference'])) {
            if ($payment['reference'] === $transaction['reference']) {
                $referenceScore = 1.0;
            } elseif (strpos($payment['reference'], $transaction['reference']) !== false ||
                     strpos($transaction['reference'], $payment['reference']) !== false) {
                $referenceScore = 0.7;
            }
        }
        $score += $referenceScore * 0.3;

        return round($score, 2);
    }

    /**
     * Get reconciliation statistics by payment method
     */
    private function getReconciliationStatsByPaymentMethod(Carbon $startDate, Carbon $endDate): array
    {
        $payments = Payment::whereBetween('payment_date', [$startDate, $endDate])->get();

        $stats = [];
        foreach ($payments as $payment) {
            $method = $payment->method;
            $status = $payment->metadata['reconciliation_status'] ?? 'pending';

            if (!isset($stats[$method])) {
                $stats[$method] = [
                    'total_count' => 0,
                    'total_amount' => 0,
                    'reconciled_count' => 0,
                    'reconciled_amount' => 0,
                    'pending_count' => 0,
                    'pending_amount' => 0,
                    'discrepancy_count' => 0,
                    'discrepancy_amount' => 0
                ];
            }

            $stats[$method]['total_count']++;
            $stats[$method]['total_amount'] += $payment->amount;

            switch ($status) {
                case 'reconciled':
                    $stats[$method]['reconciled_count']++;
                    $stats[$method]['reconciled_amount'] += $payment->amount;
                    break;
                case 'pending':
                    $stats[$method]['pending_count']++;
                    $stats[$method]['pending_amount'] += $payment->amount;
                    break;
                case 'discrepancy':
                    $stats[$method]['discrepancy_count']++;
                    $stats[$method]['discrepancy_amount'] += $payment->amount;
                    break;
            }
        }

        // Calculate percentages
        foreach ($stats as $method => &$data) {
            $data['reconciled_percentage'] = $data['total_count'] > 0 ?
                round(($data['reconciled_count'] / $data['total_count']) * 100, 2) : 0;
            $data['pending_percentage'] = $data['total_count'] > 0 ?
                round(($data['pending_count'] / $data['total_count']) * 100, 2) : 0;
            $data['discrepancy_percentage'] = $data['total_count'] > 0 ?
                round(($data['discrepancy_count'] / $data['total_count']) * 100, 2) : 0;
        }

        return $stats;
    }

    /**
     * Get aging analysis
     */
    private function getAgingAnalysis(array $pendingPayments): array
    {
        $agingBuckets = [
            '0-7_days' => ['count' => 0, 'amount' => 0],
            '8-30_days' => ['count' => 0, 'amount' => 0],
            '31-60_days' => ['count' => 0, 'amount' => 0],
            '61-90_days' => ['count' => 0, 'amount' => 0],
            'over_90_days' => ['count' => 0, 'amount' => 0]
        ];

        $now = Carbon::now();

        foreach ($pendingPayments as $payment) {
            $paymentDate = Carbon::parse($payment['payment_date']);
            $daysOld = $now->diffInDays($paymentDate);

            if ($daysOld <= 7) {
                $bucket = '0-7_days';
            } elseif ($daysOld <= 30) {
                $bucket = '8-30_days';
            } elseif ($daysOld <= 60) {
                $bucket = '31-60_days';
            } elseif ($daysOld <= 90) {
                $bucket = '61-90_days';
            } else {
                $bucket = 'over_90_days';
            }

            $agingBuckets[$bucket]['count']++;
            $agingBuckets[$bucket]['amount'] += $payment['amount'];
        }

        return $agingBuckets;
    }

    /**
     * Calculate reconciliation health
     */
    private function calculateReconciliationHealth(array $summary): array
    {
        $reconciledPercentage = $summary['reconciled_percentage'];
        $pendingPercentage = $summary['pending_percentage'];
        $discrepancyPercentage = $summary['discrepancy_percentage'];

        // Determine health status
        if ($reconciledPercentage >= 95 && $discrepancyPercentage <= 2) {
            $status = 'excellent';
            $color = 'green';
        } elseif ($reconciledPercentage >= 90 && $discrepancyPercentage <= 5) {
            $status = 'good';
            $color = 'blue';
        } elseif ($reconciledPercentage >= 80 && $discrepancyPercentage <= 10) {
            $status = 'fair';
            $color = 'yellow';
        } elseif ($reconciledPercentage >= 70 && $discrepancyPercentage <= 15) {
            $status = 'poor';
            $color = 'orange';
        } else {
            $status = 'critical';
            $color = 'red';
        }

        return [
            'status' => $status,
            'color' => $color,
            'score' => round($reconciledPercentage - ($discrepancyPercentage * 2), 2),
            'metrics' => [
                'reconciled_percentage' => $reconciledPercentage,
                'pending_percentage' => $pendingPercentage,
                'discrepancy_percentage' => $discrepancyPercentage
            ]
        ];
    }

    /**
     * Get recommended actions
     */
    private function getRecommendedActions(array $categorizedPayments, array $summary): array
    {
        $recommendations = [];

        // Check for old pending payments
        $pendingCount = count($categorizedPayments['pending']);
        if ($pendingCount > 10) {
            $recommendations[] = [
                'priority' => 'high',
                'action' => 'Review pending payments',
                'description' => "There are {$pendingCount} pending payments that need reconciliation",
                'suggested_deadline' => Carbon::now()->addDays(3)->toDateString()
            ];
        }

        // Check for discrepancies
        $discrepancyCount = count($categorizedPayments['discrepancy']);
        if ($discrepancyCount > 0) {
            $recommendations[] = [
                'priority' => 'critical',
                'action' => 'Resolve discrepancies',
                'description' => "There are {$discrepancyCount} payments with discrepancies totaling {$summary['discrepancy_amount']}",
                'suggested_deadline' => Carbon::now()->addDays(1)->toDateString()
            ];
        }

        // Check reconciliation rate
        if ($summary['reconciled_percentage'] < 90) {
            $recommendations[] = [
                'priority' => 'medium',
                'action' => 'Improve reconciliation process',
                'description' => "Current reconciliation rate is {$summary['reconciled_percentage']}%, target is 95%",
                'suggested_deadline' => Carbon::now()->addDays(7)->toDateString()
            ];
        }

        return $recommendations;
    }

    /**
     * Validate reconciliation match
     */
    private function validateReconciliationMatch(Payment $payment, array $transaction): array
    {
        $issues = [];

        // Check amount
        $amountDiff = abs($payment->amount - $transaction['amount']);
        if ($amountDiff > 0.01) {
            $issues[] = "Amount mismatch: payment {$payment->amount} vs transaction {$transaction['amount']}";
        }

        // Check currency
        if ($payment->currency !== $transaction['currency']) {
            $issues[] = "Currency mismatch: {$payment->currency} vs {$transaction['currency']}";
        }

        // Check date (within reasonable range)
        $paymentDate = Carbon::parse($payment->payment_date);
        $transactionDate = Carbon::parse($transaction['date']);
        $dateDiff = $paymentDate->diffInDays($transactionDate);

        if ($dateDiff > 3) {
            $issues[] = "Date mismatch: {$dateDiff} days difference";
        }

        return [
            'valid' => empty($issues),
            'message' => empty($issues) ? 'Valid match' : implode(', ', $issues),
            'issues' => $issues
        ];
    }

    /**
     * Check for discrepancies
     */
    private function checkForDiscrepancies(Payment $payment, array $transaction): array
    {
        $issues = [];

        // Amount discrepancy
        $amountDiff = abs($payment->amount - $transaction['amount']);
        if ($amountDiff > 0.01) {
            $issues[] = "Amount discrepancy: {$amountDiff} difference";
        }

        // Gateway fee check
        if (isset($transaction['fee']) && $transaction['fee'] > $payment->amount * 0.05) {
            $issues[] = "High gateway fee: {$transaction['fee']} ({round(($transaction['fee'] / $payment->amount) * 100, 2)}%)";
        }

        return [
            'has_discrepancy' => !empty($issues),
            'issues' => $issues
        ];
    }

    /**
     * Update invoice after reconciliation
     */
    private function updateInvoiceAfterReconciliation(Invoice $invoice, Payment $payment): void
    {
        // Update invoice metadata with reconciliation info
        $metadata = $invoice->metadata ?? [];
        $metadata['last_reconciliation_date'] = Carbon::now()->toISOString();
        $metadata['reconciled_payment_ids'] = array_merge(
            $metadata['reconciled_payment_ids'] ?? [],
            [$payment->id]
        );

        $invoice->update(['metadata' => $metadata]);
    }

    /**
     * Process unmatched transactions
     */
    private function processUnmatchedTransactions(array $transactions): void
    {
        foreach ($transactions as $transaction) {
            // Create payment record for unmatched transaction
            Payment::create([
                'id' => \Illuminate\Support\Str::uuid()->toString(),
                'invoice_id' => null,
                'amount' => $transaction['amount'],
                'currency' => $transaction['currency'],
                'method' => $transaction['method'] ?? 'unknown',
                'payment_date' => Carbon::parse($transaction['date']),
                'reference' => $transaction['reference'] ?? null,
                'transaction_id' => $transaction['id'],
                'notes' => 'Unmatched gateway transaction',
                'metadata' => [
                    'reconciliation_status' => 'unmatched',
                    'gateway_transaction_id' => $transaction['id'],
                    'gateway_data' => $transaction
                ]
            ]);
        }
    }

    /**
     * Parse discrepancy type from notes
     */
    private function parseDiscrepancyType(string $notes): string
    {
        if (stripos($notes, 'amount') !== false) {
            return 'amount_mismatch';
        } elseif (stripos($notes, 'currency') !== false) {
            return 'currency_mismatch';
        } elseif (stripos($notes, 'date') !== false) {
            return 'date_mismatch';
        } elseif (stripos($notes, 'fee') !== false) {
            return 'high_fee';
        } elseif (stripos($notes, 'reference') !== false) {
            return 'reference_mismatch';
        } else {
            return 'other';
        }
    }

    /**
     * Get discrepancy trend
     */
    private function getDiscrepancyTrend(Carbon $startDate, Carbon $endDate): array
    {
        $trend = [];
        $currentDate = $startDate->copy();

        while ($currentDate <= $endDate) {
            $periodEnd = $currentDate->copy()->addDays(6)->endOfDay();
            if ($periodEnd > $endDate) {
                $periodEnd = $endDate;
            }

            $payments = Payment::whereBetween('payment_date', [$currentDate, $periodEnd])->get();

            $discrepantCount = $payments->filter(function ($payment) {
                $status = $payment->metadata['reconciliation_status'] ?? 'pending';
                return $status === 'discrepancy';
            })->count();

            $trend[] = [
                'period' => $currentDate->format('Y-m-d'),
                'period_label' => $currentDate->format('M d') . ' - ' . $periodEnd->format('M d'),
                'total_payments' => $payments->count(),
                'discrepant_payments' => $discrepantCount,
                'discrepancy_rate' => $payments->count() > 0 ? round(($discrepantCount / $payments->count()) * 100, 2) : 0
            ];

            $currentDate = $periodEnd->copy()->addDay()->startOfDay();
        }

        return $trend;
    }

    /**
     * Analyze root causes
     */
    private function analyzeRootCauses(Collection $discrepantPayments): array
    {
        $rootCauses = [
            'data_entry_errors' => ['count' => 0, 'examples' => []],
            'gateway_issues' => ['count' => 0, 'examples' => []],
            'timing_differences' => ['count' => 0, 'examples' => []],
            'system_errors' => ['count' => 0, 'examples' => []],
            'unknown' => ['count' => 0, 'examples' => []]
        ];

        foreach ($discrepantPayments as $payment) {
            $notes = $payment->metadata['reconciliation_notes'] ?? '';
            $type = $this->parseDiscrepancyType($notes);

            switch ($type) {
                case 'amount_mismatch':
                case 'reference_mismatch':
                    $rootCauses['data_entry_errors']['count']++;
                    $rootCauses['data_entry_errors']['examples'][] = [
                        'payment_id' => $payment->id,
                        'issue' => $type,
                        'notes' => $notes
                    ];
                    break;
                case 'high_fee':
                    $rootCauses['gateway_issues']['count']++;
                    $rootCauses['gateway_issues']['examples'][] = [
                        'payment_id' => $payment->id,
                        'issue' => $type,
                        'notes' => $notes
                    ];
                    break;
                case 'date_mismatch':
                    $rootCauses['timing_differences']['count']++;
                    $rootCauses['timing_differences']['examples'][] = [
                        'payment_id' => $payment->id,
                        'issue' => $type,
                        'notes' => $notes
                    ];
                    break;
                case 'currency_mismatch':
                    $rootCauses['system_errors']['count']++;
                    $rootCauses['system_errors']['examples'][] = [
                        'payment_id' => $payment->id,
                        'issue' => $type,
                        'notes' => $notes
                    ];
                    break;
                default:
                    $rootCauses['unknown']['count']++;
                    $rootCauses['unknown']['examples'][] = [
                        'payment_id' => $payment->id,
                        'issue' => $type,
                        'notes' => $notes
                    ];
                    break;
            }
        }

        return $rootCauses;
    }

    /**
     * Generate discrepancy recommendations
     */
    private function generateDiscrepancyRecommendations(array $analysis): array
    {
        $recommendations = [];

        // Data entry errors
        if ($analysis['discrepancy_types']['amount_mismatch']['count'] ?? 0 > 0) {
            $recommendations[] = [
                'priority' => 'high',
                'action' => 'Implement amount validation',
                'description' => 'Add real-time amount validation during payment entry',
                'estimated_effort' => '2 days'
            ];
        }

        // Gateway issues
        if ($analysis['discrepancy_types']['high_fee']['count'] ?? 0 > 0) {
            $recommendations[] = [
                'priority' => 'medium',
                'action' => 'Review gateway fee structure',
                'description' => 'Analyze and negotiate better rates with payment gateway',
                'estimated_effort' => '1 week'
            ];
        }

        // Timing differences
        if ($analysis['discrepancy_types']['date_mismatch']['count'] ?? 0 > 0) {
            $recommendations[] = [
                'priority' => 'low',
                'action' => 'Adjust reconciliation window',
                'description' => 'Increase reconciliation date tolerance from 3 to 5 days',
                'estimated_effort' => '1 day'
            ];
        }

        // System errors
        if ($analysis['discrepancy_types']['currency_mismatch']['count'] ?? 0 > 0) {
            $recommendations[] = [
                'priority' => 'critical',
                'action' => 'Fix currency validation',
                'description' => 'Implement strict currency validation in payment processing',
                'estimated_effort' => '3 days'
            ];
        }

        // General recommendations based on overall metrics
        if ($analysis['impact_metrics']['discrepancy_rate_percentage'] > 5) {
            $recommendations[] = [
                'priority' => 'high',
                'action' => 'Improve reconciliation process',
                'description' => 'Discrepancy rate exceeds 5%, review entire reconciliation workflow',
                'estimated_effort' => '2 weeks'
            ];
        }

        if ($analysis['impact_metrics']['amount_at_risk_percentage'] > 2) {
            $recommendations[] = [
                'priority' => 'critical',
                'action' => 'Address high-risk discrepancies',
                'description' => 'Over 2% of total amount is at risk, prioritize resolution',
                'estimated_effort' => '1 week'
            ];
        }

        return $recommendations;
    }

    /**
     * Validate discrepancy resolution
     */
    private function validateDiscrepancyResolution(Payment $payment, array $resolutionData): void
    {
        if (empty($resolutionData['resolution_method'])) {
            throw new \Exception('Resolution method is required');
        }

        $validMethods = ['adjust_payment_amount', 'adjust_transaction_amount', 'mark_as_correct', 'create_adjustment'];
        if (!in_array($resolutionData['resolution_method'], $validMethods)) {
            throw new \Exception('Invalid resolution method');
        }

        if ($resolutionData['resolution_method'] === 'adjust_payment_amount') {
            if (!isset($resolutionData['adjustment_amount']) || !is_numeric($resolutionData['adjustment_amount'])) {
                throw new \Exception('Adjustment amount is required and must be numeric');
            }
        }

        if (empty($resolutionData['resolution_notes'])) {
            throw new \Exception('Resolution notes are required');
        }
    }

    /**
     * Build resolution notes
     */
    private function buildResolutionNotes(Payment $payment, array $resolutionData): string
    {
        $notes = "Discrepancy resolved via {$resolutionData['resolution_method']}. ";

        if (!empty($resolutionData['resolution_notes'])) {
            $notes .= "Notes: {$resolutionData['resolution_notes']}. ";
        }

        if ($resolutionData['resolution_method'] === 'adjust_payment_amount') {
            $notes .= "Adjustment: {$resolutionData['adjustment_amount']}. ";
            if (!empty($resolutionData['adjustment_reason'])) {
                $notes .= "Reason: {$resolutionData['adjustment_reason']}. ";
            }
        }

        $notes .= "Resolved by: " . ($resolutionData['resolved_by'] ?? 'system') . " at " . Carbon::now()->toDateTimeString();

        return $notes;
    }

    /**
     * Create adjustment record
     */
    private function createAdjustmentRecord(Payment $payment, float $adjustment, array $resolutionData): void
    {
        // Create adjustment payment record
        $adjustmentPayment = Payment::create([
            'id' => \Illuminate\Support\Str::uuid()->toString(),
            'invoice_id' => $payment->invoice_id,
            'amount' => $adjustment,
            'currency' => $payment->currency,
            'method' => 'adjustment',
            'payment_date' => Carbon::now(),
            'reference' => 'ADJ-' . ($payment->reference ?? $payment->id),
            'transaction_id' => null,
            'notes' => 'Adjustment for discrepancy resolution: ' . ($resolutionData['resolution_notes'] ?? ''),
            'metadata' => [
                'adjustment_for_payment_id' => $payment->id,
                'adjustment_reason' => $resolutionData['adjustment_reason'] ?? null,
                'resolution_method' => $resolutionData['resolution_method'],
                'original_amount' => $payment->amount - $adjustment
            ]
        ]);

        Log::info("Adjustment record created", [
            'original_payment_id' => $payment->id,
            'adjustment_payment_id' => $adjustmentPayment->id,
            'adjustment_amount' => $adjustment
        ]);
    }

    /**
     * Update invoice after adjustment
     */
    private function updateInvoiceAfterAdjustment(Invoice $invoice, Payment $payment): void
    {
        // Recalculate invoice totals
        $totalPaid = $invoice->payments()->sum('amount');

        if (abs($totalPaid - $invoice->total_amount) < 0.01) {
            $invoice->update([
                'status' => 'paid',
                'payment_date' => Carbon::now()
            ]);
        }

        // Update invoice metadata
        $metadata = $invoice->metadata ?? [];
        $metadata['last_adjustment_date'] = Carbon::now()->toISOString();
        $metadata['adjustment_payment_ids'] = array_merge(
            $metadata['adjustment_payment_ids'] ?? [],
            [$payment->id]
        );

        $invoice->update(['metadata' => $metadata]);

        Log::info("Invoice updated after adjustment", [
            'invoice_id' => $invoice->id,
            'payment_id' => $payment->id,
            'new_status' => $invoice->status
        ]);
    }

    /**
     * Generate summary report
     */
    private function generateSummaryReport(Carbon $startDate, Carbon $endDate): array
    {
        $reconciliationData = $this->getPaymentReconciliation([
            'date_from' => $startDate->toDateString(),
            'date_to' => $endDate->toDateString()
        ]);

        return [
            'report_type' => 'summary',
            'period' => $reconciliationData['period'],
            'summary' => $reconciliationData['summary'],
            'reconciliation_health' => $reconciliationData['reconciliation_health'],
            'recommended_actions' => $reconciliationData['recommended_actions'],
            'generated_at' => Carbon::now()->toISOString()
        ];
    }

    /**
     * Generate detailed report
     */
    private function generateDetailedReport(Carbon $startDate, Carbon $endDate): array
    {
        $reconciliationData = $this->getPaymentReconciliation([
            'date_from' => $startDate->toDateString(),
            'date_to' => $endDate->toDateString()
        ]);

        $analysis = $this->analyzeReconciliation([
            'date_from' => $startDate->toDateString(),
            'date_to' => $endDate->toDateString()
        ]);

        return [
            'report_type' => 'detailed',
            'period' => $reconciliationData['period'],
            'summary' => $reconciliationData['summary'],
            'categorized_payments' => [
                'reconciled_count' => count($reconciliationData['categorized_payments']['reconciled']),
                'pending_count' => count($reconciliationData['categorized_payments']['pending']),
                'discrepancy_count' => count($reconciliationData['categorized_payments']['discrepancy']),
                'unmatched_count' => count($reconciliationData['categorized_payments']['unmatched'])
            ],
            'analysis' => $analysis,
            'statistics_by_payment_method' => $reconciliationData['statistics_by_payment_method'],
            'aging_analysis' => $reconciliationData['aging_analysis'],
            'reconciliation_health' => $reconciliationData['reconciliation_health'],
            'recommended_actions' => $reconciliationData['recommended_actions'],
            'generated_at' => Carbon::now()->toISOString()
        ];
    }

    /**
     * Generate discrepancy report
     */
    private function generateDiscrepancyReport(Carbon $startDate, Carbon $endDate): array
    {
        $analysis = $this->analyzeReconciliation([
            'date_from' => $startDate->toDateString(),
            'date_to' => $endDate->toDateString()
        ]);

        return [
            'report_type' => 'discrepancy',
            'period' => [
                'start' => $startDate->toDateString(),
                'end' => $endDate->toDateString()
            ],
            'discrepancy_summary' => [
                'total_discrepancies' => $analysis['total_discrepancies'],
                'total_discrepant_amount' => $analysis['total_discrepant_amount'],
                'impact_metrics' => $analysis['impact_metrics']
            ],
            'discrepancy_types' => $analysis['discrepancy_types'],
            'by_payment_method' => $analysis['by_payment_method'],
            'root_causes' => $analysis['root_causes'],
            'trend' => $analysis['trend'],
            'recommendations' => $analysis['recommendations'],
            'generated_at' => Carbon::now()->toISOString()
        ];
    }

    /**
     * Generate aging report
     */
    private function generateAgingReport(Carbon $startDate, Carbon $endDate): array
    {
        $reconciliationData = $this->getPaymentReconciliation([
            'date_from' => $startDate->toDateString(),
            'date_to' => $endDate->toDateString()
        ]);

        return [
            'report_type' => 'aging',
            'period' => $reconciliationData['period'],
            'aging_analysis' => $reconciliationData['aging_analysis'],
            'pending_payments_summary' => [
                'total_pending' => count($reconciliationData['categorized_payments']['pending']),
                'total_pending_amount' => $reconciliationData['summary']['pending_amount'],
                'by_age_bucket' => $reconciliationData['aging_analysis']
            ],
            'action_plan' => $this->generateAgingActionPlan($reconciliationData['aging_analysis']),
            'generated_at' => Carbon::now()->toISOString()
        ];
    }

    /**
     * Generate aging action plan
     */
    private function generateAgingActionPlan(array $agingAnalysis): array
    {
        $actionPlan = [];

        // Over 90 days - immediate action
        if ($agingAnalysis['over_90_days']['count'] > 0) {
            $actionPlan[] = [
                'priority' => 'critical',
                'action' => 'Immediate review of payments over 90 days',
                'description' => "{$agingAnalysis['over_90_days']['count']} payments totaling {$agingAnalysis['over_90_days']['amount']} are over 90 days old",
                'deadline' => Carbon::now()->addDays(1)->toDateString(),
                'responsible' => 'Finance Manager'
            ];
        }

        // 61-90 days - urgent action
        if ($agingAnalysis['61-90_days']['count'] > 0) {
            $actionPlan[] = [
                'priority' => 'high',
                'action' => 'Urgent reconciliation of 61-90 day payments',
                'description' => "{$agingAnalysis['61-90_days']['count']} payments totaling {$agingAnalysis['61-90_days']['amount']} are 61-90 days old",
                'deadline' => Carbon::now()->addDays(3)->toDateString(),
                'responsible' => 'Reconciliation Specialist'
            ];
        }

        // 31-60 days - scheduled action
        if ($agingAnalysis['31-60_days']['count'] > 0) {
            $actionPlan[] = [
                'priority' => 'medium',
                'action' => 'Schedule reconciliation of 31-60 day payments',
                'description' => "{$agingAnalysis['31-60_days']['count']} payments totaling {$agingAnalysis['31-60_days']['amount']} are 31-60 days old",
                'deadline' => Carbon::now()->addDays(7)->toDateString(),
                'responsible' => 'Reconciliation Team'
            ];
        }

        // 8-30 days - monitor
        if ($agingAnalysis['8-30_days']['count'] > 0) {
            $actionPlan[] = [
                'priority' => 'low',
                'action' => 'Monitor 8-30 day payments',
                'description' => "{$agingAnalysis['8-30_days']['count']} payments totaling {$agingAnalysis['8-30_days']['amount']} are 8-30 days old",
                'deadline' => Carbon::now()->addDays(14)->toDateString(),
                'responsible' => 'Reconciliation Team'
            ];
        }

        return $actionPlan;
    }
}
