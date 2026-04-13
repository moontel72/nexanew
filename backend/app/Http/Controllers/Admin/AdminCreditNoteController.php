<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CreditNote;
use App\Models\Invoice;
use App\Models\Company;
use App\Services\CreditNoteService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class AdminCreditNoteController extends Controller
{
    protected $creditNoteService;

    public function __construct(CreditNoteService $creditNoteService)
    {
        $this->creditNoteService = $creditNoteService;
    }

    /**
     * Get credit notes with filters
     */
    public function getCreditNotes(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'company_id' => 'nullable|uuid|exists:companies,id',
            'status' => 'nullable|string|in:pending,approved,applied,cancelled',
            'invoice_id' => 'nullable|uuid|exists:invoices,id',
            'search' => 'nullable|string|max:255',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
            'sort_by' => 'nullable|string|in:created_at,amount,issue_date',
            'sort_order' => 'nullable|string|in:asc,desc',
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
            $query = CreditNote::with([
                'company:id,name,email',
                'invoice:id,invoice_number,total_amount',
                'approvedBy:id,name,email',
            ]);

            // Apply filters
            if ($request->has('start_date')) {
                $query->where('created_at', '>=', $request->start_date);
            }

            if ($request->has('end_date')) {
                $query->where('created_at', '<=', $request->end_date);
            }

            if ($request->has('company_id')) {
                $query->where('company_id', $request->company_id);
            }

            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            if ($request->has('invoice_id')) {
                $query->where('invoice_id', $request->invoice_id);
            }

            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function ($q) use ($search) {
                    $q->where('credit_note_number', 'like', "%{$search}%")
                        ->orWhere('reason', 'like', "%{$search}%")
                        ->orWhereHas('company', function ($q) use ($search) {
                            $q->where('name', 'like', "%{$search}%")
                                ->orWhere('email', 'like', "%{$search}%");
                        });
                });
            }

            // Apply sorting
            $sortBy = $request->get('sort_by', 'created_at');
            $sortOrder = $request->get('sort_order', 'desc');
            $query->orderBy($sortBy, $sortOrder);

            // Paginate results
            $page = $request->get('page', 1);
            $limit = $request->get('limit', 20);
            $creditNotes = $query->paginate($limit, ['*'], 'page', $page);

            // Transform response
            $transformedCreditNotes = $creditNotes->map(function ($creditNote) {
                return [
                    'id' => $creditNote->id,
                    'credit_note_number' => $creditNote->credit_note_number,
                    'company_id' => $creditNote->company_id,
                    'company_name' => $creditNote->company->name,
                    'company_email' => $creditNote->company->email,
                    'invoice_id' => $creditNote->invoice_id,
                    'invoice_number' => $creditNote->invoice?->invoice_number,
                    'amount' => (float) $creditNote->amount,
                    'currency' => $creditNote->currency,
                    'reason' => $creditNote->reason,
                    'status' => $creditNote->status,
                    'issue_date' => $creditNote->issue_date->toDateString(),
                    'approved_by' => $creditNote->approvedBy ? [
                        'id' => $creditNote->approved_by,
                        'name' => $creditNote->approvedBy->name,
                        'email' => $creditNote->approvedBy->email,
                    ] : null,
                    'approved_at' => $creditNote->approved_at?->toISOString(),
                    'applied_to_invoice' => $creditNote->applied_to_invoice,
                    'applied_at' => $creditNote->applied_at?->toISOString(),
                    'notes' => $creditNote->notes,
                    'metadata' => json_decode($creditNote->metadata, true) ?? [],
                    'created_at' => $creditNote->created_at->toISOString(),
                    'updated_at' => $creditNote->updated_at->toISOString(),
                ];
            });

            // Calculate summary statistics
            $totalAmount = $creditNotes->sum('amount');
            $pendingAmount = $creditNotes->where('status', 'pending')->sum('amount');
            $approvedAmount = $creditNotes->where('status', 'approved')->sum('amount');
            $appliedAmount = $creditNotes->where('status', 'applied')->sum('amount');

            return response()->json([
                'success' => true,
                'data' => [
                    'credit_notes' => $transformedCreditNotes,
                    'pagination' => [
                        'total' => $creditNotes->total(),
                        'per_page' => $creditNotes->perPage(),
                        'current_page' => $creditNotes->currentPage(),
                        'last_page' => $creditNotes->lastPage(),
                        'from' => $creditNotes->firstItem(),
                        'to' => $creditNotes->lastItem(),
                    ],
                    'summary' => [
                        'total_credit_notes' => $creditNotes->total(),
                        'total_amount' => (float) $totalAmount,
                        'pending_amount' => (float) $pendingAmount,
                        'approved_amount' => (float) $approvedAmount,
                        'applied_amount' => (float) $appliedAmount,
                        'average_amount' => $creditNotes->count() > 0 ? (float) ($totalAmount / $creditNotes->count()) : 0,
                    ],
                ],
                'message' => 'Credit notes retrieved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'SERVER_ERROR',
                    'message' => 'Failed to retrieve credit notes',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Create a new credit note
     */
    public function createCreditNote(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'invoice_id' => 'required|uuid|exists:invoices,id',
            'amount' => 'required|numeric|min:0.01',
            'reason' => 'required|string|max:500',
            'notes' => 'nullable|string|max:1000',
            'auto_approve' => 'nullable|boolean',
            'apply_to_invoice' => 'nullable|boolean',
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
            $invoice = Invoice::with('company')->findOrFail($request->invoice_id);

            // Validate amount doesn't exceed invoice total
            if ($request->amount > $invoice->total_amount) {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'AMOUNT_EXCEEDS_INVOICE',
                        'message' => 'Credit note amount cannot exceed invoice total amount',
                        'details' => [
                            'invoice_amount' => $invoice->total_amount,
                            'credit_note_amount' => $request->amount,
                        ],
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => $request->header('X-Request-ID'),
                ], 400);
            }

            // Generate credit note number
            $creditNoteNumber = 'CN-' . date('Y') . '-' . str_pad(
                CreditNote::whereYear('created_at', date('Y'))->count() + 1,
                5,
                '0',
                STR_PAD_LEFT
            );

            // Determine initial status
            $autoApprove = $request->get('auto_approve', false);
            $initialStatus = $autoApprove ? 'approved' : 'pending';

            // Create credit note
            $creditNote = CreditNote::create([
                'company_id' => $invoice->company_id,
                'invoice_id' => $invoice->id,
                'credit_note_number' => $creditNoteNumber,
                'amount' => $request->amount,
                'currency' => $invoice->currency,
                'reason' => $request->reason,
                'status' => $initialStatus,
                'issue_date' => now(),
                'approved_by' => $autoApprove ? auth()->id() : null,
                'approved_at' => $autoApprove ? now() : null,
                'notes' => $request->notes,
                'metadata' => json_encode([
                    'created_by_admin' => true,
                    'created_at' => now()->toISOString(),
                    'auto_approved' => $autoApprove,
                    'invoice_total' => $invoice->total_amount,
                ]),
            ]);

            // Apply to invoice if requested
            $applyToInvoice = $request->get('apply_to_invoice', false);
            if ($applyToInvoice && $initialStatus === 'approved') {
                $this->creditNoteService->applyCreditNoteToInvoice($creditNote->id, auth()->id());
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'credit_note' => [
                        'id' => $creditNote->id,
                        'credit_note_number' => $creditNote->credit_note_number,
                        'company_id' => $creditNote->company_id,
                        'company_name' => $invoice->company->name,
                        'invoice_id' => $creditNote->invoice_id,
                        'invoice_number' => $invoice->invoice_number,
                        'amount' => (float) $creditNote->amount,
                        'currency' => $creditNote->currency,
                        'reason' => $creditNote->reason,
                        'status' => $creditNote->status,
                        'issue_date' => $creditNote->issue_date->toDateString(),
                        'approved_by' => $creditNote->approved_by,
                        'approved_at' => $creditNote->approved_at?->toISOString(),
                        'applied_to_invoice' => $creditNote->applied_to_invoice,
                        'applied_at' => $creditNote->applied_at?->toISOString(),
                        'notes' => $creditNote->notes,
                        'created_at' => $creditNote->created_at->toISOString(),
                    ],
                ],
                'message' => 'Credit note created successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'CREDIT_NOTE_CREATION_FAILED',
                    'message' => 'Failed to create credit note',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Approve a credit note
     */
    public function approveCreditNote(string $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $creditNote = CreditNote::with(['invoice', 'company'])->findOrFail($id);

            // Check if credit note is already approved
            if ($creditNote->status === 'approved') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'ALREADY_APPROVED',
                        'message' => 'Credit note is already approved',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => request()->header('X-Request-ID'),
                ], 400);
            }

            // Check if credit note is cancelled
            if ($creditNote->status === 'cancelled') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'CANCELLED_CREDIT_NOTE',
                        'message' => 'Cannot approve a cancelled credit note',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => request()->header('X-Request-ID'),
                ], 400);
            }

            // Update credit note
            $creditNote->update([
                'status' => 'approved',
                'approved_by' => auth()->id(),
                'approved_at' => now(),
                'metadata' => json_encode(array_merge(
                    json_decode($creditNote->metadata, true) ?? [],
                    [
                        'approved_by_admin' => true,
                        'approved_at' => now()->toISOString(),
                    ]
                )),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'credit_note' => [
                        'id' => $creditNote->id,
                        'credit_note_number' => $creditNote->credit_note_number,
                        'company_name' => $creditNote->company->name,
                        'invoice_number' => $creditNote->invoice?->invoice_number,
                        'amount' => (float) $creditNote->amount,
                        'status' => $creditNote->status,
                        'approved_by' => auth()->id(),
                        'approved_at' => $creditNote->approved_at->toISOString(),
                    ],
                ],
                'message' => 'Credit note approved successfully',
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'CREDIT_NOTE_NOT_FOUND',
                    'message' => 'Credit note not found',
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 404);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'APPROVAL_FAILED',
                    'message' => 'Failed to approve credit note',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => request()->header('X-Request-ID'),
            ], 500);
        }
    }

    /**
     * Apply credit note to invoice
     */
    public function applyCreditNoteToInvoice(string $id): JsonResponse
    {
        DB::beginTransaction();

        try {
            $creditNote = CreditNote::with(['invoice', 'company'])->findOrFail($id);

            // Check if credit note is approved
            if ($creditNote->status !== 'approved') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'NOT_APPROVED',
                        'message' => 'Credit note must be approved before applying to invoice',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => request()->header('X-Request-ID'),
                ], 400);
            }

            // Check if credit note is already applied
            if ($creditNote->status === 'applied') {
                return response()->json([
                    'success' => false,
                    'error' => [
                        'code' => 'ALREADY_APPLIED',
                        'message' => 'Credit note is already applied to invoice',
                    ],
                    'timestamp' => now()->toISOString(),
                    'request_id' => request()->header('X-Request-ID'),
                ], 400);
            }

            // Apply credit note to invoice
            $result = $this->creditNoteService->applyCreditNoteToInvoice($id, auth()->id());

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'credit_note' => [
                        'id' => $creditNote->id,
                        'credit_note_number' => $creditNote->credit_note_number,
                        'company_name' => $creditNote->company->name,
                        'invoice_number' => $creditNote->invoice?->invoice_number,
                        'amount' => (float) $creditNote->amount,
                        'status' => 'applied',
                        'applied_to_invoice' => true,
                        'applied_at' => now()->toISOString(),
                    ],
                    'invoice' => $result['invoice'] ?? null,
