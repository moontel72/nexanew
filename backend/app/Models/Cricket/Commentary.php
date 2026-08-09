<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Commentary extends Model
{
    protected $table = 'cricket_commentary';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'ball_number',
        'over_number',
        'commentary_text',
        'event_type',
        'cricket_manager_id',
    ];

    protected $casts = [
        'ball_number' => 'integer',
        'over_number' => 'float',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Commentary $c): void {
            if (empty($c->id)) {
                $c->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function cricketManager()
    {
        return $this->belongsTo(CricketManager::class, 'cricket_manager_id');
    }
}
