<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Payment;
use App\Services\InvoiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AdminBillingControllerNew extends Controller
{
    protected InvoiceService $invoiceService;

    public function __construct(InvoiceService $invoiceService)
    {
        $this->invoiceService = $invoiceService;
    }

    public function getPlatformInvoices(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'search' => 'nullable|string|max:255',
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
            $query = Invoice::with(['company:id,name,email', 'subscription.plan:id,name']);

            if ($request->filled('search')) {
                $search = $request->search;
                $query->where(function ($q) use ($search) {
                    $q->where('invoice_number', 'like', "%{$search}%")
                        ->orWhereHas('company', function ($cq) use ($search) {
                            $cq->where('name', 'like', "%{$search}%")
                                ->orWhere('email', 'like', "%{$search}%");
                        });
                });
            }

            $page = (int) $request->get('page', 1);
            $limit = (int) $request->get('limit', 20);
            $invoices = $query->orderByDesc('issue_date')->paginate($limit, ['*'], 'page', $page);

            $transformed = $invoices->getCollection()->map(function ($invoice) {
                return [
                    'id' => $invoice->id,
                    'invoiceNumber' => $invoice->invoice_number,
                    'companyId' => $invoice->company_id,
                    'companyName' => $invoice->company?->name,
                    'companyEmail' => $invoice->company?->email,
                    'subscriptionId' => $invoice->subscription_id,
                    'subscriptionName' => $invoice->subscription?->plan?->name,
                    'issueDate' => $invoice->issue_date?->toDateString(),
                    'dueDate' => $invoice->due_date?->toDateString(),
                    'totalAmount' => (float) $invoice->total_amount,
                    'currency' => $invoice->currency,
                    'status' => $invoice->status,
                    'paymentMethod' => $invoice->payment_method,
                    'createdAt' => $invoice->created_at?->toISOString(),
                    'updatedAt' => $invoice->updated_at?->toISOString(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => [
                    'invoices' => $transformed,
                    'pagination' => [
                        'total' => $invoices->total(),
                        'per_page' => $invoices->perPage(),
                        'current_page' => $invoices->currentPage(),
                        'last_page' => $invoices->lastPage(),
                    ],
                ],
                'message' => 'Invoices retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve invoices',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    public function getInvoiceById(string $id): JsonResponse
    {
        try {
            $invoice = Invoice::with(['company:id,name,email,phone,address', 'subscription.plan:id,name'])
                ->findOrFail($id);

            $items = $invoice->items ?? [];
            if (!is_array($items)) {
                $items = [];
            }

            $normalizedItems = array_map(function ($item) {
                $m = is_array($item) ? $item : [];
                $unitPrice = $m['unit_price'] ?? ($m['unitPrice'] ?? 0);
                $total = $m['total'] ?? ($m['total_price'] ?? ($m['totalPrice'] ?? 0));

                return [
                    'id' => $m['id'] ?? Str::uuid()->toString(),
                    'description' => $m['description'] ?? '',
                    'quantity' => (float) ($m['quantity'] ?? 0),
                    'unitPrice' => (float) $unitPrice,
                    'total' => (float) $total,
                    'currency' => $m['currency'] ?? 'USD',
                    'codeType' => $m['code_type'] ?? ($m['codeType'] ?? null),
                    'codeCount' => $m['code_count'] ?? ($m['codeCount'] ?? null),
                    'periodStart' => $m['period_start'] ?? ($m['periodStart'] ?? null),
                    'periodEnd' => $m['period_end'] ?? ($m['periodEnd'] ?? null),
                    'metadata' => $m['metadata'] ?? null,
                ];
            }, $items);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $invoice->id,
                    'invoiceNumber' => $invoice->invoice_number,
                    'companyId' => $invoice->company_id,
                    'companyName' => $invoice->company?->name,
                    'companyEmail' => $invoice->company?->email,
                    'companyPhone' => $invoice->company?->phone,
                    'companyAddress' => $invoice->company?->address,
                    'subscriptionId' => $invoice->subscription_id,
                    'subscriptionName' => $invoice->subscription?->plan?->name,
                    'periodStart' => $invoice->period_start?->toDateString(),
                    'periodEnd' => $invoice->period_end?->toDateString(),
                    'issueDate' => $invoice->issue_date?->toDateString(),
                    'dueDate' => $invoice->due_date?->toDateString(),
                    'subtotal' => (float) $invoice->subtotal,
                    'taxAmount' => (float) $invoice->tax_amount,
                    'discountAmount' => (float) $invoice->discount_amount,
                    'totalAmount' => (float) $invoice->total_amount,
                    'currency' => $invoice->currency,
                    'items' => $normalizedItems,
                    'status' => $invoice->status,
                    'paymentDate' => $invoice->payment_date?->toDateString(),
                    'paymentMethod' => $invoice->payment_method,
                    'paymentReference' => $invoice->payment_reference,
                    'notes' => $invoice->notes,
                    'metadata' => $invoice->metadata ?? [],
                    'createdAt' => $invoice->created_at?->toISOString(),
                    'updatedAt' => $invoice->updated_at?->toISOString(),
                ],
                'message' => 'Invoice retrieved successfully',
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
                    'message' => 'Failed to retrieve invoice',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 500);
        }
    }

    public function generateInvoice(Request $request): JsonResponse
    {
        return response()->json([
            'success' => false,
            'error' => [
                'code' => 'NOT_IMPLEMENTED',
                'message' => 'Not implemented',
            ],
        ], 501);
    }

    public function updateInvoiceStatus(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => [
                'required',
                Rule::in(['draft', 'pending', 'paid', 'overdue', 'cancelled', 'refunded']),
            ],
            'payment_date' => 'nullable|date|required_if:status,paid',
            'payment_method' => 'nullable|string|max:50|required_if:status,paid',
            'payment_reference' => 'nullable|string|max:255',
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

        try {
            $invoice = Invoice::findOrFail($id);

            $invoice->status = $request->status;
            if ($request->status === 'paid') {
                $invoice->payment_date = $request->payment_date;
                $invoice->payment_method = $request->payment_method;
                $invoice->payment_reference = $request->payment_reference;
            }
            if ($request->notes !== null) {
                $invoice->notes = $request->notes;
            }
            $invoice->save();

            return response()->json([
                'success' => true,
                'data' => [
                    'invoiceId' => $invoice->id,
                    'status' => $invoice->status,
                ],
                'message' => 'Invoice status updated successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
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
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to update invoice status',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    public function addExtraCharge(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'description' => 'required|string|max:500',
            'unit_price' => 'required|numeric|min:0',
            'quantity' => 'nullable|numeric|min:0.01',
            'metadata' => 'nullable|array',
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
            $invoice = Invoice::findOrFail($id);
            if ($invoice->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'INVALID_STATUS',
                        'message' => 'Extra charges can only be added to pending invoices',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => $request->header('X-Request-ID'),
                ], 409);
            }

            $updated = $this->invoiceService->addItemToInvoice($id, [
                'description' => $request->description,
                'item_type' => 'extra_charge',
                'quantity' => $request->quantity ?? 1,
                'unit_price' => $request->unit_price,
                'metadata' => array_merge(['source' => 'extra_charge'], $request->metadata ?? []),
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'invoiceId' => $updated->id,
                    'totalAmount' => (float) $updated->total_amount,
                ],
                'message' => 'Extra charge added',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
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
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to add extra charge',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    public function markInvoiceAsPaid(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'payment_method' => 'required|string|max:50',
            'payment_date' => 'nullable|date',
            'payment_reference' => 'nullable|string|max:255',
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

            $invoice->status = 'paid';
            $invoice->payment_date = $request->payment_date ?? now();
            $invoice->payment_method = $request->payment_method;
            $invoice->payment_reference = $request->payment_reference;
            if ($request->notes !== null) {
                $invoice->notes = $request->notes;
            }
            $invoice->save();

            Payment::create([
                'id' => Str::uuid()->toString(),
                'invoice_id' => $invoice->id,
                'amount' => (float) $invoice->total_amount,
                'currency' => $invoice->currency,
                'method' => $request->payment_method,
                'payment_date' => $invoice->payment_date,
                'reference' => $request->payment_reference,
                'notes' => $request->notes,
                'metadata' => [
                    'marked_paid_by_admin' => true,
                ],
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'invoiceId' => $invoice->id,
                    'status' => $invoice->status,
                ],
                'message' => 'Invoice marked as paid',
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
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to mark invoice as paid',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }
}
