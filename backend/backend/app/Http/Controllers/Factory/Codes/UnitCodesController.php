<?php

namespace App\Http\Controllers\Factory\Codes;

use App\Http\Controllers\Controller;
use App\Models\CompanySubscription;
use App\Services\Codes\CodeExportLockedException;
use App\Services\Codes\CodeGenerator;
use App\Services\Codes\CodeExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;

class UnitCodesController extends Controller
{
    public function __construct(private CodeGenerator $generator, private CodeExportService $exporter)
    {
    }

    public function generate(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'count' => ['required', 'integer', 'min:1', 'max:5000'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'packet_code_id' => ['nullable', 'uuid'],
            'packet_code' => ['nullable', 'string', 'max:255'],
        ]);

        $companyId = (string) $user->company_id;
        $subscription = CompanySubscription::query()->where('company_id', $companyId)->where('status', 'active')->first();
        if (!$subscription) {
            return response()->json(['message' => 'No active subscription'], 422);
        }

        $planId = (string) $subscription->plan_id;
        $count = (int) $data['count'];

        $nextSeq = (int) (DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->where('base_codes.company_id', $companyId)
            ->max('unit_codes.sequence_number') ?? 0) + 1;

        $packetCodeId = $data['packet_code_id'] ?? null;
        if (!$packetCodeId && !empty($data['packet_code'])) {
            $packetCodeId = DB::table('packet_codes')
                ->join('base_codes', 'packet_codes.id', '=', 'base_codes.id')
                ->where('base_codes.company_id', $companyId)
                ->where('base_codes.code_type', 'packet')
                ->where('base_codes.code', (string) $data['packet_code'])
                ->value('packet_codes.id');
        }

        $created = DB::transaction(function () use ($companyId, $planId, $count, $nextSeq, $packetCodeId, $data) {
            $baseRows = $this->generator->generateBase($companyId, $planId, 'unit', $count, [
                'batch_id' => $data['batch_id'] ?? null,
            ]);

            $unitRows = [];
            for ($i = 0; $i < $count; $i++) {
                $id = $baseRows[$i]['id'];
                $seq = $nextSeq + $i;
                $auth = 'AUTH-' . strtoupper(Str::random(12));
                $serial = 'SN-' . strtoupper(Str::random(10));

                $unitRows[] = [
                    'id' => $id,
                    'packet_code_id' => $packetCodeId,
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
                    'model' => null,
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
            ],
        ]);
    }

    public function list(Request $request)
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        $query = DB::table('unit_codes')
            ->join('base_codes', 'unit_codes.id', '=', 'base_codes.id')
            ->leftJoin('base_codes as packet_base', 'unit_codes.packet_code_id', '=', 'packet_base.id')
            ->select([
                'unit_codes.id',
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
                'unit_codes.packet_code_id',
                'packet_base.code as packet_code_value',
                'unit_codes.sequence_number',
                'unit_codes.authentication_code',
                'unit_codes.serial_number',
                'unit_codes.is_master_code',
                'unit_codes.verification_count',
                'unit_codes.is_reported_fake',
                'unit_codes.is_blocked',
                'base_codes.created_at',
                'base_codes.updated_at',
            ])
            ->where('base_codes.company_id', $companyId)
            ->where('base_codes.code_type', 'unit');

        if ($status = $request->query('status')) {
            $query->where('base_codes.status', $status);
        }

        if ($search = $request->query('search')) {
            $search = (string) $search;
            $query->where('base_codes.code', 'ilike', "%{$search}%");
        }

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
                'internationalCode' => $row->international_code,
                'batchId' => (string) $row->batch_id,
                'generatedAt' => $dt($row->generated_at),
                'linkedAt' => $dt($row->linked_at),
                'publishedAt' => $dt($row->published_at),
                'deactivatedAt' => $dt($row->deactivated_at),
                'productId' => $row->product_id,
                'productBatchNumber' => $row->product_batch_number,
                'packetCodeId' => $row->packet_code_id,
                'packetCode' => (string) ($row->packet_code_value ?? ''),
                'sequenceNumber' => (int) $row->sequence_number,
                'authenticationCode' => (string) $row->authentication_code,
                'serialNumber' => (string) $row->serial_number,
                'isMasterCode' => (bool) $row->is_master_code,
                'verificationCount' => (int) $row->verification_count,
                'isReportedFake' => (bool) $row->is_reported_fake,
                'isBlocked' => (bool) $row->is_blocked,
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
                codeType: 'unit',
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
}
