<?php

namespace App\Models\Marketplace;

use App\Models\Company;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PoolParticipant extends Model
{
    protected $table = 'marketplace_pool_participants';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_COMMITTED = 'committed';
    public const STATUS_CONFIRMED = 'confirmed';
    public const STATUS_PAID = 'paid';
    public const STATUS_WITHDRAWN = 'withdrawn';

    protected $fillable = [
        'id', 'pool_id', 'participant_company_id',
        'committed_quantity', 'committed_amount',
        'participation_status', 'withdrawn_at', 'withdrawal_reason',
    ];

    protected $casts = [
        'committed_quantity' => 'integer',
        'committed_amount' => 'float',
        'withdrawn_at' => 'datetime',
    ];

    // ─── Relationships ──────────────────────────────────

    public function pool(): BelongsTo
    {
        return $this->belongsTo(GroupBuyPool::class, 'pool_id');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class, 'participant_company_id');
    }
}
