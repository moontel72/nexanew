<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Reseller extends Model
{
    use HasFactory, SoftDeletes;

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
        'plan_id',
        'plan_name',
        'suspended_at',
        'suspended_reason',
        'purchase_approved',
        'business_proof_url',
        'business_proof_title',
        'business_proof_uploaded_at',
    ];

    protected $casts = [
        'suspended_at' => 'datetime',
        'purchase_approved' => 'boolean',
        'business_proof_uploaded_at' => 'datetime',
    ];

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
