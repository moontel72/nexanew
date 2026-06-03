<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

/**
 * Wave 2 — Fleet Assignment State Machine
 *
 * Binds a global identity to a carrier company with a specific role.
 * Implements race-condition guard via PostgreSQL partial unique index.
 *
 * State transitions:
 *   pending_acceptance → accept() → active
 *   active → unassign(reason) → unassigned
 *   active → suspend() → suspended → reactivate() → active
 *   pending_acceptance → unassign(reason) → unassigned
 */
class FleetAssignment extends Model
{
    protected $table = 'fleet_assignments';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'global_identity_id',
        'carrier_company_id',
        'role',
        'fleet_type',
        'status',
        'assignment_meta',
        'accepted_at',
        'unassigned_at',
        'unassign_reason',
    ];

    protected $casts = [
        'assignment_meta' => 'array',
        'accepted_at'     => 'datetime',
        'unassigned_at'   => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = $model->id ?? (string) Str::orderedUuid();
            }
        });
    }

    // ─── Relationships ───────────────────────────────────────

    public function globalIdentity()
    {
        return $this->belongsTo(GlobalIdentity::class, 'global_identity_id');
    }

    public function carrierCompany()
    {
        return $this->belongsTo(\App\Models\Company::class, 'carrier_company_id');
    }

    // ─── State Transitions ──────────────────────────────────

    /**
     * Accept a pending assignment. Only valid from 'pending_acceptance'.
     */
    public function accept(): void
    {
        if ($this->status !== 'pending_acceptance') {
            throw new \RuntimeException(
                "Cannot accept assignment in '{$this->status}' status. Only 'pending_acceptance' can be accepted."
            );
        }
        $this->update([
            'status'      => 'active',
            'accepted_at' => now(),
        ]);
    }

    /**
     * Unassign (terminate) an active or pending assignment.
     */
    public function unassign(string $reason): void
    {
        if (!in_array($this->status, ['active', 'pending_acceptance'], true)) {
            throw new \RuntimeException(
                "Cannot unassign assignment in '{$this->status}' status."
            );
        }
        $this->update([
            'status'          => 'unassigned',
            'unassigned_at'   => now(),
            'unassign_reason' => $reason,
        ]);
    }

    /**
     * Suspend an active assignment.
     */
    public function suspend(): void
    {
        if ($this->status !== 'active') {
            throw new \RuntimeException(
                "Cannot suspend assignment in '{$this->status}' status. Only 'active' can be suspended."
            );
        }
        $this->update(['status' => 'suspended']);
    }

    /**
     * Reactivate a suspended assignment.
     */
    public function reactivate(): void
    {
        if ($this->status !== 'suspended') {
            throw new \RuntimeException(
                "Cannot reactivate assignment in '{$this->status}' status. Only 'suspended' can be reactivated."
            );
        }
        $this->update(['status' => 'active']);
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending_acceptance');
    }

    public function scopeByRole($query, string $role)
    {
        return $query->where('role', $role);
    }

    public function scopeByFleetType($query, string $type)
    {
        return $query->where('fleet_type', $type);
    }

    public function scopeByCompany($query, string $companyId)
    {
        return $query->where('carrier_company_id', $companyId);
    }

    public function scopeActiveOrPending($query)
    {
        return $query->whereIn('status', ['active', 'pending_acceptance']);
    }

    // ─── Helpers ─────────────────────────────────────────────

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isPendingAcceptance(): bool
    {
        return $this->status === 'pending_acceptance';
    }

    /**
     * Check if identity already has a conflicting active assignment.
     * Used before creating a new assignment to provide early validation
     * (the DB partial unique index is the ultimate guard).
     */
    public static function hasConflictingAssignment(string $globalIdentityId, string $role): bool
    {
        return static::where('global_identity_id', $globalIdentityId)
            ->where('role', $role)
            ->whereIn('status', ['active', 'pending_acceptance'])
            ->exists();
    }
}
