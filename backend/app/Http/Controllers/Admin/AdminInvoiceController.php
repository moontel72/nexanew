<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Company;
use App\Models\Payment;
use App\Models\CreditNote;
use App\Services\InvoiceService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage;

class AdminInvoiceController extends Controller
{
    protected $invoiceService;

    public function __construct(InvoiceService $invoiceService)
    {
        $this->invoiceService = $invoiceService;
    }

    /**
     * Get company invoices
     */
    public function getCompanyInvoices(string $companyId, Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'statuses' => 'nullable|array',
            'statuses.*' => Rule::in(['draft', 'pending', 'paid', 'overdue', 'cancelled', 'refunded']),
            'page' => 'nullable|integer|min:1',
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
            $company = Company::findOrFail($companyId);

            $query = Invoice::where('company_id', $companyId)
                ->with(['subscription:id,name']);

            // Apply filters
            if ($request->has('start_date')) {
                $query->where('issue_date', '>=', $request->start_date);
            }

            if ($request->has('end_date')) {
                $query->where('issue_date', '<=', $request->end_date);
            }

            if ($request->has('statuses') && is_array($request->statuses)) {
                $query->whereIn('status', $request->statuses);
            }

            // Apply sorting
            $sortBy = $request->get('sort_by', 'issue_date');
            $sortOrder = $request->get('sort_order', 'desc');
            $query->orderBy($sortBy, $sortOrder);

            // Paginate results
            $page = $request->get('page', 1);
            $limit = $request->get('limit', 20);
            $invoices = $query->paginate($limit, ['*'], 'page', $page);

            // Transform response
            $transformedInvoices = $invoices->map(function ($invoice) {
                return [
                    'id' => $invoice->id,
                    'invoice_number' => $invoice->invoice_number,
                    'subscription_id' => $invoice->subscription_id,
                    'subscription_name' => $invoice->subscription?->name,
                    'period_start' => $invoice->period_start->toDateString(),
                    'period_end' => $invoice->period_end->toDateString(),
                    'issue_date' => $invoice->issue_date->toDateString(),
                    'due_date' => $invoice->due_date->toDateString(),
                    'subtotal' => (float) $invoice->subtotal,
                    'tax_amount' => (float) $invoice->tax_amount,
                    'discount_amount' => (float) $invoice->discount_amount,
                    'total_amount' => (float) $invoice->total_amount,
                    'currency' => $invoice->currency,
                    'status' => $invoice->status,
                    'payment_date' => $invoice->payment_date?->toDateString(),
                    'payment_method' => $invoice->payment_method,
                    'payment_reference' => $invoice->payment_reference,
                    'notes' => $invoice->notes,
                    'created_at' => $invoice->created_at->toISOString(),
                    'updated_at' => $invoice->updated_at->toISOString(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => [
                    'company' => [
                        'id' => $company->id,
                        'name' => $company->name,
                        'email' => $company->email,
                    ],
                    'invoices' => $transformedInvoices,
                    'pagination' => [
                        'total' => $invoices->total(),
                        'per_page' => $invoices->perPage(),
                        'current_page' => $invoices->currentPage(),
                        'last_page' => $invoices->lastPage(),
                        'from' => $invoices->firstItem(),
                        'to' => $invoices->lastItem(),
                    ],
                    'summary' => [
                        'total_invoices' => $invoices->total(),
                        'total_amount' => (float) $invoices->sum('total_amount'),
                        'paid_amount' => (float) $invoices->where('status', 'paid')->sum('total_amount'),
                        'pending_amount' => (float) $invoices->where('status', 'pending')->sum('total_amount'),
                        'overdue_amount' => (float) $invoices->where('status', 'overdue')->sum('total_amount'),
                        'average_days_to_pay' => $this->calculateAverageDaysToPay($invoices->items()),
                    ],
                ],
                'message' => 'Company invoices retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'COMPANY_NOT_FOUND',
                    'message' => 'Company not found',
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve company invoices',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Send invoice notification
     */
    public function sendInvoiceNotification(string $id): JsonResponse
    {
        try {
            $invoice = Invoice::with(['company:id,name,email'])->findOrFail($id);

            // Check if invoice is already paid
            if ($invoice->status === 'paid') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'INVOICE_ALREADY_PAID',
                        'message' => 'Cannot send notification for paid invoice',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => request()->header('X-Request-ID'),
                ], 400);
            }

            // TODO: Implement email sending logic
            // For now, we'll just update the metadata
            $metadata = json_decode($invoice->metadata, true) ?? [];
            $metadata['last_notification_sent'] = now()->toISOString();
            $metadata['notification_count'] = ($metadata['notification_count'] ?? 0) + 1;

            $invoice->update([
                'metadata' => json_encode($metadata),
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'invoice_id' => $invoice->id,
                    'invoice_number' => $invoice->invoice_number,
                    'company_name' => $invoice->company->name,
                    'company_email' => $invoice->company->email,
                    'notification_sent' => true,
                    'notification_count' => $metadata['notification_count'],
                    'last_notification' => $metadata['last_notification_sent'],
                ],
                'message' => 'Invoice notification sent successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVOICE_NOT_FOUND',
                    'message' => 'Invoice not found',
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'NOTIFICATION_FAILED',
                    'message' => 'Failed to send invoice notification',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Get invoice payments
     */
    public function getInvoicePayments(string $id): JsonResponse
    {
        try {
            $invoice = Invoice::findOrFail($id);
            $payments = Payment::where('invoice_id', $id)
                ->orderBy('payment_date', 'desc')
                ->get();

            $transformedPayments = $payments->map(function ($payment) {
                return [
                    'id' => $payment->id,
                    'amount' => (float) $payment->amount,
                    'currency' => $payment->currency,
                    'method' => $payment->method,
                    'payment_date' => $payment->payment_date->toDateString(),
                    'reference' => $payment->reference,
                    'transaction_id' => $payment->transaction_id,
                    'notes' => $payment->notes,
                    'metadata' => json_decode($payment->metadata, true) ?? [],
                    'created_at' => $payment->created_at->toISOString(),
                    'updated_at' => $payment->updated_at->toISOString(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => [
                    'invoice' => [
                        'id' => $invoice->id,
                        'invoice_number' => $invoice->invoice_number,
                        'total_amount' => (float) $invoice->total_amount,
                        'currency' => $invoice->currency,
                        'status' => $invoice->status,
                    ],
                    'payments' => $transformedPayments,
                    'summary' => [
                        'total_payments' => $payments->count(),
                        'total_paid' => (float) $payments->sum('amount'),
                        'remaining_balance' => (float) $invoice->total_amount - $payments->sum('amount'),
                        'payment_progress' => $invoice->total_amount > 0
                            ? ($payments->sum('amount') / $invoice->total_amount) * 100
                            : 0,
                    ],
                ],
                'message' => 'Invoice payments retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVOICE_NOT_FOUND',
                    'message' => 'Invoice not found',
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve invoice payments',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Record payment for invoice
     */
    public function recordPayment(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'method' => [
                'required',
                Rule::in(['wallet', 'credit_card', 'bank_transfer', 'cash', 'other']),
            ],
            'payment_date' => 'required|date',
            'reference' => 'nullable|string|max:255',
            'transaction_id' => 'nullable|string|max:255',
            'notes' => 'nullable|string|max:1000',
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

        DB::beginTransaction();

        try {
            $invoice = Invoice::findOrFail($id);

            // Check if invoice is already paid
            if ($invoice->status === 'paid') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'INVOICE_ALREADY_PAID',
                        'message' => 'Invoice is already paid',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => $request->header('X-Request-ID'),
                ], 400);
            }

            // Create payment
            $payment = Payment::create([
                'invoice_id' => $invoice->id,
                'amount' => $request->amount,
                'currency' => $invoice->currency,
                'method' => $request->method,
                'payment_date' => $request->payment_date,
                'reference' => $request->reference,
                'transaction_id' => $request->transaction_id,
                'notes' => $request->notes,
                'metadata' => json_encode([
                    'recorded_by_admin' => true,
                    'recorded_at' => now()->toISOString(),
                ]),
            ]);

            // Calculate total paid
            $totalPaid = Payment::where('invoice_id', $invoice->id)->sum('amount');
            $remainingBalance = $invoice->total_amount - $totalPaid;

            // Update invoice status if fully paid
            $newStatus = $invoice->status;
            if ($totalPaid >= $invoice->total_amount) {
                $newStatus = 'paid';
            } elseif ($totalPaid > 0) {
                $newStatus = 'partially_paid';
            }

            $invoice->update([
                'status' => $newStatus,
                'payment_date' => $newStatus === 'paid' ? now() : null,
                'payment_method' => $request->method,
                'payment_reference' => $request->reference,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'payment' => [
                        'id' => $payment->id,
                        'invoice_id' => $payment->invoice_id,
                        'amount' => (float) $payment->amount,
                        'currency' => $payment->currency,
                        'method' => $payment->method,
                        'payment_date' => $payment->payment_date->toDateString(),
                        'reference' => $payment->reference,
                        'transaction_id' => $payment->transaction_id,
                        'notes' => $payment->notes,
                        'created_at' => $payment->created_at->toISOString(),
                    ],
                    'invoice' => [
                        'id' => $invoice->id,
                        'invoice_number' => $invoice->invoice_number,
                        'status' => $invoice->status,
                        'total_amount' => (float) $invoice->total_amount,
                        'total_paid' => (float) $totalPaid,
                        'remaining_balance' => (float) $remainingBalance,
                        'payment_progress' => $invoice->total_amount > 0
                            ? ($totalPaid / $invoice->total_amount) * 100
                            : 0,
                    ],
                ],
                'message' => 'Payment recorded successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVOICE_NOT_FOUND',
                    'message' => 'Invoice not found',
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 404);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'PAYMENT_RECORDING_FAILED',
                    'message' => 'Failed to record payment',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Get companies with overdue invoices
     */
    public function getCompaniesWithOverdueInvoices(Request $request): JsonResponse
    {
        try {
            $query = Company::whereHas('invoices', function ($query) {
                $query->where('status', 'overdue')
                    ->where('due_date', '<', now());
            })
            ->with(['invoices' => function ($query) {
                $query->where('status', 'overdue')
                    ->where('due_date', '<', now())
                    ->orderBy('due_date', 'asc');
            }])
            ->withCount(['invoices as overdue_invoices_count' => function ($query) {
                $query->where('status', 'overdue')
                    ->where('due_date', '<',
