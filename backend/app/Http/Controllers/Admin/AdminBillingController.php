<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Company;
use App\Models\CreditNote;
use App\Models\Payment;
use App\Services\BillingService;
use App\Services\InvoiceService;
use App\Services\RevenueService;
use App\Services\ExportService;
use App\Services\Pdf\SimplePdfGenerator;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Support\Str;

class AdminBillingController extends Controller
{
    protected $billingService;
    protected $invoiceService;
    protected $revenueService;

    public function __construct(
        BillingService $billingService,
        InvoiceService $invoiceService,
        RevenueService $revenueService
    ) {
        $this->billingService = $billingService;
        $this->invoiceService = $invoiceService;
        $this->revenueService = $revenueService;
    }

    /**
     * Get platform invoices with filters
     */
    public function getPlatformInvoices(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'statuses' => 'nullable|array',
            'statuses.*' => Rule::in(['draft', 'pending', 'paid', 'overdue', 'cancelled', 'refunded']),
            'search' => 'nullable|string|max:255',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
            'company_id' => 'nullable|uuid|exists:companies,id',
            'min_amount' => 'nullable|numeric|min:0',
            'max_amount' => 'nullable|numeric|min:0',
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
            $query = Invoice::with(['company:id,name,email', 'subscription.plan:id,name'])
                ->select('invoices.*')
                ->join('companies', 'invoices.company_id', '=', 'companies.id');

            // Apply filters
            if ($request->has('start_date')) {
                $query->where('invoices.issue_date', '>=', $request->start_date);
            }

            if ($request->has('end_date')) {
                $query->where('invoices.issue_date', '<=', $request->end_date);
            }

            if ($request->has('statuses') && is_array($request->statuses)) {
                $query->whereIn('invoices.status', $request->statuses);
            }

            if ($request->has('company_id')) {
                $query->where('invoices.company_id', $request->company_id);
            }

            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function ($q) use ($search) {
                    $q->where('invoices.invoice_number', 'like', "%{$search}%")
                        ->orWhere('companies.name', 'like', "%{$search}%")
                        ->orWhere('companies.email', 'like', "%{$search}%");
                });
            }

            if ($request->has('min_amount')) {
                $query->where('invoices.total_amount', '>=', $request->min_amount);
            }

            if ($request->has('max_amount')) {
                $query->where('invoices.total_amount', '<=', $request->max_amount);
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
                    'invoiceNumber' => $invoice->invoice_number,
                    'companyId' => $invoice->company_id,
                    'companyName' => $invoice->company->name,
                    'companyEmail' => $invoice->company->email,
                    'subscriptionId' => $invoice->subscription_id,
                    'subscriptionName' => $invoice->subscription?->plan?->name,
                    'periodStart' => $invoice->period_start->toDateString(),
                    'periodEnd' => $invoice->period_end->toDateString(),
                    'issueDate' => $invoice->issue_date->toDateString(),
                    'dueDate' => $invoice->due_date->toDateString(),
                    'subtotal' => (float) $invoice->subtotal,
                    'taxAmount' => (float) $invoice->tax_amount,
                    'discountAmount' => (float) $invoice->discount_amount,
                    'totalAmount' => (float) $invoice->total_amount,
                    'currency' => $invoice->currency,
                    'status' => $invoice->status,
                    'paymentDate' => $invoice->payment_date?->toDateString(),
                    'paymentMethod' => $invoice->payment_method,
                    'paymentReference' => $invoice->payment_reference,
                    'notes' => $invoice->notes,
                    'createdAt' => $invoice->created_at->toISOString(),
                    'updatedAt' => $invoice->updated_at->toISOString(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => [
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
                        'totalInvoices' => $invoices->total(),
                        'totalAmount' => (float) $invoices->sum('total_amount'),
                        'paidAmount' => (float) $invoices->where('status', 'paid')->sum('total_amount'),
                        'pendingAmount' => (float) $invoices->where('status', 'pending')->sum('total_amount'),
                        'overdueAmount' => (float) $invoices->where('status', 'overdue')->sum('total_amount'),
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

    /**
     * Get invoice by ID
     */
    public function getInvoiceById(string $id): JsonResponse
    {
        try {
            $invoice = Invoice::with([
                'company:id,name,email,phone,address',
                'subscription.plan:id,name',
                'payments' => function ($query) {
                    $query->orderBy('payment_date', 'desc');
                },
            ])->findOrFail($id);

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

            $transformedInvoice = [
                'id' => $invoice->id,
                'invoiceNumber' => $invoice->invoice_number,
                'companyId' => $invoice->company_id,
                'companyName' => $invoice->company->name,
                'companyEmail' => $invoice->company->email,
                'companyPhone' => $invoice->company->phone,
                'companyAddress' => $invoice->company->address,
                'subscriptionId' => $invoice->subscription_id,
                'subscriptionName' => $invoice->subscription?->plan?->name,
                'periodStart' => $invoice->period_start->toDateString(),
                'periodEnd' => $invoice->period_end->toDateString(),
                'issueDate' => $invoice->issue_date->toDateString(),
                'dueDate' => $invoice->due_date->toDateString(),
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
                'createdAt' => $invoice->created_at->toISOString(),
                'updatedAt' => $invoice->updated_at->toISOString(),
            ];

            return response()->json([
                'success' => true,
                'data' => $transformedInvoice,
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

    /**
     * Generate a new invoice
     */
    public function generateInvoice(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'company_id' => 'required|uuid|exists:companies,id',
            'subscription_id' => 'nullable|uuid|exists:subscriptions,id',
            'period_start' => 'required|date',
            'period_end' => 'required|date|after_or_equal:period_start',
            'due_date' => 'required|date|after_or_equal:period_end',
            'items' => 'required|array|min:1',
            'items.*.description' => 'required|string|max:500',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.unit_price' => 'required|numeric|min:0',
            'items.*.currency' => 'required|string|size:3',
            'items.*.code_type' => 'nullable|string|max:50',
            'items.*.code_count' => 'nullable|integer|min:0',
            'tax_rate' => 'nullable|numeric|min:0|max:100',
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
            $company = Company::findOrFail($request->company_id);
            $subscription = $request->subscription_id
                ? Subscription::findOrFail($request->subscription_id)
                : null;

            // Calculate totals
            $subtotal = 0;
            $items = [];

            foreach ($request->items as $item) {
                $total = $item['quantity'] * $item['unit_price'];
                $subtotal += $total;

                $items[] = [
                    'description' => $item['description'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'total' => $total,
                    'currency' => $item['currency'],
                    'code_type' => $item['code_type'] ?? null,
                    'code_count' => $item['code_count'] ?? null,
                ];
            }

            $taxRate = $request->tax_rate ?? 0;
            $taxAmount = $subtotal * ($taxRate / 100);
            $totalAmount = $subtotal + $taxAmount;

            // Generate invoice number
            $invoiceNumber = 'INV-' . date('Y') . '-' . str_pad(
                Invoice::whereYear('created_at', date('Y'))->count() + 1,
                5,
                '0',
                STR_PAD_LEFT
            );

            // Create invoice
            $invoice = Invoice::create([
                'company_id' => $company->id,
                'subscription_id' => $subscription?->id,
                'invoice_number' => $invoiceNumber,
                'period_start' => $request->period_start,
                'period_end' => $request->period_end,
                'issue_date' => now(),
                'due_date' => $request->due_date,
                'subtotal' => $subtotal,
                'tax_amount' => $taxAmount,
                'discount_amount' => 0,
                'total_amount' => $totalAmount,
                'currency' => 'USD',
                'items' => json_encode($items),
                'status' => 'pending',
                'notes' => $request->notes,
                'metadata' => json_encode([
                    'tax_rate' => $taxRate,
                    'generated_by_admin' => true,
                    'generated_at' => now()->toISOString(),
                ]),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'invoice' => [
                        'id' => $invoice->id,
                        'invoice_number' => $invoice->invoice_number,
                        'company_id' => $invoice->company_id,
                        'company_name' => $company->name,
                        'subscription_id' => $invoice->subscription_id,
                        'subscription_name' => $subscription?->name,
                        'period_start' => $invoice->period_start->toDateString(),
                        'period_end' => $invoice->period_end->toDateString(),
                        'issue_date' => $invoice->issue_date->toDateString(),
                        'due_date' => $invoice->due_date->toDateString(),
                        'subtotal' => (float) $invoice->subtotal,
                        'tax_amount' => (float) $invoice->tax_amount,
                        'total_amount' => (float) $invoice->total_amount,
                        'currency' => $invoice->currency,
                        'status' => $invoice->status,
                        'items' => $items,
                        'notes' => $invoice->notes,
                        'created_at' => $invoice->created_at->toISOString(),
                    ],
                ],
                'message' => 'Invoice generated successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVOICE_GENERATION_FAILED',
                    'message' => 'Failed to generate invoice',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Update invoice status
     */
    public function updateInvoiceStatus(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'status' => [
                'required',
                Rule::in(['pending', 'paid', 'overdue', 'cancelled', 'refunded']),
            ],
            'payment_date' => 'nullable|date|required_if:status,paid',
            'payment_method' => 'nullable|string|max:50|required_if:status,paid',
            'payment_reference' => 'nullable|string|max:255',
            'notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json
