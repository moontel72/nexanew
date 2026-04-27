<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Services\Pdf\SimplePdfGenerator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class AdminBillingController extends Controller
{
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
            $invoice->status = (string) $request->status;
            if ($invoice->status === 'paid') {
                $invoice->payment_date = $request->payment_date ?? now();
                $invoice->payment_method = $request->payment_method;
                $invoice->payment_reference = $request->payment_reference;
                if ($request->notes !== null) {
                    $invoice->notes = $request->notes;
                }
            }
            $invoice->save();

            return response()->json([
                'success' => true,
                'data' => [
                    'invoiceId' => $invoice->id,
                    'status' => $invoice->status,
                ],
                'message' => 'Invoice status updated',
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

    public function downloadInvoicePdf(Request $request, string $id)
    {
        try {
            $invoice = Invoice::with(['company:id,name,email,phone,address', 'subscription.plan:id,name'])
                ->findOrFail($id);

            $items = $invoice->items ?? [];
            if (is_string($items)) {
                $decoded = json_decode($items, true);
                $items = is_array($decoded) ? $decoded : [];
            }
            if (!is_array($items)) {
                $items = [];
            }

            $publishItem = null;
            foreach ($items as $it) {
                if (!is_array($it)) {
                    continue;
                }
                $meta = is_array($it['metadata'] ?? null) ? $it['metadata'] : [];
                $src = (string) ($meta['source'] ?? '');
                if ($src === 'publish_codes') {
                    $publishItem = $it;
                    break;
                }
            }

            $dailyRows = DB::table('base_codes')
                ->selectRaw("DATE(COALESCE(published_at, created_at)) as day")
                ->selectRaw('code_type')
                ->selectRaw('COUNT(*)::int as count')
                ->where('company_id', $invoice->company_id)
                ->whereRaw("metadata->>'publish_invoice_id' = ?", [$invoice->id])
                ->groupByRaw('DATE(COALESCE(published_at, created_at)), code_type')
                ->orderBy('day')
                ->get();

            $hasUnit = false;
            foreach ($dailyRows as $r) {
                if (strtolower((string) ($r->code_type ?? '')) === 'unit') {
                    $hasUnit = true;
                    break;
                }
            }

            $totalsByDay = [];
            $totalUnits = 0;
            foreach ($dailyRows as $r) {
                $day = (string) ($r->day ?? '');
                $codeType = strtolower((string) ($r->code_type ?? ''));
                $count = (int) ($r->count ?? 0);
                if ($hasUnit && $codeType !== 'unit') {
                    continue;
                }
                $totalsByDay[$day] = ($totalsByDay[$day] ?? 0) + $count;
                $totalUnits += $count;
            }

            $lines = [];
            $lines[] = 'NexaTrace Invoice';
            $lines[] = 'Invoice #: ' . (string) $invoice->invoice_number;
            $lines[] = 'Status: ' . (string) $invoice->status;
            $lines[] = 'Company: ' . (string) ($invoice->company?->name ?? '');
            $lines[] = 'Company Email: ' . (string) ($invoice->company?->email ?? '');
            $lines[] = 'Issue Date: ' . (string) $invoice->issue_date;
            $lines[] = 'Due Date: ' . (string) $invoice->due_date;
            $lines[] = 'Period: ' . (string) $invoice->period_start . ' - ' . (string) $invoice->period_end;
            $lines[] = 'Currency: ' . (string) ($invoice->currency ?? 'USD');

            if ($publishItem !== null) {
                $meta = is_array($publishItem['metadata'] ?? null) ? $publishItem['metadata'] : [];
                $monthlyFee = (float) ($meta['monthly_fee'] ?? 0);
                $rate = (float) ($meta['rate'] ?? ($publishItem['unit_price'] ?? ($publishItem['unitPrice'] ?? 0)));
                $billed = (float) ($meta['billable_count'] ?? ($publishItem['quantity'] ?? 0));
                $freeApplied = (float) ($meta['free_applied'] ?? 0);
                $usageCharge = round($billed * $rate, 2);
                $monthlyTotal = round($monthlyFee + $usageCharge, 2);

                $lines[] = '';
                $lines[] = 'Billing Breakdown:';
                $lines[] = 'Total Units: ' . (string) $totalUnits;
                $lines[] = 'Free Applied: ' . (string) $freeApplied;
                $lines[] = 'Billed Codes: ' . (string) $billed;
                $lines[] = 'Rate: ' . (string) $rate;
                $lines[] = 'Billed Amount (Billed x Rate): ' . (string) $usageCharge;
                $lines[] = 'Monthly Fee: ' . (string) $monthlyFee;
                $lines[] = 'Monthly Total (Fee + Usage): ' . (string) $monthlyTotal;

                if (!empty($totalsByDay)) {
                    $lines[] = '';
                    $lines[] = 'Daily Units:';
                    foreach ($totalsByDay as $day => $cnt) {
                        $lines[] = '- ' . (string) $day . ': ' . (string) $cnt;
                    }
                }
            }

            $lines[] = '';
            $lines[] = 'Line Items:';
            foreach ($items as $item) {
                $m = is_array($item) ? $item : [];
                $desc = (string) ($m['description'] ?? '');
                $qty = (string) ($m['quantity'] ?? '');
                $unitPrice = (string) ($m['unit_price'] ?? ($m['unitPrice'] ?? ''));
                $total = (string) ($m['total'] ?? ($m['total_price'] ?? ($m['totalPrice'] ?? '')));
                $lines[] = '- ' . $desc;
                $lines[] = '  Qty: ' . $qty . '  Unit: ' . $unitPrice . '  Total: ' . $total;
            }

            $lines[] = '';
            $lines[] = 'Subtotal: ' . (string) $invoice->subtotal;
            $lines[] = 'Tax: ' . (string) $invoice->tax_amount;
            $lines[] = 'Discount: ' . (string) $invoice->discount_amount;
            $lines[] = 'Total: ' . (string) $invoice->total_amount;

            $pdf = app(SimplePdfGenerator::class)->generate($lines);
            $fileName = (string) $invoice->invoice_number . '.pdf';

            return response($pdf, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'attachment; filename="' . $fileName . '"',
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
                    'message' => 'Failed to download invoice PDF',
                    'details' => config('app.debug') ? $e->getMessage() : null,
                ],
                'timestamp' => now()->toISOString(),
                'request_id' => $request->header('X-Request-ID'),
            ], 500);
        }
    }

    public function exportInvoicesToCsv(Request $request): JsonResponse
    {
        return response()->json([
            'success' => false,
            'error' => [
                'code' => 'NOT_IMPLEMENTED',
                'message' => 'CSV export not implemented',
            ],
            'timestamp' => now()->toISOString(),
            'request_id' => $request->header('X-Request-ID'),
        ], 501);
    }

    public function exportInvoicesToExcel(Request $request): JsonResponse
    {
        return response()->json([
            'success' => false,
            'error' => [
                'code' => 'NOT_IMPLEMENTED',
                'message' => 'Excel export not implemented',
            ],
            'timestamp' => now()->toISOString(),
            'request_id' => $request->header('X-Request-ID'),
        ], 501);
    }
}

