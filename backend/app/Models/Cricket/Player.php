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
        'email',
        'phone',
        'id_card_number',
        'date_of_birth',
        'player_code',
        'jersey_number',
        'role',
        'batting_style',
        'bowling_style',
        'photo_url',
        'is_captain',
        'is_wicket_keeper',
        'position',
        'status',
    ];

    protected $casts = [
        'is_captain' => 'boolean',
        'is_wicket_keeper' => 'boolean',
        'date_of_birth' => 'date',
        'status' => 'string',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Player $player): void {
            if (empty($player->id)) {
                $player->id = (string) Str::orderedUuid();
            }
            if (empty($player->player_code)) {
                $player->player_code = self::generateUniqueCode();
            }
        });
    }

    private static function generateUniqueCode(): string
    {
        do {
            $code = str_pad((string) random_int(0, 999), 3, '0', STR_PAD_LEFT);
        } while (self::where('player_code', $code)->withTrashed()->exists());

        return $code;
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }
}
