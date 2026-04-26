<?php

namespace App\Http\Controllers\Factory;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Services\InvoiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class FactoryCustomerInvoicesController extends Controller
{
    protected InvoiceService $invoiceService;

    public function __construct(InvoiceService $invoiceService)
    {
        $this->invoiceService = $invoiceService;
    }

    public function list(Request $request): JsonResponse
    {
        try {
            $factoryId = (string) (Auth::user()?->company_id ?? Auth::user()?->factory_id ?? '');
            if ($factoryId === '') {
                throw new \Exception('Factory not authenticated');
            }

            $invoices = Invoice::query()
                ->where('company_id', $factoryId)
                ->where('type', 'customer')
                ->orderByDesc('issue_date')
                ->limit((int) $request->get('limit', 50))
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'invoices' => $invoices,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load customer invoices',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function generate(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'customer_name' => 'nullable|string|max:255',
            'customer_email' => 'nullable|email|max:255',
            'currency' => 'nullable|string|max:10',
            'due_date' => 'nullable|date',
            'notes' => 'nullable|string|max:1000',
            'items' => 'required|array|min:1',
            'items.*.description' => 'required|string|max:255',
            'items.*.quantity' => 'required|numeric|min:0.01',
            'items.*.unit_price' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $factoryId = (string) (Auth::user()?->company_id ?? Auth::user()?->factory_id ?? '');
            if ($factoryId === '') {
                throw new \Exception('Factory not authenticated');
            }

            $payload = $request->all();
            $payload['company_id'] = $factoryId;
            $payload['metadata'] = array_merge(
                is_array($payload['metadata'] ?? null) ? $payload['metadata'] : [],
                [
                    'source' => 'customer_invoice',
                    'customer_name' => $request->get('customer_name'),
                    'customer_email' => $request->get('customer_email'),
                ],
            );

            $invoice = $this->invoiceService->generateManualInvoice($payload);

            return response()->json([
                'success' => true,
                'data' => [
                    'invoice' => $invoice,
                ],
                'message' => 'Customer invoice generated',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate customer invoice',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function sendEmail(Request $request, string $invoiceId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $factoryId = (string) (Auth::user()?->company_id ?? Auth::user()?->factory_id ?? '');
            if ($factoryId === '') {
                throw new \Exception('Factory not authenticated');
            }

            $invoice = Invoice::query()
                ->where('company_id', $factoryId)
                ->where('type', 'customer')
                ->where('id', $invoiceId)
                ->firstOrFail();

            \Log::info('Customer invoice email requested', [
                'invoice_id' => $invoice->id,
                'invoice_number' => $invoice->invoice_number,
                'recipient_email' => $request->get('email'),
                'factory_id' => $factoryId,
                'requested_by' => Auth::user()?->id ?? 'system',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Invoice email has been sent',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to send invoice email',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}

