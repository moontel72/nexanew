<?php

namespace App\Http\Controllers;

use App\Jobs\OfflineSyncProcessingJob;
use App\Models\Sync\OfflineSyncPayload;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * NEXATRACE — OFFLINE SYNC CONTROLLER
 * =====================================
 *
 * REST API for mobile clients to submit offline sync payloads
 * and check sync status.
 *
 * TARGET MODULES: 4Z, 5B, 5K
 *
 * SAFETY: Entirely new controller. Zero modification to existing code.
 */

class OfflineSyncController extends Controller
{
    /**
     * POST /api/v1/sync/submit
     *
     * Submit a batch of offline actions from mobile client.
     *
     * Request body:
     * {
     *   "app_module": "store_keeper",
     *   "device_id": "ABC123",
     *   "payloads": [
     *     {
     *       "client_uuid": "uuid-1",
     *       "payload_type": "scan_code",
     *       "client_timestamp": "2026-05-21T10:30:00Z",
     *       "payload_data": {"code": "AX34567", "code_type": "unit"}
     *     }
     *   ]
     * }
     */
    public function submit(Request $request): JsonResponse
    {
        $user = $request->user();
        $userId = (string) $user->id;

        $data = $request->validate([
            'app_module' => ['required', 'string', 'in:store_keeper,factory_driver,truck_driver'],
            'device_id' => ['nullable', 'string', 'max:100'],
            'payloads' => ['required', 'array', 'min:1', 'max:200'],
            'payloads.*.client_uuid' => ['required', 'string', 'max:100'],
            'payloads.*.payload_type' => ['required', 'string', 'max:50'],
            'payloads.*.client_timestamp' => ['required', 'date'],
            'payloads.*.payload_data' => ['required', 'array'],
        ]);

        $stored = 0;
        $duplicates = 0;

        foreach ($data['payloads'] as $p) {
            // Idempotency gate — skip already-processed UUIDs
            if (OfflineSyncPayload::isDuplicate($p['client_uuid'])) {
                $duplicates++;
                continue;
            }

            OfflineSyncPayload::create([
                'id' => (string) Str::uuid(),
                'user_id' => $userId,
                'device_id' => $data['device_id'] ?? null,
                'app_module' => $data['app_module'],
                'payload_type' => $p['payload_type'],
                'payload_data' => $p['payload_data'],
                'client_uuid' => $p['client_uuid'],
                'client_timestamp' => $p['client_timestamp'],
                'status' => OfflineSyncPayload::STATUS_PENDING,
            ]);

            $stored++;
        }

        // Dispatch async processing
        if ($stored > 0) {
            OfflineSyncProcessingJob::dispatch(userId: $userId);
        }

        return response()->json([
            'success' => true,
            'message' => "{$stored} payloads queued, {$duplicates} duplicates skipped.",
            'data' => [
                'stored' => $stored,
                'duplicates_skipped' => $duplicates,
                'status' => 'processing',
            ],
        ], 202);
    }

    /**
     * GET /api/v1/sync/status
     */
    public function status(Request $request): JsonResponse
    {
        $userId = (string) $request->user()->id;

        $counts = [
            'pending' => OfflineSyncPayload::pending()->where('user_id', $userId)->count(),
            'processed' => OfflineSyncPayload::where('user_id', $userId)
                ->where('status', OfflineSyncPayload::STATUS_PROCESSED)->count(),
            'failed' => OfflineSyncPayload::where('user_id', $userId)
                ->where('status', OfflineSyncPayload::STATUS_FAILED)->count(),
            'duplicates' => OfflineSyncPayload::where('user_id', $userId)
                ->where('status', OfflineSyncPayload::STATUS_DUPLICATE)->count(),
        ];

        return response()->json(['success' => true, 'data' => $counts]);
    }
}
