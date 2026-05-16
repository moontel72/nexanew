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
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;

class UnitCodesController extends Controller
{
    private const CODE_FORMATS = ['itf14', 'gs1_128', 'code128_industrial', 'qr', 'datamatrix', 'code128_label', 'auth_code'];

    public function __construct(private CodeGenerator $generator, private CodeExportService $exporter)
    {
    }

    // ─── Generate ──────────────────────────────────────────────────

    public function generate(Request $request)
    {
        $user = $request->user();

        if (!Schema::hasColumn('unit_codes', 'code_format')) {
            return response()->json([
                'success' => false,
                'message' => "Database schema out of date: unit_codes.code_format is missing. Run migrations.",
            ], 500);
        }

        $data = $request->validate([
            'count' => ['required', 'integer', 'min:1', 'max:5000'],
            'code_format' => ['required', 'string', 'in:' . implode(',', self::CODE_FORMATS)],
            'product_id' => ['required', 'uuid'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'prefix' => ['nullable', 'string', 'max:10'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
        ]);

        Log::info('UNIT_GENERATE_REQUEST', ['code_format' => $data['code_format'] ?? 'MISSING', 'count' => $data['count'] ?? 0]);

        $companyId = (string) $user->company_id;

        // Verify product belongs to this company
        $product = Product::query()
            ->where('id', $data['product_id'])
            ->where('company_id', $companyId)
            ->first();
        if (!$product) {
            return response()->json(['message' => 'Product not found'], 422);
        }

        $subscription = CompanySubscription::query()
            ->where('company_id', $companyId)
            ->where('status', 'active')
            ->first();
        if (!$subscription) {
            return response()->json(['message' => 'No active subscription'], 422);
        }

        $planId = (string) $subscription->plan_id;
        $count = (int) $data['count'];

        $nextSeq = (int) (DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->max('unit_codes.sequence_number') ?? 0) + 1;

        $created = DB::transaction(function () use ($companyId, $planId, $count, $nextSeq, $data, $product) {
            $baseOverrides = ['batch_id' => $data['batch_id'] ?? null];
            if (!empty($data['prefix'])) {
                $baseOverrides['store_keeper_prefix'] = (string) $data['prefix'];
            }

            $baseRows = $this->generator->generateBase($companyId, $planId, 'unit', $count, $baseOverrides);

            // Link to product and set metadata
            $now = now();
            foreach ($baseRows as $r) {
                DB::table('base_codes')
                    ->where('id', (string) $r['id'])
                    ->update([
                        'product_id' => $product->id,
                        'product_batch_number' => $data['batch_id'] ?? null,
                        'manufacturing_date' => $data['manufacturing_date'] ?? null,
                        'expiry_date' => $data['expiry_date'] ?? null,
                        'warranty_months' => $data['warranty_months'] ?? null,
                        'status' => 'linked',
                        'linked_at' => $now,
                        'updated_at' => $now,
                    ]);
            }

            $codeFormat = (string) $data['code_format'];

            Log::info('UNIT_GENERATE_INSERT', ['code_format' => $codeFormat, 'count' => $count]);

            $unitRows = [];
            for ($i = 0; $i < $count; $i++) {
                $id = $baseRows[$i]['id'];
                $seq = $nextSeq + $i;
                $auth = 'AUTH-' . strtoupper(Str::random(12));
                $serial = 'SN-' . strtoupper(Str::random(10));

                $unitRows[] = [
                    'id' => $id,
                    'code_format' => $codeFormat,
                    'packet_code_id' => null,
                    'sequence_number' => $seq,
                    'authentication_code' => $auth,
                    'is_master_code' => false,
                    'master_code_id' => null,
                    'verification_count' => 0,
                    'first_verified_at' => null,
                    'last_verified_at' => null,
                    'verification_location' => null,
                    'verified_by' => null,
                    'is_reported_fake' => false,
                    'fake_reported_at' => null,
                    'fake_reported_by' => null,
                    'fake_report_reason' => null,
                    'is_blocked' => false,
                    'blocked_at' => null,
                    'blocked_by' => null,
                    'block_reason' => null,
                    'serial_number' => $serial,
                    'model' => $product->name ?? null,
                ];
            }

            DB::table('unit_codes')->insert($unitRows);

            return $unitRows;
        });

        return response()->json([
            'success' => true,
            'data' => [
                'generated_count' => count($created),
                'batch_id' => $data['batch_id'] ?? null,
                'code_format' => $data['code_format'],
                'product_id' => $data['product_id'],
                'product_name' => $product->name,
                '_debug_format' => $data['code_format'] ?? 'NOT_RECEIVED',
            ],
        ]);
    }

    public function generateForFormat(Request $request, string $format)
    {
        $request->merge(['code_format' => $format]);
        return $this->generate($request);
    }

    // ─── List ──────────────────────────────────────────────────────

    public function list(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        if (!Schema::hasColumn('unit_codes', 'code_format')) {
            return response()->json([
                'success' => false,
                'message' => "Database schema out of date: unit_codes.code_format is missing. Run migrations.",
            ], 500);
        }

        $query = DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->leftJoin('packet_codes', 'unit_codes.packet_code_id', '=', 'packet_codes.id')
            ->leftJoin('bundle_items', 'packet_codes.id', '=', 'bundle_items.packet_code_id')
            ->leftJoin('bundles', 'bundle_items.bundle_id', '=', 'bundles.id')
            ->select([
                'unit_codes.*',
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
                'bundles.order_reference as linked_order_reference',
                'bundles.bundle_code as linked_bundle_code',
            ])
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'unit')
            ->where('base_codes.is_deleted', false);

        $codeFormat = $request->input('code_format');
        if (!empty($codeFormat) && in_array((string) $codeFormat, self::CODE_FORMATS, true)) {
            $query->where('unit_codes.code_format', (string) $codeFormat);
        }

        if ($productId = $request->query('product_id')) {
            $query->where('base_codes.product_id', $productId);
        }

        $page = (int) $request->query('page', 1);
        $limit = max(1, min(200, (int) $request->query('limit', 50)));

        $paginator = $query->orderByDesc('base_codes.generated_at')->paginate($limit, ['*'], 'page', $page);

        $dt = static fn ($v) => $v ? Carbon::parse($v)->toISOString() : null;

        $items = collect($paginator->items())->map(function ($row) use ($dt) {
            return [
                'id' => (string) $row->id,
                'code' => (string) $row->code,
                'type' => (string) $row->code_type,
                'codeFormat' => (string) ($row->code_format ?? 'qr'),
                'status' => (string) $row->status,
                'factoryId' => (string) $row->company_id,
                'subscriptionPlanId' => (string) $row->subscription_plan_id,
                'storeKeeperCode' => (string) $row->store_keeper_code,
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
                'sequenceNumber' => (int) ($row->sequence_number ?? 0),
                'authenticationCode' => (string) ($row->authentication_code ?? ''),
                'serialNumber' => (string) ($row->serial_number ?? ''),
                'isMasterCode' => (bool) ($row->is_master_code ?? false),
                'verificationCount' => (int) ($row->verification_count ?? 0),
                'isReportedFake' => (bool) ($row->is_reported_fake ?? false),
                'isBlocked' => (bool) ($row->is_blocked ?? false),
                'model' => $row->model,
                'linkedOrderReference' => (string) ($row->linked_order_reference ?? ''),
                'linkedBundleCode' => (string) ($row->linked_bundle_code ?? ''),
                'createdAt' => $dt($row->created_at),
                'updatedAt' => $dt($row->updated_at),
            ];
        })->all();

        return response()->json([
            'success' => true,
            'data' => [
                'unit_codes' => $items,
                'total' => $paginator->total(),
                'page' => $paginator->currentPage(),
                'limit' => $paginator->perPage(),
                'total_pages' => $paginator->lastPage(),
            ],
        ]);
    }

    public function listForFormat(Request $request, string $format)
    {
        $request->merge(['code_format' => $format]);
        return $this->list($request);
    }

    // ─── Batches ───────────────────────────────────────────────────

    public function listBatches(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        if (!Schema::hasColumn('unit_codes', 'code_format')) {
            return response()->json([
                'success' => false,
                'message' => "Database schema out of date: unit_codes.code_format is missing. Run migrations.",
            ], 500);
        }

        $data = $request->validate([
            'code_format' => ['nullable', 'string', 'in:' . implode(',', self::CODE_FORMATS)],
            'page' => ['nullable', 'integer', 'min:1'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:200'],
        ]);

        $page = (int) ($data['page'] ?? $request->query('page', 1));
        $limit = max(1, min(200, (int) ($data['limit'] ?? $request->query('limit', 50))));
        $offset = ($page - 1) * $limit;

        $driver = DB::getDriverName();
        $isPushedExpr = $driver === 'pgsql'
            ? DB::raw('bool_or(base_codes.published_at is not null) as is_pushed')
            : DB::raw('MAX(CASE WHEN base_codes.published_at IS NOT NULL THEN 1 ELSE 0 END) as is_pushed');

        $baseGroup = DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'unit')
            ->where('base_codes.is_deleted', false)
            ->when(
                !empty($data['code_format'] ?? null),
                fn($q) => $q->where('unit_codes.code_format', (string) $data['code_format']),
            )
            ->groupBy('base_codes.batch_id', 'unit_codes.code_format', 'base_codes.product_id')
            ->select([
                'base_codes.batch_id',
                'unit_codes.code_format',
                'base_codes.product_id',
                DB::raw('COUNT(base_codes.id) as code_count'),
                DB::raw('MAX(base_codes.generated_at) as generated_at'),
                $isPushedExpr,
            ]);

        $totalQuery = DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'unit')
            ->where('base_codes.is_deleted', false)
            ->when(
                !empty($data['code_format'] ?? null),
                fn($q) => $q->where('unit_codes.code_format', (string) $data['code_format']),
            );

        $total = DB::query()->fromSub(
            (clone $totalQuery)->groupBy('base_codes.batch_id', 'unit_codes.code_format', 'base_codes.product_id')
                ->select(['base_codes.batch_id', 'unit_codes.code_format', 'base_codes.product_id']),
            't',
        )->count();

        $rows = (clone $baseGroup)
            ->orderByDesc(DB::raw('MAX(base_codes.generated_at)'))
            ->offset($offset)
            ->limit($limit)
            ->get();

        $dt = static fn($v) => $v ? Carbon::parse($v)->toISOString() : null;

        // Preload product names
        $productIds = $rows->pluck('product_id')->unique()->filter()->values();
        $productNames = DB::table('products')->whereIn('id', $productIds)->pluck('name', 'id');

        $items = $rows->map(function ($row) use ($dt, $productNames) {
            $isPushed = (bool) ($row->is_pushed ?? false);
            return [
                'batchId' => (string) ($row->batch_id ?? ''),
                'codeFormat' => (string) ($row->code_format ?? 'qr'),
                'productId' => $row->product_id,
                'productName' => $productNames[$row->product_id] ?? '',
                'codeCount' => (int) ($row->code_count ?? 0),
                'generatedAt' => $dt($row->generated_at),
                'status' => $isPushed ? 'pushed' : 'draft',
                'isPushed' => $isPushed,
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'batches' => $items,
                'total' => (int) $total,
                'page' => $page,
                'limit' => $limit,
                'total_pages' => (int) ceil(max(1, $total) / $limit),
            ],
        ]);
    }

