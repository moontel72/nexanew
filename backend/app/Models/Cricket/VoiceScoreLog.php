<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class VoiceScoreLog extends Model
{
    protected $table = 'cricket_voice_score_logs';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'cricket_manager_id',
        'raw_transcript',
        'parsed_score_data',
        'was_applied',
        'ai_response',
        'processing_time_ms',
        'status',
        'error_message',
    ];

    protected $casts = [
        'parsed_score_data' => 'array',
        'was_applied' => 'boolean',
        'processing_time_ms' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (VoiceScoreLog $log): void {
            if (empty($log->id)) {
                $log->id = (string) Str::orderedUuid();
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
