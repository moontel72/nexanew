<?php

namespace App\Http\Controllers;

use App\Services\Factory\ProductionVaultService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * NEXATRACE — FACTORY PRODUCTION CONTROLLER
 * ===========================================
 *
 * Cryptographic serial generation, batch lifecycle management,
 * and authenticity verification endpoints.
 * Wired in routes/panels/factory.php.
 */

class FactoryProductionController extends Controller
{
    public function __construct(
        private ProductionVaultService $vault
    ) {}

    /**
     * POST /api/v1/factory/production/batches
     */
    public function createBatch(Request $request): JsonResponse
    {
        $user = $request->user();
        $factoryId = (string) $user->company_id ?? (string) $user->id;

        $data = $request->validate([
            'batch_name' => ['nullable', 'string', 'max:200'],
            'product_id' => ['nullable', 'string', 'max:100'],
            'factory_secret_key' => ['required', 'string', 'min:16', 'max:256'],
        ]);

        $batchNumber = 'BAT-' . strtoupper(Str::random(10));
        $secretHash = hash('sha256', $data['factory_secret_key']);

        $batchId = (string) Str::uuid();
        \Illuminate\Support\Facades\DB::table('production_batches')->insert([
            'id' => $batchId,
            'factory_id' => $factoryId,
            'batch_number' => $batchNumber,
            'batch_name' => $data['batch_name'] ?? null,
            'product_id' => $data['product_id'] ?? null,
            'factory_secret_key_hash' => $secretHash,
            'status' => 'draft',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'data' => ['batch_id' => $batchId, 'batch_number' => $batchNumber, 'status' => 'draft'],
        ], 201);
    }

    /**
     * POST /api/v1/factory/production/generate-serials
     */
    public function generateSerials(Request $request): JsonResponse
    {
        $data = $request->validate([
            'batch_id' => ['required', 'string', 'max:100'],
            'quantity' => ['required', 'integer', 'min:1', 'max:100000'],
            'factory_secret_key' => ['required', 'string', 'min:16'],
        ]);

        try {
            $count = $this->vault->generateSecureBatchItems(
                batchId: $data['batch_id'],
                quantity: (int) $data['quantity'],
                factorySecretKey: $data['factory_secret_key'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'data' => ['serials_generated' => $count]]);
    }

    /**
     * POST /api/v1/factory/production/seal
     */
    public function sealBatch(Request $request): JsonResponse
    {
        $supervisorId = (string) $request->user()->id;

        $data = $request->validate([
            'batch_id' => ['required', 'string', 'max:100'],
            'supervisor_signature' => ['required', 'string', 'max:128'],
        ]);

        try {
            $this->vault->sealBatch($data['batch_id'], $supervisorId, $data['supervisor_signature']);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'message' => 'Batch sealed. Signature recorded.']);
    }

    /**
     * POST /api/v1/factory/production/release
     */
    public function releaseBatch(Request $request): JsonResponse
    {
        $supervisorId = (string) $request->user()->id;

        $data = $request->validate([
            'batch_id' => ['required', 'string', 'max:100'],
            'supervisor_signature' => ['required', 'string', 'max:128'],
        ]);

        try {
            $this->vault->releaseBatch($data['batch_id'], $supervisorId, $data['supervisor_signature']);
        } catch (\RuntimeException $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 422);
        }

        return response()->json(['success' => true, 'message' => 'Batch released for transit. Dispatch unlocked.']);
    }

    /**
     * POST /api/v1/factory/production/verify-serial
     */
    public function verifySerial(Request $request): JsonResponse
    {
        $data = $request->validate([
            'serial_hash' => ['required', 'string', 'max:64'],
        ]);

        $result = $this->vault->verifySerialAuthenticity($data['serial_hash']);

        if (! $result) {
            return response()->json([
                'success' => false,
                'message' => 'COUNTERFEIT DETECTED. This serial is not in the NexaTrace vault.',
                'data' => ['is_authentic' => false],
            ]);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }
}
