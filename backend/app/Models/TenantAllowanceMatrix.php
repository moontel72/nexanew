<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Wave 3 — Step 3.2: Tenant Allowance Matrix (Canonical Layer)
 *
 * Per Section 10.4.2 — Authoring surface for cross-tenant data sharing.
 *
 * Bus/Truck owners define what carrier companies can access.
 * The permissions_blob JSONB holds semantic flags that are
 * materialized into tenant_allowance_grants flat rows on save.
 *
 * Auto-sync observer: any create/update triggers a transactional
 * DELETE-then-INSERT sweep of the flat projection table.
 */
class TenantAllowanceMatrix extends Model
{
    protected $table = 'tenant_allowance_matrix';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'owner_identity_id',
        'carrier_company_id',
        'permissions_blob',
        'status',
        'expires_at',
    ];

    protected $casts = [
        'permissions_blob' => 'array',
        'expires_at'       => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function (self $model) {
            if (empty($model->id)) {
                $model->id = (string) Str::orderedUuid();
            }
        });

        // After any save, sync the flat projection
        static::saved(function (self $model) {
            $model->syncProjection();
        });

        // After delete, remove projection rows (cascade handles this, but be explicit)
        static::deleted(function (self $model) {
            DB::table('tenant_allowance_grants')
                ->where('matrix_id', $model->id)
                ->delete();
        });
    }

    // ─── Relationships ───────────────────────────────────────

    public function owner()
    {
        return $this->belongsTo(GlobalIdentity::class, 'owner_identity_id');
    }

    public function grants()
    {
        return $this->hasMany(TenantAllowanceGrant::class, 'matrix_id');
    }

    // ─── Projection Sync (Section 10.4.4) ────────────────────

    /**
     * Materialize the JSONB permissions_blob into flat tenant_allowance_grants rows.
     *
     * Algorithm:
     *   1. DELETE all existing grant rows for this matrix_id
     *   2. Flatten permissions_blob into (key, level) pairs
     *   3. INSERT each pair as a tenant_allowance_grants row
     *
     * Runs inside a DB transaction for atomicity.
     */
    public function syncProjection(): void
    {
        DB::transaction(function () {
            // 1. Purge existing projection
            DB::table('tenant_allowance_grants')
                ->where('matrix_id', $this->id)
                ->delete();

            // 2. Flatten JSONB blob
            $blob = $this->permissions_blob;
            if (!is_array($blob) || empty($blob)) {
                return;
            }

            $isActive = $this->status === 'active'
                && ($this->expires_at === null || $this->expires_at->isFuture());

            $rows = [];
            foreach ($blob as $key => $level) {
                $rows[] = [
                    'id'                => (string) Str::orderedUuid(),
                    'matrix_id'         => $this->id,
                    'owner_identity_id'  => $this->owner_identity_id,
                    'carrier_company_id' => $this->carrier_company_id,
                    'permission_key'     => $key,
                    'permission_level'   => $this->normalizeLevel($level),
                    'is_active'          => $isActive,
                    'expires_at'         => $this->expires_at,
                    'created_at'         => now(),
                    'updated_at'         => now(),
                ];
            }

            // 3. Batch insert
            if (!empty($rows)) {
                DB::table('tenant_allowance_grants')->insert($rows);
            }
        });
    }

    /**
     * Normalize a permission level string to one of the 5 canonical levels.
     */
    private function normalizeLevel(string $level): string
    {
        $valid = ['full', 'view', 'aggregate', 'redacted', 'hidden'];
        $level = strtolower(trim($level));
        return in_array($level, $valid, true) ? $level : 'hidden';
    }
}