    // ─── Download ──────────────────────────────────────────────────

    public function download(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'format' => ['required', 'string'],
            'code_ids' => ['nullable', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'code_format' => ['nullable', 'string', 'in:' . implode(',', self::CODE_FORMATS)],
            'include_qr_codes' => ['nullable', 'boolean'],
            'include_barcodes' => ['nullable', 'boolean'],
            'include_international_codes' => ['nullable', 'boolean'],
        ]);

        if (empty($data['code_ids']) && empty($data['batch_id'])) {
            return response()->json(['message' => 'code_ids or batch_id is required'], 422);
        }

        $codeIds = $data['code_ids'] ?? [];
        if (empty($codeIds) && !empty($data['batch_id'])) {
            $codeIds = DB::table('unit_codes')
                ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
                ->where('base_codes.company_id', $companyId)
                ->where('base_codes.code_type', 'unit')
                ->where('base_codes.is_deleted', false)
                ->whereNotNull('base_codes.published_at')
                ->where('base_codes.batch_id', (string) $data['batch_id'])
                ->when(!empty($data['code_format'] ?? null), fn($q) => $q->where('unit_codes.code_format', (string) $data['code_format']))
                ->limit(5000)
                ->pluck('base_codes.id')
                ->map(fn($v) => (string) $v)
                ->all();
        }

