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

class BundleCodesController extends Controller
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
            'prefix' => ['nullable', 'string', 'max:10'],
            'include_international_codes' => ['nullable', 'boolean'],
        ]);

        $companyId = (string) $user->company_id;
        $subscription = CompanySubscription::query()->where('company_id', $companyId)->where('status', 'active')->first();
        if (!$subscription) {
            return response()->json(['message' => 'No active subscription'], 422);
        }

        $planId = (string) $subscription->plan_id;
        $count = (int) $data['count'];
        $includeInternational = (bool) ($data['include_international_codes'] ?? true);

        DB::transaction(function () use ($companyId, $planId, $count, $data, $includeInternational) {
            $baseOverrides = [];
            if (!empty($data['batch_id'])) {
                $baseOverrides['batch_id'] = (string) $data['batch_id'];
            }
            if (!empty($data['prefix'])) {
                $baseOverrides['store_keeper_prefix'] = (string) $data['prefix'];
            }

            $baseRows = $this->generator->generateBase($companyId, $planId, 'bundle', $count, $baseOverrides);

            if ($includeInternational) {
                $updates = [];
                foreach ($baseRows as $r) {
                    $updates[] = [
                        'id' => (string) $r['id'],
                        'international_code' => 'INT-BUNDLE-' . strtoupper((string) Str::ulid()),
                        'updated_at' => now(),
                    ];
                }
                DB::table('base_codes')->upsert($updates, ['id'], ['international_code', 'updated_at']);
            }

            $rows = [];
            for ($i = 0; $i < $count; $i++) {
                $id = $baseRows[$i]['id'];
                $rows[] = [
                    'id' => $id,
                    'cartons_per_bundle' => 0,
                    'bundle_weight_kg' => null,
                    'bundle_dimensions' => null,
                    'storage_location' => null,
                    'shipping_method' => null,
                    'expected_delivery_date' => null,
                    'category' => null,
                    'handling_instructions' => null,
                    'customs_declaration_number' => null,
                    'insurance_value' => null,
                    'priority' => 2,
                ];
            }

            DB::table('bundle_codes')->insert($rows);
        });

        return response()->json(['success' => true, 'data' => ['generated_count' => $count]]);
    }

    public function list(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $query = DB::table('bundle_codes')
            ->join('base_codes', 'bundle_codes.id', '=', 'base_codes.id')
            ->select([
                'bundle_codes.*',
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
            ])
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'bundle')
            ->where('base_codes.is_deleted', false);

        $page = (int) $request->query('page', 1);
        $limit = (int) $request->query('limit', 50);
        $limit = max(1, min(200, $limit));

        $paginator = $query->orderByDesc('base_codes.generated_at')->paginate($limit, ['*'], 'page', $page);

        $dt = static fn ($v) => $v ? Carbon::parse($v)->toISOString() : null;

        $items = collect($paginator->items())->map(function ($row) use ($dt) {
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
                'cartonCount' => (int) ($row->cartons_per_bundle ?? 0),
                'cartonCodes' => [],
                'weight' => $row->bundle_weight_kg,
                'dimensions' => $row->bundle_dimensions,
                'storageLocation' => $row->storage_location,
                'shippingMethod' => $row->shipping_method,
                'expectedDeliveryDate' => $dt($row->expected_delivery_date),
                'actualDeliveryDate' => null,
                'sequenceNumber' => 1,
                'totalUnits' => 0,
                'category' => $row->category,
                'handlingInstructions' => $row->handling_instructions,
                'customsDeclarationNumber' => $row->customs_declaration_number,
                'insuranceValue' => $row->insurance_value,
                'priority' => (int) ($row->priority ?? 2),
            ];
        })->all();

        return response()->json([
            'success' => true,
            'data' => [
                'bundle_codes' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function update(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'batch_id' => ['nullable', 'string', 'max:100'],
            'cartons_per_bundle' => ['nullable', 'integer', 'min:0', 'max:10000'],
            'bundle_weight_kg' => ['nullable', 'numeric', 'min:0', 'max:1000000'],
            'bundle_dimensions' => ['nullable', 'string', 'max:255'],
            'storage_location' => ['nullable', 'string', 'max:255'],
            'shipping_method' => ['nullable', 'string', 'max:255'],
            'expected_delivery_date' => ['nullable', 'date'],
            'category' => ['nullable', 'string', 'max:100'],
            'handling_instructions' => ['nullable', 'string', 'max:1000'],
            'customs_declaration_number' => ['nullable', 'string', 'max:100'],
            'insurance_value' => ['nullable', 'numeric', 'min:0', 'max:100000000'],
            'priority' => ['nullable', 'integer', 'min:1', 'max:3'],
        ]);

        $now = now();

        $baseUpdated = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'bundle')
            ->where('id', $id)
            ->whereNull('published_at')
            ->where('is_deleted', false)
            ->update([
                'batch_id' => array_key_exists('batch_id', $data) ? ($data['batch_id'] ?? null) : DB::raw('batch_id'),
                'updated_at' => $now,
            ]);

        $bundleUpdated = DB::table('bundle_codes')
            ->where('id', $id)
            ->update([
                'cartons_per_bundle' => array_key_exists('cartons_per_bundle', $data) ? ((int) ($data['cartons_per_bundle'] ?? 0)) : DB::raw('cartons_per_bundle'),
                'bundle_weight_kg' => array_key_exists('bundle_weight_kg', $data) ? ($data['bundle_weight_kg'] ?? null) : DB::raw('bundle_weight_kg'),
                'bundle_dimensions' => array_key_exists('bundle_dimensions', $data) ? ($data['bundle_dimensions'] ?? null) : DB::raw('bundle_dimensions'),
                'storage_location' => array_key_exists('storage_location', $data) ? ($data['storage_location'] ?? null) : DB::raw('storage_location'),
                'shipping_method' => array_key_exists('shipping_method', $data) ? ($data['shipping_method'] ?? null) : DB::raw('shipping_method'),
                'expected_delivery_date' => array_key_exists('expected_delivery_date', $data) ? ($data['expected_delivery_date'] ?? null) : DB::raw('expected_delivery_date'),
                'category' => array_key_exists('category', $data) ? ($data['category'] ?? null) : DB::raw('category'),
                'handling_instructions' => array_key_exists('handling_instructions', $data) ? ($data['handling_instructions'] ?? null) : DB::raw('handling_instructions'),
                'customs_declaration_number' => array_key_exists('customs_declaration_number', $data) ? ($data['customs_declaration_number'] ?? null) : DB::raw('customs_declaration_number'),
                'insurance_value' => array_key_exists('insurance_value', $data) ? ($data['insurance_value'] ?? null) : DB::raw('insurance_value'),
                'priority' => array_key_exists('priority', $data) ? ((int) ($data['priority'] ?? 2)) : DB::raw('priority'),
            ]);

        return response()->json([
            'success' => true,
            'data' => [
                'updated' => (int) ($baseUpdated > 0 ? 1 : 0),
                'bundle_updated' => (int) ($bundleUpdated > 0 ? 1 : 0),
            ],
        ]);
    }

    public function delete(Request $request, string $id)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $now = now();

        $updated = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'bundle')
            ->where('id', $id)
            ->whereNull('published_at')
            ->where('is_deleted', false)
            ->update([
                'is_deleted' => true,
                'status' => 'deleted',
                'updated_at' => $now,
            ]);

        return response()->json([
            'success' => true,
            'data' => [
                'deleted' => (int) $updated,
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
            ->where('code_type', 'bundle')
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
            'code_ids' => ['nullable', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'product_batch_number' => ['nullable', 'string', 'max:100'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
        ]);

        if (empty($data['code_ids']) && empty($data['batch_id'])) {
            return response()->json(['message' => 'code_ids or batch_id is required'], 422);
        }

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
            ->where('code_type', 'bundle')
            ->whereNull('published_at')
            ->whereIn('status', ['generated', 'linked']);
        if (!empty($data['batch_id'])) {
            $query->where('batch_id', (string) $data['batch_id']);
        } else {
            $query->whereIn('id', $data['code_ids']);
        }

        $toPublish = (int) $query->count('id');
        if ($toPublish <= 0) {
            return response()->json([
                'success' => true,
                'data' => [
                    'published_count' => 0,
                ],
            ]);
        }

        $limit = (int) ($plan->monthly_bundle_codes ?? 0);
        $used = (int) ($subscription->current_bundle_codes_used ?? 0);
        if ($limit > 0 && ($used + $toPublish) > $limit) {
            return response()->json([
                'message' => 'Bundle code publish exceeds subscription limit',
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

            $linkQuery = DB::table('base_codes')
                ->where('company_id', $companyId)
                ->where('code_type', 'bundle')
                ->whereIn('id', $ids)
                ->whereNull('linked_at');

            $linkQuery->update([
                'linked_at' => $now,
                'updated_at' => $now,
            ]);

            DB::table('base_codes')
                ->where('company_id', $companyId)
                ->where('code_type', 'bundle')
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

            $subscription->current_bundle_codes_used = (int) ($subscription->current_bundle_codes_used ?? 0) + $toPublish;
            $subscription->save();

            $invoice = $this->createPublishInvoice(
                companyId: $companyId,
                subscription: $subscription,
                plan: $plan,
                codeType: 'bundle',
                quantity: $toPublish,
                publishedAt: $now,
                context: [
                    'code_ids' => $ids,
                    'batch_id' => $data['batch_id'] ?? null,
                ],
            );

            $this->stampInvoiceIdOnCodes($companyId, 'bundle', $ids, (string) $invoice->id, $now);
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
                codeType: 'bundle',
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

        $invoiceData = [
            'company_id' => $companyId,
            'subscription_id' => (string) $subscription->id,
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
                    'description' => 'Bundle codes publish',
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
        ];

        if (\Illuminate\Support\Facades\Schema::hasColumn('invoices', 'type')) {
            $invoiceData['type'] = 'platform';
        }

        $invoice = new Invoice($invoiceData);

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

        $quota = (int) ($plan->monthly_bundle_codes ?? 0);
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
