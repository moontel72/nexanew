<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\Invoice;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AdminInvoiceController extends Controller
{
    /**
     * Send invoice notification (email sending is handled elsewhere; this records metadata + returns invoice info)
     */
    public function sendInvoiceNotification(string $id): JsonResponse
    {
        try {
            $invoice = Invoice::with(['company'])->findOrFail($id);

            $metadata = is_array($invoice->metadata) ? $invoice->metadata : [];
            $metadata['notification_count'] = (int) ($metadata['notification_count'] ?? 0) + 1;
            $metadata['last_notification_sent'] = now()->toISOString();
            $invoice->metadata = $metadata;
            $invoice->save();

            return response()->json([
                'success' => true,
                'data' => [
                    'invoice_id' => $invoice->id,
                    'invoice_number' => $invoice->invoice_number,
                    'company_id' => $invoice->company_id,
                    'company_name' => $invoice->company?->name,
                    'company_email' => $invoice->company?->email,
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

            $query = Invoice::where('company_id', $companyId);

            if ($request->filled('start_date')) {
                $query->where('issue_date', '>=', $request->start_date);
            }
            if ($request->filled('end_date')) {
                $query->where('issue_date', '<=', $request->end_date);
            }
            if ($request->has('statuses') && is_array($request->statuses) && !empty($request->statuses)) {
                $query->whereIn('status', $request->statuses);
            }

            $query->orderBy('issue_date', 'desc');

            $page = (int) $request->get('page', 1);
            $limit = (int) $request->get('limit', 20);
            $total = $query->count();

            $invoices = $query
                ->skip(($page - 1) * $limit)
                ->take($limit)
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'company' => [
                        'id' => $company->id,
                        'name' => $company->name,
                        'email' => $company->email,
                    ],
                    'invoices' => $invoices->values(),
                    'pagination' => [
                        'page' => $page,
                        'limit' => $limit,
                        'total' => $total,
                        'pages' => (int) ceil($total / max(1, $limit)),
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
                $meta = $payment->metadata;
                if (is_string($meta)) {
                    $decoded = json_decode($meta, true);
                    $meta = is_array($decoded) ? $decoded : [];
                }
                if (!is_array($meta)) {
                    $meta = [];
                }

                return [
                    'id' => $payment->id,
                    'invoice_id' => $payment->invoice_id,
                    'amount' => (float) $payment->amount,
                    'currency' => $payment->currency,
                    'method' => $payment->method,
                    'payment_date' => $payment->payment_date?->toDateString(),
                    'reference' => $payment->reference,
                    'transaction_id' => $payment->transaction_id,
                    'notes' => $payment->notes,
                    'metadata' => $meta,
                    'created_at' => $payment->created_at?->toISOString(),
                    'updated_at' => $payment->updated_at?->toISOString(),
                ];
            });

            $totalPaid = (float) $payments->sum('amount');
            $invoiceTotal = (float) $invoice->total_amount;

            return response()->json([
                'success' => true,
                'data' => [
                    'invoice' => [
                        'id' => $invoice->id,
                        'invoice_number' => $invoice->invoice_number,
                        'total_amount' => $invoiceTotal,
                        'currency' => $invoice->currency,
                        'status' => $invoice->status,
                    ],
                    'payments' => $transformedPayments,
                    'summary' => [
                        'total_payments' => $payments->count(),
                        'total_paid' => $totalPaid,
                        'remaining_balance' => max(0, $invoiceTotal - $totalPaid),
                        'payment_progress' => $invoiceTotal > 0 ? ($totalPaid / $invoiceTotal) * 100 : 0,
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

            $payment = new Payment();
            $payment->id = (string) Str::uuid();
            $payment->invoice_id = $invoice->id;
            $payment->amount = (float) $request->amount;
            $payment->currency = $invoice->currency ?? 'USD';
            $payment->method = (string) $request->method;
            $payment->payment_date = $request->payment_date;
            $payment->reference = $request->reference;
            $payment->transaction_id = $request->transaction_id;
            $payment->notes = $request->notes;
            $payment->metadata = [
                'recorded_by' => 'admin',
                'recorded_at' => now()->toISOString(),
            ];
            $payment->save();

            $totalPaid = (float) Payment::where('invoice_id', $invoice->id)->sum('amount');
            $invoiceTotal = (float) $invoice->total_amount;

            if ($invoiceTotal > 0 && $totalPaid >= $invoiceTotal) {
                $invoice->status = 'paid';
                $invoice->payment_date = $request->payment_date;
                $invoice->payment_method = (string) $request->method;
                $invoice->payment_reference = $request->reference;
                $invoice->save();
            }

            DB::commit();

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
                    'payment' => [
                        'id' => $payment->id,
                        'invoice_id' => $payment->invoice_id,
                        'amount' => (float) $payment->amount,
                        'currency' => $payment->currency,
                        'method' => $payment->method,
                        'payment_date' => $payment->payment_date?->toDateString(),
                        'reference' => $payment->reference,
                        'transaction_id' => $payment->transaction_id,
                        'notes' => $payment->notes,
                        'metadata' => $payment->metadata ?? [],
                        'created_at' => $payment->created_at?->toISOString(),
                        'updated_at' => $payment->updated_at?->toISOString(),
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
            $limit = (int) $request->get('limit', 50);
            $limit = max(1, min(200, $limit));

            $companies = Company::whereHas('invoices', function ($q) {
                $q->where('status', 'overdue')
                    ->where('due_date', '<', now());
            })
                ->with(['invoices' => function ($q) {
                    $q->where('status', 'overdue')
                        ->where('due_date', '<', now())
                        ->orderBy('due_date', 'asc');
                }])
                ->withCount(['invoices as overdue_invoices_count' => function ($q) {
                    $q->where('status', 'overdue')
                        ->where('due_date', '<', now());
                }])
                ->orderByDesc('overdue_invoices_count')
                ->limit($limit)
                ->get();

            $transformed = $companies->map(function ($company) {
                $overdueInvoices = $company->invoices ?? collect();
                $overdueTotal = (float) $overdueInvoices->sum('total_amount');

                return [
                    'id' => $company->id,
                    'name' => $company->name,
                    'email' => $company->email,
                    'phone' => $company->phone,
                    'address' => $company->address,
                    'status' => $company->status,
                    'company_type' => $company->company_type,
                    'industry_type' => $company->industry_type,
                    'overdue_invoices_count' => (int) ($company->overdue_invoices_count ?? 0),
                    'overdue_total' => $overdueTotal,
                ];
            })->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'companies' => $transformed,
                ],
                'message' => 'Companies with overdue invoices retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve companies with overdue invoices',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }
}

