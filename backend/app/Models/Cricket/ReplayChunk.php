<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ReplayChunk extends Model
{
    use HasUuids;

    protected $table = 'cricket_replay_chunks';

    protected $fillable = [
        'match_id', 'chunk_counter', 'file_path',
        'start_timestamp', 'end_timestamp', 'duration_seconds',
        'file_size_bytes', 'is_complete',
    ];

    protected $casts = [
        'start_timestamp' => 'datetime',
        'end_timestamp' => 'datetime',
        'chunk_counter' => 'integer',
        'duration_seconds' => 'integer',
        'file_size_bytes' => 'integer',
        'is_complete' => 'boolean',
    ];

    public function match(): BelongsTo
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }

    public function events(): HasMany
    {
        return $this->hasMany(ReplayEvent::class, 'chunk_id');
    }
}
