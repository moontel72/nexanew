<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

/**
 * Cricket match squad — playing XI / bench selection per team per match.
 *
 * Phase 0 foundation for batting-order tracking, opening-batter selection,
 * and the live scorer's "next batter" flow.
 */
class MatchSquad extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_match_squads';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'team_id',
        'player_id',
        'batting_order',
        'status',
    ];

    protected $casts = [
        'batting_order' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (MatchSquad $squad): void {
            if (empty($squad->id)) {
                $squad->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function team()
    {
        return $this->belongsTo(Team::class, 'team_id');
    }

    public function player()
    {
        return $this->belongsTo(Player::class, 'player_id');
    }
}
