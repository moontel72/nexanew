<?php

namespace App\Services;

use App\Models\CreditNote;
use App\Models\Invoice;
use App\Models\Company;
use App\Models\Payment;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class CreditNoteService
{
    /**
     * Create a credit note
     */
    public function createCreditNote(array $data): CreditNote
    {
        DB::beginTransaction();

        try {
            // Validate required data
            $this->validateCreditNoteData($data);

            $invoice = Invoice::with("company")->findOrFail(
                $data["invoice_id"],
            );
            $company = $invoice->company;

            // Validate credit note amount
            $this->validateCreditNoteAmount($invoice, $data["amount"]);

            // Generate credit note number
            $creditNoteNumber = $this->generateCreditNoteNumber($company);

            // Create credit note
            $creditNote = CreditNote::create([
                "id" => Str::uuid()->toString(),
                "company_id" => $company->id,
                "invoice_id" => $invoice->id,
                "credit_note_number" => $creditNoteNumber,
                "amount" => $data["amount"],
                "currency" => $data["currency"] ?? $invoice->currency,
                "reason" => $data["reason"],
                "status" => "pending",
                "issue_date" => Carbon::now(),
                "approved_by" => null,
                "approved_at" => null,
                "applied_to_invoice" => false,
                "applied_at" => null,
                "notes" => $data["notes"] ?? null,
                "metadata" => $data["metadata"] ?? null,
            ]);

            // If auto-approve is enabled, approve the credit note
            if ($data["auto_approve"] ?? false) {
                $this->approveCreditNote($creditNote->id, [
                    "approved_by" => $data["created_by"] ?? null,
                    "approval_notes" => "Auto-approved during creation",
                ]);
            }

            DB::commit();

            Log::info("Credit note created", [
                "credit_note_id" => $creditNote->id,
                "credit_note_number" => $creditNoteNumber,
                "invoice_id" => $invoice->id,
                "amount" => $data["amount"],
                "company_id" => $company->id,
            ]);

            return $creditNote->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to create credit note: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Approve a credit note
     */
    public function approveCreditNote(
        string $creditNoteId,
        array $approvalData,
    ): CreditNote {
        DB::beginTransaction();

        try {
            $creditNote = CreditNote::with(["invoice", "company"])->findOrFail(
                $creditNoteId,
            );

            if ($creditNote->status !== "pending") {
                throw new \Exception("Credit note is not in pending status");
            }

            // Validate approval data
            if (empty($approvalData["approved_by"])) {
                throw new \Exception("Approver information is required");
            }

            // Update credit note status
            $creditNote->update([
                "status" => "approved",
                "approved_by" => $approvalData["approved_by"],
                "approved_at" => Carbon::now(),
                "metadata" => array_merge($creditNote->metadata ?? [], [
                    "approval_notes" => $approvalData["approval_notes"] ?? null,
                ]),
            ]);

            // If auto-apply is enabled, apply to invoice
            if ($approvalData["auto_apply"] ?? false) {
                $this->applyCreditNoteToInvoice($creditNoteId, [
                    "applied_by" => $approvalData["approved_by"],
                    "apply_notes" => "Auto-applied after approval",
                ]);
            }

            DB::commit();

            Log::info("Credit note approved", [
                "credit_note_id" => $creditNote->id,
                "approved_by" => $approvalData["approved_by"],
                "amount" => $creditNote->amount,
            ]);

            return $creditNote->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to approve credit note {$creditNoteId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Apply credit note to invoice
     */
    public function applyCreditNoteToInvoice(
        string $creditNoteId,
        array $applicationData,
    ): array {
        DB::beginTransaction();

        try {
            $creditNote = CreditNote::with(["invoice", "company"])->findOrFail(
                $creditNoteId,
            );

            if ($creditNote->status !== "approved") {
                throw new \Exception(
                    "Credit note must be approved before applying",
                );
            }

            if ($creditNote->applied_to_invoice) {
                throw new \Exception(
                    "Credit note is already applied to invoice",
                );
            }

            $invoice = $creditNote->invoice;

            // Check if invoice can accept credit note
            $this->validateInvoiceForCreditNote($invoice, $creditNote);

            // Calculate remaining invoice balance
            $paidAmount = $invoice->payments()->sum("amount");
            $remainingBalance = $invoice->total_amount - $paidAmount;

            // Determine how much of the credit note to apply
            $applyAmount = min($creditNote->amount, $remainingBalance);

            if ($applyAmount <= 0) {
                throw new \Exception(
                    "Invoice has no remaining balance to apply credit note to",
                );
            }

            // Create payment record for the credit note application
            $payment = Payment::create([
                "id" => Str::uuid()->toString(),
                "invoice_id" => $invoice->id,
                "amount" => $applyAmount,
                "currency" => $creditNote->currency,
                "method" => "credit_note",
                "payment_date" => Carbon::now(),
                "reference" => $creditNote->credit_note_number,
                "transaction_id" => null,
                "notes" => "Applied credit note: " . $creditNote->reason,
                "metadata" => [
                    "credit_note_id" => $creditNote->id,
                    "applied_by" => $applicationData["applied_by"] ?? null,
                ],
            ]);

            // Update credit note status
            $creditNote->update([
                "status" => "applied",
                "applied_to_invoice" => true,
                "applied_at" => Carbon::now(),
                "metadata" => array_merge($creditNote->metadata ?? [], [
                    "applied_amount" => $applyAmount,
                    "application_notes" =>
                        $applicationData["apply_notes"] ?? null,
                    "applied_by" => $applicationData["applied_by"] ?? null,
                ]),
            ]);

            // Update invoice status if fully paid
            $newPaidAmount = $paidAmount + $applyAmount;
            if (abs($newPaidAmount - $invoice->total_amount) < 0.01) {
                $invoice->update([
                    "status" => "paid",
                    "payment_date" => Carbon::now(),
                ]);
            }

            // Handle remaining credit note amount if any
            $remainingCreditAmount = $creditNote->amount - $applyAmount;
            $remainingCreditNote = null;

            if ($remainingCreditAmount > 0) {
                // Create a new credit note for the remaining amount
                $remainingCreditNote = $this->createRemainingCreditNote(
                    $creditNote,
                    $remainingCreditAmount,
                    $applicationData,
                );
            }

            DB::commit();

            Log::info("Credit note applied to invoice", [
                "credit_note_id" => $creditNote->id,
                "invoice_id" => $invoice->id,
                "applied_amount" => $applyAmount,
                "remaining_amount" => $remainingCreditAmount,
                "payment_id" => $payment->id,
            ]);

            return [
                "credit_note" => $creditNote->fresh(),
                "payment" => $payment,
                "remaining_credit_note" => $remainingCreditNote,
                "applied_amount" => $applyAmount,
                "remaining_amount" => $remainingCreditAmount,
                "invoice_new_balance" => max(
                    0,
                    $remainingBalance - $applyAmount,
                ),
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to apply credit note {$creditNoteId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Cancel a credit note
     */
    public function cancelCreditNote(
        string $creditNoteId,
        array $cancellationData,
    ): CreditNote {
        DB::beginTransaction();

        try {
            $creditNote = CreditNote::findOrFail($creditNoteId);

            if (!in_array($creditNote->status, ["pending", "approved"])) {
                throw new \Exception(
                    "Credit note cannot be cancelled in current status",
                );
            }

            // Update credit note status
            $creditNote->update([
                "status" => "cancelled",
                "metadata" => array_merge($creditNote->metadata ?? [], [
                    "cancelled_by" => $cancellationData["cancelled_by"] ?? null,
                    "cancellation_reason" =>
                        $cancellationData["cancellation_reason"] ?? null,
                    "cancellation_notes" =>
                        $cancellationData["cancellation_notes"] ?? null,
                    "cancelled_at" => Carbon::now()->toISOString(),
                ]),
            ]);

            DB::commit();

            Log::info("Credit note cancelled", [
                "credit_note_id" => $creditNote->id,
                "cancelled_by" => $cancellationData["cancelled_by"] ?? null,
                "reason" => $cancellationData["cancellation_reason"] ?? null,
            ]);

            return $creditNote->fresh();
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error(
                "Failed to cancel credit note {$creditNoteId}: " .
                    $e->getMessage(),
            );
            throw $e;
        }
    }

    /**
     * Get credit notes with filters
     */
    public function getCreditNotes(array $filters = []): array
    {
        $query = CreditNote::with(["invoice", "company"]);

        // Apply filters
        if (!empty($filters["company_id"])) {
            $query->where("company_id", $filters["company_id"]);
        }

        if (!empty($filters["invoice_id"])) {
            $query->where("invoice_id", $filters["invoice_id"]);
        }

        if (!empty($filters["status"])) {
            $query->where("status", $filters["status"]);
        }

        if (!empty($filters["reason"])) {
            $query->where("reason", "like", "%" . $filters["reason"] . "%");
        }

        if (!empty($filters["date_from"])) {
            $query->where("issue_date", ">=", $filters["date_from"]);
        }

        if (!empty($filters["date_to"])) {
            $query->where("issue_date", "<=", $filters["date_to"]);
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
        $sortBy = $filters["sort_by"] ?? "issue_date";
        $sortOrder = $filters["sort_order"] ?? "desc";
        $query->orderBy($sortBy, $sortOrder);

        // Apply pagination
        $perPage = $filters["per_page"] ?? 50;
        $page = $filters["page"] ?? 1;
        $creditNotes = $query->paginate($perPage, ["*"], "page", $page);

        // Calculate summary statistics
        $summary = $this->calculateCreditNotesSummary($creditNotes);

        // Get credit note statistics by status
        $statusStats = $this->getCreditNoteStatusStatistics($filters);

        // Get credit note trend
        $trend = $this->getCreditNoteTrend($filters);

        return [
            "credit_notes" => $creditNotes->items(),
            "pagination" => [
                "total" => $total,
                "per_page" => $perPage,
                "current_page" => $page,
                "total_pages" => $creditNotes->lastPage(),
                "has_more" => $creditNotes->hasMorePages(),
            ],
            "summary" => $summary,
            "status_statistics" => $statusStats,
            "trend" => $trend,
            "top_reasons" => $this->getTopCreditNoteReasons($filters),
            "company_breakdown" => $this->getCreditNoteCompanyBreakdown(
                $filters,
            ),
        ];
    }

    /**
     * Get credit note by ID with details
     */
    public function getCreditNoteWithDetails(string $creditNoteId): array
    {
        $creditNote = CreditNote::with([
            "invoice",
            "company",
            "approvedByUser",
        ])->findOrFail($creditNoteId);

        // Get related payments
        $payments = Payment::where(
            "metadata->credit_note_id",
            $creditNoteId,
        )->get();

        // Get audit trail from metadata
        $auditTrail = $this->extractAuditTrailFromMetadata($creditNote);

        // Calculate utilization
        $utilization = $this->calculateCreditNoteUtilization($creditNote);

        return [
            "credit_note" => $creditNote,
            "related_payments" => $payments,
            "audit_trail" => $auditTrail,
            "utilization" => $utilization,
            "available_actions" => $this->getAvailableActions($creditNote),
            "timeline" => $this->buildCreditNoteTimeline($creditNote),
        ];
    }

    /**
     * Get available credit for a company
     */
    public function getCompanyAvailableCredit(string $companyId): array
    {
        $company = Company::findOrFail($companyId);

        // Get approved but not applied credit notes
        $availableCreditNotes = CreditNote::where("company_id", $companyId)
            ->where("status", "approved")
            ->where("applied_to_invoice", false)
            ->get();

        $totalAvailableCredit = $availableCreditNotes->sum("amount");

        // Get pending credit notes
        $pendingCreditNotes = CreditNote::where("company_id", $companyId)
            ->where("status", "pending")
            ->get();

        $totalPendingCredit = $pendingCreditNotes->sum("amount");

        // Get applied credit notes (last 12 months)
        $appliedCreditNotes = CreditNote::where("company_id", $companyId)
            ->where("status", "applied")
            ->where("applied_at", ">=", Carbon::now()->subMonths(12))
            ->get();

        $totalAppliedCredit = $appliedCreditNotes->sum("amount");

        // Get invoices that could use credit
        $eligibleInvoices = Invoice::where("company_id", $companyId)
            ->where("status", "pending")
            ->where("due_date", ">=", Carbon::now()->subDays(30))
            ->with(["payments"])
            ->get()
            ->map(function ($invoice) {
                $paidAmount = $invoice->payments->sum("amount");
                $remainingBalance = $invoice->total_amount - $paidAmount;

                return [
                    "invoice" => $invoice,
                    "remaining_balance" => $remainingBalance,
                    "days_overdue" =>
                        $invoice->due_date < Carbon::now()
                            ? Carbon::now()->diffInDays($invoice->due_date)
                            : 0,
                ];
            })
            ->filter(function ($item) {
                return $item["remaining_balance"] > 0;
            })
            ->sortByDesc("remaining_balance")
            ->values();

        return [
            "company" => [
                "id" => $company->id,
                "name" => $company->name,
                "credit_limit" => $company->credit_limit ?? 0,
                "credit_utilization" => $company->credit_utilization ?? 0,
            ],
            "credit_summary" => [
                "total_available_credit" => round($totalAvailableCredit, 2),
                "total_pending_credit" => round($totalPendingCredit, 2),
                "total_applied_credit_12m" => round($totalAppliedCredit, 2),
                "available_credit_notes_count" => $availableCreditNotes->count(),
                "pending_credit_notes_count" => $pendingCreditNotes->count(),
            ],
            "available_credit_notes" => $availableCreditNotes,
            "eligible_invoices" => $eligibleInvoices,
            "credit_utilization_trend" => $this->getCompanyCreditUtilizationTrend(
                $companyId,
            ),
            "recommendations" => $this->generateCreditUtilizationRecommendations(
                $totalAvailableCredit,
                $eligibleInvoices,
            ),
        ];
    }

    /**
     * Generate credit note report
     */
    public function generateCreditNoteReport(array $options = []): array
    {
        $dateRange = $this->parseDateRange($options);
        $startDate = $dateRange["start"];
        $endDate = $dateRange["end"];

        $reportType = $options["type"] ?? "summary";

        switch ($reportType) {
            case "summary":
                return $this->generateCreditNoteSummaryReport(
                    $startDate,
                    $endDate,
                );
            case "detailed":
                return $this->generateCreditNoteDetailedReport(
                    $startDate,
                    $endDate,
                );
            case "aging":
                return $this->generateCreditNoteAgingReport(
                    $startDate,
                    $endDate,
                );
            case "reason_analysis":
                return $this->generateCreditNoteReasonAnalysisReport(
                    $startDate,
                    $endDate,
                );
            default:
                throw new \Exception("Unsupported report type: {$reportType}");
        }
    }

    /**
     * Validate credit note data
     */
    private function validateCreditNoteData(array $data): void
    {
        $requiredFields = ["invoice_id", "amount", "reason"];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                throw new \Exception("Missing required field: {$field}");
            }
        }

        if (!is_numeric($data["amount"]) || $data["amount"] <= 0) {
            throw new \Exception("Invalid credit note amount");
        }
    }

    /**
     * Validate credit note amount
     */
    private function validateCreditNoteAmount(
        Invoice $invoice,
        float $amount,
    ): void {
        $maxAmount = $invoice->total_amount * 1.5; // Allow up to 150% of invoice amount
        if ($amount > $maxAmount) {
            throw new \Exception(
                "Credit note amount exceeds maximum allowed ({$maxAmount})",
            );
        }

        if ($amount > $invoice->total_amount) {
            Log::warning("Credit note amount exceeds invoice amount", [
                "invoice_id" => $invoice->id,
                "invoice_amount" => $invoice->total_amount,
                "credit_note_amount" => $amount,
            ]);
        }
    }

    /**
     * Generate credit note number
     */
    private function generateCreditNoteNumber(Company $company): string
    {
        $year = Carbon::now()->format("Y");
        $month = Carbon::now()->format("m");
        $companyCode = strtoupper(substr($company->name, 0, 3));

        // Get sequence number for this month
        $sequence =
            CreditNote::where("company_id", $company->id)
                ->whereYear("issue_date", $year)
                ->whereMonth("issue_date", $month)
                ->count() + 1;

        return "CN-{$companyCode}-{$year}{$month}-" .
            str_pad($sequence, 4, "0", STR_PAD_LEFT);
    }

    /**
     * Validate invoice for credit note
     */
    private function validateInvoiceForCreditNote(
        Invoice $invoice,
        CreditNote $creditNote,
    ): void {
        if ($invoice->status === "cancelled") {
            throw new \Exception(
                "Cannot apply credit note to cancelled invoice",
            );
        }

        if ($invoice->status === "refunded") {
            throw new \Exception(
                "Cannot apply credit note to refunded invoice",
            );
        }

        if ($creditNote->currency !== $invoice->currency) {
            throw new \Exception(
                "Currency mismatch between credit note and invoice",
            );
        }
    }

    /**
     * Create remaining credit note
     */
    private function createRemainingCreditNote(
        CreditNote $originalCreditNote,
        float $remainingAmount,
        array $applicationData,
    ): CreditNote {
        $remainingCreditNote = CreditNote::create([
            "id" => \Illuminate\Support\Str::uuid()->toString(),
            "company_id" => $originalCreditNote->company_id,
            "invoice_id" => $originalCreditNote->invoice_id,
            "credit_note_number" =>
                $this->generateCreditNoteNumber($originalCreditNote->company) .
                "-R",
            "amount" => $remainingAmount,
            "currency" => $originalCreditNote->currency,
            "reason" => $originalCreditNote->reason . " (Remaining)",
            "status" => "approved",
            "issue_date" => Carbon::now(),
            "approved_by" => $originalCreditNote->approved_by,
            "approved_at" => Carbon::now(),
            "applied_to_invoice" => false,
            "notes" =>
                "Remaining amount from credit note " .
                $originalCreditNote->credit_note_number,
            "metadata" => [
                "original_credit_note_id" => $originalCreditNote->id,
                "applied_amount" =>
                    $originalCreditNote->amount - $remainingAmount,
                "created_by" => $applicationData["applied_by"] ?? null,
            ],
        ]);

        Log::info("Remaining credit note created", [
            "original_credit_note_id" => $originalCreditNote->id,
            "remaining_credit_note_id" => $remainingCreditNote->id,
            "remaining_amount" => $remainingAmount,
        ]);

        return $remainingCreditNote;
    }

    /**
     * Calculate credit notes summary
     */
    private function calculateCreditNotesSummary(Collection $creditNotes): array
    {
        $totalAmount = $creditNotes->sum("amount");
        $approvedAmount = $creditNotes
            ->where("status", "approved")
            ->sum("amount");
        $appliedAmount = $creditNotes
            ->where("status", "applied")
            ->sum("amount");
        $pendingAmount = $creditNotes
            ->where("status", "pending")
            ->sum("amount");
        $cancelledAmount = $creditNotes
            ->where("status", "cancelled")
            ->sum("amount");

        return [
            "total_amount" => round($totalAmount, 2),
            "approved_amount" => round($approvedAmount, 2),
            "applied_amount" => round($appliedAmount, 2),
            "pending_amount" => round($pendingAmount, 2),
            "cancelled_amount" => round($cancelledAmount, 2),
            "utilization_rate" =>
                $totalAmount > 0
                    ? round(($appliedAmount / $totalAmount) * 100, 2)
                    : 0,
        ];
    }

    /**
     * Get credit note status statistics
     */
    private function getCreditNoteStatusStatistics(array $filters = []): array
    {
        $query = CreditNote::query();

        // Apply filters
        if (!empty($filters["company_id"])) {
            $query->where("company_id", $filters["company_id"]);
        }

        if (!empty($filters["date_from"])) {
            $query->where("issue_date", ">=", $filters["date_from"]);
        }

        if (!empty($filters["date_to"])) {
            $query->where("issue_date", "<=", $filters["date_to"]);
        }

        $stats = $query
            ->selectRaw(
                "status, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("status")
            ->get()
            ->mapWithKeys(function ($item) {
                return [
                    $item->status => [
                        "count" => (int) $item->count,
                        "total_amount" => (float) $item->total_amount,
                    ],
                ];
            });

        return $stats->toArray();
    }

    /**
     * Get credit note trend
     */
    private function getCreditNoteTrend(array $filters = []): array
    {
        $query = CreditNote::query();

        // Apply filters
        if (!empty($filters["company_id"])) {
            $query->where("company_id", $filters["company_id"]);
        }

        $trend = $query
            ->selectRaw(
                "YEAR(issue_date) as year, MONTH(issue_date) as month, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("year", "month")
            ->orderBy("year", "desc")
            ->orderBy("month", "desc")
            ->limit(12)
            ->get()
            ->map(function ($item) {
                return [
                    "period" => Carbon::create(
                        $item->year,
                        $item->month,
                        1,
                    )->format("Y-m"),
                    "period_label" => Carbon::create(
                        $item->year,
                        $item->month,
                        1,
                    )->format("M Y"),
                    "count" => (int) $item->count,
                    "total_amount" => (float) $item->total_amount,
                    "average_amount" =>
                        $item->count > 0
                            ? $item->total_amount / $item->count
                            : 0,
                ];
            });

        return $trend->values()->toArray();
    }

    /**
     * Get top credit note reasons
     */
    private function getTopCreditNoteReasons(array $filters = []): array
    {
        $query = CreditNote::query();

        // Apply filters
        if (!empty($filters["company_id"])) {
            $query->where("company_id", $filters["company_id"]);
        }

        if (!empty($filters["date_from"])) {
            $query->where("issue_date", ">=", $filters["date_from"]);
        }

        if (!empty($filters["date_to"])) {
            $query->where("issue_date", "<=", $filters["date_to"]);
        }

        $reasons = $query
            ->selectRaw(
                "reason, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("reason")
            ->orderByDesc("count")
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    "reason" => $item->reason,
                    "count" => (int) $item->count,
                    "total_amount" => (float) $item->total_amount,
                    "average_amount" =>
                        $item->count > 0
                            ? $item->total_amount / $item->count
                            : 0,
                ];
            });

        return $reasons->toArray();
    }

    /**
     * Get credit note company breakdown
     */
    private function getCreditNoteCompanyBreakdown(array $filters = []): array
    {
        $query = CreditNote::with("company");

        // Apply filters
        if (!empty($filters["date_from"])) {
            $query->where("issue_date", ">=", $filters["date_from"]);
        }

        if (!empty($filters["date_to"])) {
            $query->where("issue_date", "<=", $filters["date_to"]);
        }

        $breakdown = $query
            ->selectRaw(
                "company_id, COUNT(*) as count, SUM(amount) as total_amount",
            )
            ->groupBy("company_id")
            ->orderByDesc("total_amount")
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    "company_id" => $item->company_id,
                    "company_name" => $item->company->name ?? "Unknown",
                    "count" => (int) $item->count,
                    "total_amount" => (float) $item->total_amount,
                ];
            });

        return $breakdown->toArray();
    }

    /**
     * Extract audit trail from metadata
     */
    private function extractAuditTrailFromMetadata(
        CreditNote $creditNote,
    ): array {
        $metadata = $creditNote->metadata ?? [];
        $auditTrail = [];

        if (!empty($metadata["created_by"])) {
            $auditTrail[] = [
                "action" => "created",
                "by" => $metadata["created_by"],
                "at" => $creditNote->created_at->toISOString(),
                "notes" => "Credit note created",
            ];
        }

        if ($creditNote->approved_at) {
            $auditTrail[] = [
                "action" => "approved",
                "by" => $creditNote->approved_by,
                "at" => $creditNote->approved_at->toISOString(),
                "notes" =>
                    $metadata["approval_notes"] ?? "Credit note approved",
            ];
        }

        if ($creditNote->applied_at) {
            $auditTrail[] = [
                "action" => "applied",
                "by" => $metadata["applied_by"] ?? null,
                "at" => $creditNote->applied_at->toISOString(),
                "notes" =>
                    $metadata["application_notes"] ??
                    "Credit note applied to invoice",
            ];
        }

        if (!empty($metadata["cancelled_at"])) {
            $auditTrail[] = [
                "action" => "cancelled",
                "by" => $metadata["cancelled_by"] ?? null,
                "at" => $metadata["cancelled_at"],
                "notes" =>
                    $metadata["cancellation_notes"] ?? "Credit note cancelled",
            ];
        }

        return $auditTrail;
    }

    /**
     * Calculate credit note utilization
     */
    private function calculateCreditNoteUtilization(
        CreditNote $creditNote,
    ): array {
        if ($creditNote->status !== "applied") {
            return [
                "utilized_amount" => 0,
                "utilized_percentage" => 0,
                "remaining_amount" => $creditNote->amount,
                "remaining_percentage" => 100,
            ];
        }

        $appliedAmount =
            $creditNote->metadata["applied_amount"] ?? $creditNote->amount;
        $utilizedPercentage = ($appliedAmount / $creditNote->amount) * 100;
        $remainingAmount = $creditNote->amount - $appliedAmount;
        $remainingPercentage = 100 - $utilizedPercentage;

        return [
            "utilized_amount" => round($appliedAmount, 2),
            "utilized_percentage" => round($utilizedPercentage, 2),
            "remaining_amount" => round($remainingAmount, 2),
            "remaining_percentage" => round($remainingPercentage, 2),
        ];
    }

    /**
     * Get available actions for credit note
     */
    private function getAvailableActions(CreditNote $creditNote): array
    {
        $actions = [];

        switch ($creditNote->status) {
            case "pending":
                $actions = ["approve", "cancel", "edit"];
                break;
            case "approved":
                $actions = ["apply", "cancel", "split"];
                break;
            case "applied":
                $actions = ["view", "download"];
                break;
            case "cancelled":
                $actions = ["view", "reactivate"];
                break;
        }

        return $actions;
    }

    /**
     * Build credit note timeline
     */
    private function buildCreditNoteTimeline(CreditNote $creditNote): array
    {
        $timeline = [
            [
                "event" => "created",
                "date" => $creditNote->created_at->toISOString(),
                "description" => "Credit note created",
                "status" => "completed",
            ],
        ];

        if ($creditNote->approved_at) {
            $timeline[] = [
                "event" => "approved",
                "date" => $creditNote->approved_at->toISOString(),
                "description" => "Credit note approved",
                "status" => "completed",
            ];
        }

        if ($creditNote->applied_at) {
            $timeline[] = [
                "event" => "applied",
                "date" => $creditNote->applied_at->toISOString(),
                "description" => "Applied to invoice",
                "status" => "completed",
            ];
        }

        if ($creditNote->status === "cancelled") {
            $timeline[] = [
                "event" => "cancelled",
                "date" => $creditNote->updated_at->toISOString(),
                "description" => "Credit note cancelled",
                "status" => "completed",
            ];
        }

        // Add future events based on current status
        if ($creditNote->status === "pending") {
            $timeline[] = [
                "event" => "approval",
                "date" => null,
                "description" => "Awaiting approval",
                "status" => "pending",
            ];
        }

        if ($creditNote->status === "approved") {
            $timeline[] = [
                "event" => "application",
                "date" => null,
                "description" => "Ready for application",
                "status" => "pending",
            ];
        }

        return $timeline;
    }

    /**
     * Get company credit utilization trend
     */
    private function getCompanyCreditUtilizationTrend(string $companyId): array
    {
        $trend = CreditNote::where("company_id", $companyId)
            ->where("status", "applied")
            ->selectRaw(
                "YEAR(applied_at) as year, MONTH(applied_at) as month, SUM(amount) as total_applied",
            )
            ->groupBy("year", "month")
            ->orderBy("year", "desc")
            ->orderBy("month", "desc")
            ->limit(6)
            ->get()
            ->map(function ($item) {
                return [
                    "period" => Carbon::create(
                        $item->year,
                        $item->month,
                        1,
                    )->format("Y-m"),
                    "period_label" => Carbon::create(
                        $item->year,
                        $item->month,
                        1,
                    )->format("M Y"),
                    "total_applied" => (float) $item->total_applied,
                ];
            });

        return $trend->values()->toArray();
    }

    /**
     * Generate credit utilization recommendations
     */
    private function generateCreditUtilizationRecommendations(
        float $availableCredit,
        array $eligibleInvoices,
    ): array {
        $recommendations = [];

        if ($availableCredit <= 0) {
            $recommendations[] = [
                "type" => "info",
                "message" => "No available credit to utilize",
                "priority" => "low",
            ];
            return $recommendations;
        }

        $totalEligibleBalance = array_sum(
            array_column($eligibleInvoices, "remaining_balance"),
        );

        if ($totalEligibleBalance <= 0) {
            $recommendations[] = [
                "type" => "info",
                "message" => "No eligible invoices for credit application",
                "priority" => "low",
            ];
            return $recommendations;
        }

        // Check if credit can cover all eligible invoices
        if ($availableCredit >= $totalEligibleBalance) {
            $recommendations[] = [
                "type" => "action",
                "message" => "Apply available credit to all eligible invoices (total: {$totalEligibleBalance})",
                "priority" => "high",
                "action" => "apply_bulk_credit",
            ];
        } else {
            $coveragePercentage = round(
                ($availableCredit / $totalEligibleBalance) * 100,
                2,
            );
            $recommendations[] = [
                "type" => "action",
                "message" => "Apply available credit to highest priority invoices ({$coveragePercentage}% coverage)",
                "priority" => "medium",
                "action" => "apply_selective_credit",
            ];
        }

        // Check for old invoices
        $oldInvoices = array_filter($eligibleInvoices, function ($invoice) {
            return $invoice["days_overdue"] > 30;
        });

        if (!empty($oldInvoices)) {
            $oldInvoicesTotal = array_sum(
                array_column($oldInvoices, "remaining_balance"),
            );
            $recommendations[] = [
                "type" => "priority",
                "message" => "Prioritize credit application to {$oldInvoicesTotal} in overdue invoices (over 30 days)",
                "priority" => "high",
                "action" => "apply_to_overdue",
            ];
        }

        return $recommendations;
    }

    /**
     * Generate credit note summary report
     */
    private function generateCreditNoteSummaryReport(
        Carbon $startDate,
        Carbon $endDate,
    ): array {
        $creditNotes = CreditNote::whereBetween("issue_date", [
            $startDate,
            $endDate,
        ])->get();

        $summary = $this->calculateCreditNotesSummary($creditNotes);
        $statusStats = $this->getCreditNoteStatusStatistics([
            "date_from" => $startDate->toDateString(),
            "date_to" => $endDate->toDateString(),
        ]);

        $trend = $this->getCreditNoteTrend([
            "date_from" => $startDate->toDateString(),
            "date_to" => $endDate->toDateString(),
        ]);

        return [
            "report_type" => "summary",
            "period" => [
                "start" => $startDate->toDateString(),
                "end" => $endDate->toDateString(),
            ],
            "summary" => $summary,
            "status_statistics" => $statusStats,
            "trend" => $trend,
            "top_reasons" => $this->getTopCreditNoteReasons([
                "date_from" => $startDate->toDateString(),
                "date_to" => $endDate->toDateString(),
            ]),
            "generated_at" => Carbon::now()->toISOString(),
        ];
    }

    /**
     * Generate credit note detailed report
     */
    private function generateCreditNoteDetailedReport(
        Carbon $startDate,
        Carbon $endDate,
    ): array {
        $creditNotes = CreditNote::with(["company", "invoice"])
            ->whereBetween("issue_date", [$startDate, $endDate])
            ->orderBy("issue_date", "desc")
            ->get();

        $summary = $this->calculateCreditNotesSummary($creditNotes);
        $statusStats = $this->getCreditNoteStatusStatistics([
            "date_from" => $startDate->toDateString(),
            "date_to" => $endDate->toDateString(),
        ]);

        $trend = $this->getCreditNoteTrend([
            "date_from" => $startDate->toDateString(),
            "date_to" => $endDate->toDateString(),
        ]);

        $companyBreakdown = $this->getCreditNoteCompanyBreakdown([
            "date_from" => $startDate->toDateString(),
            "date_to" => $endDate->toDateString(),
        ]);

        return [
            "report_type" => "detailed",
            "period" => [
                "start" => $startDate->toDateString(),
                "end" => $endDate->toDateString(),
            ],
            "summary" => $summary,
            "status_statistics" => $statusStats,
            "trend" => $trend,
            "company_breakdown" => $companyBreakdown,
            "top_reasons" => $this->getTopCreditNoteReasons([
                "date_from" => $startDate->toDateString(),
                "date_to" => $endDate->toDateString(),
            ]),
            "credit_notes" => $creditNotes
                ->map(function ($creditNote) {
                    return [
                        "id" => $creditNote->id,
                        "credit_note_number" => $creditNote->credit_note_number,
                        "company_name" =>
                            $creditNote->company->name ?? "Unknown",
                        "invoice_number" =>
                            $creditNote->invoice->invoice_number ?? "N/A",
                        "amount" => (float) $creditNote->amount,
                        "currency" => $creditNote->currency,
                        "reason" => $creditNote->reason,
                        "status" => $creditNote->status,
                        "issue_date" => $creditNote->issue_date->toDateString(),
                        "applied_at" => $creditNote->applied_at?->toDateString(),
                        "notes" => $creditNote->notes,
                    ];
                })
                ->toArray(),
            "generated_at" => Carbon::now()->toISOString(),
        ];
    }

    /**
     * Generate credit note aging report
     */
    private function generateCreditNoteAgingReport(
        Carbon $startDate,
        Carbon $endDate,
    ): array {
        $creditNotes = CreditNote::whereBetween("issue_date", [
            $startDate,
            $endDate,
        ])
            ->where("status", "approved")
            ->where("applied_to_invoice", false)
            ->with(["company"])
            ->get();

        $agingBuckets = [
            "0-30_days" => ["count" => 0, "amount" => 0, "credit_notes" => []],
            "31-60_days" => ["count" => 0, "amount" => 0, "credit_notes" => []],
            "61-90_days" => ["count" => 0, "amount" => 0, "credit_notes" => []],
            "over_90_days" => [
                "count" => 0,
                "amount" => 0,
                "credit_notes" => [],
            ],
        ];

        $now = Carbon::now();

        foreach ($creditNotes as $creditNote) {
            $daysOld = $now->diffInDays($creditNote->issue_date);

            if ($daysOld <= 30) {
                $bucket = "0-30_days";
            } elseif ($daysOld <= 60) {
                $bucket = "31-60_days";
            } elseif ($daysOld <= 90) {
                $bucket = "61-90_days";
            } else {
                $bucket = "over_90_days";
            }

            $agingBuckets[$bucket]["count"]++;
            $agingBuckets[$bucket]["amount"] += $creditNote->amount;
            $agingBuckets[$bucket]["credit_notes"][] = [
                "id" => $creditNote->id,
                "credit_note_number" => $creditNote->credit_note_number,
                "company_name" => $creditNote->company->name ?? "Unknown",
                "amount" => (float) $creditNote->amount,
                "days_old" => $daysOld,
                "issue_date" => $creditNote->issue_date->toDateString(),
            ];
        }

        return [
            "report_type" => "aging",
            "period" => [
                "start" => $startDate->toDateString(),
                "end" => $endDate->toDateString(),
            ],
            "aging_buckets" => $agingBuckets,
            "summary" => [
                "total_approved_unapplied" => $creditNotes->count(),
                "total_approved_unapplied_amount" => $creditNotes->sum(
                    "amount",
                ),
                "average_days_unapplied" =>
                    $creditNotes->count() > 0
                        ? round(
                            $creditNotes->sum(function ($cn) use ($now) {
                                return $now->diffInDays($cn->issue_date);
                            }) / $creditNotes->count(),
                            1,
                        )
                        : 0,
            ],
            "action_plan" => $this->generateCreditNoteAgingActionPlan(
                $agingBuckets,
            ),
            "generated_at" => Carbon::now()->toISOString(),
        ];
    }

    /**
     * Generate credit note aging action plan
     */
    private function generateCreditNoteAgingActionPlan(
        array $agingBuckets,
    ): array {
        $actionPlan = [];

        // Over 90 days - immediate action
        if ($agingBuckets["over_90_days"]["count"] > 0) {
            $actionPlan[] = [
                "priority" => "critical",
                "action" =>
                    "Immediate application of credit notes over 90 days",
                "description" => "{$agingBuckets["over_90_days"]["count"]} credit notes totaling {$agingBuckets["over_90_days"]["amount"]} are over 90 days old",
                "deadline" => Carbon::now()->addDays(1)->toDateString(),
                "responsible" => "Credit Manager",
            ];
        }

        // 61-90 days - urgent action
        if ($agingBuckets["61-90_days"]["count"] > 0) {
            $actionPlan[] = [
                "priority" => "high",
                "action" => "Urgent application of 61-90 day credit notes",
                "description" => "{$agingBuckets["61-90_days"]["count"]} credit notes totaling {$agingBuckets["61-90_days"]["amount"]} are 61-90 days old",
                "deadline" => Carbon::now()->addDays(3)->toDateString(),
                "responsible" => "Credit Specialist",
            ];
        }

        // 31-60 days - scheduled action
        if ($agingBuckets["31-60_days"]["count"] > 0) {
            $actionPlan[] = [
                "priority" => "medium",
                "action" => "Schedule application of 31-60 day credit notes",
                "description" => "{$agingBuckets["31-60_days"]["count"]} credit notes totaling {$agingBuckets["31-60_days"]["amount"]} are 31-60 days old",
                "deadline" => Carbon::now()->addDays(7)->toDateString(),
                "responsible" => "Credit Team",
            ];
        }

        // 0-30 days - monitor
        if ($agingBuckets["0-30_days"]["count"] > 0) {
            $actionPlan[] = [
                "priority" => "low",
                "action" => "Monitor 0-30 day credit notes",
                "description" => "{$agingBuckets["0-30_days"]["count"]} credit notes totaling {$agingBuckets["0-30_days"]["amount"]} are 0-30 days old",
                "deadline" => Carbon::now()->addDays(14)->toDateString(),
                "responsible" => "Credit Team",
            ];
        }

        return $actionPlan;
    }

    /**
     * Generate credit note reason analysis report
     */
    private function generateCreditNoteReasonAnalysisReport(
        Carbon $startDate,
        Carbon $endDate,
    ): array {
        $reasons = $this->getTopCreditNoteReasons([
            "date_from" => $startDate->toDateString(),
            "date_to" => $endDate->toDateString(),
        ]);

        $totalAmount = array_sum(array_column($reasons, "total_amount"));
        $totalCount = array_sum(array_column($reasons, "count"));

        // Calculate percentages
        foreach ($reasons as &$reason) {
            $reason["amount_percentage"] =
                $totalAmount > 0
                    ? round(($reason["total_amount"] / $totalAmount) * 100, 2)
                    : 0;
            $reason["count_percentage"] =
                $totalCount > 0
                    ? round(($reason["count"] / $totalCount) * 100, 2)
                    : 0;
        }

        // Get trend by reason
        $reasonTrends = [];
        foreach ($reasons as $reasonData) {
            $reason = $reasonData["reason"];
            $trend = CreditNote::where("reason", $reason)
                ->whereBetween("issue_date", [$startDate, $endDate])
                ->selectRaw(
                    "YEAR(issue_date) as year, MONTH(issue_date) as month, COUNT(*) as count, SUM(amount) as total_amount",
                )
                ->groupBy("year", "month")
                ->orderBy("year", "desc")
                ->orderBy("month", "desc")
                ->limit(6)
                ->get()
                ->map(function ($item) {
                    return [
                        "period" => Carbon::create(
                            $item->year,
                            $item->month,
                            1,
                        )->format("Y-m"),
                        "period_label" => Carbon::create(
                            $item->year,
                            $item->month,
                            1,
                        )->format("M Y"),
                        "count" => (int) $item->count,
                        "total_amount" => (float) $item->total_amount,
                    ];
                });

            $reasonTrends[$reason] = $trend->values()->toArray();
        }

        return [
            "report_type" => "reason_analysis",
            "period" => [
                "start" => $startDate->toDateString(),
                "end" => $endDate->toDateString(),
            ],
            "reasons" => $reasons,
            "summary" => [
                "total_reasons" => count($reasons),
                "total_amount" => $totalAmount,
                "total_count" => $totalCount,
                "average_per_reason" =>
                    count($reasons) > 0 ? $totalAmount / count($reasons) : 0,
            ],
            "reason_trends" => $reasonTrends,
            "recommendations" => $this->generateReasonAnalysisRecommendations(
                $reasons,
            ),
            "generated_at" => Carbon::now()->toISOString(),
        ];
    }

    /**
     * Generate reason analysis recommendations
     */
    private function generateReasonAnalysisRecommendations(
        array $reasons,
    ): array {
        $recommendations = [];

        // Check for high-frequency reasons
        $highFrequencyReasons = array_filter($reasons, function ($reason) {
            return $reason["count_percentage"] > 20; // More than 20% of total
        });

        foreach ($highFrequencyReasons as $reason) {
            $recommendations[] = [
                "priority" => "high",
                "action" => "Address high-frequency reason: {$reason["reason"]}",
                "description" => "This reason accounts for {$reason["count_percentage"]}% of all credit notes ({$reason["count"]} instances)",
                "estimated_effort" => "2 weeks",
            ];
        }

        // Check for high-value reasons
        $highValueReasons = array_filter($reasons, function ($reason) {
            return $reason["amount_percentage"] > 30; // More than 30% of total value
        });

        foreach ($highValueReasons as $reason) {
            $recommendations[] = [
                "priority" => "critical",
                "action" => "Address high-value reason: {$reason["reason"]}",
                "description" => "This reason accounts for {$reason["amount_percentage"]}% of total credit note value ({$reason["total_amount"]})",
                "estimated_effort" => "1 month",
            ];
        }

        // Check for preventable reasons
        $preventableKeywords = [
            "error",
            "mistake",
            "incorrect",
            "wrong",
            "duplicate",
        ];
        $preventableReasons = array_filter($reasons, function ($reason) use (
            $preventableKeywords,
        ) {
            foreach ($preventableKeywords as $keyword) {
                if (stripos($reason["reason"], $keyword) !== false) {
                    return true;
                }
            }
            return false;
        });

        foreach ($preventableReasons as $reason) {
            $recommendations[] = [
                "priority" => "medium",
                "action" => "Prevent reason: {$reason["reason"]}",
                "description" => "This appears to be a preventable reason ({$reason["count"]} instances)",
                "estimated_effort" => "1 week",
            ];
        }

        return $recommendations;
    }
}
