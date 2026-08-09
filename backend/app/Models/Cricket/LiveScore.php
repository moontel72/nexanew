<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class LiveScore extends Model
{
    protected $table = 'cricket_live_scores';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'current_innings_id',
        'batting_team_name',
        'bowling_team_name',
        'runs',
        'wickets',
        'overs',
        'target',
        'current_run_rate',
        'required_run_rate',
        'striker_name',
        'striker_runs',
        'striker_balls',
        'non_striker_name',
        'non_striker_runs',
        'non_striker_balls',
        'bowler_name',
        'bowler_overs',
        'bowler_runs_conceded',
        'bowler_wickets',
        'last_ball_result',
        'last_wicket_info',
        'partnership_runs',
        'partnership_balls',
        'recent_overs_summary',
        'full_snapshot',
        'updated_by_cricket_manager_id',
    ];

    protected $casts = [
        'runs' => 'integer',
        'wickets' => 'integer',
        'overs' => 'float',
        'target' => 'integer',
        'current_run_rate' => 'float',
        'required_run_rate' => 'float',
        'striker_runs' => 'integer',
        'striker_balls' => 'integer',
        'non_striker_runs' => 'integer',
        'non_striker_balls' => 'integer',
        'bowler_overs' => 'float',
        'bowler_runs_conceded' => 'integer',
        'bowler_wickets' => 'integer',
        'partnership_runs' => 'integer',
        'partnership_balls' => 'integer',
        'full_snapshot' => 'array',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (LiveScore $score): void {
            if (empty($score->id)) {
                $score->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }
}
