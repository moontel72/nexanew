<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ReplayEvent extends Model
{
    use HasUuids;

    protected $table = 'cricket_replay_events';

    protected $fillable = [
        'match_id', 'chunk_id', 'event_type', 'frame_timestamp',
        'annotation', 'tagged_by_cricket_manager_id', 'is_published',
    ];

    protected $casts = [
        'frame_timestamp' => 'integer',
        'is_published' => 'boolean',
    ];

    public function match(): BelongsTo
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function chunk(): BelongsTo
    {
        return $this->belongsTo(ReplayChunk::class, 'chunk_id');
    }

    public function manager(): BelongsTo
    {
        return $this->belongsTo(CricketManager::class, 'tagged_by_cricket_manager_id');
    }

    public function clips(): HasMany
    {
        return $this->hasMany(ReplayClip::class, 'event_id');
    }
}
