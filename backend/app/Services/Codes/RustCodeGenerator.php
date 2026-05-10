<?php

namespace App\Services\Codes;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Process;
use RuntimeException;

/**
 * Rust Code Generator Bridge
 *
 * Calls the compiled Rust binary (nexatrace_rust) for high-volume code generation.
 * Falls back to the PHP CodeGenerator when the Rust binary is unavailable.
 *
 * Architecture: 1:1 clone of the Carton/Packet/Unit generation pipeline.
 * The Rust binary accepts JSON on stdin and returns JSON on stdout.
 *
 * Binary path: base_path('rust/target/release/nexatrace_rust')
 * Build: cd rust && cargo build --release
 */
class RustCodeGenerator
{
    private ?string $binaryPath = null;

    private const MIN_COUNT_FOR_RUST = 500; // Use Rust for batches >= 500 codes

    public function __construct(
        private CodeGenerator $phpFallback,
    ) {
        $this->detectBinary();
    }

    /**
     * Generate base codes using Rust (or PHP fallback).
     *
     * @return array Array of base code rows
     */
    public function generateBase(
        string $companyId,
        string $planId,
        string $type,
        int $count,
        array $baseOverrides = [],
    ): array {
        // For small batches or when Rust is unavailable, use PHP fallback
        if ($count < self::MIN_COUNT_FOR_RUST || !$this->isAvailable()) {
            return $this->phpFallback->generateBase($companyId, $planId, $type, $count, $baseOverrides);
        }

        try {
            return $this->generateViaRust($companyId, $planId, $type, $count, $baseOverrides);
        } catch (\Throwable $e) {
            Log::warning('Rust generation failed, falling back to PHP', [
                'error' => $e->getMessage(),
                'type' => $type,
                'count' => $count,
            ]);
            return $this->phpFallback->generateBase($companyId, $planId, $type, $count, $baseOverrides);
        }
    }

    /**
     * Check if the Rust binary is available and executable.
     */
    public function isAvailable(): bool
    {
        return $this->binaryPath !== null && file_exists($this->binaryPath) && is_executable($this->binaryPath);
    }

    /**
     * Get the Rust binary path.
     */
    public function binaryPath(): ?string
    {
        return $this->binaryPath;
    }

    /**
     * Get the module version from Rust binary.
     */
    public function version(): string
    {
        if (!$this->isAvailable()) {
            return 'unavailable';
        }

        $result = Process::run($this->binaryPath . ' --version');
        return trim($result->output()) ?: 'unknown';
    }

    // ─── Private ──────────────────────────────────────────────────

    private function detectBinary(): void
    {
        $candidates = [
            base_path('rust/target/release/nexatrace_rust'),
            base_path('rust/target/release/nexatrace_rust.exe'),
            '/usr/local/bin/nexatrace_rust',
            '/opt/nexatrace/nexatrace_rust',
        ];

        foreach ($candidates as $path) {
            if (file_exists($path) && is_executable($path)) {
                $this->binaryPath = $path;
                Log::info('Rust binary detected', ['path' => $path]);
                return;
            }
        }

        Log::info('Rust binary not found. Code generation will use PHP fallback. Build with: cd rust && cargo build --release');
    }

    private function generateViaRust(
        string $companyId,
        string $planId,
        string $type,
        int $count,
        array $baseOverrides,
    ): array {
        $batchId = $baseOverrides['batch_id'] ?? ('BATCH-' . now()->format('YmdHis') . '-' . \Illuminate\Support\Str::random(6));
        $storeKeeperPrefix = $baseOverrides['store_keeper_prefix'] ?? strtoupper(substr($type, 0, 1));

        $input = json_encode([
            'company_id' => $companyId,
            'plan_id' => $planId,
            'code_type' => $type,
            'count' => $count,
            'batch_id' => $batchId,
            'prefix' => $storeKeeperPrefix,
            'timestamp' => now()->toIso8601String(),
        ]);

        if ($input === false) {
            throw new RuntimeException('Failed to encode Rust input JSON');
        }

        // Call Rust binary via stdin/stdout pipe
        $process = Process::input($input)->run($this->binaryPath . ' generate');

        if (!$process->successful()) {
            throw new RuntimeException('Rust binary failed: ' . $process->errorOutput());
        }

        $output = json_decode($process->output(), true);

        if (!is_array($output) || !isset($output['codes'])) {
            throw new RuntimeException('Invalid Rust output: ' . $process->output());
        }

        // Map Rust output to base_codes rows
        $rows = [];
        foreach ($output['codes'] as $i => $codeData) {
            $id = $codeData['id'] ?? (string) \Illuminate\Support\Str::uuid();
            $code = $codeData['code'] ?? (strtoupper($storeKeeperPrefix) . '-' . strtoupper(\Illuminate\Support\Str::random(10)));
            $storeKeeperCode = $codeData['store_keeper_code'] ?? ('SK-' . strtoupper(\Illuminate\Support\Str::random(10)));

            $rows[] = [
                'id' => $id,
                'company_id' => $companyId,
                'subscription_plan_id' => $planId,
                'code' => $code,
                'code_type' => $type,
                'status' => 'generated',
                'store_keeper_code' => $storeKeeperCode,
                'international_code' => $codeData['international_code'] ?? null,
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
                'qr_code_data' => $codeData['qr_code_data'] ?? null,
                'barcode_data' => $codeData['barcode_data'] ?? null,
                'metadata' => json_encode($codeData['metadata'] ?? []),
                'version' => 1,
                'is_deleted' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        return $rows;
    }
}
