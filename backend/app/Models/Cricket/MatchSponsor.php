<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class MatchSponsor extends Model
{
    protected $table = 'cricket_match_sponsors';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'sponsor_id',
        'placement',
        'is_active',
        'display_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'display_order' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (MatchSponsor $ms): void {
            if (empty($ms->id)) {
                $ms->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function sponsor()
    {
        return $this->belongsTo(Sponsor::class, 'sponsor_id');
    }
}
