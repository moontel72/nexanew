<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class PlayerCareerStats extends Model
{
    protected $table = 'cricket_player_career_stats';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'player_id', 'club_id',
        // Batting
        'total_matches', 'total_innings', 'total_runs',
        'not_outs', 'highest_score', 'highest_score_not_out',
        'batting_average', 'balls_faced', 'batting_strike_rate',
        'centuries', 'half_centuries', 'fours', 'sixes',
        // Bowling
        'total_wickets', 'bowling_average', 'best_bowling_figures',
        'economy_rate', 'maidens', 'overs_bowled_career',
        'five_wicket_hauls', 'runs_conceded',
        // Fielding
        'catches', 'run_outs', 'stumpings',
        // Form
        'recent_scores',
    ];

    protected $casts = [
        'total_matches' => 'integer',
        'total_innings' => 'integer',
        'total_runs' => 'integer',
        'not_outs' => 'integer',
        'highest_score' => 'integer',
        'highest_score_not_out' => 'boolean',
        'batting_average' => 'decimal:2',
        'balls_faced' => 'integer',
        'batting_strike_rate' => 'decimal:2',
        'centuries' => 'integer',
        'half_centuries' => 'integer',
        'fours' => 'integer',
        'sixes' => 'integer',
        'total_wickets' => 'integer',
        'bowling_average' => 'decimal:2',
        'economy_rate' => 'decimal:2',
        'maidens' => 'integer',
        'overs_bowled_career' => 'decimal:1',
        'five_wicket_hauls' => 'integer',
        'runs_conceded' => 'integer',
        'catches' => 'integer',
        'run_outs' => 'integer',
        'stumpings' => 'integer',
        'recent_scores' => 'array',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (PlayerCareerStats $stats): void {
            if (empty($stats->id)) {
                $stats->id = (string) Str::orderedUuid();
            }
        });
    }

    public function player()
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function club()
    {
        return $this->belongsTo(Club::class, 'club_id');
    }

    /**
     * Compute batting average (runs / dismissals).
     * Null if no dismissals (infinite average — return total runs).
     */
    public function getBattingAverageAttribute(): ?float
    {
        $dismissals = $this->total_innings - $this->not_outs;
        if ($dismissals <= 0) return null;
        return round($this->total_runs / $dismissals, 2);
    }

    /**
     * Compute bowling average (runs conceded / wickets).
     */
    public function getBowlingAverageComputedAttribute(): ?float
    {
        if ($this->total_wickets <= 0) return null;
        return round($this->runs_conceded / $this->total_wickets, 2);
    }
}
