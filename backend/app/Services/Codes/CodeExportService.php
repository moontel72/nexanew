<?php

namespace App\Services\Codes;

use App\Models\Invoice;
use App\Services\Pdf\SimplePdfGenerator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\URL;

class CodeExportService
{
    public function __construct(private SimplePdfGenerator $pdf)
    {
    }

    public function exportCodesToFile(
        string $companyId,
        string $codeType,
        array $codeIds,
        string $format,
        array $options = [],
    ): array {
        $format = strtolower(trim($format));
        if (!in_array($format, ['csv', 'pdf'], true)) {
            throw new \InvalidArgumentException('Invalid export format');
        }

        $rows = $this->loadBaseCodes($companyId, $codeType, $codeIds);
        if (empty($rows)) {
            throw new \RuntimeException('No codes found');
        }

        foreach ($rows as $r) {
            if (($r['status'] ?? '') !== 'published') {
                throw new \RuntimeException('Only published codes can be downloaded');
            }
        }

        $lock = $this->findUnpaidInvoiceLock($companyId, $rows);
        if ($lock !== null) {
            $invoice = $lock;
            throw new CodeExportLockedException(
                (string) ($invoice->id ?? ''),
                (string) ($invoice->invoice_number ?? ''),
                (float) ($invoice->total_amount ?? 0),
                (string) ($invoice->currency ?? 'USD'),
                (string) ($invoice->status ?? 'pending'),
            );
        }

        $ext = $format === 'pdf' ? 'pdf' : 'csv';

        // Dynamic filename: [CodeFormat]_[Type]_[BatchID]_[Date].csv
        $codeFormat = $options['code_format'] ?? '';
        $batchId = $options['batch_id'] ?? '';
        $dateStr = now()->format('Y-m-d');

        $parts = [];
        if (!empty($codeFormat)) {
            $parts[] = str_replace('_', '-', strtoupper((string) $codeFormat));
        }
        $parts[] = ucfirst($codeType);
        if (!empty($batchId)) {
            $sanitizedBatch = preg_replace('/[^A-Za-z0-9_-]/', '', (string) $batchId);
            if (!empty($sanitizedBatch)) {
                $parts[] = $sanitizedBatch;
            }
        }
        $parts[] = $dateStr;
        $baseName = implode('_', $parts);
        $fileName = $baseName . '_' . now()->format('His') . '.' . $ext;

        $dir = storage_path('app/public/exports/' . $companyId);
        File::ensureDirectoryExists($dir);
        $absPath = $dir . DIRECTORY_SEPARATOR . $fileName;

        if ($format === 'csv') {
            $this->writeCsv($absPath, $rows, $options);
        } else {
            $this->writePdf($absPath, $rows, $codeType);
        }

        return [
            'file_name' => $fileName,
            'file_path' => '/storage/exports/' . $companyId . '/' . $fileName,
            'download_url' => URL::temporarySignedRoute(
                'codes.exports.download',
                now()->addMinutes(10),
                ['companyId' => $companyId, 'file' => $fileName],
            ),
        ];
    }

    private function loadBaseCodes(string $companyId, string $codeType, array $codeIds): array
    {
        $ids = array_values(array_filter(array_map('strval', $codeIds)));
        $ids = array_values(array_unique($ids));
        if (empty($ids)) {
            return [];
        }

        $rows = DB::table('base_codes')
            ->select([
                'id',
                'code',
                'code_type',
                'status',
                'company_id',
                'subscription_plan_id',
                'store_keeper_code',
                'international_code',
                'batch_id',
                'generated_at',
                'linked_at',
                'published_at',
                'deactivated_at',
                'product_id',
                'product_batch_number',
                'manufacturing_date',
                'expiry_date',
                'warranty_months',
                'qr_code_data',
                'barcode_data',
                'metadata',
            ])
            ->where('company_id', $companyId)
            ->where('code_type', $codeType)
            ->whereIn('id', $ids)
            ->get();

        return collect($rows)->map(function ($r) {
            return [
                'id' => (string) $r->id,
                'code' => (string) $r->code,
                'code_type' => (string) $r->code_type,
                'status' => (string) $r->status,
                'company_id' => (string) $r->company_id,
                'subscription_plan_id' => (string) ($r->subscription_plan_id ?? ''),
                'store_keeper_code' => (string) ($r->store_keeper_code ?? ''),
                'international_code' => (string) ($r->international_code ?? ''),
                'batch_id' => (string) ($r->batch_id ?? ''),
                'generated_at' => $r->generated_at,
                'linked_at' => $r->linked_at,
                'published_at' => $r->published_at,
                'deactivated_at' => $r->deactivated_at,
                'product_id' => (string) ($r->product_id ?? ''),
                'product_batch_number' => (string) ($r->product_batch_number ?? ''),
                'manufacturing_date' => $r->manufacturing_date,
                'expiry_date' => $r->expiry_date,
                'warranty_months' => $r->warranty_months,
                'qr_code_data' => (string) ($r->qr_code_data ?? ''),
                'barcode_data' => (string) ($r->barcode_data ?? ''),
                'metadata' => $r->metadata,
            ];
        })->all();
    }

