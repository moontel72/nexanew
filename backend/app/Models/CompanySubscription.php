<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CompanySubscription extends Model
{
    use HasFactory;

    protected $table = 'company_subscriptions';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'company_id',
        'plan_id',
        'billing_cycle',
        'start_date',
        'end_date',
        'renewal_date',
        'auto_renew',
        'payment_method',
        'payment_status',
        'last_payment_date',
        'next_payment_date',
        'current_unit_codes_used',
        'current_packet_codes_used',
        'current_carton_codes_used',
        'current_bundle_codes_used',
        'status',
        'cancellation_reason',
        'cancelled_at',
        'metadata',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'renewal_date' => 'date',
        'auto_renew' => 'boolean',
        'last_payment_date' => 'date',
        'next_payment_date' => 'date',
        'cancelled_at' => 'datetime',
        'metadata' => 'array',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }
}
