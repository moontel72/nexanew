<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class PointsTable extends Model
{
    protected $table = 'cricket_points_table';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'tournament_id', 'team_id',
        'matches_played', 'won', 'lost', 'tied', 'no_result',
        'points', 'net_run_rate',
        'runs_for', 'overs_faced', 'runs_against', 'overs_bowled',
        'rank_position',
    ];

    protected $casts = [
        'matches_played' => 'integer',
        'won' => 'integer',
        'lost' => 'integer',
        'tied' => 'integer',
        'no_result' => 'integer',
        'points' => 'integer',
        'net_run_rate' => 'decimal:3',
        'runs_for' => 'integer',
        'overs_faced' => 'decimal:1',
        'runs_against' => 'integer',
        'overs_bowled' => 'decimal:1',
        'rank_position' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (PointsTable $pt): void {
            if (empty($pt->id)) {
                $pt->id = (string) Str::orderedUuid();
            }
        });
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    public function team()
    {
        return $this->belongsTo(Team::class, 'team_id');
    }
}
