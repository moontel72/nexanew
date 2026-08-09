<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Player extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_players';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'team_id',
        'name',
        'jersey_number',
        'role',
        'batting_style',
        'bowling_style',
        'photo_url',
        'is_captain',
        'is_wicket_keeper',
    ];

    protected $casts = [
        'is_captain' => 'boolean',
        'is_wicket_keeper' => 'boolean',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Player $player): void {
            if (empty($player->id)) {
                $player->id = (string) Str::orderedUuid();
            }
        });
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }
}
