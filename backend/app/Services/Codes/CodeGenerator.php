<?php

namespace App\Services\Codes;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CodeGenerator
{
    public function generateBase(string $companyId, string $planId, string $type, int $count, array $baseOverrides = []): array
    {
        $batchId = $baseOverrides['batch_id'] ?? ('BATCH-' . now()->format('YmdHis') . '-' . Str::random(6));
        $storeKeeperPrefix = $baseOverrides['store_keeper_prefix'] ?? strtoupper(substr($type, 0, 1));

        $rows = [];
        for ($i = 0; $i < $count; $i++) {
            $id = (string) Str::uuid();
            $code = strtoupper($storeKeeperPrefix) . '-' . strtoupper(Str::random(10));
            $storeKeeperCode = 'SK-' . strtoupper(Str::random(10));

            $rows[] = array_merge([
                'id' => $id,
                'company_id' => $companyId,
                'subscription_plan_id' => $planId,
                'code' => $code,
                'code_type' => $type,
                'status' => 'generated',
                'store_keeper_code' => $storeKeeperCode,
                'international_code' => null,
                'batch_id' => $batchId,
                'generated_at' => now(),
                'linked_at' => null,
                'published_at' => null,
                'deactivated_at' => null,
                'product_id' => null,
                'product_batch_number' => null,
                'manufacturing_date' => null,
                'expiry_date' => null,
                'warranty_months' => null,
                'qr_code_data' => null,
                'barcode_data' => null,
                'metadata' => json_encode([]),
                'version' => 1,
                'is_deleted' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ], $baseOverrides);
        }

        DB::table('base_codes')->insert($rows);

        return $rows;
    }
}

