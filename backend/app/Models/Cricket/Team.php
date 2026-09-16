<?php

namespace App\Models\Cricket;

use App\Services\Cricket\CricketDataCleanupService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Log;
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

        // A team's display name is embedded in two surfaces that outlive the
        // row: the cached `full_snapshot` of every live score (which the
        // media engine republishes verbatim to the Studio lower-third) and
        // the SRS/overlay state keyed by match id. Renaming a team — or
        // moving it to Trash — must therefore flush those caches, otherwise
        // the overlay keeps burning the previous name indefinitely.
        static::saved(function (Team $team): void {
            $team->flushFixtureSnapshots();
        });

        static::softDeleted(function (Team $team): void {
            $team->flushFixtureSnapshots();
        });

        static::restored(function (Team $team): void {
            $team->flushFixtureSnapshots();
        });
    }

    /**
     * Flushes the cached live snapshot of every fixture this team plays in.
     *
     * Delegates to the cleanup service so the flush semantics (score cache
     * + active-match pointer + overlay clear) live in exactly one place.
     * Non-fatal by design: cache maintenance must never break a team save.
     */
    private function flushFixtureSnapshots(): void
    {
        try {
            $matchIds = MatchModel::withTrashed()
                ->where('team_a_id', $this->id)
                ->orWhere('team_b_id', $this->id)
                ->pluck('id')
                ->all();

            if (empty($matchIds)) {
                return;
            }

            $cleanup = app(CricketDataCleanupService::class);
            foreach ($matchIds as $matchId) {
                $cleanup->flushMatchCaches((string) $matchId);
            }
        } catch (\Throwable $e) {
            Log::warning('Cricket: team fixture cache flush failed (non-critical)', [
                'team_id' => $this->id,
                'error' => $e->getMessage(),
            ]);
        }
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
