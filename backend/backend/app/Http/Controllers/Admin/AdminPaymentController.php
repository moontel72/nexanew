<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Invoice;
use App\Models\Company;
use App\Services\PaymentService;
use App\Services\ReconciliationService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class AdminPaymentController extends Controller
{
    protected $paymentService;
    protected $reconciliationService;

    public function __construct(
        PaymentService $paymentService,
        ReconciliationService $reconciliationService
    ) {
        $this->paymentService = $paymentService;
        $this->reconciliationService = $reconciliationService;
    }

    /**
     * Get payment reconciliation data
     */
    public function getPaymentReconciliation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reconciliation_date' => 'nullable|date',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'status' => 'nullable|string|in:pending,matched,discrepancy,resolved',
            'gateway_name' => 'nullable|string|max:50',
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
            $reconciliationDate = $request->reconciliation_date ?? now()->toDateString();
            $startDate = $request->start_date ?? Carbon::parse($reconciliationDate)->subDays(7)->toDateString();
            $endDate = $request->end_date ?? $reconciliationDate;

            // Get payments for reconciliation period
            $payments = Payment::whereBetween('payment_date', [$startDate, $endDate])
                ->with(['invoice:id,invoice_number,company_id,total_amount', 'invoice.company:id,name'])
                ->when($request->has('status'), function ($query) use ($request) {
                    $query->where('reconciliation_status', $request->status);
                })
                ->when($request->has('gateway_name'), function ($query) use ($request) {
                    $query->where('gateway_name', $request->gateway_name);
                })
                ->orderBy('payment_date', 'desc')
                ->paginate($request->get('limit', 20));

            // Calculate reconciliation statistics
            $totalPayments = Payment::whereBetween('payment_date', [$startDate, $endDate])->count();
            $matchedPayments = Payment::whereBetween('payment_date', [$startDate, $endDate])
                ->where('reconciliation_status', 'matched')
                ->count();
            $unmatchedPayments = Payment::whereBetween('payment_date', [$startDate, $endDate])
                ->where('reconciliation_status', 'unmatched')
                ->count();
            $discrepancyPayments = Payment::whereBetween('payment_date', [$startDate, $endDate])
                ->where('reconciliation_status', 'discrepancy')
                ->count();

            $totalAmount = Payment::whereBetween('payment_date', [$startDate, $endDate])->sum('amount');
            $matchedAmount = Payment::whereBetween('payment_date', [$startDate, $endDate])
                ->where('reconciliation_status', 'matched')
                ->sum('amount');
            $discrepancyAmount = Payment::whereBetween('payment_date', [$startDate, $endDate])
                ->where('reconciliation_status', 'discrepancy')
                ->sum('amount');

            $transformedPayments = $payments->map(function ($payment) {
                return [
                    'id' => $payment->id,
                    'invoice_id' => $payment->invoice_id,
                    'invoice_number' => $payment->invoice?->invoice_number,
                    'company_name' => $payment->invoice?->company?->name,
                    'amount' => (float) $payment->amount,
                    'currency' => $payment->currency,
                    'method' => $payment->method,
                    'payment_date' => $payment->payment_date->toDateString(),
                    'reference' => $payment->reference,
                    'transaction_id' => $payment->transaction_id,
                    'gateway_name' => $payment->gateway_name,
                    'gateway_transaction_id' => $payment->gateway_transaction_id,
                    'reconciliation_status' => $payment->reconciliation_status,
                    'expected_amount' => (float) $payment->expected_amount,
                    'discrepancy_amount' => (float) $payment->discrepancy_amount,
                    'reconciliation_notes' => $payment->reconciliation_notes,
                    'reconciled_at' => $payment->reconciled_at?->toISOString(),
                    'reconciled_by' => $payment->reconciled_by,
                    'created_at' => $payment->created_at->toISOString(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => [
                    'reconciliation_date' => $reconciliationDate,
                    'period' => [
                        'start_date' => $startDate,
                        'end_date' => $endDate,
                    ],
                    'statistics' => [
                        'total_payments' => $totalPayments,
                        'matched_payments' => $matchedPayments,
                        'unmatched_payments' => $unmatchedPayments,
                        'discrepancy_payments' => $discrepancyPayments,
                        'match_rate' => $totalPayments > 0 ? ($matchedPayments / $totalPayments) * 100 : 0,
                        'total_amount' => (float) $totalAmount,
                        'matched_amount' => (float) $matchedAmount,
                        'discrepancy_amount' => (float) $discrepancyAmount,
                    ],
                    'payments' => $transformedPayments,
                    'pagination' => [
                        'total' => $payments->total(),
                        'per_page' => $payments->perPage(),
                        'current_page' => $payments->currentPage(),
                        'last_page' => $payments->lastPage(),
                        'from' => $payments->firstItem(),
                        'to' => $payments->lastItem(),
                    ],
                ],
                'message' => 'Payment reconciliation data retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve payment reconciliation data',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Reconcile payments
     */
    public function reconcilePayments(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reconciliation_date' => 'required|date',
            'gateway_name' => 'required|string|max:50',
            'gateway_transactions' => 'required|array|min:1',
            'gateway_transactions.*.transaction_id' => 'required|string|max:255',
            'gateway_transactions.*.amount' => 'required|numeric|min:0.01',
            'gateway_transactions.*.currency' => 'required|string|size:3',
            'gateway_transactions.*.payment_date' => 'required|date',
            'gateway_transactions.*.customer_email' => 'nullable|email',
            'gateway_transactions.*.customer_name' => 'nullable|string|max:255',
            'gateway_transactions.*.description' => 'nullable|string|max:500',
            'auto_match' => 'nullable|boolean',
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
            $reconciliationDate = $request->reconciliation_date;
            $gatewayName = $request->gateway_name;
            $gatewayTransactions = $request->gateway_transactions;
            $autoMatch = $request->get('auto_match', true);
            $notes = $request->notes;

            $results = $this->reconciliationService->reconcilePayments(
                $reconciliationDate,
                $gatewayName,
                $gatewayTransactions,
                $autoMatch,
                $notes,
                auth()->id()
            );

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'reconciliation_date' => $reconciliationDate,
                    'gateway_name' => $gatewayName,
                    'total_transactions' => count($gatewayTransactions),
                    'results' => $results,
                    'summary' => [
                        'matched' => count(array_filter($results, fn($r) => $r['status'] === 'matched')),
                        'unmatched' => count(array_filter($results, fn($r) => $r['status'] === 'unmatched')),
                        'discrepancy' => count(array_filter($results, fn($r) => $r['status'] === 'discrepancy')),
                        'requires_review' => count(array_filter($results, fn($r) => $r['status'] === 'requires_review')),
                    ],
                ],
                'message' => 'Payments reconciled successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'RECONCILIATION_FAILED',
                    'message' => 'Failed to reconcile payments',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Analyze reconciliation discrepancies
     */
    public function analyzeReconciliation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'reconciliation_date' => 'required|date',
            'analysis_type' => 'nullable|string|in:discrepancies,unmatched,patterns',
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
            $reconciliationDate = $request->reconciliation_date;
            $analysisType = $request->get('analysis_type', 'discrepancies');

            $analysis = $this->reconciliationService->analyzeReconciliation(
                $reconciliationDate,
                $analysisType
            );

            return response()->json([
                'success' => true,
                'data' => [
                    'reconciliation_date' => $reconciliationDate,
                    'analysis_type' => $analysisType,
                    'analysis' => $analysis,
                ],
                'message' => 'Reconciliation analysis completed successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'ANALYSIS_FAILED',
                    'message' => 'Failed to analyze reconciliation',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Resolve reconciliation discrepancy
     */
    public function resolveDiscrepancy(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'resolution_type' => [
                'required',
                Rule::in(['adjust_amount', 'mark_as_matched', 'create_adjustment', 'flag_for_review']),
            ],
            'adjusted_amount' => 'nullable|numeric|min:0|required_if:resolution_type,adjust_amount',
            'notes' => 'required|string|max:1000',
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
            $payment = Payment::findOrFail($id);

            // Check if payment is already reconciled
            if ($payment->reconciliation_status === 'matched') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'ALREADY_RECONCILED',
                        'message' => 'Payment is already reconciled',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => $request->header('X-Request-ID'),
                ], 400);
            }

            $resolutionType = $request->resolution_type;
            $adjustedAmount = $request->adjusted_amount;
            $notes = $request->notes;

            // Apply resolution based on type
            switch ($resolutionType) {
                case 'adjust_amount':
                    if ($adjustedAmount === null) {
                        throw new \InvalidArgumentException('Adjusted amount is required for adjust_amount resolution');
                    }

                    // Update payment amount
                    $payment->update([
                        'amount' => $adjustedAmount,
                        'discrepancy_amount' => abs($adjustedAmount - $payment->expected_amount),
                        'reconciliation_status' => 'matched',
                        'reconciliation_notes' => $notes . "\n\nAmount adjusted from {$payment->amount} to {$adjustedAmount}",
                        'reconciled_at' => now(),
                        'reconciled_by' => auth()->id(),
                    ]);
                    break;

                case 'mark_as_matched':
                    $payment->update([
                        'reconciliation_status' => 'matched',
                        'reconciliation_notes' => $notes,
                        'reconciled_at' => now(),
                        'reconciled_by' => auth()->id(),
                    ]);
                    break;

                case 'create_adjustment':
                    // Create adjustment record (simplified for now)
                    $payment->update([
                        'reconciliation_status' => 'matched',
                        'reconciliation_notes' => $notes . "\n\nAdjustment created for discrepancy",
                        'reconciled_at' => now(),
                        'reconciled_by' => auth()->id(),
                        'metadata' => json_encode(array_merge(
                            json_decode($payment->metadata, true) ?? [],
                            ['adjustment_created' => true, 'adjustment_date' => now()->toISOString()]
                        )),
                    ]);
                    break;

                case 'flag_for_review':
                    $payment->update([
                        'reconciliation_status' => 'requires_review',
                        'reconciliation_notes' => $notes,
                    ]);
                    break;
            }

            // Update invoice if payment is now matched
            if ($payment->reconciliation_status === 'matched' && $payment->invoice) {
                $invoice = $payment->invoice;
                $totalPaid = Payment::where('invoice_id', $invoice->id)
                    ->where('reconciliation_status', 'matched')
                    ->sum('amount');

                if ($totalPaid >= $invoice->total_amount) {
                    $invoice->update([
                        'status' => 'paid',
                        'payment_date' => now(),
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'payment' => [
                        'id' => $payment->id,
                        'invoice_id' => $payment->invoice_id,
                        'invoice_number' => $payment->invoice?->invoice_number,
                        'amount' => (float) $payment->amount,
                        'expected_amount' => (float) $payment->expected_amount,
                        'discrepancy_amount' => (float) $payment->discrepancy_amount,
                        'reconciliation_status' => $payment->reconciliation_status,
                        'reconciliation_notes' => $payment->reconciliation_notes,
                        'reconciled_at' => $payment->reconciled_at?->toISOString(),
                        'reconciled_by' => $payment->reconciled_by,
                    ],
                    'resolution' => [
                        'type' => $resolutionType,
                        'adjusted_amount' => $adjustedAmount,
                        'notes' => $notes,
                        'resolved_by' => auth()->id(),
                        'resolved_at' => now()->toISOString(),
                    ],
                ],
                'message' => 'Discrepancy resolved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'PAY
