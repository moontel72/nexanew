<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReplayClip extends Model
{
    use HasUuids;

    protected $table = 'cricket_replay_clips';

    protected $fillable = [
        'match_id', 'event_id', 'clip_file_path',
        'buffer_before_ms', 'buffer_after_ms', 'playback_speed',
        'is_published', 'published_at',
    ];

    protected $casts = [
        'buffer_before_ms' => 'integer',
        'buffer_after_ms' => 'integer',
        'playback_speed' => 'float',
        'is_published' => 'boolean',
        'published_at' => 'datetime',
    ];

    public function match(): BelongsTo
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function event(): BelongsTo
    {
        return $this->belongsTo(ReplayEvent::class, 'event_id');
    }
}
