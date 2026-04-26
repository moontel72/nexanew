<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Company;
use App\Models\SubscriptionPlan;
use App\Models\Payment;
use App\Models\CreditNote;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;
use Illuminate\Support\Str;

class InvoiceService
{
    /**
     * Generate monthly subscription invoice for a company
     */
    public function generateMonthlyInvoice(
        Company $company,
        array $usageData = [],
    ): Invoice {
        DB::beginTransaction();

        try {
            $subscription = $company->activeSubscription;
            if (!$subscription) {
                throw new \Exception(
                    "Company does not have an active subscription",
                );
            }

            $plan = $subscription->plan;
            $periodStart = Carbon::now()->startOfMonth();
            $periodEnd = Carbon::now()->endOfMonth();

            // Generate invoice number
            $invoiceNumber = $this->generateInvoiceNumber($company);

            // Calculate base subscription amount
            $subtotal = $plan->monthly_price;

            // Calculate usage charges if provided
            $usageCharges = 0;
            $invoiceItems = [];
            $currency = $company->currency ?? "USD";

            if (!empty($usageData)) {
                $usageCharges = $this->calculateUsageCharges($plan, $usageData);
                $subtotal += $usageCharges;

                // Create invoice items for usage
                foreach ($usageData as $item) {
                    $invoiceItems[] = [
                        "id" => Str::uuid()->toString(),
                        "description" =>
                            $item["description"] ?? "Usage charges",
                        "item_type" => $item["type"] ?? "usage",
                        "quantity" => $item["quantity"] ?? 1,
                        "unit_price" => $item["unit_price"] ?? 0,
                        "total_price" => $item["total_price"] ?? 0,
                        "total" => $item["total_price"] ?? 0,
                        "currency" => $currency,
                        "metadata" => $item["metadata"] ?? null,
                    ];
                }
            }

            // Add subscription fee as first item
            array_unshift($invoiceItems, [
                "id" => Str::uuid()->toString(),
                "description" => "{$plan->name} Subscription Fee",
                "item_type" => "subscription_fee",
                "quantity" => 1,
                "unit_price" => $plan->monthly_price,
                "total_price" => $plan->monthly_price,
                "total" => $plan->monthly_price,
                "currency" => $currency,
                "metadata" => [
                    "plan_id" => $plan->id,
                    "plan_name" => $plan->name,
                    "period_start" => $periodStart->toDateString(),
                    "period_end" => $periodEnd->toDateString(),
                ],
            ]);

            // Calculate tax
            $taxRate = $company->tax_rate ?? 0;
            $taxAmount = $subtotal * $taxRate;
            $totalAmount = $subtotal + $taxAmount;

            // Create invoice
            $invoice = Invoice::create([
                "id" => Str::uuid()->toString(),
                "company_id" => $company->id,
                "subscription_id" => $subscription->id,
                ...(Schema::hasColumn('invoices', 'type') ? ["type" => "platform"] : []),
                "invoice_number" => $invoiceNumber,
                "period_start" => $periodStart,
                "period_end" => $periodEnd,
                "issue_date" => Carbon::now(),
                "due_date" => Carbon::now()->addDays(30),
                "subtotal" => $subtotal,
                "tax_amount" => $taxAmount,
                "discount_amount" => 0,
                "total_amount" => $totalAmount,
                "currency" => $currency,
                "items" => $invoiceItems,
                "status" => "pending",
                "notes" => "Monthly subscription invoice for {$plan->name} plan",
            ]);

            DB::commit();

            Log::info(
                "Generated monthly invoice {$invoiceNumber} for company {$company->name}",
                [
                    "company_id" => $company->id,
                    "invoice_id" => $invoice->id,
                    "amount" => $totalAmount,
                ],
            );

            return $invoice;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to generate monthly invoice for company {$company->id}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Generate manual invoice with custom items
     */
    public function generateManualInvoice(array $data): Invoice
    {
        DB::beginTransaction();

        try {
            $company = Company::findOrFail($data["company_id"]);

            // Validate items
            if (empty($data["items"]) || !is_array($data["items"])) {
                throw new \Exception("Invoice must contain at least one item");
            }

            // Generate invoice number
            $invoiceNumber = $this->generateInvoiceNumber($company, "MANUAL");

            // Calculate totals
            $subtotal = 0;
            $invoiceItems = [];

            foreach ($data["items"] as $item) {
                $quantity = $item["quantity"] ?? 1;
                $unitPrice = $item["unit_price"] ?? 0;
                $totalPrice = $quantity * $unitPrice;

                $subtotal += $totalPrice;

                $invoiceItems[] = [
                    "id" => Str::uuid()->toString(),
                    "description" => $item["description"],
                    "item_type" => $item["item_type"] ?? "manual",
                    "quantity" => $quantity,
                    "unit_price" => $unitPrice,
                    "total_price" => $totalPrice,
                    "total" => $totalPrice,
                    "currency" => $data["currency"] ?? ($company->currency ?? "USD"),
                    "metadata" => $item["metadata"] ?? null,
                ];
            }

            // Calculate tax
            $taxRate = $data["tax_rate"] ?? ($company->tax_rate ?? 0);
            $taxAmount = $subtotal * $taxRate;
            $totalAmount = $subtotal + $taxAmount;

            // Create invoice
            $invoice = Invoice::create([
                "id" => Str::uuid()->toString(),
                "company_id" => $company->id,
                ...(Schema::hasColumn('invoices', 'type') ? ["type" => "customer"] : []),
                "invoice_number" => $invoiceNumber,
                "period_start" =>
                    $data["period_start"] ?? Carbon::now()->startOfMonth(),
                "period_end" =>
                    $data["period_end"] ?? Carbon::now()->endOfMonth(),
                "issue_date" => Carbon::now(),
                "due_date" => $data["due_date"] ?? Carbon::now()->addDays(30),
                "subtotal" => $subtotal,
                "tax_amount" => $taxAmount,
                "discount_amount" => 0,
                "total_amount" => $totalAmount,
                "currency" =>
                    $data["currency"] ?? ($company->currency ?? "USD"),
                "items" => $invoiceItems,
                "status" => "pending",
                "notes" => $data["notes"] ?? null,
                "metadata" => $data["metadata"] ?? null,
            ]);

            DB::commit();

            Log::info(
                "Generated manual invoice {$invoiceNumber} for company {$company->name}",
                [
                    "company_id" => $company->id,
                    "invoice_id" => $invoice->id,
                    "amount" => $totalAmount,
                ],
            );

            return $invoice;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to generate manual invoice: " . $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Get invoice with items and payments
     */
    public function getInvoiceWithDetails(string $invoiceId): array
    {
        $invoice = Invoice::with([
            "payments",
            "company",
            "creditNotes",
        ])->findOrFail($invoiceId);

        $paidAmount = $invoice->payments->sum("amount");
        $remainingAmount = max(0, $invoice->total_amount - $paidAmount);

        $creditNoteAmount = $invoice->creditNotes
            ->where("status", "applied")
            ->sum("amount");

        return [
            "invoice" => $invoice,
            "paid_amount" => $paidAmount,
            "remaining_amount" => $remainingAmount,
            "credit_note_amount" => $creditNoteAmount,
            "is_overdue" =>
                $invoice->status === "pending" &&
                $invoice->due_date < Carbon::now(),
            "days_overdue" =>
                $invoice->due_date < Carbon::now()
                    ? Carbon::now()->diffInDays($invoice->due_date)
                    : 0,
        ];
    }

    /**
     * Update invoice status
     */
    public function updateInvoiceStatus(
        string $invoiceId,
        string $status,
        array $data = [],
    ): Invoice {
        $invoice = Invoice::findOrFail($invoiceId);

        $validStatuses = [
            "draft",
            "pending",
            "paid",
            "overdue",
            "cancelled",
            "refunded",
        ];
        if (!in_array($status, $validStatuses)) {
            throw new \Exception("Invalid invoice status: {$status}");
        }

        $updateData = ["status" => $status];

        if ($status === "paid") {
            $updateData["payment_date"] = Carbon::now();
            $updateData["method"] = $data["payment_method"] ?? null;
            $updateData["reference"] = $data["payment_reference"] ?? null;
        }

        $invoice->update($updateData);

        Log::info(
            "Updated invoice {$invoice->invoice_number} status to {$status}",
            [
                "invoice_id" => $invoice->id,
                "previous_status" => $invoice->getOriginal("status"),
            ],
        );

        return $invoice->fresh();
    }

    /**
     * Record payment for invoice
     */
    public function recordPayment(
        string $invoiceId,
        array $paymentData,
    ): Payment {
        DB::beginTransaction();

        try {
            $invoice = Invoice::findOrFail($invoiceId);

            // Validate payment amount
            $paidAmount = $invoice->payments->sum("amount");
            $remainingAmount = $invoice->total_amount - $paidAmount;

            if ($paymentData["amount"] > $remainingAmount) {
                throw new \Exception(
                    "Payment amount exceeds remaining invoice balance",
                );
            }

            // Create payment
            $payment = Payment::create([
                "id" => Str::uuid()->toString(),
                "invoice_id" => $invoice->id,
                "amount" => $paymentData["amount"],
                "currency" => $paymentData["currency"] ?? $invoice->currency,
                "method" => $paymentData["payment_method"],
                "payment_date" => $paymentData["payment_date"] ?? Carbon::now(),
                "reference" => $paymentData["payment_reference"] ?? null,
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
                    "method" => $paymentData["payment_method"],
                    "reference" => $paymentData["payment_reference"],
                ]);
            }

            DB::commit();

            Log::info(
                "Recorded payment for invoice {$invoice->invoice_number}",
                [
                    "invoice_id" => $invoice->id,
                    "payment_id" => $payment->id,
                    "amount" => $paymentData["amount"],
                ],
            );

            return $payment;
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to record payment for invoice {$invoiceId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Get companies with overdue invoices
     */
    public function getCompaniesWithOverdueInvoices(
        int $daysOverdue = 30,
    ): array {
        $overdueDate = Carbon::now()->subDays($daysOverdue);

        $companies = Company::whereHas("invoices", function ($query) use (
            $overdueDate,
        ) {
            $query
                ->where("status", "pending")
                ->where("due_date", "<", $overdueDate);
        })
            ->with([
                "invoices" => function ($query) use ($overdueDate) {
                    $query
                        ->where("status", "pending")
                        ->where("due_date", "<", $overdueDate)
                        ->orderBy("due_date", "asc");
                },
            ])
            ->get();

        $result = [];
        foreach ($companies as $company) {
            $overdueInvoices = $company->invoices;
            $totalOverdueAmount = $overdueInvoices->sum("total_amount");
            $oldestOverdue = $overdueInvoices->min("due_date");

            $result[] = [
                "company" => $company,
                "overdue_invoices_count" => $overdueInvoices->count(),
                "total_overdue_amount" => $totalOverdueAmount,
                "oldest_overdue_date" => $oldestOverdue,
                "days_overdue" => $oldestOverdue
                    ? Carbon::now()->diffInDays($oldestOverdue)
                    : 0,
            ];
        }

        // Sort by total overdue amount (descending)
        usort($result, function ($a, $b) {
            return $b["total_overdue_amount"] <=> $a["total_overdue_amount"];
        });

        return $result;
    }

    /**
     * Send invoice notification
     */
    public function sendInvoiceNotification(
        string $invoiceId,
        array $options = [],
    ): bool {
        $invoice = Invoice::with(["company"])->findOrFail($invoiceId);

        // Here you would integrate with your email service
        // For now, we'll log the notification

        $notificationData = [
            "invoice_id" => $invoice->id,
            "invoice_number" => $invoice->invoice_number,
            "company_id" => $invoice->company_id,
            "company_email" => $invoice->company->billing_email,
            "amount" => $invoice->total_amount,
            "due_date" => $invoice->due_date,
            "send_email" => $options["send_email"] ?? true,
            "send_sms" => $options["send_sms"] ?? false,
            "include_pdf" => $options["include_pdf"] ?? false,
        ];

        Log::info("Invoice notification sent", $notificationData);

        // Update last notification sent date in metadata
        $metadata = $invoice->metadata ?? [];
        $metadata["last_notification_sent_at"] = Carbon::now()->toISOString();
        $invoice->update(["metadata" => $metadata]);

        return true;
    }

    /**
     * Calculate usage charges based on plan and usage data
     */
    private function calculateUsageCharges(
        SubscriptionPlan $plan,
        array $usageData,
    ): float {
        $totalCharges = 0;

        foreach ($usageData as $item) {
            $itemType = $item["type"] ?? "unit_codes";
            $quantity = $item["quantity"] ?? 0;

            // Get base rate from plan
            $baseRate = $plan->overage_rate ?? 0.002; // Default $0.002 per unit code

            // Apply multipliers based on code type
            $multiplier = $this->getCodeTypeMultiplier($itemType);
            $unitPrice = $baseRate * $multiplier;

            $totalCharges += $quantity * $unitPrice;
        }

        return $totalCharges;
    }

    /**
     * Get multiplier for different code types
     */
    private function getCodeTypeMultiplier(string $codeType): float
    {
        $multipliers = [
            "unit_codes" => 1.0,
            "packet_codes" => 3.0,
            "carton_codes" => 5.0,
            "bundle_codes" => 10.0,
        ];

        return $multipliers[$codeType] ?? 1.0;
    }

    /**
     * Generate unique invoice number
     */
    private function generateInvoiceNumber(
        Company $company,
        string $prefix = "INV",
    ): string {
        $year = Carbon::now()->format("Y");
        $month = Carbon::now()->format("m");
        $companyCode = strtoupper(substr($company->name, 0, 3));

        // Get sequence number for this month
        $sequence =
            Invoice::where("company_id", $company->id)
                ->whereYear("issue_date", $year)
                ->whereMonth("issue_date", $month)
                ->count() + 1;

        return "{$prefix}-{$companyCode}-{$year}{$month}-" .
            str_pad($sequence, 4, "0", STR_PAD_LEFT);
    }

    /**
     * Get invoice statistics
     */
    public function getInvoiceStatistics(array $filters = []): array
    {
        $query = Invoice::query();

        // Apply filters
        if (!empty($filters["company_id"])) {
            $query->where("company_id", $filters["company_id"]);
        }

        if (!empty($filters["status"])) {
            $query->where("status", $filters["status"]);
        }

        if (!empty($filters["type"])) {
            $query->where("type", $filters["type"]);
        }

        if (!empty($filters["date_from"])) {
            $query->where("issue_date", ">=", $filters["date_from"]);
        }

        if (!empty($filters["date_to"])) {
            $query->where("issue_date", "<=", $filters["date_to"]);
        }

        $totalInvoices = $query->count();
        $totalAmount = $query->sum("total_amount");
        $paidAmount = $query->where("status", "paid")->sum("total_amount");
        $pendingAmount = $query
            ->where("status", "pending")
            ->sum("total_amount");
        $overdueAmount = $query
            ->where("status", "pending")
            ->where("due_date", "<", Carbon::now())
            ->sum("total_amount");

        return [
            "total_invoices" => $totalInvoices,
            "total_amount" => (float) $totalAmount,
            "paid_amount" => (float) $paidAmount,
            "pending_amount" => (float) $pendingAmount,
            "overdue_amount" => (float) $overdueAmount,
            "collection_rate" =>
                $totalAmount > 0 ? ($paidAmount / $totalAmount) * 100 : 0,
        ];
    }

    /**
     * Add item to existing invoice
     */
    public function addItemToInvoice(
        string $invoiceId,
        array $itemData,
    ): Invoice {
        DB::beginTransaction();

        try {
            $invoice = Invoice::findOrFail($invoiceId);

            if ($invoice->status !== "pending") {
                throw new \Exception(
                    "Cannot add items to invoice with status: {$invoice->status}",
                );
            }

            // Get current items
            $items = $invoice->items ?? [];

            // Add new item with ID
            $newItem = [
                "id" => Str::uuid()->toString(),
                "description" => $itemData["description"],
                "item_type" => $itemData["item_type"] ?? "manual",
                "quantity" => $itemData["quantity"] ?? 1,
                "unit_price" => $itemData["unit_price"] ?? 0,
                "total_price" =>
                    ($itemData["quantity"] ?? 1) *
                    ($itemData["unit_price"] ?? 0),
                "metadata" => $itemData["metadata"] ?? null,
            ];

            $items[] = $newItem;

            // Recalculate totals
            $subtotal = array_sum(array_column($items, "total_price"));
            $taxAmount = $subtotal * $invoice->tax_rate;
            $totalAmount = $subtotal + $taxAmount;

            // Update invoice
            $invoice->update([
                "items" => $items,
                "subtotal" => $subtotal,
                "tax_amount" => $taxAmount,
                "total_amount" => $totalAmount,
            ]);

            DB::commit();

            Log::info("Added item to invoice {$invoice->invoice_number}", [
                "invoice_id" => $invoice->id,
                "item_id" => $newItem["id"],
                "amount" => $newItem["total_price"],
            ]);

            return $invoice->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to add item to invoice {$invoiceId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Get invoice statistics by period
     */
    public function getInvoiceStatisticsByPeriod(
        string $periodType = "monthly",
        array $filters = [],
    ): array {
        $query = Invoice::query();

        // Apply filters
        if (!empty($filters["company_id"])) {
            $query->where("company_id", $filters["company_id"]);
        }

        if (!empty($filters["type"])) {
            $query->where("type", $filters["type"]);
        }

        // Group by period
        switch ($periodType) {
            case "daily":
                $query
                    ->selectRaw(
                        'DATE(issue_date) as period, COUNT(*) as invoice_count, SUM(total_amount) as total_amount, SUM(CASE WHEN status = "paid" THEN total_amount ELSE 0 END) as paid_amount',
                    )
                    ->groupBy(DB::raw("DATE(issue_date)"))
                    ->orderBy("period", "desc");
                break;

            case "weekly":
                $query
                    ->selectRaw(
                        'YEAR(issue_date) as year, WEEK(issue_date) as week, COUNT(*) as invoice_count, SUM(total_amount) as total_amount, SUM(CASE WHEN status = "paid" THEN total_amount ELSE 0 END) as paid_amount',
                    )
                    ->groupBy("year", "week")
                    ->orderBy("year", "desc")
                    ->orderBy("week", "desc");
                break;

            case "monthly":
            default:
                $query
                    ->selectRaw(
                        'YEAR(issue_date) as year, MONTH(issue_date) as month, COUNT(*) as invoice_count, SUM(total_amount) as total_amount, SUM(CASE WHEN status = "paid" THEN total_amount ELSE 0 END) as paid_amount',
                    )
                    ->groupBy("year", "month")
                    ->orderBy("year", "desc")
                    ->orderBy("month", "desc");
                break;

            case "yearly":
                $query
                    ->selectRaw(
                        'YEAR(issue_date) as year, COUNT(*) as invoice_count, SUM(total_amount) as total_amount, SUM(CASE WHEN status = "paid" THEN total_amount ELSE 0 END) as paid_amount',
                    )
                    ->groupBy("year")
                    ->orderBy("year", "desc");
                break;
        }

        $results = $query->get();

        // Format results
        $formattedResults = [];
        foreach ($results as $result) {
            $periodLabel = $this->formatPeriodLabel($periodType, $result);

            $formattedResults[] = [
                "period" => $periodLabel,
                "invoice_count" => (int) $result->invoice_count,
                "total_amount" => (float) $result->total_amount,
                "paid_amount" => (float) $result->paid_amount,
                "collection_rate" =>
                    $result->total_amount > 0
                        ? ($result->paid_amount / $result->total_amount) * 100
                        : 0,
            ];
        }

        return $formattedResults;
    }

    /**
     * Format period label based on period type
     */
    private function formatPeriodLabel(string $periodType, $result): string
    {
        switch ($periodType) {
            case "daily":
                return Carbon::parse($result->period)->format("Y-m-d");

            case "weekly":
                return "{$result->year} W{$result->week}";

            case "monthly":
                return Carbon::create($result->year, $result->month, 1)->format(
                    "Y-m",
                );

            case "yearly":
                return (string) $result->year;

            default:
                return "{$result->year}-{$result->month}";
        }
    }

    /**
     * Get overdue invoice analysis
     */
    public function getOverdueInvoiceAnalysis(int $daysThreshold = 30): array
    {
        $overdueDate = Carbon::now()->subDays($daysThreshold);

        $overdueInvoices = Invoice::where("status", "pending")
            ->where("due_date", "<", $overdueDate)
            ->with(["company", "payments"])
            ->get();

        $analysis = [
            "total_overdue_invoices" => $overdueInvoices->count(),
            "total_overdue_amount" => $overdueInvoices->sum("total_amount"),
            "average_days_overdue" => 0,
            "by_company" => [],
            "by_age_bucket" => [
                "30-60_days" => ["count" => 0, "amount" => 0],
                "61-90_days" => ["count" => 0, "amount" => 0],
                "91-180_days" => ["count" => 0, "amount" => 0],
                "over_180_days" => ["count" => 0, "amount" => 0],
            ],
        ];

        $totalDaysOverdue = 0;

        foreach ($overdueInvoices as $invoice) {
            $daysOverdue = Carbon::now()->diffInDays($invoice->due_date);
            $totalDaysOverdue += $daysOverdue;

            // Group by company
            $companyId = $invoice->company_id;
            if (!isset($analysis["by_company"][$companyId])) {
                $analysis["by_company"][$companyId] = [
                    "company_name" => $invoice->company->name ?? "Unknown",
                    "invoice_count" => 0,
                    "total_amount" => 0,
                    "average_days_overdue" => 0,
                ];
            }

            $analysis["by_company"][$companyId]["invoice_count"]++;
            $analysis["by_company"][$companyId]["total_amount"] +=
                $invoice->total_amount;

            // Group by age bucket
            if ($daysOverdue <= 60) {
                $bucket = "30-60_days";
            } elseif ($daysOverdue <= 90) {
                $bucket = "61-90_days";
            } elseif ($daysOverdue <= 180) {
                $bucket = "91-180_days";
            } else {
                $bucket = "over_180_days";
            }

            $analysis["by_age_bucket"][$bucket]["count"]++;
            $analysis["by_age_bucket"][$bucket]["amount"] +=
                $invoice->total_amount;
        }

        // Calculate averages
        if ($analysis["total_overdue_invoices"] > 0) {
            $analysis["average_days_overdue"] = round(
                $totalDaysOverdue / $analysis["total_overdue_invoices"],
                1,
            );
        }

        // Sort companies by total overdue amount (descending)
        uasort($analysis["by_company"], function ($a, $b) {
            return $b["total_amount"] <=> $a["total_amount"];
        });

        return $analysis;
    }
}
