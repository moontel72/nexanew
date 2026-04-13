<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubscriptionPlan extends Model
{
    use HasFactory;

    protected $table = 'subscription_plans';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'type',
        'description',
        'monthly_price',
        'yearly_price',
        'setup_fee',
        'currency',
        'monthly_unit_codes',
        'monthly_packet_codes',
        'monthly_carton_codes',
        'monthly_bundle_codes',
        'max_users',
        'max_stores',
        'max_drivers',
        'features',
        'is_custom',
        'is_recommended',
        'status',
        'company_count',
        'metadata',
        'archived_at',
    ];

    protected $casts = [
        'monthly_price' => 'decimal:2',
        'yearly_price' => 'decimal:2',
        'setup_fee' => 'decimal:2',
        'features' => 'array',
        'is_custom' => 'boolean',
        'is_recommended' => 'boolean',
        'metadata' => 'array',
        'archived_at' => 'datetime',
    ];

    public function subscriptions()
    {
        return $this->hasMany(CompanySubscription::class, 'plan_id');
    }
}
