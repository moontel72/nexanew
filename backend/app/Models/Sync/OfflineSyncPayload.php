<?php

namespace App\Models\Sync;

use Illuminate\Database\Eloquent\Model;

class OfflineSyncPayload extends Model
{
    protected $table = 'offline_sync_payloads';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_PENDING = 'pending';
    public const STATUS_PROCESSING = 'processing';
    public const STATUS_PROCESSED = 'processed';
    public const STATUS_FAILED = 'failed';
    public const STATUS_DUPLICATE = 'duplicate';

    protected $fillable = [
        'id', 'user_id', 'device_id', 'app_module', 'payload_type',
        'payload_data', 'client_uuid', 'client_timestamp',
        'status', 'attempts', 'processing_notes',
        'resolved_conflicts', 'processed_at',
    ];

    protected $casts = [
        'payload_data' => 'array',
        'resolved_conflicts' => 'array',
        'client_timestamp' => 'datetime',
        'processed_at' => 'datetime',
        'attempts' => 'integer',
    ];

    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopeForModule($query, string $module)
    {
        return $query->where('app_module', $module);
    }

    /**
     * Check if a client_uuid has already been processed (idempotency).
     */
    public static function isDuplicate(string $clientUuid): bool
    {
        return static::where('client_uuid', $clientUuid)
            ->whereIn('status', [self::STATUS_PROCESSED, self::STATUS_DUPLICATE])
            ->exists();
    }
}
