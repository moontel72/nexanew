<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class BestXi extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_best_xi';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'tournament_id', 'match_id',
        'team_label', 'selections',
        'curated_by_identity_id',
    ];

    protected $casts = [
        'selections' => 'array',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (BestXi $xi): void {
            if (empty($xi->id)) {
                $xi->id = (string) Str::orderedUuid();
            }
        });
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }
}
