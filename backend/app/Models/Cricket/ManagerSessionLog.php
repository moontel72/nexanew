<?php

namespace App\Models\Cricket;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class ManagerSessionLog extends Model
{
    protected $table = 'cricket_manager_session_logs';

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'cricket_manager_id',
        'match_id',
        'action',
        'metadata',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (ManagerSessionLog $log): void {
            if (empty($log->id)) {
                $log->id = (string) Str::orderedUuid();
            }
        });
    }

    public function cricketManager()
    {
        return $this->belongsTo(CricketManager::class, 'cricket_manager_id');
    }
}
