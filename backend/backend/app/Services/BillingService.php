<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Company;
use App\Models\Payment;
use App\Models\CreditNote;
use App\Models\Refund;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class BillingService
{
    /**
     * Generate monthly invoices for all active companies
     */
    public function generateMonthlyInvoices(): array
    {
        $results = [
            'total_companies' => 0,
            'invoices_generated' => 0,
            'total_amount' => 0,
            'errors' => [],
        ];

        // Get all active companies with active subscriptions
        $companies = Company::where('status', 'active')
            ->whereHas('activeSubscription')
            ->with('activeSubscription')
            ->get();

        $results['total_companies'] = $companies->count();

        foreach ($companies as $company) {
            try {
                DB::beginTransaction();

                $subscription = $company->activeSubscription;
                $plan = $subscription->plan;

                // Calculate period
                $periodStart = $subscription->current_period_start ?? now()->startOfMonth();
                $periodEnd = $subscription->current_period_end ?? now()->endOfMonth();
                $dueDate = now()->addDays(30);

                // Calculate usage-based charges
                $usageCharges = $this->calculateUsageCharges($company, $periodStart, $periodEnd);
                $subscriptionFee = $plan->monthly_price ?? 0;

                // Calculate totals
                $subtotal = $subscriptionFee + $usageCharges['total'];
                $taxAmount = $subtotal * 0.18; // 18% tax
                $totalAmount = $subtotal + $taxAmount;

                // Generate invoice number
                $invoiceNumber = 'INV-' . date('Y-m') . '-' . str_pad(
                    Invoice::whereYear('created_at', date('Y'))->count() + 1,
                    5,
                    '0',
                    STR_PAD_LEFT
                );

                // Create invoice items
                $items = [];

                // Subscription fee item
                if ($subscriptionFee > 0) {
                    $items[] = [
                        'description' => "Monthly subscription fee - {$plan->name}",
                        'quantity' => 1,
                        'unit_price' => $subscriptionFee,
                        'total' => $subscriptionFee,
                        'currency' => 'USD',
                        'item_type' => 'subscription_fee',
                    ];
                }

                // Usage items
                foreach ($usageCharges['items'] as $usageItem) {
                    $items[] = $usageItem;
                }

                // Create invoice
                $invoice = Invoice::create([
                    'company_id' => $company->id,
                    'subscription_id' => $subscription->id,
                    'invoice_number' => $invoiceNumber,
                    'period_start' => $periodStart,
                    'period_end' => $periodEnd,
                    'issue_date' => now(),
                    'due_date' => $dueDate,
                    'subtotal' => $subtotal,
                    'tax_amount' => $taxAmount,
                    'discount_amount' => 0,
                    'total_amount' => $totalAmount,
                    'currency' => 'USD',
                    'items' => json_encode($items),
                    'status' => 'pending',
                    'metadata' => json_encode([
                        'auto_generated' => true,
                        'generation_date' => now()->toISOString(),
                        'usage_summary' => $usageCharges['summary'],
                    ]),
                ]);

                // Update subscription period
                $subscription->update([
                    'current_period_start' => $periodEnd->copy()->addDay(),
                    'current_period_end' => $periodEnd->copy()->addMonth(),
                    'last_invoice_generated_at' => now(),
                ]);

                DB::commit();

                $results['invoices_generated']++;
                $results['total_amount'] += $totalAmount;

            } catch (\Exception $e) {
                DB::rollBack();
                $results['errors'][] = [
                    'company_id' => $company->id,
                    'company_name' => $company->name,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    /**
     * Calculate usage-based charges for a company
     */
    public function calculateUsageCharges(Company $company, Carbon $periodStart, Carbon $periodEnd): array
    {
        $charges = [
            'total' => 0,
            'items' => [],
            'summary' => [],
        ];

        // Get company's subscription plan
        $subscription = $company->activeSubscription;
        if (!$subscription) {
            return $charges;
        }

        $plan = $subscription->plan;

        // Calculate code generation charges
        $codeStats = $this->getCodeGenerationStats($company->id, $periodStart, $periodEnd);

        if ($codeStats['total_codes'] > 0) {
            $includedCodes = $plan->included_codes ?? 0;
            $overageCodes = max(0, $codeStats['total_codes'] - $includedCodes);

            if ($overageCodes > 0) {
                $overageRate = $plan->overage_rate_per_code ?? 0.002;
                $overageAmount = $overageCodes * $overageRate;

                $charges['items'][] = [
                    'description' => "Code generation overage ({$overageCodes} codes)",
                    'quantity' => $overageCodes,
                    'unit_price' => $overageRate,
                    'total' => $overageAmount,
                    'currency' => 'USD',
                    'item_type' => 'code_overage',
                    'metadata' => [
                        'included_codes' => $includedCodes,
                        'total_generated' => $codeStats['total_codes'],
                        'overage_codes' => $overageCodes,
                        'rate_per_code' => $overageRate,
                    ],
                ];

                $charges['total'] += $overageAmount;
                $charges['summary']['code_generation'] = [
                    'total_codes' => $codeStats['total_codes'],
                    'included_codes' => $includedCodes,
                    'overage_codes' => $overageCodes,
                    'amount' => $overageAmount,
                ];
            }
        }

        // Calculate transport connection fees
        $connectionFees = $this->getTransportConnectionFees($company->id, $periodStart, $periodEnd);

        if ($connectionFees['total_connections'] > 0) {
            $connectionRate = 10; // ₹10 per connection
            $connectionAmount = $connectionFees['total_connections'] * $connectionRate;

            $charges['items'][] = [
                'description' => "Transport connection fees ({$connectionFees['total_connections']} connections)",
                'quantity' => $connectionFees['total_connections'],
                'unit_price' => $connectionRate,
                'total' => $connectionAmount,
                'currency' => 'USD',
                'item_type' => 'connection_fee',
                'metadata' => [
                    'total_connections' => $connectionFees['total_connections'],
                    'rate_per_connection' => $connectionRate,
                ],
            ];

            $charges['total'] += $connectionAmount;
            $charges['summary']['transport_connections'] = [
                'total_connections' => $connectionFees['total_connections'],
                'amount' => $connectionAmount,
            ];
        }

        // Calculate commission on transport trips
        $commissionFees = $this->getTransportCommissionFees($company->id, $periodStart, $periodEnd);

        if ($commissionFees['total_commission'] > 0) {
            $charges['items'][] = [
                'description' => "Transport commission ({$commissionFees['completed_trips']} trips)",
                'quantity' => $commissionFees['completed_trips'],
                'unit_price' => $commissionFees['average_commission'],
                'total' => $commissionFees['total_commission'],
                'currency' => 'USD',
                'item_type' => 'commission',
                'metadata' => [
                    'completed_trips' => $commissionFees['completed_trips'],
                    'total_trip_value' => $commissionFees['total_trip_value'],
                    'commission_rate' => $commissionFees['commission_rate'],
                    'average_commission' => $commissionFees['average_commission'],
                ],
            ];

            $charges['total'] += $commissionFees['total_commission'];
            $charges['summary']['transport_commission'] = [
                'completed_trips' => $commissionFees['completed_trips'],
                'total_trip_value' => $commissionFees['total_trip_value'],
                'commission_amount' => $commissionFees['total_commission'],
            ];
        }

        return $charges;
    }

    /**
     * Get code generation statistics for a company
     */
    private function getCodeGenerationStats(string $companyId, Carbon $startDate, Carbon $endDate): array
    {
        // This would query the actual database
        // For now, return sample data
        return [
            'total_codes' => 125000,
            'unit_codes' => 100000,
            'packet_codes' => 20000,
            'carton_codes' => 5000,
            'bundle_codes' => 0,
        ];
    }

    /**
     * Get transport connection fees for a company
     */
    private function getTransportConnectionFees(string $companyId, Carbon $startDate, Carbon $endDate): array
    {
        // This would query the actual database
        // For now, return sample data
        return [
            'total_connections' => 15,
            'new_connections' => 15,
            'renewed_connections' => 0,
        ];
    }

    /**
     * Get transport commission fees for a company
     */
    private function getTransportCommissionFees(string $companyId, Carbon $startDate, Carbon $endDate): array
    {
        // This would query the actual database
        // For now, return sample data
        $totalTripValue = 50000;
        $commissionRate = 0.05; // 5%
        $completedTrips = 8;

        return [
            'completed_trips' => $completedTrips,
            'total_trip_value' => $totalTripValue,
            'commission_rate' => $commissionRate,
            'total_commission' => $totalTripValue * $commissionRate,
            'average_commission' => ($totalTripValue * $commissionRate) / $completedTrips,
        ];
    }

    /**
     * Process bulk payments
     */
    public function processBulkPayments(array $paymentData): array
    {
        $results = [
            'total_payments' => 0,
            'successful' => 0,
            'failed' => 0,
            'total_amount' => 0,
            'errors' => [],
        ];

        foreach ($paymentData as $payment) {
            try {
                DB::beginTransaction();

                $invoice = Invoice::findOrFail($payment['invoice_id']);

                // Validate payment amount
                if ($payment['amount'] <= 0) {
                    throw new \InvalidArgumentException('Payment amount must be greater than 0');
                }

                // Check if invoice is already paid
                if ($invoice->status === 'paid') {
                    throw new \InvalidArgumentException('Invoice is already paid');
                }

                // Create payment
                $paymentRecord = Payment::create([
                    'invoice_id' => $invoice->id,
                    'amount' => $payment['amount'],
                    'currency' => $invoice->currency,
                    'method' => $payment['method'] ?? 'bank_transfer',
                    'payment_date' => $payment['payment_date'] ?? now(),
                    'reference' => $payment['reference'] ?? null,
                    'transaction_id' => $payment['transaction_id'] ?? null,
                    'notes' => $payment['notes'] ?? null,
                    'metadata' => json_encode([
                        'bulk_processed' => true,
                        'processed_at' => now()->toISOString(),
                        'processed_by' => auth()->id(),
                    ]),
                ]);

                // Update invoice status
                $totalPaid = Payment::where('invoice_id', $invoice->id)->sum('amount');
                $remainingBalance = $invoice->total_amount - $totalPaid;

                $newStatus = 'pending';
                if ($remainingBalance <= 0) {
                    $newStatus = 'paid';
                } elseif ($totalPaid > 0) {
                    $newStatus = 'partially_paid';
                }

                $invoice->update([
                    'status' => $newStatus,
                    'payment_date' => $newStatus === 'paid' ? now() : null,
                    'payment_method' => $payment['method'] ?? 'bank_transfer',
                    'payment_reference' => $payment['reference'] ?? null,
                ]);

                DB::commit();

                $results['successful']++;
                $results['total_amount'] += $payment['amount'];

            } catch (\Exception $e) {
                DB::rollBack();
                $results['failed']++;
                $results['errors'][] = [
                    'invoice_id' => $payment['invoice_id'] ?? 'unknown',
                    'error' => $e->getMessage(),
                ];
            }
        }

        $results['total_payments'] = count($paymentData);
        return $results;
    }

    /**
     * Update credit limit for a company
     */
    public function updateCreditLimit(string $companyId, float $newLimit, string $reason, ?string $notes = null): array
    {
        try {
            DB::beginTransaction();

            $company = Company::findOrFail($companyId);

            $oldLimit = $company->credit_limit ?? 0;

            // Update company credit limit
            $company->update([
                'credit_limit' => $newLimit,
                'credit_limit_set_at' => now(),
                'credit_limit_set_by' => auth()->id(),
                'credit_limit_notes' => $notes,
                'credit_metadata' => json_encode(array_merge(
                    json_decode($company->credit_metadata, true) ?? [],
                    [
                        'limit_history' => [
                            [
                                'old_limit' => $oldLimit,
                                'new_limit' => $newLimit,
                                'changed_at' => now()->toISOString(),
                                'changed_by' => auth()->id(),
                                'reason' => $reason,
                                'notes' => $notes,
                            ],
                        ],
                    ]
                )),
            ]);

            // Recalculate credit status
            $this->updateCreditStatus($company);

            DB::commit();

            return [
                'success' => true,
                'company_id' => $companyId,
                'company_name' => $company->name,
                'old_limit' => $oldLimit,
                'new_limit' => $newLimit,
                'change_amount' => $newLimit - $oldLimit,
                'credit_available' => $company->credit_available,
                'credit_utilization_percentage' => $company->credit_utilization_percentage,
                'credit_status' => $company->credit_status,
            ];

        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Update credit status for a company based on utilization
     */
    public function updateCreditStatus(Company $company): void
    {
        $utilization = $company->credit_utilization_percentage ?? 0;

        $status = 'good';
        if ($utilization > 100) {
            $status = 'over_limit';
        } elseif ($utilization > 90) {
            $status = 'warning';
        }

        $company->update([
            'credit_status' => $status,
        ]);
    }

    /**
     * Get companies with high credit utilization
     */
    public function getCompaniesWithHighCreditUtilization(float $threshold = 90): array
    {
        $companies = Company::where('credit_utilization_percentage', '>=', $threshold)
            ->where('credit_status', '!=', 'over_limit')
            ->where('status', 'active')
            ->orderBy('credit_utilization_percentage', 'desc')
            ->get();

        return $companies->map(function ($company) {
            return [
                'id' => $company->id,
                'name' => $company->name,
                'email' => $company->email,
                'credit_limit' => $company->credit_limit,
                'credit_used' => $company->credit_used,
                'credit_available' => $company->credit_available,
                'credit_utilization_percentage' => $company->credit_utilization_percentage,
                'credit_status' => $company->credit_status,
                'last_invoice_date' => $company->invoices()->latest()->first()?->issue_date,
                'total_overdue' => $company->invoices()->where('status', 'overdue')->sum('total_amount'),
            ];
        })->toArray();
    }

    /**
     * Send credit limit alerts
     */
    public function sendCreditLimitAlerts(array $companyIds = []): array
    {
        $results = [
            'total_alerts_sent' => 0,
            'companies_notified' => [],
            'errors' => [],
        ];

        $query = Company::where('status', 'active')
            ->where('credit_utilization_percentage', '>=', 90);

        if (!empty($companyIds)) {
            $query->whereIn('id', $companyIds);
        }

        $companies = $query->get();

        foreach ($companies as $company) {
            try {
                // TODO: Implement actual email/sms notification
                // For now, just update metadata
                $metadata = json_decode($company->credit_metadata, true) ?? [];
                $alerts = $metadata['alerts'] ?? [];

                $alerts[] = [
                    'type' => 'credit_limit',
                    'level' => $company->credit_status === 'over_limit' ? 'critical' : 'warning',
                    'utilization' => $company->credit_utilization_percentage,
                    'sent_at' => now()->toISOString(),
                    'message' => $this->generateCreditAlertMessage($company),
                ];

                $company->update([
                    'credit_metadata' => json_encode(array_merge($metadata, ['alerts' => $alerts])),
                ]);

                $
