<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Refund extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'refunds';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'id';

    /**
     * The "type" of the primary key ID.
     *
     * @var string
     */
    protected $keyType = 'string';

    /**
     * Indicates if the IDs are auto-incrementing.
     *
     * @var bool
     */
    public $incrementing = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'invoice_id',
        'payment_id',
        'company_id',
        'refund_number',
        'amount',
        'currency',
        'reason',
        'status',
        'approved_amount',
        'requested_by',
        'requested_at',
        'processed_by',
        'processed_at',
        'rejection_reason',
        'rejected_by',
        'rejected_at',
        'gateway_refund_id',
        'gateway_name',
        'notes',
        'metadata',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'amount' => 'decimal:2',
        'approved_amount' => 'decimal:2',
        'requested_at' => 'datetime',
        'processed_at' => 'datetime',
        'rejected_at' => 'datetime',
        'metadata' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'metadata',
    ];

    /**
     * Get the invoice associated with the refund.
     */
    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class);
    }

    /**
     * Get the payment associated with the refund.
     */
    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }

    /**
     * Get the company that owns the refund.
     */
    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    /**
     * Get the user who requested the refund.
     */
    public function requestedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    /**
     * Get the user who processed the refund.
     */
    public function processedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'processed_by');
    }

    /**
     * Get the user who rejected the refund.
     */
    public function rejectedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rejected_by');
    }

    /**
     * Scope a query to only include pending refunds.
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope a query to only include approved refunds.
     */
    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    /**
     * Scope a query to only include partially approved refunds.
     */
    public function scopePartiallyApproved($query)
    {
        return $query->where('status', 'partially_approved');
    }

    /**
     * Scope a query to only include rejected refunds.
     */
    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    /**
     * Scope a query to only include processed refunds.
     */
    public function scopeProcessed($query)
    {
        return $query->where('status', 'processed');
    }

    /**
     * Scope a query to only include failed refunds.
     */
    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    /**
     * Scope a query to only include refunds for a specific company.
     */
    public function scopeForCompany($query, $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    /**
     * Scope a query to only include refunds for a specific invoice.
     */
    public function scopeForInvoice($query, $invoiceId)
    {
        return $query->where('invoice_id', $invoiceId);
    }

    /**
     * Check if the refund is pending.
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if the refund is approved.
     */
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    /**
     * Check if the refund is partially approved.
     */
    public function isPartiallyApproved(): bool
    {
        return $this->status === 'partially_approved';
    }

    /**
     * Check if the refund is rejected.
     */
    public function isRejected(): bool
    {
        return $this->status === 'rejected';
    }

    /**
     * Check if the refund is processed.
     */
    public function isProcessed(): bool
    {
        return $this->status === 'processed';
    }

    /**
     * Check if the refund failed.
     */
    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Check if the refund can be approved.
     */
    public function canBeApproved(): bool
    {
        return $this->isPending() && !$this->isRejected() && !$this->isProcessed();
    }

    /**
     * Check if the refund can be rejected.
     */
    public function canBeRejected(): bool
    {
        return $this->isPending() && !$this->isApproved() && !$this->isProcessed();
    }

    /**
     * Check if the refund can be processed.
     */
    public function canBeProcessed(): bool
    {
        return ($this->isApproved() || $this->isPartiallyApproved()) && !$this->isProcessed() && !$this->isFailed();
    }

    /**
     * Check if the refund can be partially approved.
     */
    public function canBePartiallyApproved(): bool
    {
        return $this->isPending() && !$this->isRejected() && !$this->isProcessed();
    }

    /**
     * Get the formatted amount with currency.
     */
    public function getFormattedAmountAttribute(): string
    {
        return number_format($this->amount, 2) . ' ' . $this->currency;
    }

    /**
     * Get the formatted approved amount with currency.
     */
    public function getFormattedApprovedAmountAttribute(): string
    {
        return $this->approved_amount ? number_format($this->approved_amount, 2) . ' ' . $this->currency : 'N/A';
    }

    /**
     * Get the refund status badge color.
     */
    public function getStatusColorAttribute(): string
    {
        return match ($this->status) {
            'pending' => 'warning',
            'approved' => 'info',
            'partially_approved' => 'info',
            'rejected' => 'danger',
            'processed' => 'success',
            'failed' => 'danger',
            default => 'secondary',
        };
    }

    /**
     * Get the refund status label.
     */
    public function getStatusLabelAttribute(): string
    {
        return match ($this->status) {
            'pending' => 'Pending',
            'approved' => 'Approved',
            'partially_approved' => 'Partially Approved',
            'rejected' => 'Rejected',
            'processed' => 'Processed',
            'failed' => 'Failed',
            default => 'Unknown',
        };
    }

    /**
     * Get the approval percentage.
     */
    public function getApprovalPercentageAttribute(): float
    {
        if ($this->amount <= 0) {
            return 0;
        }

        if ($this->isPartiallyApproved() && $this->approved_amount) {
            return ($this->approved_amount / $this->amount) * 100;
        }

        return $this->isApproved() ? 100 : 0;
    }

    /**
     * Approve the refund.
     */
    public function approve($approvedBy, $approvedAmount = null): bool
    {
        if (!$this->canBeApproved() && !$this->canBePartiallyApproved()) {
            return false;
        }

        $status = $approvedAmount && $approvedAmount < $this->amount ? 'partially_approved' : 'approved';

        $this->update([
            'status' => $status,
            'approved_amount' => $approvedAmount ?? $this->amount,
            'processed_by' => $approvedBy,
            'processed_at' => now(),
        ]);

        return true;
    }

    /**
     * Reject the refund.
     */
    public function reject($rejectedBy, $rejectionReason): bool
    {
        if (!$this->canBeRejected()) {
            return false;
        }

        $this->update([
            'status' => 'rejected',
            'rejection_reason' => $rejectionReason,
            'rejected_by' => $rejectedBy,
            'rejected_at' => now(),
        ]);

        return true;
    }

    /**
     * Mark the refund as processed.
     */
    public function markAsProcessed($gatewayRefundId = null, $gatewayName = null): bool
    {
        if (!$this->canBeProcessed()) {
            return false;
        }

        $this->update([
            'status' => 'processed',
            'gateway_refund_id' => $gatewayRefundId,
            'gateway_name' => $gatewayName,
        ]);

        return true;
    }

    /**
     * Mark the refund as failed.
     */
    public function markAsFailed(): bool
    {
        if (!$this->canBeProcessed()) {
            return false;
        }

        $this->update([
            'status' => 'failed',
        ]);

        return true;
    }
}
