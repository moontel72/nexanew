<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CateringReconciliation extends Model
{
    protected $table = 'catering_reconciliations';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'company_id',
        'issuance_id',
        'storekeeper_id',
        'total_issued_value_paisa',
        'total_returned_value_paisa',
        'total_sold_value_paisa',
        'total_wasted_value_paisa',
        'total_staff_value_paisa',
        'total_complimentary_value_paisa',
        'variance_paisa',
        'status',
        'notes',
        'reconciled_at',
    ];

    protected $casts = [
        'total_issued_value_paisa'   => 'integer',
        'total_returned_value_paisa' => 'integer',
        'total_sold_value_paisa'     => 'integer',
        'total_wasted_value_paisa'       => 'integer',
        'total_staff_value_paisa'        => 'integer',
        'total_complimentary_value_paisa' => 'integer',
        'variance_paisa'             => 'integer',
        'reconciled_at'              => 'datetime',
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

    public function issuance()
    {
        return $this->belongsTo(CateringIssuance::class, 'issuance_id');
    }

    public function storekeeper()
    {
        return $this->belongsTo(StoreKeeper::class, 'storekeeper_id');
    }

    public function scopeForCompany($query, string $companyId)
    {
        return $query->where('company_id', $companyId);
    }

    public function scopeDraft($query)
    {
        return $query->where('status', 'draft');
    }

    public function confirm(): void
    {
        $this->update(['status' => 'confirmed', 'reconciled_at' => now()]);
    }

    public function dispute(): void
    {
        $this->update(['status' => 'disputed']);
    }
}
