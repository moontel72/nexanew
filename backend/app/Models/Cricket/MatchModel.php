<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class MatchModel extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_matches';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'tournament_id',
        'team_a_id',
        'team_b_id',
        'venue',
        'ground_id',
        'stage',
        'scheduled_at',
        'match_type',
        'overs_per_side',
        'status',
        'toss_winner_team_id',
        'toss_decision',
        'current_batting_team_id',
        'current_bowling_team_id',
        'current_innings_number',
        'match_result',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'overs_per_side' => 'integer',
        'current_innings_number' => 'integer',
        'match_result' => 'array',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (MatchModel $match): void {
            if (empty($match->id)) {
                $match->id = (string) Str::orderedUuid();
            }
        });
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    /**
     * Fixture sides resolve *including* trashed teams.
     *
     * Teams keep a Trash flow (soft delete → restore), so `deleted_at` on a
     * team means "retired", not "garbage". The default belongsTo applies the
     * SoftDeletes global scope, which nulls the relation the moment a team
     * moves to Trash — and every consumer that renders `team_a.name vs
     * team_b.name` then falls back to a placeholder. That is precisely how a
     * live fixture ended up rendering as `T1 vs T2 (in_progress)` after the
     * old teams were retired and the new ones registered.
     *
     * Reads stay lenient (`withTrashed`), writes stay strict: team ids are
     * validated against the live `cricket_teams` scope in MatchController, so
     * a retired team can never be newly assigned to a fixture.
     */
    public function teamA()
    {
        return $this->belongsTo(Team::class, 'team_a_id')->withTrashed();
    }

    public function teamB()
    {
        return $this->belongsTo(Team::class, 'team_b_id')->withTrashed();
    }

    public function ground()
    {
        return $this->belongsTo(Ground::class, 'ground_id');
    }

    public function innings()
    {
        return $this->hasMany(Innings::class, 'match_id')->orderBy('innings_number');
    }

    public function liveScore()
    {
        return $this->hasOne(LiveScore::class, 'match_id');
    }

    public function commentary()
    {
        return $this->hasMany(Commentary::class, 'match_id')->orderBy('ball_number', 'desc');
    }

    public function streams()
    {
        return $this->hasMany(StreamEndpoint::class, 'match_id');
    }

    public function matchManagers()
    {
        return $this->hasMany(MatchManager::class, 'match_id');
    }

    public function matchSponsors()
    {
        return $this->hasMany(MatchSponsor::class, 'match_id');
    }

    public function squads()
    {
        return $this->hasMany(MatchSquad::class, 'match_id');
    }
}
