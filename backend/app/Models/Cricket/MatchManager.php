<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class MatchManager extends Model
{
    protected $table = 'cricket_match_managers';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'cricket_manager_id',
        'role',
        'is_active_session',
        'last_heartbeat_at',
    ];

    protected $casts = [
        'is_active_session' => 'boolean',
        'last_heartbeat_at' => 'datetime',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (MatchManager $mm): void {
            if (empty($mm->id)) {
                $mm->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function cricketManager()
    {
        return $this->belongsTo(CricketManager::class, 'cricket_manager_id');
    }
}
