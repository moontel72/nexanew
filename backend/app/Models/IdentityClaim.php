<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Wave 1 — Multi-Claim Identity Ledger (Section 10.1.3)
 *
 * Revocable surface for contact channels and credentials.
 * Handles recycled SIM cards and dual CNIC formats through
 * soft-revocation (is_revoked flag) — rows are never hard-deleted.
 *
 * Normalization rules (Section 10.1.5 step 2):
 *   - phone:      strip non-digits, preserve leading '+'
 *   - email:      lowercase, trim
 *   - cnic_old:   strip non-digits (13-digit format)
 *   - cnic_new:   strip dashes (12345-1234567-1 format)
 *   - passport:   uppercase, trim
 *   - driving_license: uppercase, trim
 */
class IdentityClaim extends Model
{
    protected $table = 'identity_claims';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'global_identity_id',
        'claim_type',
        'claim_value',
        'claim_value_hash',
        'is_primary',
        'is_revoked',
        'revoked_at',
        'revoked_reason',
        'verified_via',
        'verified_at',
    ];

    protected $casts = [
        'is_primary'    => 'boolean',
        'is_revoked'    => 'boolean',
        'revoked_at'    => 'datetime',
        'verified_at'   => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = $model->id ?? (string) Str::orderedUuid();
            }
            if (!empty($model->claim_value) && empty($model->claim_value_hash)) {
                $model->claim_value_hash = hash('sha256', strtolower($model->claim_value), true);
            }
        });

        static::updating(function (self $model) {
            if ($model->isDirty('claim_value') && !empty($model->claim_value)) {
                $model->claim_value_hash = hash('sha256', strtolower($model->claim_value), true);
            }
        });
    }

    // ─── Relationships ───────────────────────────────────────

    public function globalIdentity()
    {
        return $this->belongsTo(GlobalIdentity::class, 'global_identity_id');
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_revoked', false);
    }

    public function scopeRevoked($query)
    {
        return $query->where('is_revoked', true);
    }

    public function scopeByType($query, string $type)
    {
        return $query->where('claim_type', $type);
    }

    public function scopePrimary($query)
    {
        return $query->where('is_primary', true);
    }

    public function scopeVerified($query)
    {
        return $query->whereNotNull('verified_at');
    }

    // ─── Actions ─────────────────────────────────────────────

    /**
     * Soft-revoke this claim (e.g., SIM recycled, email changed).
     * The row is preserved for audit trail; a new claim can be
     * created for the same value on a different identity.
     */
    public function revoke(string $reason): void
    {
        $this->update([
            'is_revoked'      => true,
            'revoked_at'      => now(),
            'revoked_reason'  => $reason,
            'is_primary'      => false,
        ]);
    }

    /**
     * Mark this claim as verified through a specific method.
     */
    public function markVerified(string $via): void
    {
        $this->update([
            'verified_via' => $via,
            'verified_at'  => now(),
        ]);
    }

    /**
     * Promote to primary for this identity+claim_type combination.
     * Demotes any existing primary first.
     */
    public function promoteToPrimary(): void
    {
        \Illuminate\Support\Facades\DB::transaction(function () {
            static::where('global_identity_id', $this->global_identity_id)
                ->where('claim_type', $this->claim_type)
                ->where('is_primary', true)
                ->update(['is_primary' => false]);

            $this->update(['is_primary' => true]);
        });
    }

    // ─── Static Normalization ────────────────────────────────

    /**
     * Normalize a claim value for consistent lookup.
     * Implements Section 10.1.5 step 2.
     */
    public static function normalize(string $claimType, string $value): string
    {
        return match ($claimType) {
            'phone'            => preg_replace('/[^0-9+]/', '', $value),
            'email'            => strtolower(trim($value)),
            'cnic_old'         => preg_replace('/[^0-9]/', '', $value),
            'cnic_new'         => preg_replace('/[^0-9]/', '', $value),
            'passport'         => strtoupper(trim($value)),
            'driving_license'  => strtoupper(trim($value)),
            'biometric_hash'   => trim($value),
            'oauth_google'     => trim($value),
            'oauth_apple'      => trim($value),
            'device_fingerprint' => trim($value),
            default            => trim($value),
        };
    }
}