    private function findUnpaidInvoiceLock(string $companyId, array $rows): ?Invoice
    {
        $invoiceIds = [];
        foreach ($rows as $r) {
            $meta = $r['metadata'] ?? null;
            $decoded = null;
            if (is_string($meta) && trim($meta) !== '') {
                $decoded = json_decode($meta, true);
            } elseif (is_array($meta)) {
                $decoded = $meta;
            } elseif (is_object($meta)) {
                $decoded = json_decode(json_encode($meta), true);
            }

            if (is_array($decoded) && !empty($decoded['publish_invoice_id'])) {
                $invoiceIds[] = (string) $decoded['publish_invoice_id'];
            }
        }

        $invoiceIds = array_values(array_unique(array_filter($invoiceIds)));
        if (empty($invoiceIds)) {
            return null;
        }

        $invoices = Invoice::query()
            ->where('company_id', $companyId)
            ->whereIn('id', $invoiceIds)
            ->get()
            ->keyBy('id');

        foreach ($invoiceIds as $id) {
            $inv = $invoices->get($id);
            if ($inv && (string) $inv->status !== 'paid') {
                return $inv;
            }
        }

        return null;
    }

    private function writeCsv(string $absPath, array $rows, array $options): void
    {
        $includeQr = (bool) ($options['include_qr_codes'] ?? true);
        $includeBarcodes = (bool) ($options['include_barcodes'] ?? true);
        $includeInternational = (bool) ($options['include_international_codes'] ?? true);

        $fp = fopen($absPath, 'wb');
        if ($fp === false) {
            throw new \RuntimeException('Failed to create export file');
        }

        $headers = [
            'code',
            'code_type',
            'store_keeper_code',
            'batch_id',
            'product_id',
            'product_batch_number',
            'manufacturing_date',
            'expiry_date',
            'warranty_months',
            'published_at',
        ];

        if ($includeInternational) {
            $headers[] = 'international_code';
        }
        if ($includeQr) {
            $headers[] = 'qr_code_data';
        }
        if ($includeBarcodes) {
            $headers[] = 'barcode_data';
        }

        fputcsv($fp, $headers);

        foreach ($rows as $r) {
            $row = [
                $r['code'] ?? '',
                $r['code_type'] ?? '',
                $r['store_keeper_code'] ?? '',
                $r['batch_id'] ?? '',
                $r['product_id'] ?? '',
                $r['product_batch_number'] ?? '',
                $r['manufacturing_date'] ?? '',
                $r['expiry_date'] ?? '',
                $r['warranty_months'] ?? '',
                $r['published_at'] ?? '',
            ];

            if ($includeInternational) {
                $row[] = $r['international_code'] ?? '';
            }
            if ($includeQr) {
                $row[] = $r['qr_code_data'] ?? '';
            }
            if ($includeBarcodes) {
                $row[] = $r['barcode_data'] ?? '';
            }

            fputcsv($fp, $row);
        }

        fclose($fp);
    }

    private function writePdf(string $absPath, array $rows, string $codeType): void
    {
        $lines = [];
        $lines[] = 'NexaTrace Codes Export';
        $lines[] = 'Type: ' . strtoupper($codeType);
        $lines[] = 'Exported At: ' . now()->toDateTimeString();
        $lines[] = 'Count: ' . count($rows);
        $lines[] = '';

        foreach ($rows as $r) {
            $lines[] = 'Code: ' . ($r['code'] ?? '');
            if (!empty($r['store_keeper_code'])) {
                $lines[] = 'StoreKeeper: ' . $r['store_keeper_code'];
            }
            if (!empty($r['international_code'])) {
                $lines[] = 'International: ' . $r['international_code'];
            }
            if (!empty($r['batch_id'])) {
                $lines[] = 'Batch: ' . $r['batch_id'];
            }
            if (!empty($r['product_batch_number'])) {
                $lines[] = 'Product Batch: ' . $r['product_batch_number'];
            }
            if (!empty($r['published_at'])) {
                $lines[] = 'Published At: ' . $r['published_at'];
            }
            $lines[] = '';
        }

        $pdfBytes = $this->pdf->generate($lines);
        file_put_contents($absPath, $pdfBytes);
    }
}

class CodeExportLockedException extends \RuntimeException
{
    public function __construct(
        public readonly string $invoiceId,
        public readonly string $invoiceNumber,
        public readonly float $amount,
        public readonly string $currency,
        public readonly string $status,
    ) {
        parent::__construct('Download locked: invoice unpaid');
    }
}
