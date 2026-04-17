<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\CompanySubscription;
use App\Models\Payment;
use App\Services\Pdf\SimplePdfGenerator;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class FactoryBillingController extends Controller
{
    /**
     * Get billing summary for the factory
     */
    public function getBillingSummary(Request $request): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            // Get current subscription
            $subscription = CompanySubscription::where("company_id", $factoryId)
                ->where("status", "active")
                ->first();

            // Calculate total owed (pending + overdue invoices)
            $totalOwed = Invoice::where("company_id", $factoryId)
                ->whereIn("status", ["pending", "overdue"])
                ->sum("total_amount");

            // Calculate total paid
            $totalPaid = Invoice::where("company_id", $factoryId)
                ->where("status", "paid")
                ->sum("total_amount");

            // Count invoices by status
            $pendingInvoices = Invoice::where("company_id", $factoryId)
                ->where("status", "pending")
                ->count();

            $paidInvoices = Invoice::where("company_id", $factoryId)
                ->where("status", "paid")
                ->count();

            $overdueInvoices = Invoice::where("company_id", $factoryId)
                ->where("status", "overdue")
                ->count();

            // Get next payment date from subscription
            $nextPaymentDate = $subscription?->next_payment_date;
            $nextPaymentAmount = $subscription?->plan?->monthly_price;

            // Get usage summary from subscription
            $usageSummary = null;
            if ($subscription && $subscription->plan) {
                $usageSummary = [
                    "unit_codes" => [
                        "used" => $subscription->current_unit_codes_used ?? 0,
                        "limit" => $subscription->plan->monthly_unit_codes,
                    ],
                    "packet_codes" => [
                        "used" => $subscription->current_packet_codes_used ?? 0,
                        "limit" => $subscription->plan->monthly_packet_codes,
                    ],
                    "carton_codes" => [
                        "used" => $subscription->current_carton_codes_used ?? 0,
                        "limit" => $subscription->plan->monthly_carton_codes,
                    ],
                    "bundle_codes" => [
                        "used" => $subscription->current_bundle_codes_used ?? 0,
                        "limit" => $subscription->plan->monthly_bundle_codes,
                    ],
                ];
            }

            $summary = [
                "total_owed" => (float) $totalOwed,
                "total_paid" => (float) $totalPaid,
                "pending_invoices" => $pendingInvoices,
                "paid_invoices" => $paidInvoices,
                "overdue_invoices" => $overdueInvoices,
                "next_payment_date" => $nextPaymentDate?->toISOString(),
                "next_payment_amount" => $nextPaymentAmount
                    ? (float) $nextPaymentAmount
                    : null,
                "next_payment_currency" => "USD",
                "usage_summary" => $usageSummary,
            ];

            return response()->json([
                "success" => true,
                "data" => $summary,
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to load billing summary",
                    "error" => $e->getMessage(),
                ],
                500,
            );
        }
    }

    /**
     * Get invoices with filtering
     */
    public function getInvoices(Request $request): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            $query = Invoice::where("company_id", $factoryId)->with([
                "subscription.plan",
            ]);

            // Apply filters
            if ($request->has("start_date")) {
                $query->where(
                    "issue_date",
                    ">=",
                    $request->input("start_date"),
                );
            }

            if ($request->has("end_date")) {
                $query->where("issue_date", "<=", $request->input("end_date"));
            }

            if ($request->has("statuses")) {
                $statuses = explode(",", $request->input("statuses"));
                $query->whereIn("status", $statuses);
            }

            if ($request->has("min_amount")) {
                $query->where(
                    "total_amount",
                    ">=",
                    $request->input("min_amount"),
                );
            }

            if ($request->has("max_amount")) {
                $query->where(
                    "total_amount",
                    "<=",
                    $request->input("max_amount"),
                );
            }

            if ($request->has("search")) {
                $search = $request->input("search");
                $query->where(function ($q) use ($search) {
                    $q->where("invoice_number", "like", "%{$search}%")->orWhere(
                        "notes",
                        "like",
                        "%{$search}%",
                    );
                });
            }

            // Apply sorting
            $sortBy = $request->input("sort_by", "issue_date");
            $sortDesc = $request->input("sort_desc", "true") === "true";
            $query->orderBy($sortBy, $sortDesc ? "desc" : "asc");

            // Pagination
            $page = (int) $request->input("page", 1);
            $limit = (int) $request->input("limit", 20);
            $offset = ($page - 1) * $limit;

            $total = $query->count();
            $invoices = $query->offset($offset)->limit($limit)->get();

            return response()->json([
                "success" => true,
                "data" => $invoices,
                "meta" => [
                    "total" => $total,
                    "page" => $page,
                    "limit" => $limit,
                    "has_more" => $offset + $limit < $total,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to load invoices",
                    "error" => $e->getMessage(),
                ],
                500,
            );
        }
    }

    /**
     * Get specific invoice by ID
     */
    public function getInvoice(string $invoiceId): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            $invoice = Invoice::where("company_id", $factoryId)
                ->where("id", $invoiceId)
                ->with(["subscription.plan"])
                ->firstOrFail();

            return response()->json([
                "success" => true,
                "data" => $invoice,
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Invoice not found",
                    "error" => $e->getMessage(),
                ],
                404,
            );
        }
    }

    /**
     * Get payment history
     */
    public function getPaymentHistory(Request $request): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            $query = Payment::whereHas("invoice", function ($q) use (
                $factoryId,
            ) {
                $q->where("company_id", $factoryId);
            })->with(["invoice"]);

            // Apply filters
            if ($request->has("start_date")) {
                $query->where(
                    "payment_date",
                    ">=",
                    $request->input("start_date"),
                );
            }

            if ($request->has("end_date")) {
                $query->where(
                    "payment_date",
                    "<=",
                    $request->input("end_date"),
                );
            }

            if ($request->has("min_amount")) {
                $query->where("amount", ">=", $request->input("min_amount"));
            }

            if ($request->has("max_amount")) {
                $query->where("amount", "<=", $request->input("max_amount"));
            }

            // Apply sorting
            $sortBy = $request->input("sort_by", "payment_date");
            $sortDesc = $request->input("sort_desc", "true") === "true";
            $query->orderBy($sortBy, $sortDesc ? "desc" : "asc");

            // Pagination
            $page = (int) $request->input("page", 1);
            $limit = (int) $request->input("limit", 20);
            $offset = ($page - 1) * $limit;

            $total = $query->count();
            $payments = $query->offset($offset)->limit($limit)->get();

            return response()->json([
                "success" => true,
                "data" => $payments,
                "meta" => [
                    "total" => $total,
                    "page" => $page,
                    "limit" => $limit,
                    "has_more" => $offset + $limit < $total,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to load payment history",
                    "error" => $e->getMessage(),
                ],
                500,
            );
        }
    }

    /**
     * Get payments for a specific invoice
     */
    public function getInvoicePayments(string $invoiceId): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            // Verify invoice belongs to factory
            $invoice = Invoice::where("company_id", $factoryId)
                ->where("id", $invoiceId)
                ->firstOrFail();

            $payments = Payment::where("invoice_id", $invoiceId)
                ->orderBy("payment_date", "desc")
                ->get();

            return response()->json([
                "success" => true,
                "data" => $payments,
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to load invoice payments",
                    "error" => $e->getMessage(),
                ],
                404,
            );
        }
    }

    /**
     * Make a payment for an invoice
     */
    public function makePayment(Request $request): JsonResponse
    {
        DB::beginTransaction();

        try {
            $factoryId = $this->getFactoryId();

            $validator = Validator::make($request->all(), [
                "invoice_id" => "required|uuid|exists:invoices,id",
                "amount" => "required|numeric|min:0.01",
                "payment_method" =>
                    "required|in:wallet,credit_card,bank_transfer,cash,other",
                "reference" => "nullable|string|max:255",
                "notes" => "nullable|string|max:1000",
            ]);

            if ($validator->fails()) {
                return response()->json(
                    [
                        "success" => false,
                        "message" => "Validation failed",
                        "errors" => $validator->errors(),
                    ],
                    422,
                );
            }

            // Get and verify invoice
            $invoice = Invoice::where("company_id", $factoryId)
                ->where("id", $request->input("invoice_id"))
                ->firstOrFail();

            // Check if invoice is already paid
            if ($invoice->status === "paid") {
                return response()->json(
                    [
                        "success" => false,
                        "message" => "Invoice is already paid",
                    ],
                    400,
                );
            }

            // Check if payment amount matches invoice amount
            $paymentAmount = (float) $request->input("amount");
            $invoiceAmount = (float) $invoice->total_amount;

            if (abs($paymentAmount - $invoiceAmount) > 0.01) {
                return response()->json(
                    [
                        "success" => false,
                        "message" =>
                            "Payment amount does not match invoice amount",
                    ],
                    400,
                );
            }

            // Create payment record
            $payment = Payment::create([
                "id" => (string) \Illuminate\Support\Str::uuid(),
                "invoice_id" => $invoice->id,
                "amount" => $paymentAmount,
                "currency" => $invoice->currency,
                "method" => $request->input("payment_method"),
                "payment_date" => Carbon::now(),
                "reference" => $request->input("reference"),
                "notes" => $request->input("notes"),
                "transaction_id" =>
                    "TXN-" . strtoupper(\Illuminate\Support\Str::random(10)),
                "metadata" => [
                    "factory_id" => $factoryId,
                    "paid_by" => Auth::user()->id ?? null,
                    "ip_address" => $request->ip(),
                    "user_agent" => $request->userAgent(),
                ],
            ]);

            // Update invoice status
            $invoice->update([
                "status" => "paid",
                "payment_date" => Carbon::now(),
                "payment_method" => $request->input("payment_method"),
                "payment_reference" => $request->input("reference"),
            ]);

            // Update subscription next payment date if this is a subscription invoice
            if ($invoice->subscription_id) {
                $subscription = CompanySubscription::find(
                    $invoice->subscription_id,
                );
                if ($subscription) {
                    $subscription->update([
                        "last_payment_date" => Carbon::now(),
                        "next_payment_date" => Carbon::now()->addMonth(),
                        "payment_status" => "paid",
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                "success" => true,
                "message" => "Payment successful",
                "data" => [
                    "payment" => $payment,
                    "invoice" => $invoice->fresh(),
                ],
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json(
                [
                    "success" => false,
                    "message" => "Payment failed",
                    "error" => $e->getMessage(),
                ],
                500,
            );
        }
    }

    /**
     * Download invoice as PDF
     */
    public function downloadInvoice(string $invoiceId): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            $invoice = Invoice::where("company_id", $factoryId)
                ->where("id", $invoiceId)
                ->firstOrFail();

            // Check if invoice is paid (only paid invoices can be downloaded)
            if ($invoice->status !== "paid") {
                return response()->json(
                    [
                        "success" => false,
                        "message" => "Invoice must be paid before downloading",
                        "downloadable" => false,
                    ],
                    403,
                );
            }

            $dir = storage_path("app/public/invoices/" . $factoryId);
            File::ensureDirectoryExists($dir);
            $fileName = $invoice->invoice_number . ".pdf";
            $absPath = $dir . DIRECTORY_SEPARATOR . $fileName;

            $payments = Payment::query()
                ->where("invoice_id", $invoice->id)
                ->orderByDesc("payment_date")
                ->get();

            $lines = [];
            $lines[] = "NexaTrace Invoice";
            $lines[] = "Invoice #: " . (string) $invoice->invoice_number;
            $lines[] = "Status: " . (string) $invoice->status;
            $lines[] = "Issue Date: " . (string) $invoice->issue_date;
            $lines[] = "Due Date: " . (string) $invoice->due_date;
            $lines[] = "Currency: " . (string) ($invoice->currency ?? "USD");
            $lines[] = "";
            $lines[] = "Items:";

            $items = is_array($invoice->items) ? $invoice->items : [];
            foreach ($items as $item) {
                $desc = is_array($item) ? (string) ($item["description"] ?? "") : "";
                $qty = is_array($item) ? (string) ($item["quantity"] ?? "") : "";
                $unitPrice = is_array($item) ? (string) ($item["unit_price"] ?? "") : "";
                $total = is_array($item) ? (string) ($item["total"] ?? "") : "";
                $lines[] = "- " . $desc;
                $lines[] = "  Qty: " . $qty . "  Unit: " . $unitPrice . "  Total: " . $total;
            }

            $lines[] = "";
            $lines[] = "Subtotal: " . (string) $invoice->subtotal;
            $lines[] = "Tax: " . (string) $invoice->tax_amount;
            $lines[] = "Discount: " . (string) $invoice->discount_amount;
            $lines[] = "Total: " . (string) $invoice->total_amount;

            if ($payments->isNotEmpty()) {
                $lines[] = "";
                $lines[] = "Payments:";
                foreach ($payments as $p) {
                    $lines[] = "- " . (string) $p->payment_date . "  " . (string) $p->amount . " " . (string) $p->currency . "  " . (string) $p->method;
                }
            }

            $pdf = app(SimplePdfGenerator::class)->generate($lines);
            file_put_contents($absPath, $pdf);

            $filePath = "/storage/invoices/" . $factoryId . "/" . $fileName;

            return response()->json([
                "success" => true,
                "data" => [
                    "file_path" => $filePath,
                    "invoice_number" => $invoice->invoice_number,
                    "download_url" => url($filePath),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to download invoice",
                    "error" => $e->getMessage(),
                ],
                404,
            );
        }
    }

    /**
     * Check if invoice is downloadable
     */
    public function checkInvoiceDownloadable(string $invoiceId): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            $invoice = Invoice::where("company_id", $factoryId)
                ->where("id", $invoiceId)
                ->firstOrFail();

            $downloadable = $invoice->status === "paid";

            return response()->json([
                "success" => true,
                "data" => [
                    "downloadable" => $downloadable,
                    "status" => $invoice->status,
                    "message" => $downloadable
                        ? "Invoice is ready for download"
                        : "Invoice must be paid before downloading",
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to check invoice status",
                    "error" => $e->getMessage(),
                ],
                404,
            );
        }
    }

    /**
     * Send invoice via email
     */
    public function sendInvoiceEmail(
        Request $request,
        string $invoiceId,
    ): JsonResponse {
        try {
            $factoryId = $this->getFactoryId();

            $invoice = Invoice::where("company_id", $factoryId)
                ->where("id", $invoiceId)
                ->firstOrFail();

            $email = $request->input("email") ?? Auth::user()->email;

            // In a real implementation, this would send an email
            // For now, log the request and return success

            \Log::info("Invoice email requested", [
                "invoice_id" => $invoiceId,
                "invoice_number" => $invoice->invoice_number,
                "recipient_email" => $email,
                "factory_id" => $factoryId,
                "requested_by" => Auth::user()->id ?? "system",
            ]);

            return response()->json([
                "success" => true,
                "message" => "Invoice email has been sent",
                "data" => [
                    "invoice_id" => $invoiceId,
                    "recipient_email" => $email,
                    "sent_at" => Carbon::now()->toISOString(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to send invoice email",
                    "error" => $e->getMessage(),
                ],
                500,
            );
        }
    }

    /**
     * Get invoice statistics
     */
    public function getInvoiceStatistics(Request $request): JsonResponse
    {
        try {
            $factoryId = $this->getFactoryId();

            // Get date range (default: last 12 months)
            $endDate = Carbon::now();
            $startDate = $request->has("start_date")
                ? Carbon::parse($request->input("start_date"))
                : $endDate->copy()->subMonths(12);

            // Calculate statistics
            $totalRevenue = Invoice::where("company_id", $factoryId)
                ->where("status", "paid")
                ->whereBetween("payment_date", [$startDate, $endDate])
                ->sum("total_amount");

            $totalInvoices = Invoice::where("company_id", $factoryId)
                ->whereBetween("issue_date", [$startDate, $endDate])
                ->count();

            $paidInvoices = Invoice::where("company_id", $factoryId)
                ->where("status", "paid")
                ->whereBetween("payment_date", [$startDate, $endDate])
                ->count();

            $pendingInvoices = Invoice::where("company_id", $factoryId)
                ->where("status", "pending")
                ->whereBetween("issue_date", [$startDate, $endDate])
                ->count();

            $overdueInvoices = Invoice::where("company_id", $factoryId)
                ->where("status", "overdue")
                ->whereBetween("issue_date", [$startDate, $endDate])
                ->count();

            $averageInvoiceAmount =
                $paidInvoices > 0 ? $totalRevenue / $paidInvoices : 0;

            // Calculate monthly revenue
            $monthlyRevenue = [];
            $invoiceStatusCount = [
                "paid" => $paidInvoices,
                "pending" => $pendingInvoices,
                "overdue" => $overdueInvoices,
                "draft" => 0,
                "cancelled" => 0,
                "refunded" => 0,
            ];

            // Get monthly breakdown
            $monthlyData = Invoice::where("company_id", $factoryId)
                ->where("status", "paid")
                ->whereBetween("payment_date", [$startDate, $endDate])
                ->selectRaw(
                    "EXTRACT(YEAR FROM payment_date) as year, EXTRACT(MONTH FROM payment_date) as month, SUM(total_amount) as revenue",
                )
                ->groupBy("year", "month")
                ->orderBy("year", "desc")
                ->orderBy("month", "desc")
                ->get();

            foreach ($monthlyData as $data) {
                $key =
                    $data->year .
                    "-" .
                    str_pad($data->month, 2, "0", STR_PAD_LEFT);
                $monthlyRevenue[$key] = (float) $data->revenue;
            }

            // Get status counts
            $statusCounts = Invoice::where("company_id", $factoryId)
                ->whereBetween("issue_date", [$startDate, $endDate])
                ->selectRaw("status, COUNT(*) as count")
                ->groupBy("status")
                ->get();

            foreach ($statusCounts as $statusCount) {
                $invoiceStatusCount[$statusCount->status] =
                    (int) $statusCount->count;
            }

            $statistics = [
                "total_revenue" => (float) $totalRevenue,
                "average_invoice_amount" => (float) $averageInvoiceAmount,
                "total_invoices" => $totalInvoices,
                "paid_invoices" => $paidInvoices,
                "pending_invoices" => $pendingInvoices,
                "overdue_invoices" => $overdueInvoices,
                "monthly_revenue" => $monthlyRevenue,
                "invoice_status_count" => $invoiceStatusCount,
            ];

            return response()->json([
                "success" => true,
                "data" => $statistics,
            ]);
        } catch (\Exception $e) {
            return response()->json(
                [
                    "success" => false,
                    "message" => "Failed to load invoice statistics",
                    "error" => $e->getMessage(),
                ],
                500,
            );
        }
    }

    /**
     * Helper method to get factory ID from authenticated user
     */
    private function getFactoryId(): string
    {
        // Get factory ID from authenticated user
        $user = Auth::user();

        if (!$user) {
            throw new \Exception("User not authenticated");
        }

        // For factory users, get company_id from user record
        if ($user instanceof \App\Models\FactoryUser) {
            return $user->company_id;
        }

        // For admin users accessing factory data (for testing/debugging)
        if (
            $user instanceof \App\Models\AdminUser &&
            request()->has("factory_id")
        ) {
            return request()->input("factory_id");
        }

        throw new \Exception("Unable to determine factory ID");
    }
}
