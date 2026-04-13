<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Company;
use App\Models\User;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Mail\Message;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class NotificationService
{
    /**
     * Send invoice notification email
     */
    public function sendInvoiceNotification(Invoice $invoice, array $options = []): bool
    {
        try {
            $company = $invoice->company;
            $billingContact = $this->getBillingContact($company);

            if (!$billingContact) {
                Log::warning('No billing contact found for company', [
                    'company_id' => $company->id,
                    'invoice_id' => $invoice->id,
                ]);
                return false;
            }

            $data = $this->prepareInvoiceEmailData($invoice, $billingContact, $options);

            Mail::send('emails.invoice', $data, function (Message $message) use ($data, $invoice) {
                $message->to($data['to_email'], $data['to_name'])
                    ->subject($data['subject'])
                    ->from(
                        config('mail.from.address', 'billing@nexatrace.com'),
                        config('mail.from.name', 'NexaTrace Billing')
                    );

                // Attach PDF if available
                if ($data['attach_pdf'] && $data['pdf_path']) {
                    $message->attach($data['pdf_path'], [
                        'as' => "invoice-{$invoice->invoice_number}.pdf",
                        'mime' => 'application/pdf',
                    ]);
                }
            });

            Log::info('Invoice notification sent successfully', [
                'invoice_id' => $invoice->id,
                'invoice_number' => $invoice->invoice_number,
                'recipient' => $billingContact->email,
                'company_id' => $company->id,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send invoice notification', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return false;
        }
    }

    /**
     * Send payment confirmation email
     */
    public function sendPaymentConfirmation(Invoice $invoice, array $paymentData): bool
    {
        try {
            $company = $invoice->company;
            $billingContact = $this->getBillingContact($company);

            if (!$billingContact) {
                Log::warning('No billing contact found for payment confirmation', [
                    'company_id' => $company->id,
                    'invoice_id' => $invoice->id,
                ]);
                return false;
            }

            $data = $this->preparePaymentEmailData($invoice, $paymentData, $billingContact);

            Mail::send('emails.payment_confirmation', $data, function (Message $message) use ($data, $invoice) {
                $message->to($data['to_email'], $data['to_name'])
                    ->subject($data['subject'])
                    ->from(
                        config('mail.from.address', 'billing@nexatrace.com'),
                        config('mail.from.name', 'NexaTrace Billing')
                    );

                // Attach receipt if available
                if ($data['attach_receipt'] && $data['receipt_path']) {
                    $message->attach($data['receipt_path'], [
                        'as' => "receipt-{$invoice->invoice_number}.pdf",
                        'mime' => 'application/pdf',
                    ]);
                }
            });

            Log::info('Payment confirmation sent successfully', [
                'invoice_id' => $invoice->id,
                'invoice_number' => $invoice->invoice_number,
                'recipient' => $billingContact->email,
                'payment_amount' => $paymentData['amount'] ?? 0,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send payment confirmation', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return false;
        }
    }

    /**
     * Send overdue invoice reminder
     */
    public function sendOverdueReminder(Invoice $invoice, int $daysOverdue): bool
    {
        try {
            $company = $invoice->company;
            $billingContact = $this->getBillingContact($company);

            if (!$billingContact) {
                Log::warning('No billing contact found for overdue reminder', [
                    'company_id' => $company->id,
                    'invoice_id' => $invoice->id,
                ]);
                return false;
            }

            $data = $this->prepareOverdueEmailData($invoice, $daysOverdue, $billingContact);

            Mail::send('emails.overdue_reminder', $data, function (Message $message) use ($data, $invoice) {
                $message->to($data['to_email'], $data['to_name'])
                    ->subject($data['subject'])
                    ->from(
                        config('mail.from.address', 'billing@nexatrace.com'),
                        config('mail.from.name', 'NexaTrace Billing')
                    );

                // Attach invoice PDF
                if ($data['attach_invoice'] && $data['invoice_path']) {
                    $message->attach($data['invoice_path'], [
                        'as' => "invoice-{$invoice->invoice_number}.pdf",
                        'mime' => 'application/pdf',
                    ]);
                }
            });

            Log::info('Overdue reminder sent successfully', [
                'invoice_id' => $invoice->id,
                'invoice_number' => $invoice->invoice_number,
                'days_overdue' => $daysOverdue,
                'recipient' => $billingContact->email,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send overdue reminder', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return false;
        }
    }

    /**
     * Send credit note notification
     */
    public function sendCreditNoteNotification($creditNote): bool
    {
        try {
            $company = $creditNote->company;
            $billingContact = $this->getBillingContact($company);

            if (!$billingContact) {
                Log::warning('No billing contact found for credit note', [
                    'company_id' => $company->id,
                    'credit_note_id' => $creditNote->id,
                ]);
                return false;
            }

            $data = $this->prepareCreditNoteEmailData($creditNote, $billingContact);

            Mail::send('emails.credit_note', $data, function (Message $message) use ($data, $creditNote) {
                $message->to($data['to_email'], $data['to_name'])
                    ->subject($data['subject'])
                    ->from(
                        config('mail.from.address', 'billing@nexatrace.com'),
                        config('mail.from.name', 'NexaTrace Billing')
                    );

                // Attach credit note PDF
                if ($data['attach_pdf'] && $data['pdf_path']) {
                    $message->attach($data['pdf_path'], [
                        'as' => "credit-note-{$creditNote->credit_note_number}.pdf",
                        'mime' => 'application/pdf',
                    ]);
                }
            });

            Log::info('Credit note notification sent successfully', [
                'credit_note_id' => $creditNote->id,
                'credit_note_number' => $creditNote->credit_note_number,
                'recipient' => $billingContact->email,
                'amount' => $creditNote->amount,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send credit note notification', [
                'credit_note_id' => $creditNote->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return false;
        }
    }

    /**
     * Send refund notification
     */
    public function sendRefundNotification($refund): bool
    {
        try {
            $company = $refund->company;
            $billingContact = $this->getBillingContact($company);

            if (!$billingContact) {
                Log::warning('No billing contact found for refund', [
                    'company_id' => $company->id,
                    'refund_id' => $refund->id,
                ]);
                return false;
            }

            $data = $this->prepareRefundEmailData($refund, $billingContact);

            Mail::send('emails.refund', $data, function (Message $message) use ($data, $refund) {
                $message->to($data['to_email'], $data['to_name'])
                    ->subject($data['subject'])
                    ->from(
                        config('mail.from.address', 'billing@nexatrace.com'),
                        config('mail.from.name', 'NexaTrace Billing')
                    );
            });

            Log::info('Refund notification sent successfully', [
                'refund_id' => $refund->id,
                'recipient' => $billingContact->email,
                'amount' => $refund->amount,
            ]);

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to send refund notification', [
                'refund_id' => $refund->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return false;
        }
    }

    /**
     * Get billing contact for a company
     */
    private function getBillingContact(Company $company): ?User
    {
        // First try to get the primary billing contact
        $billingContact = $company->users()
            ->where('role', 'billing')
            ->orWhere('is_billing_contact', true)
            ->first();

        // If no billing contact, get company admin
        if (!$billingContact) {
            $billingContact = $company->users()
                ->where('role', 'admin')
                ->first();
        }

        // If still no contact, get any active user
        if (!$billingContact) {
            $billingContact = $company->users()
                ->where('status', 'active')
                ->first();
        }

        return $billingContact;
    }

    /**
     * Prepare invoice email data
     */
    private function prepareInvoiceEmailData(Invoice $invoice, User $recipient, array $options): array
    {
        $company = $invoice->company;
        $dueDate = Carbon::parse($invoice->due_date);
        $issueDate = Carbon::parse($invoice->issue_date);

        $pdfPath = null;
        $attachPdf = $options['attach_pdf'] ?? true;

        if ($attachPdf) {
            $pdfPath = $this->getInvoicePdfPath($invoice);
        }

        return [
            'to_email' => $recipient->email,
            'to_name' => $recipient->name ?? $company->name,
            'subject' => sprintf('Invoice %s from NexaTrace', $invoice->invoice_number),
            'company_name' => $company->name,
            'invoice_number' => $invoice->invoice_number,
            'issue_date' => $issueDate->format('F j, Y'),
            'due_date' => $dueDate->format('F j, Y'),
            'total_amount' => number_format($invoice->total_amount, 2),
            'currency' => $invoice->currency,
            'items' => $invoice->items,
            'notes' => $invoice->notes,
            'payment_instructions' => $this->getPaymentInstructions($company),
            'support_email' => config('mail.support.address', 'support@nexatrace.com'),
            'attach_pdf' => $attachPdf,
            'pdf_path' => $pdfPath,
            'invoice_url' => $options['invoice_url'] ?? null,
            'payment_url' => $options['payment_url'] ?? null,
        ];
    }

    /**
     * Prepare payment email data
     */
    private function preparePaymentEmailData(Invoice $invoice, array $paymentData, User $recipient): array
    {
        $company = $invoice->company;
        $paymentDate = Carbon::parse($paymentData['payment_date'] ?? now());

        $receiptPath = null;
        $attachReceipt = $paymentData['attach_receipt'] ?? true;

        if ($attachReceipt) {
            $receiptPath = $this->getReceiptPdfPath($invoice, $paymentData);
        }

        return [
            'to_email' => $recipient->email,
            'to_name' => $recipient->name ?? $company->name,
            'subject' => sprintf('Payment Confirmation for Invoice %s', $invoice->invoice_number),
            'company_name' => $company->name,
            'invoice_number' => $invoice->invoice_number,
            'payment_amount' => number_format($paymentData['amount'], 2),
            'payment_date' => $paymentDate->format('F j, Y'),
            'payment_method' => $paymentData['method'] ?? 'Unknown',
            'payment_reference' => $paymentData['reference'] ?? null,
            'currency' => $invoice->currency,
            'receipt_number' => $paymentData['receipt_number'] ?? null,
            'attach_receipt' => $attachReceipt,
            'receipt_path' => $receiptPath,
            'support_email' => config('mail.support.address', 'support@nexatrace.com'),
        ];
    }

    /**
     * Prepare overdue email data
     */
    private function prepareOverdueEmailData(Invoice $invoice, int $daysOverdue, User $recipient): array
    {
        $company = $invoice->company;
        $dueDate = Carbon::parse($invoice->due_date);

        $invoicePath = null;
        $attachInvoice = true;

        if ($attachInvoice) {
            $invoicePath = $this->getInvoicePdfPath($invoice);
        }

        // Calculate late fee if applicable
        $lateFee = 0;
        $totalWithLateFee = $invoice->total_amount;

        if ($daysOverdue > 30 && $company->late_fee_percentage > 0) {
            $lateFee = $invoice->total_amount * ($company->late_fee_percentage / 100);
            $totalWithLateFee = $invoice->total_amount + $lateFee;
        }

        return [
            'to_email' => $recipient->email,
            'to_name' => $recipient->name ?? $company->name,
            'subject' => sprintf('REMINDER: Invoice %s is %d days overdue', $invoice->invoice_number, $daysOverdue),
            'company_name' => $company->name,
            'invoice_number' => $invoice->invoice_number,
            'due_date' => $dueDate->format('F j, Y'),
            'days_overdue' => $daysOverdue,
            'original_amount' => number_format($invoice->total_amount, 2),
            'late_fee' => number_format($lateFee, 2),
            'total_with_late_fee' => number_format($totalWithLateFee, 2),
            'currency' => $invoice->currency,
            'payment_instructions' => $this->getPaymentInstructions($company),
            'support_email' => config('mail.support.address', 'support@nexatrace.com'),
            'attach_invoice' => $attachInvoice,
            'invoice_path' => $invoicePath,
            'payment_url' => url("/invoices/{$invoice->id}/pay"),
        ];
    }

    /**
     * Prepare credit note email data
     */
    private function prepareCreditNoteEmailData($creditNote, User $recipient): array
    {
        $company = $creditNote->company;
        $issueDate = Carbon::parse($creditNote->issue_date);

        $pdfPath = null;
        $attachPdf = true;

        if ($attachPdf) {
            $pdfPath = $this->getCreditNotePdfPath($creditNote);
        }

        return [
            'to_email' => $recipient->email,
            'to_name' => $recipient->name ?? $company->name,
            'subject' => sprintf('Credit Note %s from NexaTrace', $creditNote->credit_note_number),
            'company_name' => $company->name,
            'credit_note_number' => $creditNote->credit_note_number,
            'issue_date' => $issueDate->format('F j, Y'),
            'amount' => number_format($creditNote->amount, 2),
            'currency' => $creditNote->currency,
            'reason' => $creditNote->reason,
            'notes' => $creditNote->notes,
            'attach_pdf' => $attachPdf,
            'pdf_path' => $pdfPath,
            'support_email' => config('mail.support.address', 'support@nexatrace.com'),
        ];
    }

    /**
     * Prepare refund email data
     */
    private function prepareRefundEmailData($refund, User $recipient): array
    {
        $company = $refund->company;
        $processedDate = Carbon::parse($refund->processed_at ?? now());

        return [
            'to_email' => $recipient->email,
            'to_name' => $recipient->name ?? $company->name,
            'subject' => sprintf('Refund Processed - %s', $refund->reference ?? 'Reference'),
            'company_name' => $company->name,
            'refund_amount' => number_format($refund->amount, 2),
            'refund_date' => $processedDate->format('F j, Y'),
            'currency' => $refund->currency,
            'reason' => $refund->reason,
            'reference' => $refund->reference,
            'payment_method' => $refund->payment_method,
            'estimated_arrival' => $this->getRefundEstimatedArrival($refund),
            'support_email' => config('mail.support.address', 'support@nexatrace.com'),
        ];
    }

    /**
     * Get invoice PDF path
     */
    private function getInvoicePdfPath(Invoice $invoice): ?string
    {
        $path = storage_path("app/invoices/{$invoice->id}.pdf");
