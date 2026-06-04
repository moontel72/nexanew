<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Wave 1 — Global Identity Spine (Section 10.1.2)
 *
 * Immutable core per real person/entity. The id never changes.
 * password_hash supports bcrypt/argon2 verification.
 * identity_token has semantic prefixes per type.
 */
class GlobalIdentity extends Model
{
    protected $table = 'global_identities';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'identity_token',
        'display_name',
        'password',
        'password_hash',
        'kyc_status',
        'kyc_tier',
        'status',
        'identity_type',
        'risk_score',
        'primary_locale',
    ];

    protected $hidden = ['password_hash'];

    protected $casts = [
        'kyc_tier'   => 'integer',
        'risk_score' => 'float',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = (string) Str::orderedUuid();
            }
            if (empty($model->identity_token)) {
                $model->identity_token = self::generateToken($model->identity_type);
            }
        });
    }

    // ─── Relationships ───────────────────────────────────────

    public function claims()
    {
        return $this->hasMany(IdentityClaim::class, 'global_identity_id');
    }

    public function activeClaims()
    {
        return $this->hasMany(IdentityClaim::class, 'global_identity_id')->where('is_revoked', false);
    }

    public function fleetAssignments()
    {
        return $this->hasMany(FleetAssignment::class, 'global_identity_id');
    }

    public function activeFleetAssignments()
    {
        return $this->hasMany(FleetAssignment::class, 'global_identity_id')
            ->whereIn('status', ['active', 'pending_acceptance']);
    }

    // ─── Password ────────────────────────────────────────────

    public function setPasswordAttribute(string $value): void
    {
        $this->attributes['password_hash'] = Hash::make($value);
    }

    public function verifyPassword(string $plain): bool
    {
        if (empty($this->password_hash)) {
            return false;
        }
        return Hash::check($plain, $this->password_hash);
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeKycVerified($query)
    {
        return $query->where('kyc_status', 'verified');
    }

    public function scopeByKycTier($query, int $minTier)
    {
        return $query->where('kyc_tier', '>=', $minTier);
    }

    public function scopeByType($query, string $type)
    {
        return $query->where('identity_type', $type);
    }

    // ─── Status checks ───────────────────────────────────────

    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isSuspended(): bool
    {
        return $this->status === 'suspended';
    }

    public function isFrozen(): bool
    {
        return $this->status === 'frozen';
    }

    public function isDeleted(): bool
    {
        return $this->status === 'deleted';
    }

    // ─── Token generation ────────────────────────────────────

    public static function generateToken(?string $identityType = null): string
    {
        $prefix = match ($identityType) {
            'driver'    => 'TRC-DR-',
            'owner'     => 'TRC-OW-',
            'conductor' => 'TRC-CO-',
            'mixed'     => 'TRC-MX-',
            'customer'  => 'TRC-CU-',
            default     => 'TRC-GL-',
        };
        return $prefix . strtoupper(Str::random(5));
    }
}
