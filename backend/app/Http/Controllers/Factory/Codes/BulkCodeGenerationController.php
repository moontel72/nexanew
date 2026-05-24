<?php

namespace App\Http\Controllers\Factory\Codes;

use App\Http\Controllers\Controller;
use App\Jobs\BulkCodeGenerationJob;
use App\Models\CompanySubscription;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

/**
 * NEXATRACE — BULK CODE GENERATION CONTROLLER
 * ============================================
 *
 * SAFETY RULES:
 *  - This is an ENTIRELY NEW controller. It does NOT extend, override,
 *    or touch any existing code generation controller.
 *  - It lives alongside BundleCodesController, CartonCodesController,
 *    PacketCodesController, and UnitCodesController — all of which
 *    continue to operate synchronously without modification.
 *  - Used for large-volume generation (>5,000 codes) where async
 *    processing is warranted.
 *  - Small-volume requests (<5,000) should continue using the
 *    existing synchronous controllers.
 *
 * ENDPOINTS:
 *   POST /api/v1/factory/codes/bulk       → Dispatch a bulk job
 *   GET  /api/v1/factory/codes/bulk/{id}  → Check progress
 */

class BulkCodeGenerationController extends Controller
{
    private const ALLOWED_CODE_TYPES = ['bundle', 'carton', 'packet', 'unit', 'hierarchical'];
    private const MIN_BULK_COUNT = 100;
    private const MAX_BULK_COUNT = 1_000_000;

    /**
     * Dispatch a bulk code generation job.
     *
     * Request body:
     * {
     *   "code_type": "unit",          // required: bundle, carton, packet, unit, hierarchical
     *   "count": 50000,               // required: 100 – 1,000,000
     *   "prefix": "NT",               // optional: code prefix
     *   "batch_id": "BATCH-2026-001", // optional: custom batch identifier
     *   "product_id": "uuid",         // required for 'unit' type
     *   "manufacturing_date": "2026-01-15", // optional
     *   "expiry_date": "2026-12-15",        // optional
     *   "warranty_months": 24,              // optional
     *   "chunk_size": 1000                  // optional: override chunk size (100–5000)
     * }
     */
    public function dispatch(Request $request): JsonResponse
    {
        $user = $request->user();
        $companyId = (string) $user->company_id;

        // ─── Validate input ────────────────────────────
        $data = $request->validate([
            'code_type' => ['required', 'string', 'in:' . implode(',', self::ALLOWED_CODE_TYPES)],
            'count' => ['required', 'integer', 'min:' . self::MIN_BULK_COUNT, 'max:' . self::MAX_BULK_COUNT],
            'prefix' => ['nullable', 'string', 'max:10'],
            'batch_id' => ['nullable', 'string', 'max:100'],
            'product_id' => ['nullable', 'uuid'],
            'manufacturing_date' => ['nullable', 'date'],
            'expiry_date' => ['nullable', 'date'],
            'warranty_months' => ['nullable', 'integer', 'min:0', 'max:240'],
            'chunk_size' => ['nullable', 'integer', 'min:100', 'max:5000'],
            'metadata' => ['nullable', 'array'],
        ]);

        $codeType = (string) $data['code_type'];
        $count = (int) $data['count'];

        // ─── Unit codes require product_id ──────────────
        if ($codeType === 'unit' && empty($data['product_id'])) {
            return response()->json([
                'success' => false,
                'message' => 'product_id is required for unit code generation.',
            ], 422);
        }

        // ─── Check subscription ─────────────────────────
        $subscription = CompanySubscription::query()
            ->where('company_id', $companyId)
            ->where('status', 'active')
            ->first();

        if (! $subscription) {
            return response()->json([
                'success' => false,
                'message' => 'No active subscription found. Please activate a plan first.',
            ], 402);
        }

        $planId = (string) $subscription->plan_id;

        // ─── Build options ──────────────────────────────
        $options = array_filter([
            'prefix' => $data['prefix'] ?? null,
            'batch_id' => $data['batch_id'] ?? null,
            'product_id' => $data['product_id'] ?? null,
            'manufacturing_date' => $data['manufacturing_date'] ?? null,
            'expiry_date' => $data['expiry_date'] ?? null,
            'warranty_months' => $data['warranty_months'] ?? null,
            'chunk_size' => $data['chunk_size'] ?? null,
            'metadata' => $data['metadata'] ?? null,
        ], fn($v) => $v !== null);

        // ─── Dispatch job ───────────────────────────────
        $job = new BulkCodeGenerationJob($companyId, $planId, $codeType, $count, $options);

        dispatch($job);

        $jobId = $job->getJobId();

        Log::info('BulkCodeGenerationController: job dispatched', [
            'job_id' => $jobId,
            'company_id' => $companyId,
            'code_type' => $codeType,
            'count' => $count,
        ]);

        return response()->json([
            'success' => true,
            'message' => "Bulk generation of {$count} {$codeType} codes has been queued.",
            'data' => [
                'job_id' => $jobId,
                'code_type' => $codeType,
                'count' => $count,
                'status' => 'queued',
                'progress_url' => "/api/v1/factory/codes/bulk/{$jobId}",
            ],
        ], 202); // 202 Accepted — processing will happen asynchronously
    }

    /**
     * Check the progress of a bulk code generation job.
     *
     * GET /api/v1/factory/codes/bulk/{jobId}
     */
    public function progress(string $jobId): JsonResponse
    {
        $cacheKey = "bulk_gen:progress:{$jobId}";

        $progress = Cache::get($cacheKey);

        if ($progress === null) {
            return response()->json([
                'success' => false,
                'message' => 'Job not found or progress has expired. Jobs older than 1 hour are cleared.',
            ], 404);
        }

        $status = $progress['status'] ?? 'unknown';

        $httpCode = match ($status) {
            'completed', 'completed_with_errors' => 200,
            'failed' => 500,
            default => 202, // Still processing
        };

        return response()->json([
            'success' => $status !== 'failed',
            'data' => $progress,
        ], $httpCode);
    }
}
