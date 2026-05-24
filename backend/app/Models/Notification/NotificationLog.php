<?php

namespace App\Models\Notification;

use Illuminate\Database\Eloquent\Model;

class NotificationLog extends Model
{
    protected $table = 'notification_logs';
    public $incrementing = false;
    protected $keyType = 'string';

    public const STATUS_QUEUED = 'queued';
    public const STATUS_SENDING = 'sending';
    public const STATUS_DELIVERED = 'delivered';
    public const STATUS_FAILED = 'failed';
    public const STATUS_BOUNCED = 'bounced';
    public const STATUS_OPTED_OUT = 'opted_out';

    protected $fillable = [
        'id', 'company_id', 'user_id', 'channel', 'type',
        'status', 'content', 'metadata',
        'attempts', 'delivered_at', 'failed_at', 'failure_reason',
    ];

    protected $casts = [
        'metadata' => 'array',
        'attempts' => 'integer',
        'delivered_at' => 'datetime',
        'failed_at' => 'datetime',
    ];
}
