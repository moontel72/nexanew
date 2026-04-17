<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Invoice;
use App\Models\Company;
use App\Models\CreditNote;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class PaymentService
{
    /**
     * Process payment for an invoice
     */
    public function processPayment(
        string $invoiceId,
        array $paymentData,
    ): Payment {
        DB::beginTransaction();

        try {
            $invoice = Invoice::with("company")->findOrFail($invoiceId);

            // Validate payment data
            $this->validatePaymentData($paymentData);

            // Check if invoice is already paid
            $paidAmount = $invoice->payments()->sum("amount");
            $remainingAmount = $invoice->total_amount - $paidAmount;

            if ($remainingAmount <= 0) {
                throw new \Exception("Invoice is already fully paid");
            }

            // Validate payment amount
            if ($paymentData["amount"] > $remainingAmount) {
                throw new \Exception(
                    "Payment amount exceeds remaining invoice balance",
                );
            }

            // Check for duplicate payment reference
            if (!empty($paymentData["reference"])) {
                $existingPayment = Payment::where(
                    "reference",
                    $paymentData["reference"],
                )->first();

                if ($existingPayment) {
                    throw new \Exception(
                        "Payment reference already used for another payment",
                    );
                }
            }

            // Create payment record
            $payment = Payment::create([
                "id" => \Illuminate\Support\Str::uuid()->toString(),
                "invoice_id" => $invoice->id,
                "amount" => $paymentData["amount"],
                "currency" => $paymentData["currency"] ?? $invoice->currency,
                "method" => $paymentData["method"],
                "payment_date" => $paymentData["payment_date"] ?? Carbon::now(),
                "reference" => $paymentData["reference"] ?? null,
                "transaction_id" => $paymentData["transaction_id"] ?? null,
                "notes" => $paymentData["notes"] ?? null,
                "metadata" => $paymentData["metadata"] ?? null,
            ]);

            // Update invoice status if fully paid
            $newPaidAmount = $paidAmount + $paymentData["amount"];
            if (abs($newPaidAmount - $invoice->total_amount) < 0.01) {
                $invoice->update([
                    "status" => "paid",
                    "payment_date" => Carbon::now(),
                    "method" => $paymentData["method"],
                    "reference" => $paymentData["reference"],
                ]);
            }

            // Update company's payment statistics in metadata
            $company = $invoice->company;
            $metadata = $company->metadata ?? [];
            $metadata["last_payment_date"] = Carbon::now()->toISOString();
            $metadata["total_payments"] =
                ($metadata["total_payments"] ?? 0) + $paymentData["amount"];
            $company->update(["metadata" => $metadata]);

            DB::commit();

            Log::info(
                "Payment processed for invoice {$invoice->invoice_number}",
                [
                    "invoice_id" => $invoice->id,
                    "payment_id" => $payment->id,
                    "amount" => $paymentData["amount"],
                    "method" => $paymentData["method"],
                ],
            );

            return $payment->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to process payment for invoice {$invoiceId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Process partial payment
     */
    public function processPartialPayment(
        string $invoiceId,
        array $paymentData,
    ): Payment {
        // For partial payments, we don't mark invoice as paid
        $paymentData["allow_partial"] = true;
        return $this->processPayment($invoiceId, $paymentData);
    }

    /**
     * Process bulk payments
     */
    public function processBulkPayments(array $paymentsData): array
    {
        DB::beginTransaction();

        try {
            $results = [
                "successful" => [],
                "failed" => [],
                "total_amount" => 0,
            ];

            foreach ($paymentsData as $index => $paymentData) {
                try {
                    $invoiceId = $paymentData["invoice_id"];
                    $invoice = Invoice::find($invoiceId);

                    if (!$invoice) {
                        throw new \Exception("Invoice not found: {$invoiceId}");
                    }

                    $payment = $this->processPayment($invoiceId, $paymentData);

                    $results["successful"][] = [
                        "index" => $index,
                        "invoice_id" => $invoiceId,
                        "invoice_number" => $invoice->invoice_number,
                        "payment_id" => $payment->id,
                        "amount" => $payment->amount,
                        "company_name" => $invoice->company->name,
                    ];

                    $results["total_amount"] += $payment->amount;
                } catch (\Exception $e) {
                    $results["failed"][] = [
                        "index" => $index,
                        "invoice_id" => $paymentData["invoice_id"] ?? "unknown",
                        "error" => $e->getMessage(),
                    ];
                }
            }

            DB::commit();

            Log::info("Bulk payments processed", [
                "total_payments" => count($paymentsData),
                "successful" => count($results["successful"]),
                "failed" => count($results["failed"]),
                "total_amount" => $results["total_amount"],
            ]);

            return $results;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to process bulk payments: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Record offline payment (cash, check, bank transfer)
     */
    public function recordOfflinePayment(
        string $invoiceId,
        array $paymentData,
    ): Payment {
        $paymentData["method"] = $paymentData["method"] ?? "offline";
        $paymentData["transaction_id"] = null;

        return $this->processPayment($invoiceId, $paymentData);
    }

    /**
     * Record payment reversal/refund
     */
    public function recordPaymentReversal(
        string $paymentId,
        array $reversalData,
    ): Payment {
        DB::beginTransaction();

        try {
            $payment = Payment::with("invoice")->findOrFail($paymentId);

            // Validate reversal amount
            $maxReversalAmount =
                $payment->amount - ($payment->metadata["reversed_amount"] ?? 0);
            if ($reversalData["amount"] > $maxReversalAmount) {
                throw new \Exception(
                    "Reversal amount exceeds available amount",
                );
            }

            // Create reversal payment (negative amount)
            $reversalPayment = Payment::create([
                "id" => \Illuminate\Support\Str::uuid()->toString(),
                "invoice_id" => $payment->invoice_id,
                "amount" => -$reversalData["amount"],
                "currency" => $payment->currency,
                "method" => "reversal",
                "payment_date" =>
                    $reversalData["payment_date"] ?? Carbon::now(),
                "reference" =>
                    $reversalData["reference"] ?? "REV-" . $payment->reference,
                "transaction_id" => $reversalData["transaction_id"] ?? null,
                "notes" => $reversalData["notes"] ?? "Payment reversal",
                "metadata" => [
                    "reversal_of_payment_id" => $payment->id,
                    "reversal_reason" => $reversalData["reason"] ?? null,
                ],
            ]);

            // Update original payment's metadata
            $metadata = $payment->metadata ?? [];
            $metadata["reversed_amount"] =
                ($metadata["reversed_amount"] ?? 0) + $reversalData["amount"];
            $metadata["reversal_status"] =
                $metadata["reversed_amount"] >= $payment->amount
                    ? "fully_reversed"
                    : "partially_reversed";
            $payment->update(["metadata" => $metadata]);

            // Update invoice status if needed
            $invoice = $payment->invoice;
            $totalPaid = $invoice->payments()->sum("amount");

            if ($totalPaid < $invoice->total_amount) {
                $invoice->update([
                    "status" => "pending",
                    "payment_date" => null,
                ]);
            }

            DB::commit();

            Log::info("Payment reversal recorded", [
                "original_payment_id" => $payment->id,
                "reversal_payment_id" => $reversalPayment->id,
                "amount" => $reversalData["amount"],
                "reason" => $reversalData["notes"] ?? "No reason provided",
            ]);

            return $reversalPayment;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to record payment reversal for payment {$paymentId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Get payment history for a company
     */
    public function getCompanyPaymentHistory(
        string $companyId,
        array $filters = [],
    ): array {
        $query = Payment::whereHas("invoice", function ($q) use ($companyId) {
            $q->where("company_id", $companyId);
        })->with(["invoice", "invoice.company"]);

        // Apply filters
        if (!empty($filters["date_from"])) {
            $query->where("payment_date", ">=", $filters["date_from"]);
        }

        if (!empty($filters["date_to"])) {
            $query->where("payment_date", "<=", $filters["date_to"]);
        }

        if (!empty($filters["method"])) {
            $query->where("method", $filters["method"]);
        }

        if (!empty($filters["min_amount"])) {
            $query->where("amount", ">=", $filters["min_amount"]);
        }

        if (!empty($filters["max_amount"])) {
            $query->where("amount", "<=", $filters["max_amount"]);
        }

        // Get total count for pagination
        $total = $query->count();

        // Apply sorting
        $sortBy = $filters["sort_by"] ?? "payment_date";
        $sortOrder = $filters["sort_order"] ?? "desc";
        $query->orderBy($sortBy, $sortOrder);

        // Apply pagination
        $perPage = $filters["per_page"] ?? 50;
        $page = $filters["page"] ?? 1;
        $payments = $query->paginate($perPage, ["*"], "page", $page);

        // Calculate summary statistics
        $totalAmount = $payments->sum("amount");
        $averagePayment =
            $payments->count() > 0 ? $totalAmount / $payments->count() : 0;

        // Payment method distribution
        $paymentMethodDistribution = $payments
            ->groupBy("method")
            ->map(function ($group) {
                return [
                    "count" => $group->count(),
                    "total_amount" => $group->sum("amount"),
                    "percentage" => 0, // Will be calculated below
                ];
            });

        // Calculate percentages
        $totalForPercentage = $paymentMethodDistribution->sum("total_amount");
        if ($totalForPercentage > 0) {
            $paymentMethodDistribution = $paymentMethodDistribution->map(
                function ($data) use ($totalForPercentage) {
                    $data["percentage"] = round(
                        ($data["total_amount"] / $totalForPercentage) * 100,
                        2,
                    );
                    return $data;
                },
            );
        }

        // Monthly trend
        $monthlyTrend = $this->getMonthlyPaymentTrend($companyId, $filters);

        return [
            "payments" => $payments->items(),
            "pagination" => [
                "total" => $total,
                "per_page" => $perPage,
                "current_page" => $page,
                "total_pages" => $payments->lastPage(),
                "has_more" => $payments->hasMorePages(),
            ],
            "summary" => [
                "total_payments" => $payments->count(),
                "total_amount" => round($totalAmount, 2),
                "average_payment_amount" => round($averagePayment, 2),
                "date_range" => [
                    "from" => $payments->min("payment_date")?->toDateString(),
                    "to" => $payments->max("payment_date")?->toDateString(),
                ],
            ],
            "payment_method_distribution" => $paymentMethodDistribution,
            "monthly_trend" => $monthlyTrend,
            "recent_activity" => $this->getRecentPaymentActivity(
                $companyId,
                10,
            ),
        ];
    }

    /**
     * Get payment statistics
     */
    public function getPaymentStatistics(array $filters = []): array
    {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange["start"];
        $endDate = $dateRange["end"];

        // Total payments
        $totalPayments = Payment::whereBetween("payment_date", [
            $startDate,
            $endDate,
        ])->count();

        // Total amount
        $totalAmount = Payment::whereBetween("payment_date", [
            $startDate,
            $endDate,
        ])->sum("amount");

        // Average payment amount
        $averagePayment =
            $totalPayments > 0 ? $totalAmount / $totalPayments : 0;

        // Payment method distribution
        $paymentMethodStats = Payment::whereBetween("payment_date", [
            $startDate,
            $endDate,
        ])
            ->selectRaw(
                "method, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("method")
            ->get()
            ->mapWithKeys(function ($item) use ($totalAmount) {
                $percentage =
                    $totalAmount > 0
                        ? ($item->total_amount / $totalAmount) * 100
                        : 0;
                return [
                    $item->method => [
                        "count" => $item->count,
                        "total_amount" => (float) $item->total_amount,
                        "percentage" => round($percentage, 2),
                        "average_amount" =>
                            $item->count > 0
                                ? $item->total_amount / $item->count
                                : 0,
                    ],
                ];
            });

        // Daily payment trend
        $dailyTrend = Payment::whereBetween("payment_date", [
            $startDate,
            $endDate,
        ])
            ->selectRaw(
                "DATE(payment_date) as date, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("date")
            ->orderBy("date")
            ->get();

        // Top paying companies
        $topCompanies = Payment::whereBetween("payment_date", [
            $startDate,
            $endDate,
        ])
            ->with(["invoice.company"])
            ->selectRaw(
                "invoice_id, COUNT(*) as payment_count, SUM(amount) as total_paid",
            )
            ->groupBy("invoice_id")
            ->orderByDesc("total_paid")
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    "invoice_id" => $item->invoice_id,
                    "invoice_number" =>
                        $item->invoice->invoice_number ?? "Unknown",
                    "company_name" =>
                        $item->invoice->company->name ?? "Unknown",
                    "payment_count" => $item->payment_count,
                    "total_paid" => (float) $item->total_paid,
                ];
            });

        return [
            "period" => [
                "start" => $startDate->toDateString(),
                "end" => $endDate->toDateString(),
            ],
            "overall_statistics" => [
                "total_payments" => $totalPayments,
                "total_amount" => round($totalAmount, 2),
                "average_payment_amount" => round($averagePayment, 2),
            ],
            "payment_method_analysis" => $paymentMethodStats,
            "daily_trend" => $dailyTrend,
            "top_paying_companies" => $topCompanies,
            "peak_payment_times" => $this->getPeakPaymentTimes(
                $startDate,
                $endDate,
            ),
            "forecast" => $this->forecastNextPeriodPayments(
                $startDate,
                $endDate,
            ),
        ];
    }

    /**
     * Validate payment data
     */
    private function validatePaymentData(array $paymentData): void
    {
        $requiredFields = ["amount", "method"];
        foreach ($requiredFields as $field) {
            if (empty($paymentData[$field])) {
                throw new \Exception("Missing required field: {$field}");
            }
        }

        if (
            !is_numeric($paymentData["amount"]) ||
            $paymentData["amount"] <= 0
        ) {
            throw new \Exception("Invalid payment amount");
        }

        $validPaymentMethods = [
            "credit_card",
            "debit_card",
            "bank_transfer",
            "paypal",
            "stripe",
            "cash",
            "check",
            "offline",
            "wallet",
            "reversal",
        ];
        if (!in_array($paymentData["method"], $validPaymentMethods)) {
            throw new \Exception("Invalid payment method");
        }
    }

    /**
     * Parse date range from filters
     */
    private function parseDateRange(array $filters): array
    {
        $defaultStart = Carbon::now()->subDays(30)->startOfDay();
        $defaultEnd = Carbon::now()->endOfDay();

        $startDate = !empty($filters["date_from"])
            ? Carbon::parse($filters["date_from"])->startOfDay()
            : $defaultStart;

        $endDate = !empty($filters["date_to"])
            ? Carbon::parse($filters["date_to"])->endOfDay()
            : $defaultEnd;

        return [
            "start" => $startDate,
            "end" => $endDate,
        ];
    }

    /**
     * Get monthly payment trend for a company
     */
    private function getMonthlyPaymentTrend(
        string $companyId,
        array $filters,
    ): array {
        $dateRange = $this->parseDateRange($filters);
        $startDate = $dateRange["start"];
        $endDate = $dateRange["end"];

        $trend = Payment::whereHas("invoice", function ($q) use ($companyId) {
            $q->where("company_id", $companyId);
        })
            ->whereBetween("payment_date", [$startDate, $endDate])
            ->selectRaw(
                "YEAR(payment_date) as year, MONTH(payment_date) as month, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("year", "month")
            ->orderBy("year")
            ->orderBy("month")
            ->get();

        return $trend
            ->map(function ($item) {
                return [
                    "year" => $item->year,
                    "month" => $item->month,
                    "count" => (int) $item->count,
                    "total_amount" => (float) $item->total_amount,
                    "average_amount" =>
                        $item->count > 0
                            ? $item->total_amount / $item->count
                            : 0,
                ];
            })
            ->toArray();
    }

    /**
     * Get recent payment activity for a company
     */
    private function getRecentPaymentActivity(
        string $companyId,
        int $limit = 10,
    ): array {
        $payments = Payment::whereHas("invoice", function ($q) use (
            $companyId,
        ) {
            $q->where("company_id", $companyId);
        })
            ->with(["invoice"])
            ->orderBy("payment_date", "desc")
            ->limit($limit)
            ->get();

        return $payments
            ->map(function ($payment) {
                return [
                    "id" => $payment->id,
                    "invoice_number" =>
                        $payment->invoice->invoice_number ?? "N/A",
                    "amount" => (float) $payment->amount,
                    "method" => $payment->method,
                    "payment_date" => $payment->payment_date->toDateString(),
                    "reference" => $payment->reference,
                    "notes" => $payment->notes,
                ];
            })
            ->toArray();
    }

    /**
     * Get peak payment times
     */
    private function getPeakPaymentTimes(
        Carbon $startDate,
        Carbon $endDate,
    ): array {
        // This would typically query payment gateway data
        // For now, return mock data
        return [
            "by_hour" => [
                ["hour" => 9, "count" => 15, "amount" => 4500],
                ["hour" => 10, "count" => 22, "amount" => 6800],
                ["hour" => 14, "count" => 18, "amount" => 5200],
                ["hour" => 16, "count" => 25, "amount" => 8900],
            ],
            "by_day_of_week" => [
                ["day" => "Monday", "count" => 45, "amount" => 15000],
                ["day" => "Tuesday", "count" => 52, "amount" => 18000],
                ["day" => "Wednesday", "count" => 48, "amount" => 16500],
                ["day" => "Thursday", "count" => 55, "amount" => 19500],
                ["day" => "Friday", "count" => 60, "amount" => 22000],
                ["day" => "Saturday", "count" => 25, "amount" => 8500],
                ["day" => "Sunday", "count" => 18, "amount" => 6200],
            ],
        ];
    }

    /**
     * Forecast next period payments
     */
    private function forecastNextPeriodPayments(
        Carbon $startDate,
        Carbon $endDate,
    ): array {
        // Simple forecasting based on historical data
        $historicalPayments = Payment::whereBetween("payment_date", [
            $startDate->copy()->subDays(90),
            $endDate,
        ])
            ->selectRaw(
                "DATE(payment_date) as date, SUM(amount) as daily_amount",
            )
            ->groupBy("date")
            ->orderBy("date")
            ->get();

        if ($historicalPayments->isEmpty()) {
            return [
                "next_30_days_forecast" => 0,
                "confidence_level" => "low",
                "based_on_days" => 0,
            ];
        }

        $averageDaily = $historicalPayments->avg("daily_amount");
        $next30DaysForecast = $averageDaily * 30;

        // Calculate confidence based on data points
        $dataPoints = $historicalPayments->count();
        $confidence =
            $dataPoints >= 60 ? "high" : ($dataPoints >= 30 ? "medium" : "low");

        return [
            "next_30_days_forecast" => round($next30DaysForecast, 2),
            "confidence_level" => $confidence,
            "based_on_days" => $dataPoints,
            "average_daily_payment" => round($averageDaily, 2),
        ];
    }

    /**
     * Calculate payment velocity
     */
    private function calculatePaymentVelocity(
        Carbon $startDate,
        Carbon $endDate,
    ): float {
        $invoices = Invoice::where("status", "paid")
            ->whereBetween("payment_date", [$startDate, $endDate])
            ->whereNotNull("issue_date")
            ->get();

        if ($invoices->isEmpty()) {
            return 0;
        }

        $totalDays = 0;
        foreach ($invoices as $invoice) {
            $daysToPay = $invoice->issue_date->diffInDays(
                $invoice->payment_date,
            );
            $totalDays += $daysToPay;
        }

        return $totalDays / $invoices->count();
    }
}
