<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class TenantAccount extends Model
{
    use HasApiTokens;
    public $incrementing = false;
    protected $keyType = 'string';
    protected $table = 'tenant_accounts';

    protected $fillable = [
        'id', 'parent_account_id', 'account_name', 'email', 'password',
        'phone_number', 'is_independent', 'account_type', 'status', 'metadata',
    ];

    protected $hidden = ['password'];
    protected $casts = ['is_independent' => 'bool', 'metadata' => 'array'];

    protected static function boot()
    {
        parent::boot();
        static::creating(fn ($m) => $m->id = (string) Str::uuid());
    }

    public function parent()
    {
        return $this->belongsTo(TenantAccount::class, 'parent_account_id');
    }

    public function children()
    {
        return $this->hasMany(TenantAccount::class, 'parent_account_id');
    }

    public function shiftAllocations()
    {
        return $this->hasMany(\App\Models\BusShiftAllocation::class, 'tenant_account_id');
    }

    /** Returns all tenant IDs in this hierarchy (self + descendants). */
    public function getAllTenantIds(): array
    {
        $ids = [$this->id];
        foreach ($this->children as $child) {
            $ids = array_merge($ids, $child->getAllTenantIds());
        }
        return $ids;
    }

    /** Scope: root accounts only (no parent). */
    public function scopeRoot($query)
    {
        return $query->whereNull('parent_account_id');
    }
}
