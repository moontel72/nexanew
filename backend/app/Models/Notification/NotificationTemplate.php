<?php

namespace App\Models\Notification;

use Illuminate\Database\Eloquent\Model;

class NotificationTemplate extends Model
{
    protected $table = 'notification_templates';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id', 'template_key', 'name', 'channel',
        'subject', 'body_template', 'placeholders', 'metadata',
    ];

    protected $casts = [
        'placeholders' => 'array',
        'metadata' => 'array',
    ];

    public function render(array $data = []): string
    {
        $body = $this->body_template;
        foreach ($data as $key => $value) {
            $body = str_replace("{{$key}}", (string) $value, $body);
        }
        return $body;
    }

    public function renderSubject(array $data = []): string
    {
        if (! $this->subject) return '';
        $subject = $this->subject;
        foreach ($data as $key => $value) {
            $subject = str_replace("{{$key}}", (string) $value, $subject);
        }
        return $subject;
    }
}
