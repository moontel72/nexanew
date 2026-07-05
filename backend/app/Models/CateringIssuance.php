<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CateringIssuance extends Model
{
    protected $table = 'catering_issuances';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'storekeeper_id',
        'trip_id',
        'route_id',
        'bus_reg_number',
        'conductor_name',
        'bundle_id',
        'packet_id',
        'status',
        'notes',
        'issued_at',
        'reconciled_at',
    ];

    protected $casts = [
        'issued_at'      => 'datetime',
        'reconciled_at'  => 'datetime',
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

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function storekeeper()
    {
        return $this->belongsTo(StoreKeeper::class, 'storekeeper_id');
    }

    public function trip()
    {
        return $this->belongsTo(\App\Models\Transport\BusTrip::class, 'trip_id');
    }

    public function items()
    {
        return $this->hasMany(CateringIssuanceItem::class, 'issuance_id');
    }

    public function reconciliation()
    {
        return $this->hasOne(CateringReconciliation::class, 'issuance_id');
    }

    public function scopeForCompany($query, string $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeActive($query)
    {
        return $query->whereIn('status', ['pending', 'issued', 'partially_returned']);
    }

    public function markIssued(): void
    {
        $this->update(['status' => 'issued', 'issued_at' => now()]);
    }

    public function markReconciled(): void
    {
        $this->update(['status' => 'reconciled', 'reconciled_at' => now()]);
    }
}
