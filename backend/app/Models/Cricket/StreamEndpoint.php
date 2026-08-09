<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class StreamEndpoint extends Model
{
    use SoftDeletes;

    protected $table = 'cricket_streams';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'match_id',
        'camera_label',
        'camera_number',
        'rtmp_ingest_url',
        'rtmp_stream_key',
        'hls_playlist_url',
        'stream_status',
        'is_primary',
        'failover_priority',
        'last_activated_by_manager_id',
        'last_live_at',
    ];

    protected $casts = [
        'camera_number' => 'integer',
        'is_primary' => 'boolean',
        'failover_priority' => 'integer',
        'last_live_at' => 'datetime',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (StreamEndpoint $stream): void {
            if (empty($stream->id)) {
                $stream->id = (string) Str::orderedUuid();
            }
        });
    }

    public function match()
    {
        return $this->belongsTo(MatchModel::class, 'match_id');
    }
}
