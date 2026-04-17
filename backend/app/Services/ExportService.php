<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Payment;
use App\Models\CreditNote;
use App\Models\Company;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use League\Csv\Writer;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ExportService
{
    /**
     * Export invoices to CSV
     */
    public function exportInvoicesToCsv(array $filters = []): StreamedResponse
    {
        $invoices = $this->getInvoicesForExport($filters);

        return response()->streamDownload(function () use ($invoices) {
            $csv = Writer::createFromFileObject(new \SplTempFileObject());

            // Add headers
            $csv->insertOne([
                'Invoice Number',
                'Company',
                'Issue Date',
                'Due Date',
                'Period Start',
                'Period End',
                'Subtotal',
                'Tax',
                'Discount',
                'Total Amount',
                'Currency',
                'Status',
                'Payment Date',
                'Payment Method',
                'Payment Reference',
                'Created At',
            ]);

            // Add data rows
            foreach ($invoices as $invoice) {
                $csv->insertOne([
                    $invoice->invoice_number,
                    $invoice->company->name ?? 'N/A',
                    $invoice->issue_date ? Carbon::parse($invoice->issue_date)->format('Y-m-d') : '',
                    $invoice->due_date ? Carbon::parse($invoice->due_date)->format('Y-m-d') : '',
                    $invoice->period_start ? Carbon::parse($invoice->period_start)->format('Y-m-d') : '',
                    $invoice->period_end ? Carbon::parse($invoice->period_end)->format('Y-m-d') : '',
                    number_format($invoice->subtotal, 2),
                    number_format($invoice->tax_amount, 2),
                    number_format($invoice->discount_amount, 2),
                    number_format($invoice->total_amount, 2),
                    $invoice->currency,
                    $invoice->status,
                    $invoice->payment_date ? Carbon::parse($invoice->payment_date)->format('Y-m-d') : '',
                    $invoice->payment_method ?? '',
                    $invoice->payment_reference ?? '',
                    $invoice->created_at ? Carbon::parse($invoice->created_at)->format('Y-m-d H:i:s') : '',
                ]);
            }

            echo $csv->getContent();
        }, 'invoices-' . date('Y-m-d') . '.csv');
    }

    /**
     * Export invoices to Excel
     */
    public function exportInvoicesToExcel(array $filters = []): StreamedResponse
    {
        $invoices = $this->getInvoicesForExport($filters);

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        // Set headers
        $headers = [
            'Invoice Number',
            'Company',
            'Issue Date',
            'Due Date',
            'Period Start',
            'Period End',
            'Subtotal',
            'Tax',
            'Discount',
            'Total Amount',
            'Currency',
            'Status',
            'Payment Date',
            'Payment Method',
            'Payment Reference',
            'Created At',
        ];

        foreach ($headers as $index => $header) {
            $sheet->setCellValueByColumnAndRow($index + 1, 1, $header);
        }

        // Add data rows
        $row = 2;
        foreach ($invoices as $invoice) {
            $sheet->setCellValueByColumnAndRow(1, $row, $invoice->invoice_number);
            $sheet->setCellValueByColumnAndRow(2, $row, $invoice->company->name ?? 'N/A');
            $sheet->setCellValueByColumnAndRow(3, $row, $invoice->issue_date ? Carbon::parse($invoice->issue_date)->format('Y-m-d') : '');
            $sheet->setCellValueByColumnAndRow(4, $row, $invoice->due_date ? Carbon::parse($invoice->due_date)->format('Y-m-d') : '');
            $sheet->setCellValueByColumnAndRow(5, $row, $invoice->period_start ? Carbon::parse($invoice->period_start)->format('Y-m-d') : '');
            $sheet->setCellValueByColumnAndRow(6, $row, $invoice->period_end ? Carbon::parse($invoice->period_end)->format('Y-m-d') : '');
            $sheet->setCellValueByColumnAndRow(7, $row, $invoice->subtotal);
            $sheet->setCellValueByColumnAndRow(8, $row, $invoice->tax_amount);
            $sheet->setCellValueByColumnAndRow(9, $row, $invoice->discount_amount);
            $sheet->setCellValueByColumnAndRow(10, $row, $invoice->total_amount);
            $sheet->setCellValueByColumnAndRow(11, $row, $invoice->currency);
            $sheet->setCellValueByColumnAndRow(12, $row, $invoice->status);
            $sheet->setCellValueByColumnAndRow(13, $row, $invoice->payment_date ? Carbon::parse($invoice->payment_date)->format('Y-m-d') : '');
            $sheet->setCellValueByColumnAndRow(14, $row, $invoice->payment_method ?? '');
            $sheet->setCellValueByColumnAndRow(15, $row, $invoice->payment_reference ?? '');
            $sheet->setCellValueByColumnAndRow(16, $row, $invoice->created_at ? Carbon::parse($invoice->created_at)->format('Y-m-d H:i:s') : '');

            $row++;
        }

        // Auto-size columns
        foreach (range('A', 'P') as $column) {
            $sheet->getColumnDimension($column)->setAutoSize(true);
        }

        // Create writer and return stream
        $writer = new Xlsx($spreadsheet);

        return response()->streamDownload(function () use ($writer) {
            $writer->save('php://output');
        }, 'invoices-' . date('Y-m-d') . '.xlsx');
    }

    /**
     * Export payments to CSV
     */
    public function exportPaymentsToCsv(array $filters = []): StreamedResponse
    {
        $payments = $this->getPaymentsForExport($filters);

        return response()->streamDownload(function () use ($payments) {
            $csv = Writer::createFromFileObject(new \SplTempFileObject());

            // Add headers
            $csv->insertOne([
                'Payment Date',
                'Invoice Number',
                'Company',
                'Amount',
                'Currency',
                'Payment Method',
                'Reference',
                'Transaction ID',
                'Status',
                'Reconciliation Status',
                'Notes',
                'Created At',
            ]);

            // Add data rows
            foreach ($payments as $payment) {
                $csv->insertOne([
                    $payment->payment_date ? Carbon::parse($payment->payment_date)->format('Y-m-d') : '',
                    $payment->invoice->invoice_number ?? 'N/A',
                    $payment->invoice->company->name ?? 'N/A',
                    number_format($payment->amount, 2),
                    $payment->currency,
                    $payment->method,
                    $payment->reference ?? '',
                    $payment->transaction_id ?? '',
                    $payment->status,
                    $payment->metadata['reconciliation_status'] ?? 'pending',
                    $payment->notes ?? '',
                    $payment->created_at ? Carbon::parse($payment->created_at)->format('Y-m-d H:i:s') : '',
                ]);
            }

            echo $csv->getContent();
        }, 'payments-' . date('Y-m-d') . '.csv');
    }

    /**
     * Export revenue report to Excel
     */
    public function exportRevenueReportToExcel(array $filters = []): StreamedResponse
    {
        $revenueService = app(RevenueService::class);
        $revenueData = $revenueService->getPlatformRevenueSummary($filters);

        $spreadsheet = new Spreadsheet();

        // Summary sheet
        $summarySheet = $spreadsheet->getActiveSheet();
        $summarySheet->setTitle('Revenue Summary');

        $summarySheet->setCellValue('A1', 'Revenue Report - ' . date('F j, Y'));
        $summarySheet->mergeCells('A1:D1');
        $summarySheet->getStyle('A1')->getFont()->setBold(true)->setSize(14);

        $summaryData = [
            ['Metric', 'Amount', 'Currency', 'Percentage'],
            ['Total Revenue', $revenueData['total_revenue'] ?? 0, $revenueData['currency'] ?? 'USD', '100%'],
            ['Recurring Revenue', $revenueData['recurring_revenue'] ?? 0, $revenueData['currency'] ?? 'USD', $this->calculatePercentage($revenueData['recurring_revenue'] ?? 0, $revenueData['total_revenue'] ?? 1)],
            ['Usage Revenue', $revenueData['usage_revenue'] ?? 0, $revenueData['currency'] ?? 'USD', $this->calculatePercentage($revenueData['usage_revenue'] ?? 0, $revenueData['total_revenue'] ?? 1)],
            ['Commission Revenue', $revenueData['commission_revenue'] ?? 0, $revenueData['currency'] ?? 'USD', $this->calculatePercentage($revenueData['commission_revenue'] ?? 0, $revenueData['total_revenue'] ?? 1)],
            ['Manual Revenue', $revenueData['manual_revenue'] ?? 0, $revenueData['currency'] ?? 'USD', $this->calculatePercentage($revenueData['manual_revenue'] ?? 0, $revenueData['total_revenue'] ?? 1)],
            ['Refunds', $revenueData['total_refunds'] ?? 0, $revenueData['currency'] ?? 'USD', $this->calculatePercentage($revenueData['total_refunds'] ?? 0, $revenueData['total_revenue'] ?? 1)],
            ['Net Revenue', $revenueData['net_revenue'] ?? 0, $revenueData['currency'] ?? 'USD', $this->calculatePercentage($revenueData['net_revenue'] ?? 0, $revenueData['total_revenue'] ?? 1)],
        ];

        $row = 3;
        foreach ($summaryData as $data) {
            $col = 1;
            foreach ($data as $value) {
                if (is_numeric($value) && $col == 2) {
                    $summarySheet->setCellValueByColumnAndRow($col, $row, $value);
                    $summarySheet->getStyleByColumnAndRow($col, $row)->getNumberFormat()->setFormatCode('#,##0.00');
                } else {
                    $summarySheet->setCellValueByColumnAndRow($col, $row, $value);
                }
                $col++;
            }
            $row++;
        }

        // Auto-size columns
        foreach (range('A', 'D') as $column) {
            $summarySheet->getColumnDimension($column)->setAutoSize(true);
        }

        // Style header row
        $summarySheet->getStyle('A3:D3')->getFont()->setBold(true);
        $summarySheet->getStyle('A3:D3')->getFill()->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)->getStartColor()->setARGB('FFE0E0E0');

        // Create writer and return stream
        $writer = new Xlsx($spreadsheet);

        return response()->streamDownload(function () use ($writer) {
            $writer->save('php://output');
        }, 'revenue-report-' . date('Y-m-d') . '.xlsx');
    }

    /**
     * Export credit notes to CSV
     */
    public function exportCreditNotesToCsv(array $filters = []): StreamedResponse
    {
        $creditNotes = $this->getCreditNotesForExport($filters);

        return response()->streamDownload(function () use ($creditNotes) {
            $csv = Writer::createFromFileObject(new \SplTempFileObject());

            // Add headers
            $csv->insertOne([
                'Credit Note Number',
                'Company',
                'Invoice Number',
                'Amount',
                'Currency',
                'Reason',
                'Status',
                'Issue Date',
                'Approved By',
                'Application Date',
                'Applied To Invoice',
                'Expiry Date',
                'Created At',
            ]);

            // Add data rows
            foreach ($creditNotes as $creditNote) {
                $csv->insertOne([
                    $creditNote->credit_note_number,
                    $creditNote->company->name ?? 'N/A',
                    $creditNote->invoice->invoice_number ?? 'N/A',
                    number_format($creditNote->amount, 2),
                    $creditNote->currency,
                    $creditNote->reason,
                    $creditNote->status,
                    $creditNote->issue_date ? Carbon::parse($creditNote->issue_date)->format('Y-m-d') : '',
                    $creditNote->approved_by ?? '',
                    $creditNote->application_date ? Carbon::parse($creditNote->application_date)->format('Y-m-d') : '',
                    $creditNote->applied_to_invoice_id ?? '',
                    $creditNote->expiry_date ? Carbon::parse($creditNote->expiry_date)->format('Y-m-d') : '',
                    $creditNote->created_at ? Carbon::parse($creditNote->created_at)->format('Y-m-d H:i:s') : '',
                ]);
            }

            echo $csv->getContent();
        }, 'credit-notes-' . date('Y-m-d') . '.csv');
    }

    /**
     * Get invoices for export with filters
     */
    private function getInvoicesForExport(array $filters = []): Collection
    {
        $query = Invoice::with(['company', 'payments']);

        if (!empty($filters['start_date'])) {
            $query->where('issue_date', '>=', Carbon::parse($filters['start_date'])->startOfDay());
        }

        if (!empty($filters['end_date'])) {
            $query->where('issue_date', '<=', Carbon::parse($filters['end_date'])->endOfDay());
        }

        if (!empty($filters['status'])) {
            $query->whereIn('status', (array) $filters['status']);
        }

        if (!empty($filters['company_id'])) {
            $query->where('company_id', $filters['company_id']);
        }

        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('invoice_number', 'like', "%{$search}%")
                  ->orWhereHas('company', function ($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        return $query->orderBy('issue_date', 'desc')->get();
    }

    /**
     * Get payments for export with filters
     */
    private function getPaymentsForExport(array $filters = []): Collection
    {
        $query = Payment::with(['invoice.company']);

        if (!empty($filters['start_date'])) {
            $query->where('payment_date', '>=', Carbon::parse($filters['start_date'])->startOfDay());
        }

        if (!empty($filters['end_date'])) {
            $query->where('payment_date', '<=', Carbon::parse($filters['end_date'])->endOfDay());
        }

        if (!empty($filters['status'])) {
            $query->whereIn('status', (array) $filters['status']);
        }

        if (!empty($filters['company_id'])) {
            $query->whereHas('invoice', function ($q) use ($filters) {
                $q->where('company_id', $filters['company_id']);
            });
        }

        if (!empty($filters['method'])) {
            $query->where('method', $filters['method']);
        }

        return $query->orderBy('payment_date', 'desc')->get();
    }

    /**
     * Get credit notes for export with filters
     */
    private function getCreditNotesForExport(array $filters = []): Collection
    {
        $query = CreditNote::with(['company', 'invoice']);

        if (!empty($filters['start_date'])) {
            $query->where('issue_date', '>=', Carbon::parse($filters['start_date'])->startOfDay());
        }

        if (!empty($filters['end_date'])) {
            $query->where('issue_date', '<=', Carbon::parse($filters['end_date'])->endOfDay());
        }

        if (!empty($filters['status'])) {
            $query->whereIn('status', (array) $filters['status']);
        }

        if (!empty($filters['company_id'])) {
            $query->where('company_id', $filters['company_id']);
        }

        return $query->orderBy('issue_date', 'desc')->get();
    }

    /**
     * Calculate percentage
     */
    private function calculatePercentage(float $part, float $total): string
    {
        if ($total == 0) {
            return '0%';
        }

        $percentage = ($part / $total) * 100;
        return number_format($percentage, 2) . '%';
    }
}
