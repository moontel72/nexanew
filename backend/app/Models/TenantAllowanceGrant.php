<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

/**
 * Wave 3 — Step 3.3: Tenant Allowance Grant (Flat B-Tree Projection)
 *
 * Per Section 10.4.3 — Hot read path for VendorAllowanceShield middleware.
 *
 * Each row represents a single permission key with its level,
 * auto-materialized from tenant_allowance_matrix JSONB on save.
 *
 * Lookup is O(log n) via composite B-tree index on
 * (owner_identity_id, permission_key) WHERE is_active = TRUE.
 */
class TenantAllowanceGrant extends Model
{
    protected $table = 'tenant_allowance_grants';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'matrix_id',
        'owner_identity_id',
        'carrier_company_id',
        'permission_key',
        'permission_level',
        'is_active',
        'expires_at',
    ];

    protected $casts = [
        'is_active'  => 'boolean',
        'expires_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();
        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = (string) Str::orderedUuid();
            }
        });
    }

    // ─── Relationships ───────────────────────────────────────

    public function matrix()
    {
        return $this->belongsTo(TenantAllowanceMatrix::class, 'matrix_id');
    }

    // ─── Scopes ──────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            });
    }

    // ─── Static Lookup (Section 10.4.5 step 2) ───────────────

    private const REDIS_CACHE_PREFIX = 'allowance:resolve:';
    private const REDIS_CACHE_TTL = 60; // seconds

    /**
     * Resolve the permission level for a (owner, carrier, key) triple.
     *
     * F-5 Fix: Wrapped in 60-second Redis cache to prevent repeated
     * cross-tenant requests from hammering the PostgreSQL B-tree index.
     *
     * Single O(log n) B-tree probe. Returns 'hidden' if no grant found.
     */
    public static function resolveLevel(
        string $ownerIdentityId,
        string $carrierCompanyId,
        string $permissionKey
    ): string {
        $cacheKey = self::REDIS_CACHE_PREFIX . md5("{$ownerIdentityId}|{$carrierCompanyId}|{$permissionKey}");

        $cached = \Illuminate\Support\Facades\Redis::get($cacheKey);
        if ($cached !== null) {
            return $cached;
        }

        $grant = static::where('owner_identity_id', $ownerIdentityId)
            ->where('carrier_company_id', $carrierCompanyId)
            ->where('permission_key', $permissionKey)
            ->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            })
            ->select('permission_level')
            ->first();

        $level = $grant ? $grant->permission_level : 'hidden';

        \Illuminate\Support\Facades\Redis::setex($cacheKey, self::REDIS_CACHE_TTL, $level);

        return $level;
    }
}
