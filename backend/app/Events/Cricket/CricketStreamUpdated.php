<?php

namespace App\Events\Cricket;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * CricketStreamUpdated — Director-style stream context change.
 *
 * Fired whenever the Cricket Manager activates or deactivates a camera
 * stream. The public player on cricket.traceodd.com listens for this
 * event and switches the program feed instantly — the manager acts as
 * the broadcast director.
 *
 * Uses ShouldBroadcastNow for immediate dispatch (no queue delay).
 */
class CricketStreamUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public string $matchId;

    /** Active program stream payload, or null when nothing is live. */
    public ?array $activeStream;

    public function __construct(string $matchId, ?array $activeStream)
    {
        $this->matchId = $matchId;
        $this->activeStream = $activeStream;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel('cricket.match.' . $this->matchId),
        ];
    }

    public function broadcastAs(): string
    {
        return 'stream.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'match_id' => $this->matchId,
            'active_stream' => $this->activeStream,
            'timestamp' => now()->toIso8601String(),
        ];
    }
}