        if (empty($codeIds)) {
            return response()->json(['message' => 'No codes found for download'], 422);
        }

        try {
            $res = $this->exporter->exportCodesToFile(
                companyId: $companyId,
                codeType: 'unit',
                codeIds: $codeIds,
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

    // ─── Publish ──────────────────────────────────────────────────

    public function publish(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'code_ids' => ['nullable', 'array', 'min:1', 'max:5000'],
            'code_ids.*' => ['uuid'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'code_format' => ['nullable', 'string', 'in:' . implode(',', self::CODE_FORMATS)],
            'count' => ['nullable', 'integer', 'min:1'],
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
            ->where('code_type', 'unit')
            ->whereNull('published_at')
            ->whereIn('status', ['generated', 'linked']);
        if (!empty($data['batch_id'])) {
            $query->where('batch_id', (string) $data['batch_id']);
            if (!empty($data['code_format'] ?? null)) {
                $query->join('unit_codes', 'unit_codes.id', '=', 'base_codes.id')
                    ->where('unit_codes.code_format', (string) $data['code_format']);
            }
        } else {
            $query->whereIn('id', $data['code_ids']);
        }

        $toPublish = (int) $query->count('base_codes.id');
        if ($toPublish <= 0) {
            return response()->json([
                'success' => true,
                'data' => [
                    'published_count' => 0,
                ],
            ]);
        }

        $limit = (int) ($plan->monthly_unit_codes ?? 0);
        $used = (int) ($subscription->current_unit_codes_used ?? 0);
        if ($limit > 0 && ($used + $toPublish) > $limit) {
            return response()->json([
                'message' => 'Unit code publish exceeds subscription limit',
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
            $ids = (clone $query)->pluck('base_codes.id')->map(fn ($v) => (string) $v)->all();

            DB::table('base_codes')
                ->where('company_id', $companyId)
                ->where('code_type', 'unit')
                ->whereIn('id', $ids)
                ->whereNull('linked_at')
                ->update([
                    'linked_at' => $now,
                    'updated_at' => $now,
                ]);

            DB::table('base_codes')
                ->where('company_id', $companyId)
                ->where('code_type', 'unit')
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

            $subscription->current_unit_codes_used = (int) ($subscription->current_unit_codes_used ?? 0) + $toPublish;
            $subscription->save();

            $invoice = $this->createPublishInvoice(
                companyId: $companyId,
                subscription: $subscription,
                plan: $plan,
                codeType: 'unit',
                quantity: $toPublish,
                publishedAt: $now,
                context: [
                    'code_ids' => $ids,
                    'batch_id' => $data['batch_id'] ?? null,
                ],
            );

            $this->stampInvoiceIdOnCodes($companyId, 'unit', $ids, (string) $invoice->id, $now);
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

    // ─── Batch Delete ─────────────────────────────────────────────

    public function deleteBatch(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $data = $request->validate([
            'batch_id' => ['required', 'string', 'max:100'],
            'code_format' => ['nullable', 'string', 'in:' . implode(',', self::CODE_FORMATS)],
        ]);

        $ids = DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'unit')
            ->where('base_codes.is_deleted', false)
            ->whereNull('base_codes.published_at')
            ->where('base_codes.batch_id', (string) $data['batch_id'])
            ->when(
                !empty($data['code_format'] ?? null),
                fn ($q) => $q->where('unit_codes.code_format', (string) $data['code_format']),
            )
            ->pluck('base_codes.id')
            ->map(fn ($v) => (string) $v)
            ->all();

        if (empty($ids)) {
            return response()->json([
                'success' => true,
                'data' => [
                    'deleted' => 0,
                ],
            ]);
        }

        $now = now();
        $updated = DB::table('base_codes')
            ->where('company_id', $companyId)
            ->where('code_type', 'unit')
            ->whereIn('id', $ids)
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

    // ─── Private Helpers ──────────────────────────────────────────

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
                    'description' => 'Unit codes publish',
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

        if (Schema::hasColumn('invoices', 'type')) {
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

        $quota = (int) ($plan->monthly_unit_codes ?? 0);
        if ($quota <= 0) {
            return 0.0;
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
            $jsonExpr = DB::raw("coalesce(metadata,'{}'::jsonb) || '{\"publish_invoice_id\": \"{$invoiceId}\"}'::jsonb");
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
