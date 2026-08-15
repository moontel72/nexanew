<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Innings extends Model
{
    protected $table = 'cricket_innings';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'innings_number',
        'batting_team_id',
        'bowling_team_id',
        'total_runs',
        'total_wickets',
        'total_overs',
        'total_balls',
        'extras_wides',
        'extras_no_balls',
        'extras_byes',
        'extras_leg_byes',
        'extras_penalty',
        'deliveries',
        'batting_scorecard',
        'bowling_scorecard',
        'status',
        'fall_of_wickets',
        'current_striker_id',
        'current_non_striker_id',
        'current_bowler_id',
        'is_super_over',
        'overs_limit',
    ];

    protected $casts = [
        'innings_number' => 'integer',
        'total_runs' => 'integer',
        'total_wickets' => 'integer',
        'total_overs' => 'float',
        'total_balls' => 'integer',
        'extras_wides' => 'integer',
        'extras_no_balls' => 'integer',
        'extras_byes' => 'integer',
        'extras_leg_byes' => 'integer',
        'extras_penalty' => 'integer',
        'deliveries' => 'array',
        'batting_scorecard' => 'array',
        'bowling_scorecard' => 'array',
        'fall_of_wickets' => 'array',
        'is_super_over' => 'boolean',
        'overs_limit' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Innings $innings): void {
            if (empty($innings->id)) {
                $innings->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function battingTeam()
    {
        return $this->belongsTo(Team::class, 'batting_team_id');
    }

    public function bowlingTeam()
    {
        return $this->belongsTo(Team::class, 'bowling_team_id');
    }

    /**
     * Append a delivery ball to the innings.
     */
    public function appendDelivery(array $ballData): void
    {
        $deliveries = $this->deliveries ?? [];
        $deliveries[] = $ballData;
        $this->deliveries = $deliveries;
    }
}
