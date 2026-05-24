<?php

namespace App\Models\Notification;

use Illuminate\Database\Eloquent\Model;

class UserNotificationPreference extends Model
{
    protected $table = 'user_notification_preferences';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'user_id', 'notification_type',
        'channel_preferences', 'is_enabled',
    ];

    protected $casts = [
        'channel_preferences' => 'array',
        'is_enabled' => 'boolean',
    ];

    /**
     * Check if a channel is enabled for this notification type.
     */
    public function isChannelEnabled(string $channel): bool
    {
        if (! $this->is_enabled) return false;
        return (bool) ($this->channel_preferences[$channel] ?? true);
    }

    /**
     * Get all enabled channels for this notification type.
     */
    public function enabledChannels(): array
    {
        if (! $this->is_enabled) return [];
        return array_keys(array_filter($this->channel_preferences ?? [], fn($v) => (bool) $v));
    }
}
