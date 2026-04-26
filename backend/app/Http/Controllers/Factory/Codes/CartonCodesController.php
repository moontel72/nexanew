<?php

namespace App\Http\Controllers\Factory\Codes;

use App\Http\Controllers\Controller;
use App\Models\CompanySubscription;
use App\Models\Invoice;
use App\Models\Product;
use App\Models\SubscriptionPlan;
use App\Services\Codes\CodeExportLockedException;
use App\Services\Codes\CodeGenerator;
use App\Services\Codes\CodeExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class CartonCodesController extends Controller
{
    public function __construct(private CodeGenerator $generator, private CodeExportService $exporter)
    {
    }

    public function generate(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'count' => ['required', 'integer', 'min:1', 'max:2000'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'bundle_code_id' => ['nullable', 'uuid'],
            'bundle_code' => ['nullable', 'string', 'max:255'],
            'packet_count' => ['required', 'integer', 'min:1', 'max:10000'],
            'total_units' => ['nullable', 'integer', 'min:1', 'max:1000000'],
            'units_per_packet' => ['nullable', 'integer', 'min:1', 'max:10000'],
        ]);

        $companyId = (string) $user->company_id;
        $subscription = CompanySubscription::query()->where('company_id', $companyId)->where('status', 'active')->first();
        if (!$subscription) {
            return response()->json(['message' => 'No active subscription'], 422);
        }

        $planId = (string) $subscription->plan_id;
        $count = (int) $data['count'];

        $nextSeq = (int) (DB::table('carton_codes')
            ->join('base_codes', 'carton_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->max('carton_codes.sequence_number') ?? 0) + 1;

        $bundleCodeId = $data['bundle_code_id'] ?? null;
        if (!$bundleCodeId && !empty($data['bundle_code'])) {
            $bundleCodeId = DB::table('bundle_codes')
                ->join('base_codes', 'bundle_codes.id', '=', 'base_codes.id')
                ->where('base_codes.company_id', $companyId)
                ->where('base_codes.code_type', 'bundle')
                ->where('base_codes.code', (string) $data['bundle_code'])
                ->value('bundle_codes.id');
        }

        $totalUnits = $data['total_units'] ?? null;
        if ($totalUnits === null) {
            $upp = $data['units_per_packet'] ?? null;
            if ($upp !== null) {
                $totalUnits = (int) $data['packet_count'] * (int) $upp;
            }
        }

        if ($totalUnits === null) {
            return response()->json(['message' => 'total_units or units_per_packet is required'], 422);
        }

        DB::transaction(function () use ($companyId, $planId, $count, $nextSeq, $data, $bundleCodeId, $totalUnits) {
            $baseRows = $this->generator->generateBase($companyId, $planId, 'carton', $count, [
                'batch_id' => $data['batch_id'] ?? null,
            ]);

            $rows = [];
            for ($i = 0; $i < $count; $i++) {
                $id = $baseRows[$i]['id'];
                $rows[] = [
                    'id' => $id,
                    'bundle_code_id' => $bundleCodeId,
                    'packet_count' => (int) $data['packet_count'],
                    'packet_codes' => '{}',
                    'sequence_number' => $nextSeq + $i,
                    'total_units' => (int) $totalUnits,
                    'weight_kg' => null,
                    'dimensions' => null,
                    'carton_type' => null,
                    'grade' => null,
                    'max_weight_capacity_kg' => null,
                    'is_sealed' => false,
                    'sealed_at' => null,
                    'sealed_by' => null,
                    'temperature_requirements' => null,
                    'handling_instructions' => null,
                    'carton_barcode' => null,
                    'carton_qr_code' => null,
                    'condition' => 'New',
                    'last_inspection_date' => null,
                    'inspection_notes' => null,
                ];
            }

            DB::table('carton_codes')->insert($rows);
        });

        return response()->json(['success' => true, 'data' => ['generated_count' => $count]]);
    }

    public function list(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $query = DB::table('carton_codes')
            ->join('base_codes', 'carton_codes.id', '=', 'base_codes.id')
            ->leftJoin('base_codes as bundle_base', 'carton_codes.bundle_code_id', '=', 'bundle_base.id')
            ->select([
                'carton_codes.*',
                'base_codes.code',
                'base_codes.code_type',
                'base_codes.status',
                'base_codes.company_id',
                'base_codes.subscription_plan_id',
                'base_codes.store_keeper_code',
                'base_codes.international_code',
                'base_codes.batch_id',
                'base_codes.generated_at',
                'base_codes.linked_at',
                'base_codes.published_at',
                'base_codes.deactivated_at',
                'base_codes.product_id',
                'base_codes.product_batch_number',
                'base_codes.manufacturing_date',
                'base_codes.expiry_date',
                'base_codes.warranty_months',
                'base_codes.qr_code_data',
                'base_codes.barcode_data',
                'base_codes.metadata',
                'base_codes.version',
                'base_codes.is_deleted',
                'base_codes.created_at',
                'base_codes.updated_at',
                'bundle_base.code as bundle_code_value',
            ])
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'carton');

        $page = (int) $request->query('page', 1);
        $limit = (int) $request->query('limit', 50);
        $limit = max(1, min(200, $limit));

        $paginator = $query->orderByDesc('base_codes.generated_at')->paginate($limit, ['*'], 'page', $page);

        $dt = static fn ($v) => $v ? Carbon::parse($v)->toISOString() : null;

        $items = collect($paginator->items())->map(function ($row) use ($dt) {
            $packetCodes = [];
            if (!empty($row->packet_codes)) {
                $decoded = is_string($row->packet_codes) ? json_decode($row->packet_codes, true) : $row->packet_codes;
                if (is_array($decoded)) {
                    $packetCodes = array_values(array_filter($decoded, fn ($v) => is_string($v)));
                }
            }

            return [
                'id' => (string) $row->id,
                'code' => (string) $row->code,
                'type' => (string) $row->code_type,
                'status' => (string) $row->status,
                'factoryId' => (string) $row->company_id,
                'subscriptionPlanId' => (string) $row->subscription_plan_id,
                'storeKeeperCode' => (string) $row->store_keeper_code,
                'internationalCode' => (string) ($row->international_code ?? ''),
                'batchId' => (string) ($row->batch_id ?? ''),
                'generatedAt' => $dt($row->generated_at),
                'linkedAt' => $dt($row->linked_at),
                'publishedAt' => $dt($row->published_at),
                'deactivatedAt' => $dt($row->deactivated_at),
                'productId' => $row->product_id,
                'productBatchNumber' => $row->product_batch_number,
                'manufacturingDate' => $dt($row->manufacturing_date),
                'expiryDate' => $dt($row->expiry_date),
                'warrantyMonths' => $row->warranty_months,
                'qrCodeData' => $row->qr_code_data,
                'barcodeData' => $row->barcode_data,
                'metadata' => is_string($row->metadata) ? $row->metadata : json_encode($row->metadata ?? []),
                'version' => (int) ($row->version ?? 1),
                'createdAt' => $dt($row->created_at),
                'updatedAt' => $dt($row->updated_at),
                'isDeleted' => (bool) ($row->is_deleted ?? false),
                'bundleCode' => (string) ($row->bundle_code_value ?? ''),
                'packetCount' => (int) ($row->packet_count ?? 0),
                'packetCodes' => $packetCodes,
                'weight' => $row->weight_kg,
                'dimensions' => $row->dimensions,
                'sequenceNumber' => (int) ($row->sequence_number ?? 0),
                'totalUnits' => (int) ($row->total_units ?? 0),
                'cartonType' => $row->carton_type,
                'grade' => $row->grade,
                'maxWeightCapacity' => $row->max_weight_capacity_kg,
                'isSealed' => (bool) ($row->is_sealed ?? false),
                'sealedAt' => $dt($row->sealed_at),
                'sealedBy' => $row->sealed_by,
                'temperatureRequirements' => $row->temperature_requirements,
                'handlingInstructions' => $row->handling_instructions,
                'cartonBarcode' => $row->carton_barcode,
                'cartonQrCode' => $row->carton_qr_code,
                'condition' => (string) ($row->condition ?? 'New'),
                'lastInspectionDate' => $dt($row->last_inspection_date),
                'inspectionNotes' => $row->inspection_notes,
            ];
        })->all();

        return response()->json([
            'success' => true,
            'data' => [
                'carton_codes' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function link(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'code_id' => ['required', 'uuid'],
            'product_id' => ['required', 'uuid'],
            'product_batch_number' => ['nullable', 'string', 'max:100'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
        ]);

        $product = Product::query()
            ->where('id', (string) $data['product_id'])
            ->where('company_id', $companyId)
            ->firstOrFail();

        $now = now();

        $updated = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'carton')
            ->where('id', (string) $data['code_id'])
            ->whereNull('published_at')
            ->update([
                'product_id' => (string) $product->id,
                'product_batch_number' => $data['product_batch_number'] ?? null,
                'manufacturing_date' => $data['manufacturing_date'] ?? null,
                'expiry_date' => $data['expiry_date'] ?? null,
                'warranty_months' => $data['warranty_months'] ?? null,
                'status' => 'linked',
                'linked_at' => $now,
                'updated_at' => $now,
            ]);

        return response()->json([
            'success' => true,
            'data' => [
                'linked_count' => (int) $updated,
            ],
        ]);
    }

    public function publish(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'code_ids' => ['required', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'product_batch_number' => ['nullable', 'string', 'max:100'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
        ]);

        $subscription = CompanySubscription::query()
            ->where('company_id', $companyId)
            ->where('status', 'active')
            ->first();
        if (!$subscription) {
            return response()->json(['message' => 'No active subscription'], 422);
        }

        $plan = SubscriptionPlan::query()->find((string) $subscription->plan_id);
        if (!$plan) {
            return response()->json(['message' => 'Invalid subscription plan'], 422);
        }

        $query = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'carton')
            ->whereIn('id', $data['code_ids'])
            ->whereNull('published_at')
            ->whereIn('status', ['generated', 'linked']);

        $toPublish = (int) $query->count('id');
        if ($toPublish <= 0) {
            return response()->json([
                'success' => true,
                'data' => [
                    'published_count' => 0,
                ],
            ]);
        }

        $limit = (int) ($plan->monthly_carton_codes ?? 0);
        $used = (int) ($subscription->current_carton_codes_used ?? 0);
        if ($limit > 0 && ($used + $toPublish) > $limit) {
            return response()->json([
                'message' => 'Carton code publish exceeds subscription limit',
                'data' => [
                    'limit' => $limit,
                    'used' => $used,
                    'requested' => $toPublish,
                    'remaining' => max(0, $limit - $used),
                ],
            ], 422);
        }

        $now = now();
        $invoice = null;

        DB::transaction(function () use ($companyId, $query, $subscription, $plan, $toPublish, $data, $now, &$invoice) {
            $ids = (clone $query)->pluck('id')->map(fn ($v) => (string) $v)->all();

            DB::table('base_codes')
                ->where('company_id', $companyId)
                ->where('code_type', 'carton')
                ->whereIn('id', $ids)
                ->whereNull('linked_at')
                ->update([
                    'linked_at' => $now,
                    'updated_at' => $now,
                ]);

            DB::table('base_codes')
                ->where('company_id', $companyId)
                ->where('code_type', 'carton')
                ->whereIn('id', $ids)
                ->update([
                    'status' => 'published',
                    'published_at' => $now,
                    'subscription_plan_id' => (string) $plan->id,
                    'product_batch_number' => $data['product_batch_number'] ?? DB::raw('product_batch_number'),
                    'manufacturing_date' => $data['manufacturing_date'] ?? DB::raw('manufacturing_date'),
                    'expiry_date' => $data['expiry_date'] ?? DB::raw('expiry_date'),
                    'warranty_months' => $data['warranty_months'] ?? DB::raw('warranty_months'),
                    'updated_at' => $now,
                ]);

            $subscription->current_carton_codes_used = (int) ($subscription->current_carton_codes_used ?? 0) + $toPublish;
            $subscription->save();

            $invoice = $this->createPublishInvoice(
                companyId: $companyId,
                subscription: $subscription,
                plan: $plan,
                codeType: 'carton',
                quantity: $toPublish,
                publishedAt: $now,
                context: [
                    'code_ids' => $ids,
                ],
            );

            $this->stampInvoiceIdOnCodes($companyId, 'carton', $ids, (string) $invoice->id, $now);
        });

        return response()->json([
            'success' => true,
            'data' => [
                'published_count' => $toPublish,
                'invoice' => $invoice ? [
                    'id' => (string) $invoice->id,
                    'invoice_number' => (string) $invoice->invoice_number,
                    'status' => (string) $invoice->status,
                    'total_amount' => (float) $invoice->total_amount,
                    'currency' => (string) ($invoice->currency ?? 'USD'),
                ] : null,
            ],
        ]);
    }

    public function download(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'format' => ['required', 'string'],
            'code_ids' => ['required', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'include_qr_codes' => ['nullable', 'boolean'],
            'include_barcodes' => ['nullable', 'boolean'],
            'include_international_codes' => ['nullable', 'boolean'],
        ]);

        try {
            $res = $this->exporter->exportCodesToFile(
                companyId: $companyId,
                codeType: 'carton',
                codeIds: $data['code_ids'],
                format: (string) $data['format'],
                options: $data,
            );

            return response()->json(['success' => true, 'data' => $res]);
        } catch (CodeExportLockedException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Download locked. Please pay the invoice first.',
                'data' => [
                    'invoice_id' => $e->invoiceId,
                    'invoice_number' => $e->invoiceNumber,
                    'amount' => $e->amount,
                    'currency' => $e->currency,
                    'status' => $e->status,
                ],
            ], 423);
        }
    }

    private function createPublishInvoice(
        string $companyId,
        CompanySubscription $subscription,
        SubscriptionPlan $plan,
        string $codeType,
        int $quantity,
        \DateTimeInterface $publishedAt,
        array $context = [],
    ): Invoice {
        $currency = (string) ($plan->currency ?? 'USD');
        $unitPrice = $this->calculatePublishUnitPrice($plan, $codeType);
        $subtotal = round($unitPrice * max(0, $quantity), 2);

        $issueDate = Carbon::parse($publishedAt)->toDateString();
        $dueDate = Carbon::parse($publishedAt)->copy()->addDays(7)->toDateString();
        $periodStart = Carbon::parse($publishedAt)->copy()->startOfMonth()->toDateString();
        $periodEnd = Carbon::parse($publishedAt)->copy()->endOfMonth()->toDateString();

        $invoiceNumber = $this->generateUniqueInvoiceNumber();

        $invoice = new Invoice([
            'company_id' => $companyId,
            'subscription_id' => (string) $subscription->id,
            'type' => 'platform',
            'invoice_number' => $invoiceNumber,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            'issue_date' => $issueDate,
            'due_date' => $dueDate,
            'subtotal' => $subtotal,
            'tax_amount' => 0,
            'discount_amount' => 0,
            'total_amount' => $subtotal,
            'currency' => $currency,
            'items' => [
                [
                    'id' => (string) Str::uuid(),
                    'description' => 'Carton codes publish',
                    'quantity' => (float) $quantity,
                    'unit_price' => $unitPrice,
                    'total' => $subtotal,
                    'currency' => $currency,
                    'code_type' => $codeType,
                    'code_count' => $quantity,
                    'period_start' => $periodStart,
                    'period_end' => $periodEnd,
                    'metadata' => [
                        'source' => 'publish_codes',
                    ],
                ],
            ],
            'status' => $subtotal > 0 ? 'pending' : 'paid',
            'payment_date' => $subtotal > 0 ? null : $issueDate,
            'payment_method' => $subtotal > 0 ? null : 'system',
            'payment_reference' => $subtotal > 0 ? null : 'FREE',
            'metadata' => array_merge([
                'source' => 'publish_codes',
                'code_type' => $codeType,
                'quantity' => $quantity,
                'unit_price' => $unitPrice,
                'published_at' => Carbon::parse($publishedAt)->toISOString(),
                'plan_id_at_publish' => (string) $plan->id,
                'plan_type_at_publish' => (string) ($plan->type ?? ''),
                'plan_monthly_price_at_publish' => (float) ($plan->monthly_price ?? 0),
            ], $context),
        ]);

        $invoice->id = (string) Str::uuid();
        $invoice->save();

        return $invoice;
    }

    private function calculatePublishUnitPrice(SubscriptionPlan $plan, string $codeType): float
    {
        $meta = $plan->metadata;
        if (is_array($meta) && isset($meta['publish_rates']) && is_array($meta['publish_rates'])) {
            $explicit = $meta['publish_rates'][$codeType] ?? null;
            if ($explicit !== null && is_numeric($explicit)) {
                return max(0.0, round((float) $explicit, 6));
            }
        }

        $price = (float) ($plan->monthly_price ?? 0);
        if ($price <= 0) {
            return 0.0;
        }

        $quota = (int) ($plan->monthly_carton_codes ?? 0);
        if ($quota <= 0) {
            $fallback = (int) ($plan->monthly_unit_codes ?? 0);
            if ($fallback <= 0) {
                return 0.0;
            }
            $quota = $fallback;
        }

        return max(0.0, round($price / $quota, 6));
    }

    private function generateUniqueInvoiceNumber(): string
    {
        $prefix = 'INV-' . now()->format('Ym') . '-';

        for ($i = 0; $i < 10; $i++) {
            $candidate = $prefix . strtoupper(Str::random(8));
            if (!Invoice::query()->where('invoice_number', $candidate)->exists()) {
                return $candidate;
            }
        }

        return $prefix . strtoupper((string) Str::uuid());
    }

    private function stampInvoiceIdOnCodes(string $companyId, string $codeType, array $ids, string $invoiceId, \DateTimeInterface $now): void
    {
        $driver = DB::getDriverName();
        $jsonExpr = null;
        if ($driver === 'pgsql') {
            $jsonExpr = DB::raw("jsonb_set(coalesce(metadata,'{}'::jsonb), '{publish_invoice_id}', '\"{$invoiceId}\"', true)");
        } else {
            $jsonExpr = DB::raw("JSON_SET(COALESCE(metadata, JSON_OBJECT()), '$.publish_invoice_id', '{$invoiceId}')");
        }

        DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', $codeType)
            ->whereIn('id', $ids)
            ->update([
                'metadata' => $jsonExpr,
                'updated_at' => $now,
            ]);
    }
}
