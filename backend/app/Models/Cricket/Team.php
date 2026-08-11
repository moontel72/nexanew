<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Team extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_teams';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'tournament_id',
        'name',
        'team_code',
        'short_code',
        'logo_url',
        'captain_name',
        'home_city',
        'primary_color',
        'details',
        'status',
    ];

    protected $casts = [
        'status' => 'string',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Team $team): void {
            if (empty($team->id)) {
                $team->id = (string) Str::orderedUuid();
            }
            if (empty($team->team_code)) {
                $team->team_code = self::generateUniqueCode();
            }
        });
    }

    private static function generateUniqueCode(): string
    {
        do {
            $code = str_pad((string) random_int(0, 999), 3, '0', STR_PAD_LEFT);
        } while (self::where('team_code', $code)->withTrashed()->exists());

        return $code;
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function players()
    {
        return $this->hasMany(Player::class);
    }
}
