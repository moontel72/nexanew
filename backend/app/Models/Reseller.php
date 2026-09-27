<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\SoftDeletes;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Support\Facades\Hash;

class Reseller extends Authenticatable
{
    use HasApiTokens, HasFactory, SoftDeletes;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'business_name',
        'registration_no',
        'email',
        'phone',
        'password',
        'city',
        'address',
        'status',
        'plan_name',
        'suspended_at',
        'suspended_reason',
        'purchase_approved',
        'business_proof_url',
        'business_proof_title',
        'business_proof_uploaded_at',
        // Group-Incharge C2b — which Sub-Admin created this account (NULL = platform-created).
        'created_by_sub_admin_id',
    ];

    protected $hidden = ['password'];

    protected $casts = [
        'suspended_at' => 'datetime',
        'purchase_approved' => 'boolean',
        'business_proof_uploaded_at' => 'datetime',
    ];

    // Auto-hash password
    public function setPasswordAttribute($value)
    {
        if (!empty($value)) {
            $this->attributes['password'] = Hash::make($value);
        }
    }

    // Boot: auto-generate UUID
    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) \Illuminate\Support\Str::uuid();
            }
        });
    }
}
